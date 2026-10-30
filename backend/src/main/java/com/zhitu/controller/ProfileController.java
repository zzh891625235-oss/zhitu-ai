package com.zhitu.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.dto.Result;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.service.StudentProfileService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 学生档案控制器 —— 档案读写 + AI 画像生成。
 *
 * 档案返回结构中额外附带 majorName，
 * 前端无需再自行维护「专业 ID → 专业名」的映射表。
 */
@RestController
@RequestMapping("/api")
public class ProfileController {

    private final StudentProfileService profileService;
    private final MajorMapper majorMapper;
    private final ObjectMapper objectMapper;

    public ProfileController(StudentProfileService profileService, MajorMapper majorMapper,
                             ObjectMapper objectMapper) {
        this.profileService = profileService;
        this.majorMapper = majorMapper;
        this.objectMapper = objectMapper;
    }

    /** 保存/更新档案 */
    @PostMapping("/profile")
    public Result<Map<String, Object>> saveProfile(Authentication auth,
                                                   @RequestBody StudentProfile profile) {
        Long userId = (Long) auth.getPrincipal();
        StudentProfile saved = profileService.saveProfile(userId, profile);
        return Result.success("档案保存成功", toProfileMap(saved));
    }

    /**
     * 获取档案。
     *
     * 未初始化档案属于正常状态（新注册用户第一次进首页就会调用），
     * 返回 200 + data=null，避免前端弹出红色错误提示，
     * 由前端展示「开始 AI 档案初始化」的引导。
     */
    @GetMapping("/profile")
    public Result<Map<String, Object>> getProfile(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        StudentProfile profile = profileService.getByUserId(userId);
        if (profile == null) {
            return Result.success("尚未完成档案初始化", null);
        }
        return Result.success(toProfileMap(profile));
    }

    /** AI 生成学生画像 */
    @PostMapping("/ai/generate-portrait")
    public Result<Map<String, Object>> generatePortrait(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> portrait = profileService.generatePortrait(userId);
        return Result.success("AI画像生成成功", portrait);
    }

    /** 获取已生成的 AI 画像（未生成时返回 200 + null，不是错误） */
    @GetMapping("/ai/portrait")
    public Result<Map<String, Object>> getPortrait(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        StudentProfile profile = profileService.getByUserId(userId);
        if (profile == null || profile.getAiPortrait() == null) {
            return Result.success("尚未生成AI画像", null);
        }
        try {
            Map<String, Object> portrait = objectMapper.readValue(profile.getAiPortrait(),
                new TypeReference<Map<String, Object>>() {});
            return Result.success(portrait);
        } catch (Exception e) {
            return Result.error(500, "画像数据解析失败");
        }
    }

    // ================================================================

    /**
     * 把实体转成前端友好的结构：保留全部原字段，附加 majorName。
     *
     * 注意这里使用 Spring 容器里的 ObjectMapper（已注册 JavaTimeModule），
     * 不要用 new ObjectMapper()：后者无法处理 LocalDateTime 字段，
     * 会在转换时抛出 "Java 8 date/time type not supported by default"。
     */
    private Map<String, Object> toProfileMap(StudentProfile profile) {
        Map<String, Object> map = objectMapper.convertValue(profile,
            new TypeReference<Map<String, Object>>() {});
        map.put("majorName", resolveMajorName(profile.getMajorId()));
        return map;
    }

    private String resolveMajorName(Long majorId) {
        if (majorId == null) {
            return null;
        }
        try {
            Major major = majorMapper.selectById(majorId);
            return major == null ? null : major.getName();
        } catch (Exception e) {
            return null;
        }
    }
}
