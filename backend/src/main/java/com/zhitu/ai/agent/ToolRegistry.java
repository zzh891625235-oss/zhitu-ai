package com.zhitu.ai.agent;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Agent 工具注册中心。
 *
 * <p>所有实现了 {@link AgentTool} 的 Spring Bean 都会被注入进来，按名字索引。
 * 它同时负责把这组工具翻译成两种对外形态：
 * <ul>
 *   <li>{@link #openAiTools()} —— OpenAI Chat Completions 的 tools 数组，给 Function Calling 用；</li>
 *   <li>{@link #manifest()}      —— MCP 风格的 tools/list 结果，给外部 MCP 客户端发现和调用。</li>
 * </ul>
 * 一份工具定义、两套协议出口，避免「为了接 MCP 再写一版工具」的代码重复。
 */
@Component
public class ToolRegistry {

    private static final Logger log = LoggerFactory.getLogger(ToolRegistry.class);

    private final Map<String, AgentTool> tools = new LinkedHashMap<>();

    public ToolRegistry(Collection<AgentTool> toolBeans) {
        for (AgentTool tool : toolBeans) {
            AgentTool prev = tools.put(tool.name(), tool);
            if (prev != null) {
                log.warn("工具名冲突：{}（{} 被覆盖）", tool.name(), prev.getClass().getSimpleName());
            }
        }
        log.info("Agent 工具注册完成，共 {} 个：{}", tools.size(), tools.keySet());
    }

    public AgentTool get(String name) {
        return tools.get(name);
    }

    public Collection<AgentTool> all() {
        return tools.values();
    }

    /**
     * 转成 OpenAI tools 数组。
     * 形如：[{"type":"function","function":{"name":...,"description":...,"parameters":{...}}}]
     */
    public List<Map<String, Object>> openAiTools() {
        List<Map<String, Object>> list = new ArrayList<>();
        for (AgentTool tool : tools.values()) {
            Map<String, Object> fn = new LinkedHashMap<>();
            fn.put("name", tool.name());
            fn.put("description", tool.description());
            fn.put("parameters", tool.parametersSchema());

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("type", "function");
            item.put("function", fn);
            list.add(item);
        }
        return list;
    }

    /**
     * MCP 风格的清单：让 Claude Desktop 之类的 MCP 客户端也能发现这些工具。
     * 字段对齐 MCP tools/list 的 inputSchema 命名。
     */
    public List<Map<String, Object>> manifest() {
        List<Map<String, Object>> list = new ArrayList<>();
        for (AgentTool tool : tools.values()) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("name", tool.name());
            item.put("description", tool.description());
            item.put("inputSchema", tool.parametersSchema());
            item.put("dataDomain", tool.dataDomain());
            list.add(item);
        }
        return list;
    }
}
