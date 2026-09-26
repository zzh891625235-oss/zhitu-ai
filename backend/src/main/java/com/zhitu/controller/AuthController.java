package com.zhitu.controller;

import com.zhitu.dto.*;
import com.zhitu.entity.User;
import com.zhitu.service.UserService;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

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
        LoginRequest loginReq = new LoginRequest();
        loginReq.setPhone(request.getPhone());
        loginReq.setPassword(request.getPassword());
        LoginResponse resp = userService.login(loginReq);
        return Result.success("注册成功", resp);
    }

    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse resp = userService.login(request);
        return Result.success("登录成功", resp);
    }
}
