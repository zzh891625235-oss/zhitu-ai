package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.entity.*;
import com.zhitu.mapper.*;
import com.zhitu.service.CompetitionRecommendService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
public class CompetitionRecommendServiceImpl implements CompetitionRecommendService {

    private final StudentProfileMapper profileMapper;
    private final UserMapper userMapper;
    private final CompetitionMapper competitionMapper;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public CompetitionRecommendServiceImpl(StudentProfileMapper profileMapper, UserMapper userMapper,
                                            CompetitionMapper competitionMapper, AIService aiService) {
        this.profileMapper = profileMapper;
        this.userMapper = userMapper;
        this.competitionMapper = competitionMapper;
        this.aiService = aiService;
    }

    @Override
    public List<Map<String, Object>> recommend(Long userId) {
        StudentProfile profile = profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        if (profile == null) throw new RuntimeException("请先完善档案");

        User user = userMapper.selectById(userId);
        List<Competition> allComps = competitionMapper.selectList(
            new LambdaQueryWrapper<Competition>().eq(Competition::getStatus, "ACTIVE"));

        try {
            String prompt = buildPrompt();
            String msg = buildUserMessage(profile, user, allComps);
            String aiResp = aiService.chat(prompt, msg);
            String json = extractJson(aiResp);
            List<Map<String, Object>> recommendations = objectMapper.readValue(json,
                new TypeReference<List<Map<String, Object>>>() {});
            // 补充竞赛详情
            enrichRecommendations(recommendations, allComps);
            return recommendations;
        } catch (Exception e) {
            return buildFallbackRecommendations(profile, allComps);
        }
    }

    private String buildPrompt() {
        return "你是竞赛推荐专家。根据学生信息和可选竞赛列表，推荐3-4个最合适的竞赛。\n" +
               "严格输出JSON数组：\n" +
               "[{\"competitionId\":1,\"score\":95,\"reasons\":[\"理由1\",\"理由2\"]}]\n" +
               "score是匹配度(0-100)，reasons是推荐理由。按score降序排列。";
    }

    private String buildUserMessage(StudentProfile p, User u, List<Competition> comps) {
        StringBuilder sb = new StringBuilder();
        sb.append("学生：").append(u.getNickname()).append("，").append(p.getGrade())
          .append("，成绩").append(p.getGpa()).append("，编程").append(p.getProgrammingLevel())
          .append("，兴趣").append(p.getInterests()).append("，目标").append(p.getCareerGoal()).append("\n");
        sb.append("可选竞赛：\n");
        for (Competition c : comps) {
            sb.append(c.getId()).append(".").append(c.getName())
              .append(" [类型:").append(c.getType())
              .append(" 难度:").append(c.getDifficulty())
              .append(" 报名截止:").append(c.getRegistrationEnd()).append("]\n");
        }
        return sb.toString();
    }

    private String extractJson(String text) {
        int s = text.indexOf("["), e = text.lastIndexOf("]");
        return (s >= 0 && e > s) ? text.substring(s, e + 1) : "[]";
    }

    private void enrichRecommendations(List<Map<String, Object>> recs, List<Competition> comps) {
        for (Map<String, Object> rec : recs) {
            Long compId = ((Number) rec.get("competitionId")).longValue();
            Competition comp = comps.stream().filter(c -> c.getId().equals(compId)).findFirst().orElse(null);
            if (comp != null) {
                rec.put("name", comp.getName());
                rec.put("type", comp.getType());
                rec.put("difficulty", comp.getDifficulty());
                rec.put("registrationEnd", comp.getRegistrationEnd().toString());
                rec.put("competitionStart", comp.getCompetitionStart().toString());
                rec.put("officialUrl", comp.getOfficialUrl());
                long days = ChronoUnit.DAYS.between(LocalDate.now(), comp.getRegistrationEnd());
                rec.put("daysLeft", days);
                rec.put("recommendDays", comp.getRecommendDays());
            }
        }
    }

    private List<Map<String, Object>> buildFallbackRecommendations(StudentProfile p, List<Competition> comps) {
        List<Map<String, Object>> results = new ArrayList<>();
        String level = p.getProgrammingLevel();
        String grade = p.getGrade();
        boolean isSenior = "大四".equals(grade);
        boolean isJunior = "大三".equals(grade);

        for (Competition c : comps) {
            int score = 50;
            List<String> reasons = new ArrayList<>();

            // 难度匹配
            if ("BEGINNER".equals(c.getDifficulty()) && ("BEGINNER".equals(level) || "BASIC".equals(level))) {
                score += 30; reasons.add("难度适合你当前水平");
            } else if ("INTERMEDIATE".equals(c.getDifficulty())) {
                score += 20; reasons.add("难度适中，有挑战性");
            } else if ("ADVANCED".equals(c.getDifficulty()) && "ADVANCED".equals(level)) {
                score += 25; reasons.add("你的能力可以冲击高级比赛");
            }

            // 年级匹配
            if ("不限".equals(c.getSuitableGrade()) || (c.getSuitableGrade() != null && c.getSuitableGrade().contains(grade))) {
                score += 15; reasons.add("适合你当前年级");
            }

            // 剩余时间
            long daysLeft = ChronoUnit.DAYS.between(LocalDate.now(),
                c.getRegistrationEnd() != null ? c.getRegistrationEnd() : LocalDate.now().plusDays(30));
            if (daysLeft > 30) { score += 15; reasons.add("准备时间充裕（" + daysLeft + "天）"); }
            else if (daysLeft > 7) { score += 8; reasons.add("还有" + daysLeft + "天，抓紧准备"); }
            else if (daysLeft > 0) { score += 3; reasons.add("报名即将截止，尽快决定"); }

            // 适合高年级的比赛对大一大二降低分数
            if (c.getSuitableGrade() != null && c.getSuitableGrade().contains("大二及以上") && "大一".equals(grade)) {
                score -= 20;
            }

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("competitionId", c.getId());
            item.put("name", c.getName());
            item.put("type", c.getType());
            item.put("difficulty", c.getDifficulty());
            item.put("registrationEnd", c.getRegistrationEnd() != null ? c.getRegistrationEnd().toString() : "");
            item.put("competitionStart", c.getCompetitionStart() != null ? c.getCompetitionStart().toString() : "");
            item.put("officialUrl", c.getOfficialUrl());
            item.put("daysLeft", daysLeft);
            item.put("recommendDays", c.getRecommendDays());
            item.put("score", Math.min(100, score));
            item.put("reasons", reasons);
            results.add(item);
        }

        results.sort((a, b) -> ((Integer) b.get("score")).compareTo((Integer) a.get("score")));
        return results.subList(0, Math.min(4, results.size()));
    }
}
