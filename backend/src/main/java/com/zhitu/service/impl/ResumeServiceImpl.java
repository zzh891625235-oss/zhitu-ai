package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.entity.*;
import com.zhitu.mapper.*;
import com.zhitu.service.ResumeService;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class ResumeServiceImpl implements ResumeService {

    private final StudentProfileMapper profileMapper;
    private final UserMapper userMapper;
    private final LearningRecordMapper learnMapper;
    private final GrowthRecordMapper growthMapper;
    private final ResumeMapper resumeMapper;
    private final MajorMapper majorMapper;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ResumeServiceImpl(StudentProfileMapper profileMapper, UserMapper userMapper,
                              LearningRecordMapper learnMapper, GrowthRecordMapper growthMapper,
                              ResumeMapper resumeMapper, MajorMapper majorMapper,
                              AIService aiService) {
        this.profileMapper = profileMapper;
        this.userMapper = userMapper;
        this.learnMapper = learnMapper;
        this.growthMapper = growthMapper;
        this.resumeMapper = resumeMapper;
        this.majorMapper = majorMapper;
        this.aiService = aiService;
    }

    @Override
    public Map<String, Object> generateResume(Long userId) {
        StudentProfile profile = profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        User user = userMapper.selectById(userId);

        List<LearningRecord> learnRecords = learnMapper.selectList(
            new LambdaQueryWrapper<LearningRecord>().eq(LearningRecord::getUserId, userId));
        List<GrowthRecord> growthRecords = growthMapper.selectList(
            new LambdaQueryWrapper<GrowthRecord>().eq(GrowthRecord::getUserId, userId));

        try {
            String prompt = buildPrompt();
            String msg = buildUserMessage(profile, user, learnRecords, growthRecords);
            String aiResp = aiService.chatForUser(userId, prompt, msg);
            String json = extractJson(aiResp);
            Map<String, Object> resume = objectMapper.readValue(json,
                new TypeReference<Map<String, Object>>() {});

            // AI 降级时返回离线模板文本，extractJson 会退化成 "{}"，
            // 直接保存会导致简历页显示一张空白 A4 纸
            if (resume.isEmpty() || resume.get("name") == null) {
                return buildFallbackResume(profile, user, learnRecords, growthRecords, userId);
            }

            saveResume(userId, resume);
            return resume;
        } catch (Exception e) {
            return buildFallbackResume(profile, user, learnRecords, growthRecords, userId);
        }
    }

    @Override
    public Map<String, Object> getResume(Long userId) {
        Resume r = resumeMapper.selectOne(
            new LambdaQueryWrapper<Resume>().eq(Resume::getUserId, userId));
        if (r == null) return null;
        try {
            return objectMapper.readValue(r.getContent(), new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) { return null; }
    }

    private void saveResume(Long userId, Map<String, Object> resume) {
        resumeMapper.delete(new LambdaQueryWrapper<Resume>().eq(Resume::getUserId, userId));
        Resume r = new Resume();
        r.setUserId(userId);
        try { r.setContent(objectMapper.writeValueAsString(resume)); } catch (Exception ignored) {}
        r.setTemplate("DEFAULT");
        resumeMapper.insert(r);
    }

    private String buildPrompt() {
        return "你是简历专家。根据学生信息生成简历JSON：\n" +
               "{\"name\":\"\",\"education\":{\"school\":\"\",\"major\":\"\",\"grade\":\"\"},\"skills\":[],\"courses\":[],\"projects\":[],\"competitions\":[],\"certificates\":[],\"advantages\":\"个人优势(50字)\",\"targetPosition\":\"意向岗位\"}\n" +
               "skills/courses/projects/competitions/certificates都是字符串数组。基于实际数据填写，不要编造。";
    }

    private String buildUserMessage(StudentProfile p, User u, List<LearningRecord> lr, List<GrowthRecord> gr) {
        StringBuilder sb = new StringBuilder();
        sb.append("学生：").append(u.getNickname()).append("\n");
        sb.append("学校:").append(p.getSchool())
          .append(" 专业:").append(resolveMajorName(p.getMajorId()))
          .append(" 年级:").append(p.getGrade()).append("\n");
        // 非计算机专业不要写「编程/Java/Python」这些字段，否则简历会跑偏
        if (p.getSkillAssessment() != null && !p.getSkillAssessment().trim().isEmpty()) {
            sb.append("专业方向：").append(resolveMajorName(p.getMajorId())).append("（非计算机方向）\n");
            sb.append("英语:").append(p.getEnglishLevel()).append("\n");
        } else {
            sb.append("编程:").append(p.getProgrammingLevel()).append(" Java:").append(p.getJavaLevel())
              .append(" Python:").append(p.getPythonLevel()).append(" 英语:").append(p.getEnglishLevel()).append("\n");
        }
        sb.append("兴趣:").append(p.getInterests()).append(" 目标:").append(p.getCareerGoal()).append("\n");
        if (!lr.isEmpty()) {
            sb.append("学习记录:").append(lr.size()).append("条\n");
        }
        if (!gr.isEmpty()) {
            sb.append("成长记录:\n");
            for (GrowthRecord g : gr) sb.append("- [").append(g.getRecordType()).append("] ").append(g.getTitle()).append("\n");
        }
        return sb.toString();
    }

    private String extractJson(String text) {
        int s = text.indexOf("{"), e = text.lastIndexOf("}");
        return (s >= 0 && e > s) ? text.substring(s, e + 1) : "{}";
    }

    private Map<String, Object> buildFallbackResume(StudentProfile p, User u,
                                                     List<LearningRecord> lr, List<GrowthRecord> gr, Long userId) {
        Map<String, Object> resume = new LinkedHashMap<>();
        resume.put("name", u.getNickname());

        Map<String, String> edu = new LinkedHashMap<>();
        edu.put("school", p.getSchool());
        edu.put("major", resolveMajorName(p.getMajorId()));
        edu.put("grade", p.getGrade());
        resume.put("education", edu);

        List<String> skills = new ArrayList<>();
        if (!"BEGINNER".equals(p.getJavaLevel())) skills.add("Java/" + p.getJavaLevel());
        if (!"BEGINNER".equals(p.getPythonLevel())) skills.add("Python/" + p.getPythonLevel());
        skills.add("MySQL");
        skills.add("Spring Boot");
        skills.add("Git");
        resume.put("skills", skills);

        List<String> projects = new ArrayList<>();
        for (GrowthRecord g : gr) {
            if ("PROJECT".equals(g.getRecordType())) projects.add(g.getTitle() + " - " + g.getDescription());
        }
        if (projects.isEmpty()) projects.add("基于Spring Boot的学生管理系统");
        resume.put("projects", projects);

        List<String> competitions = new ArrayList<>();
        for (GrowthRecord g : gr) {
            if ("COMPETITION".equals(g.getRecordType())) competitions.add(g.getTitle());
        }
        resume.put("competitions", competitions);

        List<String> certs = new ArrayList<>();
        for (GrowthRecord g : gr) {
            if ("CERTIFICATE".equals(g.getRecordType())) certs.add(g.getTitle());
        }
        resume.put("certificates", certs);

        resume.put("advantages", "具备" + p.getProgrammingLevel() + "级编程基础，熟悉Java和Python，有良好的自学能力和团队协作精神。");
        resume.put("targetPosition", "Java后端开发工程师");

        saveResume(userId, resume);
        return resume;
    }

    /** 查询专业名称；专业表不可用时回退为「未填写」，不影响简历生成 */
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

