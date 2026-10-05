-- ============================================================
-- 智途AI · 大学生成长规划平台
-- 03 / 03 —— 业务种子数据（DML）
--
-- 内容：
--   1. 课程（计算机 / 软件工程 / 人工智能 / 大数据 / 电子信息 五大方向）
--   2. 竞赛（含动态报名时间，演示时永远有倒计时）
--   3. 课程知识点（knowledge_point）
--   4. 演示账号：13800000000 / 123456（含完整档案、画像、规划、档案、简历）
--
-- 说明：
--   * 竞赛日期使用相对当前日期的表达式，保证任何时间演示都有"报名倒计时"。
--     正式部署时请替换为赛事官方公布的固定日期。
--   * 演示账号相关的数据每次执行会先清空再写入，不影响其它账号。
--   * 可安全重复执行。
-- ============================================================

USE zhitu_ai;

-- ============================================================
-- 1. 课程
-- ============================================================
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order) VALUES
-- 1 · 计算机科学与技术
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
(1, '软件工程', '需求分析、设计模式、软件测试', 'INTERMEDIATE', '大三上', '工程实践', 12),
-- 2 · 软件工程
(2, '程序设计基础', '以C语言为载体建立程序设计思维', 'BEGINNER', '大一上', '编程基础', 1),
(2, '面向对象程序设计', 'Java语法、类与对象、继承多态、异常处理', 'BEGINNER', '大一下', '编程基础', 2),
(2, '数据结构与算法', '常用数据结构与算法复杂度分析', 'INTERMEDIATE', '大二上', '核心基础', 3),
(2, '数据库系统原理', 'SQL、事务、索引、数据库设计', 'INTERMEDIATE', '大二上', '核心基础', 4),
(2, '软件工程导论', '软件生命周期、过程模型、团队协作', 'INTERMEDIATE', '大二下', '专业核心', 5),
(2, '软件需求工程', '需求获取、建模、规格说明与变更管理', 'INTERMEDIATE', '大二下', '专业核心', 6),
(2, '软件设计与体系结构', '设计模式、架构风格、模块化设计', 'INTERMEDIATE', '大三上', '专业核心', 7),
(2, '软件测试技术', '单元测试、集成测试、自动化测试', 'INTERMEDIATE', '大三上', '专业核心', 8),
(2, '软件项目管理', '进度估算、敏捷开发、风险管理', 'INTERMEDIATE', '大三下', '专业核心', 9),
(2, '微服务架构与DevOps', '微服务拆分、容器化、CI/CD流水线', 'ADVANCED', '大四上', '工程实践', 10),
-- 3 · 人工智能
(3, 'Python程序设计', 'Python基础与科学计算库', 'BEGINNER', '大一上', '编程基础', 1),
(3, '高等数学', '极限、微积分、级数', 'BEGINNER', '大一上', '数学基础', 2),
(3, '线性代数', '矩阵、向量空间、特征值分解', 'INTERMEDIATE', '大一下', '数学基础', 3),
(3, '概率论与数理统计', '随机变量、分布、假设检验', 'INTERMEDIATE', '大二上', '数学基础', 4),
(3, '数据结构与算法', '常用数据结构与算法设计', 'INTERMEDIATE', '大二上', '核心基础', 5),
(3, '机器学习', '回归、分类、聚类、模型评估', 'INTERMEDIATE', '大二下', 'AI核心', 6),
(3, '深度学习', '神经网络、CNN、RNN、Transformer', 'ADVANCED', '大三上', 'AI核心', 7),
(3, '计算机视觉', '图像处理、目标检测、图像分割', 'ADVANCED', '大三上', 'AI方向', 8),
(3, '自然语言处理', '词向量、序列建模、预训练语言模型', 'ADVANCED', '大三下', 'AI方向', 9),
(3, '强化学习', '马尔可夫决策过程、Q-Learning、策略梯度', 'ADVANCED', '大三下', 'AI方向', 10),
(3, '大模型与提示工程', '大模型原理、微调、RAG与Agent应用', 'ADVANCED', '大四上', '前沿技术', 11),
-- 4 · 大数据科学与技术
(4, 'Python程序设计', 'Python基础与数据处理', 'BEGINNER', '大一上', '编程基础', 1),
(4, 'Java程序设计', 'Java基础语法与面向对象', 'BEGINNER', '大一下', '编程基础', 2),
(4, '数据结构', '线性结构、树、图与排序查找', 'INTERMEDIATE', '大二上', '核心基础', 3),
(4, '数据库原理与应用', '关系数据库、SQL调优、NoSQL入门', 'INTERMEDIATE', '大二上', '核心基础', 4),
(4, 'Linux与Shell编程', 'Linux命令、Shell脚本、服务器运维', 'BEGINNER', '大二上', '工程基础', 5),
(4, 'Hadoop分布式计算', 'HDFS、MapReduce、YARN', 'INTERMEDIATE', '大二下', '大数据核心', 6),
(4, 'Spark大数据处理', 'RDD、DataFrame、Spark SQL与调优', 'INTERMEDIATE', '大三上', '大数据核心', 7),
(4, '数据采集与预处理', '爬虫、数据清洗、特征工程', 'INTERMEDIATE', '大三上', '数据处理', 8),
(4, '数据仓库与OLAP', '维度建模、数仓分层、OLAP引擎', 'INTERMEDIATE', '大三下', '数据处理', 9),
(4, '数据可视化', 'ECharts、Tableau、可视化叙事', 'ADVANCED', '大三下', '应用方向', 10),
-- 5 · 电子信息工程
(5, '电路分析基础', '基尔霍夫定律、网络定理、动态电路', 'BEGINNER', '大一上', '专业基础', 1),
(5, 'C语言程序设计', 'C语言基础与嵌入式编程入门', 'BEGINNER', '大一上', '编程基础', 2),
(5, '模拟电子技术', '二极管、三极管、运放与放大电路', 'INTERMEDIATE', '大一下', '专业基础', 3),
(5, '数字电子技术', '逻辑门、组合逻辑、时序逻辑', 'INTERMEDIATE', '大二上', '专业基础', 4),
(5, '信号与系统', '连续与离散信号、傅里叶变换、系统响应', 'ADVANCED', '大二上', '专业基础', 5),
(5, '单片机原理与应用', '51/STM32架构、外设驱动、中断', 'INTERMEDIATE', '大二下', '嵌入式', 6),
(5, '数字信号处理', '采样定理、数字滤波器、FFT', 'ADVANCED', '大三上', '专业核心', 7),
(5, '通信原理', '调制解调、信道编码、通信系统', 'ADVANCED', '大三上', '专业核心', 8),
(5, '嵌入式系统设计', 'RTOS、驱动开发、系统集成', 'INTERMEDIATE', '大三下', '嵌入式', 9),
(5, 'FPGA设计与Verilog', 'Verilog HDL、时序约束、FPGA开发流程', 'INTERMEDIATE', '大三下', '硬件设计', 10)
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- ============================================================
-- 2. 竞赛
-- 日期使用 CURDATE() 相对表达式，保证演示时始终有"报名中"的赛事
-- ============================================================
INSERT INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) VALUES
('蓝桥杯全国软件和信息技术专业人才大赛',
 '工业和信息化部人才交流中心主办的全国性IT学科赛事，个人赛，适合作为第一个正式比赛',
 '算法编程', '["计算机科学与技术","软件工程","人工智能","大数据科学与技术"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY),
 DATE_ADD(CURDATE(), INTERVAL 80 DAY), DATE_ADD(CURDATE(), INTERVAL 82 DAY),
 'INTERMEDIATE', 'https://www.lanqiao.cn/', 60),
('中国高校计算机大赛-团体程序设计天梯赛',
 '以团队为单位的程序设计能力竞赛，强调协作与基础功底',
 '算法编程', '["计算机科学与技术","软件工程","人工智能"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY),
 DATE_ADD(CURDATE(), INTERVAL 55 DAY), DATE_ADD(CURDATE(), INTERVAL 55 DAY),
 'INTERMEDIATE', 'https://gplt.patest.cn/', 45),
('ACM-ICPC 国际大学生程序设计竞赛',
 '全球最具影响力的大学生程序设计竞赛，三人一队，难度高、含金量高',
 '算法编程', '["计算机科学与技术","软件工程","人工智能"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 50 DAY),
 DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 140 DAY),
 'ADVANCED', 'https://icpc.global/', 120),
('中国大学生计算机设计大赛',
 '教育部高等学校计算机类专业教学指导委员会主办的综合性赛事，适合有作品的同学',
 '综合', '["计算机科学与技术","软件工程","数字媒体技术","人工智能"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 60 DAY),
 DATE_ADD(CURDATE(), INTERVAL 100 DAY), DATE_ADD(CURDATE(), INTERVAL 150 DAY),
 'INTERMEDIATE', 'https://www.jsjds.com.cn/', 60),
('全国大学生数学建模竞赛',
 '全国规模最大的数学建模竞赛，三天三夜完成建模与论文，保研加分项',
 '数学建模', '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","数学与应用数学"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 70 DAY),
 DATE_ADD(CURDATE(), INTERVAL 95 DAY), DATE_ADD(CURDATE(), INTERVAL 98 DAY),
 'ADVANCED', 'http://www.mcm.edu.cn/', 75),
('中国国际大学生创新大赛（互联网+）',
 '教育部主办的创新创业大赛，适合有完整项目与商业计划的团队',
 '创新创业', '["计算机科学与技术","软件工程","人工智能","工商管理"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 90 DAY),
 DATE_ADD(CURDATE(), INTERVAL 120 DAY), DATE_ADD(CURDATE(), INTERVAL 200 DAY),
 'ADVANCED', 'https://cy.ncss.cn/', 90),
('传智杯全国大学生IT技能大赛',
 '传智教育主办的IT技能竞赛，覆盖编程、Web、AI等方向，入门友好',
 '综合', '["计算机科学与技术","软件工程","人工智能","大数据科学与技术"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY),
 DATE_ADD(CURDATE(), INTERVAL 45 DAY), DATE_ADD(CURDATE(), INTERVAL 70 DAY),
 'BEGINNER', 'https://www.itcast.cn/', 30),
('全国大学生电子设计竞赛',
 '电子信息类专业最具含金量的学科竞赛，四人一队，软硬件结合',
 '电子设计', '["电子信息工程","通信工程","自动化","物联网工程"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 25 DAY), DATE_ADD(CURDATE(), INTERVAL 85 DAY),
 DATE_ADD(CURDATE(), INTERVAL 120 DAY), DATE_ADD(CURDATE(), INTERVAL 125 DAY),
 'ADVANCED', 'https://nuedc.xjtu.edu.cn/', 90),
('华为ICT大赛',
 '华为主办的ICT技术竞赛，含网络、云、计算赛道，对进大厂有实际帮助',
 '综合', '["计算机科学与技术","软件工程","通信工程","电子信息工程"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY),
 DATE_ADD(CURDATE(), INTERVAL 65 DAY), DATE_ADD(CURDATE(), INTERVAL 90 DAY),
 'INTERMEDIATE', 'https://e.huawei.com/cn/talent/ict-competition', 45),
('全国大学生英语竞赛（NECCS）',
 '覆盖面最广的英语学科竞赛，对四六级和保研都有帮助',
 '英语', '["*"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY),
 DATE_ADD(CURDATE(), INTERVAL 50 DAY), DATE_ADD(CURDATE(), INTERVAL 50 DAY),
 'BEGINNER', 'https://www.chinaneccs.cn/', 30)
ON DUPLICATE KEY UPDATE
    description = VALUES(description), type = VALUES(type),
    suitable_major = VALUES(suitable_major), suitable_grade = VALUES(suitable_grade),
    registration_start = VALUES(registration_start), registration_end = VALUES(registration_end),
    competition_start = VALUES(competition_start), competition_end = VALUES(competition_end),
    difficulty = VALUES(difficulty), official_url = VALUES(official_url),
    recommend_days = VALUES(recommend_days);

-- ============================================================
-- 3. 课程知识点（示例：数据结构）
-- ============================================================
SET @ds_course = (SELECT id FROM course WHERE major_id = 1 AND name = '数据结构' LIMIT 1);
DELETE FROM knowledge_point WHERE course_id = @ds_course;
INSERT INTO knowledge_point (course_id, name, description, parent_id, sort_order) VALUES
(@ds_course, '线性表', '顺序表与链表，插入删除复杂度对比', NULL, 1),
(@ds_course, '栈与队列', 'LIFO/FIFO 结构及典型应用场景', NULL, 2),
(@ds_course, '树与二叉树', '遍历、线索树、哈夫曼树、平衡树', NULL, 3),
(@ds_course, '图', '存储结构、DFS/BFS、最短路径、最小生成树', NULL, 4),
(@ds_course, '查找', '顺序查找、二分查找、哈希表、B树', NULL, 5),
(@ds_course, '排序', '快排、归并、堆排及其稳定性与复杂度', NULL, 6);

-- ============================================================
-- 4. 演示账号
--    手机号 13800000000 / 密码 123456
--    密码为 BCrypt 加密存储，明文不会入库
-- ============================================================
INSERT INTO user (phone, password, nickname, role) VALUES
('13800000000', '$2a$10$Cdp6ZQ1X9bqElozp94P3j.iTnR6Wpp/fVEhfjtyjd/CeeiWnHGBGG', '林知途', 'STUDENT')
ON DUPLICATE KEY UPDATE nickname = VALUES(nickname), role = VALUES(role);

-- 管理员账号（用于体验管理后台：/home/admin）
INSERT INTO user (phone, password, nickname, role) VALUES
('13900000000', '$2a$10$Cdp6ZQ1X9bqElozp94P3j.iTnR6Wpp/fVEhfjtyjd/CeeiWnHGBGG', '系统管理员', 'ADMIN')
ON DUPLICATE KEY UPDATE nickname = VALUES(nickname), role = VALUES(role);

SET @demo_uid = (SELECT id FROM user WHERE phone = '13800000000' LIMIT 1);

-- 学生档案（major_id = 1 计算机科学与技术）
INSERT INTO student_profile (user_id, school, major_id, grade, gpa,
    programming_level, java_level, python_level, cpp_level, ds_level, db_level,
    web_level, ai_level, english_level, interests, career_goal, ai_portrait) VALUES
(@demo_uid, '华中科技大学', 1, '大二', '良好',
 'INTERMEDIATE', 'INTERMEDIATE', 'BASIC', 'BASIC', 'BASIC', 'INTERMEDIATE',
 'INTERMEDIATE', 'BEGINNER', 'INTERMEDIATE',
 '["Java后端","Web开发","AI/机器学习"]', '就业',
 '{"summary":"你是一名基础扎实、方向清晰的大二学生。Java 与数据库能力已进入中级水平，Web 开发有实践经验，具备冲击大厂后端岗位的潜力。当前主要短板在于算法训练量不足、AI 方向尚未入门，且缺少可展示的完整项目与竞赛经历。建议本学期以「算法 + 一个完整项目」为主线。","strengths":["Java 与面向对象基础扎实","已有 Web 全栈实践经验","学习主动性强，方向明确"],"weaknesses":["算法刷题量偏少，缺少竞赛经历","项目深度不够，缺少可量化的成果","AI 方向尚未入门"],"scores":{"programming":72,"algorithm":48,"project":58,"competition":35,"ai":28,"english":65,"overall":51},"suggestions":["本学期刷完 LeetCode Hot 100，重点补动态规划与图论","把现有课程项目升级为可部署的完整项目并写进简历","每周固定 2 小时英语听力，为六级和后续技术文档阅读打底","关注蓝桥杯与传智杯，先拿一个省级奖项"],"threeMonthPlan":["第1个月：数据结构与算法系统复习，完成 60 道题","第2个月：独立完成一个 Spring Boot + Vue 的完整项目并部署上线","第3个月：报名并备战蓝桥杯，同步开始了解 AI 基础"]}')
ON DUPLICATE KEY UPDATE
    school = VALUES(school), major_id = VALUES(major_id), grade = VALUES(grade), gpa = VALUES(gpa),
    programming_level = VALUES(programming_level), java_level = VALUES(java_level),
    python_level = VALUES(python_level), cpp_level = VALUES(cpp_level), ds_level = VALUES(ds_level),
    db_level = VALUES(db_level), web_level = VALUES(web_level), ai_level = VALUES(ai_level),
    english_level = VALUES(english_level), interests = VALUES(interests),
    career_goal = VALUES(career_goal), ai_portrait = VALUES(ai_portrait);

-- 四年规划
DELETE FROM ai_plan WHERE user_id = @demo_uid AND plan_type = 'FOUR_YEAR';
INSERT INTO ai_plan (user_id, plan_type, content, start_date, end_date, status) VALUES
(@demo_uid, 'FOUR_YEAR',
 '{"overview":"以「就业」为目标，围绕 Java 后端方向构建核心竞争力：大二打牢算法与工程基础，大三用实习和项目完成从学生到工程师的转变。","freshman":{"theme":"打好基础，探索方向","goals":["掌握 C 与 Python 两门语言基础","通过英语四级","养成每天写代码的习惯"],"courses":["C语言程序设计","Python程序设计","高等数学","大学英语"],"skills":["C 语言基础","Git 版本控制","Linux 常用命令"],"competitions":["校级程序设计竞赛","全国大学生英语竞赛"],"tips":"大一不要急着追新技术，把编程和数学基础打牢，多动手少看视频。"},"sophomore":{"theme":"核心能力建设","goals":["掌握数据结构与算法","通过英语六级","完成一个可部署的完整项目","拿到第一个竞赛奖项"],"courses":["数据结构","数据库原理","Java程序设计","Web前端开发","Spring Boot框架"],"skills":["Java / Spring Boot","MySQL 与索引优化","Vue 3","前后端联调"],"competitions":["蓝桥杯","传智杯","中国大学生计算机设计大赛"],"tips":"大二是能力爆发期。数据结构必须学扎实，同时把项目做完整、能演示、能写进简历。"},"junior":{"theme":"实习与深度实战","goals":["拿到一份后端开发实习","完成两个有技术深度的项目","确定秋招目标岗位","开始系统刷面试题"],"courses":["操作系统","计算机网络","软件工程","机器学习"],"skills":["Redis 与缓存设计","消息队列","Docker 与部署","设计模式"],"competitions":["互联网+创新创业大赛","数学建模竞赛"],"tips":"大三的实习经历是校招最重要的加分项，务必在暑假前拿到。秋招提前批通常 7 月就开始了。"},"senior":{"theme":"收获成果","goals":["完成秋招并签约","完成毕业设计","完成从学生到职场人的心态转变"],"courses":["毕业设计"],"skills":["简历与面试表达","职业素养","技术复盘能力"],"competitions":[],"tips":"第一份工作优先选择能让你快速成长的团队，而不是只看薪资。"},"risks":["数据结构与算法是校招笔试的硬门槛，大二不补，大三会非常被动","没有实习经历会让简历在初筛阶段就被过滤","英语六级未通过会直接影响部分大厂的简历筛选"],"certificates":["大学英语四级 / 六级（CET-4/6）","软件设计师（软考中级）","计算机等级考试二级/三级"]}',
 CURDATE(), DATE_ADD(CURDATE(), INTERVAL 4 YEAR), 'ACTIVE');

-- 每日学习计划（今天起 7 天）
DELETE FROM study_plan WHERE user_id = @demo_uid AND plan_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 DAY);
INSERT INTO study_plan (user_id, course_id, plan_date, content, is_completed) VALUES
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '数据结构' LIMIT 1), CURDATE(), '复习线性表：手写单链表反转与环检测，完成 3 道 LeetCode', 0),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '算法设计与分析' LIMIT 1), DATE_ADD(CURDATE(), INTERVAL 1 DAY), '动态规划入门：01 背包与最长递增子序列，完成 4 道题', 0),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = 'Spring Boot框架' LIMIT 1), DATE_ADD(CURDATE(), INTERVAL 2 DAY), '为课程项目补上统一异常处理与参数校验', 0),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '数据结构' LIMIT 1), DATE_ADD(CURDATE(), INTERVAL 3 DAY), '二叉树专题：前中后序非递归遍历 + 层序遍历', 0),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '数据库原理' LIMIT 1), DATE_ADD(CURDATE(), INTERVAL 4 DAY), '索引原理与执行计划分析，优化 3 条慢查询', 0),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '计算机网络' LIMIT 1), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'TCP 三次握手四次挥手 + HTTP 缓存机制整理成笔记', 0),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = 'Web前端开发' LIMIT 1), DATE_ADD(CURDATE(), INTERVAL 6 DAY), '给项目做移动端适配，完成响应式布局改造', 0);

-- 学习记录（课程进度）
INSERT INTO learning_record (user_id, course_id, progress, study_minutes, status) VALUES
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = 'C语言程序设计' LIMIT 1), 100, 1800, 'COMPLETED'),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = 'Python程序设计' LIMIT 1), 100, 1200, 'COMPLETED'),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '数据结构' LIMIT 1), 60, 960, 'IN_PROGRESS'),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = '数据库原理' LIMIT 1), 45, 720, 'IN_PROGRESS'),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = 'Java程序设计' LIMIT 1), 80, 1440, 'IN_PROGRESS'),
(@demo_uid, (SELECT id FROM course WHERE major_id = 1 AND name = 'Web前端开发' LIMIT 1), 35, 600, 'IN_PROGRESS')
ON DUPLICATE KEY UPDATE
    progress = VALUES(progress), study_minutes = VALUES(study_minutes), status = VALUES(status);

-- 成长档案
DELETE FROM growth_record WHERE user_id = @demo_uid;
INSERT INTO growth_record (user_id, record_type, title, description, record_date) VALUES
(@demo_uid, 'PROJECT', '校园二手交易平台', '基于 Spring Boot + Vue 3 的前后端分离项目，实现商品发布、搜索、订单与即时通讯，独立完成数据库设计与后端接口开发', DATE_SUB(CURDATE(), INTERVAL 120 DAY)),
(@demo_uid, 'PROJECT', '个人博客系统', '使用 Vue 3 + Vite 搭建，支持 Markdown 渲染与标签检索，已部署至云服务器', DATE_SUB(CURDATE(), INTERVAL 60 DAY)),
(@demo_uid, 'COMPETITION', '蓝桥杯省赛三等奖', 'Java 组个人赛，负责全部算法题训练与参赛', DATE_SUB(CURDATE(), INTERVAL 200 DAY)),
(@demo_uid, 'CERTIFICATE', '大学英语四级（CET-4）', '总分 538', DATE_SUB(CURDATE(), INTERVAL 300 DAY)),
(@demo_uid, 'HONOR', '校级一等奖学金', '2024-2025 学年，专业排名前 10%', DATE_SUB(CURDATE(), INTERVAL 150 DAY)),
(@demo_uid, 'INTERNSHIP', '某科技公司后端开发实习生', '参与订单服务接口开发与单元测试编写，熟悉 Git 协作与 Code Review 流程', DATE_SUB(CURDATE(), INTERVAL 30 DAY));

-- AI 简历
DELETE FROM resume WHERE user_id = @demo_uid;
INSERT INTO resume (user_id, content, template) VALUES
(@demo_uid,
 '{"name":"林知途","education":{"school":"华中科技大学","major":"计算机科学与技术","grade":"大二"},"skills":["Java / Spring Boot","MySQL 与索引优化","Vue 3 / Vite","Git 协作开发","Linux 常用命令"],"courses":["数据结构","数据库原理","Java程序设计","Web前端开发","Spring Boot框架"],"projects":["校园二手交易平台 — Spring Boot + Vue 3 前后端分离，独立完成数据库设计与后端接口开发","个人博客系统 — Vue 3 + Vite 实现 Markdown 渲染与标签检索，已部署上线"],"competitions":["蓝桥杯省赛三等奖"],"certificates":["大学英语四级（CET-4）538分","校级一等奖学金"],"advantages":"具备扎实的 Java 与数据库基础，有两个完整的前后端分离项目经验，学习能力强，能快速上手新框架。","targetPosition":"Java 后端开发工程师（实习）"}',
 'DEFAULT');

-- 站内通知
DELETE FROM notification WHERE user_id = @demo_uid;
INSERT INTO notification (user_id, title, content, is_read) VALUES
(@demo_uid, '蓝桥杯报名即将截止', '你关注的「蓝桥杯全国软件和信息技术专业人才大赛」报名将于 40 天后截止，建议尽快完成报名并开始刷题。', 0),
(@demo_uid, 'AI 画像已更新', '系统根据你最新的学习记录更新了学生画像，算法能力得分较上次提升 8 分。', 0),
(@demo_uid, '本周学习计划已生成', 'AI 根据你的课程进度生成了 7 天学习计划，其中「数据结构」被识别为当前优先级最高的科目。', 1);

-- ============================================================
-- 种子数据写入完成
-- 演示账号：13800000000 / 123456
-- 管理账号：13900000000 / 123456
-- ============================================================
