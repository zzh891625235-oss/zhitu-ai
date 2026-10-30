package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.PromptLibrary;
import com.zhitu.dto.Result;
import com.zhitu.entity.AiChat;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.AiChatMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

@RestController
@RequestMapping("/api")
public class AiChatController {

    private static final Logger log = LoggerFactory.getLogger(AiChatController.class);

    private final AIService aiService;
    private final AiChatMapper chatMapper;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiChatController(AIService aiService, AiChatMapper chatMapper,
                            StudentProfileMapper profileMapper, MajorMapper majorMapper) {
        this.aiService = aiService;
        this.chatMapper = chatMapper;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
    }

    /** AI 对话（一次性返回） */
    @PostMapping("/ai/chat")
    public Result<Map<String, Object>> chat(Authentication auth, @RequestBody Map<String, Object> body) {
        Long userId = (Long) auth.getPrincipal();
        String question = (String) body.get("question");
        String type = (String) body.getOrDefault("type", "GENERAL");

        String answer = aiService.chatForUser(userId, getSystemPrompt(type, majorName(userId)), question);
        saveChat(userId, type, question, answer);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("answer", answer);
        result.put("real", Boolean.TRUE.equals(aiService.status(userId).get("lastCallReal")));
        return Result.success(result);
    }

    /**
     * AI 对话（流式）。
     *
     * 采用 NDJSON（每行一个 JSON 对象）而非标准 SSE：
     * 模型输出中包含大量换行，标准 SSE 的 `data:` 单行格式会把换行后的内容丢掉，
     * 而 NDJSON 由前端按行读取，可以完整保留 Markdown 的结构。
     *
     * 每行格式：{"type":"delta"|"done"|"error","text":"..."}
     */
    @PostMapping(value = "/ai/chat-stream", produces = "application/x-ndjson;charset=UTF-8")
    public void chatStream(Authentication auth,
                           @RequestBody Map<String, Object> body,
                           HttpServletResponse response) throws IOException {
        Long userId = (Long) auth.getPrincipal();
        String question = (String) body.get("question");
        String type = (String) body.getOrDefault("type", "GENERAL");

        response.setContentType("application/x-ndjson;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-transform");
        response.setHeader("X-Accel-Buffering", "no");

        PrintWriter writer = response.getWriter();
        if (question == null || question.trim().isEmpty()) {
            writeLine(writer, "error", "问题不能为空");
            return;
        }

        StringBuilder full = new StringBuilder();
        try {
            aiService.chatStreamForUser(userId, getSystemPrompt(type, majorName(userId)), question, delta -> {
                full.append(delta);
                writeLine(writer, "delta", delta);
            });
        } catch (Exception e) {
            log.error("流式对话失败", e);
            writeLine(writer, "error", "AI 服务异常，请稍后重试");
        }

        saveChat(userId, type, question, full.toString());

        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put("real", Boolean.TRUE.equals(aiService.status(userId).get("lastCallReal")));
        try {
            writeLine(writer, "done", objectMapper.writeValueAsString(meta));
        } catch (Exception e) {
            writeLine(writer, "done", "{\"real\":false}");
        }
    }

    /** 获取对话历史 */
    @GetMapping("/ai/chat-history")
    public Result<List<AiChat>> history(Authentication auth,
                                        @RequestParam(defaultValue = "GENERAL") String type) {
        Long userId = (Long) auth.getPrincipal();
        List<AiChat> chats = chatMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AiChat>()
                .eq(AiChat::getUserId, userId)
                .eq(AiChat::getChatType, type)
                .orderByDesc(AiChat::getCreatedAt)
                .last("LIMIT 20"));
        return Result.success(chats);
    }

    /** 清空某类型的对话历史 */
    @DeleteMapping("/ai/chat-history")
    public Result<?> clearHistory(Authentication auth,
                                  @RequestParam(defaultValue = "GENERAL") String type) {
        Long userId = (Long) auth.getPrincipal();
        chatMapper.delete(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AiChat>()
            .eq(AiChat::getUserId, userId)
            .eq(AiChat::getChatType, type));
        return Result.success("已清空");
    }

    /**
     * AI 服务状态。
     * 前端据此提示用户「当前是真实大模型输出」还是「离线模板模式」，
     * 避免把模板内容当成 AI 结果展示。
     */
    @GetMapping("/ai/status")
    public Result<Map<String, Object>> status(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return Result.success(aiService.status(userId));
    }

    // ================================================================

    private void saveChat(Long userId, String type, String question, String answer) {
        try {
            AiChat chat = new AiChat();
            chat.setUserId(userId);
            chat.setChatType(type);
            chat.setQuestion(question);
            chat.setAnswer(answer);
            chatMapper.insert(chat);
        } catch (Exception e) {
            log.warn("保存对话记录失败：{}", e.getMessage());
        }
    }

    private void writeLine(PrintWriter writer, String type, String text) {
        Map<String, Object> node = new LinkedHashMap<>();
        node.put("type", type);
        node.put("text", text);
        try {
            writer.write(objectMapper.writeValueAsString(node));
            writer.write('\n');
            writer.flush();
        } catch (Exception ignored) {
            // 客户端可能已断开，忽略写入失败
        }
    }

    /** 取该学生的专业名称；未填写档案时返回 null */
    private String majorName(Long userId) {
        try {
            StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
            if (p == null || p.getMajorId() == null) return null;
            Major m = majorMapper.selectById(p.getMajorId());
            return m == null ? null : m.getName();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 按对话模式构造系统提示。
     *
     * 实现已经统一收敛到 {@link com.zhitu.ai.PromptLibrary#scenePrompt}：
     * 普通对话与 Agent 两条链路共用同一套人设，避免同一个学生在两个入口拿到
     * 不同口径的回答。这里保留一层薄封装，只是为了不让调用点出现大范围改名。
     */
    private String getSystemPrompt(String type, String majorName) {
        return PromptLibrary.scenePrompt(type, majorName);
    }
}

