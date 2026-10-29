package com.zhitu.ai;

import java.util.List;
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

    /**
     * 带工具声明的对话（Function Calling）。
     *
     * 模型这次可以不直接回答，而是返回一个或多个「我要调用某个工具」的请求。
     * 这是 Agent 能被称作 Agent 的关键：把「要不要查数据、查哪些数据」的决策权
     * 交给模型，代码只负责忠实执行并把结果原样回灌。
     *
     * @param systemPrompt 系统提示
     * @param messages     完整对话历史，元素形如
     *                     {@code {role:user|assistant|tool, content|tool_calls|tool_call_id}}
     * @param tools        OpenAI 协议的工具数组
     * @param userId       用于选取该用户的 Key；同时也决定了返回 null 时的降级语义
     * @return 模型结果；<b>返回 null 表示当前环境不具备工具调用能力</b>
     *         （未配置 Key、模型不支持 tools 或调用异常），调用方应自行走规则降级路径
     */
    ModelReply chatWithTools(String systemPrompt, List<Map<String, Object>> messages,
                             List<Map<String, Object>> tools, Long userId);

    /**
     * 多模态：让模型「看」一张图片并按指令输出结构化信息。
     *
     * 本平台用它把证书、奖状、成绩单的照片变成可以直接入库的成长档案字段，
     * 省掉用户手打标题、日期、发证单位的步骤。
     *
     * @param instruction 希望模型做什么，例如「提取这是一张什么证书」
     * @param base64      图片内容的 Base64 编码（不含 data: 前缀）
     * @param mime        图片 MIME 类型，如 image/jpeg
     * @return 模型输出；<b>返回 null 表示当前环境不支持图像理解</b>，
     *         调用方应引导用户手动填写（而不是伪造一份识别结果）
     */
    default String visionForUser(Long userId, String instruction, String base64, String mime) {
        return null;
    }

    /** AI 服务状态，供前端展示「真实大模型 / 离线模板」 */
    Map<String, Object> status(Long userId);
}
