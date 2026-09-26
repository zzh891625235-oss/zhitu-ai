package com.zhitu;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 智途AI - 大学生成长规划平台 启动类
 */
@SpringBootApplication
@MapperScan("com.zhitu.mapper")
public class ZhituApplication {
    public static void main(String[] args) {
        SpringApplication.run(ZhituApplication.class, args);
    }
}
