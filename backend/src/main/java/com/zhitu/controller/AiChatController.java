package com.zhitu.controller;

import com.zhitu.ai.AIService;
import com.zhitu.dto.Result;
import com.zhitu.entity.AiChat;
import com.zhitu.mapper.AiChatMapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api")
public class AiChatController {

    private final AIService aiService;
    private final AiChatMapper chatMapper;

    public AiChatController(AIService aiService, AiChatMapper chatMapper) {
        this.aiService = aiService;
        this.chatMapper = chatMapper;
    }

    /** AI对话 */
    @PostMapping("/ai/chat")
    public Result<Map<String, String>> chat(Authentication auth, @RequestBody Map<String, Object> body) {
        Long userId = (Long) auth.getPrincipal();
        String question = (String) body.get("question");
        String type = (String) body.getOrDefault("type", "GENERAL");

        // 根据类型选择系统提示词
        String systemPrompt = getSystemPrompt(type);

        String answer = aiService.chatForUser(userId, systemPrompt, question);

        // 保存对话记录
        AiChat chat = new AiChat();
        chat.setUserId(userId);
        chat.setChatType(type);
        chat.setQuestion(question);
        chat.setAnswer(answer);
        chatMapper.insert(chat);

        Map<String, String> result = new LinkedHashMap<>();
        result.put("answer", answer);
        return Result.success(result);
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

    private String getSystemPrompt(String type) {
        switch (type) {
            case "LEARNING":
                return "你是编程学习导师。用通俗易懂的语言解释计算机概念。用生活中的例子帮助理解。回答控制在200字以内。";
            case "CAREER":
                return "你是职业规划顾问。针对大学生的职业困惑，给出具体可操作的建议。不要空泛。";
            case "COMPETITION":
                return "你是竞赛辅导老师。帮学生分析比赛策略、准备方法。给出有实操性的建议。";
            default:
                return "你是智途AI助手。帮助大学生解决学习、成长、规划方面的问题。回答简洁专业。";
        }
    }
}

