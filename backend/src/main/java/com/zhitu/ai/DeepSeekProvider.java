package com.zhitu.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.entity.UserSettings;
import com.zhitu.mapper.UserSettingsMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.annotation.PostConstruct;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Consumer;

/**
 * DeepSeek / OpenAI 兼容协议的 AI 服务实现。
 *
 * 兼容任何遵循 OpenAI Chat Completions 协议的服务：
 * DeepSeek、OpenAI、通义千问（兼容模式）等，切换只需改 application.yml。
 *
 * 设计要点：
 *  1. 每个用户可使用自己的 API Key（「API 设置」页），优先级高于系统配置；
 *  2. 调用失败会按配置重试，最终失败时降级到离线模板，并记录该状态，
 *     前端可据此提示用户「当前不是大模型生成」，不会伪装成 AI 结果；
 *  3. 支持流式（SSE）输出，用于 AI 助手与模拟面试的打字机效果。
 */
@Component
@ConditionalOnProperty(name = "ai.provider", havingValue = "deepseek", matchIfMissing = true)
public class DeepSeekProvider implements AIService {

    private static final Logger log = LoggerFactory.getLogger(DeepSeekProvider.class);

    @Value("${ai.api-key:}")
    private String systemApiKey;

    @Value("${ai.api-url:https://api.deepseek.com/v1}")
    private String systemApiUrl;

    @Value("${ai.model:deepseek-chat}")
    private String systemModel;

    /** 视觉模型：留空时回退到 ai.model（此时若模型不支持视觉，会降级为手动填写） */
    @Value("${ai.vision-model:}")
    private String visionModel;

    @Value("${ai.timeout:60000}")
    private int timeout;

    @Value("${ai.max-retries:2}")
    private int maxRetries;

    private final UserSettingsMapper settingsMapper;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** 记录每位用户最近一次调用是否真的命中了大模型 */
    private final Map<Long, Boolean> lastCallReal = new ConcurrentHashMap<>();

    /**
     * 当前模型是否支持 tools 参数。
     * 一旦收到不支持的错误就永久关闭（进程内），避免每条消息都白白多打一次网络请求。
     */
    private volatile boolean toolsSupported = true;

    public DeepSeekProvider(UserSettingsMapper settingsMapper) {
        this.settingsMapper = settingsMapper;
    }

    @PostConstruct
    void initHttpClient() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Math.min(timeout, 15000));
        factory.setReadTimeout(timeout);
        restTemplate.setRequestFactory(factory);
        log.info("AI 服务初始化完成：provider=deepseek, url={}, model={}, timeout={}ms, maxRetries={}",
                systemApiUrl, systemModel, timeout, maxRetries);
    }

    // ================================================================
    // 对外接口
    // ================================================================

    @Override
    public String chat(String systemPrompt, String userMessage) {
        return chatWithKey(systemPrompt, userMessage, systemApiKey, systemApiUrl, systemModel);
    }

    @Override
    public String chatWithKey(String systemPrompt, String userMessage, String apiKey, String apiUrl, String model) {
        if (!isConfigured(apiKey)) {
            return fallback(systemPrompt, userMessage);
        }
        String answer = callWithRetry(systemPrompt, userMessage, apiKey, apiUrl, model);
        return answer != null ? answer : fallback(systemPrompt, userMessage);
    }

    @Override
    public String chatForUser(Long userId, String systemPrompt, String userMessage) {
        UserSettings settings = loadSettings(userId);
        String key = firstNonBlank(settings == null ? null : settings.getApiKey(), systemApiKey);
        String url = firstNonBlank(settings == null ? null : settings.getApiUrl(), systemApiUrl);
        String model = firstNonBlank(settings == null ? null : settings.getModel(), systemModel);

        if (!isConfigured(key)) {
            markCall(userId, false);
            return fallback(systemPrompt, userMessage);
        }
        String answer = callWithRetry(systemPrompt, userMessage, key, url, model);
        if (answer != null) {
            markCall(userId, true);
            return answer;
        }
        markCall(userId, false);
        return fallback(systemPrompt, userMessage);
    }

    @Override
    public String chatStreamForUser(Long userId, String systemPrompt, String userMessage, Consumer<String> onDelta) {
        UserSettings settings = loadSettings(userId);
        String key = firstNonBlank(settings == null ? null : settings.getApiKey(), systemApiKey);
        String url = firstNonBlank(settings == null ? null : settings.getApiUrl(), systemApiUrl);
        String model = firstNonBlank(settings == null ? null : settings.getModel(), systemModel);

        if (isConfigured(key)) {
            try {
                String full = streamOnce(systemPrompt, userMessage, key, url, model, onDelta);
                if (full != null && !full.trim().isEmpty()) {
                    markCall(userId, true);
                    return full;
                }
            } catch (Exception e) {
                log.warn("流式调用失败，降级为离线模板：{}", e.getMessage());
            }
        }

        // 降级：一次性把离线模板内容推给前端，保证界面仍有反馈
        markCall(userId, false);
        String fb = fallback(systemPrompt, userMessage);
        if (onDelta != null) {
            onDelta.accept(fb);
        }
        return fb;
    }

    @Override
    public String getUserApiKey(Long userId) {
        UserSettings settings = loadSettings(userId);
        if (settings != null && isConfigured(settings.getApiKey())) {
            return settings.getApiKey();
        }
        return systemApiKey;
    }

    @Override
    public String visionForUser(Long userId, String instruction, String base64, String mime) {
        UserSettings settings = loadSettings(userId);
        String key = firstNonBlank(settings == null ? null : settings.getApiKey(), systemApiKey);
        String url = firstNonBlank(settings == null ? null : settings.getApiUrl(), systemApiUrl);
        String model = firstNonBlank(visionModel, systemModel);
        if (!isConfigured(key) || base64 == null || base64.isEmpty()) {
            return null;
        }
        String type = mime == null || mime.isEmpty() ? "image/jpeg" : mime;
        try {
            String out = callVisionApi(instruction, "data:" + type + ";base64," + base64, key, url, model);
            if (out != null && !out.trim().isEmpty()) {
                markCall(userId, true);
                return out;
            }
        } catch (Exception e) {
            log.warn("图像理解失败（模型 {} 可能不支持视觉输入）：{}", model, e.getMessage());
        }
        return null;
    }

    /**
     * 图文混合输入（OpenAI 协议的 content 数组形式）。
     *
     * 注意：图像 token 消耗远高于文本，所以这里<b>不做重试</b>，
     * 失败就让上层提示用户手动填写，避免一次点击烧掉大量额度。
     */
    @SuppressWarnings("unchecked")
    private String callVisionApi(String instruction, String dataUrl, String key, String url, String model) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(key);

        Map<String, Object> textPart = new LinkedHashMap<>();
        textPart.put("type", "text");
        textPart.put("text", instruction);
        Map<String, Object> imagePart = new LinkedHashMap<>();
        imagePart.put("type", "image_url");
        Map<String, Object> imageUrl = new LinkedHashMap<>();
        imageUrl.put("url", dataUrl);
        imagePart.put("image_url", imageUrl);

        Map<String, Object> user = new LinkedHashMap<>();
        user.put("role", "user");
        user.put("content", new Object[]{textPart, imagePart});

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model);
        body.put("messages", Collections.singletonList(user));
        body.put("temperature", 0.1);
        body.put("max_tokens", 800);

        ResponseEntity<Map> response =
                restTemplate.postForEntity(chatEndpoint(url), new HttpEntity<>(body, headers), Map.class);
        Map<String, Object> result = response.getBody();
        if (result == null) {
            return null;
        }
        Object choices = result.get("choices");
        if (!(choices instanceof List) || ((List<?>) choices).isEmpty()) {
            return null;
        }
        Object message = ((Map<String, Object>) ((List<?>) choices).get(0)).get("message");
        if (message instanceof Map) {
            Object content = ((Map<?, ?>) message).get("content");
            return content == null ? null : content.toString();
        }
        return null;
    }

    @Override
    public ModelReply chatWithTools(String systemPrompt, List<Map<String, Object>> messages,
                                    List<Map<String, Object>> tools, Long userId) {
        if (!toolsSupported) {
            return null;
        }
        UserSettings settings = loadSettings(userId);
        String key = firstNonBlank(settings == null ? null : settings.getApiKey(), systemApiKey);
        String url = firstNonBlank(settings == null ? null : settings.getApiUrl(), systemApiUrl);
        String model = firstNonBlank(settings == null ? null : settings.getModel(), systemModel);
        if (!isConfigured(key)) {
            return null;
        }

        int attempts = Math.max(1, maxRetries);
        for (int i = 1; i <= attempts; i++) {
            try {
                ModelReply reply = callToolsApi(systemPrompt, messages, tools, key, url, model);
                if (reply != null) {
                    markCall(userId, true);
                    return reply;
                }
                log.warn("工具调用返回为空（第 {}/{} 次）", i, attempts);
            } catch (Exception e) {
                log.warn("工具调用失败（第 {}/{} 次）：{}", i, attempts, e.getMessage());
                // 400 通常是该模型/网关不认识 tools 字段，关掉开关避免每次对话都空跑一次
                String msg = e.getMessage();
                if (msg != null && (msg.contains("400") || msg.toLowerCase().contains("tool"))) {
                    toolsSupported = false;
                    log.warn("当前模型似乎不支持 tools 参数，后续对话将切换到本地规则编排模式：model={}", model);
                    break;
                }
            }
        }
        // 返回 null 是一种明确的信号：上层应当降级，而不是把工具结果伪装成模型决策
        return null;
    }

    @Override
    public Map<String, Object> status(Long userId) {
        UserSettings settings = loadSettings(userId);
        String userKey = settings == null ? null : settings.getApiKey();
        String effectiveKey = firstNonBlank(userKey, systemApiKey);

        Map<String, Object> status = new LinkedHashMap<>();
        status.put("provider", "deepseek");
        status.put("model", firstNonBlank(settings == null ? null : settings.getModel(), systemModel));
        status.put("configured", isConfigured(effectiveKey));
        status.put("keySource", isConfigured(userKey) ? "USER" : (isConfigured(systemApiKey) ? "SYSTEM" : "NONE"));
        status.put("lastCallReal", lastCallReal.getOrDefault(userId, false));
        return status;
    }

    // ================================================================
    // 内部实现
    // ================================================================

    /** 读取用户级配置；表不存在或查询异常时安全返回 null，不影响主流程 */
    private UserSettings loadSettings(Long userId) {
        if (userId == null) {
            return null;
        }
        try {
            return settingsMapper.selectOne(
                    new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));
        } catch (Exception e) {
            log.debug("读取用户 AI 配置失败（userId={}）：{}", userId, e.getMessage());
            return null;
        }
    }

    /** 带重试的调用，全部失败返回 null（由调用方决定是否降级） */
    private String callWithRetry(String systemPrompt, String userMessage, String key, String url, String model) {
        int attempts = Math.max(1, maxRetries + 1);
        String lastError = null;
        for (int i = 1; i <= attempts; i++) {
            try {
                String answer = callApi(systemPrompt, userMessage, key, url, model);
                if (answer != null && !answer.trim().isEmpty()) {
                    return answer;
                }
                lastError = "模型返回内容为空";
            } catch (Exception e) {
                lastError = e.getMessage();
                log.warn("AI 调用失败（第 {}/{} 次）：{}", i, attempts, e.getMessage());
            }
        }
        log.warn("AI 调用最终失败，已降级为离线模板：{}", lastError);
        return null;
    }

    @SuppressWarnings("unchecked")
    private String callApi(String systemPrompt, String userMessage, String key, String url, String model) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(key);

        Map<String, Object> body = buildRequestBody(systemPrompt, userMessage, model, false);
        String endpoint = chatEndpoint(url);

        ResponseEntity<Map> response = restTemplate.postForEntity(endpoint, new HttpEntity<>(body, headers), Map.class);
        Map<String, Object> result = response.getBody();
        if (result == null) {
            return null;
        }
        Object choices = result.get("choices");
        if (!(choices instanceof List) || ((List<?>) choices).isEmpty()) {
            return null;
        }
        Object message = ((Map<String, Object>) ((List<?>) choices).get(0)).get("message");
        if (message instanceof Map) {
            Object content = ((Map<?, ?>) message).get("content");
            return content == null ? null : content.toString();
        }
        return null;
    }

    /** 流式调用：逐行解析 SSE，把增量内容回调出去 */
    private String streamOnce(String systemPrompt, String userMessage, String key, String url, String model,
                              Consumer<String> onDelta) {
        Map<String, Object> body = buildRequestBody(systemPrompt, userMessage, model, true);
        String endpoint = chatEndpoint(url);

        return restTemplate.execute(URI.create(endpoint), HttpMethod.POST, request -> {
            request.getHeaders().setContentType(MediaType.APPLICATION_JSON);
            request.getHeaders().setBearerAuth(key);
            request.getHeaders().setAccept(Collections.singletonList(MediaType.TEXT_EVENT_STREAM));
            objectMapper.writeValue(request.getBody(), body);
        }, response -> {
            StringBuilder full = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(response.getBody(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.isEmpty() || !line.startsWith("data:")) {
                        continue;
                    }
                    String payload = line.substring(5).trim();
                    if ("[DONE]".equals(payload)) {
                        break;
                    }
                    String delta = extractDelta(payload);
                    if (delta != null && !delta.isEmpty()) {
                        full.append(delta);
                        if (onDelta != null) {
                            onDelta.accept(delta);
                        }
                    }
                }
            }
            return full.toString();
        });
    }

    @SuppressWarnings("unchecked")
    private String extractDelta(String json) {
        try {
            Map<String, Object> node = objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
            Object choices = node.get("choices");
            if (!(choices instanceof List) || ((List<?>) choices).isEmpty()) {
                return null;
            }
            Object delta = ((Map<String, Object>) ((List<?>) choices).get(0)).get("delta");
            if (delta instanceof Map) {
                Object content = ((Map<?, ?>) delta).get("content");
                return content == null ? null : content.toString();
            }
        } catch (Exception ignored) {
            // 单行解析失败不影响整体流
        }
        return null;
    }

    /**
     * 发起一次带工具声明的请求，并把响应解析成 {@link ModelReply}。
     *
     * 响应里可能出现两种形态之一：
     *  1. 直接给出 content —— 模型认为不需要查任何东西，可以直接回答；
     *  2. 给出 tool_calls 且 content 为空 —— 模型请求先执行工具。
     * 两种情况都统一包装返回，由上层决定下一步。
     */
    @SuppressWarnings("unchecked")
    private ModelReply callToolsApi(String systemPrompt, List<Map<String, Object>> messages,
                                    List<Map<String, Object>> tools, String key, String url, String model) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(key);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model);
        body.put("messages", buildMessages(systemPrompt, messages));
        // 工具调用阶段刻意压低温度：这里要的是稳定的结构化决策，不是文采
        body.put("temperature", 0.2);
        if (tools != null && !tools.isEmpty()) {
            body.put("tools", tools);
            body.put("tool_choice", "auto");
        }

        ResponseEntity<Map> response =
                restTemplate.postForEntity(chatEndpoint(url), new HttpEntity<>(body, headers), Map.class);
        Map<String, Object> result = response.getBody();
        if (result == null) {
            return null;
        }
        Object choices = result.get("choices");
        if (!(choices instanceof List) || ((List<?>) choices).isEmpty()) {
            return null;
        }
        Object message = ((Map<String, Object>) ((List<?>) choices).get(0)).get("message");
        if (!(message instanceof Map)) {
            return null;
        }
        Map<String, Object> msg = (Map<String, Object>) message;

        ModelReply reply = new ModelReply();
        Object content = msg.get("content");
        reply.setContent(content == null ? "" : content.toString());
        reply.setFinishReason(String.valueOf(((Map<String, Object>) ((List<?>) choices).get(0)).get("finish_reason")));

        Object toolCalls = msg.get("tool_calls");
        if (toolCalls instanceof List) {
            for (Object tc : (List<?>) toolCalls) {
                if (!(tc instanceof Map)) {
                    continue;
                }
                Map<String, Object> call = (Map<String, Object>) tc;
                Object fn = call.get("function");
                if (!(fn instanceof Map)) {
                    continue;
                }
                Map<String, Object> f = (Map<String, Object>) fn;
                reply.getToolCalls().add(new ModelReply.ToolCall(
                        String.valueOf(call.get("id")),
                        String.valueOf(f.get("name")),
                        f.get("arguments") == null ? "{}" : String.valueOf(f.get("arguments"))));
            }
        }
        return reply;
    }

    /** 把系统提示拼到对话历史最前面：tools 请求需要自己携带完整上下文 */
    private List<Map<String, Object>> buildMessages(String systemPrompt, List<Map<String, Object>> messages) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (systemPrompt != null && !systemPrompt.isEmpty()) {
            Map<String, Object> sys = new LinkedHashMap<>();
            sys.put("role", "system");
            sys.put("content", systemPrompt);
            list.add(sys);
        }
        if (messages != null) {
            list.addAll(messages);
        }
        return list;
    }

    private Map<String, Object> buildRequestBody(String systemPrompt, String userMessage, String model, boolean stream) {
        Map<String, String> sys = new LinkedHashMap<>();
        sys.put("role", "system");
        sys.put("content", systemPrompt);
        Map<String, String> usr = new LinkedHashMap<>();
        usr.put("role", "user");
        usr.put("content", userMessage);

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(sys);
        messages.add(usr);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model);
        body.put("messages", messages);
        body.put("temperature", 0.7);
        if (stream) {
            body.put("stream", true);
        }
        return body;
    }

    private String chatEndpoint(String url) {
        String base = url == null ? "" : url.trim();
        if (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }
        return base + "/chat/completions";
    }

    private boolean isConfigured(String key) {
        return key != null && !key.trim().isEmpty() && !key.contains("your-api-key");
    }

    private void markCall(Long userId, boolean real) {
        if (userId != null) {
            lastCallReal.put(userId, real);
        }
    }

    private String firstNonBlank(String first, String second) {
        if (first != null && !first.trim().isEmpty()) {
            return first.trim();
        }
        return second;
    }

    // ================================================================
    // 离线模板：未配置 Key 或调用失败时使用
    // 内容基于常见计算机专业问题的人工知识库，保证断网演示时依然可用
    // ================================================================

    private String fallback(String systemPrompt, String userMessage) {
        if (userMessage == null || userMessage.trim().isEmpty()) {
            return "请告诉我你的问题，我会尽力帮你分析。";
        }
        String q = userMessage;

        // 调用方（AiChatController.getSystemPrompt）会把专业写进系统提示开头。
        // 非计算机专业的学生不应该拿到 Java / 蓝桥杯 / 408 那一套内容。
        String majorName = majorFrom(systemPrompt);
        boolean it = MajorDirection.isIT(majorName == null ? "" : majorName);
        MajorDirection dir = MajorDirection.resolve(majorName == null ? "" : majorName);

        if (q.contains("多态")) {
            return "**多态**：同一个方法调用，作用在不同对象上产生不同行为。\n\n"
                 + "三个必要条件：继承、方法重写、父类引用指向子类对象。\n\n"
                 + "```java\nAnimal a = new Dog();\na.sound(); // 输出「汪汪」而不是「动物叫」\n```\n\n"
                 + "面试延伸：JVM 通过虚方法表在运行时确定实际调用哪个方法，这叫动态绑定。";
        }
        if (q.contains("链表") || q.contains("数组")) {
            return "**链表 vs 数组**\n\n"
                 + "| 维度 | 数组 | 链表 |\n| --- | --- | --- |\n"
                 + "| 随机访问 | O(1) | O(n) |\n| 插入删除 | O(n) | O(1) |\n| 内存 | 连续，可能浪费 | 分散，额外指针开销 |\n\n"
                 + "选择原则：读多写少用数组，频繁插入删除用链表。";
        }
        if (q.contains("三次握手") || q.contains("TCP")) {
            return "**TCP 三次握手**\n\n"
                 + "1. 客户端 → 服务端：SYN，携带初始序号 seq=x\n"
                 + "2. 服务端 → 客户端：SYN+ACK，seq=y，ack=x+1\n"
                 + "3. 客户端 → 服务端：ACK，ack=y+1\n\n"
                 + "为什么是三次：需要双方都确认「自己的发送能力」和「对方的接收能力」都正常，两次无法让服务端确认客户端能收到。";
        }
        if (q.contains("索引")) {
            return "**MySQL 索引要点**\n\n"
                 + "* 底层是 B+ 树：非叶子节点只存键，叶子节点存数据并用链表相连，适合范围查询\n"
                 + "* 最左前缀原则：联合索引 (a,b,c) 能命中 a、a+b、a+b+c，无法命中 b 单独查询\n"
                 + "* 索引失效常见场景：对列做运算或函数、隐式类型转换、以 % 开头的模糊查询\n"
                 + "* 用 EXPLAIN 看 type 和 key，尽量避免 ALL（全表扫描）";
        }
        if (q.contains("秋招") || q.contains("求职") || q.contains("找工作")) {
            if (it) {
                return "**秋招准备路线**\n\n"
                     + "1. 技术栈：深入一门语言 + 常用框架原理（Spring、MySQL、Redis）\n"
                     + "2. 算法：LeetCode 200 题以上，重点掌握高频题型\n"
                     + "3. 项目：至少 2 个能讲清楚难点的完整项目\n"
                     + "4. 实习：大三暑假的实习是校招最大加分项\n\n"
                     + "时间线：7-8 月提前批 → 9-10 月正式批 → 次年 3-4 月春招补录。";
            }
            return "**求职准备路线（" + dir.label() + "方向）**\n\n"
                 + "1. 专业能力：把核心专业课学扎实，面试里讲得清原理比背题有用\n"
                 + "2. 证书：优先考取「" + join(dir.certificates(), 2) + "」这类对口证书\n"
                 + "3. 实践：至少 2 段能讲清楚你具体做了什么的对口实习或课程项目\n"
                 + "4. 岗位方向：" + join(dir.positions(), 4) + "\n\n"
                 + "时间线：大三暑假实习 → 大四上 9-11 月秋招 → 次年 3-4 月春招补录。";
        }
        if (q.contains("考研") || q.contains("保研")) {
            String subject = it
                ? "专业课（计算机统考多为 408）"
                : "专业课（目标院校自命题，务必查最新招生简章）";
            return "**考研 / 保研要点**\n\n"
                 + "* 保研：看前三年 GPA + 竞赛科研，大三下就要开始联系导师和参加夏令营\n"
                 + "* 考研：数学 + 英语 + 政治 + " + subject + "\n"
                 + "* 时间线：大三上确定目标院校 → 大三下开始系统复习 → 大四上 12 月考试\n"
                 + "* 无论哪条路，GPA 都是基础，不要为了竞赛牺牲成绩。";
        }
        if (q.contains("竞赛") || q.contains("蓝桥杯") || q.contains("ACM") || q.contains("比赛")) {
            if (it) {
                return "**计算机类竞赛选择建议**\n\n"
                     + "* 入门友好：传智杯、蓝桥杯（个人赛，适合第一次参赛）\n"
                     + "* 含金量高：ACM-ICPC、中国大学生计算机设计大赛\n"
                     + "* 保研加分：数学建模竞赛、互联网+创新创业大赛\n\n"
                     + "建议大一大二从蓝桥杯起步积累经验，大三冲击高含金量赛事。";
            }
            return "**" + dir.label() + "方向竞赛建议**\n\n"
                 + "* 本方向常见赛事：" + competitionsOf(dir) + "\n"
                 + "* 选择原则：先校级 / 省级起步，积累作品与答辩经验后再冲国家级\n"
                 + "* 备赛重点：竞赛考的大多就是专业课内容的综合应用，别抛开课程单独刷题\n\n"
                 + "建议大一大二先参加校级赛事练手，大三冲击含金量更高的赛事。";
        }
        if (q.contains("实习")) {
            if (it) {
                return "**如何拿到第一份实习**\n\n"
                     + "1. 先有一个能演示的项目，部署上线并有 GitHub 仓库\n"
                     + "2. 简历突出「你解决了什么问题」，而不是「你用了什么技术」\n"
                     + "3. 投递节奏：日常实习全年可投，暑期实习集中在 3-5 月\n"
                     + "4. 面试重点：项目细节 + 八股（Java 基础、集合、JVM、MySQL、Redis）+ 算法题";
            }
            return "**如何拿到第一份实习**\n\n"
                 + "1. 先有一段讲得清的真实经历：课程实践、实验室项目、校内岗位都算\n"
                 + "2. 简历突出「你解决了什么问题」，而不是「你参与了什么」\n"
                 + "3. 投递节奏：日常实习全年可投，暑期实习集中在 3-5 月\n"
                 + "4. 面试重点：专业课基础 + 项目细节 + 对目标岗位的理解\n\n"
                 + "对口岗位可参考：" + join(dir.positions(), 3) + "。";
        }
        if (q.contains("简历")) {
            String example = it
                ? "* 正例：独立设计订单表结构并优化慢查询，接口 P95 从 800ms 降到 120ms\n"
                : "* 正例：在课程实践中负责 XX 环节，把 XX 流程的耗时从 3 天缩短到 1 天\n";
            String bad = it ? "* 反例：负责后端开发\n" : "* 反例：协助老师完成相关工作\n";
            return "**简历写作要点**\n\n"
                 + "* 一页为宜，倒序排列经历\n"
                 + "* 经历描述用 STAR 法：背景 → 你的任务 → 你怎么做的 → 量化结果\n"
                 + bad
                 + example
                 + "* 技能栏只写能被追问的，写了就要能答上来";
        }

        // 通用兜底：给出结构化思路，并明确说明当前处于离线模式
        String topic = q.length() > 24 ? q.substring(0, 24) + "……" : q;
        return "关于「" + topic + "」，可以从这几个角度入手：\n\n"
             + "1. **先明确目标**：你希望解决的具体问题是什么，期望达到什么结果\n"
             + "2. **拆解路径**：把大目标拆成阶段性的小任务，明确每阶段要产出的东西\n"
             + "3. **找参照**：看看同专业、同年级里做得好的同学是怎么做的\n"
             + "4. **立即行动**：先做一件 30 分钟内能完成的事，避免停留在计划阶段\n\n"
             + "> 当前运行在**离线模板模式**，以上为内置建议。"
             + "在「API 设置」中填入自己的 API Key 后，即可获得针对你个人学情的深度分析。";
    }

    /**
     * 从系统提示开头取出调用方写入的专业名（格式见 AiChatController.getSystemPrompt）。
     *
     * 取不到就返回 null，此时方向会落到通用兜底（不会按计算机方向输出）——
     * 这是刻意的：宁可给通用建议，也不要给一个文科生讲 408 和蓝桥杯。
     */
    private String majorFrom(String systemPrompt) {
        if (systemPrompt == null) return null;
        int s = systemPrompt.indexOf("【专业:");
        if (s < 0) return null;
        int e = systemPrompt.indexOf('】', s);
        if (e <= s) return null;
        String name = systemPrompt.substring(s + 4, e).trim();
        return name.isEmpty() ? null : name;
    }

    /** 取列表前 n 项并用「、」连接 */
    private String join(List<String> items, int n) {
        if (items == null || items.isEmpty()) return "—";
        StringBuilder sb = new StringBuilder();
        int limit = Math.min(n, items.size());
        for (int i = 0; i < limit; i++) {
            if (i > 0) sb.append("、");
            sb.append(items.get(i));
        }
        return sb.toString();
    }

    /** 汇总该方向四年规划里出现过的竞赛，去重后最多 5 个 */
    private String competitionsOf(MajorDirection dir) {
        LinkedHashSet<String> set = new LinkedHashSet<>();
        for (MajorDirection.YearPlan y : dir.years()) {
            if (y.competitions != null) set.addAll(y.competitions);
        }
        if (set.isEmpty()) return "本方向校级 / 省级专业技能竞赛";
        return join(new ArrayList<>(set), 5);
    }
}
