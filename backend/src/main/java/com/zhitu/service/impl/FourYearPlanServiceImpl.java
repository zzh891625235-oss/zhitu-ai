package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.MajorDirection;
import com.zhitu.entity.AiPlan;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.entity.User;
import com.zhitu.mapper.AiPlanMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.mapper.UserMapper;
import com.zhitu.service.FourYearPlanService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
public class FourYearPlanServiceImpl implements FourYearPlanService {

    private final StudentProfileMapper profileMapper;
    private final UserMapper userMapper;
    private final AiPlanMapper aiPlanMapper;
    private final MajorMapper majorMapper;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public FourYearPlanServiceImpl(StudentProfileMapper profileMapper, UserMapper userMapper,
                                    AiPlanMapper aiPlanMapper, MajorMapper majorMapper,
                                    AIService aiService) {
        this.profileMapper = profileMapper;
        this.userMapper = userMapper;
        this.aiPlanMapper = aiPlanMapper;
        this.majorMapper = majorMapper;
        this.aiService = aiService;
    }

    @Override
    public Map<String, Object> generatePlan(Long userId) {
        StudentProfile profile = profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        if (profile == null) throw new RuntimeException("请先完善个人档案");

        User user = userMapper.selectById(userId);
        String systemPrompt = buildSystemPrompt();
        String userMessage = buildUserMessage(profile, user);

        try {
            String aiResponse = aiService.chatForUser(userId, systemPrompt, userMessage);
            String jsonStr = extractJson(aiResponse);
            Map<String, Object> plan = objectMapper.readValue(jsonStr,
                new TypeReference<Map<String, Object>>() {});

            // AI 降级时返回的是离线模板文本，extractJson 会退化成 "{}"，
            // 这里必须校验，否则会把一份空规划存进数据库
            if (plan.isEmpty() || plan.get("freshman") == null) {
                Map<String, Object> fallback = buildFallbackPlan(profile);
                savePlan(userId, fallback);
                return fallback;
            }

            // 保存到数据库
            savePlan(userId, plan);
            return plan;
        } catch (Exception e) {
            Map<String, Object> fallback = buildFallbackPlan(profile);
            savePlan(userId, fallback);
            return fallback;
        }
    }

    @Override
    public Map<String, Object> getPlan(Long userId) {
        AiPlan aiPlan = aiPlanMapper.selectOne(
            new LambdaQueryWrapper<AiPlan>()
                .eq(AiPlan::getUserId, userId)
                .eq(AiPlan::getPlanType, "FOUR_YEAR")
                .orderByDesc(AiPlan::getCreatedAt)
                .last("LIMIT 1"));
        if (aiPlan == null) return null;
        try {
            return objectMapper.readValue(aiPlan.getContent(),
                new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            return null;
        }
    }

    private void savePlan(Long userId, Map<String, Object> plan) {
        // 先删除旧规划
        aiPlanMapper.delete(new LambdaQueryWrapper<AiPlan>()
            .eq(AiPlan::getUserId, userId).eq(AiPlan::getPlanType, "FOUR_YEAR"));
        AiPlan aiPlan = new AiPlan();
        aiPlan.setUserId(userId);
        aiPlan.setPlanType("FOUR_YEAR");
        try {
            aiPlan.setContent(objectMapper.writeValueAsString(plan));
        } catch (Exception ignored) {}
        aiPlan.setStartDate(LocalDate.now());
        aiPlan.setEndDate(LocalDate.now().plusYears(4));
        aiPlan.setStatus("ACTIVE");
        aiPlanMapper.insert(aiPlan);
    }

    private String buildSystemPrompt() {
        return "你是一名大学生成长规划专家。请根据学生信息生成大学四年成长规划。\n" +
               "严格输出JSON格式：\n" +
               "{\n" +
               "  \"overview\": \"总体概述(30字)\",\n" +
               "  \"freshman\": { \"theme\": \"大一主题\", \"goals\": [\"目标1\"], \"courses\": [\"课程1\"], \"skills\": [\"技能1\"], \"competitions\": [\"比赛1\"], \"tips\": \"建议\" },\n" +
               "  \"sophomore\": { \"theme\": \"大二主题\", \"goals\": [], \"courses\": [], \"skills\": [], \"competitions\": [], \"tips\": \"\" },\n" +
               "  \"junior\": { \"theme\": \"大三主题\", \"goals\": [], \"courses\": [], \"skills\": [], \"competitions\": [], \"tips\": \"\" },\n" +
               "  \"senior\": { \"theme\": \"大四主题\", \"goals\": [], \"courses\": [], \"skills\": [], \"competitions\": [], \"tips\": \"\" },\n" +
               "  \"risks\": [\"风险提醒1\",\"风险提醒2\"],\n" +
               "  \"certificates\": [\"推荐证书1\",\"推荐证书2\"]\n" +
               "}\n" +
               "根据学生当前年级，已完成年份标记为completed。结合学生的职业目标(就业/考研/保研/考公)给出具体建议。";
    }

    private String buildUserMessage(StudentProfile p, User u) {
        StringBuilder sb = new StringBuilder();
        sb.append("学生信息：\n");
        sb.append("昵称：").append(u.getNickname()).append("\n");
        sb.append("学校：").append(p.getSchool()).append("\n");
        sb.append("专业：").append(resolveMajorName(p.getMajorId())).append("\n");
        sb.append("年级：").append(p.getGrade()).append("\n");
        sb.append("成绩：").append(p.getGpa()).append("\n");
        // 非计算机专业不要输出编程相关字段，否则会误导规划方向
        if (p.getSkillAssessment() != null && !p.getSkillAssessment().trim().isEmpty()) {
            sb.append("说明：该生为").append(resolveMajorName(p.getMajorId()))
              .append("专业，非计算机方向，请按该专业的特点给出规划。\n");
        } else {
            sb.append("编程基础：").append(p.getProgrammingLevel()).append("\n");
        }
        sb.append("英语水平：").append(p.getEnglishLevel()).append("\n");
        sb.append("兴趣：").append(p.getInterests()).append("\n");
        sb.append("职业目标：").append(p.getCareerGoal()).append("\n");
        return sb.toString();
    }

    private String extractJson(String text) {
        int s = text.indexOf("{"), e = text.lastIndexOf("}");
        return (s >= 0 && e > s) ? text.substring(s, e + 1) : "{}";
    }

    /** 查询专业名称；专业表不可用时回退为「未填写」，避免影响规划生成 */
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

    /**
     * AI 不可用时的兜底规划。
     *
     * 内容按专业方向给出：土木工程的学生不该看到「C语言 / 数据结构 / 蓝桥杯」，
     * 那对他的规划没有任何参考价值。方向划分见 MajorDirection。
     */
    private Map<String, Object> buildFallbackPlan(StudentProfile p) {
        MajorDirection direction = MajorDirection.resolve(resolveMajorName(p.getMajorId()));
        MajorDirection.YearPlan[] years = direction.years();
        String career = (p.getCareerGoal() == null || p.getCareerGoal().isEmpty()) ? "就业" : p.getCareerGoal();

        Map<String, Object> plan = new LinkedHashMap<>();
        plan.put("overview", "这是为你（" + direction.label() + " · " + p.getGrade() + " · 目标" + career
            + "）生成的规划框架。在「API 设置」中配置 Key 后，AI 会结合你的具体基础给出更贴合的版本。");

        plan.put("freshman", toYearMap(years[0]));
        plan.put("sophomore", toYearMap(years[1]));
        plan.put("junior", toYearMap(years[2], careerGoals(career, true)));
        plan.put("senior", toYearMap(years[3], careerGoals(career, false)));
        plan.put("risks", direction.risks());
        plan.put("certificates", direction.certificates());
        return plan;
    }

    /** 按职业目标给大三 / 大四追加几条更有针对性的目标 */
    private List<String> careerGoals(String career, boolean junior) {
        if ("考研".equals(career) || "保研".equals(career)) {
            return junior ? Arrays.asList("确定目标院校与导师", "开始系统复习")
                          : Arrays.asList("完成考研 / 保研", "准备复试");
        }
        if ("考公".equals(career)) {
            return junior ? Arrays.asList("开始行测与申论学习")
                          : Arrays.asList("参加国考 / 省考");
        }
        if ("创业".equals(career)) {
            return junior ? Arrays.asList("验证商业想法，做小范围尝试")
                          : Arrays.asList("推进项目落地");
        }
        return junior ? Arrays.asList("争取一份对口实习", "提前准备秋招")
                      : Arrays.asList("完成秋招签约");
    }

    private Map<String, Object> toYearMap(MajorDirection.YearPlan year) {
        return toYearMap(year, Collections.<String>emptyList());
    }

    private Map<String, Object> toYearMap(MajorDirection.YearPlan year, List<String> extraGoals) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("theme", year.theme);
        List<String> goals = new ArrayList<>(year.goals);
        goals.addAll(extraGoals);
        map.put("goals", goals);
        map.put("courses", year.courses);
        map.put("skills", year.skills);
        map.put("competitions", year.competitions);
        map.put("tips", year.tips);
        return map;
    }
}