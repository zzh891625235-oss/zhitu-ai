package com.zhitu.service;

import com.zhitu.dto.LoginRequest;
import com.zhitu.dto.LoginResponse;
import com.zhitu.dto.RegisterRequest;
import com.zhitu.entity.User;

public interface UserService {
    User register(RegisterRequest request);
    LoginResponse login(LoginRequest request);
    User getById(Long id);
}
