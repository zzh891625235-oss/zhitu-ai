package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.MajorDirection;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 读取学生的 AI 画像与九项能力自评。
 *
 * 画像里存着上一次 AI 生成的优势/短板判断；能力自评则是学生自己勾选的等级。
 * 两者结合，Agent 才能说出「你的算法能力是短板，先补这块」这种有依据的建议，
 * 而不是泛泛地「多练习」。
 */
@Component
public class PortraitTool extends JsonTool {

    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;
    private final ObjectMapper mapper = new ObjectMapper();

    public PortraitTool(StudentProfileMapper profileMapper, MajorMapper majorMapper) {
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
    }

    @Override
    public String name() {
        return "get_ability_portrait";
    }

    @Override
    public String description() {
        return "读取学生的能力画像：九个维度的自评等级、AI 上次生成的优势与短板分析。"
                + "当需要判断「他哪里强、哪里弱」「该先补什么」时调用。"
                + "自评等级取值：BEGINNER(入门) < ELEMENTARY(了解) < INTERMEDIATE(熟练) < ADVANCED(精通)。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        return ToolSchemas.emptyObject();
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        Map<String, Object> out = new LinkedHashMap<>();
        if (p == null) {
            out.put("available", false);
            out.put("message", "尚未填写档案，没有能力数据");
            return json(out);
        }
        out.put("available", true);

        // 能力自评有两套存储，按「当前专业方向」选一套，不能并存着都读：
        //   计算机/电子信息方向 -> 9 个编程字段（下面的 legacyLevels）；
        //   其它方向           -> skillAssessment JSON（{template, items:[{label,value}]}）。
        // 学生换过专业时旧方向的 JSON 可能仍留在库里；不按方向区分的话，
        // 数据科学的学生会被 Agent 当成「医学类自评全零基础」。
        String majorName = resolveMajorName(p.getMajorId());
        boolean it = MajorDirection.isIT(majorName);
        out.put("majorDirection", MajorDirection.resolve(majorName).label());

        List<Map<String, Object>> items = new ArrayList<>();
        if (!it && p.getSkillAssessment() != null && !p.getSkillAssessment().trim().isEmpty()) {
            try {
                JsonNode root = mapper.readTree(p.getSkillAssessment());
                JsonNode arr = root.isArray() ? root : root.get("items");
                if (arr != null && arr.isArray()) {
                    for (JsonNode n : arr) {
                        Map<String, Object> item = new LinkedHashMap<>();
                        item.put("skill", n.path("label").asText(""));
                        item.put("level", n.path("value").asText("BEGINNER"));
                        items.add(item);
                    }
                }
            } catch (Exception ignored) {
                // 历史数据格式可能不规范，忽略后走空列表
            }
        }
        out.put("skillCount", items.size());
        out.put("skills", items);

        // 计算机/电子信息方向的能力自评就写在这 9 个字段上（历史命名沿用 legacy）；
        // 其它方向若恰好也有值（例如换专业前填过），一并给出供参考
        Map<String, Object> legacy = new LinkedHashMap<>();
        putIfNotBlank(legacy, "programming", p.getProgrammingLevel());
        putIfNotBlank(legacy, "java", p.getJavaLevel());
        putIfNotBlank(legacy, "python", p.getPythonLevel());
        putIfNotBlank(legacy, "cpp", p.getCppLevel());
        putIfNotBlank(legacy, "dataStructure", p.getDsLevel());
        putIfNotBlank(legacy, "database", p.getDbLevel());
        putIfNotBlank(legacy, "web", p.getWebLevel());
        putIfNotBlank(legacy, "ai", p.getAiLevel());
        putIfNotBlank(legacy, "english", p.getEnglishLevel());
        if (!legacy.isEmpty()) {
            out.put("legacyLevels", legacy);
        }

        String portrait = p.getAiPortrait();
        if (portrait != null && !portrait.trim().isEmpty()) {
            // 画像可能很长，只回传前 600 字，够模型抓住结论又不至于淹没上下文
            out.put("aiPortrait", portrait.length() > 600 ? portrait.substring(0, 600) + "…" : portrait);
        } else {
            out.put("aiPortrait", null);
        }
        return json(out);
    }

    private String resolveMajorName(Long majorId) {
        if (majorId == null) {
            return "";
        }
        try {
            Major major = majorMapper.selectById(majorId);
            return major == null ? "" : String.valueOf(major.getName());
        } catch (Exception e) {
            return "";
        }
    }

    private void putIfNotBlank(Map<String, Object> map, String key, String value) {
        if (value != null && !value.trim().isEmpty()) {
            map.put(key, value);
        }
    }

    @Override
    public String dataDomain() {
        return "private:student_profile";
    }
}

