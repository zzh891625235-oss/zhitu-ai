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

    @GetMapping("/resume")
    public Result<Map<String, Object>> getResume(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> resume = resumeService.getResume(userId);
        if (resume == null) return Result.error(404, "尚未生成简历");
        return Result.success(resume);
    }
}
