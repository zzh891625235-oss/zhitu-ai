package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.CompetitionMajorMatcher;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.Competition;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.CompetitionMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.service.CompetitionRecommendService;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 检索与学生专业对口的竞赛。
 *
 * <p>这是防幻觉的关键一环：返回给模型的每一条赛事，都<b>必须是数据库中真实存在的记录</b>，
 * 带上 id 与官网，模型没有机会（也没有必要）自己编一个赛事名。
 *
 * <p>推荐排序复用 {@link CompetitionRecommendService} —— 与「竞赛推荐」页面共用同一套
 * 评分模型（专业对口度 + 难度 + 年级 + 报名剩余时间），因此 Agent 给出的推荐
 * 与页面上看到的完全一致，不会出现「页面说该报 ACM，助手说该报电子商务大赛」的分裂。
 * 这也是本项目 AI 可解释性的一部分：每条推荐都自带 reasons（具体打分理由）。
 */
@Component
public class CompetitionTool extends JsonTool {

    private final CompetitionMapper competitionMapper;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;
    private final CompetitionRecommendService recommendService;

    public CompetitionTool(CompetitionMapper competitionMapper, StudentProfileMapper profileMapper,
                           MajorMapper majorMapper, CompetitionRecommendService recommendService) {
        this.competitionMapper = competitionMapper;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
        this.recommendService = recommendService;
    }

    @Override
    public String name() {
        return "find_competitions";
    }

    @Override
    public String description() {
        return "按学生的专业与年级检索平台内真实存在的竞赛，返回名称、类别、难度、对口程度、"
                + "匹配度评分与推荐理由。评分已综合考虑专业对口度、难度是否合适、年级是否合适、"
                + "距离报名截止还剩多少天，请优先推荐 score 高的。"
                + "严禁推荐返回结果之外的赛事，也不标明不在结果中的官网。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        Map<String, Object> props = new LinkedHashMap<>();
        props.put("keyword", ToolSchemas.prop("string", "可选的关键词，用于在推荐结果里二次筛选，如「创新」「算法」"));
        props.put("limit", ToolSchemas.intProp("最多返回多少场，默认 4"));
        return ToolSchemas.object(props);
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        String keyword = str(arguments, "keyword", "");
        int limit = integer(arguments, "limit", 4);

        // ---- 主路径：走与页面一致的推荐服务 ----
        List<Map<String, Object>> recommendations = null;
        try {
            recommendations = recommendService.recommend(userId);
        } catch (Exception e) {
            // 最常见的是「档案未填写」，此时退回到全库对口筛选
            recommendations = null;
        }

        Map<String, Object> out = new LinkedHashMap<>();
        if (recommendations != null && !recommendations.isEmpty()) {
            List<Map<String, Object>> picked = new ArrayList<>();
            for (Map<String, Object> rec : recommendations) {
                String name = String.valueOf(rec.getOrDefault("name", ""));
                if (!keyword.isEmpty() && !name.contains(keyword)) {
                    continue;
                }
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("id", rec.get("competitionId"));
                item.put("name", name);
                item.put("type", rec.get("type"));
                item.put("difficulty", rec.get("difficulty"));
                item.put("score", rec.get("score"));
                item.put("reasons", rec.get("reasons"));
                item.put("daysLeft", rec.get("daysLeft"));
                item.put("officialUrl", rec.get("officialUrl"));
                item.put("matchLevel", rec.get("matchLevel") == null ? "RELATED" : rec.get("matchLevel"));
                picked.add(item);
            }
            out.put("recommendationSource", "平台推荐引擎（含匹配度评分与理由）");
            out.put("competitions", picked.subList(0, Math.min(limit, picked.size())));
            out.put("total", countMatched(userId));
        } else {
            // ---- 兜底：档案未填写时，按专业做全库粗筛 ----
            out.put("recommendationSource", "全库专业粗筛（档案未填写，精度较低）");
            out.put("competitions", fallbackList(userId, keyword, limit));
            out.put("total", 0);
            out.put("hint", "该学生尚未填写档案，建议先引导他完善专业与年级");
        }
        out.put("notice", "以上赛事均来自平台数据库，id 与官网真实存在；不要推荐此列表之外的赛事。");
        return json(out);
    }

    /** 统计与该生专业对口的赛事总数，用于告诉模型「可选面有多大」 */
    private int countMatched(Long userId) {
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        String majorName = null;
        if (p != null && p.getMajorId() != null) {
            Major m = majorMapper.selectById(p.getMajorId());
            majorName = m == null ? null : m.getName();
        }
        int n = 0;
        for (Competition c : competitionMapper.selectList(new LambdaQueryWrapper<Competition>())) {
            if (CompetitionMajorMatcher.matchLevel(c.getSuitableMajor(), majorName) != null) {
                n++;
            }
        }
        return n;
    }

    private List<Map<String, Object>> fallbackList(Long userId, String keyword, int limit) {
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        String majorName = null;
        if (p != null && p.getMajorId() != null) {
            Major m = majorMapper.selectById(p.getMajorId());
            majorName = m == null ? null : m.getName();
        }
        List<Map<String, Object>> all = new ArrayList<>();
        for (Competition c : competitionMapper.selectList(new LambdaQueryWrapper<Competition>())) {
            if (c.getName() == null) {
                continue;
            }
            CompetitionMajorMatcher.MatchLevel level =
                    CompetitionMajorMatcher.matchLevel(c.getSuitableMajor(), majorName);
            if (level == null) {
                continue;
            }
            if (!keyword.isEmpty() && !c.getName().contains(keyword)) {
                continue;
            }
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", c.getId());
            item.put("name", c.getName());
            item.put("type", c.getType());
            item.put("difficulty", c.getDifficulty());
            item.put("score", null);
            item.put("reasons", Collections.singletonList("与该专业对口，但未做个性化打分"));
            item.put("officialUrl", c.getOfficialUrl());
            item.put("matchLevel", level.name());
            all.add(item);
        }
        return all.subList(0, Math.min(limit, all.size()));
    }

    @Override
    public String dataDomain() {
        return "platform:competition";
    }
}
