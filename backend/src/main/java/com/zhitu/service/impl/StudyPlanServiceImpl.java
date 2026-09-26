package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
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
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public StudyPlanServiceImpl(StudyPlanMapper planMapper, LearningRecordMapper recordMapper,
                                 StudentProfileMapper profileMapper, AIService aiService) {
        this.planMapper = planMapper;
        this.recordMapper = recordMapper;
        this.profileMapper = profileMapper;
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
            String aiResp = aiService.chat(prompt, msg);
            String json = extractJson(aiResp);
            List<Map<String, Object>> plans = objectMapper.readValue(json,
                new TypeReference<List<Map<String, Object>>>() {});
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
        StringBuilder sb = new StringBuilder();
        sb.append("学生：").append(p.getGrade()).append("，编程").append(p.getProgrammingLevel())
          .append("，Java").append(p.getJavaLevel()).append("，Python").append(p.getPythonLevel())
          .append("，数据结构").append(p.getDsLevel()).append("\n");
        if (!records.isEmpty()) {
            sb.append("最近学习记录：\n");
            for (LearningRecord r : records) {
                sb.append("- 课程").append(r.getCourseId()).append("：").append(r.getNotes())
                  .append("（").append(r.getStudyMinutes()).append("分钟）\n");
            }
        }
        sb.append("请生成未来").append(days).append("天的学习计划。");
        return sb.toString();
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
        String[] courses = {"Java程序设计", "数据结构", "算法练习", "Spring Boot", "Python", "数据库", "Web前端"};
        String[] tasks = {"基础语法复习", "链表与树", "LeetCode每日一题", "RESTful API设计", "数据处理练习", "SQL查询优化", "Vue组件开发"};

        // 根据弱项调整安排
        String weakest = "数据结构";
        if ("BEGINNER".equals(p.getJavaLevel())) weakest = "Java";
        else if ("BEGINNER".equals(p.getDsLevel())) weakest = "数据结构";
        else if ("BEGINNER".equals(p.getPythonLevel())) weakest = "Python";

        for (int i = 0; i < days; i++) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("day", i + 1);
            // 弱项多安排
            if (i % 3 == 0) {
                item.put("course", weakest);
                item.put("task", "重点攻克" + weakest + "薄弱环节");
                item.put("duration", "60分钟");
            } else {
                int idx = i % courses.length;
                item.put("course", courses[idx]);
                item.put("task", tasks[idx]);
                item.put("duration", "45分钟");
            }
            plans.add(item);
        }
        savePlans(userId, plans);
        return plans;
    }
}
