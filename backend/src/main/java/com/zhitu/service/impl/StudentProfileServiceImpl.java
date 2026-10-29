package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.MajorDirection;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.entity.User;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.mapper.UserMapper;
import com.zhitu.service.StudentProfileService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 学生档案服务 - 包含AI画像生成
 */
@Service
public class StudentProfileServiceImpl implements StudentProfileService {

    private final StudentProfileMapper profileMapper;
    private final UserMapper userMapper;
    private final MajorMapper majorMapper;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public StudentProfileServiceImpl(StudentProfileMapper profileMapper,
                                      UserMapper userMapper,
                                      MajorMapper majorMapper,
                                      AIService aiService) {
        this.profileMapper = profileMapper;
        this.userMapper = userMapper;
        this.majorMapper = majorMapper;
        this.aiService = aiService;
    }

    @Override
    public StudentProfile saveProfile(Long userId, StudentProfile profile) {
        // 换专业时要清掉旧方向的自评数据：
        // 计算机/电子信息方向的自评直接落在 9 个编程字段上，前端不会再发
        // skillAssessment；而 updateById 跳过 null 字段，旧方向（如医学类）
        // 的自评 JSON 会一直残留在库里，污染画像与 Agent 工具的结果。
        // 这里显式写成空串（非 null，能被更新；下游按空白视为「无」）。
        String majorName = resolveMajorName(profile.getMajorId());
        if (MajorDirection.isIT(majorName)
                && (profile.getSkillAssessment() == null || profile.getSkillAssessment().trim().isEmpty())) {
            profile.setSkillAssessment("");
        }
        // 查询是否已有档案
        StudentProfile existing = profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        if (existing != null) {
            profile.setId(existing.getId());
            profile.setUserId(userId);
            profileMapper.updateById(profile);
        } else {
            profile.setUserId(userId);
            profileMapper.insert(profile);
        }
        return profile;
    }

    @Override
    public StudentProfile getByUserId(Long userId) {
        return profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
    }

    @Override
    public Map<String, Object> generatePortrait(Long userId) {
        StudentProfile profile = getByUserId(userId);
        if (profile == null) {
            throw new RuntimeException("请先完善个人档案信息");
        }
        User user = userMapper.selectById(userId);

        // 构建AI提示词
        String systemPrompt = buildPortraitSystemPrompt();
        String userMessage = buildPortraitUserMessage(profile, user);

        try {
            String aiResponse = aiService.chatForUser(userId, systemPrompt, userMessage);
            // 提取JSON部分
            String jsonStr = extractJson(aiResponse);
            Map<String, Object> portrait = objectMapper.readValue(jsonStr,
                new TypeReference<Map<String, Object>>() {});

            // 关键校验：
            // AI 未配置或调用失败时，chatForUser 会「降级并返回离线模板文本」而不是抛异常。
            // 那段文本里没有 JSON，extractJson 会退化成返回 "{}"，
            // 若直接存库就会出现「画像已生成但内容全空」的现象（前端显示空白卡片）。
            if (portrait.isEmpty() || portrait.get("summary") == null) {
                Map<String, Object> fallback = buildFallbackPortrait(profile);
                savePortrait(profile, fallback);
                return fallback;
            }

            savePortrait(profile, portrait);
            return portrait;
        } catch (Exception e) {
            // AI 调用异常时同样返回兜底画像
            Map<String, Object> fallback = buildFallbackPortrait(profile);
            savePortrait(profile, fallback);
            return fallback;
        }
    }

    /** 保存画像；失败不影响本次返回，用户至少能看到内容 */
    private void savePortrait(StudentProfile profile, Map<String, Object> portrait) {
        try {
            profile.setAiPortrait(objectMapper.writeValueAsString(portrait));
            profileMapper.updateById(profile);
        } catch (Exception ignored) {
            // 落库失败时不阻断返回
        }
    }

    /** 构建系统提示词 */
    private String buildPortraitSystemPrompt() {
        return "你是一名大学生职业发展规划专家。请根据以下学生信息，分析学生能力并生成画像。\n" +
               "必须严格输出JSON格式，不要有其他文字。JSON结构如下：\n" +
               "{\n" +
               "  \"summary\": \"总体评价(50-100字)\",\n" +
               "  \"strengths\": [\"优势1\",\"优势2\",\"优势3\"],\n" +
               "  \"weaknesses\": [\"不足1\",\"不足2\",\"不足3\"],\n" +
               "  \"scores\": {\n" +
               "    \"programming\": 0,\n" +
               "    \"algorithm\": 0,\n" +
               "    \"project\": 0,\n" +
               "    \"competition\": 0,\n" +
               "    \"ai\": 0,\n" +
               "    \"english\": 0,\n" +
               "    \"overall\": 0\n" +
               "  },\n" +
               "  \"suggestions\": [\"建议1\",\"建议2\",\"建议3\"],\n" +
               "  \"threeMonthPlan\": [\"第1个月目标\",\"第2个月目标\",\"第3个月目标\"]\n" +
               "}\n" +
               "分数范围0-100，根据学生实际水平客观打分。";
    }

    /** 构建用户消息 */
    private String buildPortraitUserMessage(StudentProfile p, User u) {
        StringBuilder sb = new StringBuilder();
        sb.append("学生信息：\n");
        sb.append("昵称：").append(u.getNickname()).append("\n");
        sb.append("学校：").append(p.getSchool()).append("\n");
        sb.append("专业：").append(resolveMajorName(p.getMajorId())).append("\n");
        sb.append("年级：").append(p.getGrade()).append("\n");
        sb.append("成绩水平：").append(p.getGpa()).append("\n");
        // 能力自评：计算机/电子信息专业用那 9 个编程字段，
        // 其它专业用 skillAssessment 里保存的通用能力项。
        // 否则会给临床医学的学生塞一堆「Java基础」「数据结构」，纯属噪声。
        //
        // 注意必须按「当前专业方向」来选，而不是「skillAssessment 有没有值」：
        // 学生换过专业时，旧方向的自评 JSON 还留在库里（前端改专业后不会重发该字段，
        // updateById 又跳过 null），若只看有没有值，就会把数据科学学生的画像
        // 按残留的「医学类自评」生成——AI 只能如实报告两者对不上。
        String majorName = resolveMajorName(p.getMajorId());
        String skillText = MajorDirection.isIT(majorName) ? null : describeSkillAssessment(p.getSkillAssessment());
        if (skillText != null) {
            sb.append("专业能力自评：\n").append(skillText);
        } else {
            sb.append("编程基础：").append(p.getProgrammingLevel()).append("\n");
            sb.append("Java基础：").append(p.getJavaLevel()).append("\n");
            sb.append("Python基础：").append(p.getPythonLevel()).append("\n");
            sb.append("C/C++基础：").append(p.getCppLevel()).append("\n");
            sb.append("数据结构：").append(p.getDsLevel()).append("\n");
            sb.append("数据库基础：").append(p.getDbLevel()).append("\n");
            sb.append("Web开发：").append(p.getWebLevel()).append("\n");
            sb.append("AI基础：").append(p.getAiLevel()).append("\n");
            sb.append("英语水平：").append(p.getEnglishLevel()).append("\n");
        }
        sb.append("兴趣方向：").append(p.getInterests()).append("\n");
        sb.append("职业目标：").append(p.getCareerGoal()).append("\n");
        sb.append("\n请基于以上信息生成学生画像JSON。");
        return sb.toString();
    }

    /** 从AI回复中提取JSON */
    private String extractJson(String text) {
        int start = text.indexOf("{");
        int end = text.lastIndexOf("}");
        if (start >= 0 && end > start) {
            return text.substring(start, end + 1);
        }
        return "{}";
    }

    /**
     * AI 不可用时的兜底画像。
     *
     * 内容按专业方向给出：让土木工程的学生看到「每天 1-2 小时编程练习」「关注蓝桥杯」
     * 是没有意义的，不如给一些他真正用得上的建议。
     */
    private Map<String, Object> buildFallbackPortrait(StudentProfile p) {
        MajorDirection direction = MajorDirection.resolve(resolveMajorName(p.getMajorId()));
        String grade = (p.getGrade() == null || p.getGrade().isEmpty()) ? "在读" : p.getGrade();

        Map<String, Object> portrait = new LinkedHashMap<>();
        portrait.put("summary", "你是" + grade + "的" + direction.label() + "学生。"
            + "以下评估由系统按你的自评数据生成，是一份通用参考。"
            + "在「API 设置」中配置 Key 后，可以得到贴合你个人情况的深度分析。");
        portrait.put("strengths", direction.strengths());
        portrait.put("weaknesses", direction.weaknesses());

        Map<String, Object> scores = new LinkedHashMap<>();
        scores.put("programming", levelToScore(p.getProgrammingLevel()));
        scores.put("algorithm", levelToScore(p.getDsLevel()));
        scores.put("project", levelToScore(p.getWebLevel()));
        scores.put("competition", 40);
        scores.put("ai", levelToScore(p.getAiLevel()));
        scores.put("english", levelToScore(p.getEnglishLevel()));
        int sum = 0;
        for (Object v : scores.values()) sum += (Integer) v;
        scores.put("overall", sum / 6);
        portrait.put("scores", scores);

        // 雷达图的六个维度名随专业变化，否则土木专业会看到「编程 / 算法」这种无关标签
        portrait.put("dimensionLabels", dimensionLabels(direction));
        portrait.put("suggestions", direction.suggestions());

        MajorDirection.YearPlan firstYear = direction.years()[0];
        List<String> threeMonth = new ArrayList<>();
        List<String> goals = firstYear.goals;
        for (int i = 0; i < Math.min(3, goals.size()); i++) {
            threeMonth.add("第" + (i + 1) + "个月：" + goals.get(i));
        }
        portrait.put("threeMonthPlan", threeMonth);
        return portrait;
    }

    /** 不同专业方向的能力维度命名 */
    private List<String> dimensionLabels(MajorDirection direction) {
        switch (direction.label()) {
            case "计算机 / 电子信息":
                return Arrays.asList("编程", "算法", "项目", "竞赛", "AI", "英语");
            case "土木 / 建筑类":
                return Arrays.asList("力学", "制图", "专业软件", "实践", "竞赛", "英语");
            case "机电 / 自动化 / 材料类":
                return Arrays.asList("数理", "制图", "专业软件", "动手", "竞赛", "英语");
            case "医学类":
                return Arrays.asList("基础医学", "临床", "实验", "科研", "竞赛", "医学英语");
            case "经管类":
                return Arrays.asList("经济学", "财务", "数据分析", "实践", "竞赛", "英语");
            case "法学类":
                return Arrays.asList("法条", "案例", "逻辑", "写作", "实务", "英语");
            case "教育类":
                return Arrays.asList("教育理论", "心理学", "教学技能", "实践", "竞赛", "英语");
            case "艺术类":
                return Arrays.asList("专业技能", "作品集", "创意", "软件", "展览", "英语");
            case "农学类":
                return Arrays.asList("生物学", "实验", "田间实践", "科研", "竞赛", "英语");
            case "理科基础类":
                return Arrays.asList("数学", "推理", "计算工具", "科研", "竞赛", "英语");
            case "人文社科 / 外语类":
                return Arrays.asList("阅读", "写作", "研究方法", "表达", "实践", "外语");
            default:
                return Arrays.asList("专业理论", "实践", "工具", "协作", "竞赛", "英语");
        }
    }

    /** 等级转分数 */
    private int levelToScore(String level) {
        if (level == null) return 30;
        switch (level) {
            case "ADVANCED": return 85;
            case "INTERMEDIATE": return 65;
            case "BASIC": return 45;
            case "BEGINNER": default: return 25;
        }
    }

    /**
     * 把非计算机专业的 skillAssessment JSON 转成提示词文本。
     * 解析失败或没有配置时返回 null，调用方会回退到那 9 个编程字段。
     */
    private String describeSkillAssessment(String json) {
        if (json == null || json.trim().isEmpty()) {
            return null;
        }
        try {
            Map<String, Object> root = objectMapper.readValue(json,
                new TypeReference<Map<String, Object>>() {});
            Object items = root.get("items");
            if (!(items instanceof List) || ((List<?>) items).isEmpty()) {
                return null;
            }
            StringBuilder sb = new StringBuilder();
            Object template = root.get("template");
            if (template != null) {
                sb.append("  （方向：").append(template).append("）\n");
            }
            for (Object item : (List<?>) items) {
                if (!(item instanceof Map)) continue;
                Map<?, ?> row = (Map<?, ?>) item;
                sb.append("  ").append(row.get("label"))
                  .append("：").append(levelToLabel(String.valueOf(row.get("value"))))
                  .append("\n");
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }

    /** 把等级代码转成中文，让提示词更自然 */
    private String levelToLabel(String level) {
        if (level == null || "null".equals(level)) return "未评估";
        switch (level) {
            case "ADVANCED": return "熟练";
            case "INTERMEDIATE": return "中等";
            case "BASIC": return "入门";
            case "BEGINNER": return "零基础";
            default: return level;
        }
    }

    /** 查询专业名称；专业表不可用时回退为「未填写」，不影响画像生成 */
    private String resolveMajorName(Long majorId) {
        if (majorId == null) {
            return "未填写";
        }
        try {
            Major major = majorMapper.selectById(majorId);
            return major == null ? "未填写" : major.getName();
        } catch (Exception e) {
            return "未填写";
        }
    }
}

