package com.zhitu.ai;

import java.util.ArrayList;
import java.util.List;

/**
 * 大模型一次对话的返回结果。
 *
 * <p>除了常规文本 {@code content}，还可能需要承载工具调用 {@code toolCalls} ——
 * 这是 Function Calling 的关键：模型不直接回答，而是先「请求执行某个函数」。
 *
 * <p>之所以不直接用 Map：与其让上层猜结构，不如把协议字段固化成类型，
 * 编译器能帮我们挡住大部分字段名拼写错误。
 */
public class ModelReply {

    /** 模型给出的文本内容（调用工具时可能为空） */
    private String content;

    /** 模型请求调用的工具列表 */
    private List<ToolCall> toolCalls = new ArrayList<>();

    /** 本次请求消耗的信息，用于前端展示透明度 */
    private String finishReason;

    public ModelReply() {
    }

    public ModelReply(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public List<ToolCall> getToolCalls() {
        return toolCalls;
    }

    public void setToolCalls(List<ToolCall> toolCalls) {
        this.toolCalls = toolCalls;
    }

    public String getFinishReason() {
        return finishReason;
    }

    public void setFinishReason(String finishReason) {
        this.finishReason = finishReason;
    }

    public boolean hasToolCalls() {
        return toolCalls != null && !toolCalls.isEmpty();
    }

    /** 单个工具调用请求 */
    public static class ToolCall {

        private String id;
        private String name;
        /** 模型给出的入参，标准协议里是「JSON 字符串」而不是对象 */
        private String arguments;

        public ToolCall() {
        }

        public ToolCall(String id, String name, String arguments) {
            this.id = id;
            this.name = name;
            this.arguments = arguments;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getArguments() {
            return arguments;
        }

        public void setArguments(String arguments) {
            this.arguments = arguments;
        }
    }
}
