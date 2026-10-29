package com.zhitu.ai.agent;

import java.util.Map;

/**
 * Agent 工具契约 —— Function Calling / MCP 在本项目中的最小抽象。
 *
 * <p>每个工具类都实现这个接口，由 {@link ToolRegistry} 在启动时自动收集，
 * 再转换成 OpenAI Chat Completions 协议的 {@code tools} 数组交给大模型。
 * 大模型决定调用哪个工具后，运行时会把 {@code function.arguments} 解析成
 * Map 传进 {@link #execute}，执行结果以纯文本回灌给模型继续推理。
 *
 * <p>设计约束（评审关注的可控性）：
 * <ol>
 *   <li>工具只做「读」，不写库 —— Agent 不得擅自修改用户数据，避免不可预期的副作用；</li>
 *   <li>工具必须自己带 userId 做数据隔离，看不到别人的数据；</li>
 *   <li>出错时返回人类可读的说明而不是抛异常，让大模型知道可以换条路。</li>
 * </ol>
 */
public interface AgentTool {

    /** 工具名，必须与大模型返回的 tool_calls[].function.name 一致 */
    String name();

    /**
     * 给大模型看的描述。这里写得具体与否，直接决定模型会不会在正确的时机调用它，
     * 因此每个工具的描述都写清了「什么时候用」与「会返回什么」。
     */
    String description();

    /** 入参的 JSON Schema（根 type 固定为 object）；无入参时 properties 为空对象 */
    Map<String, Object> parametersSchema();

    /**
     * 执行工具。
     *
     * @param userId    当前登录用户 ID，用于数据隔离
     * @param arguments 大模型给出的入参，可能是 null 或缺失字段
     * @return 回灌给大模型的文本结果（本项目统一用 JSON，便于模型抽取字段）
     */
    String execute(Long userId, Map<String, Object> arguments);

    /**
     * 该工具读取的数据域，用于前端把「AI 调用了哪些数据源」展示给用户。
     * 这是本项目 AI 可解释性的一部分：回答里提到的数字，都能追溯到某个数据源。
     */
    default String dataDomain() {
        return "private";
    }
}
