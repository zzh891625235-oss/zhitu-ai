package com.zhitu.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * 启动时的数据库结构自检。
 *
 * 背景：数据库结构落后于代码时（例如新增了 skill_assessment 列，
 * 但用户只重启了后端、没有重新执行 schema.sql），
 * 所有涉及该表的查询都会抛 "Unknown column"，用户看到的是一大段看不懂的 SQL 报错。
 *
 * 这里把问题消灭在启动阶段：检测并补齐缺失的列，并打印清晰日志。
 * 只处理「新增列」这一类向后兼容的变更；更复杂的迁移仍以 database/schema.sql 为准。
 */
@Component
@Order(1)
public class SchemaMigration implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(SchemaMigration.class);

    /**
     * 表名 / 列名 / 列定义，与 database/schema.sql 的幂等迁移段保持一致。
     * 后续再加字段时，两处都补上即可。
     */
    private static final String[][] REQUIRED_COLUMNS = {
        {"student_profile", "skill_assessment", "TEXT"},
        {"user_settings", "api_key", "VARCHAR(255)"},
        {"user_settings", "api_url", "VARCHAR(255)"},
        {"user_settings", "model", "VARCHAR(100)"},
        {"notification", "is_read", "TINYINT(1) DEFAULT 0"},
        {"growth_record", "evidence_url", "VARCHAR(500)"},
        {"competition", "recommend_days", "INT DEFAULT 30"}
    };

    private final DataSource dataSource;

    public SchemaMigration(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void run(ApplicationArguments args) {
        try (Connection conn = dataSource.getConnection()) {
            int added = 0;
            for (String[] column : REQUIRED_COLUMNS) {
                String table = column[0];
                String name = column[1];
                if (!tableExists(conn, table) || columnExists(conn, table, name)) {
                    continue;
                }
                try (Statement statement = conn.createStatement()) {
                    statement.executeUpdate("ALTER TABLE `" + table + "` ADD COLUMN `" + name + "` " + column[2]);
                    log.warn("数据库缺少列 {}.{}，已自动补齐", table, name);
                    added++;
                }
            }
            if (added > 0) {
                log.warn("本次启动共自动补齐 {} 个缺失的列。"
                       + "建议同时更新 database/schema.sql 以便其它环境保持一致。", added);
            } else {
                log.info("数据库结构自检通过");
            }
        } catch (Exception e) {
            // 自检失败不应阻止应用启动：数据库连不上时，
            // 业务查询会给出更具体、更易定位的错误
            log.warn("数据库结构自检未完成：{}", e.getMessage());
        }
    }

    private boolean tableExists(Connection conn, String table) throws Exception {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getTables(conn.getCatalog(), null, table, new String[]{"TABLE"})) {
            return rs.next();
        }
    }

    private boolean columnExists(Connection conn, String table, String column) throws Exception {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getColumns(conn.getCatalog(), null, table, column)) {
            return rs.next();
        }
    }
}
