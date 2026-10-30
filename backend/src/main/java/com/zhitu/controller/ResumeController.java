package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.service.ResumeService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class ResumeController {

    private final ResumeService resumeService;

    public ResumeController(ResumeService resumeService) {
        this.resumeService = resumeService;
    }

    @PostMapping("/ai/generate-resume")
    public Result<Map<String, Object>> generate(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return Result.success("简历生成成功", resumeService.generateResume(userId));
    }

    /** 获取简历（未生成时返回 200 + null，避免前端弹红色错误提示） */
    @GetMapping("/resume")
    public Result<Map<String, Object>> getResume(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> resume = resumeService.getResume(userId);
        if (resume == null) return Result.success("尚未生成简历", null);
        return Result.success(resume);
    }
}
