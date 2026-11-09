package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.CompetitionMajorMatcher;
import com.zhitu.ai.CompetitionMajorMatcher.MatchLevel;
import com.zhitu.dto.Result;
import com.zhitu.entity.BilibiliResource;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.BilibiliResourceMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * B 站公开课资源推荐。
 *
 * <p>专业学习页的课程地图回答「校内该学什么」，这里回答「校外去哪学」。
 * 推荐逻辑与竞赛推荐同一套匹配规则（CompetitionMajorMatcher）：
 * 精确专业 > 同方向相关 > 全专业通用，三级打分排序，保证推荐理由可解释。
 */
@RestController
@RequestMapping("/api/bilibili")
public class BilibiliController {

    private final BilibiliResourceMapper resourceMapper;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;

    public BilibiliController(BilibiliResourceMapper resourceMapper,
                              StudentProfileMapper profileMapper,
                              MajorMapper majorMapper) {
        this.resourceMapper = resourceMapper;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
    }

    /** 资源总数与分类列表（页面筛选器用） */
    @GetMapping("/categories")
    public Result<Map<String, Object>> categories() {
        List<BilibiliResource> all = resourceMapper.selectList(null);
        Map<String, Long> byCategory = all.stream()
                .collect(Collectors.groupingBy(BilibiliResource::getCategory, TreeMap::new, Collectors.counting()));
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("total", all.size());
        out.put("categories", byCategory);
        return Result.success(out);
    }

    /** 资源列表：可按分类 / 关键词（标题+UP主+keywords 模糊）过滤 */
    @GetMapping("/resources")
    public Result<List<Map<String, Object>>> resources(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "60") int limit) {

        boolean hasCategory = category != null && !category.trim().isEmpty();
        List<BilibiliResource> list = resourceMapper.selectList(
                new LambdaQueryWrapper<BilibiliResource>()
                        .eq(hasCategory, BilibiliResource::getCategory, hasCategory ? category.trim() : null)
                        .orderByAsc(BilibiliResource::getSortOrder).orderByAsc(BilibiliResource::getId));

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.trim().toLowerCase();
            list = list.stream().filter(r ->
                    containsIgnoreCase(r.getTitle(), kw) || containsIgnoreCase(r.getUploader(), kw)
                            || containsIgnoreCase(r.getKeywords(), kw))
                    .collect(Collectors.toList());
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (BilibiliResource r : list.subList(0, Math.min(limit, list.size()))) {
            result.add(toItem(r, null));
        }
        return Result.success(result);
    }

    /**
     * 个性化推荐：按用户专业三级匹配打分。
     * EXACT（专业对口 100 分）> RELATED（同方向 80 分）> OPEN（通用 60 分），
     * 同分按 sort_order（推荐学习顺序）稳定排序，每个分类最多 4 条保证多样性。
     */
    @GetMapping("/recommend")
    public Result<Map<String, Object>> recommend(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();

        StudentProfile profile = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        String majorName = null;
        if (profile != null && profile.getMajorId() != null) {
            Major major = majorMapper.selectById(profile.getMajorId());
            if (major != null) majorName = major.getName();
        }

        List<BilibiliResource> all = resourceMapper.selectList(
                new LambdaQueryWrapper<BilibiliResource>()
                        .orderByAsc(BilibiliResource::getSortOrder).orderByAsc(BilibiliResource::getId));

        List<Map<String, Object>> scored = new ArrayList<>();
        for (BilibiliResource r : all) {
            int score;
            String reason;
            if (majorName == null) {
                // 尚未完善档案：只推荐真正面向所有专业（suitable_major 含 "*"）的课程
                if (!CompetitionMajorMatcher.isOpenToAll(r.getSuitableMajor())) continue;
                score = 60;
                reason = "大学生通用技能，任何专业都建议掌握";
            } else {
                MatchLevel level = CompetitionMajorMatcher.matchLevel(r.getSuitableMajor(), majorName);
                if (level == MatchLevel.EXACT) {
                    score = 100;
                    reason = "与你的专业「" + majorName + "」直接对口";
                } else if (level == MatchLevel.RELATED) {
                    score = 80;
                    reason = "与你所在专业方向相关，学完即加分";
                } else if (level == MatchLevel.OPEN) {
                    score = 60;
                    reason = "大学生通用技能，任何专业都建议掌握";
                } else {
                    // level == null：这门课与当前专业完全不对口（例如 C语言之于口腔医学）。
                    // 以前这里错误地落进「通用技能」分支给 60 分，导致换到任何专业后，
                    // 其他专业的课程都还挂在推荐里，看起来「B站课程没变」。直接跳过。
                    continue;
                }
            }
            Map<String, Object> item = toItem(r, reason);
            item.put("score", score);
            scored.add(item);
        }

        scored.sort((a, b) -> {
            int byScore = Integer.compare((int) b.get("score"), (int) a.get("score"));
            return byScore != 0 ? byScore : Integer.compare((int) a.get("sortOrder"), (int) b.get("sortOrder"));
        });

        // 同分类最多 4 条，避免某个大类刷屏
        Map<String, Integer> categoryCount = new HashMap<>();
        List<Map<String, Object>> picked = new ArrayList<>();
        for (Map<String, Object> item : scored) {
            String cat = (String) item.get("category");
            int used = categoryCount.getOrDefault(cat, 0);
            if (used >= 4) continue;
            categoryCount.put(cat, used + 1);
            picked.add(item);
            if (picked.size() >= 16) break;
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("majorName", majorName);
        out.put("total", all.size());
        out.put("recommendations", picked);
        return Result.success(out);
    }

    private Map<String, Object> toItem(BilibiliResource r, String reason) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", r.getId());
        item.put("title", r.getTitle());
        item.put("uploader", r.getUploader());
        item.put("category", r.getCategory());
        item.put("keywords", r.getKeywords());
        item.put("difficulty", r.getDifficulty());
        item.put("description", r.getDescription());
        item.put("url", r.getUrl());
        item.put("sortOrder", r.getSortOrder() == null ? 0 : r.getSortOrder());
        item.put("matchReason", reason);
        return item;
    }

    private boolean containsIgnoreCase(String text, String keyword) {
        return text != null && text.toLowerCase().contains(keyword);
    }
}
