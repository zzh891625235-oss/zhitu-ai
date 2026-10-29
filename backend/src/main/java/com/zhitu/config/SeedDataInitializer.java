package com.zhitu.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.support.EncodedResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;

/**
 * 一体化演示包 · 基础数据初始化（仅 demo profile 生效）
 *
 * schema-h2.sql 由 spring.sql.init 每次启动幂等执行（IF NOT EXISTS）；
 * data-h2.sql（majors.sql + data.sql 合并，含演示账号）仅在 major 表为空
 * （首次启动）时导入一次，避免重启后种子数据与用户真实数据冲突或重复。
 */
@Profile("demo")
@Component
public class SeedDataInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(SeedDataInitializer.class);

    private final DataSource dataSource;
    private final JdbcTemplate jdbcTemplate;

    public SeedDataInitializer(DataSource dataSource, JdbcTemplate jdbcTemplate) {
        this.dataSource = dataSource;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM major", Integer.class);
        if (count != null && count > 0) {
            log.info("[demo] 检测到已有基础数据（major={} 条），跳过种子数据导入", count);
            return;
        }
        log.info("[demo] 首次启动，正在导入基础数据（专业/课程/竞赛/演示账号）...");
        try (Connection conn = dataSource.getConnection()) {
            // 必须显式指定 UTF-8：脚本内含中文，Windows 下 JVM 默认 GBK 会导致乱码
            ScriptUtils.executeSqlScript(conn,
                    new EncodedResource(new ClassPathResource("db/data-h2.sql"), StandardCharsets.UTF_8));
        }
        log.info("[demo] 基础数据导入完成");
    }
}
