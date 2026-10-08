-- ============================================================
-- 智途AI · 大学生成长规划平台
-- 03 / 03 —— 业务种子数据（DML）
--
-- 内容：
--   1. 课程（18 个专业方向模板 × 175 个专业 + 10 门通识课，共约 3950 条）
--   2. 竞赛（47 条，覆盖工/医/农/经管/法/教/艺/文各方向，含动态报名时间）
--   3. 课程知识点（knowledge_point）
--   4. 演示账号：13800000000 / 123456（含完整档案、画像、规划、档案、简历）
--
-- 说明：
--   * 第 1 段中「>>> GENERATED:courses >>>」到「<<< GENERATED:courses <<<」之间
--     由 scripts/gen-courses.mjs 依据 backend 的 MajorDirection.java 与
--     scripts/course-templates.mjs 自动生成，**请勿手工编辑**。
--     改完模板后执行：node scripts/gen-courses.mjs（在 zhitu-ai 目录下）
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
-- 1.2 课程 · 按专业方向自动展开（覆盖其余 170 个专业）
--
-- 下面这段由 scripts/gen-courses.mjs 生成：只维护一份「方向 → 课程」模板
-- （scripts/course-templates.mjs），再用 INSERT ... SELECT 配合专业名正则，
-- 把模板铺到该方向下的每一个专业上，避免手写一千多行课程。
-- 方向正则与优先级直接解析自 backend/.../MajorDirection.java，两边不会漂移。
--
-- 修改模板后请执行：node scripts/gen-courses.mjs
-- 请勿手工编辑标记之间的内容。
-- ============================================================
-- >>> GENERATED:courses >>>
-- 10 门通识课，铺给全部 175 个专业

-- 通识课程 · 所有专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '大学英语' AS name, '综合英语听说读写训练，四六级能力基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '通识必修' AS category, 1 AS sort_order
    UNION ALL SELECT '思想道德与法治' AS name, '世界观人生观价值观与法治素养教育' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '通识必修' AS category, 2 AS sort_order
    UNION ALL SELECT '大学体育' AS name, '体能训练与运动技能，养成终身体育习惯' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '通识必修' AS category, 3 AS sort_order
    UNION ALL SELECT '计算机应用基础' AS name, '办公软件、信息检索与数字素养基本技能' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '通识必修' AS category, 4 AS sort_order
    UNION ALL SELECT '中国近现代史纲要' AS name, '近代以来中国历史进程与基本历史经验' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '通识必修' AS category, 5 AS sort_order
    UNION ALL SELECT '马克思主义基本原理' AS name, '辩证唯物主义与历史唯物主义基本原理' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '通识必修' AS category, 6 AS sort_order
    UNION ALL SELECT '大学语文' AS name, '汉语表达、经典文本阅读与写作训练' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '通识选修' AS category, 7 AS sort_order
    UNION ALL SELECT '创新创业基础' AS name, '创新思维方法、创业流程与商业计划书撰写' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '通识选修' AS category, 8 AS sort_order
    UNION ALL SELECT '大学生职业发展与就业指导' AS name, '自我认知、职业规划与求职技能训练' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '通识选修' AS category, 9 AS sort_order
    UNION ALL SELECT '毕业设计（论文）' AS name, '结合专业方向的综合课题研究、设计与答辩' AS description, 'ADVANCED' AS difficulty, '大四上' AS semester, '综合实践' AS category, 10 AS sort_order
) c
WHERE 1 = 1
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 以下按专业方向逐块铺开；顺序与 MajorDirection.java 的优先级一致

-- 计算机 / 电子信息 · 17 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '高等数学' AS name, '极限、导数、积分、级数与常微分方程' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT 'C语言程序设计' AS name, '数据类型、流程控制、函数、指针与文件操作' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '线性代数' AS name, '行列式、矩阵、向量空间与线性方程组' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '离散数学' AS name, '集合、关系、图论、数理逻辑与组合计数' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '数据结构' AS name, '线性表、栈、队列、树、图、查找与排序' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '计算机组成原理' AS name, '运算器、存储器、指令系统与总线结构' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '概率论与数理统计' AS name, '随机变量、常见分布、参数估计与假设检验' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业基础' AS category, 7 AS sort_order
    UNION ALL SELECT '操作系统' AS name, '进程与线程、内存管理、文件系统与并发控制' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '数据库原理' AS name, '关系模型、SQL、范式设计与事务并发控制' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '计算机网络' AS name, '分层体系结构、TCP/IP协议、路由与网络安全' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '算法设计与分析' AS name, '分治、动态规划、贪心、回溯与复杂度分析' AS description, 'ADVANCED' AS difficulty, '大三上' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '软件工程' AS name, '需求分析、软件设计、测试与项目过程管理' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 12 AS sort_order
    UNION ALL SELECT '人工智能导论' AS name, '搜索、机器学习、神经网络与知识表示初步' AS description, 'ADVANCED' AS difficulty, '大三下' AS semester, '前沿拓展' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程'
  AND m.id NOT IN (1, 2, 3, 4, 5)
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 土木 / 建筑类 · 8 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '高等数学' AS name, '极限、导数、积分、级数与常微分方程' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '工程制图与识图' AS name, '投影原理、三视图、剖面图与施工图识读' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '土木工程材料' AS name, '水泥、混凝土、建筑钢材与沥青的性能与检测' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '理论力学' AS name, '静力学、运动学与动力学三大基本定律' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '材料力学' AS name, '拉压、剪切、扭转、弯曲与强度刚度计算' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '结构力学' AS name, '静定与超静定结构的内力分析与位移计算' AS description, 'ADVANCED' AS difficulty, '大二下' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '土力学与地基基础' AS name, '土的物理力学性质、地基承载力与基础设计' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '混凝土结构设计原理' AS name, '受弯受剪构件承载力计算与构造要求' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '钢结构设计' AS name, '钢结构连接、轴心受力构件与梁柱设计' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '工程CAD与BIM建模' AS name, 'AutoCAD绘图与Revit建筑结构建模出图' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '工程实践' AS category, 10 AS sort_order
    UNION ALL SELECT '建筑施工技术' AS name, '土方、砌筑、混凝土与装配式施工工艺' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '工程实践' AS category, 11 AS sort_order
    UNION ALL SELECT '工程概预算' AS name, '工程量清单计价、定额套用与造价文件编制' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '工程实践' AS category, 12 AS sort_order
) c
WHERE m.name REGEXP '土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 机电 / 自动化 / 材料类 · 18 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '高等数学' AS name, '极限、导数、积分、级数与常微分方程' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '工程制图' AS name, '投影法、零件图与装配图的绘制与识读' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT 'C语言程序设计' AS name, '数据类型、流程控制、函数、指针与文件操作' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '大学物理' AS name, '力学、热学、电磁学、光学与近代物理基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '理论力学' AS name, '静力学、运动学与动力学三大基本定律' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '材料力学' AS name, '拉压、剪切、扭转、弯曲与强度刚度计算' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 6 AS sort_order
    UNION ALL SELECT '电工电子技术' AS name, '电路分析、模拟电子与数字电子技术基础' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 7 AS sort_order
    UNION ALL SELECT '机械原理与机械设计' AS name, '机构运动分析、齿轮传动与通用零部件设计' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '自动控制原理' AS name, '系统建模、时域频域分析与稳定性判据' AS description, 'ADVANCED' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '单片机与嵌入式系统' AS name, '微控制器结构、中断定时器与接口编程' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '电气控制与PLC' AS name, '继电器控制线路与PLC梯形图程序设计' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '工程实践' AS category, 11 AS sort_order
    UNION ALL SELECT '液压与气动技术' AS name, '液压气动元件、基本回路设计与系统调试' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 12 AS sort_order
    UNION ALL SELECT '机械制造技术基础' AS name, '切削加工、工艺规程编制与装配精度分析' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '工程实践' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 纺织 / 轻化类 · 2 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '无机与分析化学' AS name, '溶液平衡、滴定分析与仪器分析基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '纺织概论' AS name, '纤维、纱线、织物与纺织产业链的整体认识' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '有机化学' AS name, '烃类、含氧含氮化合物与高分子合成基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '纺织材料学' AS name, '纤维结构与性能、纱线与织物基本参数测试' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业核心' AS category, 4 AS sort_order
    UNION ALL SELECT '纺纱学' AS name, '开清棉、梳棉、并条、粗纱与细纱工艺原理' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '织造学' AS name, '络筒、整经、浆纱、穿经与织造工艺原理' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '纺织品设计基础' AS name, '织物组织、配色与面料结构设计方法' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '染整工艺学' AS name, '前处理、染色、印花与后整理工艺原理' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '非织造技术' AS name, '非织造材料成网、固结工艺与产品应用' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '功能性纺织品' AS name, '阻燃、抗菌、防水透湿等功能整理与产品开发' AS description, 'ADVANCED' AS difficulty, '大三下' AS semester, '前沿拓展' AS category, 10 AS sort_order
    UNION ALL SELECT '纺织品贸易与检验' AS name, '纺织品标准、检测方法与外贸业务流程实务' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '工程实践' AS category, 11 AS sort_order
) c
WHERE m.name REGEXP '纺织|轻化'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 化工 / 环境 / 生物工程类 · 4 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '高等数学' AS name, '极限、导数、积分、级数与常微分方程' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '工程制图' AS name, '投影法、零件图与化工设备图的绘制与识读' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '无机与分析化学' AS name, '溶液平衡、滴定分析与仪器分析基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '有机化学' AS name, '烃类、含氧含氮化合物与反应机理基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '物理化学' AS name, '热力学、相平衡、电化学与化学动力学' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '化工原理' AS name, '流体流动、传热、传质与分离单元操作' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '化工热力学' AS name, '状态方程、相平衡计算与过程能量分析' AS description, 'ADVANCED' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '化学反应工程' AS name, '反应动力学、理想反应器与反应器设计' AS description, 'ADVANCED' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '化工设备设计' AS name, '换热器、塔设备与储罐的强度与结构设计' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '工程实践' AS category, 9 AS sort_order
    UNION ALL SELECT '化工工艺学' AS name, '典型化工产品的工艺流程与工艺条件分析' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '化工过程模拟(Aspen)' AS name, 'Aspen Plus流程建模、单元操作与参数优化' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '工程实践' AS category, 11 AS sort_order
    UNION ALL SELECT '化工安全与环保' AS name, '化工过程风险识别、安全设计与三废治理' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 12 AS sort_order
) c
WHERE m.name REGEXP '化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 食品 / 轻工类 · 1 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '无机与分析化学' AS name, '溶液平衡、滴定分析与仪器分析基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '食品微生物学' AS name, '微生物形态生理、发酵作用与食品腐败控制' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '有机化学' AS name, '烃类、含氧含氮化合物与反应机理基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '食品化学' AS name, '水分、糖类、蛋白质、脂类与风味物质变化' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 4 AS sort_order
    UNION ALL SELECT '食品工程原理' AS name, '流体输送、传热、浓缩、干燥与分离操作' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '食品营养学' AS name, '营养素功能、膳食平衡与营养评价方法' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '食品分析与检验' AS name, '理化指标与微生物指标的检测方法及标准' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '工程实践' AS category, 7 AS sort_order
    UNION ALL SELECT '食品工艺学' AS name, '果蔬、肉乳与粮油制品的加工工艺及保藏' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '食品机械与设备' AS name, '食品加工典型设备的结构、选型与操作' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '工程实践' AS category, 9 AS sort_order
    UNION ALL SELECT '食品安全学' AS name, '生物化学物理危害、风险评估与过程控制' AS description, 'ADVANCED' AS difficulty, '大三下' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '食品质量管理与法规' AS name, '食品安全国家标准、HACCP与质量管理体系' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 11 AS sort_order
) c
WHERE m.name REGEXP '食品|粮食|农产|包装|农业工程'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 药学 / 中药类 · 2 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '无机化学' AS name, '溶液平衡、配合物与元素化学基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '有机化学' AS name, '烃类、含氧含氮化合物与反应机理基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '分析化学' AS name, '化学分析与仪器分析方法及数据处理' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '人体解剖生理学' AS name, '人体各系统的结构与生理功能基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '生物化学' AS name, '蛋白质、酶、糖脂代谢与核酸化学基础' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '药物化学' AS name, '药物结构与活性关系、合成路线与稳定性' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '药理学' AS name, '药物作用机制、药效学与不良反应' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '药剂学' AS name, '片剂、注射剂等剂型设计与制备工艺' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '药物分析' AS name, '药品质量标准、含量测定与杂质检查方法' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '天然药物化学' AS name, '天然产物有效成分的提取分离与结构鉴定' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '生药学与中药鉴定学' AS name, '常用中药材的性状、显微与理化鉴定' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '药物制剂工程' AS name, '制剂生产设备、GMP车间与工艺放大' AS description, 'ADVANCED' AS difficulty, '大四上' AS semester, '工程实践' AS category, 12 AS sort_order
    UNION ALL SELECT '药事管理与法规' AS name, '药品注册、生产经营监管与药师职责' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '药学|中药|药物制剂|临床药学'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 护理类 · 1 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '人体解剖学' AS name, '人体各系统器官的位置、形态与结构' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '生理学' AS name, '细胞、血液、循环、呼吸与神经等生理功能' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '病理学' AS name, '疾病发生发展过程中的形态与机能改变' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '药理学' AS name, '药物作用机制、药效学与用药护理要点' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '健康评估' AS name, '问诊、体格检查与辅助检查结果分析' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '基础护理学' AS name, '无菌技术、注射输液、导尿与病情观察操作' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '内科护理学' AS name, '呼吸循环消化等系统常见疾病的护理措施' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '外科护理学' AS name, '围手术期护理、创伤与常见外科疾病护理' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '妇产科护理学' AS name, '妊娠、分娩、产褥期与妇科疾病的护理' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '儿科护理学' AS name, '小儿生长发育规律与常见儿科疾病护理' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '急危重症护理学' AS name, '急救技术、心肺复苏与重症监护护理' AS description, 'ADVANCED' AS difficulty, '大四上' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '社区护理学' AS name, '社区健康管理、慢病随访与健康教育' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 12 AS sort_order
) c
WHERE m.name REGEXP '护理'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 农学类 · 8 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '植物学' AS name, '植物细胞、组织、器官形态与系统分类' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '土壤肥料学' AS name, '土壤理化性质、养分循环与合理施肥原理' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '生物化学' AS name, '蛋白质、酶、糖脂代谢与核酸化学基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '植物生理学' AS name, '水分矿质、光合呼吸、生长发育与逆境生理' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业核心' AS category, 4 AS sort_order
    UNION ALL SELECT '遗传学' AS name, '孟德尔遗传、连锁交换、基因突变与数量性状' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '农业微生物学' AS name, '土壤与植物相关微生物特性及其农业应用' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 6 AS sort_order
    UNION ALL SELECT '作物栽培学' AS name, '主要农作物的生长发育规律与高产栽培技术' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '园艺植物栽培学' AS name, '果树、蔬菜与花卉的栽培管理及设施生产' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '植物保护学(病虫害防治)' AS name, '主要病虫草害的识别、发生规律与综合防治' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '农业生态学' AS name, '农业生态系统结构功能与可持续耕作制度' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '田间试验与统计分析' AS name, '试验设计、方差分析与试验数据的统计推断' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业基础' AS category, 11 AS sort_order
    UNION ALL SELECT '种子学' AS name, '种子形成、活力检验、加工贮藏与质量控制' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 12 AS sort_order
    UNION ALL SELECT '智慧农业导论' AS name, '物联网、遥感与农业大数据在种植业中的应用' AS description, 'ADVANCED' AS difficulty, '大四上' AS semester, '前沿拓展' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '农学|园艺|植物|林学|园林|草业|茶学|烟草|种子'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 动物 / 水产类 · 3 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '动物学' AS name, '动物类群的形态结构、分类与进化' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '动物解剖学' AS name, '家畜家禽各系统器官的形态与位置' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '动物生物化学' AS name, '蛋白质、酶与糖脂代谢等生命化学基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '动物生理学' AS name, '血液、循环、呼吸、消化与神经内分泌功能' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业核心' AS category, 4 AS sort_order
    UNION ALL SELECT '微生物学与免疫学' AS name, '病原微生物特性与机体免疫应答机制' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '动物营养与饲料学' AS name, '营养需要、饲料养分评价与日粮配合' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '动物遗传育种学' AS name, '遗传规律、选择方法与畜禽育种体系' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '动物繁殖学' AS name, '生殖生理、人工授精与繁殖调控技术' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '兽医学基础' AS name, '兽医病理、药理与临床诊断基本方法' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '动物疫病防治' AS name, '传染病与寄生虫病的流行规律及综合防控' AS description, 'ADVANCED' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '水产养殖学' AS name, '主要养殖鱼类的水质管理、饲料与养殖模式' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '畜牧业经营管理' AS name, '养殖场生产组织、成本核算与市场营销' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业选修' AS category, 12 AS sort_order
) c
WHERE m.name REGEXP '动物|水产|畜牧|兽医'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 医学类 · 12 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '人体解剖学' AS name, '人体各系统器官的位置、形态与结构' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '生理学' AS name, '细胞、血液、循环、呼吸与神经等生理功能' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '生物化学与分子生物学' AS name, '物质代谢、基因表达与分子生物学技术' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '医学微生物学与免疫学' AS name, '病原微生物特性与机体免疫应答机制' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '病理学' AS name, '疾病发生发展过程中的形态与机能改变' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '药理学' AS name, '药物作用机制、药效学与临床应用原则' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业基础' AS category, 6 AS sort_order
    UNION ALL SELECT '诊断学' AS name, '问诊、体格检查与实验室及器械检查' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '内科学' AS name, '呼吸循环消化内分泌等内科疾病的诊治' AS description, 'ADVANCED' AS difficulty, '大三上' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '外科学' AS name, '外科总论、常见外科疾病的诊断与手术原则' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '妇产科学' AS name, '妊娠、分娩、产褥期与妇科疾病的诊治' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '儿科学' AS name, '小儿生长发育规律与常见儿科疾病的诊治' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '临床技能训练' AS name, '病史采集、体格检查与常用临床操作训练' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '实践教学' AS category, 12 AS sort_order
) c
WHERE m.name REGEXP '医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 经管类 · 26 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '管理学原理' AS name, '计划、组织、领导与控制等管理基本职能' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '微观经济学' AS name, '供求理论、消费者行为、厂商理论与市场结构' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '会计学原理' AS name, '会计要素、复式记账与财务报表编制' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '宏观经济学' AS name, '国民收入、就业、通胀与宏观经济政策' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '统计学' AS name, '描述统计、抽样推断与回归分析基础' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '经济法' AS name, '市场主体、合同、竞争与消费者权益法律制度' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 6 AS sort_order
    UNION ALL SELECT '市场营销学' AS name, '市场细分、目标市场选择与营销组合策略' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '组织行为学' AS name, '个体、群体与组织层面的行为规律' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '财务管理' AS name, '资金时间价值、筹资投资与营运资金管理' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '运营管理' AS name, '生产与服务系统的计划、库存与质量管理' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '金融学' AS name, '货币信用、金融市场与金融机构运行机制' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '计量经济学' AS name, '回归模型设定、估计检验与经济数据实证' AS description, 'ADVANCED' AS difficulty, '大三下' AS semester, '专业核心' AS category, 12 AS sort_order
    UNION ALL SELECT '战略管理' AS name, '环境分析、竞争战略选择与战略实施评价' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医|医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 法学类 · 8 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '法理学' AS name, '法的本质、渊源、效力与法律推理方法' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '宪法学' AS name, '国家基本制度、公民基本权利与国家机构' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '民法总论' AS name, '民事主体、法律行为、代理与诉讼时效' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业核心' AS category, 3 AS sort_order
    UNION ALL SELECT '刑法总论' AS name, '犯罪构成、正当防卫与刑罚制度' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业核心' AS category, 4 AS sort_order
    UNION ALL SELECT '民事诉讼法' AS name, '管辖、证据、审判程序与执行程序' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '刑事诉讼法' AS name, '立案侦查、审查起诉与审判程序规则' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '行政法与行政诉讼法' AS name, '行政行为、行政复议与行政诉讼制度' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 7 AS sort_order
    UNION ALL SELECT '商法' AS name, '公司、证券、票据、保险与破产法律制度' AS description, 'ADVANCED' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '经济法' AS name, '反垄断、反不正当竞争与财税金融监管法' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '知识产权法' AS name, '著作权、专利权与商标权的取得与保护' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '国际法' AS name, '国际法主体、条约、海洋与争端解决制度' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '法律职业伦理' AS name, '法官、检察官与律师的职业规范及执业纪律' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 12 AS sort_order
) c
WHERE m.name REGEXP '法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医|医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生|工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 教育类 · 8 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '教育学原理' AS name, '教育的本质、目的、制度与教育基本规律' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '普通心理学' AS name, '感知、记忆、思维、情绪与人格等心理现象' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '中外教育史' AS name, '中国与外国教育思想及教育制度的演变' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '教育心理学' AS name, '学习理论、学习动机、迁移与个体差异' AS description, 'INTERMEDIATE' AS difficulty, '大一下' AS semester, '专业核心' AS category, 4 AS sort_order
    UNION ALL SELECT '课程与教学论' AS name, '课程设计、教学目标确定与课堂教学方法' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '普通话与教师口语' AS name, '普通话语音训练与教师教学语言表达' AS description, 'BEGINNER' AS difficulty, '大二上' AS semester, '技能训练' AS category, 6 AS sort_order
    UNION ALL SELECT '现代教育技术' AS name, '多媒体课件制作、微课与信息化教学设计' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '技能训练' AS category, 7 AS sort_order
    UNION ALL SELECT '教育研究方法' AS name, '教育调查、实验设计与研究论文撰写' AS description, 'ADVANCED' AS difficulty, '大二下' AS semester, '专业基础' AS category, 8 AS sort_order
    UNION ALL SELECT '教师职业技能训练' AS name, '板书、说课、试讲与课堂教学评价训练' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '技能训练' AS category, 9 AS sort_order
    UNION ALL SELECT '班级管理' AS name, '班集体建设、学生指导与家校沟通实务' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '运动生理学' AS name, '运动时人体机能变化规律与运动训练基础' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '体育教学论' AS name, '体育教学目标、内容组织与教学方法设计' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业核心' AS category, 12 AS sort_order
    UNION ALL SELECT '教育政策与法规' AS name, '教育法律法规、教师权利义务与学校制度' AS description, 'INTERMEDIATE' AS difficulty, '大四上' AS semester, '专业核心' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '教育学|学前教育|小学教育|特殊教育|体育教育|运动训练|社会体育|教育技术'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医|医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生|工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济|法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 艺术类 · 15 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '艺术概论' AS name, '艺术的本质、门类、创作与接受基本理论' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '素描与色彩基础' AS name, '造型、结构、明暗与色彩表现基础训练' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '中外美术史' AS name, '中国与西方美术的发展脉络与代表作品' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '平面构成与色彩构成' AS name, '点线面的组织规律与色彩对比调和原理' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '设计软件基础(PS/AI)' AS name, 'Photoshop图像处理与Illustrator矢量绘图' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '技能训练' AS category, 5 AS sort_order
    UNION ALL SELECT '字体与版式设计' AS name, '汉字与西文字体设计及版面编排方法' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '摄影基础' AS name, '曝光、构图、用光与数字后期处理基础' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '技能训练' AS category, 7 AS sort_order
    UNION ALL SELECT '数字媒体艺术基础' AS name, '数字影像、交互设计与动态图形创作基础' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 8 AS sort_order
    UNION ALL SELECT '设计心理学' AS name, '用户认知、情感与行为规律在设计中的应用' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业基础' AS category, 9 AS sort_order
    UNION ALL SELECT '影视视听语言' AS name, '镜头、景别、声音与剪辑的叙事规律' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '毕业创作' AS name, '综合运用所学完成系列作品的创作与展陈' AS description, 'ADVANCED' AS difficulty, '大四上' AS semester, '综合实践' AS category, 11 AS sort_order
) c
WHERE m.name REGEXP '音乐|作曲|美术|绘画|雕塑|设计|动画|戏剧|影视|广播电视编导|播音|摄影|舞蹈|艺术'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医|医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生|工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济|法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学|教育学|学前教育|小学教育|特殊教育|体育教育|运动训练|社会体育|教育技术'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 理科基础类 · 17 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '数学分析' AS name, '极限、连续、微分、积分与级数理论' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '高等代数' AS name, '多项式、矩阵、线性空间与线性变换' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 2 AS sort_order
    UNION ALL SELECT '解析几何' AS name, '向量代数、平面曲线与空间曲面方程' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '普通物理学' AS name, '力学、热学、电磁学、光学与近代物理基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 4 AS sort_order
    UNION ALL SELECT '无机化学' AS name, '溶液平衡、配合物与元素化学基础' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '专业基础' AS category, 5 AS sort_order
    UNION ALL SELECT '有机化学' AS name, '烃类、含氧含氮化合物与反应机理基础' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 6 AS sort_order
    UNION ALL SELECT '分析化学' AS name, '化学分析与仪器分析方法及数据处理' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 7 AS sort_order
    UNION ALL SELECT '概率论与数理统计' AS name, '随机变量、常见分布、参数估计与假设检验' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业基础' AS category, 8 AS sort_order
    UNION ALL SELECT '常微分方程' AS name, '一阶与高阶方程解法、定性理论与应用' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业基础' AS category, 9 AS sort_order
    UNION ALL SELECT '细胞生物学' AS name, '细胞结构、代谢、分裂分化与信号转导' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 10 AS sort_order
    UNION ALL SELECT '遗传学' AS name, '孟德尔遗传、连锁交换、基因突变与数量性状' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '数理统计' AS name, '抽样分布、参数估计、假设检验与方差分析' AS description, 'ADVANCED' AS difficulty, '大三下' AS semester, '专业核心' AS category, 12 AS sort_order
    UNION ALL SELECT '心理学导论' AS name, '心理现象、主要流派与心理学研究方法' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '专业选修' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '数学|物理|化学|生物科学|生物技术|生态|天文|地理|大气|海洋|地质|地球物理|统计|心理|计算科学'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医|医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生|工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济|法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学|教育学|学前教育|小学教育|特殊教育|体育教育|运动训练|社会体育|教育技术|音乐|作曲|美术|绘画|雕塑|设计|动画|戏剧|影视|广播电视编导|播音|摄影|舞蹈|艺术'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- 人文社科 / 外语类 · 25 个专业
INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)
SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order
FROM major m
CROSS JOIN (
    SELECT '现代汉语' AS name, '语音、文字、词汇、语法与修辞基础' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 1 AS sort_order
    UNION ALL SELECT '中国古代文学' AS name, '先秦至清代的文学发展脉络与经典作品' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业核心' AS category, 2 AS sort_order
    UNION ALL SELECT '综合英语' AS name, '英语精读与听说读写综合能力训练' AS description, 'BEGINNER' AS difficulty, '大一上' AS semester, '专业基础' AS category, 3 AS sort_order
    UNION ALL SELECT '英语听力与口语' AS name, '英语语音、听力理解与口头表达训练' AS description, 'BEGINNER' AS difficulty, '大一下' AS semester, '技能训练' AS category, 4 AS sort_order
    UNION ALL SELECT '古代汉语' AS name, '文言词汇语法、古籍选读与标点翻译' AS description, 'ADVANCED' AS difficulty, '大一下' AS semester, '专业核心' AS category, 5 AS sort_order
    UNION ALL SELECT '中国现当代文学' AS name, '五四以来的文学思潮、作家作品与批评' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业核心' AS category, 6 AS sort_order
    UNION ALL SELECT '语言学概论' AS name, '语言的本质、结构系统与语言研究方法' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 7 AS sort_order
    UNION ALL SELECT '中国通史' AS name, '中国历代政治、经济与文化的演变' AS description, 'INTERMEDIATE' AS difficulty, '大二上' AS semester, '专业基础' AS category, 8 AS sort_order
    UNION ALL SELECT '外国文学' AS name, '欧美与东方文学的发展脉络与经典作品' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业核心' AS category, 9 AS sort_order
    UNION ALL SELECT '哲学导论' AS name, '中西哲学的基本问题、流派与思维方式' AS description, 'INTERMEDIATE' AS difficulty, '大二下' AS semester, '专业基础' AS category, 10 AS sort_order
    UNION ALL SELECT '翻译理论与实践' AS name, '英汉互译技巧、文体处理与译作评析' AS description, 'ADVANCED' AS difficulty, '大三上' AS semester, '专业核心' AS category, 11 AS sort_order
    UNION ALL SELECT '传播学概论' AS name, '传播过程、媒介理论与受众研究基本框架' AS description, 'INTERMEDIATE' AS difficulty, '大三上' AS semester, '专业基础' AS category, 12 AS sort_order
    UNION ALL SELECT '新闻采访与写作' AS name, '选题策划、采访方法与新闻稿写作实务' AS description, 'INTERMEDIATE' AS difficulty, '大三下' AS semester, '技能训练' AS category, 13 AS sort_order
) c
WHERE m.name REGEXP '汉语言|汉语国际|英语|俄语|日语|德语|法语|西班牙语|朝鲜语|翻译|新闻|广播电视学|广告|传播|编辑出版|网络与新媒体|历史|考古|文物|世界史|哲学|逻辑学|宗教学|伦理学'
  AND m.name NOT REGEXP '计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程|土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土|机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通|纺织|轻化|化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学|食品|粮食|农产|包装|农业工程|药学|中药|药物制剂|临床药学|护理|农学|园艺|植物|林学|园林|草业|茶学|烟草|种子|动物|水产|畜牧|兽医|医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生|工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济|法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学|教育学|学前教育|小学教育|特殊教育|体育教育|运动训练|社会体育|教育技术|音乐|作曲|美术|绘画|雕塑|设计|动画|戏剧|影视|广播电视编导|播音|摄影|舞蹈|艺术|数学|物理|化学|生物科学|生物技术|生态|天文|地理|大气|海洋|地质|地球物理|统计|心理|计算科学'
ON DUPLICATE KEY UPDATE
    description = VALUES(description), difficulty = VALUES(difficulty),
    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);

-- <<< GENERATED:courses <<<

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
-- 2.2 竞赛 · 其它专业方向
--
-- 上面 10 个赛事以计算机 / 电子信息方向为主，这里补齐土木、机械、
-- 化工、食品、医学、药学、农林、经管、法学、师范、艺术、理科、
-- 人文等方向的代表性赛事，保证任何一个专业都有可推荐的比赛。
-- 日期同样使用 CURDATE() 相对表达式，任何时候演示都有报名倒计时。
-- ============================================================
INSERT INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) VALUES
('全国大学生结构设计竞赛',
 '土木工程专业最高级别的学科竞赛，需制作结构模型并现场进行加载试验',
 '土木建筑', '["土木工程","建筑学","水利水电工程","工程管理"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 55 DAY),
 DATE_ADD(CURDATE(), INTERVAL 85 DAY), DATE_ADD(CURDATE(), INTERVAL 88 DAY),
 'INTERMEDIATE', 'http://www.structurecontest.com/', 75),
('全国大学生先进成图技术与产品信息建模创新大赛',
 '工程制图与三维建模能力的国家级赛事，土木、建筑、机械专业通用',
 '土木建筑', '["土木工程","建筑学","城乡规划","机械工程","机械设计制造及其自动化"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY),
 DATE_ADD(CURDATE(), INTERVAL 62 DAY), DATE_ADD(CURDATE(), INTERVAL 63 DAY),
 'INTERMEDIATE', 'https://www.chengtudasai.com/', 60),
('全国周培源大学生力学竞赛',
 '力学基础能力的权威竞赛，土木、机械、水利类专业认可度高',
 '土木建筑', '["土木工程","机械工程","水利水电工程","航空航天工程"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 25 DAY), DATE_ADD(CURDATE(), INTERVAL 80 DAY),
 DATE_ADD(CURDATE(), INTERVAL 115 DAY), DATE_ADD(CURDATE(), INTERVAL 115 DAY),
 'ADVANCED', 'https://www.cstam.org.cn/', 90),
('全国大学生BIM应用技能大赛',
 '建筑信息模型（BIM）应用能力竞赛，偏实务，对土建类就业帮助直接',
 '土木建筑', '["土木工程","建筑学","城乡规划","工程管理","工程造价"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY),
 DATE_ADD(CURDATE(), INTERVAL 58 DAY), DATE_ADD(CURDATE(), INTERVAL 59 DAY),
 'INTERMEDIATE', 'https://www.bimcontest.com/', 45),
('全国大学生机械创新设计大赛',
 '机械类最有影响力的学科竞赛，要求做出可运行的实物作品',
 '机械控制', '["机械工程","机械设计制造及其自动化","车辆工程","机器人工程","材料成型及控制工程"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 95 DAY),
 DATE_ADD(CURDATE(), INTERVAL 140 DAY), DATE_ADD(CURDATE(), INTERVAL 142 DAY),
 'ADVANCED', 'http://umic.ckcest.cn/', 120),
('全国大学生智能汽车竞赛',
 '以智能车为载体，覆盖控制、传感、嵌入式与算法，自动化专业的经典赛事',
 '机械控制', '["自动化","电气工程及其自动化","测控技术与仪器","电子信息工程","车辆工程","机器人工程"]', '大二及以上',
 DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 45 DAY),
 DATE_ADD(CURDATE(), INTERVAL 100 DAY), DATE_ADD(CURDATE(), INTERVAL 102 DAY),
 'ADVANCED', 'https://smartcarrace.com/', 120),
('中国大学生工程实践与创新能力大赛',
 '面向工程实践与创新能力的综合赛事，含智能物流、飞行器、桥梁等赛项',
 '机械控制', '["机械工程","自动化","电气工程及其自动化","工业工程","土木工程"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 70 DAY),
 DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 130 DAY),
 'ADVANCED', 'https://www.gcxl.edu.cn/', 90),
('全国大学生节能减排社会实践与科技竞赛',
 '面向能源、动力、环境类专业的科技竞赛，作品需体现节能减排效益',
 '机械控制', '["能源与动力工程","环境工程","电气工程及其自动化","化学工程与工艺"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY),
 DATE_ADD(CURDATE(), INTERVAL 52 DAY), DATE_ADD(CURDATE(), INTERVAL 53 DAY),
 'INTERMEDIATE', 'https://www.jienengjianpai.org/', 75),
('全国大学生金相技能大赛',
 '材料类专业最基础的实践技能竞赛，考察试样制备与显微组织观察',
 '材料', '["材料科学与工程","材料成型及控制工程","机械工程"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 50 DAY),
 DATE_ADD(CURDATE(), INTERVAL 75 DAY), DATE_ADD(CURDATE(), INTERVAL 76 DAY),
 'INTERMEDIATE', 'https://www.csm.org.cn/', 45),
('全国大学生化工设计竞赛',
 '化工类专业最具影响力的赛事，需完成整套工艺设计并进行经济分析',
 '化工设计', '["化学工程与工艺","制药工程","生物工程","应用化学"]', '大三及以上',
 DATE_ADD(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 88 DAY),
 DATE_ADD(CURDATE(), INTERVAL 130 DAY), DATE_ADD(CURDATE(), INTERVAL 135 DAY),
 'ADVANCED', 'https://www.chemsoc.org.cn/', 120),
('全国大学生化学实验竞赛',
 '化学实验操作与实验设计能力的国家级赛事，理工科化学方向适用',
 '化工设计', '["化学","应用化学","化学工程与工艺","制药工程","材料科学与工程"]', '大三及以上',
 DATE_SUB(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY),
 DATE_ADD(CURDATE(), INTERVAL 56 DAY), DATE_ADD(CURDATE(), INTERVAL 57 DAY),
 'ADVANCED', 'https://www.chemsoc.org.cn/', 90),
('全国大学生生命科学竞赛',
 '面向生物、生物工程、食品、医学等专业的科研类竞赛，需完整科研过程',
 '生命科学', '["生物科学","生物技术","生物工程","食品科学与工程","基础医学","生物医学工程"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 68 DAY),
 DATE_ADD(CURDATE(), INTERVAL 105 DAY), DATE_ADD(CURDATE(), INTERVAL 108 DAY),
 'INTERMEDIATE', 'https://www.culsc.cn/', 90),
('全国大学生食品科技创新大赛',
 '食品类专业的创新创业赛事，作品需含实物产品或完整工艺方案',
 '食品轻工', '["食品科学与工程"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 6 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY),
 DATE_ADD(CURDATE(), INTERVAL 64 DAY), DATE_ADD(CURDATE(), INTERVAL 65 DAY),
 'INTERMEDIATE', 'https://www.cifst.org.cn/', 60),
('全国大学生纺织类创新创业大赛',
 '纺织、轻化类专业的学科竞赛，覆盖材料、工艺与产品设计',
 '食品轻工', '["纺织工程","轻化工程","材料科学与工程"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 16 DAY), DATE_ADD(CURDATE(), INTERVAL 66 DAY),
 DATE_ADD(CURDATE(), INTERVAL 96 DAY), DATE_ADD(CURDATE(), INTERVAL 97 DAY),
 'INTERMEDIATE', 'https://www.ctes.cn/', 60),
('中国大学生医学技术技能大赛',
 '教育部主办的医学类最高级别赛事，分临床、护理、药学、预防等赛道',
 '医学技能', '["临床医学","护理学","药学","预防医学","中医学","麻醉学"]', '大三及以上',
 DATE_ADD(CURDATE(), INTERVAL 22 DAY), DATE_ADD(CURDATE(), INTERVAL 92 DAY),
 DATE_ADD(CURDATE(), INTERVAL 135 DAY), DATE_ADD(CURDATE(), INTERVAL 138 DAY),
 'ADVANCED', 'https://www.moe.gov.cn/', 120),
('全国大学生基础医学创新研究暨实验设计论坛',
 '基础医学与实验设计类竞赛，适合有科研经历、准备保研的同学',
 '医学技能', '["基础医学","临床医学","预防医学","医学检验技术","法医学"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY),
 DATE_ADD(CURDATE(), INTERVAL 70 DAY), DATE_ADD(CURDATE(), INTERVAL 72 DAY),
 'INTERMEDIATE', 'https://www.cma.org.cn/', 75),
('全国大学生药苑论坛',
 '药学类专业的学术与创新竞赛，含论文、实验与成果展示环节',
 '药学', '["药学","中药学","制药工程","临床药学"]', '大三及以上',
 DATE_ADD(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 56 DAY),
 DATE_ADD(CURDATE(), INTERVAL 86 DAY), DATE_ADD(CURDATE(), INTERVAL 88 DAY),
 'INTERMEDIATE', 'https://www.cpa.org.cn/', 60),
('全国大学生动物医学专业技能大赛',
 '动物医学与动物科学专业的操作技能赛事，考察临床与防疫基本功',
 '农林', '["动物医学","动物科学"]', '大三及以上',
 DATE_ADD(CURDATE(), INTERVAL 9 DAY), DATE_ADD(CURDATE(), INTERVAL 49 DAY),
 DATE_ADD(CURDATE(), INTERVAL 79 DAY), DATE_ADD(CURDATE(), INTERVAL 80 DAY),
 'INTERMEDIATE', 'https://www.caav.org.cn/', 60),
('全国大学生植物生产类实践技能竞赛',
 '农学、园艺、植物保护类专业的实践技能赛事，田间与实验室结合',
 '农林', '["农学","园艺","植物保护","植物科学与技术","茶学","烟草"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY),
 DATE_ADD(CURDATE(), INTERVAL 68 DAY), DATE_ADD(CURDATE(), INTERVAL 69 DAY),
 'INTERMEDIATE', 'https://www.caass.org.cn/', 60),
('全国大学生市场调查与分析大赛',
 '经管类专业最主流的学科竞赛，含调研报告、数据分析与现场答辩',
 '经管实务', '["市场营销","工商管理","会计学","财务管理","统计学","经济统计学","经济学","人力资源管理"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY),
 DATE_ADD(CURDATE(), INTERVAL 50 DAY), DATE_ADD(CURDATE(), INTERVAL 52 DAY),
 'INTERMEDIATE', 'http://www.china-csm.org/', 75),
('全国大学生物流设计大赛',
 '物流管理专业最高规格赛事，以企业真实案例命题，作品需可落地',
 '经管实务', '["物流管理","供应链管理","交通运输","电子商务","工业工程"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 24 DAY), DATE_ADD(CURDATE(), INTERVAL 84 DAY),
 DATE_ADD(CURDATE(), INTERVAL 120 DAY), DATE_ADD(CURDATE(), INTERVAL 122 DAY),
 'INTERMEDIATE', 'http://www.chinawuliu.com.cn/', 75),
('中金所杯全国大学生金融知识大赛',
 '金融类专业的知识型竞赛，覆盖金融衍生品、投资实务与风险管理',
 '经管实务', '["金融学","金融工程","投资学","保险学","经济学","经济统计学"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 4 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY),
 DATE_ADD(CURDATE(), INTERVAL 66 DAY), DATE_ADD(CURDATE(), INTERVAL 66 DAY),
 'INTERMEDIATE', 'http://www.cffex.com.cn/', 60),
('全国大学生会计信息化技能大赛',
 '会计与财务类专业的信息化实务竞赛，考察财务软件与业财融合能力',
 '经管实务', '["会计学","财务管理","税收学","工商管理"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 6 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY),
 DATE_ADD(CURDATE(), INTERVAL 66 DAY), DATE_ADD(CURDATE(), INTERVAL 67 DAY),
 'BEGINNER', 'https://www.yonyou.com/', 45),
('全国大学生模拟法庭竞赛',
 '法学专业最典型的实践竞赛，以模拟庭审形式考察法律职业能力',
 '法学', '["法学","知识产权","监狱学","侦查学"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 13 DAY), DATE_ADD(CURDATE(), INTERVAL 58 DAY),
 DATE_ADD(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 92 DAY),
 'INTERMEDIATE', 'https://www.moj.gov.cn/', 60),
('全国学生学宪法讲宪法活动',
 '面向全国学生的宪法学习与演讲活动，法学与思政类专业友好',
 '法学', '["法学","知识产权","思想政治教育","政治学与行政学","行政管理"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_ADD(CURDATE(), INTERVAL 18 DAY),
 DATE_ADD(CURDATE(), INTERVAL 44 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY),
 'BEGINNER', 'https://www.moe.gov.cn/', 30),
('田家炳杯全国师范院校师范生教学技能竞赛',
 '师范类专业最高规格的教学技能竞赛，含说课、板书与教学设计',
 '师范技能', '["教育学","学前教育","小学教育","特殊教育","体育教育","汉语言文学","数学与应用数学","英语"]', '大三及以上',
 DATE_ADD(CURDATE(), INTERVAL 17 DAY), DATE_ADD(CURDATE(), INTERVAL 72 DAY),
 DATE_ADD(CURDATE(), INTERVAL 108 DAY), DATE_ADD(CURDATE(), INTERVAL 110 DAY),
 'INTERMEDIATE', 'https://www.moe.gov.cn/', 90),
('全国大学生广告艺术大赛',
 '广告、设计、新闻传播类专业的主流赛事，覆盖面广、获奖机会多',
 '艺术设计', '["广告学","视觉传达设计","数字媒体艺术","传播学","广播电视学","网络与新媒体"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 9 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY),
 DATE_ADD(CURDATE(), INTERVAL 70 DAY), DATE_ADD(CURDATE(), INTERVAL 72 DAY),
 'INTERMEDIATE', 'https://www.sun-ada.net/', 60),
('全国大学生工业设计大赛',
 '产品设计、工业设计类国家级赛事，注重作品的落地性与可用性',
 '艺术设计', '["产品设计","视觉传达设计","环境设计","工业工程"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 11 DAY), DATE_ADD(CURDATE(), INTERVAL 61 DAY),
 DATE_ADD(CURDATE(), INTERVAL 95 DAY), DATE_ADD(CURDATE(), INTERVAL 96 DAY),
 'INTERMEDIATE', 'https://www.cuidc.org/', 75),
('全国大学生艺术展演',
 '教育部主办的综合性艺术展演，覆盖音乐、美术、舞蹈、戏剧等门类',
 '艺术设计', '["音乐学","音乐表演","美术学","绘画","雕塑","播音与主持艺术"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 28 DAY), DATE_ADD(CURDATE(), INTERVAL 98 DAY),
 DATE_ADD(CURDATE(), INTERVAL 150 DAY), DATE_ADD(CURDATE(), INTERVAL 160 DAY),
 'INTERMEDIATE', 'https://www.moe.gov.cn/', 90),
('全国大学生数学竞赛',
 '面向本科生的数学基础能力竞赛，分数学类与非数学类，各专业均可参加',
 '理科基础', '["*"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 11 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY),
 DATE_ADD(CURDATE(), INTERVAL 60 DAY), DATE_ADD(CURDATE(), INTERVAL 60 DAY),
 'INTERMEDIATE', 'http://www.cmathc.cn/', 60),
('中国大学生物理学术竞赛',
 '物理类专业最具代表性的学术竞赛，以开放性物理问题的辩论形式进行',
 '理科基础', '["物理学","应用物理学","材料科学与工程"]', '大二及以上',
 DATE_ADD(CURDATE(), INTERVAL 21 DAY), DATE_ADD(CURDATE(), INTERVAL 91 DAY),
 DATE_ADD(CURDATE(), INTERVAL 130 DAY), DATE_ADD(CURDATE(), INTERVAL 133 DAY),
 'ADVANCED', 'https://www.cps.org.cn/', 120),
('全国大学生统计建模大赛',
 '统计学类专业赛事，围绕真实数据完成建模与研究报告撰写',
 '理科基础', '["统计学","经济统计学","数学与应用数学","应用化学"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 52 DAY),
 DATE_ADD(CURDATE(), INTERVAL 88 DAY), DATE_ADD(CURDATE(), INTERVAL 90 DAY),
 'INTERMEDIATE', 'http://www.china-csm.org/', 75),
('外研社杯全国大学生英语挑战赛',
 '英语类专业主流赛事，含演讲、写作、阅读三项，认可度高',
 '英语', '["英语","翻译","汉语国际教育","*"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 13 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY),
 DATE_ADD(CURDATE(), INTERVAL 57 DAY), DATE_ADD(CURDATE(), INTERVAL 58 DAY),
 'INTERMEDIATE', 'https://uchallenge.unipus.cn/', 45),
('中华经典诵写讲大赛',
 '面向高校师生的经典诵读、讲解与书写大赛，人文类专业友好',
 '人文', '["汉语言文学","汉语言","汉语国际教育","历史学","哲学","*"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 9 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY),
 DATE_ADD(CURDATE(), INTERVAL 74 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY),
 'BEGINNER', 'https://www.moe.gov.cn/', 30),
('全国大学生网络文化节',
 '面向大学生的网络文化作品征集，覆盖网文、摄影、短视频、公益广告',
 '综合', '["*"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 47 DAY),
 DATE_ADD(CURDATE(), INTERVAL 80 DAY), DATE_ADD(CURDATE(), INTERVAL 82 DAY),
 'BEGINNER', 'https://www.moe.gov.cn/', 30),
('全国大学生职业规划大赛',
 '教育部主办的职业生涯规划类赛事，与成长规划高度契合，各专业均可参加',
 '综合', '["*"]', '不限',
 DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY),
 DATE_ADD(CURDATE(), INTERVAL 72 DAY), DATE_ADD(CURDATE(), INTERVAL 74 DAY),
 'BEGINNER', 'https://www.moe.gov.cn/', 30),
('挑战杯全国大学生课外学术科技作品竞赛',
 '覆盖面最广的大学生学术科技竞赛，被称为大学生学术科技的奥林匹克',
 '综合', '["*"]', '不限',
 DATE_ADD(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 100 DAY),
 DATE_ADD(CURDATE(), INTERVAL 150 DAY), DATE_ADD(CURDATE(), INTERVAL 160 DAY),
 'INTERMEDIATE', 'https://www.tiaozhanbei.net/', 90)
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
