package com.zhitu.ai.agent;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Map;

/**
 * 工具基类：统一把结果序列化成 JSON 文本回灌给大模型。
 *
 * 用 JSON 而不是自然语言描述的原因很实际：模型从
 * {"gpa":"3.6","grade":"大二"} 里抽字段，比从一段散文中抽出同一组数字稳定得多，
 * 也更省 token。所有工具共用这一个出口，序列化行为才能保持一致。
 */
public abstract class JsonTool implements AgentTool {

    protected final ObjectMapper om = new ObjectMapper();

    protected String json(Object value) {
        try {
            return om.writeValueAsString(value);
        } catch (Exception e) {
            return "{\"error\":\"结果序列化失败\"}";
        }
    }

    /** 取字符串入参，缺失时返回默认值 */
    protected String str(Map<String, Object> args, String key, String def) {
        if (args == null) {
            return def;
        }
        Object v = args.get(key);
        return v == null || String.valueOf(v).trim().isEmpty() ? def : String.valueOf(v).trim();
    }

    /** 取整数入参，解析失败时返回默认值 */
    protected int integer(Map<String, Object> args, String key, int def) {
        if (args == null) {
            return def;
        }
        try {
            return Integer.parseInt(String.valueOf(args.get(key)).trim());
        } catch (Exception e) {
            return def;
        }
    }
}
