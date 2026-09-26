package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.service.CompetitionRecommendService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class RecommendController {

    private final CompetitionRecommendService recommendService;

    public RecommendController(CompetitionRecommendService recommendService) {
        this.recommendService = recommendService;
    }

    @PostMapping("/ai/recommend-competitions")
    public Result<List<Map<String, Object>>> recommend(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return Result.success("AI推荐完成", recommendService.recommend(userId));
    }
}
