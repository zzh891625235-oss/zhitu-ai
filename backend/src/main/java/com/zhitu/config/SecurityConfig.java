package com.zhitu.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.dto.Result;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * Spring Security 配置。
 *
 * 采用无状态 JWT 鉴权，接口分三类：
 *   1. 公开：注册 / 登录 / 健康检查 / 专业 / 课程 / 竞赛
 *   2. 需要登录：其余全部接口
 *   3. 需要管理员：/api/admin/**
 *
 * 401 与 403 也会返回与业务接口一致的结构，
 * 否则前端 axios 拦截器拿不到 message，只能显示「网络错误」。
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final ObjectMapper objectMapper;

    public SecurityConfig(JwtAuthFilter jwtAuthFilter, ObjectMapper objectMapper) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.objectMapper = objectMapper;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .cors()
            .and()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
                .antMatchers("/api/auth/**").permitAll()
                .antMatchers("/api/health").permitAll()
                .antMatchers("/api/majors").permitAll()
                .antMatchers("/api/courses/**").permitAll()
                .antMatchers("/api/competitions/**").permitAll()
                .antMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            .and()
            .exceptionHandling()
                .authenticationEntryPoint((request, response, ex) ->
                        writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, 401, "登录状态已失效，请重新登录"))
                .accessDeniedHandler((request, response, ex) ->
                        writeJson(response, HttpServletResponse.SC_FORBIDDEN, 403, "没有权限访问该功能"))
            .and()
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    private void writeJson(HttpServletResponse response, int httpStatus, int code, String message) throws IOException {
        response.setStatus(httpStatus);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write(objectMapper.writeValueAsString(Result.error(code, message)));
    }
}
