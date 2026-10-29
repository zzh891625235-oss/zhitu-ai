package com.zhitu.ai.agent;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 构造 OpenAI Function Calling 所需的 JSON Schema 的小工具。
 *
 * 之所以单独抽出来：8 个工具如果各写各的 Map 嵌套，schema 会散落成难以维护的
 * 字面量；集中在这里能保证所有工具产出的 schema 结构一致，
 * 也方便将来直接复用给 MCP servers/list 的响应。
 */
public final class ToolSchemas {

    private ToolSchemas() {
    }

    /** 基础标量参数 */
    public static Map<String, Object> prop(String type, String description) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", type);
        m.put("description", description);
        return m;
    }

    /** 带取值范围的字符串参数，约束模型输出，避免它自由发挥 */
    public static Map<String, Object> enumProp(String description, String... allowed) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "string");
        m.put("description", description);
        m.put("enum", Arrays.asList(allowed));
        return m;
    }

    /** 组装根对象 Schema */
    public static Map<String, Object> object(Map<String, Object> properties) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("type", "object");
        m.put("properties", properties);
        return m;
    }

    /** 无入参的工具：properties 必须存在但为空对象，否则部分模型会报错 */
    public static Map<String, Object> emptyObject() {
        return object(new LinkedHashMap<String, Object>());
    }

    /** 便捷构造：按顺序 name1,v1,name2,v2... */
    public static Map<String, Object> props(Object... kv) {
        Map<String, Object> m = new LinkedHashMap<>();
        for (int i = 0; i + 1 < kv.length; i += 2) {
            m.put(String.valueOf(kv[i]), kv[i + 1]);
        }
        return m;
    }

    /** 整数参数 */
    public static Map<String, Object> intProp(String description) {
        return prop("integer", description);
    }

    public static List<String> list(String... items) {
        return Arrays.asList(items);
    }
}
