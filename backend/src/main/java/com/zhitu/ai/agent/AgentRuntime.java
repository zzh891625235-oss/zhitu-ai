package com.zhitu.ai.agent;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.ModelReply;
import com.zhitu.ai.PromptLibrary;
import com.zhitu.ai.guard.AiGuard;
import com.zhitu.ai.rag.RagService;
import com.zhitu.entity.AiChat;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.AiChatMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.function.Consumer;

/**
 * 成长 Agent 运行时 —— 本项目 AI 能力的核心。
 *
 * <h3>它到底做了什么</h3>
 * 一次问答被拆成四个阶段，每个阶段都向前端发出可见事件：
 * <ol>
 *   <li><b>护栏</b>：注入与违规内容检测，不通过直接终止；</li>
 *   <li><b>检索</b>：RAG 从本地知识库取回带编号的资料片段；</li>
 *   <li><b>工具循环</b>：把工具清单交给大模型，由它决定查什么（{@code LLM_DRIVEN}）；
 *       若模型不可用，退回 {@link RulePlanner} 的确定性编排（{@code RULE_DRIVEN}）；</li>
 *   <li><b>合成</b>：流式输出最终答案，并做一轮 hallucinations 事后校验。</li>
 * </ol>
 *
 * <h3>为什么不是「一次调用写完答案」</h3>
 * 单次 Prompt 有两个绕不过去的问题：一是模型看不到学生真实数据，只能编；
 * 二是即便塞了数据，也无法保证它真的用了。<b>工具调用强制模型显式声明「我要查什么」</b>，
 * 查到的东西会以 JSON 原样回灌，答案里的每个数字都能追溯到某次工具调用。
 * 这也是本项目对「AI 可解释性」给出的答卷。
 *
 * <h3>降级策略</h3>
 * 没有 API Key 时依然可用：工具照样真实执行、数据照样来自数据库，
 * 只是由 {@link OfflineComposer} 依据规则合成文本。功能降级，诚实不降级。
 */
@Component
public class AgentRuntime {

    private static final Logger log = LoggerFactory.getLogger(AgentRuntime.class);

    /** 单次问答允许的最大工具轮次，防止模型陷入无限调用拖垮响应 */
    public static final int MAX_STEPS = 4;

    private final ToolRegistry registry;
    private final AIService aiService;
    private final RagService ragService;
    private final AiGuard guard;
    private final RulePlanner rulePlanner;
    private final OfflineComposer composer;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;
    private final AiChatMapper chatMapper;
    private final ObjectMapper om = new ObjectMapper();

    public AgentRuntime(ToolRegistry registry, AIService aiService, RagService ragService, AiGuard guard,
                        RulePlanner rulePlanner, OfflineComposer composer, StudentProfileMapper profileMapper,
                        MajorMapper majorMapper, AiChatMapper chatMapper) {
        this.registry = registry;
        this.aiService = aiService;
        this.ragService = ragService;
        this.guard = guard;
        this.rulePlanner = rulePlanner;
        this.composer = composer;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
        this.chatMapper = chatMapper;
    }

    /** 一次 Agent 运行的产出摘要 */
    public static class AgentResult {
        private final String answer;
        private final List<String> tools;
        private final boolean real;
        private final String mode;

        public AgentResult(String answer, List<String> tools, boolean real, String mode) {
            this.answer = answer;
            this.tools = tools;
            this.real = real;
            this.mode = mode;
        }

        public String getAnswer() {
            return answer;
        }

        public List<String> getTools() {
            return tools;
        }

        public boolean isReal() {
            return real;
        }

        /** LLM_DRIVEN / RULE_DRIVEN / BLOCKED */
        public String getMode() {
            return mode;
        }
    }

    /**
     * 执行一轮 Agent 对话。
     *
     * @param sink 事件回调，每个事件是一个 Map（含 type 字段），由 Controller 逐行写给前端
     */
    public AgentResult run(Long userId, String question, String scene, Consumer<Map<String, Object>> sink) {
        String type = scene == null || scene.isEmpty() ? "GENERAL" : scene;

        // ---------- 阶段 0：入口护栏 ----------
        AiGuard.InputVerdict verdict = guard.verifyInput(question);
        if (!verdict.isAllowed()) {
            emit(sink, "blocked", "reason", verdict.getReason());
            return new AgentResult(verdict.getReason(), Collections.<String>emptyList(), false, "BLOCKED");
        }
        String q = guard.maskSecrets(verdict.getSanitized());
        String majorName = majorNameOf(userId);

        // ---------- 阶段 1：RAG 检索 ----------
        emit(sink, "status", "phase", "retrieval", "text", "正在本地知识库检索相关资料…");
        List<RagService.Citation> citations = ragService.search(q, majorName, 4);
        emit(sink, "citations", "items", citationItems(citations));

        List<String> facts = new ArrayList<>();
        for (RagService.Citation c : citations) {
            facts.add(c.getTitle());
        }

        List<Map<String, Object>> messages = new ArrayList<>();
        messages.add(message("user", "content", q));
        StringBuilder toolContext = new StringBuilder();
        List<ToolOutcome> outcomes = new ArrayList<>();
        List<String> executedNames = new ArrayList<>();

        // ---------- 阶段 2：工具循环 ----------
        List<Map<String, Object>> toolsPayload = registry.openAiTools();
        ModelReply reply = aiService.chatWithTools(
                PromptLibrary.agentPlannerPrompt(type, majorName, 1, MAX_STEPS), messages, toolsPayload, userId);
        boolean llm = reply != null;

        if (llm) {
            emit(sink, "mode", "mode", "LLM_DRIVEN", "text", "已连接大模型，由模型自主决定调用哪些工具");
            int step = 1;
            while (reply != null && reply.hasToolCalls() && step <= MAX_STEPS) {
                messages.add(assistantToolCallsMessage(reply));
                int idx = 0;
                for (ModelReply.ToolCall call : reply.getToolCalls()) {
                    idx++;
                    Map<String, Object> args = parseArguments(call.getArguments());
                    AgentTool tool = registry.get(call.getName());
                    if (tool == null) {
                        String unavailable = "{\"error\":\"不存在的工具 " + call.getName() + "\"}";
                        messages.add(toolMessage(call.getId(), unavailable));
                        emit(sink, "tool_result", "name", call.getName(), "ok", false, "preview", unavailable);
                        continue;
                    }
                    emit(sink, "tool_call", "step", step, "index", idx, "name", tool.name(),
                            "arguments", args, "purpose", tool.dataDomain());
                    String result = executeQuietly(userId, tool, args, name -> executedNames.add(name));
                    String preview = result.length() <= 160 ? result.replaceAll("\\s+", " ")
                            : result.replaceAll("\\s+", " ").substring(0, 160) + "…";
                    emit(sink, "tool_result", "name", tool.name(), "ok", true, "preview", preview,
                            "dataDomain", tool.dataDomain());
                    outcomes.add(new ToolOutcome(step, tool.name(), tool.dataDomain(), args, result, true,
                            tool.dataDomain()));
                    facts.addAll(collectFacts(result));
                    toolContext.append("### ").append(tool.name()).append("\n").append(result).append("\n\n");
                    messages.add(toolMessage(call.getId(), result));
                }
                step++;
                reply = aiService.chatWithTools(
                        PromptLibrary.agentPlannerPrompt(type, majorName, step, MAX_STEPS),
                        messages, toolsPayload, userId);
            }
        } else {
            emit(sink, "mode", "mode", "RULE_DRIVEN", "text", "未连接大模型，改用本地规则编排（工具数据依然真实）");
            List<RulePlanner.PlanStep> plan = rulePlanner.plan(q);
            int idx = 0;
            for (RulePlanner.PlanStep ps : plan) {
                idx++;
                AgentTool tool = registry.get(ps.tool);
                if (tool == null) {
                    continue;
                }
                Map<String, Object> args = rulePlanner.argumentsFor(ps.tool, q);
                emit(sink, "tool_call", "step", 1, "index", idx, "name", tool.name(),
                        "arguments", args, "purpose", ps.purpose);
                String result = executeQuietly(userId, tool, args, name -> executedNames.add(name));
                String preview = result.replaceAll("\\s+", " ");
                preview = preview.length() <= 160 ? preview : preview.substring(0, 160) + "…";
                emit(sink, "tool_result", "name", tool.name(), "ok", true, "preview", preview,
                        "dataDomain", tool.dataDomain());
                outcomes.add(new ToolOutcome(1, tool.name(), ps.purpose, args, result, true, tool.dataDomain()));
                facts.addAll(collectFacts(result));
                toolContext.append("### ").append(tool.name()).append("\n").append(result).append("\n\n");
            }
        }

        // ---------- 阶段 3：合成最终答案 ----------
        emit(sink, "status", "phase", "compose", "text", "正在整合资料，生成建议…");
        String answer;
        boolean real = false;
        String directAnswer = llm && reply != null ? reply.getContent() : null;

        if (llm && outcomes.isEmpty() && directAnswer != null && !directAnswer.trim().isEmpty()) {
            // 模型判断无需查任何工具（闲聊、纯概念题），直接采用它的回答
            emit(sink, "delta", "text", directAnswer);
            answer = directAnswer;
            real = true;
        } else if (llm) {
            String systemPrompt = PromptLibrary.finalAnswerPrompt(
                    type, majorName, ragService.renderContext(citations), toolContext.toString());
            StringBuilder buf = new StringBuilder();
            try {
                aiService.chatStreamForUser(userId, systemPrompt, q, delta -> {
                    buf.append(delta);
                    emit(sink, "delta", "text", delta);
                });
                answer = buf.toString();
                real = Boolean.TRUE.equals(aiService.status(userId).get("lastCallReal"));
            } catch (Exception e) {
                log.warn("流式合成失败，改用离线合成：{}", e.getMessage());
                answer = composer.compose(q, outcomes, citations);
                streamAsTyping(sink, answer);
            }
            if (answer == null || answer.trim().isEmpty()) {
                answer = composer.compose(q, outcomes, citations);
                streamAsTyping(sink, answer);
            }
        } else {
            answer = composer.compose(q, outcomes, citations);
            streamAsTyping(sink, answer);
        }

        // ---------- 阶段 4：事后校验 + 收尾 ----------
        List<String> suspects = guard.suspectClaims(answer, facts);
        emit(sink, "verify", "mode", llm ? "LLM_DRIVEN" : "RULE_DRIVEN", "checkedFacts", facts.size(),
                "suspects", suspects);
        emit(sink, "done", "real", real, "mode", llm ? "LLM_DRIVEN" : "RULE_DRIVEN",
                "steps", outcomes.size(), "tools", executedNames, "ragHit", citations.size());

        saveChat(userId, type, q, answer);
        return new AgentResult(answer, executedNames, real, llm ? "LLM_DRIVEN" : "RULE_DRIVEN");
    }

    // ================================================================
    // 内部实现
    // ================================================================

    /** 执行工具并吞掉异常：工具出问题不该让整轮对话崩掉，而要让模型知道这条路走不通 */
    private String executeQuietly(Long userId, AgentTool tool, Map<String, Object> args, Consumer<String> onName) {
        try {
            String r = tool.execute(userId, args);
            if (onName != null) {
                onName.accept(tool.name());
            }
            return r == null || r.isEmpty() ? "{\"empty\":true}" : r;
        } catch (Exception e) {
            log.warn("工具执行失败：{} / {}", tool.name(), e.getMessage());
            return "{\"error\":\"工具执行失败：" + String.valueOf(e.getMessage()).replace("\"", "'") + "\"}";
        }
    }

    /** 离线答案没有流式来源，这里切成小块推送，保留打字机效果 */
    private void streamAsTyping(Consumer<Map<String, Object>> sink, String text) {
        if (text == null || text.isEmpty()) {
            return;
        }
        int pos = 0;
        while (pos < text.length()) {
            int end = Math.min(text.length(), pos + 14);
            emit(sink, "delta", "text", text.substring(pos, end));
            pos = end;
        }
    }

    private Map<String, Object> parseArguments(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return new LinkedHashMap<>();
        }
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> map = om.readValue(raw, Map.class);
            return map;
        } catch (Exception e) {
            // 少数模型会把参数写成 key=value 或带多余括号，这里做一次宽容处理
            Map<String, Object> fallback = new LinkedHashMap<>();
            fallback.put("_raw", raw);
            return fallback;
        }
    }

    /** 从工具返回的 JSON 里抽取可能作为「事实」的字段，用于最终答案的事实一致性校验 */
    private List<String> collectFacts(String json) {
        List<String> names = new ArrayList<>();
        if (json == null || json.isEmpty() || json.charAt(0) != '{' && json.charAt(0) != '[') {
            return names;
        }
        try {
            collectNames(om.readTree(json), names);
        } catch (Exception ignored) {
            // 非 JSON 结果不做抽取
        }
        return names;
    }

    private void collectNames(JsonNode node, List<String> out) {
        if (node == null) {
            return;
        }
        if (node.isObject()) {
            Iterator<Map.Entry<String, JsonNode>> it = node.fields();
            while (it.hasNext()) {
                Map.Entry<String, JsonNode> e = it.next();
                String key = e.getKey();
                JsonNode v = e.getValue();
                if (("name".equals(key) || "title".equals(key)) && v.isTextual()) {
                    out.add(v.asText());
                } else {
                    collectNames(v, out);
                }
            }
        } else if (node.isArray()) {
            for (JsonNode n : node) {
                collectNames(n, out);
            }
        }
    }

    private Map<String, Object> message(String role, String key, Object value) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("role", role);
        m.put(key, value);
        return m;
    }

    private Map<String, Object> toolMessage(String toolCallId, String content) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("role", "tool");
        m.put("tool_call_id", toolCallId == null ? "" : toolCallId);
        m.put("content", content);
        return m;
    }

    private Map<String, Object> assistantToolCallsMessage(ModelReply reply) {
        List<Map<String, Object>> calls = new ArrayList<>();
        for (ModelReply.ToolCall c : reply.getToolCalls()) {
            Map<String, Object> fn = new LinkedHashMap<>();
            fn.put("name", c.getName());
            fn.put("arguments", c.getArguments());
            Map<String, Object> one = new LinkedHashMap<>();
            one.put("id", c.getId());
            one.put("type", "function");
            one.put("function", fn);
            calls.add(one);
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("role", "assistant");
        m.put("content", reply.getContent() == null ? "" : reply.getContent());
        m.put("tool_calls", calls);
        return m;
    }

    private List<Map<String, Object>> citationItems(List<RagService.Citation> citations) {
        List<Map<String, Object>> items = new ArrayList<>();
        for (RagService.Citation c : citations) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", c.getId());
            m.put("source", c.getSource());
            m.put("title", c.getTitle());
            m.put("score", c.getScore());
            String text = c.getText().replaceAll("\\s+", " ").trim();
            m.put("excerpt", text.length() > 140 ? text.substring(0, 140) + "…" : text);
            items.add(m);
        }
        return items;
    }

    private String majorNameOf(Long userId) {
        try {
            StudentProfile p = profileMapper.selectOne(
                    new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
            if (p == null || p.getMajorId() == null) {
                return null;
            }
            Major m = majorMapper.selectById(p.getMajorId());
            return m == null ? null : m.getName();
        } catch (Exception e) {
            return null;
        }
    }

    private void saveChat(Long userId, String type, String question, String answer) {
        try {
            AiChat chat = new AiChat();
            chat.setUserId(userId);
            // 按场景分别存历史，切换模式时各自维护上下文
            chat.setChatType(type);
            chat.setQuestion(question);
            chat.setAnswer(answer);
            chatMapper.insert(chat);
        } catch (Exception e) {
            log.warn("保存 Agent 对话记录失败：{}", e.getMessage());
        }
    }

    /** 事件发射：把 (k,v) 变参组装成有序 Map，第一个字段固定为 type */
    private void emit(Consumer<Map<String, Object>> sink, String type, Object... kv) {
        if (sink == null) {
            return;
        }
        Map<String, Object> event = new LinkedHashMap<>();
        event.put("type", type);
        for (int i = 0; i + 1 < kv.length; i += 2) {
            event.put(String.valueOf(kv[i]), kv[i + 1]);
        }
        event.put("ts", System.currentTimeMillis());
        sink.accept(event);
    }
}
