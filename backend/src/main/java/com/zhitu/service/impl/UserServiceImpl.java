package com.zhitu.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.dto.LoginRequest;
import com.zhitu.dto.LoginResponse;
import com.zhitu.dto.RegisterRequest;
import com.zhitu.entity.User;
import com.zhitu.exception.BusinessException;
import com.zhitu.mapper.UserMapper;
import com.zhitu.service.UserService;
import com.zhitu.utils.JwtUtils;
import com.zhitu.utils.PasswordUtils;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final JwtUtils jwtUtils;

    public UserServiceImpl(UserMapper userMapper, JwtUtils jwtUtils) {
        this.userMapper = userMapper;
        this.jwtUtils = jwtUtils;
    }

    @Override
    public User register(RegisterRequest request) {
        // 检查手机号是否已注册
        User existing = userMapper.selectByPhone(request.getPhone());
        if (existing != null) {
            throw new BusinessException(400, "该手机号已注册");
        }
        User user = new User();
        user.setPhone(request.getPhone());
        user.setPassword(PasswordUtils.encode(request.getPassword()));
        user.setNickname(request.getNickname() != null ? request.getNickname() : "同学");
        user.setRole("STUDENT");
        userMapper.insert(user);
        return user;
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        User user = userMapper.selectByPhone(request.getPhone());
        if (user == null) {
            throw new BusinessException(401, "手机号或密码错误");
        }
        if (!PasswordUtils.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(401, "手机号或密码错误");
        }
        String token = jwtUtils.generateToken(user.getId(), user.getPhone(), user.getRole());
        return new LoginResponse(token, user.getId(), user.getNickname(), user.getRole());
    }

    @Override
    public User getById(Long id) {
        return userMapper.selectById(id);
    }
}
