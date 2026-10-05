-- ============================================================
-- 智途AI · 大学生成长规划平台
-- 01 / 03 —— 数据库与表结构（DDL）
-- 数据库: MySQL 8.x    编码: utf8mb4
--
-- 执行顺序（三个脚本都要执行，缺一不可）：
--   1. schema.sql   建库建表        ← 本文件
--   2. majors.sql   专业字典数据（12 个学科门类）
--   3. data.sql     课程 / 竞赛 / 知识点 / 演示账号
--
-- 一键执行：
--   Windows :  powershell -ExecutionPolicy Bypass -File scripts/init-db.ps1
--   macOS/Linux: bash scripts/init-db.sh
--   手动    :  mysql -uroot -p < schema.sql  （依次执行三个文件）
--
-- 本文件只负责结构，不含任何业务数据，可安全重复执行。
-- ============================================================

CREATE DATABASE IF NOT EXISTS zhitu_ai DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE zhitu_ai;

-- ============================================================
-- 用户表
-- ============================================================
CREATE TABLE IF NOT EXISTS user (
    id BIGINT NOT NULL AUTO_INCREMENT,
    phone VARCHAR(20) NOT NULL COMMENT '手机号（登录账号）',
    password VARCHAR(255) NOT NULL COMMENT 'BCrypt 加密后的密码',
    nickname VARCHAR(50) DEFAULT NULL,
    avatar VARCHAR(500) DEFAULT NULL,
    role VARCHAR(20) DEFAULT 'STUDENT' COMMENT 'STUDENT / ADMIN',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 用户级 AI 配置表
-- 「API 设置」页面依赖此表：用户可用自己的 Key 调用大模型
-- ============================================================
CREATE TABLE IF NOT EXISTS user_settings (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    api_key VARCHAR(255) DEFAULT NULL COMMENT '用户自备的 API Key',
    api_url VARCHAR(255) DEFAULT NULL COMMENT '兼容 OpenAI 协议的接口地址',
    model VARCHAR(100) DEFAULT NULL COMMENT '模型名，如 deepseek-chat',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 专业字典表（数据见 majors.sql）
-- ============================================================
CREATE TABLE IF NOT EXISTS major (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) COMMENT '学科门类：工学 / 理学 / 医学 ...',
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_major_name (name), KEY idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 学生档案表
-- major_id 关联 major.id（后端统一使用专业表主键，勿再自行拼接 ID）
-- ============================================================
CREATE TABLE IF NOT EXISTS student_profile (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    school VARCHAR(100),
    major_id BIGINT COMMENT '关联 major.id',
    grade VARCHAR(20),
    gpa VARCHAR(10),
    programming_level VARCHAR(20),
    java_level VARCHAR(20),
    python_level VARCHAR(20),
    cpp_level VARCHAR(20),
    ds_level VARCHAR(20),
    db_level VARCHAR(20),
    web_level VARCHAR(20),
    ai_level VARCHAR(20),
    english_level VARCHAR(20),
    interests TEXT COMMENT 'JSON 数组字符串',
    career_goal VARCHAR(50),
    skill_assessment TEXT COMMENT '非计算机专业的能力自评 JSON：{template,items:[{label,value}]}',
    ai_portrait JSON COMMENT 'AI 生成的学生画像',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_id (user_id),
    KEY idx_major_id (major_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 课程表（专业学习地图）
-- ============================================================
CREATE TABLE IF NOT EXISTS course (
    id BIGINT NOT NULL AUTO_INCREMENT,
    major_id BIGINT COMMENT '关联 major.id',
    name VARCHAR(200) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20) DEFAULT 'BEGINNER' COMMENT 'BEGINNER / INTERMEDIATE / ADVANCED',
    semester VARCHAR(20),
    category VARCHAR(50),
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_major_name (major_id, name),
    KEY idx_major_id (major_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 知识点表（课程下的学习节点）
-- ============================================================
CREATE TABLE IF NOT EXISTS knowledge_point (
    id BIGINT NOT NULL AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    parent_id BIGINT,
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_course_id (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 竞赛表
-- ============================================================
CREATE TABLE IF NOT EXISTS competition (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    type VARCHAR(50) COMMENT '算法编程 / 数学建模 / 创新创业 ...',
    suitable_major VARCHAR(500) COMMENT 'JSON 数组：适配专业',
    suitable_grade VARCHAR(200),
    registration_start DATE,
    registration_end DATE,
    competition_start DATE,
    competition_end DATE,
    difficulty VARCHAR(20) DEFAULT 'EASY',
    official_url VARCHAR(500),
    recommend_days INT DEFAULT 30 COMMENT '建议提前备赛天数',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_competition_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI 规划表（四年规划 / 动态学习计划 / 竞赛推荐结果）
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_plan (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    plan_type VARCHAR(50) NOT NULL COMMENT 'FOUR_YEAR / STUDY / COMPETITION',
    content JSON,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_plan (user_id, plan_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 学习记录表（课程进度）
-- ============================================================
CREATE TABLE IF NOT EXISTS learning_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    course_id BIGINT,
    knowledge_point_id BIGINT,
    progress INT DEFAULT 0,
    study_minutes INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'IN_PROGRESS' COMMENT 'IN_PROGRESS / COMPLETED',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_course (user_id, course_id),
    KEY idx_user_record (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 每日学习计划表（打卡 + AI 动态调整）
-- ============================================================
CREATE TABLE IF NOT EXISTS study_plan (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    course_id BIGINT,
    plan_date DATE NOT NULL,
    content VARCHAR(500) NOT NULL,
    is_completed TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_date (user_id, plan_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 成长档案表（项目 / 竞赛 / 证书 / 实习 / 荣誉）
-- ============================================================
CREATE TABLE IF NOT EXISTS growth_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    record_type VARCHAR(50) NOT NULL COMMENT 'PROJECT / COMPETITION / CERTIFICATE / INTERNSHIP / HONOR',
    title VARCHAR(200) NOT NULL,
    description TEXT,
    record_date DATE,
    evidence_url VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_type (user_id, record_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI 对话记录表
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_chat (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    chat_type VARCHAR(50) DEFAULT 'GENERAL' COMMENT 'GENERAL / LEARNING / CAREER / COMPETITION / INTERVIEW',
    question TEXT NOT NULL,
    answer TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_chat (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI 简历表
-- ============================================================
CREATE TABLE IF NOT EXISTS resume (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    content JSON,
    template VARCHAR(50) DEFAULT 'DEFAULT',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 通知表（竞赛报名截止、计划提醒等站内信）
-- ============================================================
CREATE TABLE IF NOT EXISTS notification (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    is_read TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 结构补齐（幂等迁移）
--
-- 为什么需要这一段：
--   CREATE TABLE IF NOT EXISTS 只保证「表存在」，并不会修改已存在表的结构。
--   如果数据库是用更早的脚本或手工创建的，就会缺少后续新增的列，
--   接着执行 data.sql 时会报：Unknown column 'xxx' in 'field list'。
--
-- 做法：
--   逐列查询 information_schema，只对「确实缺失」的列执行 ALTER TABLE，
--   因此可以安全地重复执行，也不会覆盖已有数据。
--
-- 说明：
--   补上的列一律允许 NULL 且不带 NOT NULL / DEFAULT 约束。
--   这样即使表里已有数据也不会因为约束冲突而失败——
--   这里的首要目标是让结构可用，而不是严格复刻建表语句。
-- ============================================================

DROP PROCEDURE IF EXISTS zhitu_sync_column;

DELIMITER $$
CREATE PROCEDURE zhitu_sync_column(IN tbl VARCHAR(64), IN col VARCHAR(64), IN col_def VARCHAR(255))
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = col
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `', col, '` ', col_def);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

-- user
CALL zhitu_sync_column('user', 'phone', 'VARCHAR(20)');
CALL zhitu_sync_column('user', 'password', 'VARCHAR(255)');
CALL zhitu_sync_column('user', 'nickname', 'VARCHAR(50)');
CALL zhitu_sync_column('user', 'avatar', 'VARCHAR(500)');
CALL zhitu_sync_column('user', 'role', 'VARCHAR(20)');
CALL zhitu_sync_column('user', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('user', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- user_settings
CALL zhitu_sync_column('user_settings', 'user_id', 'BIGINT');
CALL zhitu_sync_column('user_settings', 'api_key', 'VARCHAR(255)');
CALL zhitu_sync_column('user_settings', 'api_url', 'VARCHAR(255)');
CALL zhitu_sync_column('user_settings', 'model', 'VARCHAR(100)');
CALL zhitu_sync_column('user_settings', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('user_settings', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- major
CALL zhitu_sync_column('major', 'name', 'VARCHAR(100)');
CALL zhitu_sync_column('major', 'description', 'TEXT');
CALL zhitu_sync_column('major', 'category', 'VARCHAR(50)');
CALL zhitu_sync_column('major', 'sort_order', 'INT DEFAULT 0');
CALL zhitu_sync_column('major', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('major', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- student_profile
CALL zhitu_sync_column('student_profile', 'user_id', 'BIGINT');
CALL zhitu_sync_column('student_profile', 'school', 'VARCHAR(100)');
CALL zhitu_sync_column('student_profile', 'major_id', 'BIGINT');
CALL zhitu_sync_column('student_profile', 'grade', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'gpa', 'VARCHAR(10)');
CALL zhitu_sync_column('student_profile', 'programming_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'java_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'python_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'cpp_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'ds_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'db_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'web_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'ai_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'english_level', 'VARCHAR(20)');
CALL zhitu_sync_column('student_profile', 'interests', 'TEXT');
CALL zhitu_sync_column('student_profile', 'career_goal', 'VARCHAR(50)');
CALL zhitu_sync_column('student_profile', 'skill_assessment', 'TEXT');
CALL zhitu_sync_column('student_profile', 'ai_portrait', 'JSON');
CALL zhitu_sync_column('student_profile', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('student_profile', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- course
CALL zhitu_sync_column('course', 'major_id', 'BIGINT');
CALL zhitu_sync_column('course', 'name', 'VARCHAR(200)');
CALL zhitu_sync_column('course', 'description', 'TEXT');
CALL zhitu_sync_column('course', 'difficulty', 'VARCHAR(20)');
CALL zhitu_sync_column('course', 'semester', 'VARCHAR(20)');
CALL zhitu_sync_column('course', 'category', 'VARCHAR(50)');
CALL zhitu_sync_column('course', 'sort_order', 'INT DEFAULT 0');
CALL zhitu_sync_column('course', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('course', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- knowledge_point（本次报错就出在这里缺 parent_id）
CALL zhitu_sync_column('knowledge_point', 'course_id', 'BIGINT');
CALL zhitu_sync_column('knowledge_point', 'name', 'VARCHAR(200)');
CALL zhitu_sync_column('knowledge_point', 'description', 'TEXT');
CALL zhitu_sync_column('knowledge_point', 'parent_id', 'BIGINT');
CALL zhitu_sync_column('knowledge_point', 'sort_order', 'INT DEFAULT 0');
CALL zhitu_sync_column('knowledge_point', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('knowledge_point', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- competition
CALL zhitu_sync_column('competition', 'name', 'VARCHAR(200)');
CALL zhitu_sync_column('competition', 'description', 'TEXT');
CALL zhitu_sync_column('competition', 'type', 'VARCHAR(50)');
CALL zhitu_sync_column('competition', 'suitable_major', 'VARCHAR(500)');
CALL zhitu_sync_column('competition', 'suitable_grade', 'VARCHAR(200)');
CALL zhitu_sync_column('competition', 'registration_start', 'DATE');
CALL zhitu_sync_column('competition', 'registration_end', 'DATE');
CALL zhitu_sync_column('competition', 'competition_start', 'DATE');
CALL zhitu_sync_column('competition', 'competition_end', 'DATE');
CALL zhitu_sync_column('competition', 'difficulty', 'VARCHAR(20)');
CALL zhitu_sync_column('competition', 'official_url', 'VARCHAR(500)');
CALL zhitu_sync_column('competition', 'recommend_days', 'INT DEFAULT 30');
CALL zhitu_sync_column('competition', 'status', 'VARCHAR(20)');
CALL zhitu_sync_column('competition', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('competition', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- ai_plan
CALL zhitu_sync_column('ai_plan', 'user_id', 'BIGINT');
CALL zhitu_sync_column('ai_plan', 'plan_type', 'VARCHAR(50)');
CALL zhitu_sync_column('ai_plan', 'content', 'JSON');
CALL zhitu_sync_column('ai_plan', 'start_date', 'DATE');
CALL zhitu_sync_column('ai_plan', 'end_date', 'DATE');
CALL zhitu_sync_column('ai_plan', 'status', 'VARCHAR(20)');
CALL zhitu_sync_column('ai_plan', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('ai_plan', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- learning_record
CALL zhitu_sync_column('learning_record', 'user_id', 'BIGINT');
CALL zhitu_sync_column('learning_record', 'course_id', 'BIGINT');
CALL zhitu_sync_column('learning_record', 'knowledge_point_id', 'BIGINT');
CALL zhitu_sync_column('learning_record', 'progress', 'INT DEFAULT 0');
CALL zhitu_sync_column('learning_record', 'study_minutes', 'INT DEFAULT 0');
CALL zhitu_sync_column('learning_record', 'status', 'VARCHAR(20)');
CALL zhitu_sync_column('learning_record', 'notes', 'TEXT');
CALL zhitu_sync_column('learning_record', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- study_plan
CALL zhitu_sync_column('study_plan', 'user_id', 'BIGINT');
CALL zhitu_sync_column('study_plan', 'course_id', 'BIGINT');
CALL zhitu_sync_column('study_plan', 'plan_date', 'DATE');
CALL zhitu_sync_column('study_plan', 'content', 'VARCHAR(500)');
CALL zhitu_sync_column('study_plan', 'is_completed', 'TINYINT(1) DEFAULT 0');
CALL zhitu_sync_column('study_plan', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('study_plan', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- growth_record
CALL zhitu_sync_column('growth_record', 'user_id', 'BIGINT');
CALL zhitu_sync_column('growth_record', 'record_type', 'VARCHAR(50)');
CALL zhitu_sync_column('growth_record', 'title', 'VARCHAR(200)');
CALL zhitu_sync_column('growth_record', 'description', 'TEXT');
CALL zhitu_sync_column('growth_record', 'record_date', 'DATE');
CALL zhitu_sync_column('growth_record', 'evidence_url', 'VARCHAR(500)');
CALL zhitu_sync_column('growth_record', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- ai_chat
CALL zhitu_sync_column('ai_chat', 'user_id', 'BIGINT');
CALL zhitu_sync_column('ai_chat', 'chat_type', 'VARCHAR(50)');
CALL zhitu_sync_column('ai_chat', 'question', 'TEXT');
CALL zhitu_sync_column('ai_chat', 'answer', 'TEXT');
CALL zhitu_sync_column('ai_chat', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- resume
CALL zhitu_sync_column('resume', 'user_id', 'BIGINT');
CALL zhitu_sync_column('resume', 'content', 'JSON');
CALL zhitu_sync_column('resume', 'template', 'VARCHAR(50)');
CALL zhitu_sync_column('resume', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');
CALL zhitu_sync_column('resume', 'updated_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

-- notification
CALL zhitu_sync_column('notification', 'user_id', 'BIGINT');
CALL zhitu_sync_column('notification', 'title', 'VARCHAR(200)');
CALL zhitu_sync_column('notification', 'content', 'TEXT');
CALL zhitu_sync_column('notification', 'is_read', 'TINYINT(1) DEFAULT 0');
CALL zhitu_sync_column('notification', 'created_at', 'DATETIME DEFAULT CURRENT_TIMESTAMP');

DROP PROCEDURE IF EXISTS zhitu_sync_column;

-- ============================================================
-- 唯一索引补齐
--
-- 只补列还不够：data.sql 里大量使用 ON DUPLICATE KEY UPDATE，
-- 它依赖唯一键才能做到「重复执行不产生重复数据」。
-- 旧结构的表通常也没有这些唯一键，于是每次执行都会重复插入
-- （实测：课程表会从 53 条涨到 106 条）。
--
-- 注意：建立唯一索引前必须先清掉已有的重复行，否则 ALTER 会直接失败。
-- 下面统一按「保留 id 最小的一条」处理。
-- ============================================================

-- 去重（没有重复时影响 0 行，可安全重复执行）
DELETE a FROM `user` a INNER JOIN `user` b
    ON a.id > b.id AND a.phone = b.phone;
DELETE a FROM `user_settings` a INNER JOIN `user_settings` b
    ON a.id > b.id AND a.user_id = b.user_id;
DELETE a FROM `student_profile` a INNER JOIN `student_profile` b
    ON a.id > b.id AND a.user_id = b.user_id;
DELETE a FROM `resume` a INNER JOIN `resume` b
    ON a.id > b.id AND a.user_id = b.user_id;
DELETE a FROM `major` a INNER JOIN `major` b
    ON a.id > b.id AND a.name = b.name;
DELETE a FROM `course` a INNER JOIN `course` b
    ON a.id > b.id AND a.name = b.name
    AND (a.major_id = b.major_id OR (a.major_id IS NULL AND b.major_id IS NULL));
DELETE a FROM `competition` a INNER JOIN `competition` b
    ON a.id > b.id AND a.name = b.name;
DELETE a FROM `learning_record` a INNER JOIN `learning_record` b
    ON a.id > b.id AND a.user_id = b.user_id
    AND (a.course_id = b.course_id OR (a.course_id IS NULL AND b.course_id IS NULL));

DROP PROCEDURE IF EXISTS zhitu_sync_unique;

DELIMITER $$
CREATE PROCEDURE zhitu_sync_unique(IN tbl VARCHAR(64), IN idx VARCHAR(64), IN idx_cols VARCHAR(255))
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND INDEX_NAME = idx
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', tbl, '` ADD UNIQUE KEY `', idx, '` (', idx_cols, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL zhitu_sync_unique('user', 'uk_phone', '`phone`');
CALL zhitu_sync_unique('user_settings', 'uk_user_id', '`user_id`');
CALL zhitu_sync_unique('student_profile', 'uk_user_id', '`user_id`');
CALL zhitu_sync_unique('resume', 'uk_user_id', '`user_id`');
CALL zhitu_sync_unique('major', 'uk_major_name', '`name`');
CALL zhitu_sync_unique('course', 'uk_course_major_name', '`major_id`,`name`');
CALL zhitu_sync_unique('competition', 'uk_competition_name', '`name`');
CALL zhitu_sync_unique('learning_record', 'uk_user_course', '`user_id`,`course_id`');

DROP PROCEDURE IF EXISTS zhitu_sync_unique;

-- ============================================================
-- 结构建立完成，请继续执行 majors.sql 与 data.sql
-- ============================================================
