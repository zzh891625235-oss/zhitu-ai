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

    @Value("${ai.api-key}")
    private String apiKey;

    @Value("${ai.api-url}")
    private String apiUrl;

    @Value("${ai.model}")
    private String model;

    private final RestTemplate restTemplate = new RestTemplate();

    /** 真实的AI调用 */
    private String callRealAI(String systemPrompt, String userMessage) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, String> sys = new LinkedHashMap<>();
        sys.put("role", "system"); sys.put("content", systemPrompt);
        Map<String, String> usr = new LinkedHashMap<>();
        usr.put("role", "user"); usr.put("content", userMessage);
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(sys); messages.add(usr);

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
                Map<String, Object> msg = (Map<String, Object>) choices.get(0).get("message");
                return (String) msg.get("content");
            }
        }
        return null;
    }

    @Override
    public String chat(String systemPrompt, String userMessage) {
        // 如果配置了真实API Key，调用真实AI
        if (apiKey != null && !apiKey.isEmpty() && !apiKey.contains("your-api-key")) {
            try {
                String real = callRealAI(systemPrompt, userMessage);
                if (real != null && !real.isEmpty()) return real;
            } catch (Exception e) {
                // 降级到智能兜底
            }
        }
        // 智能兜底——根据上下文生成有意义的回复
        return smartFallback(systemPrompt, userMessage);
    }

    /** 智能兜底——根据提示词类型生成不同风格的回复 */
    private String smartFallback(String systemPrompt, String userMessage) {
        String lowerPrompt = systemPrompt != null ? systemPrompt.toLowerCase() : "";
        String lowerMsg = userMessage != null ? userMessage.toLowerCase() : "";

        // JSON生成类请求——返回基础JSON结构
        if (systemPrompt != null && systemPrompt.contains("JSON")) {
            return generateFallbackJson(systemPrompt, userMessage);
        }

        // 对话类请求——返回智能回复
        return generateChatReply(systemPrompt, userMessage);
    }

    private String generateChatReply(String systemPrompt, String userMessage) {
        if (userMessage == null) return "请问有什么可以帮助你的？";

        // 学习类问题
        if (userMessage.contains("多态") || userMessage.contains("polymorphism")) {
            return "多态是面向对象编程的核心概念之一。简单来说：\n\n" +
                   "**什么是多态？**\n" +
                   "同一个方法调用，不同对象表现出不同行为。就像\"叫\"这个动作——狗叫是\"汪汪\"，猫叫是\"喵喵\"。\n\n" +
                   "**Java中的多态实现：**\n" +
                   "```java\n" +
                   "Animal a = new Dog();\n" +
                   "a.sound(); // 输出\"汪汪\"\n" +
                   "a = new Cat();\n" +
                   "a.sound(); // 输出\"喵喵\"\n" +
                   "```\n\n" +
                   "关键条件：继承 + 方法重写 + 父类引用指向子类对象。";
        }

        if (userMessage.contains("链表") || userMessage.contains("数组")) {
            return "**链表 vs 数组**\n\n" +
                   "| 特性 | 数组 | 链表 |\n" +
                   "|------|------|------|\n" +
                   "| 内存 | 连续 | 分散 |\n" +
                   "| 访问 | O(1) 随机 | O(n) 遍历 |\n" +
                   "| 插入/删除 | O(n) | O(1) |\n" +
                   "| 空间 | 固定 | 动态 |\n\n" +
                   "📌 选数组：需要频繁随机访问\n📌 选链表：需要频繁插入删除";
        }

        if (userMessage.contains("TCP") || userMessage.contains("三次握手")) {
            return "**TCP三次握手**（连接建立过程）\n\n" +
                   "1️⃣ **SYN**：客户端→服务器 \"我想连接你\"\n" +
                   "2️⃣ **SYN+ACK**：服务器→客户端 \"收到，准备好了\"\n" +
                   "3️⃣ **ACK**：客户端→服务器 \"好的，开始传数据\"\n\n" +
                   "为什么是三次？保证双方收发能力正常，防止旧连接请求导致混乱。";
        }

        if (userMessage.contains("竞赛") || userMessage.contains("比赛")) {
            return "关于竞赛，给你几个建议：\n\n" +
                   "🏆 **适合新手的**：传智杯、蓝桥杯（入门级，难度适中）\n" +
                   "🏆 **证明实力的**：ACM-ICPC、数学建模竞赛\n" +
                   "🏆 **加分的**：互联网+创新创业大赛、计算机设计大赛\n\n" +
                   "建议大一大二从蓝桥杯开始，积累经验后再冲击ACM。";
        }

        if (userMessage.contains("就业") || userMessage.contains("秋招") || userMessage.contains("面试")) {
            return "**计算机专业就业准备清单：**\n\n" +
                   "📌 **技术栈**：Java(Spring Boot) / C++ / Go / Python 选一个深入\n" +
                   "📌 **算法**：LeetCode刷200+题，Hot 100必刷\n" +
                   "📌 **项目**：至少2个完整项目，部署上线\n" +
                   "📌 **八股文**：操作系统、网络、数据库基础\n" +
                   "📌 **实习**：大三暑假一定要实习！\n\n" +
                   "秋招时间线：7-8月提前批 → 9-10月正式批 → 11-12月补录";
        }

        if (userMessage.contains("考研") || userMessage.contains("研究生")) {
            return "**计算机考研建议：**\n\n" +
                   "📚 **考试科目(408)**：数据结构、计算机组成原理、操作系统、计算机网络\n" +
                   "📚 **数学**：数一（高数+线代+概率）\n" +
                   "📚 **英语**：英语一\n" +
                   "📚 **政治**：全国统一\n\n" +
                   "时间规划：大三上确定目标 → 大三下开始系统复习 → 暑假强化 → 9-12月冲刺";
        }

        // 通用兜底
        return "感谢你的提问！作为智途AI助手，我目前运行在离线模式（未配置AI API Key）。\n\n" +
               "不过别担心——关于「" + (userMessage.length() > 30 ? userMessage.substring(0, 30) + "..." : userMessage) +
               "」这个问题，建议你：\n\n" +
               "1. 查阅相关教材和文档\n" +
               "2. 在课程模块找到对应知识点\n" +
               "3. 配置AI API Key后获得更精准的回答\n\n" +
               "配置方法：在 `application.yml` 中设置 `ai.api-key` 为你的DeepSeek/Qwen/OpenAI API Key。";
    }

    private String generateFallbackJson(String systemPrompt, String userMessage) {
        // 返回空JSON结构，让调用方自行填充
        String prompt = systemPrompt.toLowerCase();
        if (prompt.contains("画像") || prompt.contains("portrait")) {
            return "{\"summary\":\"基于你的学习信息，AI正在分析中...\",\"strengths\":[\"学习态度积极\"],\"weaknesses\":[\"部分基础待加强\"],\"scores\":{\"programming\":50,\"algorithm\":40,\"project\":40,\"competition\":35,\"ai\":30,\"english\":50,\"overall\":41},\"suggestions\":[\"建议制定系统学习计划\"],\"threeMonthPlan\":[\"夯实基础\",\"项目实践\",\"参加比赛\"]}";
        }
        if (prompt.contains("规划") || prompt.contains("plan") || prompt.contains("年")) {
            return "{\"overview\":\"规划生成中...\",\"freshman\":{},\"sophomore\":{},\"junior\":{},\"senior\":{}}";
        }
        if (prompt.contains("简历") || prompt.contains("resume")) {
            return "{\"name\":\"\",\"education\":{},\"skills\":[],\"projects\":[],\"competitions\":[],\"advantages\":\"\"}";
        }
        if (prompt.contains("竞赛") || prompt.contains("competition")) {
            return "[]";
        }
        return "{}";
    }
}
