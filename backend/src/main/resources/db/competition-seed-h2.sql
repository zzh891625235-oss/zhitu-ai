-- ============================================================
-- 竞赛字典 · 专业对齐种子数据（H2 demo profile 专用）
--
-- 由 scripts/gen-competition-seed.py 从以下数据源生成：
--   1) backend/src/main/resources/db/data-h2.sql 里的 47 条竞赛（保留原有描述/日期/官网）
--   2) 新增赛事，补齐每个专业的对口赛事
--
-- 设计约束：
--   * suitable_major 里的专业名必须严格取自 database/majors.sql 的 175 个专业，
--     否则精确匹配永远命中不了，只能靠方向兜底，会出现"比赛与专业不对应"。
--   * 使用 MERGE ... KEY(name) 全量 upsert：重复执行幂等，且保留原有 id，
--     不会影响前端已加入计划的记录。
-- ============================================================

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('蓝桥杯全国软件和信息技术专业人才大赛',
 '工业和信息化部人才交流中心主办的全国性IT学科赛事，个人赛，适合作为第一个正式比赛',
 '算法编程', '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","数据科学与大数据技术","网络工程","信息安全","物联网工程","智能科学与技术","数字媒体技术","电子信息工程","通信工程"]', '不限',
 DATEADD('DAY', -15, CURRENT_DATE), DATEADD('DAY', 40, CURRENT_DATE),
 DATEADD('DAY', 80, CURRENT_DATE), DATEADD('DAY', 82, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.lanqiao.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国高校计算机大赛-团体程序设计天梯赛',
 '以团队为单位的程序设计能力竞赛，强调协作与基础功底',
 '算法编程', '["计算机科学与技术","软件工程","人工智能","网络工程","信息安全","物联网工程","数据科学与大数据技术","智能科学与技术","电子信息工程"]', '不限',
 DATEADD('DAY', -10, CURRENT_DATE), DATEADD('DAY', 25, CURRENT_DATE),
 DATEADD('DAY', 55, CURRENT_DATE), DATEADD('DAY', 55, CURRENT_DATE),
 'INTERMEDIATE', 'https://gplt.patest.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('ACM-ICPC 国际大学生程序设计竞赛',
 '全球最具影响力的大学生程序设计竞赛，三人一队，难度高、含金量高',
 '算法编程', '["计算机科学与技术","软件工程","人工智能","网络工程","信息安全","数据科学与大数据技术","智能科学与技术"]', '不限',
 DATEADD('DAY', 20, CURRENT_DATE), DATEADD('DAY', 50, CURRENT_DATE),
 DATEADD('DAY', 110, CURRENT_DATE), DATEADD('DAY', 140, CURRENT_DATE),
 'ADVANCED', 'https://icpc.global/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生计算机设计大赛',
 '教育部高等学校计算机类专业教学指导委员会主办的综合性赛事，适合有作品的同学',
 '综合', '["计算机科学与技术","软件工程","数字媒体技术","人工智能","数字媒体艺术","动画","教育技术学","广播电视编导","视觉传达设计"]', '不限',
 DATEADD('DAY', 5, CURRENT_DATE), DATEADD('DAY', 60, CURRENT_DATE),
 DATEADD('DAY', 100, CURRENT_DATE), DATEADD('DAY', 150, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.jsjds.com.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生数学建模竞赛',
 '全国规模最大的数学建模竞赛，三天三夜完成建模与论文，保研加分项',
 '数学建模', '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","数据科学与大数据技术","数学与应用数学","信息与计算科学","统计学","经济学","金融学","经济统计学","物理学"]', '大二及以上',
 DATEADD('DAY', 15, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 DATEADD('DAY', 95, CURRENT_DATE), DATEADD('DAY', 98, CURRENT_DATE),
 'ADVANCED', 'http://www.mcm.edu.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国国际大学生创新大赛（互联网+）',
 '教育部主办的创新创业大赛，适合有完整项目与商业计划的团队',
 '创新创业', '["计算机科学与技术","软件工程","人工智能","工商管理","市场营销","电子商务","信息管理与信息系统","经济学","金融学","机械工程","材料科学与工程","农学"]', '不限',
 DATEADD('DAY', 30, CURRENT_DATE), DATEADD('DAY', 90, CURRENT_DATE),
 DATEADD('DAY', 120, CURRENT_DATE), DATEADD('DAY', 200, CURRENT_DATE),
 'ADVANCED', 'https://cy.ncss.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('传智杯全国大学生IT技能大赛',
 '传智教育主办的IT技能竞赛，覆盖编程、Web、AI等方向，入门友好',
 '综合', '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","数据科学与大数据技术","网络工程","物联网工程","数字媒体技术","电子商务","信息管理与信息系统"]', '不限',
 DATEADD('DAY', -5, CURRENT_DATE), DATEADD('DAY', 30, CURRENT_DATE),
 DATEADD('DAY', 45, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 'BEGINNER', 'https://www.itcast.cn/', 30);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生电子设计竞赛',
 '电子信息类专业最具含金量的学科竞赛，四人一队，软硬件结合',
 '电子设计', '["电子信息工程","通信工程","自动化","物联网工程","电子科学与技术","微电子科学与工程","集成电路设计与集成系统","光电信息科学与工程","机器人工程","测控技术与仪器","计算机科学与技术"]', '大二及以上',
 DATEADD('DAY', 25, CURRENT_DATE), DATEADD('DAY', 85, CURRENT_DATE),
 DATEADD('DAY', 120, CURRENT_DATE), DATEADD('DAY', 125, CURRENT_DATE),
 'ADVANCED', 'https://nuedc.xjtu.edu.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('华为ICT大赛',
 '华为主办的ICT技术竞赛，含网络、云、计算赛道，对进大厂有实际帮助',
 '综合', '["计算机科学与技术","软件工程","通信工程","电子信息工程","网络工程","信息安全","物联网工程","大数据科学与技术","数据科学与大数据技术","集成电路设计与集成系统","自动化"]', '不限',
 DATEADD('DAY', -20, CURRENT_DATE), DATEADD('DAY', 35, CURRENT_DATE),
 DATEADD('DAY', 65, CURRENT_DATE), DATEADD('DAY', 90, CURRENT_DATE),
 'INTERMEDIATE', 'https://e.huawei.com/cn/talent/ict-competition', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生英语竞赛（NECCS）',
 '覆盖面最广的英语学科竞赛，对四六级和保研都有帮助',
 '英语', '["*"]', '不限',
 DATEADD('DAY', -30, CURRENT_DATE), DATEADD('DAY', 20, CURRENT_DATE),
 DATEADD('DAY', 50, CURRENT_DATE), DATEADD('DAY', 50, CURRENT_DATE),
 'BEGINNER', 'https://www.chinaneccs.cn/', 30);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生结构设计竞赛',
 '土木工程专业最高级别的学科竞赛，需制作结构模型并现场进行加载试验',
 '土木建筑', '["土木工程","建筑学","水利水电工程","工程管理","工程造价","风景园林"]', '大二及以上',
 DATEADD('DAY', 10, CURRENT_DATE), DATEADD('DAY', 55, CURRENT_DATE),
 DATEADD('DAY', 85, CURRENT_DATE), DATEADD('DAY', 88, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.structurecontest.com/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生先进成图技术与产品信息建模创新大赛',
 '工程制图与三维建模能力的国家级赛事，土木、建筑、机械专业通用',
 '土木建筑', '["土木工程","建筑学","城乡规划","机械工程","机械设计制造及其自动化","车辆工程","工业工程","测绘工程","机器人工程","风景园林"]', '不限',
 DATEADD('DAY', -8, CURRENT_DATE), DATEADD('DAY', 32, CURRENT_DATE),
 DATEADD('DAY', 62, CURRENT_DATE), DATEADD('DAY', 63, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.chengtudasai.com/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国周培源大学生力学竞赛',
 '力学基础能力的权威竞赛，土木、机械、水利类专业认可度高',
 '土木建筑', '["土木工程","机械工程","水利水电工程","航空航天工程","机械设计制造及其自动化","船舶与海洋工程","材料科学与工程","核工程与核技术"]', '大二及以上',
 DATEADD('DAY', 25, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 DATEADD('DAY', 115, CURRENT_DATE), DATEADD('DAY', 115, CURRENT_DATE),
 'ADVANCED', 'https://www.cstam.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生BIM应用技能大赛',
 '建筑信息模型（BIM）应用能力竞赛，偏实务，对土建类就业帮助直接',
 '土木建筑', '["土木工程","建筑学","城乡规划","工程管理","工程造价","风景园林","环境设计"]', '不限',
 DATEADD('DAY', -12, CURRENT_DATE), DATEADD('DAY', 28, CURRENT_DATE),
 DATEADD('DAY', 58, CURRENT_DATE), DATEADD('DAY', 59, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.bimcontest.com/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生机械创新设计大赛',
 '机械类最有影响力的学科竞赛，要求做出可运行的实物作品',
 '机械控制', '["机械工程","机械设计制造及其自动化","车辆工程","机器人工程","材料成型及控制工程","工业工程","材料科学与工程","自动化"]', '大二及以上',
 DATEADD('DAY', 20, CURRENT_DATE), DATEADD('DAY', 95, CURRENT_DATE),
 DATEADD('DAY', 140, CURRENT_DATE), DATEADD('DAY', 142, CURRENT_DATE),
 'ADVANCED', 'http://umic.ckcest.cn/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生智能汽车竞赛',
 '以智能车为载体，覆盖控制、传感、嵌入式与算法，自动化专业的经典赛事',
 '机械控制', '["自动化","电气工程及其自动化","测控技术与仪器","电子信息工程","车辆工程","机器人工程","计算机科学与技术","软件工程","人工智能","机械工程"]', '大二及以上',
 DATEADD('DAY', -5, CURRENT_DATE), DATEADD('DAY', 45, CURRENT_DATE),
 DATEADD('DAY', 100, CURRENT_DATE), DATEADD('DAY', 102, CURRENT_DATE),
 'ADVANCED', 'https://smartcarrace.com/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生工程实践与创新能力大赛',
 '面向工程实践与创新能力的综合赛事，含智能物流、飞行器、桥梁等赛项',
 '机械控制', '["机械工程","自动化","电气工程及其自动化","工业工程","土木工程","车辆工程","机器人工程","航空航天工程","船舶与海洋工程"]', '不限',
 DATEADD('DAY', 15, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 DATEADD('DAY', 110, CURRENT_DATE), DATEADD('DAY', 130, CURRENT_DATE),
 'ADVANCED', 'https://www.gcxl.edu.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生节能减排社会实践与科技竞赛',
 '面向能源、动力、环境类专业的科技竞赛，作品需体现节能减排效益',
 '机械控制', '["能源与动力工程","环境工程","电气工程及其自动化","化学工程与工艺","材料科学与工程","土木工程","核工程与核技术","安全工程"]', '不限',
 DATEADD('DAY', -18, CURRENT_DATE), DATEADD('DAY', 22, CURRENT_DATE),
 DATEADD('DAY', 52, CURRENT_DATE), DATEADD('DAY', 53, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.jienengjianpai.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生金相技能大赛',
 '材料类专业最基础的实践技能竞赛，考察试样制备与显微组织观察',
 '材料', '["材料科学与工程","材料成型及控制工程","机械工程","应用化学","化学工程与工艺"]', '不限',
 DATEADD('DAY', 12, CURRENT_DATE), DATEADD('DAY', 50, CURRENT_DATE),
 DATEADD('DAY', 75, CURRENT_DATE), DATEADD('DAY', 76, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.csm.org.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生化工设计竞赛',
 '化工类专业最具影响力的赛事，需完成整套工艺设计并进行经济分析',
 '化工设计', '["化学工程与工艺","制药工程","生物工程","应用化学","环境工程","安全工程","能源与动力工程"]', '大三及以上',
 DATEADD('DAY', 18, CURRENT_DATE), DATEADD('DAY', 88, CURRENT_DATE),
 DATEADD('DAY', 130, CURRENT_DATE), DATEADD('DAY', 135, CURRENT_DATE),
 'ADVANCED', 'https://www.chemsoc.org.cn/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生化学实验竞赛',
 '化学实验操作与实验设计能力的国家级赛事，理工科化学方向适用',
 '化工设计', '["化学","应用化学","化学工程与工艺","制药工程","材料科学与工程","生物工程","环境工程"]', '大三及以上',
 DATEADD('DAY', -14, CURRENT_DATE), DATEADD('DAY', 26, CURRENT_DATE),
 DATEADD('DAY', 56, CURRENT_DATE), DATEADD('DAY', 57, CURRENT_DATE),
 'ADVANCED', 'https://www.chemsoc.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生生命科学竞赛',
 '面向生物、生物工程、食品、医学等专业的科研类竞赛，需完整科研过程',
 '生命科学', '["生物科学","生物技术","生物工程","食品科学与工程","基础医学","农学","动物科学","药学","预防医学","生态学","水产养殖学"]', '不限',
 DATEADD('DAY', 8, CURRENT_DATE), DATEADD('DAY', 68, CURRENT_DATE),
 DATEADD('DAY', 105, CURRENT_DATE), DATEADD('DAY', 108, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.culsc.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生食品科技创新大赛',
 '食品类专业的创新创业赛事，作品需含实物产品或完整工艺方案',
 '食品轻工', '["食品科学与工程","生物工程","化学工程与工艺","生物技术","预防医学"]', '不限',
 DATEADD('DAY', -6, CURRENT_DATE), DATEADD('DAY', 34, CURRENT_DATE),
 DATEADD('DAY', 64, CURRENT_DATE), DATEADD('DAY', 65, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cifst.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生纺织类创新创业大赛',
 '纺织、轻化类专业的学科竞赛，覆盖材料、工艺与产品设计',
 '纺织设计', '["纺织工程","轻化工程","材料科学与工程","服装与服饰设计","产品设计"]', '不限',
 DATEADD('DAY', 16, CURRENT_DATE), DATEADD('DAY', 66, CURRENT_DATE),
 DATEADD('DAY', 96, CURRENT_DATE), DATEADD('DAY', 97, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.ctes.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生医学技术技能大赛',
 '教育部主办的医学类最高级别赛事，分临床、护理、药学、预防等赛道',
 '医学技能', '["临床医学","护理学","药学","预防医学","中医学","麻醉学","口腔医学","医学影像学","中西医临床医学","康复治疗学","医学检验技术","针灸推拿学"]', '大三及以上',
 DATEADD('DAY', 22, CURRENT_DATE), DATEADD('DAY', 92, CURRENT_DATE),
 DATEADD('DAY', 135, CURRENT_DATE), DATEADD('DAY', 138, CURRENT_DATE),
 'ADVANCED', 'https://www.moe.gov.cn/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生基础医学创新研究暨实验设计论坛',
 '基础医学与实验设计类竞赛，适合有科研经历、准备保研的同学',
 '医学技能', '["基础医学","临床医学","预防医学","医学检验技术","法医学","口腔医学","麻醉学","中西医临床医学","药学","中医学"]', '不限',
 DATEADD('DAY', -10, CURRENT_DATE), DATEADD('DAY', 40, CURRENT_DATE),
 DATEADD('DAY', 70, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cma.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生药苑论坛',
 '药学类专业的学术与创新竞赛，含论文、实验与成果展示环节',
 '药学', '["药学","中药学","制药工程","生物工程","化学工程与工艺","临床医学"]', '大三及以上',
 DATEADD('DAY', 14, CURRENT_DATE), DATEADD('DAY', 56, CURRENT_DATE),
 DATEADD('DAY', 86, CURRENT_DATE), DATEADD('DAY', 88, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cpa.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生动物医学专业技能大赛',
 '动物医学与动物科学专业的操作技能赛事，考察临床与防疫基本功',
 '农林', '["动物医学","动物科学","水产养殖学","生物科学"]', '大三及以上',
 DATEADD('DAY', 9, CURRENT_DATE), DATEADD('DAY', 49, CURRENT_DATE),
 DATEADD('DAY', 79, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.caav.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生植物生产类实践技能竞赛',
 '农学、园艺、植物保护类专业的实践技能赛事，田间与实验室结合',
 '农林', '["农学","园艺","植物保护","茶学","烟草","林学","园林","草业科学"]', '不限',
 DATEADD('DAY', -7, CURRENT_DATE), DATEADD('DAY', 38, CURRENT_DATE),
 DATEADD('DAY', 68, CURRENT_DATE), DATEADD('DAY', 69, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.caass.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生市场调查与分析大赛',
 '经管类专业最主流的学科竞赛，含调研报告、数据分析与现场答辩',
 '经管实务', '["市场营销","工商管理","会计学","财务管理","统计学","经济统计学","经济学","人力资源管理","电子商务","信息管理与信息系统","公共管理","国际经济与贸易","社会学"]', '不限',
 DATEADD('DAY', -20, CURRENT_DATE), DATEADD('DAY', 20, CURRENT_DATE),
 DATEADD('DAY', 50, CURRENT_DATE), DATEADD('DAY', 52, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.china-csm.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生物流设计大赛',
 '物流管理专业最高规格赛事，以企业真实案例命题，作品需可落地',
 '经管实务', '["物流管理","供应链管理","交通运输","电子商务","工业工程","交通工程","信息管理与信息系统"]', '大二及以上',
 DATEADD('DAY', 24, CURRENT_DATE), DATEADD('DAY', 84, CURRENT_DATE),
 DATEADD('DAY', 120, CURRENT_DATE), DATEADD('DAY', 122, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.chinawuliu.com.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中金所杯全国大学生金融知识大赛',
 '金融类专业的知识型竞赛，覆盖金融衍生品、投资实务与风险管理',
 '经管实务', '["金融学","金融工程","投资学","保险学","经济学","经济统计学","财务管理","会计学","数学与应用数学","统计学"]', '不限',
 DATEADD('DAY', -4, CURRENT_DATE), DATEADD('DAY', 36, CURRENT_DATE),
 DATEADD('DAY', 66, CURRENT_DATE), DATEADD('DAY', 66, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.cffex.com.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生会计信息化技能大赛',
 '会计与财务类专业的信息化实务竞赛，考察财务软件与业财融合能力',
 '经管实务', '["会计学","财务管理","税收学","工商管理","财政学","国民经济管理"]', '不限',
 DATEADD('DAY', 6, CURRENT_DATE), DATEADD('DAY', 42, CURRENT_DATE),
 DATEADD('DAY', 66, CURRENT_DATE), DATEADD('DAY', 67, CURRENT_DATE),
 'BEGINNER', 'https://www.yonyou.com/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生模拟法庭竞赛',
 '法学专业最典型的实践竞赛，以模拟庭审形式考察法律职业能力',
 '法学', '["法学","知识产权","监狱学","政治学与行政学","社会学","社会工作"]', '大二及以上',
 DATEADD('DAY', 13, CURRENT_DATE), DATEADD('DAY', 58, CURRENT_DATE),
 DATEADD('DAY', 90, CURRENT_DATE), DATEADD('DAY', 92, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.moj.gov.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国学生学宪法讲宪法活动',
 '面向全国学生的宪法学习与演讲活动，法学与思政类专业友好',
 '法学', '["法学","知识产权","思想政治教育","政治学与行政学","行政管理","国际政治","社会学"]', '不限',
 DATEADD('DAY', -16, CURRENT_DATE), DATEADD('DAY', 18, CURRENT_DATE),
 DATEADD('DAY', 44, CURRENT_DATE), DATEADD('DAY', 44, CURRENT_DATE),
 'BEGINNER', 'https://www.moe.gov.cn/', 30);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('田家炳杯全国师范院校师范生教学技能竞赛',
 '师范类专业最高规格的教学技能竞赛，含说课、板书与教学设计',
 '师范技能', '["教育学","学前教育","小学教育","特殊教育","体育教育","汉语言文学","数学与应用数学","英语","汉语言","物理学","化学","历史学","思想政治教育","地理科学","生物科学"]', '大三及以上',
 DATEADD('DAY', 17, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 DATEADD('DAY', 108, CURRENT_DATE), DATEADD('DAY', 110, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.moe.gov.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生广告艺术大赛',
 '广告、设计、新闻传播类专业的主流赛事，覆盖面广、获奖机会多',
 '艺术设计', '["广告学","视觉传达设计","数字媒体艺术","传播学","广播电视学","网络与新媒体","动画","产品设计","环境设计","摄影","广播电视编导","新闻学"]', '不限',
 DATEADD('DAY', -9, CURRENT_DATE), DATEADD('DAY', 36, CURRENT_DATE),
 DATEADD('DAY', 70, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.sun-ada.net/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生工业设计大赛',
 '产品设计、工业设计类国家级赛事，注重作品的落地性与可用性',
 '艺术设计', '["产品设计","视觉传达设计","环境设计","工业工程","机械工程","数字媒体艺术","动画"]', '不限',
 DATEADD('DAY', 11, CURRENT_DATE), DATEADD('DAY', 61, CURRENT_DATE),
 DATEADD('DAY', 95, CURRENT_DATE), DATEADD('DAY', 96, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cuidc.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生艺术展演',
 '教育部主办的综合性艺术展演，覆盖音乐、美术、舞蹈、戏剧等门类',
 '艺术设计', '["音乐学","音乐表演","美术学","绘画","雕塑","播音与主持艺术","戏剧影视文学","广播电视编导","动画"]', '不限',
 DATEADD('DAY', 28, CURRENT_DATE), DATEADD('DAY', 98, CURRENT_DATE),
 DATEADD('DAY', 150, CURRENT_DATE), DATEADD('DAY', 160, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.moe.gov.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生数学竞赛',
 '面向本科生的数学基础能力竞赛，分数学类与非数学类，各专业均可参加',
 '理科基础', '["*"]', '不限',
 DATEADD('DAY', -11, CURRENT_DATE), DATEADD('DAY', 29, CURRENT_DATE),
 DATEADD('DAY', 60, CURRENT_DATE), DATEADD('DAY', 60, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.cmathc.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生物理学术竞赛',
 '物理类专业最具代表性的学术竞赛，以开放性物理问题的辩论形式进行',
 '理科基础', '["物理学","应用物理学","材料科学与工程","电子信息工程","光电信息科学与工程","核工程与核技术"]', '大二及以上',
 DATEADD('DAY', 21, CURRENT_DATE), DATEADD('DAY', 91, CURRENT_DATE),
 DATEADD('DAY', 130, CURRENT_DATE), DATEADD('DAY', 133, CURRENT_DATE),
 'ADVANCED', 'https://www.cps.org.cn/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生统计建模大赛',
 '统计学类专业赛事，围绕真实数据完成建模与研究报告撰写',
 '理科基础', '["统计学","经济统计学","数学与应用数学","应用化学","经济学","金融学","保险学","大数据科学与技术","数据科学与大数据技术","信息与计算科学"]', '不限',
 DATEADD('DAY', 7, CURRENT_DATE), DATEADD('DAY', 52, CURRENT_DATE),
 DATEADD('DAY', 88, CURRENT_DATE), DATEADD('DAY', 90, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.china-csm.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('外研社杯全国大学生英语挑战赛',
 '英语类专业主流赛事，含演讲、写作、阅读三项，认可度高',
 '英语', '["英语","翻译","汉语国际教育","*"]', '不限',
 DATEADD('DAY', -13, CURRENT_DATE), DATEADD('DAY', 27, CURRENT_DATE),
 DATEADD('DAY', 57, CURRENT_DATE), DATEADD('DAY', 58, CURRENT_DATE),
 'INTERMEDIATE', 'https://uchallenge.unipus.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中华经典诵写讲大赛',
 '面向高校师生的经典诵读、讲解与书写大赛，人文类专业友好',
 '人文', '["汉语言文学","汉语言","汉语国际教育","历史学","哲学","思想政治教育","文物与博物馆学","*"]', '不限',
 DATEADD('DAY', 9, CURRENT_DATE), DATEADD('DAY', 44, CURRENT_DATE),
 DATEADD('DAY', 74, CURRENT_DATE), DATEADD('DAY', 75, CURRENT_DATE),
 'BEGINNER', 'https://www.moe.gov.cn/', 30);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生网络文化节',
 '面向大学生的网络文化作品征集，覆盖网文、摄影、短视频、公益广告',
 '综合', '["*"]', '不限',
 DATEADD('DAY', -3, CURRENT_DATE), DATEADD('DAY', 47, CURRENT_DATE),
 DATEADD('DAY', 80, CURRENT_DATE), DATEADD('DAY', 82, CURRENT_DATE),
 'BEGINNER', 'https://www.moe.gov.cn/', 30);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生职业规划大赛',
 '教育部主办的职业生涯规划类赛事，与成长规划高度契合，各专业均可参加',
 '综合', '["*"]', '不限',
 DATEADD('DAY', -2, CURRENT_DATE), DATEADD('DAY', 38, CURRENT_DATE),
 DATEADD('DAY', 72, CURRENT_DATE), DATEADD('DAY', 74, CURRENT_DATE),
 'BEGINNER', 'https://www.moe.gov.cn/', 30);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('挑战杯全国大学生课外学术科技作品竞赛',
 '覆盖面最广的大学生学术科技竞赛，被称为大学生学术科技的奥林匹克',
 '综合', '["*"]', '不限',
 DATEADD('DAY', 30, CURRENT_DATE), DATEADD('DAY', 100, CURRENT_DATE),
 DATEADD('DAY', 150, CURRENT_DATE), DATEADD('DAY', 160, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.tiaozhanbei.net/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生信息安全竞赛',
 '信息安全领域最具权威的学科竞赛，含作品赛与创新实践能力赛，考察攻防与安全开发',
 '信息安全', '["信息安全","网络工程","计算机科学与技术","软件工程","物联网工程","通信工程"]', '不限',
 DATEADD('DAY', -6, CURRENT_DATE), DATEADD('DAY', 46, CURRENT_DATE),
 DATEADD('DAY', 78, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 'ADVANCED', 'http://www.ciscn.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生集成电路创新创业大赛',
 '集成电路领域规模最大的赛事，覆盖设计、制造、封测与应用全链条',
 '电子设计', '["集成电路设计与集成系统","微电子科学与工程","电子科学与技术","电子信息工程","光电信息科学与工程","自动化"]', '大二及以上',
 DATEADD('DAY', 13, CURRENT_DATE), DATEADD('DAY', 63, CURRENT_DATE),
 DATEADD('DAY', 100, CURRENT_DATE), DATEADD('DAY', 102, CURRENT_DATE),
 'ADVANCED', 'https://univ.ciciec.com/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生光电设计竞赛',
 '光电类专业的代表性赛事，需完成光电系统设计与实物制作',
 '电子设计', '["光电信息科学与工程","电子科学与技术","应用物理学","物理学","测控技术与仪器","电子信息工程"]', '大二及以上',
 DATEADD('DAY', -9, CURRENT_DATE), DATEADD('DAY', 41, CURRENT_DATE),
 DATEADD('DAY', 75, CURRENT_DATE), DATEADD('DAY', 77, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.gdjyc.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生智能技术应用大赛',
 '面向智能科学与技术的应用型竞赛，涵盖机器学习、机器人、智能系统等方向',
 '人工智能', '["智能科学与技术","人工智能","机器人工程","自动化","计算机科学与技术","数据科学与大数据技术"]', '不限',
 DATEADD('DAY', 8, CURRENT_DATE), DATEADD('DAY', 53, CURRENT_DATE),
 DATEADD('DAY', 86, CURRENT_DATE), DATEADD('DAY', 88, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.caai.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生服务外包创新创业大赛',
 '教育部等主办的创新创业赛事，以企业真实命题为主，看重落地与工程能力',
 '创新创业', '["数据科学与大数据技术","大数据科学与技术","软件工程","信息管理与信息系统","电子商务","计算机科学与技术"]', '不限',
 DATEADD('DAY', -16, CURRENT_DATE), DATEADD('DAY', 34, CURRENT_DATE),
 DATEADD('DAY', 66, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.fwwb.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生飞行器设计创新大赛',
 '航空航天类专业的核心赛事，需完成飞行器设计、制作与飞行验证',
 '航空航天', '["航空航天工程","飞行器设计与工程","飞行器动力工程","机械设计制造及其自动化","自动化"]', '大二及以上',
 DATEADD('DAY', 19, CURRENT_DATE), DATEADD('DAY', 89, CURRENT_DATE),
 DATEADD('DAY', 130, CURRENT_DATE), DATEADD('DAY', 133, CURRENT_DATE),
 'ADVANCED', 'https://www.csaa.org.cn/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生船舶与海洋工程设计大赛',
 '船舶与海洋工程领域的专业赛事，围绕船型设计与海洋结构物展开',
 '机械控制', '["船舶与海洋工程","海洋科学","机械工程","水利水电工程","材料科学与工程"]', '大二及以上',
 DATEADD('DAY', 11, CURRENT_DATE), DATEADD('DAY', 61, CURRENT_DATE),
 DATEADD('DAY', 96, CURRENT_DATE), DATEADD('DAY', 98, CURRENT_DATE),
 'ADVANCED', 'https://www.csy.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生交通科技大赛',
 '交通运输类专业最高规格赛事，围绕交通规划、安全与智能交通选题',
 '土木建筑', '["交通工程","交通运输","土木工程","城乡规划","物流管理","测绘工程"]', '不限',
 DATEADD('DAY', -7, CURRENT_DATE), DATEADD('DAY', 43, CURRENT_DATE),
 DATEADD('DAY', 76, CURRENT_DATE), DATEADD('DAY', 78, CURRENT_DATE),
 'INTERMEDIATE', 'http://www.nactrans.com.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生核科技竞赛',
 '核工程与核技术方向的专业竞赛，涵盖反应堆物理、辐射防护与核安全',
 '能源核工', '["核工程与核技术","能源与动力工程","物理学","材料科学与工程","安全工程"]', '大三及以上',
 DATEADD('DAY', 26, CURRENT_DATE), DATEADD('DAY', 86, CURRENT_DATE),
 DATEADD('DAY', 128, CURRENT_DATE), DATEADD('DAY', 130, CURRENT_DATE),
 'ADVANCED', 'https://www.cns.org.cn/', 120);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生安全科学与工程实践创新大赛',
 '安全工程专业的实践类竞赛，围绕风险评估、应急管理与安全设计展开',
 '机械控制', '["安全工程","环境工程","化学工程与工艺","土木工程","工业工程"]', '不限',
 DATEADD('DAY', 6, CURRENT_DATE), DATEADD('DAY', 51, CURRENT_DATE),
 DATEADD('DAY', 84, CURRENT_DATE), DATEADD('DAY', 86, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.china-safety.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生城市设计竞赛',
 '城乡规划与建筑类专业的重要赛事，以真实地块为命题完成城市设计方案',
 '土木建筑', '["城乡规划","建筑学","风景园林","环境设计","园林"]', '大三及以上',
 DATEADD('DAY', -11, CURRENT_DATE), DATEADD('DAY', 39, CURRENT_DATE),
 DATEADD('DAY', 72, CURRENT_DATE), DATEADD('DAY', 75, CURRENT_DATE),
 'ADVANCED', 'https://www.planning.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生测绘地理信息创新创业大赛',
 '测绘与地理信息类的专业赛事，涵盖测量、遥感、GIS 开发等方向',
 '土木建筑', '["测绘工程","地理科学","土木工程","土地资源管理","地质学","城乡规划"]', '不限',
 DATEADD('DAY', 14, CURRENT_DATE), DATEADD('DAY', 64, CURRENT_DATE),
 DATEADD('DAY', 98, CURRENT_DATE), DATEADD('DAY', 100, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.csgpc.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生材料热处理创新创业大赛',
 '材料类专业的行业赛事，围绕热处理工艺与材料性能展开',
 '材料', '["材料科学与工程","材料成型及控制工程","机械工程","化学工程与工艺","应用化学"]', '大二及以上',
 DATEADD('DAY', -13, CURRENT_DATE), DATEADD('DAY', 37, CURRENT_DATE),
 DATEADD('DAY', 70, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.chts.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生纱线设计大赛',
 '纺织工程专业的特色赛事，考察纱线结构与纺纱工艺的设计能力',
 '纺织设计', '["纺织工程","轻化工程","服装与服饰设计","材料科学与工程"]', '不限',
 DATEADD('DAY', 9, CURRENT_DATE), DATEADD('DAY', 54, CURRENT_DATE),
 DATEADD('DAY', 88, CURRENT_DATE), DATEADD('DAY', 90, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.ctes.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生非织造材料开发与应用大赛',
 '非织造材料方向的行业赛事，覆盖材料开发、工艺设计与终端应用',
 '纺织设计', '["纺织工程","轻化工程","材料科学与工程","化学工程与工艺"]', '大二及以上',
 DATEADD('DAY', -4, CURRENT_DATE), DATEADD('DAY', 44, CURRENT_DATE),
 DATEADD('DAY', 78, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cnia.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生食品工程虚拟仿真大赛',
 '食品工程原理的仿真操作竞赛，考察工艺计算与单元操作能力',
 '食品轻工', '["食品科学与工程","生物工程","化学工程与工艺","生物技术"]', '不限',
 DATEADD('DAY', 17, CURRENT_DATE), DATEADD('DAY', 67, CURRENT_DATE),
 DATEADD('DAY', 100, CURRENT_DATE), DATEADD('DAY', 102, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cifst.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国护理专业本科临床技能大赛',
 '护理学专业最高规格的技能竞赛，覆盖基础护理与专科护理操作',
 '医学技能', '["护理学","康复治疗学","临床医学","麻醉学"]', '大三及以上',
 DATEADD('DAY', -8, CURRENT_DATE), DATEADD('DAY', 42, CURRENT_DATE),
 DATEADD('DAY', 76, CURRENT_DATE), DATEADD('DAY', 79, CURRENT_DATE),
 'ADVANCED', 'https://www.cna-cast.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生医学影像技术实践技能大赛',
 '医学影像技术方向的实践技能竞赛，考察影像检查与设备操作规范',
 '医学技能', '["医学影像学","医学检验技术","临床医学","生物工程"]', '大三及以上',
 DATEADD('DAY', 12, CURRENT_DATE), DATEADD('DAY', 62, CURRENT_DATE),
 DATEADD('DAY', 95, CURRENT_DATE), DATEADD('DAY', 97, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cma.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生口腔医学技能大赛',
 '口腔医学专业的临床技能竞赛，含口腔内科、外科与修复操作考核',
 '医学技能', '["口腔医学","临床医学"]', '大三及以上',
 DATEADD('DAY', 5, CURRENT_DATE), DATEADD('DAY', 55, CURRENT_DATE),
 DATEADD('DAY', 90, CURRENT_DATE), DATEADD('DAY', 92, CURRENT_DATE),
 'ADVANCED', 'https://www.cndent.com/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生中医药创新创业大赛',
 '中医药方向的创新创业赛事，涵盖中药研发、中医诊疗与健康产品',
 '药学', '["中医学","中药学","针灸推拿学","中西医临床医学","药学","制药工程"]', '不限',
 DATEADD('DAY', -15, CURRENT_DATE), DATEADD('DAY', 35, CURRENT_DATE),
 DATEADD('DAY', 68, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.catcm.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生茶艺技能大赛',
 '茶学专业的特色技能竞赛，考察茶艺展示、茶叶审评与茶文化传播',
 '农林', '["茶学","园艺","农学","食品科学与工程"]', '不限',
 DATEADD('DAY', 10, CURRENT_DATE), DATEADD('DAY', 58, CURRENT_DATE),
 DATEADD('DAY', 90, CURRENT_DATE), DATEADD('DAY', 92, CURRENT_DATE),
 'BEGINNER', 'https://www.caass.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生草学技能大赛',
 '草业科学专业的实践技能竞赛，覆盖草地资源、牧草育种与生态修复',
 '农林', '["草业科学","农学","园艺","林学","生态学"]', '大二及以上',
 DATEADD('DAY', -6, CURRENT_DATE), DATEADD('DAY', 40, CURRENT_DATE),
 DATEADD('DAY', 74, CURRENT_DATE), DATEADD('DAY', 76, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.caass.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生林学专业技能大赛',
 '林学与园林类专业的实践竞赛，考察森林调查、苗木识别与园林设计',
 '农林', '["林学","园林","生态学","植物保护","风景园林","地理科学"]', '不限',
 DATEADD('DAY', 21, CURRENT_DATE), DATEADD('DAY', 76, CURRENT_DATE),
 DATEADD('DAY', 112, CURRENT_DATE), DATEADD('DAY', 115, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.csf.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生乡村振兴创意大赛',
 '面向乡村振兴的综合性赛事，农学、规划、经管、设计类专业均可参与',
 '综合', '["农学","园艺","植物保护","林学","园林","动物科学","水产养殖学","茶学","烟草","草业科学","城乡规划","电子商务","旅游管理"]', '不限',
 DATEADD('DAY', -18, CURRENT_DATE), DATEADD('DAY', 32, CURRENT_DATE),
 DATEADD('DAY', 66, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 'BEGINNER', 'https://www.moe.gov.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生动物科学专业技能大赛',
 '动物科学专业的技能竞赛，覆盖饲料配方、繁殖技术与养殖管理',
 '农林', '["动物科学","动物医学","水产养殖学","生物科学"]', '大二及以上',
 DATEADD('DAY', 9, CURRENT_DATE), DATEADD('DAY', 57, CURRENT_DATE),
 DATEADD('DAY', 90, CURRENT_DATE), DATEADD('DAY', 92, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.caav.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生水产技能大赛',
 '水产养殖学专业的技能竞赛，考察水质检测、鱼病诊断与养殖操作',
 '农林', '["水产养殖学","动物科学","海洋科学","生物科学","环境工程"]', '不限',
 DATEADD('DAY', -10, CURRENT_DATE), DATEADD('DAY', 36, CURRENT_DATE),
 DATEADD('DAY', 70, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.csfish.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生法律职业能力大赛',
 '法学专业的综合能力竞赛，含法律文书写作、案例分析与会展辩论',
 '法学', '["法学","知识产权","监狱学","政治学与行政学","社会学"]', '大二及以上',
 DATEADD('DAY', 15, CURRENT_DATE), DATEADD('DAY', 65, CURRENT_DATE),
 DATEADD('DAY', 98, CURRENT_DATE), DATEADD('DAY', 100, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.chinalaw.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生环境资源模拟法庭大赛',
 '以环境资源案件为命题的模拟法庭赛事，法学与环境类专业交叉参赛',
 '法学', '["法学","知识产权","环境工程","行政管理"]', '大三及以上',
 DATEADD('DAY', -12, CURRENT_DATE), DATEADD('DAY', 38, CURRENT_DATE),
 DATEADD('DAY', 72, CURRENT_DATE), DATEADD('DAY', 74, CURRENT_DATE),
 'ADVANCED', 'https://www.chinalaw.org.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国高校模拟集体谈判大赛',
 '劳动关系领域的实践赛事，模拟集体协商与谈判，经管与法学专业通用',
 '法学', '["劳动与社会保障","社会工作","法学","人力资源管理","公共管理","行政管理"]', '不限',
 DATEADD('DAY', 7, CURRENT_DATE), DATEADD('DAY', 52, CURRENT_DATE),
 DATEADD('DAY', 86, CURRENT_DATE), DATEADD('DAY', 88, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.mohrss.gov.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生社会调查方法大赛',
 '社会学与公共管理类的实证赛事，要求完成完整的社会调查与报告',
 '经管实务', '["社会学","社会工作","行政管理","公共管理","统计学","市场营销","新闻学"]', '不限',
 DATEADD('DAY', -5, CURRENT_DATE), DATEADD('DAY', 45, CURRENT_DATE),
 DATEADD('DAY', 78, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.china-csm.org/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国学前教育专业学生教育技能大赛',
 '学前教育专业的教学技能竞赛，含活动设计、弹唱跳画与说课',
 '师范技能', '["学前教育","特殊教育","小学教育","教育学"]', '大二及以上',
 DATEADD('DAY', 16, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 DATEADD('DAY', 104, CURRENT_DATE), DATEADD('DAY', 107, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.moe.gov.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国高校体育教育专业学生基本功大赛',
 '体育教育专业的基本功竞赛，考察运动技能、教学设计与体能',
 '师范技能', '["体育教育","运动训练","社会体育指导与管理"]', '大三及以上',
 DATEADD('DAY', -14, CURRENT_DATE), DATEADD('DAY', 36, CURRENT_DATE),
 DATEADD('DAY', 70, CURRENT_DATE), DATEADD('DAY', 73, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.moe.gov.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('iTeach全国大学生数字化教育应用创新大赛',
 '教育技术方向的创新赛事，聚焦数字化教学资源与教育产品设计',
 '师范技能', '["教育技术学","教育学","小学教育","学前教育","汉语言文学","计算机科学与技术"]', '不限',
 DATEADD('DAY', 4, CURRENT_DATE), DATEADD('DAY', 49, CURRENT_DATE),
 DATEADD('DAY', 82, CURRENT_DATE), DATEADD('DAY', 84, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.iteach.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国高校心理学专业本科生创新创业论坛',
 '心理学专业的学术与创新交流平台，含论文、实践项目与创业方案',
 '理科基础', '["心理学","教育学","社会工作"]', '不限',
 DATEADD('DAY', -9, CURRENT_DATE), DATEADD('DAY', 41, CURRENT_DATE),
 DATEADD('DAY', 75, CURRENT_DATE), DATEADD('DAY', 77, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cpsbeijing.org/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生人力资源管理知识技能竞赛',
 '人力资源管理专业的实务竞赛，模拟招聘、绩效与薪酬方案设计',
 '经管实务', '["人力资源管理","工商管理","公共管理","劳动与社会保障","行政管理"]', '不限',
 DATEADD('DAY', 11, CURRENT_DATE), DATEADD('DAY', 59, CURRENT_DATE),
 DATEADD('DAY', 92, CURRENT_DATE), DATEADD('DAY', 94, CURRENT_DATE),
 'BEGINNER', 'https://www.chrm.org.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生旅游策划大赛',
 '旅游管理类专业的策划赛事，围绕目的地营销与文旅产品设计',
 '经管实务', '["旅游管理","酒店管理","会展经济与管理","市场营销","公共管理"]', '不限',
 DATEADD('DAY', -3, CURRENT_DATE), DATEADD('DAY', 47, CURRENT_DATE),
 DATEADD('DAY', 80, CURRENT_DATE), DATEADD('DAY', 82, CURRENT_DATE),
 'BEGINNER', 'https://www.cnta.gov.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生国际贸易技能大赛',
 '国际经济与贸易专业的实务竞赛，模拟外贸业务流程与商务谈判',
 '经管实务', '["国际经济与贸易","经济学","财政学","税收学","英语"]', '不限',
 DATEADD('DAY', 13, CURRENT_DATE), DATEADD('DAY', 63, CURRENT_DATE),
 DATEADD('DAY', 96, CURRENT_DATE), DATEADD('DAY', 98, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.ccpit.org/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生资产评估知识竞赛',
 '财政与资产评估方向的竞赛，考察估值方法与实务案例分析',
 '经管实务', '["财政学","税收学","财务管理","投资学","国民经济管理","工程管理","会计学"]', '大二及以上',
 DATEADD('DAY', -17, CURRENT_DATE), DATEADD('DAY', 33, CURRENT_DATE),
 DATEADD('DAY', 66, CURRENT_DATE), DATEADD('DAY', 68, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cas.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生电子商务创新创意及创业挑战赛',
 '电子商务领域的三创赛，覆盖商业模式、平台运营与技术实现',
 '经管实务', '["电子商务","市场营销","信息管理与信息系统","计算机科学与技术","工商管理","物流管理"]', '不限',
 DATEADD('DAY', 8, CURRENT_DATE), DATEADD('DAY', 58, CURRENT_DATE),
 DATEADD('DAY', 92, CURRENT_DATE), DATEADD('DAY', 95, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.ec.gov.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生土地资源管理技能大赛',
 '土地资源管理专业的实务竞赛，涵盖国土调查、规划与估价',
 '经管实务', '["土地资源管理","测绘工程","地理科学","城乡规划","公共管理","工程管理"]', '不限',
 DATEADD('DAY', -8, CURRENT_DATE), DATEADD('DAY', 38, CURRENT_DATE),
 DATEADD('DAY', 72, CURRENT_DATE), DATEADD('DAY', 74, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.mnr.gov.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('多语种全国口译大赛',
 '覆盖英日俄德法西朝等语种的口译赛事，外语类专业均可参加',
 '英语', '["英语","翻译","俄语","日语","德语","法语","西班牙语","朝鲜语","汉语国际教育"]', '不限',
 DATEADD('DAY', 18, CURRENT_DATE), DATEADD('DAY', 68, CURRENT_DATE),
 DATEADD('DAY', 102, CURRENT_DATE), DATEADD('DAY', 104, CURRENT_DATE),
 'ADVANCED', 'https://www.tac-online.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生新媒体创意大赛',
 '新闻传播类专业的作品赛事，覆盖短视频、图文、H5 与数据新闻',
 '艺术设计', '["新闻学","传播学","网络与新媒体","广播电视学","编辑出版学","广告学","汉语言文学"]', '不限',
 DATEADD('DAY', -11, CURRENT_DATE), DATEADD('DAY', 39, CURRENT_DATE),
 DATEADD('DAY', 72, CURRENT_DATE), DATEADD('DAY', 74, CURRENT_DATE),
 'BEGINNER', 'https://www.moe.gov.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生历史学论坛',
 '历史学类的学术交流与论文竞赛，覆盖中国史、世界史与考古方向',
 '人文', '["历史学","世界史","考古学","文物与博物馆学","哲学","汉语言文学"]', '不限',
 DATEADD('DAY', 12, CURRENT_DATE), DATEADD('DAY', 62, CURRENT_DATE),
 DATEADD('DAY', 96, CURRENT_DATE), DATEADD('DAY', 98, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cssn.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生哲学论坛',
 '哲学类学术论文与思辨竞赛，哲学、逻辑学、伦理学等专业适用',
 '人文', '["哲学","逻辑学","宗教学","伦理学","思想政治教育","汉语言文学"]', '不限',
 DATEADD('DAY', -6, CURRENT_DATE), DATEADD('DAY', 44, CURRENT_DATE),
 DATEADD('DAY', 78, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cssn.cn/', 75);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生摄影大赛',
 '摄影与影像类专业的作品赛事，覆盖纪实、商业与艺术摄影',
 '艺术设计', '["摄影","数字媒体艺术","视觉传达设计","广播电视编导","动画"]', '不限',
 DATEADD('DAY', 7, CURRENT_DATE), DATEADD('DAY', 54, CURRENT_DATE),
 DATEADD('DAY', 88, CURRENT_DATE), DATEADD('DAY', 90, CURRENT_DATE),
 'BEGINNER', 'https://www.cpanet.org.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国大学生动漫创意大赛',
 '动画与数字媒体类的创作赛事，覆盖动画短片、漫画与游戏美术',
 '艺术设计', '["动画","数字媒体艺术","视觉传达设计","戏剧影视文学","广播电视编导"]', '不限',
 DATEADD('DAY', -13, CURRENT_DATE), DATEADD('DAY', 37, CURRENT_DATE),
 DATEADD('DAY', 70, CURRENT_DATE), DATEADD('DAY', 72, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.caanet.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('中国国际大学生时装周',
 '服装与服饰设计专业的发布与竞赛平台，含毕业设计作品专场',
 '艺术设计', '["服装与服饰设计","产品设计","纺织工程","视觉传达设计"]', '大三及以上',
 DATEADD('DAY', 23, CURRENT_DATE), DATEADD('DAY', 83, CURRENT_DATE),
 DATEADD('DAY', 126, CURRENT_DATE), DATEADD('DAY', 130, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.chinafashionweek.org/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生戏剧节',
 '戏剧影视类的展演与竞赛，覆盖话剧、短片与播音主持作品',
 '艺术设计', '["戏剧影视文学","广播电视编导","播音与主持艺术","音乐表演","音乐学"]', '不限',
 DATEADD('DAY', -9, CURRENT_DATE), DATEADD('DAY', 41, CURRENT_DATE),
 DATEADD('DAY', 76, CURRENT_DATE), DATEADD('DAY', 80, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.chinatheatre.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生天文创新作品竞赛',
 '天文方向的创新作品竞赛，含观测、科普与数据处理作品',
 '理科基础', '["天文学","物理学","应用物理学","光电信息科学与工程"]', '不限',
 DATEADD('DAY', 10, CURRENT_DATE), DATEADD('DAY', 60, CURRENT_DATE),
 DATEADD('DAY', 94, CURRENT_DATE), DATEADD('DAY', 96, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cas.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生海洋知识竞赛',
 '海洋科学方向的科普与知识竞赛，海洋、生物、地质类专业通用',
 '理科基础', '["海洋科学","水产养殖学","生物科学","地质学","环境工程"]', '不限',
 DATEADD('DAY', -15, CURRENT_DATE), DATEADD('DAY', 35, CURRENT_DATE),
 DATEADD('DAY', 68, CURRENT_DATE), DATEADD('DAY', 70, CURRENT_DATE),
 'BEGINNER', 'https://www.soa.gov.cn/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生地质技能竞赛',
 '地质类专业的实践技能竞赛，考察野外地质、岩矿鉴定与地质填图',
 '理科基础', '["地质学","地球物理学","地理科学","测绘工程","土木工程"]', '大二及以上',
 DATEADD('DAY', 14, CURRENT_DATE), DATEADD('DAY', 64, CURRENT_DATE),
 DATEADD('DAY', 98, CURRENT_DATE), DATEADD('DAY', 101, CURRENT_DATE),
 'ADVANCED', 'https://www.geosociety.org.cn/', 90);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生气象科普作品大赛',
 '大气科学方向的科普创作竞赛，涵盖科普文章、短视频与可视化作品',
 '理科基础', '["大气科学","地理科学","应用物理学","生态学","物理学"]', '不限',
 DATEADD('DAY', -4, CURRENT_DATE), DATEADD('DAY', 46, CURRENT_DATE),
 DATEADD('DAY', 79, CURRENT_DATE), DATEADD('DAY', 81, CURRENT_DATE),
 'BEGINNER', 'https://www.cms1924.org/', 45);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生生物化学实验技能大赛',
 '生物类专业的实验技能竞赛，考察生化分离、分析与检测操作',
 '生命科学', '["生物科学","生物技术","生物工程","应用化学","食品科学与工程","药学"]', '大二及以上',
 DATEADD('DAY', 6, CURRENT_DATE), DATEADD('DAY', 56, CURRENT_DATE),
 DATEADD('DAY', 90, CURRENT_DATE), DATEADD('DAY', 92, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.csbmb.org.cn/', 60);

MERGE INTO competition (name, description, type, suitable_major, suitable_grade,
    registration_start, registration_end, competition_start, competition_end,
    difficulty, official_url, recommend_days) KEY(name) VALUES
('全国大学生护理学专业创新创业大赛',
 '护理学方向的创新创业赛事，涵盖临床护理创新、健康管理与护理器械',
 '医学技能', '["护理学","康复治疗学","临床医学","预防医学"]', '不限',
 DATEADD('DAY', 20, CURRENT_DATE), DATEADD('DAY', 74, CURRENT_DATE),
 DATEADD('DAY', 108, CURRENT_DATE), DATEADD('DAY', 110, CURRENT_DATE),
 'INTERMEDIATE', 'https://www.cna-cast.org.cn/', 75);

