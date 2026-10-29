package com.zhitu.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.agent.AgentRuntime;
import com.zhitu.ai.agent.ToolOutcome;
import com.zhitu.ai.agent.ToolRegistry;
import com.zhitu.ai.rag.RagService;
import com.zhitu.dto.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Agent 接口层。
 *
 * <p>对外暴露四件事：
 * <ul>
 *   <li>{@code POST /api/agent/chat-stream} —— 一次完整的 Agent 对话，NDJSON 事件流；</li>
 *   <li>{@code GET  /api/agent/tools}       —— 工具清单（OpenAI tools 协议 + MCP inputSchema）；</li>
 *   <li>{@code POST /api/agent/tools/invoke}—— 直接执行一次工具调用（对接外部 MCP 客户端用）；</li>
 *   <li>{@code GET  /api/agent/rag-stats}   —— RAG 索引统计，用于验证检索真的在工作。</li>
 * </ul>
 */
@RestController
@RequestMapping("/api/agent")
public class AgentController {

    private static final Logger log = LoggerFactory.getLogger(AgentController.class);

    private final AgentRuntime runtime;
    private final ToolRegistry registry;
    private final RagService ragService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AgentController(AgentRuntime runtime, ToolRegistry registry, RagService ragService) {
        this.runtime = runtime;
        this.registry = registry;
        this.ragService = ragService;
    }

    /**
     * Agent 对话（NDJSON 事件流）。
     *
     * <p>为什么不用标准 SSE：模型输出里含有大量换行与 Markdown，标准 SSE 的
     * {@code data:} 单行格式会把换行后的内容截断。NDJSON 一行一个 JSON 对象，
     * 前端按行读，结构可以完整保留。
     *
     * <p>事件类型：
     * <pre>
     * status     {phase, text}                 阶段提示（检索 / 合成）
     * citations  {items:[{source,title,score,excerpt}]}  本次用到的知识库片段
     * mode       {mode, text}                  LLM_DRIVEN / RULE_DRIVEN
     * tool_call  {step,index,name,arguments,purpose}     调用了哪个工具
     * tool_result{name, ok, preview, dataDomain}         工具返回了什么
     * delta      {text}                        正文增量
     * verify     {mode, checkedFacts, suspects[]}        事实一致性校验结果
     * done       {real, mode, steps, tools[], ragHit}
     * blocked    {reason}                      被安全护栏拦截
     * </pre>
     */
    @PostMapping(value = "/chat-stream", produces = "application/x-ndjson;charset=UTF-8")
    public void chatStream(Authentication auth,
                           @RequestBody Map<String, Object> body,
                           HttpServletResponse response) throws IOException {
        Long userId = (Long) auth.getPrincipal();
        String question = body == null ? null : (String) body.get("question");
        String scene = body == null ? null : (String) body.getOrDefault("scene", "GENERAL");

        response.setContentType("application/x-ndjson;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-transform");
        response.setHeader("X-Accel-Buffering", "no");

        PrintWriter writer = response.getWriter();
        try {
            runtime.run(userId, question, scene, event -> {
                try {
                    writer.write(objectMapper.writeValueAsString(event));
                    writer.write('\n');
                    writer.flush();
                } catch (Exception e) {
                    log.debug("写入事件失败（客户端可能已断开）：{}", e.getMessage());
                }
            });
        } catch (Exception e) {
            log.error("Agent 运行失败", e);
            writeError(writer, "Agent 运行异常：" + e.getMessage());
        }
    }

    /**
     * 工具清单。
     * 同时给出 {@code tools}（OpenAI Function Calling 协议）与 {@code mcp}（MCP tools/list 形态），
     * 让外部 MCP 客户端可以直接发现并调用本平台的工具。
     */
    @GetMapping("/tools")
    public Result<Map<String, Object>> tools(Authentication auth) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("count", registry.all().size());
        data.put("tools", registry.manifest());
        data.put("protocol", "OpenAI Function Calling / MCP tools-list");
        return Result.success(data);
    }

    /**
     * 直接调用一个工具（MCP 风格 JSON-RPC 的 HTTP 化版本）。
     * 供 MCP Server 转发、也便于在接口层面单独验证某个工具是否正常。
     */
    @PostMapping("/tools/invoke")
    public Result<Map<String, Object>> invoke(Authentication auth, @RequestBody Map<String, Object> body) {
        Long userId = (Long) auth.getPrincipal();
        String name = body == null ? null : (String) body.get("name");
        if (name == null || name.isEmpty()) {
            return Result.error(400, "缺少工具名 name");
        }
        if (registry.get(name) == null) {
            return Result.error(404, "不存在的工具：" + name + "，可调用 GET /api/agent/tools 查看全部工具");
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> args = (Map<String, Object>) body.get("arguments");
        com.zhitu.ai.agent.AgentTool tool = registry.get(name);
        try {
            String result = tool.execute(userId, args);
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("tool", name);
            data.put("result", result);
            return Result.success(data);
        } catch (Exception e) {
            log.warn("工具 {} 执行失败：{}", name, e.getMessage());
            return Result.error(400, "工具执行失败：" + e.getMessage());
        }
    }

    /** RAG 索引统计 */
    @GetMapping("/rag-stats")
    public Result<Map<String, Object>> ragStats(Authentication auth) {
        return Result.success(ragService.stats());
    }

    private void writeError(PrintWriter writer, String message) {
        Map<String, Object> node = new LinkedHashMap<>();
        node.put("type", "error");
        node.put("text", message);
        try {
            writer.write(objectMapper.writeValueAsString(node));
            writer.write('\n');
            writer.flush();
        } catch (Exception ignored) {
            // 客户端已断开
        }
    }
}
