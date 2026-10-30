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

    /**
     * 获取四年规划。
     *
     * 「尚未生成」是正常状态而不是错误：首页/规划页在用户还没点生成时会主动来查，
     * 若这里返回 404，前端拦截器会弹一条红色的「请先初始化档案」，
     * 让已经初始化过档案的用户误以为流程坏了。因此统一返回 200 + data=null，
     * 由前端根据 data 是否为空展示引导按钮。
     */
    @GetMapping("/plan/four-year")
    public Result<Map<String, Object>> getPlan(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> plan = planService.getPlan(userId);
        if (plan == null) {
            return Result.success("尚未生成四年规划", null);
        }
        return Result.success(plan);
    }
}
