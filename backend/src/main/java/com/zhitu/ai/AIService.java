package com.zhitu.ai;

/**
 * AI服务接口 - 统一AI调用入口
 * 后续可切换DeepSeek / Qwen / OpenAI等模型
 */
public interface AIService {
    /**
     * 调用AI生成内容
     * @param systemPrompt 系统提示词
     * @param userMessage 用户消息
     * @return AI回复文本
     */
    String chat(String systemPrompt, String userMessage);
}
