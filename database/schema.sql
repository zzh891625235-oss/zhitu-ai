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
-- 结构建立完成，请继续执行 majors.sql 与 data.sql
-- ============================================================
