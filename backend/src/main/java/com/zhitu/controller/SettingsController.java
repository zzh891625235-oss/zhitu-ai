package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.dto.Result;
import com.zhitu.entity.UserSettings;
import com.zhitu.mapper.UserSettingsMapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api")
public class SettingsController {

    private final UserSettingsMapper settingsMapper;

    public SettingsController(UserSettingsMapper settingsMapper) {
        this.settingsMapper = settingsMapper;
    }

    /** 获取用户设置 */
    @GetMapping("/settings")
    public Result<Map<String, Object>> getSettings(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        UserSettings settings = settingsMapper.selectOne(
            new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));

        Map<String, Object> result = new LinkedHashMap<>();
        if (settings != null) {
            result.put("apiKey", maskKey(settings.getApiKey()));
            result.put("apiUrl", settings.getApiUrl());
            result.put("model", settings.getModel());
            result.put("hasKey", settings.getApiKey() != null && !settings.getApiKey().isEmpty());
        } else {
            result.put("hasKey", false);
        }
        return Result.success(result);
    }

    /** 保存设置 */
    @PutMapping("/settings")
    public Result<?> saveSettings(Authentication auth, @RequestBody Map<String, String> body) {
        Long userId = (Long) auth.getPrincipal();
        UserSettings existing = settingsMapper.selectOne(
            new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));

        UserSettings settings = existing != null ? existing : new UserSettings();
        settings.setUserId(userId);
        if (body.containsKey("apiKey") && body.get("apiKey") != null && !body.get("apiKey").isEmpty()) {
            settings.setApiKey(body.get("apiKey"));
        }
        if (body.containsKey("apiUrl")) settings.setApiUrl(body.get("apiUrl"));
        if (body.containsKey("model")) settings.setModel(body.get("model"));

        if (existing != null) {
            settingsMapper.updateById(settings);
        } else {
            settingsMapper.insert(settings);
        }
        return Result.success("设置已保存");
    }

    /** 测试API连接 */
    @PostMapping("/settings/test")
    public Result<Map<String, String>> testConnection(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        UserSettings settings = settingsMapper.selectOne(
            new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, userId));

        if (settings == null || settings.getApiKey() == null || settings.getApiKey().isEmpty()) {
            return Result.error(400, "请先配置API Key");
        }

        try {
            // 简单测试：调用API的models列表
            String url = (settings.getApiUrl() != null ? settings.getApiUrl() : "https://api.deepseek.com/v1") + "/models";
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) new java.net.URL(url).openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + settings.getApiKey());
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            int code = conn.getResponseCode();

            Map<String, String> result = new LinkedHashMap<>();
            if (code == 200) {
                result.put("status", "ok");
                result.put("message", "API连接成功！AI服务已就绪");
            } else {
                result.put("status", "error");
                result.put("message", "API返回状态码: " + code);
            }
            return Result.success(result);
        } catch (Exception e) {
            Map<String, String> result = new LinkedHashMap<>();
            result.put("status", "error");
            result.put("message", "连接失败: " + e.getMessage());
            return Result.success(result);
        }
    }

    private String maskKey(String key) {
        if (key == null || key.length() <= 8) return key;
        return key.substring(0, 4) + "****" + key.substring(key.length() - 4);
    }
}
