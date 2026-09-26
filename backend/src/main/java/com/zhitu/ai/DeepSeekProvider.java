package com.zhitu.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.entity.UserSettings;
import com.zhitu.mapper.UserSettingsMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Component
@ConditionalOnProperty(name = "ai.provider", havingValue = "deepseek", matchIfMissing = true)
public class DeepSeekProvider implements AIService {

    @Value("${ai.api-key}") private String systemApiKey;
    @Value("${ai.api-url}") private String systemApiUrl;
    @Value("${ai.model}") private String systemModel;
    private final UserSettingsMapper settingsMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    public DeepSeekProvider(UserSettingsMapper settingsMapper) { this.settingsMapper = settingsMapper; }

    @Override
    public String chat(String systemPrompt, String userMessage) {
        return chatWithKey(systemPrompt, userMessage, systemApiKey, systemApiUrl, systemModel);
    }

    @Override
    public String chatForUser(Long userId, String systemPrompt, String userMessage) {
        String key = getUserApiKey(userId);
        String url = getUserApiUrl(userId);
        String model = getUserModel(userId);
        return chatWithKey(systemPrompt, userMessage, key, url, model);
    }

    @Override
    public String chatWithKey(String systemPrompt, String userMessage, String apiKey, String apiUrl, String model) {
        if (apiKey != null && !apiKey.isEmpty() && !apiKey.contains("your-api-key")) {
            try {
                String real = callAPI(systemPrompt, userMessage, apiKey, apiUrl, model);
                if (real != null && !real.isEmpty()) return real;
            } catch (Exception ignored) {}
        }
        return fallback(systemPrompt, userMessage);
    }

    @Override
    public String getUserApiKey(Long userId) {
        try {
            UserSettings s = settingsMapper.selectOne(new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));
            if (s != null && s.getApiKey() != null && !s.getApiKey().isEmpty()) return s.getApiKey();
        } catch (Exception ignored) {}
        return systemApiKey;
    }

    private String getUserApiUrl(Long userId) {
        try {
            UserSettings s = settingsMapper.selectOne(new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));
            if (s != null && s.getApiUrl() != null) return s.getApiUrl();
        } catch (Exception ignored) {}
        return systemApiUrl;
    }

    private String getUserModel(Long userId) {
        try {
            UserSettings s = settingsMapper.selectOne(new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));
            if (s != null && s.getModel() != null) return s.getModel();
        } catch (Exception ignored) {}
        return systemModel;
    }

    private String callAPI(String sp, String um, String key, String url, String model) {
        HttpHeaders h = new HttpHeaders(); h.setContentType(MediaType.APPLICATION_JSON); h.setBearerAuth(key);
        Map<String,String> sys=new LinkedHashMap<>(); sys.put("role","system"); sys.put("content",sp);
        Map<String,String> usr=new LinkedHashMap<>(); usr.put("role","user"); usr.put("content",um);
        List<Map<String,String>> ms=new ArrayList<>(); ms.add(sys); ms.add(usr);
        Map<String,Object> body=new LinkedHashMap<>(); body.put("model",model); body.put("messages",ms); body.put("temperature",0.7);
        ResponseEntity<Map> resp=restTemplate.postForEntity(url+"/chat/completions",new HttpEntity<>(body,h),Map.class);
        Map<String,Object> rb=resp.getBody();
        if(rb!=null&&rb.containsKey("choices")){List<Map<String,Object>> cs=(List)rb.get("choices");if(!cs.isEmpty()){Map<String,Object> m=(Map)cs.get(0).get("message");return(String)m.get("content");}}
        return null;
    }

    private String fallback(String sp, String um) {
        if(um==null)return "";
        if(um.contains("多态"))return "**多态**：同一方法调用，不同对象表现不同行为。\n```java\nAnimal a=new Dog(); a.sound();//汪汪\n```\n条件：继承+重写+父类引用指向子类。";
        if(um.contains("链表"))return "**链表vs数组**\n|访问|O(1)vsO(n)|\n|插入|O(n)vsO(1)|\n📌随机访问选数组，频繁插入选链表。";
        if(um.contains("秋招"))return "**秋招准备**：\n📌技术栈深入一门\n📌LeetCode200+\n📌2个完整项目\n📌大三暑假实习\n7-8月提前批→9-10月正式批。";
        if(um.contains("竞赛"))return "🏆新手：传智杯/蓝桥杯\n🏆进阶：ACM/数学建模\n建议大一大二从蓝桥杯开始。";
        return "关于「"+(um.length()>20?um.substring(0,20)+"...":um)+"」，配置AI API Key后获得更精准回答。";
    }
}
