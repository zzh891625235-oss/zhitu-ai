package com.zhitu.controller;

import com.zhitu.dto.*;
import com.zhitu.entity.User;
import com.zhitu.service.UserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器 - 注册/登录
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public Result<LoginResponse> register(@Valid @RequestBody RegisterRequest request) {
        User user = userService.register(request);
        // 注册成功直接返回token（自动登录）
        LoginResponse resp = userService.login(new LoginRequest() {{
            setPhone(request.getPhone());
            setPassword(request.getPassword());
        }});
        return Result.success("注册成功", resp);
    }

    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse resp = userService.login(request);
        return Result.success("登录成功", resp);
    }
}
