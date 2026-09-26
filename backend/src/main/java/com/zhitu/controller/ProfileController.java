package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.entity.StudentProfile;
import com.zhitu.service.StudentProfileService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 学生档案控制器 - 档案CRUD + AI画像生成
 */
@RestController
@RequestMapping("/api")
public class ProfileController {

    private final StudentProfileService profileService;

    public ProfileController(StudentProfileService profileService) {
        this.profileService = profileService;
    }

    /** 保存/更新档案 */
    @PostMapping("/profile")
    public Result<StudentProfile> saveProfile(Authentication auth,
                                               @RequestBody StudentProfile profile) {
        Long userId = (Long) auth.getPrincipal();
        StudentProfile saved = profileService.saveProfile(userId, profile);
        return Result.success("档案保存成功", saved);
    }

    /** 获取档案 */
    @GetMapping("/profile")
    public Result<StudentProfile> getProfile(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        StudentProfile profile = profileService.getByUserId(userId);
        if (profile == null) {
            return Result.error(404, "请先完成档案初始化");
        }
        return Result.success(profile);
    }

    /** AI生成学生画像 */
    @PostMapping("/ai/generate-portrait")
    public Result<Map<String, Object>> generatePortrait(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> portrait = profileService.generatePortrait(userId);
        return Result.success("AI画像生成成功", portrait);
    }

    /** 获取AI画像 */
    @GetMapping("/ai/portrait")
    public Result<Map<String, Object>> getPortrait(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        StudentProfile profile = profileService.getByUserId(userId);
        if (profile == null || profile.getAiPortrait() == null) {
            return Result.error(404, "AI画像尚未生成，请先完成档案初始化");
        }
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            Map<String, Object> portrait = mapper.readValue(profile.getAiPortrait(),
                new com.fasterxml.jackson.core.type.TypeReference<Map<String, Object>>() {});
            return Result.success(portrait);
        } catch (Exception e) {
            return Result.error(500, "画像数据解析失败");
        }
    }
}
