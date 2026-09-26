package com.zhitu.ai;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Component
@ConditionalOnProperty(name = "ai.provider", havingValue = "deepseek", matchIfMissing = true)
public class DeepSeekProvider implements AIService {

    @Value("${ai.api-url}")
    private String apiUrl;

    @Value("${ai.api-key}")
    private String apiKey;

    @Value("${ai.model}")
    private String model;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public String chat(String systemPrompt, String userMessage) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, String> sysMsg = new LinkedHashMap<>();
        sysMsg.put("role", "system");
        sysMsg.put("content", systemPrompt);

        Map<String, String> usrMsg = new LinkedHashMap<>();
        usrMsg.put("role", "user");
        usrMsg.put("content", userMessage);

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(sysMsg);
        messages.add(usrMsg);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model);
        body.put("messages", messages);
        body.put("temperature", 0.7);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(
            apiUrl + "/chat/completions", entity, Map.class);

        Map<String, Object> respBody = response.getBody();
        if (respBody != null && respBody.containsKey("choices")) {
            List<Map<String, Object>> choices = (List<Map<String, Object>>) respBody.get("choices");
            if (!choices.isEmpty()) {
                Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                return (String) message.get("content");
            }
        }
        return "AI服务暂时不可用";
    }
}
