package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.service.FourYearPlanService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 四年规划控制器
 */
@RestController
@RequestMapping("/api")
public class PlanController {

    private final FourYearPlanService planService;

    public PlanController(FourYearPlanService planService) {
        this.planService = planService;
    }

    /** AI生成四年规划 */
    @PostMapping("/ai/generate-plan")
    public Result<Map<String, Object>> generatePlan(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> plan = planService.generatePlan(userId);
        return Result.success("四年规划生成成功", plan);
    }

    /** 获取四年规划 */
    @GetMapping("/plan/four-year")
    public Result<Map<String, Object>> getPlan(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> plan = planService.getPlan(userId);
        if (plan == null) {
            return Result.error(404, "尚未生成四年规划，请先初始化档案");
        }
        return Result.success(plan);
    }
}
