package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.service.StudyPlanService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class StudyPlanController {

    private final StudyPlanService planService;

    public StudyPlanController(StudyPlanService planService) {
        this.planService = planService;
    }

    /** 生成/刷新学习计划 */
    @PostMapping("/study-plan/generate")
    public Result<List<Map<String, Object>>> generatePlan(Authentication auth,
                                                           @RequestParam(defaultValue = "7") int days) {
        Long userId = (Long) auth.getPrincipal();
        return Result.success("学习计划已生成", planService.generateStudyPlan(userId, days));
    }

    /** 获取当前计划 */
    @GetMapping("/study-plan")
    public Result<List<Map<String, Object>>> getPlan(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return Result.success(planService.getCurrentPlan(userId));
    }

    /** 记录学习 + AI分析 */
    @PostMapping("/study-plan/record")
    public Result<Map<String, Object>> record(Authentication auth,
                                               @RequestBody Map<String, Object> body) {
        Long userId = (Long) auth.getPrincipal();
        String content = (String) body.getOrDefault("content", "");
        int minutes = (int) body.getOrDefault("minutes", 30);
        int courseId = (int) body.getOrDefault("courseId", 1);
        Map<String, Object> analysis = planService.recordAndAnalyze(userId, content, minutes, courseId);
        return Result.success("学习已记录，AI分析完成", analysis);
    }
}
