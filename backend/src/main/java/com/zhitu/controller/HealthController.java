package com.zhitu.controller;

import com.zhitu.dto.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public Result<Map<String, String>> health() {
        Map<String, String> info = new LinkedHashMap<>();
        info.put("status", "ok");
        info.put("app", "Zhitu AI");
        info.put("version", "1.0.0");
        return Result.success(info);
    }
}
