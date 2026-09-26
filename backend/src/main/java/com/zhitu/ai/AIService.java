package com.zhitu.ai;

public interface AIService {
    String chat(String systemPrompt, String userMessage);
    String chatWithKey(String systemPrompt, String userMessage, String apiKey, String apiUrl, String model);
    String chatForUser(Long userId, String systemPrompt, String userMessage);
    String getUserApiKey(Long userId);
}
