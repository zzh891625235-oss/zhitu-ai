package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.GrowthRecord;
import com.zhitu.mapper.GrowthRecordMapper;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 读取成长档案（项目 / 竞赛 / 证书 / 实习 / 荣誉）。
 *
 * 简历和面试建议最怕空对空：这个工具把学生真实沉淀过的经历拉出来，
 * 让 Agent 能指着具体的经历说「这一段应该改成量化的写法」，
 * 而不是给一份人人适用的模板。
 */
@Component
public class GrowthTool extends JsonTool {

    private static final String[] TYPES = {"PROJECT", "COMPETITION", "CERTIFICATE", "INTERNSHIP", "HONOR"};

    private final GrowthRecordMapper growthRecordMapper;

    public GrowthTool(GrowthRecordMapper growthRecordMapper) {
        this.growthRecordMapper = growthRecordMapper;
    }

    @Override
    public String name() {
        return "get_growth_records";
    }

    @Override
    public String description() {
        return "读取学生的成长档案：项目、竞赛获奖、证书、实习、荣誉五类记录的条数与明细。"
                + "当需要写简历优化建议、模拟面试、盘点大学经历时调用。"
                + "recordType 可选值：PROJECT / COMPETITION / CERTIFICATE / INTERNSHIP / HONOR，不传则返回全部类型的统计。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        Map<String, Object> props = new LinkedHashMap<>();
        props.put("recordType", ToolSchemas.enumProp("只看某一类记录，不传则返回全部类型的统计",
                "PROJECT", "COMPETITION", "CERTIFICATE", "INTERNSHIP", "HONOR"));
        props.put("limit", ToolSchemas.intProp("明细最多返回多少条，默认 12"));
        return ToolSchemas.object(props);
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        String type = str(arguments, "recordType", "");
        int limit = Math.max(1, Math.min(50, integer(arguments, "limit", 12)));

        List<GrowthRecord> records = growthRecordMapper.selectList(
                new LambdaQueryWrapper<GrowthRecord>()
                        .eq(GrowthRecord::getUserId, userId)
                        .orderByDesc(GrowthRecord::getRecordDate)
                        .orderByDesc(GrowthRecord::getId));

        Map<String, Integer> stats = new LinkedHashMap<>();
        for (String t : TYPES) {
            stats.put(t, 0);
        }
        List<Map<String, Object>> details = new ArrayList<>();
        for (GrowthRecord r : records) {
            String rt = r.getRecordType() == null ? "PROJECT" : r.getRecordType();
            Integer n = stats.get(rt);
            stats.put(rt, n == null ? 1 : n + 1);
            if ((type.isEmpty() || type.equals(rt)) && details.size() < limit) {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("type", rt);
                item.put("title", r.getTitle());
                item.put("date", String.valueOf(r.getRecordDate()));
                if (r.getDescription() != null && !r.getDescription().isEmpty()) {
                    item.put("description", r.getDescription().length() > 120
                            ? r.getDescription().substring(0, 120) + "…" : r.getDescription());
                }
                details.add(item);
            }
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("statistics", stats);
        out.put("total", records.size());
        out.put("records", details);
        if (records.isEmpty()) {
            out.put("message", "成长档案还是空的，建议先补充 1-2 条课程项目或竞赛经历，简历才有内容可写");
        }
        return json(out);
    }

    @Override
    public String dataDomain() {
        return "private:growth_record";
    }
}
