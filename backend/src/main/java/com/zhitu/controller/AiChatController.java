package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.MajorDirection;
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
     * majorName 会以「【专业:xxx】」的形式写进提示开头：既让模型知道自己在跟
     * 哪个专业的学生对话，也让离线兜底（DeepSeekProvider.fallback）能解析出
     * 专业方向，避免给非计算机专业的学生返回 Java / 蓝桥杯 / 408 那一套内容。
     */
    private String getSystemPrompt(String type, String majorName) {
        boolean it = majorName == null || MajorDirection.isIT(majorName);
        String base;
        switch (type) {
            case "LEARNING":
                base = it
                    ? "你是编程学习导师。用通俗易懂的语言解释计算机概念，多用生活中的类比。"
                      + "回答控制在 200 字以内，涉及代码时给出最小可运行的示例。"
                    : "你是专业课学习导师。针对学生所学专业的概念与课程难点，用通俗易懂的语言讲解，"
                      + "多用生活中的类比，必要时给出具体的学习步骤或示例。回答控制在 200 字以内。";
                break;
            case "CAREER":
                base = (it ? "你是面向计算机专业大学生的职业规划顾问。" : "你是面向大学生的职业规划顾问。")
                     + "针对职业困惑给出具体、可执行、有时间节点的建议，不要空泛。结合当前就业市场实际情况。";
                break;
            case "COMPETITION":
                base = "你是竞赛辅导老师。帮学生分析赛事选择、备赛节奏、拿奖策略，"
                     + "给出可操作的训练计划与资源建议。只推荐与学生专业方向相关的竞赛。";
                break;
            case "INTERVIEW":
                base = (it ? "你是技术面试官。" : "你是面试官。")
                     + "针对大学生求职面试进行模拟提问与点评：先抛出 1-2 个有区分度的问题，"
                     + "等学生回答后给出具体反馈（哪里答得好、哪里遗漏、标准答案要点），再追问下一个问题。"
                     + "语气专业但不打击人。";
                break;
            default:
                base = "你是智途AI助手，服务对象是中国大学生。帮助解决学习、成长、规划方面的问题，"
                     + "回答简洁专业、条理清晰，优先使用 Markdown 列表和加粗突出要点。";
        }
        if (majorName != null && !majorName.isEmpty()) {
            MajorDirection dir = MajorDirection.resolve(majorName);
            base = "【专业:" + majorName + "】学生专业为「" + majorName + "」，方向属「" + dir.label() + "」。\n" + base;
        }
        return base;
    }
}
