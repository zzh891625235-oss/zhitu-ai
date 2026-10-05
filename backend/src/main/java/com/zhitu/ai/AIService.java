package com.zhitu.ai;

import java.util.Map;
import java.util.function.Consumer;

/**
 * 统一 AI 服务接口。
 *
 * 平台所有需要大模型的能力（学生画像、四年规划、动态计划、竞赛推荐、
 * 简历生成、AI 助手、模拟面试）都只依赖这个接口，
 * 因此更换模型厂商时不需要改动任何业务代码。
 */
public interface AIService {

    /** 使用系统级配置调用（无用户上下文） */
    String chat(String systemPrompt, String userMessage);

    /** 使用指定的 Key / 地址 / 模型调用 */
    String chatWithKey(String systemPrompt, String userMessage, String apiKey, String apiUrl, String model);

    /** 优先使用该用户自己的 Key，未配置时回退到系统配置 */
    String chatForUser(Long userId, String systemPrompt, String userMessage);

    /**
     * 流式对话：模型每返回一段增量文本就回调一次 onDelta。
     *
     * @return 拼接后的完整回答；若最终降级为离线模板，则一次性回调全部内容
     */
    String chatStreamForUser(Long userId, String systemPrompt, String userMessage, Consumer<String> onDelta);

    /** 获取该用户当前生效的 API Key */
    String getUserApiKey(Long userId);

    /** AI 服务状态，供前端展示「真实大模型 / 离线模板」 */
    Map<String, Object> status(Long userId);
}
