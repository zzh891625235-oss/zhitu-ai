package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.AIService;
import com.zhitu.ai.MajorDirection;
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
    private final MajorMapper majorMapper;
    private final AIService aiService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public CompetitionRecommendServiceImpl(StudentProfileMapper profileMapper, UserMapper userMapper,
                                            CompetitionMapper competitionMapper, MajorMapper majorMapper,
                                            AIService aiService) {
        this.profileMapper = profileMapper;
        this.userMapper = userMapper;
        this.competitionMapper = competitionMapper;
        this.majorMapper = majorMapper;
        this.aiService = aiService;
    }

    @Override
    public List<Map<String, Object>> recommend(Long userId) {
        StudentProfile profile = profileMapper.selectOne(
            new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        if (profile == null) throw new RuntimeException("请先完善档案");

        User user = userMapper.selectById(userId);
        String majorName = resolveMajorName(profile.getMajorId());
        List<Competition> allComps = competitionMapper.selectList(
            new LambdaQueryWrapper<Competition>().eq(Competition::getStatus, "ACTIVE"));

        try {
            String prompt = buildPrompt();
            String msg = buildUserMessage(profile, user, majorName, allComps);
            String aiResp = aiService.chatForUser(userId, prompt, msg);
            String json = extractJson(aiResp);
            List<Map<String, Object>> recommendations = objectMapper.readValue(json,
                new TypeReference<List<Map<String, Object>>>() {});

            // AI 降级时返回离线模板文本，extractJson 会退化成 "[]"。
            // 另外 enrichRecommendations 会强转 competitionId，
            // 所以这里连元素结构一起校验，避免空推荐或 NPE。
            if (recommendations.isEmpty() || recommendations.get(0).get("competitionId") == null) {
                return buildFallbackRecommendations(profile, majorName, allComps);
            }

            // 补充竞赛详情
            enrichRecommendations(recommendations, allComps);
            return recommendations;
        } catch (Exception e) {
            return buildFallbackRecommendations(profile, majorName, allComps);
        }
    }

    private String buildPrompt() {
        return "你是竞赛推荐专家。根据学生信息和可选竞赛列表，推荐3-4个最合适的竞赛。\n" +
               "重要：优先推荐与学生专业方向对口的竞赛（每个竞赛后面标了「对口专业」与「是否对口」），\n" +
               "明显不对口的竞赛（例如给护理学学生推荐程序设计竞赛）不要出现在结果里。\n" +
               "严格输出JSON数组：\n" +
               "[{\"competitionId\":1,\"score\":95,\"reasons\":[\"理由1\",\"理由2\"]}]\n" +
               "score是匹配度(0-100)，reasons是推荐理由。按score降序排列。";
    }

    private String buildUserMessage(StudentProfile p, User u, String majorName, List<Competition> comps) {
        StringBuilder sb = new StringBuilder();
        sb.append("学生：").append(u.getNickname()).append("，").append(p.getGrade())
          .append("，专业：").append(majorName)
          .append("，成绩").append(p.getGpa()).append("，技能水平").append(p.getProgrammingLevel())
          .append("，兴趣").append(p.getInterests()).append("，目标").append(p.getCareerGoal()).append("\n");
        sb.append("可选竞赛：\n");
        for (Competition c : comps) {
            sb.append(c.getId()).append(".").append(c.getName())
              .append(" [类型:").append(c.getType())
              .append(" 难度:").append(c.getDifficulty())
              .append(" 对口专业:").append(c.getSuitableMajor())
              .append(" 是否对口:").append(matchesMajor(c.getSuitableMajor(), majorName) ? "是" : "否")
              .append(" 报名截止:").append(c.getRegistrationEnd()).append("]\n");
        }
        return sb.toString();
    }

    /** 查询专业名称；专业表不可用时返回空字符串，不影响推荐 */
    private String resolveMajorName(Long majorId) {
        if (majorId == null) return "";
        try {
            Major major = majorMapper.selectById(majorId);
            return major == null ? "" : major.getName();
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * 竞赛的 suitable_major 是一个 JSON 数组（["*"] 表示不限专业）。
     * 先做名称直接匹配，再做「专业方向」匹配——这样数据库里只列了「会计学」
     * 的比赛，财务管理、审计学的学生也能被识别为对口。
     *
     * 包级可见是为了让 CompetitionMajorMatchTest 能直接验证匹配规则。
     */
    boolean matchesMajor(String suitableMajorJson, String majorName) {
        if (suitableMajorJson == null || suitableMajorJson.trim().isEmpty()) return false;
        List<String> list;
        try {
            list = objectMapper.readValue(suitableMajorJson, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            // 脏数据（不是合法 JSON）时退化成包含判断，避免整个推荐失败
            return majorName != null && !majorName.isEmpty() && suitableMajorJson.contains(majorName);
        }
        if (list.contains("*")) return true;
        if (majorName == null || majorName.isEmpty()) return false;
        if (list.contains(majorName)) return true;

        MajorDirection mine = MajorDirection.resolve(majorName);
        if (mine.isGeneral()) return false;
        for (String s : list) {
            MajorDirection other = MajorDirection.resolve(s);
            if (!other.isGeneral() && other == mine) return true;
        }
        return false;
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

    /** suitable_major 里含 "*" 表示不限专业 */
    private boolean isOpenToAll(String suitableMajorJson) {
        if (suitableMajorJson == null || suitableMajorJson.trim().isEmpty()) return false;
        try {
            List<String> list = objectMapper.readValue(suitableMajorJson, new TypeReference<List<String>>() {});
            return list.contains("*");
        } catch (Exception e) {
            return suitableMajorJson.contains("\"*\"");
        }
    }

    /**
     * 离线（未配置 API Key）时的规则化推荐。
     *
     * <p>包级可见是为了让 {@code CompetitionMajorMatchTest} 直接验证过滤与理由文案，
     * 而不是只能通过 HTTP 接口间接观察——这里出过两个真实问题：
     * 面向全校的竞赛被标成「与你的专业方向对口」、已经截止的竞赛仍被推荐。
     */
    List<Map<String, Object>> buildFallbackRecommendations(StudentProfile p, String majorName,
                                                           List<Competition> comps) {
        String level = p.getProgrammingLevel();
        String grade = p.getGrade();

        // 先按专业过滤掉明显不对口的竞赛，否则护理学、会计学的学生会收到
        // 「蓝桥杯」「ACM」这类完全无关的推荐。
        List<Competition> candidates = new ArrayList<>();
        for (Competition c : comps) {
            if (matchesMajor(c.getSuitableMajor(), majorName) || isOpenToAll(c.getSuitableMajor())) {
                candidates.add(c);
            }
        }
        // 一条都对不上（专业未填写或数据缺失）时不做过滤，至少给得出结果
        if (candidates.isEmpty()) candidates = comps;

        // 再排除报名已经结束的竞赛：推荐一个半年前就截止的比赛没有意义
        // （剩下的时间打分分支对负数一律不加分，但它仍会以基础分出现在列表里）。
        List<Competition> open = new ArrayList<>();
        for (Competition c : candidates) {
            if (c.getRegistrationEnd() == null
                    || !c.getRegistrationEnd().isBefore(LocalDate.now())) {
                open.add(c);
            }
        }
        // 全部已截止时（例如刚导入的静态演示数据）保留原候选，不让页面变空
        if (!open.isEmpty()) candidates = open;

        List<Map<String, Object>> results = new ArrayList<>();

        for (Competition c : candidates) {
            int score = 50;
            List<String> reasons = new ArrayList<>();

            // 专业对口度。
            // 注意顺序：必须先判「不限专业」再判「对口」。因为 matchesMajor() 对
            // suitable_major 为 ["*"] 的竞赛也返回 true，若反过来的话，面向全校的
            // 英语竞赛会被标成「与你的专业方向对口」——理由不实，分数也虚高。
            if (isOpenToAll(c.getSuitableMajor())) {
                score += 10; reasons.add("不限专业，都可以参加");
            } else if (matchesMajor(c.getSuitableMajor(), majorName)) {
                score += 35; reasons.add("与你的专业方向对口");
            }

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

