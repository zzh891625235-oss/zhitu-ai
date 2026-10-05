package com.zhitu.utils;

import io.jsonwebtoken.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;

/**
 * JWT 工具类。
 *
 * Token 中携带：用户 ID（subject）、手机号、角色。
 * 角色用于「管理后台」等需要区分权限的接口鉴权。
 */
@Component
public class JwtUtils {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long expiration;

    /** 生成 JWT Token（含角色） */
    public String generateToken(Long userId, String phone, String role) {
        return Jwts.builder()
                .setSubject(String.valueOf(userId))
                .claim("phone", phone)
                .claim("role", role == null ? "STUDENT" : role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(SignatureAlgorithm.HS256, secret)
                .compact();
    }

    /** 不带角色时的重载，按学生处理 */
    public String generateToken(Long userId, String phone) {
        return generateToken(userId, phone, "STUDENT");
    }

    private Claims parse(String token) {
        return Jwts.parser()
                .setSigningKey(secret)
                .parseClaimsJws(token)
                .getBody();
    }

    /** 解析Token获取用户ID */
    public Long getUserIdFromToken(String token) {
        return Long.parseLong(parse(token).getSubject());
    }

    /**
     * 从 Token 中读取角色。
     *
     * 兼容修复前签发的、不含 role 声明的旧 Token：缺失时按 STUDENT 处理，
     * 这样老用户不会因为这次改动而全部失去登录态。
     */
    public String getRoleFromToken(String token) {
        try {
            Object role = parse(token).get("role");
            return role == null ? "STUDENT" : role.toString();
        } catch (Exception e) {
            return "STUDENT";
        }
    }

    /** 验证Token是否有效 */
    public boolean validateToken(String token) {
        try {
            parse(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
