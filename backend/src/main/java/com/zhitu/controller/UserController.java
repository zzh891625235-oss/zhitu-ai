package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.entity.User;
import com.zhitu.service.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

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
        if (user == null) {
            return Result.error(401, "用户不存在或登录状态已失效");
        }
        // 绝不把密码哈希返回给前端
        user.setPassword(null);
        return Result.success(user);
    }
}
