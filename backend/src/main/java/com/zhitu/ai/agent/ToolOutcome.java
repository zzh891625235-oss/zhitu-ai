package com.zhitu.ai.agent;

import java.util.Map;

/**
 * 一次工具调用的完整记录。
 *
 * 它同时被三处消费：
 * <ul>
 *   <li>Agent 运行时：把 result 回灌给大模型；</li>
 *   <li>前端：渲染「AI 调用了什么工具、拿到了什么」的执行轨迹；</li>
 *   <li>离线编排器：在模型不可用时，直接依据这些真实数据合成答案。</li>
 * </ul>
 */
public class ToolOutcome {

    private final int step;
    private final String tool;
    private final String purpose;
    private final Map<String, Object> arguments;
    private final String result;
    private final boolean success;
    private final String dataDomain;

    public ToolOutcome(int step, String tool, String purpose, Map<String, Object> arguments,
                       String result, boolean success, String dataDomain) {
        this.step = step;
        this.tool = tool;
        this.purpose = purpose;
        this.arguments = arguments;
        this.result = result;
        this.success = success;
        this.dataDomain = dataDomain;
    }

    public int getStep() {
        return step;
    }

    public String getTool() {
        return tool;
    }

    public String getPurpose() {
        return purpose;
    }

    public Map<String, Object> getArguments() {
        return arguments;
    }

    public String getResult() {
        return result;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getDataDomain() {
        return dataDomain;
    }

    /** 给前端展示的结果摘要（模型能看到完整 JSON，用户看摘要就够了） */
    public String preview() {
        if (result == null || result.isEmpty()) {
            return "(空结果)";
        }
        String flat = result.replaceAll("\\s+", " ").trim();
        return flat.length() <= 160 ? flat : flat.substring(0, 160) + "…";
    }
}
