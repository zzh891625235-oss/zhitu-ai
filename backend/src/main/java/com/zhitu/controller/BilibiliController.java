package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.BilibiliRecommendPolicy;
import com.zhitu.ai.CourseMajorRelevance;
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
 * 专业相关度用 {@link CourseMajorRelevance}，按「精确专业 100 > 近亲专业 80 >
 * 全专业通用 60」三级打分排序，不对口的课程直接跳过。
 *
 * <p>注意：这里刻意不复用竞赛的 {@code CompetitionMajorMatcher}。竞赛按学科大类
 * 匹配是合理的，但那个大类把「心理」「数学」「统计」归到一起，套到课程上会把
 * 机器学习推给心理学专业。相关度规则的唯一事实来源是 CourseMajorRelevance，
 * Agent 的 {@code search_bilibili_courses} 工具也调用同一个类。
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
            @RequestParam(defaultValue = "400") int limit) {

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
     * 个性化推荐：不对口的课程直接跳过；推荐位由 {@link BilibiliRecommendPolicy} 按
     * 「100 分对口优先占满 → 80 分近亲最多 3 门 → 60 分通用最多 2 门」分配，
     * 同分按 sort_order（推荐学习顺序）稳定排序，避免通用课挤掉专业课。
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
            String suitable = r.getSuitableMajor();
            int score = CourseMajorRelevance.score(suitable, majorName);
            if (score == CourseMajorRelevance.NOT_MATCH) continue;
            Map<String, Object> item = toItem(r, CourseMajorRelevance.reason(score, suitable, majorName));
            item.put("score", score);
            item.put("matchType", matchType(score));
            item.put("matchLabel", matchLabel(score));
            // 同为 100 分时，标题命中专业核心词的课程排在拓展课前面
            item.put("fitness", CourseMajorRelevance.fitness(
                    r.getTitle(), r.getKeywords(), suitable, majorName));
            scored.add(item);
        }

        // 先按分数、贴合度、sort_order 排好；策略内部按分数做稳定排序时会保留这个同分顺序
        scored.sort((a, b) -> {
            int byScore = Integer.compare((int) b.get("score"), (int) a.get("score"));
            if (byScore != 0) return byScore;
            int byFitness = Integer.compare((int) b.get("fitness"), (int) a.get("fitness"));
            return byFitness != 0 ? byFitness
                    : Integer.compare((int) a.get("sortOrder"), (int) b.get("sortOrder"));
        });

        BilibiliRecommendPolicy.PickResult<Map<String, Object>> pick = BilibiliRecommendPolicy.pick(
                scored, BilibiliRecommendPolicy.DEFAULT_LIMIT,
                m -> (int) m.get("score"), m -> (String) m.get("category"));

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("majorName", majorName);
        out.put("total", all.size());
        out.put("exactTotal", pick.exactTotal());
        out.put("relatedTotal", pick.relatedTotal());
        out.put("openTotal", pick.openTotal());
        out.put("exactPicked", pick.exactPicked());
        // fitness 只是内部排序键，不暴露给前端
        List<Map<String, Object>> picked = pick.items();
        for (Map<String, Object> item : picked) item.remove("fitness");
        out.put("recommendations", picked);
        return Result.success(out);
    }

    private String matchType(int score) {
        if (score >= CourseMajorRelevance.EXACT) return "exact";
        if (score >= CourseMajorRelevance.RELATED) return "related";
        return "open";
    }

    private String matchLabel(int score) {
        if (score >= CourseMajorRelevance.EXACT) return "专业对口";
        if (score >= CourseMajorRelevance.RELATED) return "相近专业";
        return "通用技能";
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
