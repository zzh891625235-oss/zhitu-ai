package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
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

    private Map<String, Object> buildFallbackPlan(StudentProfile p) {
        Map<String, Object> plan = new LinkedHashMap<>();
        boolean isCS = true; // 计算机专业

        String career = p.getCareerGoal() != null ? p.getCareerGoal() : "就业";

        plan.put("overview", "基于你的" + p.getGrade() + "年级和" + career + "目标，为你制定以下四年规划。");

        // 大一
        Map<String, Object> freshman = new LinkedHashMap<>();
        freshman.put("theme", "打好基础，探索方向");
        freshman.put("goals", Arrays.asList("掌握至少一门编程语言", "通过英语四级", "培养自主学习习惯", "了解专业方向"));
        freshman.put("courses", Arrays.asList("C语言程序设计", "Python程序设计", "高等数学", "大学英语"));
        freshman.put("skills", Arrays.asList("C语言基础", "Python基础语法", "Linux基本操作"));
        freshman.put("competitions", Arrays.asList("校级编程竞赛", "英语竞赛"));
        freshman.put("tips", "大一最重要的是打好编程和数学基础，不要急于求成。多写代码，少看视频。");
        plan.put("freshman", freshman);

        // 大二
        Map<String, Object> sophomore = new LinkedHashMap<>();
        sophomore.put("theme", "核心能力建设");
        sophomore.put("goals", Arrays.asList("掌握数据结构和算法", "完成2-3个实战项目", "通过英语六级", "参加省级以上竞赛"));
        sophomore.put("courses", Arrays.asList("数据结构", "数据库原理", "Java程序设计", "Web前端开发", "Spring Boot框架"));
        sophomore.put("skills", Arrays.asList("Java/Spring Boot", "MySQL", "Vue.js", "Git版本控制"));
        sophomore.put("competitions", Arrays.asList("蓝桥杯", "传智杯", "大学生计算机设计大赛"));
        sophomore.put("tips", "大二是能力爆发的关键期。数据结构必须学扎实，至少参加一个比赛积累经验。");
        plan.put("sophomore", sophomore);

        // 大三
        Map<String, Object> junior = new LinkedHashMap<>();
        if ("考研".equals(career) || "保研".equals(career)) {
            junior.put("theme", "升学备战");
            junior.put("goals", Arrays.asList("完成考研/保研科目复习", "保持GPA", "参与科研项目", "发表论文"));
            junior.put("courses", Arrays.asList("操作系统", "计算机网络", "机器学习", "软件工程"));
            junior.put("skills", Arrays.asList("数学(高数/线代/概率)", "408专业课", "英语"));
            junior.put("competitions", Arrays.asList("数学建模竞赛", "ACM-ICPC"));
            junior.put("tips", "大三上学期确定目标院校，下学期开始系统复习。科研经历对复试很重要。");
        } else if ("考公".equals(career)) {
            junior.put("theme", "公考准备 + 专业提升");
            junior.put("goals", Arrays.asList("开始行测/申论学习", "完成专业核心课", "准备实习"));
            junior.put("courses", Arrays.asList("操作系统", "计算机网络", "软件工程"));
            junior.put("skills", Arrays.asList("行测刷题", "申论写作", "Java/Python项目"));
            junior.put("competitions", Arrays.asList("互联网+创新创业大赛"));
            junior.put("tips", "考公和专业技术两手准备，不要孤注一掷。");
        } else {
            junior.put("theme", "职业方向确定 + 深度实战");
            junior.put("goals", Arrays.asList("确定职业方向(后端/前端/AI等)", "完成2个深度项目", "找一份实习", "准备秋招"));
            junior.put("courses", Arrays.asList("操作系统", "计算机网络", "机器学习", "软件工程"));
            junior.put("skills", Arrays.asList("Spring Boot深入", "Redis", "Docker", "设计模式"));
            junior.put("competitions", Arrays.asList("互联网+创新创业大赛", "数学建模竞赛"));
            junior.put("tips", "大三要找实习！实习经历是校招最重要的加分项。暑假开始准备秋招。");
        }
        plan.put("junior", junior);

        // 大四
        Map<String, Object> senior = new LinkedHashMap<>();
        if ("考研".equals(career) || "保研".equals(career)) {
            senior.put("theme", "冲刺 + 毕业");
            senior.put("goals", Arrays.asList("完成考研/保研", "完成毕业设计", "准备复试"));
            senior.put("courses", Arrays.asList("毕业设计"));
            senior.put("skills", Arrays.asList("复试准备", "科研方向深入"));
            senior.put("competitions", Collections.emptyList());
            senior.put("tips", "考研冲刺阶段保持心态，保研同学提前联系导师。");
        } else if ("考公".equals(career)) {
            senior.put("theme", "公考冲刺 + 就业双选");
            senior.put("goals", Arrays.asList("参加国考/省考", "完成毕业设计", "准备春招备选"));
            senior.put("courses", Arrays.asList("毕业设计"));
            senior.put("skills", Arrays.asList("真题模拟", "面试技巧"));
            senior.put("competitions", Collections.emptyList());
            senior.put("tips", "不要把所有希望放在考公上，春招也要关注。");
        } else {
            senior.put("theme", "收获成果");
            senior.put("goals", Arrays.asList("完成秋招/春招签约", "完成毕业设计", "规划职业发展"));
            senior.put("courses", Arrays.asList("毕业设计"));
            senior.put("skills", Arrays.asList("简历优化", "面试技巧", "职业素养"));
            senior.put("competitions", Collections.emptyList());
            senior.put("tips", "第一份工作很重要，选择能让你快速成长的公司和岗位。");
        }
        plan.put("senior", senior);

        plan.put("risks", Arrays.asList(
            "大二数据结构没学好→ 后续算法和面试都会受影响",
            "没有实习经历→ 校招竞争力明显不足",
            "英语六级没过→ 部分大厂有硬性要求"
        ));
        plan.put("certificates", Arrays.asList(
            "大学英语四级/六级(CET-4/6)",
            "软件设计师(中级职称)",
            "计算机等级考试",
            career.contains("就业") ? "阿里/华为等大厂认证" : "教师资格证"
        ));

        return plan;
    }
}

