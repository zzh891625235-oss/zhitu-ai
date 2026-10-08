package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.MajorDirection;
import com.zhitu.entity.*;
import com.zhitu.mapper.*;
import com.zhitu.service.StudyPlanService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
public class StudyPlanServiceImpl implements StudyPlanService {

    private final StudyPlanMapper planMapper;
    private final LearningRecordMapper recordMapper;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public StudyPlanServiceImpl(StudyPlanMapper planMapper, LearningRecordMapper recordMapper,
                                 StudentProfileMapper profileMapper, MajorMapper majorMapper,
                                 AIService aiService) {
        this.planMapper = planMapper;
        this.recordMapper = recordMapper;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
        this.aiService = aiService;
    }

    @Override
    public List<Map<String, Object>> generateStudyPlan(Long userId, int days) {
        StudentProfile profile = profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));

        // 获取最近学习记录用于分析
        List<LearningRecord> recentRecords = recordMapper.selectList(
            new LambdaQueryWrapper<LearningRecord>()
                .eq(LearningRecord::getUserId, userId)
                .orderByDesc(LearningRecord::getCreatedAt)
                .last("LIMIT 10"));

        // 清除旧计划
        planMapper.delete(new LambdaQueryWrapper<StudyPlan>()
            .eq(StudyPlan::getUserId, userId).lt(StudyPlan::getPlanDate, LocalDate.now()));

        try {
            String prompt = buildPrompt();
            String msg = buildUserMessage(profile, recentRecords, days);
            String aiResp = aiService.chatForUser(userId, prompt, msg);
            String json = extractJson(aiResp);
            List<Map<String, Object>> plans = objectMapper.readValue(json,
                new TypeReference<List<Map<String, Object>>>() {});

            // AI 降级时返回离线模板文本，extractJson 会退化成 "[]"，
            // 这里校验后走规则模板，避免学习计划页空白
            if (plans.isEmpty() || plans.get(0).get("task") == null) {
                return buildFallbackPlan(profile, recentRecords, days, userId);
            }

            // 保存到数据库
            savePlans(userId, plans);
            return plans;
        } catch (Exception e) {
            return buildFallbackPlan(profile, recentRecords, days, userId);
        }
    }

    @Override
    public List<Map<String, Object>> getCurrentPlan(Long userId) {
        LocalDate today = LocalDate.now();
        List<StudyPlan> plans = planMapper.selectList(
            new LambdaQueryWrapper<StudyPlan>()
                .eq(StudyPlan::getUserId, userId)
                .ge(StudyPlan::getPlanDate, today)
                .orderByAsc(StudyPlan::getPlanDate));

        List<Map<String, Object>> result = new ArrayList<>();
        for (StudyPlan sp : plans) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", sp.getId());
            item.put("date", sp.getPlanDate().toString());
            item.put("content", sp.getContent());
            item.put("completed", sp.getIsCompleted() == 1);
            result.add(item);
        }
        return result;
    }

    @Override
    public Map<String, Object> recordAndAnalyze(Long userId, String content, int minutes, int courseId) {
        // 保存学习记录
        LearningRecord record = new LearningRecord();
        record.setUserId(userId);
        record.setCourseId((long) courseId);
        record.setStudyMinutes(minutes);
        record.setNotes(content);
        record.setStatus("IN_PROGRESS");
        record.setProgress(minutes > 60 ? 50 : 25);
        recordMapper.insert(record);

        // 获取最新记录统计
        List<LearningRecord> records = recordMapper.selectList(
            new LambdaQueryWrapper<LearningRecord>()
                .eq(LearningRecord::getUserId, userId)
                .orderByDesc(LearningRecord::getCreatedAt)
                .last("LIMIT 20"));
        int totalMinutes = records.stream().mapToInt(LearningRecord::getStudyMinutes).sum();
        int courseCovered = (int) records.stream().map(LearningRecord::getCourseId).distinct().count();

        // AI分析
        Map<String, Object> analysis = new LinkedHashMap<>();
        analysis.put("totalMinutes", totalMinutes);
        analysis.put("coursesCovered", courseCovered);
        analysis.put("recordCount", records.size());

        // 学习连续性分析
        String consistency;
        if (totalMinutes > 600) consistency = "学习势头很好，保持！";
        else if (totalMinutes > 300) consistency = "学习稳定，可以适当增加强度";
        else consistency = "学习时间偏少，建议每天至少坚持1小时";

        analysis.put("consistency", consistency);
        analysis.put("suggestion", generateSuggestion(records));
        analysis.put("mood", totalMinutes > 400 ? "excellent" : totalMinutes > 200 ? "good" : "needs_effort");

        return analysis;
    }

    private String generateSuggestion(List<LearningRecord> records) {
        if (records.isEmpty()) return "开始你的第一条学习记录吧！";
        long courseCount = records.stream().map(LearningRecord::getCourseId).distinct().count();
        if (courseCount <= 1) return "建议拓宽学习范围，不要只学一门课";
        return "继续保持多样化的学习节奏，注意复习巩固";
    }

    private String buildPrompt() {
        return "你是学习计划专家。根据学生情况生成未来N天学习计划。严格输出JSON数组：\n" +
               "[{\"day\":1,\"course\":\"课程名\",\"task\":\"学习任务\",\"duration\":\"预估时长\"}]\n" +
               "根据学生的弱项多安排薄弱环节的练习。";
    }

    private String buildUserMessage(StudentProfile p, List<LearningRecord> records, int days) {
        String majorName = resolveMajorName(p.getMajorId());
        MajorDirection direction = MajorDirection.resolve(majorName);
        StringBuilder sb = new StringBuilder();
        sb.append("专业：").append(majorName).append("（").append(direction.label()).append("）")
          .append("，年级：").append(p.getGrade()).append("\n");
        // 计算机 / 电子信息方向才看那 9 项技术自评；其它方向用专业方向的课程范围约束
        if (MajorDirection.isIT(majorName)) {
            sb.append("编程基础：").append(p.getProgrammingLevel())
              .append("，Java：").append(p.getJavaLevel())
              .append("，Python：").append(p.getPythonLevel())
              .append("，数据结构：").append(p.getDsLevel()).append("\n");
        } else {
            sb.append("本专业方向核心课程参考：");
            for (String c : directionPool(direction)) {
                sb.append(c).append("、");
            }
            sb.append("\n");
        }
        if (!records.isEmpty()) {
            sb.append("最近学习记录：\n");
            for (LearningRecord r : records) {
                sb.append("- 课程").append(r.getCourseId()).append("：").append(r.getNotes())
                  .append("（").append(r.getStudyMinutes()).append("分钟）\n");
            }
        }
        sb.append("请生成未来").append(days).append("天的学习计划，内容必须贴合上述专业方向。");
        return sb.toString();
    }

    /** 查询专业名称；专业表不可用时回退为「未填写」，避免影响计划生成 */
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

    /** 把方向四年规划里的课程拼成去重的课程池，作为计划的选题范围 */
    private List<String> directionPool(MajorDirection direction) {
        List<String> pool = new ArrayList<>();
        for (MajorDirection.YearPlan y : direction.years()) {
            for (String c : y.courses) {
                if (!pool.contains(c)) {
                    pool.add(c);
                }
            }
        }
        if (pool.isEmpty()) {
            pool.add("专业核心课程");
        }
        return pool;
    }

    private int gradeIndex(String grade) {
        if ("大一".equals(grade)) return 0;
        if ("大二".equals(grade)) return 1;
        if ("大三".equals(grade)) return 2;
        if ("大四".equals(grade)) return 3;
        return 1;
    }

    private String extractJson(String text) {
        int s = text.indexOf("["), e = text.lastIndexOf("]");
        return (s >= 0 && e > s) ? text.substring(s, e + 1) : "[]";
    }

    private void savePlans(Long userId, List<Map<String, Object>> plans) {
        LocalDate today = LocalDate.now();
        for (Map<String, Object> p : plans) {
            StudyPlan sp = new StudyPlan();
            sp.setUserId(userId);
            int dayOffset = ((Number) p.getOrDefault("day", 0)).intValue();
            sp.setPlanDate(today.plusDays(dayOffset - 1));
            sp.setContent(p.getOrDefault("task", "").toString());
            sp.setIsCompleted(0);
            planMapper.insert(sp);
        }
    }

    private List<Map<String, Object>> buildFallbackPlan(StudentProfile p, List<LearningRecord> records, int days, Long userId) {
        List<Map<String, Object>> plans = new ArrayList<>();

        // 课程池来自「专业方向」而不是写死的计算机课程：
        // 护理专业的学生不该被安排「数据结构 / Spring Boot」。
        String majorName = resolveMajorName(p.getMajorId());
        MajorDirection direction = MajorDirection.resolve(majorName);
        MajorDirection.YearPlan[] years = direction.years();
        List<String> pool = directionPool(direction);

        // 先按当前年级锁定本年最该攻的一门课
        int gradeIdx = Math.min(Math.max(gradeIndex(p.getGrade()), 0), years.length - 1);
        MajorDirection.YearPlan current = years[gradeIdx];
        String focus = current.courses.isEmpty() ? pool.get(0) : current.courses.get(0);

        // 计算机 / 电子信息方向再叠加一次弱项判断（那 9 项自评只对该方向有意义）
        if (MajorDirection.isIT(majorName)) {
            if ("BEGINNER".equals(p.getDsLevel()) && pool.contains("数据结构")) {
                focus = "数据结构";
            } else if ("BEGINNER".equals(p.getJavaLevel()) && pool.contains("Java程序设计")) {
                focus = "Java程序设计";
            } else if ("BEGINNER".equals(p.getPythonLevel()) && pool.contains("Python程序设计")) {
                focus = "Python程序设计";
            }
        }

        String[] itTasks = {"基础语法复习", "核心概念梳理", "每日一题练习", "动手写一个小功能", "整理错题与笔记"};
        String[] commonTasks = {"梳理知识框架并做笔记", "完成配套习题与例题", "做一个小实验 / 小作品",
                                "复习本周内容并查漏补缺", "整理错题与薄弱点"};
        boolean it = MajorDirection.isIT(majorName);
        String[] tasks = it ? itTasks : commonTasks;

        for (int i = 0; i < days; i++) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("day", i + 1);
            // 弱项多安排
            if (i % 3 == 0) {
                item.put("course", focus);
                item.put("task", "重点攻克「" + focus + "」的薄弱环节");
                item.put("duration", "60分钟");
            } else {
                String course = pool.get(i % pool.size());
                item.put("course", course);
                item.put("task", tasks[i % tasks.length]);
                item.put("duration", "45分钟");
            }
            plans.add(item);
        }
        savePlans(userId, plans);
        return plans;
    }
}

