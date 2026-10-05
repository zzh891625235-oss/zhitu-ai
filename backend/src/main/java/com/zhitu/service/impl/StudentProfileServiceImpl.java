package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
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

            // 保存AI画像到档案
            profile.setAiPortrait(objectMapper.writeValueAsString(portrait));
            profileMapper.updateById(profile);

            return portrait;
        } catch (Exception e) {
            // AI调用失败时返回模拟画像
            return buildFallbackPortrait(profile);
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
        String skillText = describeSkillAssessment(p.getSkillAssessment());
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

    /** AI不可用时的兜底画像 */
    private Map<String, Object> buildFallbackPortrait(StudentProfile p) {
        Map<String, Object> portrait = new LinkedHashMap<>();
        portrait.put("summary", "你是一位有潜力的" + p.getGrade() + "学生，基础能力正在成长中。建议制定系统学习计划，逐步提升核心技能。");
        portrait.put("strengths", Arrays.asList("学习态度积极", "对专业有兴趣", "目标明确"));
        portrait.put("weaknesses", Arrays.asList("项目经验不足", "算法基础待加强", "竞赛经历较少"));

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

        portrait.put("suggestions", Arrays.asList(
            "建议每天保持1-2小时编程练习",
            "参加至少1个团队项目积累经验",
            "关注蓝桥杯等适合新手的竞赛"
        ));
        portrait.put("threeMonthPlan", Arrays.asList(
            "第1个月：夯实编程基础，完成1个小项目",
            "第2个月：学习数据结构和算法，刷题30道",
            "第3个月：参加1个校级比赛，积累竞赛经验"
        ));
        return portrait;
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

