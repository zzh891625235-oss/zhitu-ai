-- ============================================================
-- B 站公开课资源种子数据（H2 demo profile 专用）
--
-- 定位：校内课程地图回答「该学什么」，这批资源回答「去哪学」。
-- 匹配规则与 competition 表完全一致：
--   * suitable_major 为 JSON 数组，"*" 表示面向所有专业；
--   * 精确命中专业名 = 对口；同方向（MajorDirection）= 相关；"*" = 通用。
--
-- URL 策略（重要设计决策）：
--   存 B 站搜索直达链接（课程名 + UP 主的组合关键词）而非具体 BV 号。
--   BV 号会因视频下架/转载失效，评委点开死链是硬伤；
--   「课程名+UP主」搜索组合长期稳定命中正版课程页。
--
-- 使用 MERGE ... KEY(title) 幂等 upsert：补录新课程、修正专业对应关系后，
-- 用户无需删除 data/ 目录重建数据库。
-- ============================================================

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('高等数学 · 宋浩老师全程课', '宋浩老师官方', '大学基础课',
 '高等数学,微积分,高数,极限,导数,积分', 'BEGINNER', '["*"]',
 '大学高数口碑天花板，考研级讲解深入浅出，讲透极限与积分的本质',
 'https://search.bilibili.com/all?keyword=宋浩老师高等数学全程', 1);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('线性代数 · 宋浩老师全程课', '宋浩老师官方', '大学基础课',
 '线性代数,矩阵,行列式,线代,特征值', 'BEGINNER', '["*"]',
 '把矩阵讲成画面感，期末救急与考研打基础两相宜',
 'https://search.bilibili.com/all?keyword=宋浩老师线性代数全程', 2);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('概率论与数理统计 · 宋浩老师', '宋浩老师官方', '大学基础课',
 '概率论,数理统计,概率,随机变量,假设检验', 'BEGINNER', '["*"]',
 '概率论入门首选，例题驱动，统计专业与工科通用',
 'https://search.bilibili.com/all?keyword=宋浩老师概率论数理统计', 3);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('计算机网络 · 湖科大教书匠微课堂', '湖科大教书匠', '大学基础课',
 '计算机网络,TCP,IP,协议,OSI,HTTP', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","网络工程","信息安全","物联网工程","数据科学与大数据技术","通信工程","电子信息工程"]',
 '动画级图解 TCP/IP 全流程，计网期末与考研 401 首选',
 'https://search.bilibili.com/all?keyword=湖科大教书匠计算机网络', 4);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('大学物理 · 不挂科系列', '蜂考VIP', '大学基础课',
 '大学物理,力学,电磁学,光学,物理', 'BEGINNER', '["*"]',
 '考前突击速成向，配套讲义按题型归纳，救急优先',
 'https://search.bilibili.com/all?keyword=大学物理不挂科', 5);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('C语言 · 鹏哥 C 语言系统课', '鹏哥C语言', '编程开发',
 'C语言,指针,数组,函数,程序设计,编程入门', 'BEGINNER',
 '["计算机科学与技术","软件工程","网络工程","物联网工程","智能科学与技术","电子信息工程","通信工程","自动化","机械设计制造及其自动化"]',
 '从零开始的 C 语言体系课，指针部分掰开揉碎讲',
 'https://search.bilibili.com/all?keyword=鹏哥C语言', 10);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('Java 入门 · 尚硅谷宋红康全套', '尚硅谷官方', '编程开发',
 'Java,面向对象,JVM,集合,多线程,后端', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","网络工程","信息安全","数据科学与大数据技术","智能科学与技术"]',
 '企业级 Java 基础标准课，配套源码与笔记完整',
 'https://search.bilibili.com/all?keyword=尚硅谷宋红康Java入门', 11);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('Python 入门 · 黑马程序员全套', '黑马程序员', '编程开发',
 'Python,爬虫,自动化,编程入门,脚本', 'BEGINNER', '["计算机科学与技术","软件工程","人工智能","数据科学与大数据技术","网络工程","信息安全","物联网工程","通信工程","电子信息工程","智能科学与技术","信息管理与信息系统","电子商务"]',
 '理工科通用的 Python 起步课，数据处理、自动化与后续专业课程都从这里开始',
 'https://search.bilibili.com/all?keyword=黑马程序员Python入门教程', 12);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('前端三件套 HTML+CSS+JS · 黑马', '黑马程序员', '编程开发',
 '前端,HTML,CSS,JavaScript,Web,网页', 'BEGINNER',
 '["计算机科学与技术","软件工程","数字媒体技术","网络工程","数字媒体艺术","电子商务"]',
 '前端零基础第一站，做个人主页 / 课程设计 Web 大作业都能用上',
 'https://search.bilibili.com/all?keyword=黑马程序员前端HTMLCSSJavaScript', 13);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('数据结构 · 王道考研全程', '王道论坛', '编程开发',
 '数据结构,算法,链表,树,图,排序,考研408', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程"]',
 '408 考研标配，配合动画演示理解树与图的遍历',
 'https://search.bilibili.com/all?keyword=王道考研数据结构', 14);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('MySQL 数据库 · 尚硅谷全套', '尚硅谷官方', '编程开发',
 'MySQL,数据库,SQL,索引,事务,后端', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","数据科学与大数据技术","信息管理与信息系统","网络工程","电子商务"]',
 '数据库课内听不懂的 SQL 实战，这里全补齐，索引与事务讲得透',
 'https://search.bilibili.com/all?keyword=尚硅谷MySQL数据库', 15);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('Linux · 韩顺平一周实战', '韩顺平', '编程开发',
 'Linux,Ubuntu,命令行,运维,Shell,服务器', 'BEGINNER',
 '["计算机科学与技术","软件工程","网络工程","信息安全","物联网工程","通信工程","电子信息工程","人工智能","数据科学与大数据技术"]',
 '从装系统到 Shell 脚本，实验室服务器不再陌生',
 'https://search.bilibili.com/all?keyword=韩顺平Linux', 16);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('Git 与 GitHub 版本管理实战', 'Geek学院', '编程开发',
 'Git,GitHub,版本控制,协作,分支', 'BEGINNER', '["计算机科学与技术","软件工程","人工智能","数据科学与大数据技术","网络工程","信息安全","物联网工程","通信工程","电子信息工程"]',
 '课程设计组队协作、代码作业留痕都需要的工程基本功',
 'https://search.bilibili.com/all?keyword=GitGitHub版本控制教程', 17);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('SpringBoot 企业级开发 · 尚硅谷', '尚硅谷官方', '编程开发',
 'SpringBoot,Spring,Java后端,微服务,接口', 'ADVANCED',
 '["计算机科学与技术","软件工程","人工智能","网络工程","数据科学与大数据技术"]',
 '做毕业设计与实习项目的事实标准框架，学完能独立交付后端服务',
 'https://search.bilibili.com/all?keyword=尚硅谷SpringBoot', 18);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('机器学习 · 吴恩达公开课（中英字幕）', '吴恩达 Andrew Ng', '数据与AI',
 '机器学习,深度学习,AI,吴恩达,神经网络,监督学习', 'BEGINNER',
 '["人工智能","计算机科学与技术","软件工程","数据科学与大数据技术","智能科学与技术","自动化","应用统计学","统计学","数学与应用数学","信息与计算科学"]',
 '全球公认的 AI 第一课，数学推导与直觉并重',
 'https://search.bilibili.com/all?keyword=吴恩达机器学习', 20);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('深度学习与生成式 AI · 李宏毅全程', '李宏毅 Hung-yi Lee', '数据与AI',
 '深度学习,大模型,LLM,Transformer,AIGC,生成式AI', 'INTERMEDIATE',
 '["人工智能","计算机科学与技术","软件工程","数据科学与大数据技术","智能科学与技术","网络工程"]',
 '台大李宏毅每年更新，紧跟大模型与 AIGC 前沿，中文讲得最清楚',
 'https://search.bilibili.com/all?keyword=李宏毅机器学习深度学习', 21);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('PyTorch 深度学习实战入门', '我是土堆', '数据与AI',
 'PyTorch,深度学习,神经网络,训练,模型', 'INTERMEDIATE',
 '["人工智能","计算机科学与技术","软件工程","数据科学与大数据技术","智能科学与技术","自动化"]',
 '跟着敲完就能跑通第一个训练任务，深度学习框架首选',
 'https://search.bilibili.com/all?keyword=土堆PyTorch深度学习', 22);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('数据分析 · NumPy + Pandas 全套', '黑马程序员', '数据与AI',
 '数据分析,NumPy,Pandas,数据清洗,可视化,Excel', 'INTERMEDIATE',
 '["数据科学与大数据技术","应用统计学","统计学","经济统计学","金融学","会计学","财务管理","市场营销","电子商务","信息管理与信息系统","数学与应用数学"]',
 '经管与数据类专业的第二门「必修课」，处理课程数据与实习报表都靠它',
 'https://search.bilibili.com/all?keyword=NumPyPandas数据分析', 23);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('AI 编程助手与 Prompt 工程', '技术蛋老师', '数据与AI',
 'Prompt,提示词,AI工具,ChatGPT,效率,大模型', 'BEGINNER', '["*"]',
 '把大模型用成学习外脑：查文献、改代码、练外语的正确姿势',
 'https://search.bilibili.com/all?keyword=Prompt提示词工程入门', 24);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('Photoshop 从入门到精通', 'oeasy', '设计创作',
 'PS,Photoshop,修图,平面设计,海报', 'BEGINNER', '["*"]',
 '社团海报、课程汇报封面、表情包制作一站学会',
 'https://search.bilibili.com/all?keyword=oeasyPhotoshop教程', 30);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('视频剪辑 Premiere 入门到实战', 'doyoudo', '设计创作',
 '剪辑,PR,Premiere,视频后期,自媒体', 'BEGINNER',
 '["数字媒体技术","数字媒体艺术","广播电视编导","动画","广告学","网络与新媒体","新闻学","戏剧影视文学"]',
 '从粗剪到调色，自媒体时代的基本功',
 'https://search.bilibili.com/all?keyword=doyoudoPremiere剪辑', 31);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('Excel 从入门到精通 · 王佩丰 24 讲', '王佩丰', '职场技能',
 'Excel,表格,函数,数据透视表,办公', 'BEGINNER', '["*"]',
 '全专业通用的硬技能：函数、透视表、图表，实习第一周就见效',
 'https://search.bilibili.com/all?keyword=王佩丰Excel24讲', 40);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('PPT 设计与汇报表达', '秋叶', '职场技能',
 'PPT,幻灯片,演示,答辩,汇报', 'BEGINNER', '["*"]',
 '课程答辩、竞赛路演、社团竞选都吃这套',
 'https://search.bilibili.com/all?keyword=秋叶PPT教程', 41);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('大学生求职：简历与面试实战', '张雪峰老师', '职场技能',
 '求职,简历,面试,秋招,春招,职业规划', 'INTERMEDIATE', '["*"]',
 '从简历怎么写到面试怎么聊，就业季刚需',
 'https://search.bilibili.com/all?keyword=大学生求职简历面试', 42);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('英语四六级全程班', '刘晓艳', '外语提升',
 '四六级,CET4,CET6,英语,听力,阅读,写作', 'BEGINNER', '["*"]',
 '大学生过级标配，听力+阅读+写作分模块突破',
 'https://search.bilibili.com/all?keyword=刘晓艳四六级全程', 50);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('英语口语零基础到流利表达', '英语兔', '外语提升',
 '英语口语,发音,口语练习,日常英语', 'BEGINNER',
 '["英语","商务英语","翻译","日语","德语","法语","西班牙语","俄语","朝鲜语","新闻学","国际经济与贸易"]',
 '发音规则与日常表达，把应试英语变成能开口的英语',
 'https://search.bilibili.com/all?keyword=英语兔英语口语', 51);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('日语入门 · 标准日本语初级', '圆圆的日语教室', '外语提升',
 '日语,五十音,标准日本语,日语入门', 'BEGINNER', '["英语","商务英语","翻译","日语","德语","法语","西班牙语","俄语","朝鲜语","汉语国际教育","国际经济与贸易"]',
 '二外、考研二外、兴趣学习通用起步课',
 'https://search.bilibili.com/all?keyword=标准日本语日语入门', 52);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('考研数学全程 · 张宇', '张宇', '考研升学',
 '考研数学,高数考研,考研,数学一,数学二,数学三', 'INTERMEDIATE', '["*"]',
 '考研数学主线课，基础 30 讲起步衔接强化',
 'https://search.bilibili.com/all?keyword=张宇考研数学', 60);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('考研政治 · 徐涛全程', '徐涛', '考研升学',
 '考研政治,马原,毛中特,思修,考研', 'BEGINNER', '["*"]',
 '政治讲得有逻辑有温度，冲刺背诵手册配套使用',
 'https://search.bilibili.com/all?keyword=徐涛考研政治', 61);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('教师资格证 · 科目一科目二全程', '粉笔教育', '考研升学',
 '教师资格证,教资,教育学,科目二,教师', 'BEGINNER',
 '["教育学","学前教育","小学教育","汉语言文学","应用心理学","体育教育","数学与应用数学","英语"]',
 '师范与非师范生考教资的主线课，笔试面试全覆盖',
 'https://search.bilibili.com/all?keyword=教师资格证粉笔全程', 62);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('初级会计实务 + 经济法基础', '之了课堂', '考研升学',
 '初级会计,会计职称,会计实务,经济法,CPA', 'BEGINNER',
 '["会计学","财务管理","审计学","工商管理","金融学","国际经济与贸易","税收学","资产评估"]',
 '会计专业第一证，非会计专业转行财务的敲门砖',
 'https://search.bilibili.com/all?keyword=初级会计之了课堂', 63);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('人体解剖学 · 系统解剖全程', '霍琨老师', '大学基础课',
 '解剖学,人体解剖,系统解剖,医学', 'INTERMEDIATE',
 '["临床医学","护理学","口腔医学","药学","医学影像学","预防医学","中医学","康复治疗学","麻醉学"]',
 '手绘图讲解剖的传奇课程，医学生期末救命课',
 'https://search.bilibili.com/all?keyword=霍琨系统解剖学', 70);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('法考客观题精讲 · 民法刑法', '众合教育', '考研升学',
 '法考,司法考试,民法,刑法,法律职业资格', 'INTERMEDIATE',
 '["法学","知识产权","监狱学","政治学与行政学","社会学","社会工作","国际政治","思想政治教育"]',
 '法考客观题主线精讲，民法刑法两大分值担当，法学生必刷',
 'https://search.bilibili.com/all?keyword=法考客观题民法刑法精讲', 71);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('申论与公文写作 · 系统课', '粉笔公考', '职场技能',
 '申论,公文写作,考公,行测,公务员', 'BEGINNER',
 '["法学","汉语言文学","行政管理","公共事业管理","政治学与行政学","思想政治教育","社会学","新闻学"]',
 '考公申论与机关公文写作一站式，文科生体制内就业必备',
 'https://search.bilibili.com/all?keyword=申论公文写作系统课', 72);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('心理学导论 · 普通心理学', '心理学陈老师', '大学基础课',
 '心理学,普通心理学,心理学导论,认知,情绪', 'BEGINNER',
 '["心理学","应用心理学","教育学","学前教育","小学教育","社会工作","护理学"]',
 '心理学入门第一课，考研312与教资心理学都从这里起步',
 'https://search.bilibili.com/all?keyword=普通心理学考研', 73);

MERGE INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) KEY(title) VALUES
('中国古代文学史 · 袁行霈版', '文学考研阿甘', '大学基础课',
 '古代文学,文学史,袁行霈,先秦文学,唐宋文学', 'INTERMEDIATE',
 '["汉语言文学","汉语国际教育","新闻学","广告学","编辑出版学","秘书学","戏剧影视文学"]',
 '中文系核心课，考研文学史主线，把朝代脉络与作品串成一条线',
 'https://search.bilibili.com/all?keyword=中国古代文学史袁行霈', 74);
