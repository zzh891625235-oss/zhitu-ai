-- ============================================================
-- 智途AI - 大学生成长规划平台 数据库完整初始化脚本
-- 数据库: MySQL 8.x / 编码: utf8mb4
-- ============================================================

CREATE DATABASE IF NOT EXISTS zhitu_ai DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE zhitu_ai;

-- ============================================================
-- 用户表
-- ============================================================
CREATE TABLE IF NOT EXISTS user (
    id BIGINT NOT NULL AUTO_INCREMENT,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) DEFAULT NULL,
    avatar VARCHAR(500) DEFAULT NULL,
    role VARCHAR(20) DEFAULT 'STUDENT',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 专业表
-- ============================================================
CREATE TABLE IF NOT EXISTS major (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 学生档案表
-- ============================================================
CREATE TABLE IF NOT EXISTS student_profile (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    school VARCHAR(100),
    major_id BIGINT,
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
    interests TEXT,
    career_goal VARCHAR(50),
    ai_portrait JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_id (user_id),
    KEY idx_major_id (major_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 课程表
-- ============================================================
CREATE TABLE IF NOT EXISTS course (
    id BIGINT NOT NULL AUTO_INCREMENT,
    major_id BIGINT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20) DEFAULT 'BEGINNER',
    semester VARCHAR(20),
    category VARCHAR(50),
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_major_id (major_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 知识点表
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
    type VARCHAR(50),
    suitable_major VARCHAR(500),
    suitable_grade VARCHAR(200),
    registration_start DATE,
    registration_end DATE,
    competition_start DATE,
    competition_end DATE,
    difficulty VARCHAR(20) DEFAULT 'EASY',
    official_url VARCHAR(500),
    recommend_days INT DEFAULT 30,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI规划表
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_plan (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    content JSON,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_plan (user_id, plan_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 学习记录表
-- ============================================================
CREATE TABLE IF NOT EXISTS learning_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    course_id BIGINT,
    knowledge_point_id BIGINT,
    progress INT DEFAULT 0,
    study_minutes INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'IN_PROGRESS',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_record (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 学习计划表
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
-- 成长档案表
-- ============================================================
CREATE TABLE IF NOT EXISTS growth_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    record_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    record_date DATE,
    evidence_url VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_type (user_id, record_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI对话记录表
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_chat (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    chat_type VARCHAR(50) DEFAULT 'GENERAL',
    question TEXT NOT NULL,
    answer TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_user_chat (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 简历表
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
-- 通知表
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
-- 智途AI 种子数据
-- ============================================================
USE zhitu_ai;

INSERT INTO major (name, description, category, sort_order) VALUES
('计算机科学与技术', '涵盖计算机基础理论、编程、算法、系统设计等', '工学', 1),
('软件工程', '涵盖软件开发方法、软件项目管理、软件测试等', '工学', 2),
('人工智能', '涵盖机器学习、深度学习、自然语言处理、计算机视觉等', '工学', 3),
('大数据', '涵盖数据采集、处理、分析、可视化等', '工学', 4),
('电子信息工程', '涵盖电子技术、信号处理、通信原理等', '工学', 5);

INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order) VALUES
(1, 'C语言程序设计', 'C语言基础语法、指针、结构体、文件操作', 'BEGINNER', '大一上', '编程基础', 1),
(1, 'Python程序设计', 'Python基础语法、函数、面向对象、常用库', 'BEGINNER', '大一下', '编程基础', 2),
(1, '数据结构', '线性表、栈、队列、树、图、查找、排序', 'INTERMEDIATE', '大二上', '核心基础', 3),
(1, '算法设计与分析', '分治、贪心、动态规划、回溯', 'ADVANCED', '大二下', '核心基础', 4),
(1, '数据库原理', '关系模型、SQL、范式、事务、索引优化', 'INTERMEDIATE', '大二上', '核心基础', 5),
(1, 'Java程序设计', 'Java基础、面向对象、集合、IO、多线程', 'INTERMEDIATE', '大二上', '编程语言', 6),
(1, 'Web前端开发', 'HTML/CSS/JavaScript/Vue.js', 'INTERMEDIATE', '大二下', 'Web开发', 7),
(1, 'Spring Boot框架', 'Spring Boot核心、MVC、MyBatis、RESTful API', 'INTERMEDIATE', '大二下', '后端开发', 8),
(1, '操作系统', '进程管理、内存管理、文件系统', 'ADVANCED', '大三上', '核心基础', 9),
(1, '计算机网络', 'TCP/IP、HTTP、DNS、网络安全', 'ADVANCED', '大三上', '核心基础', 10),
(1, '机器学习', '监督学习、无监督学习、神经网络', 'ADVANCED', '大三下', 'AI方向', 11),
(1, '软件工程', '需求分析、设计模式、软件测试', 'INTERMEDIATE', '大三上', '工程实践', 12);

INSERT INTO competition (name, description, type, suitable_major, suitable_grade, registration_start, registration_end, competition_start, competition_end, difficulty, official_url, recommend_days) VALUES
('蓝桥杯全国软件和信息技术专业人才大赛', '工业和信息化部人才交流中心主办的全国性IT学科赛事', '算法编程', '["计算机科学与技术","软件工程","人工智能"]', '不限', '2026-10-01', '2026-12-15', '2027-04-01', '2027-04-30', 'INTERMEDIATE', 'https://www.lanqiao.cn/', 60),
('ACM-ICPC国际大学生程序设计竞赛', '全球最具影响力的大学生程序设计竞赛', '算法编程', '["计算机科学与技术","软件工程","人工智能"]', '不限', '2026-09-01', '2026-10-31', '2027-03-01', '2027-05-31', 'ADVANCED', 'https://icpc.global/', 90),
('中国大学生计算机设计大赛', '教育部高等学校计算机类专业教学指导委员会主办', '综合', '["计算机科学与技术","软件工程","人工智能"]', '不限', '2027-01-01', '2027-03-31', '2027-05-01', '2027-08-31', 'INTERMEDIATE', 'https://www.jsjds.com.cn/', 45),
('全国大学生数学建模竞赛', '全国规模最大的数学建模竞赛', '数学建模', '["计算机科学与技术","软件工程","人工智能"]', '大二及以上', '2026-05-01', '2026-09-01', '2026-09-10', '2026-09-13', 'ADVANCED', 'http://www.mcm.edu.cn/', 60),
('互联网+大学生创新创业大赛', '教育部主办的创新创业大赛', '创新创业', '["计算机科学与技术","软件工程","人工智能"]', '不限', '2027-03-01', '2027-05-31', '2027-06-01', '2027-10-31', 'ADVANCED', 'https://cy.ncss.cn/', 90),
('传智杯全国大学生IT技能大赛', '传智教育主办的IT技能竞赛', '综合', '["计算机科学与技术","软件工程","人工智能"]', '不限', '2026-10-01', '2026-12-01', '2026-12-15', '2027-01-15', 'BEGINNER', 'https://www.itcast.cn/', 30);

