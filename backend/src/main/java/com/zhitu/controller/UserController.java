package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.entity.User;
import com.zhitu.service.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 用户信息控制器
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/profile")
    public Result<User> getProfile(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        User user = userService.getById(userId);
        user.setPassword(null); // 不返回密码
        return Result.success(user);
    }
}
