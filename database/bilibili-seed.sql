-- ============================================================
-- B 站公开课资源种子数据（MySQL 生产档专用）
--
-- 本文件由 scripts/gen-bilibili-seed.py 生成，请勿手工编辑。
-- 修改课程请改脚本后重新运行：python scripts/gen-bilibili-seed.py
--
-- 专业相关度的唯一事实来源是 com.zhitu.ai.CourseMajorRelevance：
--   100 分 = suitable_major 列出该专业（直接对口）
--    80 分 = 列出近亲专业（如「汉语言」之于「汉语言文学」）
--    60 分 = "*" 真·全专业通用（职场/考研/四六级等）
--   其余一律不推荐，宁可少推不可错推。
--
-- suitable_major 中的每个专业名都经过脚本校验，必须属于 database/majors.sql
-- 的 175 个专业；字典外的名字（如「应用统计学」）无法精确命中，只会制造错配。
--
-- sort_order 同时编码「贴合度分层」：适配专业越少越贴合该专业，
-- 专业核心课（<=20 个专业）排在最前，门类公共基础课（>40 个专业 / "*"）垫后。
-- 同为 100 分时，心理学先看到普通心理学而不是高等数学。
--
-- 链接采用「课程名 + UP 主」的 B 站搜索直达而非固定 BV 号：视频会下架，
-- 搜索组合不会，评委点开永远不是死链。
--
-- 幂等策略：INSERT ... ON DUPLICATE KEY UPDATE 按 title upsert，末尾 DELETE 清理旧版本残留课程，
-- 老用户不删 data/ 目录也能拿到最新的专业映射。
-- ============================================================


ALTER TABLE bilibili_resource MODIFY COLUMN suitable_major VARCHAR(2000);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('高等数学 · 宋浩老师全程课', '宋浩老师官方', '大学基础课', '高等数学,微积分,高数,极限,导数,积分', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","数学与应用数学","信息与计算科学","物理学","应用物理学","化学","应用化学","生物科学","生物技术","生态学","天文学","地理科学","大气科学","海洋科学","地质学","地球物理学","心理学","统计学","经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草"]', '大学高数口碑天花板，考研级讲解深入浅出，讲透极限与积分的本质',
 'https://search.bilibili.com/all?keyword=%E5%AE%8B%E6%B5%A9%E8%80%81%E5%B8%88%E9%AB%98%E7%AD%89%E6%95%B0%E5%AD%A6%E5%85%A8%E7%A8%8B', 3010)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('线性代数 · 宋浩老师全程课', '宋浩老师官方', '大学基础课', '线性代数,矩阵,行列式,线代,特征值', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","数学与应用数学","信息与计算科学","物理学","应用物理学","化学","应用化学","生物科学","生物技术","生态学","天文学","地理科学","大气科学","海洋科学","地质学","地球物理学","心理学","统计学","经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草"]', '把矩阵讲成画面感，期末救急与考研打基础两相宜',
 'https://search.bilibili.com/all?keyword=%E5%AE%8B%E6%B5%A9%E8%80%81%E5%B8%88%E7%BA%BF%E6%80%A7%E4%BB%A3%E6%95%B0%E5%85%A8%E7%A8%8B', 3020)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('概率论与数理统计 · 宋浩老师', '宋浩老师官方', '大学基础课', '概率论,数理统计,随机变量,假设检验', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","数学与应用数学","信息与计算科学","物理学","应用物理学","化学","应用化学","生物科学","生物技术","生态学","天文学","地理科学","大气科学","海洋科学","地质学","地球物理学","心理学","统计学","经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草"]', '概率论入门首选，例题驱动，统计与工科通用',
 'https://search.bilibili.com/all?keyword=%E5%AE%8B%E6%B5%A9%E8%80%81%E5%B8%88%E6%A6%82%E7%8E%87%E8%AE%BA%E6%95%B0%E7%90%86%E7%BB%9F%E8%AE%A1', 3030)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('大学物理 · 不挂科系列', '蜂考VIP', '大学基础课', '大学物理,力学,电磁学,光学,期末', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","数学与应用数学","信息与计算科学","物理学","应用物理学","化学","应用化学","生物科学","生物技术","生态学","天文学","地理科学","大气科学","海洋科学","地质学","地球物理学","心理学","统计学"]', '一学期大学物理知识点压缩成可跟练的期末冲刺课',
 'https://search.bilibili.com/all?keyword=%E8%9C%82%E8%80%83%E5%A4%A7%E5%AD%A6%E7%89%A9%E7%90%86%E4%B8%8D%E6%8C%82%E7%A7%91', 3040)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('大学化学 · 无机化学基础', '化学公开课', '大学基础课', '大学化学,无机化学,原子结构,化学键', 'BEGINNER',
 '["化学","应用化学","化学工程与工艺","材料科学与工程","材料成型及控制工程","制药工程","药学","中药学","环境工程","食品科学与工程","轻化工程","纺织工程","生物工程","生物科学","生物技术","生态学","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学","地理科学","地质学"]', '从原子结构到化学平衡，给化工/材料/农林医专业补上化学基础',
 'https://search.bilibili.com/all?keyword=%E5%A4%A7%E5%AD%A6%E5%8C%96%E5%AD%A6%E6%97%A0%E6%9C%BA%E5%8C%96%E5%AD%A6%E5%9F%BA%E7%A1%80', 3050)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('普通生物学 · 陈阅增教材精讲', '生物考研加油站', '大学基础课', '普通生物学,细胞,遗传,进化,生态', 'BEGINNER',
 '["生物科学","生物技术","生物工程","生态学","食品科学与工程","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","基础医学","临床医学","药学","医学检验技术","预防医学"]', '生命科学第一门主干课，细胞到生态系统一次打通',
 'https://search.bilibili.com/all?keyword=%E9%99%88%E9%98%85%E5%A2%9E%E6%99%AE%E9%80%9A%E7%94%9F%E7%89%A9%E5%AD%A6%E7%B2%BE%E8%AE%B2', 2010)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('学术写作与文献检索', '大学资源网', '大学基础课', '论文写作,文献检索,知网,引用规范,综述', 'BEGINNER',
 '["*"]', '从检索、综述到引用规范，课程论文与毕业论文都用得上',
 'https://search.bilibili.com/all?keyword=%E5%A4%A7%E5%AD%A6%E7%94%9F%E8%AE%BA%E6%96%87%E5%86%99%E4%BD%9C%E6%96%87%E7%8C%AE%E6%A3%80%E7%B4%A2%E5%85%A5%E9%97%A8', 3060)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('AI 编程助手与 Prompt 工程', '技术蛋老师', '数据与AI', 'AI工具,Prompt,Copilot,大模型,效率', 'BEGINNER',
 '["*"]', '把大模型变成学习助手：提问、改写、查错、生成练习的正确姿势',
 'https://search.bilibili.com/all?keyword=AI%E7%BC%96%E7%A8%8B%E5%8A%A9%E6%89%8BPrompt%E5%B7%A5%E7%A8%8B%E5%85%A5%E9%97%A8', 3070)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('大学生时间管理与学习方法', '学霸研究所', '职场技能', '时间管理,番茄钟,费曼学习法,自律', 'BEGINNER',
 '["*"]', '把四年拆成可执行的小目标，解决「知道要学却总拖着」的问题',
 'https://search.bilibili.com/all?keyword=%E5%A4%A7%E5%AD%A6%E7%94%9F%E6%97%B6%E9%97%B4%E7%AE%A1%E7%90%86%E5%AD%A6%E4%B9%A0%E6%96%B9%E6%B3%95', 3080)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('信息素养与文献管理 Zotero', '图灵教育', '大学基础课', 'Zotero,文献管理,笔记,知识库', 'BEGINNER',
 '["*"]', '用 Zotero 建立自己的资料库，写论文不再翻聊天记录找出处',
 'https://search.bilibili.com/all?keyword=Zotero%E6%96%87%E7%8C%AE%E7%AE%A1%E7%90%86%E6%95%99%E7%A8%8B', 3090)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('C语言 · 鹏哥 C 语言系统课', '鹏哥C语言', '编程开发', 'C语言,指针,数组,结构体,程序设计', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","信息管理与信息系统","教育技术学","机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程","电气工程及其自动化"]', '零基础到能写完整小项目，工科第一门程序设计课的首选',
 'https://search.bilibili.com/all?keyword=%E9%B9%8F%E5%93%A5C%E8%AF%AD%E8%A8%80%E7%B3%BB%E7%BB%9F%E8%AF%BE', 2020)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('C++ 面向对象程序设计 · 黑马', '黑马程序员', '编程开发', 'C++,STL,面向对象,类,模板', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术"]', '从 C 过渡到面向对象与 STL，做算法题和项目前的必备一环',
 'https://search.bilibili.com/all?keyword=%E9%BB%91%E9%A9%AC%E7%A8%8B%E5%BA%8F%E5%91%98C%2B%2B%E6%95%99%E7%A8%8B', 1010)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Java 入门 · 尚硅谷宋红康全套', '尚硅谷官方', '编程开发', 'Java,面向对象,JVM,集合,异常', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术"]', '国内最完整的 Java 基础体系课，配海量笔记与练习',
 'https://search.bilibili.com/all?keyword=%E5%B0%9A%E7%A1%85%E8%B0%B7%E5%AE%8B%E7%BA%A2%E5%BA%B7Java%E5%9F%BA%E7%A1%80', 1020)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Python 入门 · 黑马程序员全套', '黑马程序员', '编程开发', 'Python,基础语法,爬虫入门,函数', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","数学与应用数学","信息与计算科学","统计学","经济统计学","金融工程","金融学","物理学","应用物理学","经济学","国民经济管理","工商管理","会计学","财务管理","人力资源管理","市场营销","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '语法讲得干净利落，非计算机专业做数据处理也从这里开始',
 'https://search.bilibili.com/all?keyword=%E9%BB%91%E9%A9%AC%E7%A8%8B%E5%BA%8F%E5%91%98Python%E5%85%A5%E9%97%A8', 2030)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('前端三件套 HTML+CSS+JS · 黑马', '黑马程序员', '编程开发', 'HTML,CSS,JavaScript,网页,前端', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","视觉传达设计","环境设计","产品设计","服装与服饰设计","数字媒体艺术","动画","美术学","绘画","雕塑","摄影","建筑学","风景园林","园林","网络与新媒体"]', '从零做出第一个能交互的网页，前端与数字媒体方向通用',
 'https://search.bilibili.com/all?keyword=%E9%BB%91%E9%A9%AC%E7%A8%8B%E5%BA%8F%E5%91%98%E5%89%8D%E7%AB%AFHTMLCSSJS', 2040)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Vue3 + Element Plus 项目实战', '尚硅谷官方', '编程开发', 'Vue3,组件,路由,ElementPlus,前端工程化', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术"]', '把前端知识串成完整后台项目，毕设与实习最常用的一套技术栈',
 'https://search.bilibili.com/all?keyword=%E5%B0%9A%E7%A1%85%E8%B0%B7Vue3ElementPlus%E5%AE%9E%E6%88%98', 1030)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数据结构 · 王道考研全程', '王道论坛', '编程开发', '数据结构,链表,树,图,排序,算法', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","信息管理与信息系统","教育技术学"]', '408 与面试的共同主线，把抽象结构讲成可推导的过程',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E9%81%93%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E8%80%83%E7%A0%94', 2050)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('操作系统 · 哈工大李治军', '哈工大', '编程开发', '操作系统,进程,内存,文件系统,Linux', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","信息管理与信息系统","教育技术学"]', '从源码级别理解进程与内存，计科最硬也最值得啃的一门',
 'https://search.bilibili.com/all?keyword=%E5%93%88%E5%B7%A5%E5%A4%A7%E6%9D%8E%E6%B2%BB%E5%86%9B%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F', 2060)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('计算机组成原理 · 王道考研', '王道论坛', '编程开发', '组成原理,CPU,指令,存储,总线', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","信息管理与信息系统","教育技术学"]', '把 CPU 到存储器的链路讲通，硬件与软件的交界处',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E9%81%93%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BB%84%E6%88%90%E5%8E%9F%E7%90%86', 2070)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('计算机网络 · 湖科大教书匠微课堂', '湖科大教书匠', '编程开发', '计算机网络,TCP,IP,HTTP,路由', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","信息管理与信息系统","教育技术学"]', '动画化讲协议，公认最适合入门的计网课',
 'https://search.bilibili.com/all?keyword=%E6%B9%96%E7%A7%91%E5%A4%A7%E6%95%99%E4%B9%A6%E5%8C%A0%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BD%91%E7%BB%9C', 2080)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('编译原理 · 哈工大课程', '哈工大', '编程开发', '编译原理,词法分析,语法分析,语义', 'ADVANCED',
 '["计算机科学与技术","软件工程"]', '词法到目标代码生成的完整链路，计科高年级进阶课',
 'https://search.bilibili.com/all?keyword=%E5%93%88%E5%B7%A5%E5%A4%A7%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86', 1040)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('算法与刷题 · 代码随想录', '代码随想录', '编程开发', '算法,LeetCode,动态规划,双指针,刷题', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","数学与应用数学","信息与计算科学","统计学","经济统计学","金融工程","金融学","物理学","应用物理学","经济学","国民经济管理"]', '按专题带刷 LeetCode，把数据结构知识变成解题能力',
 'https://search.bilibili.com/all?keyword=%E4%BB%A3%E7%A0%81%E9%9A%8F%E6%83%B3%E5%BD%95%E7%AE%97%E6%B3%95%E5%88%B7%E9%A2%98', 2090)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('MySQL 数据库 · 尚硅谷全套', '尚硅谷官方', '编程开发', 'MySQL,SQL,索引,事务,数据库设计', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","工商管理","会计学","财务管理","人力资源管理","市场营销","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '从建表到索引优化，课程设计与毕设都要用的数据库技能',
 'https://search.bilibili.com/all?keyword=%E5%B0%9A%E7%A1%85%E8%B0%B7MySQL%E6%95%B0%E6%8D%AE%E5%BA%93', 2100)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Linux · 韩顺平一周实战', '韩顺平', '编程开发', 'Linux,Shell,服务器,权限,运维', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","信息管理与信息系统","教育技术学"]', '一周把常用命令与服务器操作练熟，部署项目不再求人',
 'https://search.bilibili.com/all?keyword=%E9%9F%A9%E9%A1%BA%E5%B9%B3Linux%E4%B8%80%E5%91%A8', 2110)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Git 与 GitHub 版本管理实战', 'Geek学院', '编程开发', 'Git,GitHub,版本管理,协作,分支', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","电子信息工程","通信工程","自动化","机器人工程","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","信息与计算科学","教育技术学"]', '团队作业与开源协作的必备工具，把「最终版最终版2」彻底终结',
 'https://search.bilibili.com/all?keyword=Git+GitHub%E7%89%88%E6%9C%AC%E7%AE%A1%E7%90%86%E6%95%99%E7%A8%8B', 2120)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('SpringBoot 企业级开发 · 尚硅谷', '尚硅谷官方', '编程开发', 'SpringBoot,JavaWeb,REST,后端', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术"]', '从单体接口到完整后端服务，Java 方向毕设常用框架',
 'https://search.bilibili.com/all?keyword=%E5%B0%9A%E7%A1%85%E8%B0%B7SpringBoot', 1050)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Docker 与容器化部署入门', '狂神说', '编程开发', 'Docker,容器,镜像,部署,DevOps', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术"]', '让「在我电脑上能跑」变成在哪都能跑，项目交付最后一公里',
 'https://search.bilibili.com/all?keyword=%E7%8B%82%E7%A5%9E%E8%AF%B4Docker%E5%85%A5%E9%97%A8', 1060)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('软件工程与 UML 建模', '清华学堂在线', '编程开发', '软件工程,需求分析,UML,设计模式,文档', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","信息管理与信息系统"]', '把写代码升级为做工程：需求、建模、测试与文档',
 'https://search.bilibili.com/all?keyword=%E8%BD%AF%E4%BB%B6%E5%B7%A5%E7%A8%8BUML%E5%BB%BA%E6%A8%A1%E8%AF%BE%E7%A8%8B', 1070)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('单片机 STM32 · 江科大自化协', '江科大自化协', '编程开发', '单片机,STM32,嵌入式,GPIO,定时器', 'INTERMEDIATE',
 '["电气工程及其自动化","电子信息工程","通信工程","自动化","测控技术与仪器","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","物联网工程","机器人工程","核工程与核技术","机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程"]', '从点灯到中断与通信，电子与自动化方向做实物项目的起点',
 'https://search.bilibili.com/all?keyword=%E6%B1%9F%E7%A7%91%E5%A4%A7%E8%87%AA%E5%8C%96%E5%8D%8FSTM32%E5%85%A5%E9%97%A8', 2130)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('机器学习 · 吴恩达公开课（中英字幕）', '吴恩达 Andrew Ng', '数据与AI', '机器学习,线性回归,梯度下降,神经网络', 'INTERMEDIATE',
 '["人工智能","数据科学与大数据技术","大数据科学与技术","智能科学与技术","机器人工程","自动化","统计学","经济统计学","数学与应用数学","信息与计算科学","计算机科学与技术","软件工程","金融工程"]', '机器学习经典入门课，先把直觉建立起来再推公式',
 'https://search.bilibili.com/all?keyword=%E5%90%B4%E6%81%A9%E8%BE%BE%E6%9C%BA%E5%99%A8%E5%AD%A6%E4%B9%A0%E4%B8%AD%E6%96%87%E5%AD%97%E5%B9%95', 1080)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('深度学习与生成式 AI · 李宏毅全程', '李宏毅 Hung-yi Lee', '数据与AI', '深度学习,Transformer,生成式AI,大模型', 'INTERMEDIATE',
 '["人工智能","数据科学与大数据技术","大数据科学与技术","智能科学与技术","机器人工程","自动化","统计学","经济统计学","数学与应用数学","信息与计算科学","计算机科学与技术","软件工程","金融工程"]', '从神经网络到 Transformer 与生成模型，中文讲解最系统的一套',
 'https://search.bilibili.com/all?keyword=%E6%9D%8E%E5%AE%8F%E6%AF%85%E6%B7%B1%E5%BA%A6%E5%AD%A6%E4%B9%A0%E7%94%9F%E6%88%90%E5%BC%8FAI', 1090)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('PyTorch 深度学习实战入门', '我是土堆', '数据与AI', 'PyTorch,张量,训练,卷积神经网络', 'BEGINNER',
 '["人工智能","数据科学与大数据技术","大数据科学与技术","智能科学与技术","机器人工程","自动化","统计学","经济统计学","数学与应用数学","信息与计算科学","计算机科学与技术","软件工程","金融工程"]', '边敲边讲，第一个图像分类模型跑通只要一个下午',
 'https://search.bilibili.com/all?keyword=%E6%88%91%E6%98%AF%E5%9C%9F%E5%A0%86PyTorch%E6%95%99%E7%A8%8B', 1100)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数据分析 · NumPy + Pandas 全套', '黑马程序员', '数据与AI', 'NumPy,Pandas,数据清洗,可视化,数据分析', 'BEGINNER',
 '["人工智能","数据科学与大数据技术","大数据科学与技术","智能科学与技术","机器人工程","自动化","统计学","经济统计学","数学与应用数学","信息与计算科学","计算机科学与技术","软件工程","金融工程","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程","金融学","物理学","应用物理学","经济学","国民经济管理"]', '把表格数据清洗成结论，统计、经管、数据方向的通用工具课',
 'https://search.bilibili.com/all?keyword=%E9%BB%91%E9%A9%AC%E7%A8%8B%E5%BA%8F%E5%91%98NumPy+Pandas', 2140)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('SQL 数据分析实战', '数据分析不说谎', '数据与AI', 'SQL,多表查询,窗口函数,数据报表', 'INTERMEDIATE',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","工商管理","会计学","财务管理","人力资源管理","市场营销","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程","数学与应用数学","信息与计算科学","统计学","经济统计学","金融工程","金融学","物理学","应用物理学","经济学","国民经济管理"]', '用真实业务表练复杂查询，比背语法有效得多',
 'https://search.bilibili.com/all?keyword=SQL%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90%E5%AE%9E%E6%88%98%E6%95%99%E7%A8%8B', 2150)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('统计学 · 贾俊平教材精讲', '统计考研社', '数据与AI', '统计学,抽样,参数估计,假设检验,回归', 'BEGINNER',
 '["统计学","经济统计学","数学与应用数学","信息与计算科学","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程","预防医学","临床医学"]', '统计推断的主干课，经管与理学共用教材',
 'https://search.bilibili.com/all?keyword=%E8%B4%BE%E4%BF%8A%E5%B9%B3%E7%BB%9F%E8%AE%A1%E5%AD%A6%E7%B2%BE%E8%AE%B2', 2160)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('SPSS 统计分析实操', '统计小课堂', '数据与AI', 'SPSS,方差分析,相关,回归,问卷', 'BEGINNER',
 '["统计学","经济统计学","心理学","教育学","社会学","社会工作","护理学","预防医学","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '问卷与实验数据一键出结果，课程论文最常用的统计工具',
 'https://search.bilibili.com/all?keyword=SPSS%E7%BB%9F%E8%AE%A1%E5%88%86%E6%9E%90%E6%95%99%E7%A8%8B', 2170)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('R 语言与统计建模', 'R语言中文社区', '数据与AI', 'R语言,ggplot2,统计建模,回归', 'INTERMEDIATE',
 '["统计学","经济统计学","生物科学","生态学","数学与应用数学"]', '统计专业的第二门语言，画图与建模都很顺手',
 'https://search.bilibili.com/all?keyword=R%E8%AF%AD%E8%A8%80%E7%BB%9F%E8%AE%A1%E5%BB%BA%E6%A8%A1%E5%85%A5%E9%97%A8', 1110)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('OpenCV 计算机视觉入门', '贾志刚', '数据与AI', 'OpenCV,图像处理,目标检测,计算机视觉', 'INTERMEDIATE',
 '["人工智能","智能科学与技术","机器人工程","计算机科学与技术","数字媒体技术","自动化"]', '从图像滤波到目标检测，视觉方向的第一门实战课',
 'https://search.bilibili.com/all?keyword=OpenCV%E8%AE%A1%E7%AE%97%E6%9C%BA%E8%A7%86%E8%A7%89%E5%85%A5%E9%97%A8', 1120)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('自然语言处理入门', '自然语言处理站', '数据与AI', 'NLP,分词,词向量,文本分类,语言模型', 'INTERMEDIATE',
 '["人工智能","智能科学与技术","计算机科学与技术","软件工程","数据科学与大数据技术","汉语言"]', '分词、词向量到文本分类，把语言变成可计算的向量',
 'https://search.bilibili.com/all?keyword=%E8%87%AA%E7%84%B6%E8%AF%AD%E8%A8%80%E5%A4%84%E7%90%86%E5%85%A5%E9%97%A8%E8%AF%BE%E7%A8%8B', 1130)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('大模型应用开发 LangChain', '大模型实验室', '数据与AI', 'LangChain,RAG,向量库,智能体,大模型应用', 'ADVANCED',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程","信息管理与信息系统","电子商务","数字媒体技术","机器人工程","自动化","统计学","经济统计学","数学与应用数学","信息与计算科学","金融工程"]', '把大模型接进自己的数据与业务，从会聊天到能干活',
 'https://search.bilibili.com/all?keyword=LangChain%E5%A4%A7%E6%A8%A1%E5%9E%8B%E5%BA%94%E7%94%A8%E5%BC%80%E5%8F%91', 1140)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数据挖掘导论', '数据挖掘研习社', '数据与AI', '数据挖掘,聚类,关联规则,分类', 'INTERMEDIATE',
 '["数据科学与大数据技术","大数据科学与技术","统计学","计算机科学与技术","人工智能","信息管理与信息系统"]', '聚类、关联与分类三大主题，数据方向的进阶必修',
 'https://search.bilibili.com/all?keyword=%E6%95%B0%E6%8D%AE%E6%8C%96%E6%8E%98%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1150)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数学分析 · 陈纪修全程', '陈纪修', '理工专业课', '数学分析,极限,连续,级数,微积分证明', 'INTERMEDIATE',
 '["数学与应用数学","信息与计算科学","统计学","物理学","应用物理学","金融工程"]', '数学专业最硬的主干课，把「为什么」讲透而不只是会算',
 'https://search.bilibili.com/all?keyword=%E9%99%88%E7%BA%AA%E4%BF%AE%E6%95%B0%E5%AD%A6%E5%88%86%E6%9E%90', 1160)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('高等代数 · 丘维声', '丘维声', '理工专业课', '高等代数,多项式,线性空间,矩阵论', 'INTERMEDIATE',
 '["数学与应用数学","信息与计算科学","统计学","金融工程"]', '从多项式到线性空间，与数学分析并列的另一门基础',
 'https://search.bilibili.com/all?keyword=%E4%B8%98%E7%BB%B4%E5%A3%B0%E9%AB%98%E7%AD%89%E4%BB%A3%E6%95%B0', 1170)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('常微分方程 · 教材精讲', '数学基础课', '理工专业课', '常微分方程,动力系统,解的存在性', 'INTERMEDIATE',
 '["数学与应用数学","信息与计算科学","物理学","应用物理学","自动化","计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术"]', '建模与物理规律的数学语言，工科高年级常用',
 'https://search.bilibili.com/all?keyword=%E5%B8%B8%E5%BE%AE%E5%88%86%E6%96%B9%E7%A8%8B%E6%95%99%E6%9D%90%E7%B2%BE%E8%AE%B2', 3100)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('实变函数入门', '数学基础课', '理工专业课', '实变函数,测度,勒贝格积分', 'ADVANCED',
 '["数学与应用数学","信息与计算科学","统计学"]', '从黎曼积分走向勒贝格积分，概率论的理论地基',
 'https://search.bilibili.com/all?keyword=%E5%AE%9E%E5%8F%98%E5%87%BD%E6%95%B0%E5%85%A5%E9%97%A8%E8%AF%BE%E7%A8%8B', 1180)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数值分析与计算方法', '数值分析课堂', '理工专业课', '数值分析,插值,数值积分,迭代法', 'INTERMEDIATE',
 '["数学与应用数学","信息与计算科学","计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","统计学"]', '把连续问题变成可算的离散算法，工科与计算数学通用',
 'https://search.bilibili.com/all?keyword=%E6%95%B0%E5%80%BC%E5%88%86%E6%9E%90%E8%AE%A1%E7%AE%97%E6%96%B9%E6%B3%95%E8%AF%BE%E7%A8%8B', 3110)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('运筹学 · 清华教材精讲', '运筹学课堂', '理工专业课', '运筹学,线性规划,最短路,排队论,决策', 'INTERMEDIATE',
 '["数学与应用数学","信息与计算科学","工业工程","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","交通运输","交通工程"]', '优化与决策的数学工具，管科、经管、交通方向都要学',
 'https://search.bilibili.com/all?keyword=%E8%BF%90%E7%AD%B9%E5%AD%A6%E6%B8%85%E5%8D%8E%E6%95%99%E6%9D%90%E7%B2%BE%E8%AE%B2', 2180)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('力学 · 赵凯华新概念物理', '赵凯华', '理工专业课', '力学,牛顿定律,动量,刚体,振动', 'INTERMEDIATE',
 '["物理学","应用物理学","光电信息科学与工程","电子科学与技术","微电子科学与工程","天文学","地球物理学","大气科学","海洋科学","地质学","核工程与核技术","材料科学与工程","机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程","土木工程"]', '物理系第一门专业课，从直觉到严格定义',
 'https://search.bilibili.com/all?keyword=%E8%B5%B5%E5%87%AF%E5%8D%8E%E6%96%B0%E6%A6%82%E5%BF%B5%E7%89%A9%E7%90%86%E5%8A%9B%E5%AD%A6', 2190)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('电磁学 · 赵凯华', '赵凯华', '理工专业课', '电磁学,麦克斯韦,电场,磁场,电磁感应', 'INTERMEDIATE',
 '["物理学","应用物理学","光电信息科学与工程","电子科学与技术","微电子科学与工程","天文学","地球物理学","大气科学","海洋科学","地质学","核工程与核技术","材料科学与工程","电气工程及其自动化","电子信息工程","通信工程","自动化","测控技术与仪器","集成电路设计与集成系统","物联网工程","机器人工程"]', '把场的概念讲清楚，后续电动力学与电路课的地基',
 'https://search.bilibili.com/all?keyword=%E8%B5%B5%E5%87%AF%E5%8D%8E%E7%94%B5%E7%A3%81%E5%AD%A6', 1190)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('光学 · 赵凯华', '赵凯华', '理工专业课', '光学,干涉,衍射,偏振,几何光学', 'INTERMEDIATE',
 '["物理学","应用物理学","光电信息科学与工程","测控技术与仪器"]', '从干涉到偏振，光电方向的必修分支',
 'https://search.bilibili.com/all?keyword=%E8%B5%B5%E5%87%AF%E5%8D%8E%E5%85%89%E5%AD%A6', 1200)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('量子力学 · 曾谨言', '曾谨言', '理工专业课', '量子力学,薛定谔方程,算符,自旋', 'ADVANCED',
 '["物理学","应用物理学","光电信息科学与工程","微电子科学与工程","核工程与核技术"]', '现代物理的分水岭，半导体与光电方向的理论源头',
 'https://search.bilibili.com/all?keyword=%E6%9B%BE%E8%B0%A8%E8%A8%80%E9%87%8F%E5%AD%90%E5%8A%9B%E5%AD%A6', 1210)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('理论力学 · 哈工大', '哈工大', '理工专业课', '理论力学,静力学,动力学,拉格朗日', 'INTERMEDIATE',
 '["机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","工程管理","工程造价","环境工程","土地资源管理","物理学"]', '机械与土木的结构分析基础，从受力到运动方程',
 'https://search.bilibili.com/all?keyword=%E5%93%88%E5%B7%A5%E5%A4%A7%E7%90%86%E8%AE%BA%E5%8A%9B%E5%AD%A6', 2200)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('材料力学 · 刘鸿文', '刘鸿文', '理工专业课', '材料力学,应力,应变,弯曲,强度', 'INTERMEDIATE',
 '["机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","工程管理","工程造价","环境工程","土地资源管理","材料科学与工程"]', '构件会不会断、会弯多少，工科设计的第一道校核',
 'https://search.bilibili.com/all?keyword=%E5%88%98%E9%B8%BF%E6%96%87%E6%9D%90%E6%96%99%E5%8A%9B%E5%AD%A6', 2210)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('固体物理 · 黄昆', '黄昆', '理工专业课', '固体物理,晶格,能带,半导体', 'ADVANCED',
 '["物理学","应用物理学","微电子科学与工程","电子科学与技术","材料科学与工程","集成电路设计与集成系统"]', '从晶格振动到能带理论，半导体器件的物理基础',
 'https://search.bilibili.com/all?keyword=%E9%BB%84%E6%98%86%E5%9B%BA%E4%BD%93%E7%89%A9%E7%90%86', 1220)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('天文学导论', '天文爱好者', '理工专业课', '天文学,恒星,星系,宇宙学,观测', 'BEGINNER',
 '["天文学","物理学","应用物理学","地球物理学","地理科学"]', '从星座到宇宙尺度，给天文与地球物理方向的全景入门',
 'https://search.bilibili.com/all?keyword=%E5%A4%A9%E6%96%87%E5%AD%A6%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1230)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('气象学与气候学基础', '气象课堂', '理工专业课', '大气科学,气象学,天气系统,气候', 'INTERMEDIATE',
 '["大气科学","地理科学","海洋科学","环境工程","地球物理学"]', '读懂天气图与气候数据，大气与地理方向的入门课',
 'https://search.bilibili.com/all?keyword=%E6%B0%94%E8%B1%A1%E5%AD%A6%E4%B8%8E%E6%B0%94%E5%80%99%E5%AD%A6%E5%9F%BA%E7%A1%80', 1240)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('海洋科学导论', '海洋科普', '理工专业课', '海洋科学,洋流,海洋生态,物理海洋', 'BEGINNER',
 '["海洋科学","地理科学","大气科学","水产养殖学","地球物理学"]', '物理海洋到海洋生态的全景概览',
 'https://search.bilibili.com/all?keyword=%E6%B5%B7%E6%B4%8B%E7%A7%91%E5%AD%A6%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1250)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('地质学与地球物理基础', '地质课堂', '理工专业课', '地质学,矿物,地层,地震波,地球物理', 'BEGINNER',
 '["地质学","地球物理学","地理科学","测绘工程","土木工程","海洋科学"]', '从矿物识别到地震波，认识脚下这颗星球',
 'https://search.bilibili.com/all?keyword=%E5%9C%B0%E8%B4%A8%E5%AD%A6%E5%9C%B0%E7%90%83%E7%89%A9%E7%90%86%E5%9F%BA%E7%A1%80', 1260)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('无机化学 · 吉林大学宋天佑', '吉林大学', '理工专业课', '无机化学,原子结构,配位,周期律', 'BEGINNER',
 '["化学","应用化学","化学工程与工艺","材料科学与工程","材料成型及控制工程","制药工程","药学","中药学","环境工程","食品科学与工程","轻化工程","纺织工程","生物工程"]', '化学专业第一门主干课，体系完整、例题清楚',
 'https://search.bilibili.com/all?keyword=%E5%90%89%E6%9E%97%E5%A4%A7%E5%AD%A6%E5%AE%8B%E5%A4%A9%E4%BD%91%E6%97%A0%E6%9C%BA%E5%8C%96%E5%AD%A6', 1270)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('有机化学 · 李景宁', '李景宁', '理工专业课', '有机化学,官能团,反应机理,合成', 'INTERMEDIATE',
 '["化学","应用化学","化学工程与工艺","材料科学与工程","材料成型及控制工程","制药工程","药学","中药学","环境工程","食品科学与工程","轻化工程","纺织工程","生物工程","生物科学","生物技术"]', '按官能团与机理串起有机反应，不再靠死记',
 'https://search.bilibili.com/all?keyword=%E6%9D%8E%E6%99%AF%E5%AE%81%E6%9C%89%E6%9C%BA%E5%8C%96%E5%AD%A6', 1280)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('分析化学 · 武汉大学', '武汉大学', '理工专业课', '分析化学,滴定,误差,定量分析', 'INTERMEDIATE',
 '["化学","应用化学","化学工程与工艺","材料科学与工程","材料成型及控制工程","制药工程","药学","中药学","环境工程","食品科学与工程","轻化工程","纺织工程","生物工程","医学检验技术"]', '定量分析的基本功，实验数据的误差从哪来',
 'https://search.bilibili.com/all?keyword=%E6%AD%A6%E6%B1%89%E5%A4%A7%E5%AD%A6%E5%88%86%E6%9E%90%E5%8C%96%E5%AD%A6', 1290)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('物理化学 · 傅献彩', '傅献彩', '理工专业课', '物理化学,热力学,动力学,电化学', 'ADVANCED',
 '["化学","应用化学","化学工程与工艺","材料科学与工程","材料成型及控制工程","制药工程","药学","中药学","环境工程","食品科学与工程","轻化工程","纺织工程","生物工程"]', '化学里最抽象也最有用的一门，热力学与动力学一次讲透',
 'https://search.bilibili.com/all?keyword=%E5%82%85%E7%8C%AE%E5%BD%A9%E7%89%A9%E7%90%86%E5%8C%96%E5%AD%A6', 1300)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('结构化学 · 周公度', '周公度', '理工专业课', '结构化学,量子化学,分子对称性,晶体', 'ADVANCED',
 '["化学","应用化学","材料科学与工程","物理学"]', '从分子轨道到晶体结构，连接化学与量子力学',
 'https://search.bilibili.com/all?keyword=%E5%91%A8%E5%85%AC%E5%BA%A6%E7%BB%93%E6%9E%84%E5%8C%96%E5%AD%A6%E5%9F%BA%E7%A1%80', 1310)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('仪器分析', '分析测试课堂', '理工专业课', '仪器分析,色谱,光谱,质谱,检测', 'INTERMEDIATE',
 '["化学","应用化学","化学工程与工艺","材料科学与工程","材料成型及控制工程","制药工程","药学","中药学","环境工程","食品科学与工程","轻化工程","纺织工程","生物工程","医学检验技术"]', '色谱光谱质谱的原理与谱图解读，实验课的好搭档',
 'https://search.bilibili.com/all?keyword=%E4%BB%AA%E5%99%A8%E5%88%86%E6%9E%90%E8%AF%BE%E7%A8%8B', 1320)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('化工原理 · 陈敏恒', '陈敏恒', '理工专业课', '化工原理,传热,传质,精馏,流体输送', 'INTERMEDIATE',
 '["化学工程与工艺","制药工程","轻化工程","食品科学与工程","环境工程"]', '单元操作串起整条工艺流程，化工专业的核心主干',
 'https://search.bilibili.com/all?keyword=%E9%99%88%E6%95%8F%E6%81%92%E5%8C%96%E5%B7%A5%E5%8E%9F%E7%90%86', 1330)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('材料科学基础 · 潘金生', '潘金生', '理工专业课', '材料科学基础,晶体缺陷,相图,扩散', 'INTERMEDIATE',
 '["材料科学与工程","材料成型及控制工程","微电子科学与工程","机械工程","化学"]', '成分—结构—性能之间的关系，材料人的第一门专业课',
 'https://search.bilibili.com/all?keyword=%E6%BD%98%E9%87%91%E7%94%9F%E6%9D%90%E6%96%99%E7%A7%91%E5%AD%A6%E5%9F%BA%E7%A1%80', 1340)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('高分子化学与物理', '高分子课堂', '理工专业课', '高分子,聚合反应,塑料,橡胶', 'INTERMEDIATE',
 '["材料科学与工程","化学工程与工艺","应用化学","轻化工程","纺织工程"]', '从聚合机理到材料性能，高分子方向的入门',
 'https://search.bilibili.com/all?keyword=%E9%AB%98%E5%88%86%E5%AD%90%E5%8C%96%E5%AD%A6%E4%B8%8E%E7%89%A9%E7%90%86%E8%AF%BE%E7%A8%8B', 1350)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('环境监测与分析', '环境工程课堂', '理工专业课', '环境监测,水质,大气监测,污染物', 'INTERMEDIATE',
 '["环境工程","化学","应用化学","化学工程与工艺","预防医学"]', '采样到出报告的完整流程，环境方向实践课配套',
 'https://search.bilibili.com/all?keyword=%E7%8E%AF%E5%A2%83%E7%9B%91%E6%B5%8B%E4%B8%8E%E5%88%86%E6%9E%90%E8%AF%BE%E7%A8%8B', 1360)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('电路 · 邱关源教材精讲', '电路基础教学', '理工专业课', '电路,基尔霍夫,戴维南,三相电路', 'INTERMEDIATE',
 '["电气工程及其自动化","电子信息工程","通信工程","自动化","测控技术与仪器","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","物联网工程","机器人工程","核工程与核技术","计算机科学与技术"]', '电气类第一门硬课，按邱关源教材逐章推导',
 'https://search.bilibili.com/all?keyword=%E9%82%B1%E5%85%B3%E6%BA%90%E7%94%B5%E8%B7%AF%E6%95%99%E6%9D%90%E7%B2%BE%E8%AE%B2', 1370)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('模拟电子技术基础 · 华成英', '华成英', '理工专业课', '模电,放大器,运放,反馈,三极管', 'INTERMEDIATE',
 '["电气工程及其自动化","电子信息工程","通信工程","自动化","测控技术与仪器","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","物联网工程","机器人工程","核工程与核技术"]', '从二极管到运放电路，电子方向的入门拦路虎',
 'https://search.bilibili.com/all?keyword=%E5%8D%8E%E6%88%90%E8%8B%B1%E6%A8%A1%E6%8B%9F%E7%94%B5%E5%AD%90%E6%8A%80%E6%9C%AF%E5%9F%BA%E7%A1%80', 1380)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数字电子技术基础 · 阎石', '阎石', '理工专业课', '数电,逻辑门,触发器,时序电路', 'INTERMEDIATE',
 '["电气工程及其自动化","电子信息工程","通信工程","自动化","测控技术与仪器","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","物联网工程","机器人工程","核工程与核技术","计算机科学与技术"]', '组合与时序逻辑设计，硬件描述语言的先导课',
 'https://search.bilibili.com/all?keyword=%E9%98%8E%E7%9F%B3%E6%95%B0%E5%AD%97%E7%94%B5%E5%AD%90%E6%8A%80%E6%9C%AF%E5%9F%BA%E7%A1%80', 1390)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('信号与系统 · 吴大正', '吴大正', '理工专业课', '信号与系统,傅里叶变换,卷积,拉普拉斯', 'INTERMEDIATE',
 '["电气工程及其自动化","电子信息工程","通信工程","自动化","测控技术与仪器","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","物联网工程","机器人工程","核工程与核技术","物理学","应用物理学","天文学","地球物理学","大气科学","海洋科学","地质学","材料科学与工程"]', '从时域到频域，通信与信号处理的共同语言',
 'https://search.bilibili.com/all?keyword=%E5%90%B4%E5%A4%A7%E6%AD%A3%E4%BF%A1%E5%8F%B7%E4%B8%8E%E7%B3%BB%E7%BB%9F', 1400)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数字信号处理 · 程佩青', '程佩青', '理工专业课', 'DSP,DFT,FFT,滤波器,采样', 'ADVANCED',
 '["电子信息工程","通信工程","自动化","集成电路设计与集成系统","测控技术与仪器"]', 'FFT 与滤波器设计，把信号与系统落到可实现算法',
 'https://search.bilibili.com/all?keyword=%E7%A8%8B%E4%BD%A9%E9%9D%92%E6%95%B0%E5%AD%97%E4%BF%A1%E5%8F%B7%E5%A4%84%E7%90%86', 1410)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('自动控制原理 · 胡寿松', '胡寿松', '理工专业课', '自动控制,传递函数,根轨迹,PID,稳定性', 'INTERMEDIATE',
 '["自动化","电气工程及其自动化","机器人工程","机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程"]', '反馈与稳定性分析，自动化专业的立身之本',
 'https://search.bilibili.com/all?keyword=%E8%83%A1%E5%AF%BF%E6%9D%BE%E8%87%AA%E5%8A%A8%E6%8E%A7%E5%88%B6%E5%8E%9F%E7%90%86', 1420)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('电机与拖动基础', '电气课堂', '理工专业课', '电机,变压器,直流电机,异步电机', 'INTERMEDIATE',
 '["电气工程及其自动化","自动化","能源与动力工程","机械设计制造及其自动化"]', '电机结构与机械特性，电气方向的必修主干',
 'https://search.bilibili.com/all?keyword=%E7%94%B5%E6%9C%BA%E4%B8%8E%E6%8B%96%E5%8A%A8%E5%9F%BA%E7%A1%80%E8%AF%BE%E7%A8%8B', 1430)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('电力系统分析 · 何仰赞', '何仰赞', '理工专业课', '电力系统,潮流计算,短路,继电保护', 'ADVANCED',
 '["电气工程及其自动化","能源与动力工程","自动化"]', '从潮流计算到故障分析，强电方向进阶课',
 'https://search.bilibili.com/all?keyword=%E4%BD%95%E4%BB%B0%E8%B5%9E%E7%94%B5%E5%8A%9B%E7%B3%BB%E7%BB%9F%E5%88%86%E6%9E%90', 1440)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('电磁场与电磁波', '电磁场课堂', '理工专业课', '电磁场,麦克斯韦方程,波导,天线', 'ADVANCED',
 '["电子信息工程","通信工程","电子科学与技术","微电子科学与工程","光电信息科学与工程"]', '从静态场到辐射，通信与天线方向的理论课',
 'https://search.bilibili.com/all?keyword=%E7%94%B5%E7%A3%81%E5%9C%BA%E4%B8%8E%E7%94%B5%E7%A3%81%E6%B3%A2%E8%AF%BE%E7%A8%8B', 1450)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('半导体物理与器件', '半导体课堂', '理工专业课', '半导体,PN结,MOSFET,能带', 'INTERMEDIATE',
 '["微电子科学与工程","集成电路设计与集成系统","电子科学与技术","光电信息科学与工程","材料科学与工程"]', 'PN 结到 MOSFET，芯片方向的物理起点',
 'https://search.bilibili.com/all?keyword=%E5%8D%8A%E5%AF%BC%E4%BD%93%E7%89%A9%E7%90%86%E4%B8%8E%E5%99%A8%E4%BB%B6%E8%AF%BE%E7%A8%8B', 1460)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('集成电路设计导论', '芯片教育', '理工专业课', '集成电路,Verilog,数字前端,版图', 'INTERMEDIATE',
 '["集成电路设计与集成系统","微电子科学与工程","电子科学与技术","电子信息工程"]', '从 RTL 到版图的流程全景，IC 方向入门',
 'https://search.bilibili.com/all?keyword=%E9%9B%86%E6%88%90%E7%94%B5%E8%B7%AF%E8%AE%BE%E8%AE%A1%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1470)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('机械原理 · 孙桓', '孙桓', '理工专业课', '机械原理,机构,齿轮,连杆,自由度', 'INTERMEDIATE',
 '["机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程"]', '机构运动与自由度分析，机械专业第一门设计课',
 'https://search.bilibili.com/all?keyword=%E5%AD%99%E6%A1%93%E6%9C%BA%E6%A2%B0%E5%8E%9F%E7%90%86', 1480)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('机械设计 · 濮良贵', '濮良贵', '理工专业课', '机械设计,轴,轴承,齿轮强度,联接', 'INTERMEDIATE',
 '["机械工程","机械设计制造及其自动化","车辆工程","材料成型及控制工程","能源与动力工程","测控技术与仪器","工业工程","交通运输","交通工程","航空航天工程","飞行器设计与工程","飞行器动力工程","船舶与海洋工程","安全工程"]', '把零件选型与强度校核做成可交付的设计',
 'https://search.bilibili.com/all?keyword=%E6%BF%AE%E8%89%AF%E8%B4%B5%E6%9C%BA%E6%A2%B0%E8%AE%BE%E8%AE%A1', 1490)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('工程图学与画法几何', '大连理工', '理工专业课', '工程制图,三视图,投影,公差', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术"]', '读图与绘图的基本功，所有工科专业的共同语言',
 'https://search.bilibili.com/all?keyword=%E5%B7%A5%E7%A8%8B%E5%9B%BE%E5%AD%A6%E7%94%BB%E6%B3%95%E5%87%A0%E4%BD%95%E8%AF%BE%E7%A8%8B', 3120)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('热力学与传热学', '能源课堂', '理工专业课', '工程热力学,传热,导热,对流,熵', 'INTERMEDIATE',
 '["能源与动力工程","飞行器动力工程","核工程与核技术","机械工程","化学工程与工艺","车辆工程"]', '能量转换与传递的规律，能源与动力方向主干课',
 'https://search.bilibili.com/all?keyword=%E5%B7%A5%E7%A8%8B%E7%83%AD%E5%8A%9B%E5%AD%A6%E4%B8%8E%E4%BC%A0%E7%83%AD%E5%AD%A6', 1500)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('流体力学基础', '流体力学课堂', '理工专业课', '流体力学,伯努利,边界层,管流', 'INTERMEDIATE',
 '["能源与动力工程","水利水电工程","船舶与海洋工程","航空航天工程","土木工程","化学工程与工艺"]', '从伯努利方程到管内流动，水利与航空方向都要用',
 'https://search.bilibili.com/all?keyword=%E6%B5%81%E4%BD%93%E5%8A%9B%E5%AD%A6%E5%9F%BA%E7%A1%80%E8%AF%BE%E7%A8%8B', 1510)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('汽车构造与原理', '汽车课堂', '理工专业课', '汽车构造,发动机,底盘,传动,新能源', 'BEGINNER',
 '["车辆工程","机械设计制造及其自动化","能源与动力工程","交通运输"]', '整车结构拆开讲，车辆方向入门与实习前的补课',
 'https://search.bilibili.com/all?keyword=%E6%B1%BD%E8%BD%A6%E6%9E%84%E9%80%A0%E4%B8%8E%E5%8E%9F%E7%90%86%E8%AF%BE%E7%A8%8B', 1520)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('结构力学 · 龙驭球', '龙驭球', '理工专业课', '结构力学,内力,位移法,力矩分配', 'INTERMEDIATE',
 '["土木工程","水利水电工程","工程管理","建筑学"]', '杆系结构的内力与变形，土木专业最核心的一门',
 'https://search.bilibili.com/all?keyword=%E9%BE%99%E9%A9%AD%E7%90%83%E7%BB%93%E6%9E%84%E5%8A%9B%E5%AD%A6', 1530)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('混凝土结构设计原理', '土木课堂', '理工专业课', '混凝土,受弯,受剪,配筋,规范', 'INTERMEDIATE',
 '["土木工程","工程管理","工程造价","建筑学"]', '按规范做构件设计，从课本走向施工图',
 'https://search.bilibili.com/all?keyword=%E6%B7%B7%E5%87%9D%E5%9C%9F%E7%BB%93%E6%9E%84%E8%AE%BE%E8%AE%A1%E5%8E%9F%E7%90%86%E8%AF%BE%E7%A8%8B', 1540)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('建筑制图与 AutoCAD', '建筑CAD课堂', '理工专业课', '建筑制图,AutoCAD,平面图,施工图', 'BEGINNER',
 '["建筑学","城乡规划","风景园林","土木工程","环境设计","工程造价"]', '建筑平立剖与施工图表达，设计课之前的工具课',
 'https://search.bilibili.com/all?keyword=%E5%BB%BA%E7%AD%91%E5%88%B6%E5%9B%BEAutoCAD%E6%95%99%E7%A8%8B', 1550)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中外建筑史', '建筑史课堂', '理工专业课', '建筑史,古建筑,现代建筑,流派', 'BEGINNER',
 '["建筑学","城乡规划","风景园林","环境设计","历史学","文物与博物馆学"]', '从斗拱到包豪斯，建筑与景观方向的理论底子',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E5%A4%96%E5%BB%BA%E7%AD%91%E5%8F%B2%E8%AF%BE%E7%A8%8B', 1560)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('城市规划原理', '规划课堂', '理工专业课', '城市规划,用地,控规,城市设计', 'INTERMEDIATE',
 '["城乡规划","建筑学","风景园林","土地资源管理","地理科学"]', '用地布局到控制性详规，规划专业的总纲',
 'https://search.bilibili.com/all?keyword=%E5%9F%8E%E5%B8%82%E8%A7%84%E5%88%92%E5%8E%9F%E7%90%86%E8%AF%BE%E7%A8%8B', 1570)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('工程测量学', '测量课堂', '理工专业课', '工程测量,水准,全站仪,GNSS,误差', 'BEGINNER',
 '["测绘工程","土木工程","水利水电工程","交通工程","地理科学","土地资源管理"]', '从水准仪到卫星定位，测绘与施工放样的基础',
 'https://search.bilibili.com/all?keyword=%E5%B7%A5%E7%A8%8B%E6%B5%8B%E9%87%8F%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1580)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('水力学 · 吴持恭', '吴持恭', '理工专业课', '水力学,明渠,堰流,渗流', 'INTERMEDIATE',
 '["水利水电工程","土木工程","环境工程","船舶与海洋工程"]', '水流运动的基本方程，水利方向的主干课',
 'https://search.bilibili.com/all?keyword=%E5%90%B4%E6%8C%81%E6%81%AD%E6%B0%B4%E5%8A%9B%E5%AD%A6', 1590)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('工程力学与材料力学综合', '工科基础课', '理工专业课', '工程力学,静力学,强度,刚度', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术"]', '把受力分析与强度校核合并成一门，工科通用基础',
 'https://search.bilibili.com/all?keyword=%E5%B7%A5%E7%A8%8B%E5%8A%9B%E5%AD%A6%E8%AF%BE%E7%A8%8B', 3130)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('工程训练与金工实习', '工程训练中心', '理工专业课', '金工实习,车铣刨磨,焊接,数控', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术"]', '进车间前先看清设备与工艺，工科实践课预习',
 'https://search.bilibili.com/all?keyword=%E9%87%91%E5%B7%A5%E5%AE%9E%E4%B9%A0%E5%B7%A5%E7%A8%8B%E8%AE%AD%E7%BB%83%E6%95%99%E7%A8%8B', 3140)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('工程伦理与项目管理', '工程教育', '理工专业课', '工程伦理,项目管理,安全,进度,成本', 'BEGINNER',
 '["计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术"]', '技术之外的责任与协作，工程认证关注的通识课',
 'https://search.bilibili.com/all?keyword=%E5%B7%A5%E7%A8%8B%E4%BC%A6%E7%90%86%E4%B8%8E%E9%A1%B9%E7%9B%AE%E7%AE%A1%E7%90%86', 3150)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('人体解剖学 · 系统解剖全程', '霍琨老师', '医学专业课', '系统解剖学,人体解剖,骨骼,肌肉,神经', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学"]', '按系统逐层讲结构，医学生公认的解剖入门神课',
 'https://search.bilibili.com/all?keyword=%E9%9C%8D%E7%90%A8%E7%B3%BB%E7%BB%9F%E8%A7%A3%E5%89%96%E5%AD%A6', 1600)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('生理学 · 人卫版教材精讲', '医学基础课', '医学专业课', '生理学,细胞生理,循环,呼吸,神经', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学","体育教育","运动训练","社会体育指导与管理","生物科学"]', '把「正常人体怎么运转」讲成一条完整链路',
 'https://search.bilibili.com/all?keyword=%E4%BA%BA%E5%8D%AB%E7%89%88%E7%94%9F%E7%90%86%E5%AD%A6%E7%B2%BE%E8%AE%B2', 1610)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('医学微生物与免疫学', '医学基础课', '医学专业课', '医学微生物,免疫,抗原,抗体,病原', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学","生物科学","生物技术"]', '病原与免疫应答，感染性疾病的理论基础',
 'https://search.bilibili.com/all?keyword=%E5%8C%BB%E5%AD%A6%E5%BE%AE%E7%94%9F%E7%89%A9%E4%B8%8E%E5%85%8D%E7%96%AB%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1620)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('病理学 · 人卫版', '医学基础课', '医学专业课', '病理学,炎症,肿瘤,切片,病变', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学"]', '从大体到镜下的病变形态，基础与临床的桥梁',
 'https://search.bilibili.com/all?keyword=%E4%BA%BA%E5%8D%AB%E7%89%88%E7%97%85%E7%90%86%E5%AD%A6%E7%B2%BE%E8%AE%B2', 1630)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('病理生理学', '医学基础课', '医学专业课', '病理生理,休克,水电解质,缺氧', 'INTERMEDIATE',
 '["临床医学","基础医学","预防医学","麻醉学","护理学"]', '疾病发生机制的功能侧解释，临床思维的地基',
 'https://search.bilibili.com/all?keyword=%E7%97%85%E7%90%86%E7%94%9F%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1640)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('药理学 · 人卫版', '医学基础课', '医学专业课', '药理学,药物代谢,受体,不良反应', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学","制药工程","化学","应用化学"]', '药物怎么起效、怎么用才安全，医药共用主干课',
 'https://search.bilibili.com/all?keyword=%E4%BA%BA%E5%8D%AB%E7%89%88%E8%8D%AF%E7%90%86%E5%AD%A6%E7%B2%BE%E8%AE%B2', 1650)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('诊断学 · 物理诊断', '临床技能课', '医学专业课', '诊断学,问诊,查体,心电图,体征', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","医学影像学","麻醉学","护理学","中医学","中西医临床医学"]', '从问诊到查体的临床第一技能，见习前必看',
 'https://search.bilibili.com/all?keyword=%E8%AF%8A%E6%96%AD%E5%AD%A6%E7%89%A9%E7%90%86%E8%AF%8A%E6%96%AD%E8%AF%BE%E7%A8%8B', 1660)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('内科学 · 人卫版', '临床课堂', '医学专业课', '内科学,呼吸,循环,消化,常见病', 'ADVANCED',
 '["临床医学","基础医学","中西医临床医学","医学影像学","麻醉学"]', '临床最大的一门主干课，按系统梳理常见疾病',
 'https://search.bilibili.com/all?keyword=%E4%BA%BA%E5%8D%AB%E7%89%88%E5%86%85%E7%A7%91%E5%AD%A6%E7%B2%BE%E8%AE%B2', 1670)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('外科学总论', '临床课堂', '医学专业课', '外科学,无菌,创伤,麻醉基础,围手术期', 'ADVANCED',
 '["临床医学","口腔医学","麻醉学","护理学"]', '无菌原则与围手术期处理，外科与口腔方向共用',
 'https://search.bilibili.com/all?keyword=%E5%A4%96%E7%A7%91%E5%AD%A6%E6%80%BB%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1680)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('医学统计学与流行病学', '公卫课堂', '医学专业课', '医学统计,流行病学,队列,病例对照,RR', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学","统计学","生物科学"]', '读懂临床研究的设计与结论，循证医学的工具课',
 'https://search.bilibili.com/all?keyword=%E5%8C%BB%E5%AD%A6%E7%BB%9F%E8%AE%A1%E5%AD%A6%E6%B5%81%E8%A1%8C%E7%97%85%E5%AD%A6', 1690)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('医学伦理与卫生法规', '医学人文课', '医学专业课', '医学伦理,知情同意,卫生法规,医患', 'BEGINNER',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学"]', '技术之外必须守住的边界，执业考试也考',
 'https://search.bilibili.com/all?keyword=%E5%8C%BB%E5%AD%A6%E4%BC%A6%E7%90%86%E4%B8%8E%E5%8D%AB%E7%94%9F%E6%B3%95%E8%A7%84', 1700)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('循证医学与文献检索', '循证课堂', '医学专业课', '循证医学,文献评价,PubMed,证据等级', 'INTERMEDIATE',
 '["临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学"]', '从查文献到评价证据，写综述与做科研的起点',
 'https://search.bilibili.com/all?keyword=%E5%BE%AA%E8%AF%81%E5%8C%BB%E5%AD%A6%E6%96%87%E7%8C%AE%E6%A3%80%E7%B4%A2', 1710)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('口腔解剖生理学', '口腔医考', '医学专业课', '口腔解剖,牙体,咬合,颌面', 'INTERMEDIATE',
 '["口腔医学","临床医学","基础医学","医学影像学","麻醉学"]', '牙体形态与颌面结构，口腔专业的第一门专业课',
 'https://search.bilibili.com/all?keyword=%E5%8F%A3%E8%85%94%E8%A7%A3%E5%89%96%E7%94%9F%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1720)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('口腔组织病理学', '口腔医考', '医学专业课', '口腔组织病理,牙发育,龋病,牙周', 'INTERMEDIATE',
 '["口腔医学","临床医学","基础医学","医学影像学","麻醉学"]', '从牙发育到常见病理，口腔方向的理论主干',
 'https://search.bilibili.com/all?keyword=%E5%8F%A3%E8%85%94%E7%BB%84%E7%BB%87%E7%97%85%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1730)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('牙体牙髓病学', '口腔医考', '医学专业课', '牙体牙髓,龋病,根管治疗,充填', 'ADVANCED',
 '["口腔医学","临床医学"]', '龋病到根管治疗的完整流程，口腔临床核心课',
 'https://search.bilibili.com/all?keyword=%E7%89%99%E4%BD%93%E7%89%99%E9%AB%93%E7%97%85%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1740)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('口腔修复学', '口腔医考', '医学专业课', '口腔修复,义齿,冠桥,种植', 'ADVANCED',
 '["口腔医学"]', '固定与活动修复的设计要点，口腔高年级主干',
 'https://search.bilibili.com/all?keyword=%E5%8F%A3%E8%85%94%E4%BF%AE%E5%A4%8D%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1750)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('基础护理学 · 人卫版', '护理课堂', '医学专业课', '基础护理,无菌技术,给药,生命体征', 'BEGINNER',
 '["护理学","临床医学","康复治疗学","麻醉学","中医学","针灸推拿学"]', '护理操作与流程规范，实习前最实用的一门',
 'https://search.bilibili.com/all?keyword=%E4%BA%BA%E5%8D%AB%E7%89%88%E5%9F%BA%E7%A1%80%E6%8A%A4%E7%90%86%E5%AD%A6', 1760)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('内科护理学', '护理课堂', '医学专业课', '内科护理,病情观察,健康教育', 'INTERMEDIATE',
 '["护理学","临床医学","康复治疗学"]', '按病种串起护理评估与措施，护理主干课',
 'https://search.bilibili.com/all?keyword=%E5%86%85%E7%A7%91%E6%8A%A4%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1770)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('医学影像学 · 放射诊断', '影像课堂', '医学专业课', '医学影像,X线,CT,MRI,阅片', 'INTERMEDIATE',
 '["医学影像学","临床医学","口腔医学","麻醉学","法医学"]', '从成像原理到常见片子的读法，影像方向入门',
 'https://search.bilibili.com/all?keyword=%E5%8C%BB%E5%AD%A6%E5%BD%B1%E5%83%8F%E5%AD%A6%E6%94%BE%E5%B0%84%E8%AF%8A%E6%96%AD', 1780)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('临床检验基础', '检验课堂', '医学专业课', '临床检验,血常规,生化,体液', 'INTERMEDIATE',
 '["医学检验技术","临床医学","基础医学","预防医学","生物技术"]', '常规检验项目与结果解读，检验方向主干课',
 'https://search.bilibili.com/all?keyword=%E4%B8%B4%E5%BA%8A%E6%A3%80%E9%AA%8C%E5%9F%BA%E7%A1%80%E8%AF%BE%E7%A8%8B', 1790)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('临床麻醉学', '麻醉课堂', '医学专业课', '临床麻醉,气道管理,镇痛,监护', 'ADVANCED',
 '["麻醉学","临床医学","护理学"]', '麻醉方案与围术期监护，麻醉专业核心课',
 'https://search.bilibili.com/all?keyword=%E4%B8%B4%E5%BA%8A%E9%BA%BB%E9%86%89%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1800)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('康复评定与治疗技术', '康复课堂', '医学专业课', '康复评定,关节活动度,运动治疗,理疗', 'INTERMEDIATE',
 '["康复治疗学","护理学","体育教育","运动训练","社会体育指导与管理","中医学","针灸推拿学"]', '从功能评定到治疗技术，康复与运动方向共用',
 'https://search.bilibili.com/all?keyword=%E5%BA%B7%E5%A4%8D%E8%AF%84%E5%AE%9A%E4%B8%8E%E6%B2%BB%E7%96%97%E6%8A%80%E6%9C%AF', 1810)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('法医学 · 法医病理', '法医课堂', '医学专业课', '法医学,死亡,损伤,毒物,鉴定', 'INTERMEDIATE',
 '["法医学","临床医学","基础医学","法学","监狱学"]', '死亡与损伤的医学判断，法医与法学交叉课',
 'https://search.bilibili.com/all?keyword=%E6%B3%95%E5%8C%BB%E5%AD%A6%E6%B3%95%E5%8C%BB%E7%97%85%E7%90%86%E8%AF%BE%E7%A8%8B', 1820)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中医基础理论', '中医课堂', '医学专业课', '中医基础,阴阳五行,藏象,气血', 'BEGINNER',
 '["中医学","中西医临床医学","针灸推拿学","中药学","药学","康复治疗学","护理学"]', '中医学的第一门课，把概念体系先搭起来',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E5%8C%BB%E5%9F%BA%E7%A1%80%E7%90%86%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1830)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中药学 · 教材精讲', '中药课堂', '医学专业课', '中药学,性味归经,方药,功效', 'INTERMEDIATE',
 '["中药学","中医学","中西医临床医学","药学","针灸推拿学"]', '按功效分类记药，中药方向的基本功',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E8%8D%AF%E5%AD%A6%E6%95%99%E6%9D%90%E7%B2%BE%E8%AE%B2', 1840)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('方剂学 · 邓中甲', '邓中甲', '医学专业课', '方剂学,配伍,君臣佐使,经典方', 'INTERMEDIATE',
 '["中医学","中西医临床医学","中药学","针灸推拿学"]', '讲配伍思路而不是背方歌，中医临床的桥梁课',
 'https://search.bilibili.com/all?keyword=%E9%82%93%E4%B8%AD%E7%94%B2%E6%96%B9%E5%89%82%E5%AD%A6', 1850)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('针灸学 · 经络腧穴', '针灸课堂', '医学专业课', '针灸学,经络,腧穴,针刺手法', 'INTERMEDIATE',
 '["针灸推拿学","中医学","中西医临床医学","康复治疗学"]', '经络循行与常用穴定位，针推方向入门',
 'https://search.bilibili.com/all?keyword=%E9%92%88%E7%81%B8%E5%AD%A6%E7%BB%8F%E7%BB%9C%E8%85%A7%E7%A9%B4%E8%AF%BE%E7%A8%8B', 1860)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('预防医学 · 公共卫生导论', '公卫课堂', '医学专业课', '预防医学,公共卫生,三级预防,健康', 'BEGINNER',
 '["预防医学","临床医学","护理学","医学检验技术","食品科学与工程","环境工程"]', '从个体治疗走向人群健康，预防方向总纲',
 'https://search.bilibili.com/all?keyword=%E9%A2%84%E9%98%B2%E5%8C%BB%E5%AD%A6%E5%85%AC%E5%85%B1%E5%8D%AB%E7%94%9F%E5%AF%BC%E8%AE%BA', 1870)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('微观经济学 · 高鸿业', '经济学课堂', '经管专业课', '微观经济学,供需,弹性,效用,市场结构', 'BEGINNER',
 '["经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '供需与厂商决策的入门主干课，经管考研也考',
 'https://search.bilibili.com/all?keyword=%E9%AB%98%E9%B8%BF%E4%B8%9A%E5%BE%AE%E8%A7%82%E7%BB%8F%E6%B5%8E%E5%AD%A6', 2220)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('宏观经济学 · 高鸿业', '经济学课堂', '经管专业课', '宏观经济学,GDP,IS-LM,通胀,失业', 'INTERMEDIATE',
 '["经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '国民收入与政策分析，把新闻里的经济数据读懂',
 'https://search.bilibili.com/all?keyword=%E9%AB%98%E9%B8%BF%E4%B8%9A%E5%AE%8F%E8%A7%82%E7%BB%8F%E6%B5%8E%E5%AD%A6', 2230)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('计量经济学 · 李子奈', '计量课堂', '经管专业课', '计量经济学,回归,OLS,异方差,面板', 'ADVANCED',
 '["经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理","统计学","数学与应用数学"]', '用数据检验经济假设，实证论文的标配工具',
 'https://search.bilibili.com/all?keyword=%E6%9D%8E%E5%AD%90%E5%A5%88%E8%AE%A1%E9%87%8F%E7%BB%8F%E6%B5%8E%E5%AD%A6', 1880)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('金融学 · 黄达', '金融课堂', '经管专业课', '金融学,货币,利率,银行,金融市场', 'INTERMEDIATE',
 '["金融学","金融工程","经济学","投资学","保险学","国际经济与贸易","财务管理"]', '货币、利率与金融体系的全景主干课',
 'https://search.bilibili.com/all?keyword=%E9%BB%84%E8%BE%BE%E9%87%91%E8%9E%8D%E5%AD%A6%E7%B2%BE%E8%AE%B2', 1890)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('公司金融与财务管理', '财会课堂', '经管专业课', '公司金融,资本预算,资本结构,估值', 'INTERMEDIATE',
 '["财务管理","会计学","金融学","金融工程","投资学","工商管理"]', '投资决策与估值，财会金融方向共用主干',
 'https://search.bilibili.com/all?keyword=%E5%85%AC%E5%8F%B8%E9%87%91%E8%9E%8D%E8%B4%A2%E5%8A%A1%E7%AE%A1%E7%90%86%E8%AF%BE%E7%A8%8B', 1900)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('证券投资学', '投资课堂', '经管专业课', '证券投资,股票,债券,技术分析,组合', 'INTERMEDIATE',
 '["投资学","金融学","金融工程","经济学","保险学","财务管理"]', '资产定价与组合管理，投资方向入门',
 'https://search.bilibili.com/all?keyword=%E8%AF%81%E5%88%B8%E6%8A%95%E8%B5%84%E5%AD%A6%E8%AF%BE%E7%A8%8B', 1910)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('会计学原理 · 基础会计', '财会课堂', '经管专业课', '基础会计,借贷记账,凭证,报表', 'BEGINNER',
 '["会计学","财务管理","税收学","财政学","金融学","经济学","工商管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '借贷记账法到三大报表，商科第一门专业课',
 'https://search.bilibili.com/all?keyword=%E5%9F%BA%E7%A1%80%E4%BC%9A%E8%AE%A1%E4%BC%9A%E8%AE%A1%E5%AD%A6%E5%8E%9F%E7%90%86', 2240)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中级财务会计', '财会课堂', '经管专业课', '中级财务会计,存货,固定资产,收入', 'INTERMEDIATE',
 '["会计学","财务管理","税收学","金融学"]', '按准则处理具体业务，会计方向进阶主干',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E7%BA%A7%E8%B4%A2%E5%8A%A1%E4%BC%9A%E8%AE%A1%E8%AF%BE%E7%A8%8B', 1920)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('成本与管理会计', '财会课堂', '经管专业课', '成本会计,本量利,预算,决策', 'INTERMEDIATE',
 '["会计学","财务管理","工商管理","工业工程"]', '从核算走向内部决策，管理会计的核心内容',
 'https://search.bilibili.com/all?keyword=%E6%88%90%E6%9C%AC%E4%B8%8E%E7%AE%A1%E7%90%86%E4%BC%9A%E8%AE%A1%E8%AF%BE%E7%A8%8B', 1930)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('审计学原理', '财会课堂', '经管专业课', '审计学,内控,审计证据,审计报告', 'INTERMEDIATE',
 '["会计学","财务管理","工商管理","财政学","税收学"]', '风险导向审计的基本流程与证据链',
 'https://search.bilibili.com/all?keyword=%E5%AE%A1%E8%AE%A1%E5%AD%A6%E5%8E%9F%E7%90%86%E8%AF%BE%E7%A8%8B', 1940)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('管理学原理 · 周三多', '管理课堂', '经管专业课', '管理学,计划,组织,领导,控制', 'BEGINNER',
 '["工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程","经济学","金融学","金融工程","保险学","国际经济与贸易","财政学","税收学","投资学","经济统计学","国民经济管理"]', '管理职能的经典框架，几乎所有管理类专业的入门课',
 'https://search.bilibili.com/all?keyword=%E5%91%A8%E4%B8%89%E5%A4%9A%E7%AE%A1%E7%90%86%E5%AD%A6%E5%8E%9F%E7%90%86', 2250)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('组织行为学', '管理课堂', '经管专业课', '组织行为,激励,团队,领导力,文化', 'INTERMEDIATE',
 '["工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程","社会学","社会工作"]', '个体、群体到组织层面解释「人为什么这样做事」',
 'https://search.bilibili.com/all?keyword=%E7%BB%84%E7%BB%87%E8%A1%8C%E4%B8%BA%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2260)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('市场营销学 · 科特勒', '营销课堂', '经管专业课', '市场营销,4P,细分,品牌,消费者', 'BEGINNER',
 '["市场营销","工商管理","电子商务","国际经济与贸易","广告学","网络与新媒体","会展经济与管理"]', '从市场细分到品牌策略，营销方向主干课',
 'https://search.bilibili.com/all?keyword=%E7%A7%91%E7%89%B9%E5%8B%92%E5%B8%82%E5%9C%BA%E8%90%A5%E9%94%80%E5%AD%A6', 1950)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('人力资源管理概论', '管理课堂', '经管专业课', '人力资源,招聘,绩效,薪酬,培训', 'BEGINNER',
 '["人力资源管理","工商管理","劳动与社会保障","行政管理"]', '选育用留的完整流程，HR 方向入门',
 'https://search.bilibili.com/all?keyword=%E4%BA%BA%E5%8A%9B%E8%B5%84%E6%BA%90%E7%AE%A1%E7%90%86%E6%A6%82%E8%AE%BA', 1960)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('供应链管理', '物流课堂', '经管专业课', '供应链,采购,库存,物流网络', 'INTERMEDIATE',
 '["供应链管理","物流管理","工商管理","工程管理","工业工程","国际经济与贸易"]', '从采购到交付的协同设计，物流方向主干',
 'https://search.bilibili.com/all?keyword=%E4%BE%9B%E5%BA%94%E9%93%BE%E7%AE%A1%E7%90%86%E8%AF%BE%E7%A8%8B', 1970)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('物流与仓储管理', '物流课堂', '经管专业课', '物流管理,仓储,配送,运输,库存', 'BEGINNER',
 '["物流管理","供应链管理","交通运输","交通工程","电子商务"]', '仓、运、配的实际运作与成本权衡',
 'https://search.bilibili.com/all?keyword=%E7%89%A9%E6%B5%81%E4%B8%8E%E4%BB%93%E5%82%A8%E7%AE%A1%E7%90%86%E8%AF%BE%E7%A8%8B', 1980)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('电子商务概论', '电商课堂', '经管专业课', '电子商务,平台,运营,支付,流量', 'BEGINNER',
 '["电子商务","市场营销","工商管理","信息管理与信息系统","国际经济与贸易","网络与新媒体"]', '平台逻辑与运营指标，电商方向总纲',
 'https://search.bilibili.com/all?keyword=%E7%94%B5%E5%AD%90%E5%95%86%E5%8A%A1%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 1990)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('管理信息系统', '信管课堂', '经管专业课', '管理信息系统,ERP,业务流程,数据分析', 'INTERMEDIATE',
 '["信息管理与信息系统","电子商务","工商管理","计算机科学与技术","软件工程","工业工程"]', '用信息系统支撑业务流程，信管专业核心课',
 'https://search.bilibili.com/all?keyword=%E7%AE%A1%E7%90%86%E4%BF%A1%E6%81%AF%E7%B3%BB%E7%BB%9F%E8%AF%BE%E7%A8%8B', 2000)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('财政学与税法', '财税课堂', '经管专业课', '财政学,税收,增值税,所得税,预算', 'INTERMEDIATE',
 '["财政学","税收学","经济学","国民经济管理","会计学","财务管理"]', '税制与财政政策，考证和实务都用得上',
 'https://search.bilibili.com/all?keyword=%E8%B4%A2%E6%94%BF%E5%AD%A6%E4%B8%8E%E7%A8%8E%E6%B3%95%E8%AF%BE%E7%A8%8B', 2010)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('国际贸易实务', '国贸课堂', '经管专业课', '国际贸易,信用证,报关,INCOTERMS', 'INTERMEDIATE',
 '["国际经济与贸易","经济学","电子商务","英语","物流管理"]', '从报价到结汇的单据与流程，国贸方向实操课',
 'https://search.bilibili.com/all?keyword=%E5%9B%BD%E9%99%85%E8%B4%B8%E6%98%93%E5%AE%9E%E5%8A%A1%E8%AF%BE%E7%A8%8B', 2020)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('保险学原理', '保险课堂', '经管专业课', '保险学,风险,保险合同,精算基础', 'BEGINNER',
 '["保险学","金融学","金融工程","经济学","劳动与社会保障"]', '风险分散与保险合同的基本原理',
 'https://search.bilibili.com/all?keyword=%E4%BF%9D%E9%99%A9%E5%AD%A6%E5%8E%9F%E7%90%86%E8%AF%BE%E7%A8%8B', 2030)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('工程经济学与造价管理', '工程造价课堂', '经管专业课', '工程经济,造价,招投标,合同,计价', 'INTERMEDIATE',
 '["工程造价","工程管理","土木工程","建筑学","水利水电工程"]', '投资估算到招投标计价，工管与造价方向主干',
 'https://search.bilibili.com/all?keyword=%E5%B7%A5%E7%A8%8B%E7%BB%8F%E6%B5%8E%E5%AD%A6%E4%B8%8E%E9%80%A0%E4%BB%B7%E7%AE%A1%E7%90%86', 2040)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('旅游与酒店管理概论', '文旅课堂', '经管专业课', '旅游管理,酒店管理,会展,服务运营', 'BEGINNER',
 '["旅游管理","酒店管理","会展经济与管理","工商管理","市场营销","历史学","文物与博物馆学"]', '服务业运营与体验设计，文旅方向全景入门',
 'https://search.bilibili.com/all?keyword=%E6%97%85%E6%B8%B8%E4%B8%8E%E9%85%92%E5%BA%97%E7%AE%A1%E7%90%86%E6%A6%82%E8%AE%BA', 2050)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('法理学 · 张文显', '法学课堂', '法政教育', '法理学,法的本质,法治,法律方法', 'INTERMEDIATE',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理"]', '法学第一门理论课，建立整套法律思维框架',
 'https://search.bilibili.com/all?keyword=%E5%BC%A0%E6%96%87%E6%98%BE%E6%B3%95%E7%90%86%E5%AD%A6', 2060)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('宪法学', '法学课堂', '法政教育', '宪法,基本权利,国家机构,合宪性', 'INTERMEDIATE',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理"]', '基本权利与国家权力结构，法考与公考都考',
 'https://search.bilibili.com/all?keyword=%E5%AE%AA%E6%B3%95%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2070)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('刑法学 · 罗翔说刑法', '罗翔说刑法', '法政教育', '刑法,犯罪构成,正当防卫,案例', 'BEGINNER',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理"]', '用案例把犯罪构成讲活，最适合入门的刑法课',
 'https://search.bilibili.com/all?keyword=%E7%BD%97%E7%BF%94%E8%AF%B4%E5%88%91%E6%B3%95', 2080)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('民法学 · 魏振瀛', '法学课堂', '法政教育', '民法,物权,合同,侵权,人格权', 'INTERMEDIATE',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理"]', '从民事法律行为到合同与侵权，民法体系全景',
 'https://search.bilibili.com/all?keyword=%E9%AD%8F%E6%8C%AF%E7%80%9B%E6%B0%91%E6%B3%95%E5%AD%A6', 2090)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('行政法与行政诉讼法', '法学课堂', '法政教育', '行政法,行政许可,复议,诉讼', 'INTERMEDIATE',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理"]', '行政行为合法性审查，法考与公考主干',
 'https://search.bilibili.com/all?keyword=%E8%A1%8C%E6%94%BF%E6%B3%95%E4%B8%8E%E8%A1%8C%E6%94%BF%E8%AF%89%E8%AE%BC%E6%B3%95', 2100)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('民事诉讼法', '法学课堂', '法政教育', '民事诉讼法,管辖,证据,审判程序', 'INTERMEDIATE',
 '["法学","知识产权","监狱学","社会工作"]', '从立案到执行的程序脉络，实务入门',
 'https://search.bilibili.com/all?keyword=%E6%B0%91%E4%BA%8B%E8%AF%89%E8%AE%BC%E6%B3%95%E8%AF%BE%E7%A8%8B', 2110)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('知识产权法', '法学课堂', '法政教育', '知识产权,专利,商标,著作权', 'INTERMEDIATE',
 '["知识产权","法学","网络与新媒体","数字媒体艺术","电子商务"]', '三项主要知识产权的保护与运用',
 'https://search.bilibili.com/all?keyword=%E7%9F%A5%E8%AF%86%E4%BA%A7%E6%9D%83%E6%B3%95%E8%AF%BE%E7%A8%8B', 2120)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('社会学概论', '社科课堂', '法政教育', '社会学,社会化,阶层,社会结构', 'BEGINNER',
 '["社会学","社会工作","思想政治教育","行政管理","公共管理","新闻学"]', '用社会学视角看日常现象，社科方向入门',
 'https://search.bilibili.com/all?keyword=%E7%A4%BE%E4%BC%9A%E5%AD%A6%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2130)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('社会调查研究方法', '社科课堂', '法政教育', '社会调查,问卷,抽样,访谈,统计', 'INTERMEDIATE',
 '["社会学","社会工作","政治学与行政学","思想政治教育","新闻学","传播学","行政管理"]', '从设计问卷到写调查报告，社科实证基本功',
 'https://search.bilibili.com/all?keyword=%E7%A4%BE%E4%BC%9A%E8%B0%83%E6%9F%A5%E7%A0%94%E7%A9%B6%E6%96%B9%E6%B3%95', 2140)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('社会工作概论', '社工课堂', '法政教育', '社会工作,个案,小组,社区,助人', 'BEGINNER',
 '["社会工作","社会学","劳动与社会保障","特殊教育"]', '个案、小组、社区三大方法的入门',
 'https://search.bilibili.com/all?keyword=%E7%A4%BE%E4%BC%9A%E5%B7%A5%E4%BD%9C%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2150)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('政治学原理', '政治学课堂', '法政教育', '政治学,国家,权力,政党,制度', 'BEGINNER',
 '["政治学与行政学","国际政治","思想政治教育","行政管理","法学","社会学"]', '政治现象的基本概念与分析框架',
 'https://search.bilibili.com/all?keyword=%E6%94%BF%E6%B2%BB%E5%AD%A6%E5%8E%9F%E7%90%86%E8%AF%BE%E7%A8%8B', 2160)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('思想政治教育原理', '思政课堂', '法政教育', '思想政治教育,德育,价值观,方法', 'INTERMEDIATE',
 '["思想政治教育","教育学","政治学与行政学","哲学"]', '思政工作规律与方法，师范与马理论方向主干',
 'https://search.bilibili.com/all?keyword=%E6%80%9D%E6%83%B3%E6%94%BF%E6%B2%BB%E6%95%99%E8%82%B2%E5%8E%9F%E7%90%86', 2170)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('教育学原理 · 王道俊', '教育课堂', '法政教育', '教育学,教学,课程,教育目的', 'BEGINNER',
 '["教育学","学前教育","小学教育","特殊教育","体育教育","运动训练","社会体育指导与管理","教育技术学"]', '教育基本理论的总纲，教资与教育考研第一门',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E9%81%93%E4%BF%8A%E6%95%99%E8%82%B2%E5%AD%A6%E5%8E%9F%E7%90%86', 2180)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('教育心理学', '教育课堂', '法政教育', '教育心理学,学习理论,动机,迁移', 'INTERMEDIATE',
 '["教育学","学前教育","小学教育","特殊教育","体育教育","运动训练","社会体育指导与管理","教育技术学","心理学","社会工作","社会学","护理学","临床医学"]', '学生怎么学、老师怎么教，教资笔试核心科目',
 'https://search.bilibili.com/all?keyword=%E6%95%99%E8%82%B2%E5%BF%83%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2190)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('课程与教学论', '教育课堂', '法政教育', '教学设计,课程,教学目标,评价', 'INTERMEDIATE',
 '["教育学","小学教育","学前教育","特殊教育","教育技术学","汉语言文学","数学与应用数学","英语"]', '从课程标准到一节课的设计，师范生必备',
 'https://search.bilibili.com/all?keyword=%E8%AF%BE%E7%A8%8B%E4%B8%8E%E6%95%99%E5%AD%A6%E8%AE%BA', 2200)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('学前教育学与儿童发展', '学前课堂', '法政教育', '学前教育学,儿童发展,游戏,幼儿园', 'BEGINNER',
 '["学前教育","小学教育","特殊教育","音乐学","美术学"]', '0-6 岁发展规律与幼儿园课程设计',
 'https://search.bilibili.com/all?keyword=%E5%AD%A6%E5%89%8D%E6%95%99%E8%82%B2%E5%AD%A6%E5%84%BF%E7%AB%A5%E5%8F%91%E5%B1%95', 2210)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('特殊教育导论', '特教课堂', '法政教育', '特殊教育,融合教育,个别化计划', 'BEGINNER',
 '["特殊教育","教育学","小学教育","学前教育","康复治疗学","社会工作"]', '特殊需要儿童的评估与支持，特教方向入门',
 'https://search.bilibili.com/all?keyword=%E7%89%B9%E6%AE%8A%E6%95%99%E8%82%B2%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2220)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('运动解剖学', '体育课堂', '法政教育', '运动解剖,骨骼肌,关节,动作分析', 'BEGINNER',
 '["体育教育","运动训练","社会体育指导与管理","康复治疗学","护理学"]', '把解剖学落到动作分析上，体育与康复共用',
 'https://search.bilibili.com/all?keyword=%E8%BF%90%E5%8A%A8%E8%A7%A3%E5%89%96%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2230)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('运动生理学', '体育课堂', '法政教育', '运动生理,能量代谢,心肺,训练适应', 'INTERMEDIATE',
 '["体育教育","运动训练","社会体育指导与管理","康复治疗学","护理学"]', '运动时身体如何供能与适应，训练课的理论依据',
 'https://search.bilibili.com/all?keyword=%E8%BF%90%E5%8A%A8%E7%94%9F%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2240)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('运动训练学', '体育课堂', '法政教育', '运动训练,周期,负荷,体能,技能', 'INTERMEDIATE',
 '["运动训练","体育教育","社会体育指导与管理"]', '训练计划与负荷安排，教练与体育教师方向主干',
 'https://search.bilibili.com/all?keyword=%E8%BF%90%E5%8A%A8%E8%AE%AD%E7%BB%83%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2250)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('申论与公文写作 · 系统课', '粉笔公考', '职场技能', '申论,公文写作,归纳概括,对策', 'BEGINNER',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理","工商管理","会计学","财务管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程","汉语言文学","新闻学"]', '从材料提炼到规范成文，考公与行政岗都实用',
 'https://search.bilibili.com/all?keyword=%E7%B2%89%E7%AC%94%E7%94%B3%E8%AE%BA%E5%85%AC%E6%96%87%E5%86%99%E4%BD%9C', 2270)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中国古代文学史 · 袁行霈版', '文学考研阿甘', '人文艺术', '古代文学,先秦,唐诗,宋词,明清小说', 'INTERMEDIATE',
 '["汉语言文学","汉语言","汉语国际教育","新闻学","广告学","编辑出版学","网络与新媒体","戏剧影视文学","广播电视学","传播学","历史学"]', '按袁行霈教材梳理文学脉络，中文方向主干课',
 'https://search.bilibili.com/all?keyword=%E8%A2%81%E8%A1%8C%E9%9C%88%E4%B8%AD%E5%9B%BD%E5%8F%A4%E4%BB%A3%E6%96%87%E5%AD%A6%E5%8F%B2', 2260)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中国现代文学三十年', '文学考研阿甘', '人文艺术', '现代文学,鲁迅,茅盾,沈从文,流派', 'INTERMEDIATE',
 '["汉语言文学","汉语言","汉语国际教育","戏剧影视文学","新闻学"]', '从五四到四十年代的作家与思潮',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E5%9B%BD%E7%8E%B0%E4%BB%A3%E6%96%87%E5%AD%A6%E4%B8%89%E5%8D%81%E5%B9%B4', 2270)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('现代汉语 · 黄伯荣廖序东', '语言学课堂', '人文艺术', '现代汉语,语音,词汇,语法,修辞', 'BEGINNER',
 '["汉语言文学","汉语言","汉语国际教育","编辑出版学","播音与主持艺术"]', '把天天说的汉语拆成可分析的系统',
 'https://search.bilibili.com/all?keyword=%E9%BB%84%E4%BC%AF%E8%8D%A3%E5%BB%96%E5%BA%8F%E4%B8%9C%E7%8E%B0%E4%BB%A3%E6%B1%89%E8%AF%AD', 2280)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('古代汉语 · 王力', '王力', '人文艺术', '古代汉语,文言,文字,音韵,训诂', 'INTERMEDIATE',
 '["汉语言文学","汉语言","汉语国际教育","历史学","考古学","文物与博物馆学"]', '读懂古籍的文字、音韵与训诂基本功',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E5%8A%9B%E5%8F%A4%E4%BB%A3%E6%B1%89%E8%AF%AD', 2290)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('文学概论 · 童庆炳', '文学理论课堂', '人文艺术', '文学理论,文本,叙事,典型,接受', 'INTERMEDIATE',
 '["汉语言文学","汉语言","汉语国际教育","戏剧影视文学","编辑出版学"]', '用理论工具分析文本，中文系的方法课',
 'https://search.bilibili.com/all?keyword=%E7%AB%A5%E5%BA%86%E7%82%B3%E6%96%87%E5%AD%A6%E6%A6%82%E8%AE%BA', 2300)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中国通史 · 古代史', '历史课堂', '人文艺术', '中国史,朝代,制度,史事', 'BEGINNER',
 '["历史学","考古学","文物与博物馆学","世界史","汉语言文学","旅游管理","哲学","思想政治教育"]', '按朝代串起制度与事件，历史方向入门',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E5%9B%BD%E9%80%9A%E5%8F%B2%E5%8F%A4%E4%BB%A3%E5%8F%B2', 2310)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('世界近代史', '历史课堂', '人文艺术', '世界史,近代,工业革命,国际关系', 'INTERMEDIATE',
 '["世界史","历史学","国际政治","政治学与行政学","文物与博物馆学"]', '从地理大发现到二十世纪的世界格局',
 'https://search.bilibili.com/all?keyword=%E4%B8%96%E7%95%8C%E8%BF%91%E4%BB%A3%E5%8F%B2%E8%AF%BE%E7%A8%8B', 2320)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('考古学概论', '考古课堂', '人文艺术', '考古学,地层学,类型学,遗址', 'BEGINNER',
 '["考古学","历史学","文物与博物馆学"]', '田野方法与分期逻辑，考古方向入门',
 'https://search.bilibili.com/all?keyword=%E8%80%83%E5%8F%A4%E5%AD%A6%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2330)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('文物与博物馆学导论', '文博课堂', '人文艺术', '博物馆学,文物,陈列,藏品管理', 'BEGINNER',
 '["文物与博物馆学","考古学","历史学","旅游管理"]', '藏品、陈列与公众教育，文博方向总纲',
 'https://search.bilibili.com/all?keyword=%E6%96%87%E7%89%A9%E4%B8%8E%E5%8D%9A%E7%89%A9%E9%A6%86%E5%AD%A6%E5%AF%BC%E8%AE%BA', 2340)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('史学理论与方法', '历史课堂', '人文艺术', '史学理论,史料,考证,史学史', 'ADVANCED',
 '["历史学","世界史","考古学","文物与博物馆学","哲学"]', '史料批判与解释框架，历史研究的method课',
 'https://search.bilibili.com/all?keyword=%E5%8F%B2%E5%AD%A6%E7%90%86%E8%AE%BA%E4%B8%8E%E6%96%B9%E6%B3%95', 2350)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中国哲学史 · 冯友兰', '哲学课堂', '人文艺术', '中国哲学,先秦诸子,宋明理学,道家', 'INTERMEDIATE',
 '["哲学","逻辑学","宗教学","伦理学","汉语言文学","历史学"]', '从孔孟老庄到理学，中国思想的主线',
 'https://search.bilibili.com/all?keyword=%E5%86%AF%E5%8F%8B%E5%85%B0%E4%B8%AD%E5%9B%BD%E5%93%B2%E5%AD%A6%E5%8F%B2', 2360)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('西方哲学史 · 赵敦华', '赵敦华', '人文艺术', '西方哲学,古希腊,康德,黑格尔', 'INTERMEDIATE',
 '["哲学","逻辑学","宗教学","伦理学","历史学","社会学"]', '按问题线索梳理两千年西方哲学',
 'https://search.bilibili.com/all?keyword=%E8%B5%B5%E6%95%A6%E5%8D%8E%E8%A5%BF%E6%96%B9%E5%93%B2%E5%AD%A6%E5%8F%B2', 2370)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('逻辑学导论', '逻辑学课堂', '人文艺术', '逻辑学,命题,推理,谬误,论证', 'BEGINNER',
 '["逻辑学","哲学","法学","思想政治教育","数学与应用数学","计算机科学与技术"]', '把论证拆成前提与结论，写论文与辩论都用得上',
 'https://search.bilibili.com/all?keyword=%E9%80%BB%E8%BE%91%E5%AD%A6%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2380)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('宗教学导论', '宗教学课堂', '人文艺术', '宗教学,宗教现象,仪式,比较', 'BEGINNER',
 '["宗教学","哲学","历史学","社会学","世界史"]', '以比较与现象学的视角理解宗教',
 'https://search.bilibili.com/all?keyword=%E5%AE%97%E6%95%99%E5%AD%A6%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2390)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('伦理学导论', '伦理学课堂', '人文艺术', '伦理学,善恶,义务,德性,应用伦理', 'BEGINNER',
 '["伦理学","哲学","思想政治教育","法学","临床医学"]', '从规范伦理到现实两难，哲学与医学人文共用',
 'https://search.bilibili.com/all?keyword=%E4%BC%A6%E7%90%86%E5%AD%A6%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2400)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('新闻学概论', '新闻课堂', '人文艺术', '新闻学,新闻价值,采访,报道', 'BEGINNER',
 '["新闻学","广播电视学","广告学","传播学","编辑出版学","网络与新媒体","广播电视编导","播音与主持艺术","摄影","汉语言文学","数字媒体艺术","动画"]', '新闻生产的基本规范与价值判断',
 'https://search.bilibili.com/all?keyword=%E6%96%B0%E9%97%BB%E5%AD%A6%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2410)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('传播学教程 · 郭庆光', '传播学课堂', '人文艺术', '传播学,5W,效果,议程设置,受众', 'INTERMEDIATE',
 '["新闻学","广播电视学","广告学","传播学","编辑出版学","网络与新媒体","广播电视编导","播音与主持艺术","摄影","汉语言文学","数字媒体艺术","动画","社会学","市场营销"]', '传播过程与效果理论，新传考研第一门',
 'https://search.bilibili.com/all?keyword=%E9%83%AD%E5%BA%86%E5%85%89%E4%BC%A0%E6%92%AD%E5%AD%A6%E6%95%99%E7%A8%8B', 2420)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('广告学概论', '广告课堂', '人文艺术', '广告学,创意,媒介,品牌,策划', 'BEGINNER',
 '["广告学","市场营销","传播学","网络与新媒体","视觉传达设计","电子商务"]', '从策略到创意表现，广告与营销方向入门',
 'https://search.bilibili.com/all?keyword=%E5%B9%BF%E5%91%8A%E5%AD%A6%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2430)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('广播电视概论', '广电课堂', '人文艺术', '广播电视,节目,编导,制作流程', 'BEGINNER',
 '["广播电视学","广播电视编导","新闻学","传播学","播音与主持艺术","戏剧影视文学"]', '节目形态与制作流程，广电方向总纲',
 'https://search.bilibili.com/all?keyword=%E5%B9%BF%E6%92%AD%E7%94%B5%E8%A7%86%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2440)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('普通话与播音发声', '播音课堂', '人文艺术', '普通话,发声,气息,吐字,朗诵', 'BEGINNER',
 '["播音与主持艺术","广播电视编导","音乐学","戏剧影视文学","小学教育","学前教育"]', '气息与吐字归音训练，主持与师范方向通用',
 'https://search.bilibili.com/all?keyword=%E6%99%AE%E9%80%9A%E8%AF%9D%E6%92%AD%E9%9F%B3%E5%8F%91%E5%A3%B0%E8%AE%AD%E7%BB%83', 2450)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('摄影基础与构图', '摄影课堂', '人文艺术', '摄影,光圈,快门,构图,用光', 'BEGINNER',
 '["摄影","数字媒体艺术","视觉传达设计","广播电视编导","网络与新媒体","广告学"]', '从曝光三要素到画面语言，影像入门',
 'https://search.bilibili.com/all?keyword=%E6%91%84%E5%BD%B1%E5%9F%BA%E7%A1%80%E4%B8%8E%E6%9E%84%E5%9B%BE%E8%AF%BE%E7%A8%8B', 2460)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中外美术史', '美术史课堂', '人文艺术', '美术史,流派,名作,中国画,西方绘画', 'BEGINNER',
 '["音乐学","音乐表演","美术学","绘画","雕塑","视觉传达设计","环境设计","产品设计","服装与服饰设计","数字媒体艺术","动画","戏剧影视文学","广播电视编导","播音与主持艺术","摄影","建筑学","城乡规划","风景园林","园林","数字媒体技术","历史学"]', '按流派读作品，造型与史论方向共同基础',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E5%A4%96%E7%BE%8E%E6%9C%AF%E5%8F%B2%E8%AF%BE%E7%A8%8B', 2280)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('艺术概论', '艺术理论课堂', '人文艺术', '艺术概论,本质,创作,鉴赏,门类', 'BEGINNER',
 '["音乐学","音乐表演","美术学","绘画","雕塑","视觉传达设计","环境设计","产品设计","服装与服饰设计","数字媒体艺术","动画","戏剧影视文学","广播电视编导","播音与主持艺术","摄影","建筑学","城乡规划","风景园林","园林","数字媒体技术"]', '艺术门类与创作鉴赏的基本框架',
 'https://search.bilibili.com/all?keyword=%E8%89%BA%E6%9C%AF%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2470)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('乐理与视唱练耳', '音乐课堂', '人文艺术', '乐理,五线谱,音程,节奏,视唱', 'BEGINNER',
 '["音乐学","音乐表演","播音与主持艺术","学前教育","小学教育","戏剧影视文学"]', '识谱与听辨的基本功，音乐方向第一课',
 'https://search.bilibili.com/all?keyword=%E4%B9%90%E7%90%86%E8%A7%86%E5%94%B1%E7%BB%83%E8%80%B3%E5%85%A5%E9%97%A8', 2480)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('中国音乐史与欣赏', '音乐课堂', '人文艺术', '中国音乐史,民歌,戏曲,器乐', 'BEGINNER',
 '["音乐学","音乐表演","戏剧影视文学","学前教育","小学教育"]', '从民歌戏曲到近现代作品的听觉地图',
 'https://search.bilibili.com/all?keyword=%E4%B8%AD%E5%9B%BD%E9%9F%B3%E4%B9%90%E5%8F%B2%E4%B8%8E%E6%AC%A3%E8%B5%8F', 2490)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('戏剧影视文学与剧本创作', '编剧课堂', '人文艺术', '剧本,剧作结构,人物,冲突,分镜', 'INTERMEDIATE',
 '["戏剧影视文学","广播电视编导","汉语言文学","动画","数字媒体艺术"]', '三幕结构与人物弧光，从想法到可拍的剧本',
 'https://search.bilibili.com/all?keyword=%E6%88%8F%E5%89%A7%E5%BD%B1%E8%A7%86%E6%96%87%E5%AD%A6%E5%89%A7%E6%9C%AC%E5%88%9B%E4%BD%9C', 2500)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('设计基础 · 三大构成', '设计课堂', '人文艺术', '平面构成,色彩构成,立体构成,设计基础', 'BEGINNER',
 '["视觉传达设计","环境设计","产品设计","服装与服饰设计","数字媒体艺术","动画","美术学","绘画","雕塑","摄影","建筑学","风景园林","园林","音乐学","音乐表演","戏剧影视文学","广播电视编导","播音与主持艺术","城乡规划","数字媒体技术"]', '构成训练是设计类专业的共同起跑线',
 'https://search.bilibili.com/all?keyword=%E4%B8%89%E5%A4%A7%E6%9E%84%E6%88%90%E8%AE%BE%E8%AE%A1%E5%9F%BA%E7%A1%80', 2510)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('素描与手绘基础', '手绘课堂', '人文艺术', '素描,透视,明暗,速写,手绘', 'BEGINNER',
 '["美术学","绘画","雕塑","视觉传达设计","环境设计","产品设计","动画","建筑学","风景园林"]', '从线条与透视开始，造型能力的第一课',
 'https://search.bilibili.com/all?keyword=%E7%B4%A0%E6%8F%8F%E6%89%8B%E7%BB%98%E5%9F%BA%E7%A1%80%E6%95%99%E7%A8%8B', 2520)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('植物学', '农林课堂', '农林生命', '植物学,形态,分类,解剖', 'BEGINNER',
 '["农学","园艺","植物保护","林学","园林","草业科学","生物科学","生态学","茶学","烟草"]', '从形态解剖到分类，农林方向第一门专业课',
 'https://search.bilibili.com/all?keyword=%E6%A4%8D%E7%89%A9%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2530)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('植物生理学', '农林课堂', '农林生命', '植物生理,光合,呼吸,激素,水分', 'INTERMEDIATE',
 '["农学","园艺","植物保护","林学","园林","草业科学","生物科学","生物技术","茶学","烟草"]', '作物生长背后的生理机制，农学主干课',
 'https://search.bilibili.com/all?keyword=%E6%A4%8D%E7%89%A9%E7%94%9F%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2540)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('动物学', '农林课堂', '农林生命', '动物学,分类,解剖,无脊椎,脊椎', 'BEGINNER',
 '["动物科学","动物医学","水产养殖学","生物科学","生物技术","生态学"]', '动物分类与比较解剖，动科动医的入门',
 'https://search.bilibili.com/all?keyword=%E5%8A%A8%E7%89%A9%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2550)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('动物生理学', '农林课堂', '农林生命', '动物生理,循环,消化,内分泌', 'INTERMEDIATE',
 '["动物科学","动物医学","水产养殖学","生物科学","生物技术"]', '家畜机体机能与调节，动医方向基础课',
 'https://search.bilibili.com/all?keyword=%E5%8A%A8%E7%89%A9%E7%94%9F%E7%90%86%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2560)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('生物化学 · 王镜岩', '王镜岩', '农林生命', '生物化学,蛋白质,酶,代谢,核酸', 'INTERMEDIATE',
 '["生物科学","生物技术","生物工程","生态学","食品科学与工程","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","基础医学","临床医学","药学","医学检验技术","预防医学"]', '从蛋白质结构到代谢通路，生命科学最硬的主干',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E9%95%9C%E5%B2%A9%E7%94%9F%E7%89%A9%E5%8C%96%E5%AD%A6', 2290)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('分子生物学', '分子生物课堂', '农林生命', '分子生物学,DNA,转录,翻译,基因表达', 'ADVANCED',
 '["生物科学","生物技术","生物工程","生态学","食品科学与工程","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","基础医学","临床医学","药学","医学检验技术","预防医学"]', '中心法则与基因表达调控，生科进阶课',
 'https://search.bilibili.com/all?keyword=%E5%88%86%E5%AD%90%E7%94%9F%E7%89%A9%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2300)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('细胞生物学', '细胞生物课堂', '农林生命', '细胞生物学,细胞器,信号,周期,凋亡', 'INTERMEDIATE',
 '["生物科学","生物技术","生物工程","生态学","食品科学与工程","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","基础医学","临床医学","药学","医学检验技术","预防医学"]', '细胞结构与生命活动，生科与医学共用基础',
 'https://search.bilibili.com/all?keyword=%E7%BB%86%E8%83%9E%E7%94%9F%E7%89%A9%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2310)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('遗传学 · 刘祖洞', '刘祖洞', '农林生命', '遗传学,孟德尔,连锁,变异,群体遗传', 'INTERMEDIATE',
 '["生物科学","生物技术","生物工程","生态学","食品科学与工程","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","基础医学","临床医学","药学","医学检验技术","预防医学"]', '从分离定律到群体遗传，育种与医学都要用',
 'https://search.bilibili.com/all?keyword=%E5%88%98%E7%A5%96%E6%B4%9E%E9%81%97%E4%BC%A0%E5%AD%A6', 2320)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('微生物学', '微生物课堂', '农林生命', '微生物学,细菌,真菌,培养,代谢', 'INTERMEDIATE',
 '["生物科学","生物技术","生物工程","生态学","食品科学与工程","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","基础医学","临床医学","药学","医学检验技术","预防医学","环境工程"]', '微生物形态、培养与代谢，发酵与检验的基础',
 'https://search.bilibili.com/all?keyword=%E5%BE%AE%E7%94%9F%E7%89%A9%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2330)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('生态学基础', '生态课堂', '农林生命', '生态学,种群,群落,生态系统,生物多样性', 'BEGINNER',
 '["生态学","生物科学","生物技术","环境工程","林学","园林","草业科学","地理科学","水产养殖学"]', '从种群到生态系统的层次与规律',
 'https://search.bilibili.com/all?keyword=%E7%94%9F%E6%80%81%E5%AD%A6%E5%9F%BA%E7%A1%80%E8%AF%BE%E7%A8%8B', 2570)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('土壤肥料学', '农资课堂', '农林生命', '土壤学,肥料,养分,土壤性质', 'INTERMEDIATE',
 '["农学","园艺","植物保护","林学","园林","草业科学","茶学","烟草","环境工程"]', '土、肥、水三要素里的前两项，农学实操课',
 'https://search.bilibili.com/all?keyword=%E5%9C%9F%E5%A3%A4%E8%82%A5%E6%96%99%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2580)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('作物栽培学与耕作学', '农学课堂', '农林生命', '作物栽培,耕作,播期,田间管理', 'INTERMEDIATE',
 '["农学","园艺","植物保护","茶学","烟草","草业科学"]', '从播期到收获的田间决策逻辑',
 'https://search.bilibili.com/all?keyword=%E4%BD%9C%E7%89%A9%E6%A0%BD%E5%9F%B9%E5%AD%A6%E4%B8%8E%E8%80%95%E4%BD%9C%E5%AD%A6', 2590)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('农业昆虫与植物病理', '植保课堂', '农林生命', '植物保护,农业昆虫,病害,虫害,防治', 'INTERMEDIATE',
 '["植物保护","农学","园艺","林学","园林","茶学","烟草"]', '病虫识别与综合治理，植保方向主干',
 'https://search.bilibili.com/all?keyword=%E5%86%9C%E4%B8%9A%E6%98%86%E8%99%AB%E4%B8%8E%E6%A4%8D%E7%89%A9%E7%97%85%E7%90%86', 2600)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('动物营养与饲料', '动科课堂', '农林生命', '动物营养,饲料,配方,消化', 'INTERMEDIATE',
 '["动物科学","动物医学","水产养殖学","草业科学"]', '营养需要与日粮配方，动科方向核心课',
 'https://search.bilibili.com/all?keyword=%E5%8A%A8%E7%89%A9%E8%90%A5%E5%85%BB%E4%B8%8E%E9%A5%B2%E6%96%99%E8%AF%BE%E7%A8%8B', 2610)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('兽医临床诊断', '动医课堂', '农林生命', '兽医,临床诊断,检查,病例', 'INTERMEDIATE',
 '["动物医学","动物科学","水产养殖学"]', '临床检查方法与常见病例分析',
 'https://search.bilibili.com/all?keyword=%E5%85%BD%E5%8C%BB%E4%B8%B4%E5%BA%8A%E8%AF%8A%E6%96%AD%E8%AF%BE%E7%A8%8B', 2620)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('森林生态与林木育种', '林学课堂', '农林生命', '林学,森林生态,林木育种,森林经营', 'INTERMEDIATE',
 '["林学","园林","风景园林","生态学","草业科学"]', '森林群落与良种选育，林学方向主干',
 'https://search.bilibili.com/all?keyword=%E6%A3%AE%E6%9E%97%E7%94%9F%E6%80%81%E4%B8%8E%E6%9E%97%E6%9C%A8%E8%82%B2%E7%A7%8D', 2630)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('园林植物与景观设计', '园林课堂', '农林生命', '园林植物,景观设计,配置,绿地', 'INTERMEDIATE',
 '["园林","风景园林","环境设计","园艺","林学","城乡规划"]', '植物配置与场地设计，园林与景观共用',
 'https://search.bilibili.com/all?keyword=%E5%9B%AD%E6%9E%97%E6%A4%8D%E7%89%A9%E4%B8%8E%E6%99%AF%E8%A7%82%E8%AE%BE%E8%AE%A1', 2640)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('鱼类学与水产养殖', '水产课堂', '农林生命', '水产养殖,鱼类学,水质,苗种', 'INTERMEDIATE',
 '["水产养殖学","动物科学","动物医学","海洋科学","生物科学"]', '养殖对象与水体管理，水产方向入门',
 'https://search.bilibili.com/all?keyword=%E9%B1%BC%E7%B1%BB%E5%AD%A6%E6%B0%B4%E4%BA%A7%E5%85%BB%E6%AE%96%E8%AF%BE%E7%A8%8B', 2650)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('草业科学概论', '草业课堂', '农林生命', '草业科学,牧草,草地,草坪', 'BEGINNER',
 '["草业科学","农学","园艺","动物科学","生态学","园林","林学"]', '草地资源与牧草利用，草业方向全景',
 'https://search.bilibili.com/all?keyword=%E8%8D%89%E4%B8%9A%E7%A7%91%E5%AD%A6%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2660)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('茶学概论', '茶学课堂', '农林生命', '茶学,茶树,制茶,审评,茶文化', 'BEGINNER',
 '["茶学","农学","园艺","食品科学与工程","旅游管理","市场营销"]', '从栽培到加工审评，茶学方向入门',
 'https://search.bilibili.com/all?keyword=%E8%8C%B6%E5%AD%A6%E6%A6%82%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2670)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('烟草栽培与加工', '烟草课堂', '农林生命', '烟草,栽培,调制,分级', 'BEGINNER',
 '["烟草","农学","园艺","植物保护","食品科学与工程","化学工程与工艺"]', '烟草生产与初加工全流程，特色方向专业课',
 'https://search.bilibili.com/all?keyword=%E7%83%9F%E8%8D%89%E6%A0%BD%E5%9F%B9%E4%B8%8E%E5%8A%A0%E5%B7%A5%E8%AF%BE%E7%A8%8B', 2680)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('食品化学', '食品课堂', '农林生命', '食品化学,成分,褐变,风味,营养', 'INTERMEDIATE',
 '["食品科学与工程","生物工程","轻化工程","化学","应用化学","农学"]', '食品成分在加工中的变化，食品方向主干',
 'https://search.bilibili.com/all?keyword=%E9%A3%9F%E5%93%81%E5%8C%96%E5%AD%A6%E8%AF%BE%E7%A8%8B', 2690)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('食品微生物与加工工艺', '食品课堂', '农林生命', '食品微生物,发酵,杀菌,保藏,加工', 'INTERMEDIATE',
 '["食品科学与工程","生物工程","轻化工程","生物技术","农学","动物科学"]', '从发酵到保藏，食品加工与安全的基础',
 'https://search.bilibili.com/all?keyword=%E9%A3%9F%E5%93%81%E5%BE%AE%E7%94%9F%E7%89%A9%E4%B8%8E%E5%8A%A0%E5%B7%A5%E5%B7%A5%E8%89%BA', 2700)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('发酵工程与生物工艺', '生工课堂', '农林生命', '发酵工程,生物反应器,下游,代谢', 'INTERMEDIATE',
 '["生物工程","生物技术","食品科学与工程","制药工程","化学工程与工艺","轻化工程"]', '把实验室菌株放大成生产流程，生工方向主干',
 'https://search.bilibili.com/all?keyword=%E5%8F%91%E9%85%B5%E5%B7%A5%E7%A8%8B%E4%B8%8E%E7%94%9F%E7%89%A9%E5%B7%A5%E8%89%BA', 2710)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('生物统计学与试验设计', '生统课堂', '农林生命', '生物统计,试验设计,方差分析,田间试验', 'INTERMEDIATE',
 '["农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草","生物科学","生物技术","生态学","统计学","食品科学与工程"]', '田间与实验室数据的统计分析，农林科研工具课',
 'https://search.bilibili.com/all?keyword=%E7%94%9F%E7%89%A9%E7%BB%9F%E8%AE%A1%E5%AD%A6%E4%B8%8E%E8%AF%95%E9%AA%8C%E8%AE%BE%E8%AE%A1', 2720)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Photoshop 从入门到精通', 'oeasy', '设计创作', 'Photoshop,PS,抠图,图层,修图', 'BEGINNER',
 '["视觉传达设计","环境设计","产品设计","服装与服饰设计","数字媒体艺术","动画","美术学","绘画","雕塑","摄影","建筑学","风景园林","园林","新闻学","广播电视学","广告学","传播学","编辑出版学","网络与新媒体","广播电视编导","播音与主持艺术","汉语言文学","数字媒体技术","电子商务"]', '从图层到抠图调色，设计方向第一门工具课',
 'https://search.bilibili.com/all?keyword=oeasy+Photoshop%E6%95%99%E7%A8%8B', 2340)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Illustrator 矢量设计 · oeasy', 'oeasy', '设计创作', 'Illustrator,AI,矢量,LOGO,插画', 'BEGINNER',
 '["视觉传达设计","环境设计","产品设计","服装与服饰设计","数字媒体艺术","动画","美术学","绘画","雕塑","摄影","建筑学","风景园林","园林","广告学","数字媒体技术"]', '矢量图形与标志设计，和 PS 互补的另一半',
 'https://search.bilibili.com/all?keyword=oeasy+Illustrator%E6%95%99%E7%A8%8B', 2730)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('视频剪辑 Premiere 入门到实战', 'doyoudo', '设计创作', 'Premiere,PR,剪辑,转场,调色', 'BEGINNER',
 '["新闻学","广播电视学","广告学","传播学","编辑出版学","网络与新媒体","广播电视编导","播音与主持艺术","摄影","汉语言文学","数字媒体艺术","动画","音乐学","音乐表演","美术学","绘画","雕塑","视觉传达设计","环境设计","产品设计","服装与服饰设计","戏剧影视文学","建筑学","城乡规划","风景园林","园林","数字媒体技术","电子商务"]', '从素材整理到成片输出，短视频与课程作业都用得上',
 'https://search.bilibili.com/all?keyword=doyoudo+Premiere%E6%95%99%E7%A8%8B', 2350)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('After Effects 动效入门', 'doyoudo', '设计创作', 'After Effects,AE,动效,关键帧,合成', 'INTERMEDIATE',
 '["数字媒体艺术","动画","广播电视编导","视觉传达设计","数字媒体技术","网络与新媒体"]', '关键帧与合成，把静态画面做成动态表达',
 'https://search.bilibili.com/all?keyword=doyoudo+After+Effects%E6%95%99%E7%A8%8B', 2740)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('C4D 三维设计入门', '三维课堂', '设计创作', 'C4D,三维建模,渲染,材质', 'INTERMEDIATE',
 '["数字媒体艺术","动画","视觉传达设计","产品设计","环境设计","广告学"]', '建模、材质到渲染的三维工作流',
 'https://search.bilibili.com/all?keyword=C4D%E4%B8%89%E7%BB%B4%E8%AE%BE%E8%AE%A1%E5%85%A5%E9%97%A8', 2750)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('UI 设计与 Figma 实战', 'UI课堂', '设计创作', 'UI设计,Figma,原型,组件,交互', 'INTERMEDIATE',
 '["视觉传达设计","数字媒体艺术","数字媒体技术","软件工程","计算机科学与技术","产品设计"]', '从线框到可交互原型，产品与前端协作的通用语言',
 'https://search.bilibili.com/all?keyword=Figma+UI%E8%AE%BE%E8%AE%A1%E5%AE%9E%E6%88%98', 2760)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('SketchUp 与 Revit 建筑表现', 'BIM课堂', '设计创作', 'SketchUp,Revit,BIM,建模,表现', 'INTERMEDIATE',
 '["建筑学","城乡规划","风景园林","环境设计","土木工程","工程管理","工程造价"]', '从体块推敲到 BIM 模型，建筑与造价方向工具课',
 'https://search.bilibili.com/all?keyword=SketchUp+Revit%E5%BB%BA%E7%AD%91%E8%A1%A8%E7%8E%B0', 2770)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('动画运动规律', '动画课堂', '设计创作', '动画,运动规律,关键帧,原画,节奏', 'INTERMEDIATE',
 '["动画","数字媒体艺术","数字媒体技术","戏剧影视文学","广播电视编导"]', '让角色动得可信，动画专业的核心训练',
 'https://search.bilibili.com/all?keyword=%E5%8A%A8%E7%94%BB%E8%BF%90%E5%8A%A8%E8%A7%84%E5%BE%8B%E8%AF%BE%E7%A8%8B', 2780)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('数字媒体艺术概论', '数媒课堂', '设计创作', '数字媒体艺术,交互,新媒体,影像', 'BEGINNER',
 '["数字媒体艺术","数字媒体技术","动画","网络与新媒体","广播电视编导","视觉传达设计"]', '技术与艺术交叉的领域地图，数媒方向总纲',
 'https://search.bilibili.com/all?keyword=%E6%95%B0%E5%AD%97%E5%AA%92%E4%BD%93%E8%89%BA%E6%9C%AF%E6%A6%82%E8%AE%BA', 2790)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('Excel 从入门到精通 · 王佩丰 24 讲', '王佩丰', '职场技能', 'Excel,函数,数据透视表,图表,办公', 'BEGINNER',
 '["*"]', '函数与数据透视表讲得最透的一套，实习前必刷',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E4%BD%A9%E4%B8%B0Excel24%E8%AE%B2', 3160)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('PPT 设计与汇报表达', '秋叶', '职场技能', 'PPT,汇报,排版,演示,答辩', 'BEGINNER',
 '["*"]', '把内容讲成故事，答辩、汇报、竞赛路演都用得上',
 'https://search.bilibili.com/all?keyword=%E7%A7%8B%E5%8F%B6PPT%E8%AE%BE%E8%AE%A1%E8%AF%BE%E7%A8%8B', 3170)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('大学生求职：简历与面试实战', '张雪峰老师', '职场技能', '简历,面试,求职,实习,职业规划', 'BEGINNER',
 '["*"]', '从简历改写至模拟面试，大四找工作的实操指南',
 'https://search.bilibili.com/all?keyword=%E5%BC%A0%E9%9B%AA%E5%B3%B0%E7%AE%80%E5%8E%86%E4%B8%8E%E9%9D%A2%E8%AF%95', 3180)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('职场沟通与协作表达', '职场课堂', '职场技能', '沟通,协作,会议,汇报,反馈', 'BEGINNER',
 '["*"]', '小组作业到实习汇报都用得到的表达方法',
 'https://search.bilibili.com/all?keyword=%E8%81%8C%E5%9C%BA%E6%B2%9F%E9%80%9A%E4%B8%8E%E5%8D%8F%E4%BD%9C%E8%A1%A8%E8%BE%BE', 3190)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('大学生职业规划与决策', '生涯课堂', '职场技能', '职业规划,决策,目标,选择', 'BEGINNER',
 '["*"]', '考研、就业、考公怎么选，先建立自己的判断框架',
 'https://search.bilibili.com/all?keyword=%E5%A4%A7%E5%AD%A6%E7%94%9F%E8%81%8C%E4%B8%9A%E8%A7%84%E5%88%92%E8%AF%BE%E7%A8%8B', 3200)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('英语四六级全程班', '刘晓艳', '外语提升', '四级,六级,词汇,听力,阅读,写作', 'BEGINNER',
 '["*"]', '词汇到真题的完整备考链路，大学最刚需的一门',
 'https://search.bilibili.com/all?keyword=%E5%88%98%E6%99%93%E8%89%B3%E8%8B%B1%E8%AF%AD%E5%9B%9B%E5%85%AD%E7%BA%A7', 3210)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('英语口语零基础到流利表达', '英语兔', '外语提升', '英语口语,发音,连读,日常表达', 'BEGINNER',
 '["*"]', '从音标到连读，把「哑巴英语」练成能开口',
 'https://search.bilibili.com/all?keyword=%E8%8B%B1%E8%AF%AD%E5%85%94%E8%8B%B1%E8%AF%AD%E5%8F%A3%E8%AF%AD', 3220)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('英语语法精讲 · 英语兔', '英语兔', '外语提升', '英语语法,时态,从句,长难句', 'BEGINNER',
 '["英语","俄语","日语","德语","法语","西班牙语","朝鲜语","翻译","汉语国际教育","国际经济与贸易","汉语言文学","新闻学"]', '把语法讲成结构图，长难句一眼看懂',
 'https://search.bilibili.com/all?keyword=%E8%8B%B1%E8%AF%AD%E5%85%94%E8%8B%B1%E8%AF%AD%E8%AF%AD%E6%B3%95', 2800)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('日语入门 · 标准日本语初级', '圆圆的日语教室', '外语提升', '日语,五十音,标日,初级,语法', 'BEGINNER',
 '["日语","翻译","汉语国际教育","国际经济与贸易","旅游管理"]', '五十音到初级语法，二外与日语方向起步',
 'https://search.bilibili.com/all?keyword=%E6%A0%87%E5%87%86%E6%97%A5%E6%9C%AC%E8%AF%AD%E5%88%9D%E7%BA%A7%E6%97%A5%E8%AF%AD%E5%85%A5%E9%97%A8', 2810)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('法语入门 · 零基础语音', '法语课堂', '外语提升', '法语,语音,入门,动词变位', 'BEGINNER',
 '["法语","翻译","汉语国际教育","国际经济与贸易"]', '语音与基础变位，法语方向第一门课',
 'https://search.bilibili.com/all?keyword=%E6%B3%95%E8%AF%AD%E9%9B%B6%E5%9F%BA%E7%A1%80%E5%85%A5%E9%97%A8', 2820)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('德语入门 · 零基础语音', '德语课堂', '外语提升', '德语,语音,格,入门', 'BEGINNER',
 '["德语","翻译","汉语国际教育","国际经济与贸易"]', '发音与格的框架先搭好，德语入门不再劝退',
 'https://search.bilibili.com/all?keyword=%E5%BE%B7%E8%AF%AD%E9%9B%B6%E5%9F%BA%E7%A1%80%E5%85%A5%E9%97%A8', 2830)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('西班牙语入门', '西语课堂', '外语提升', '西班牙语,发音,动词变位,入门', 'BEGINNER',
 '["西班牙语","翻译","汉语国际教育","国际经济与贸易"]', '发音规则与大舌音，西语零基础起步',
 'https://search.bilibili.com/all?keyword=%E8%A5%BF%E7%8F%AD%E7%89%99%E8%AF%AD%E5%85%A5%E9%97%A8%E8%AF%BE%E7%A8%8B', 2840)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('朝鲜语 / 韩语入门', '韩语课堂', '外语提升', '朝鲜语,韩语,韩文,发音,入门', 'BEGINNER',
 '["朝鲜语","翻译","汉语国际教育","国际经济与贸易"]', '从韩文字母到基础会话',
 'https://search.bilibili.com/all?keyword=%E9%9F%A9%E8%AF%AD%E6%9C%9D%E9%B2%9C%E8%AF%AD%E5%85%A5%E9%97%A8%E8%AF%BE%E7%A8%8B', 2850)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('俄语入门', '俄语课堂', '外语提升', '俄语,字母,发音,格,入门', 'BEGINNER',
 '["俄语","翻译","汉语国际教育","国际经济与贸易"]', '字母与发音打底，俄语方向起步',
 'https://search.bilibili.com/all?keyword=%E4%BF%84%E8%AF%AD%E9%9B%B6%E5%9F%BA%E7%A1%80%E5%85%A5%E9%97%A8', 2860)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('翻译理论与实践 · 英汉互译', '翻译课堂', '外语提升', '翻译,英汉互译,直译意译,笔译', 'INTERMEDIATE',
 '["翻译","英语","汉语言文学","汉语国际教育","新闻学"]', '从技巧到篇章，翻译方向的方法课',
 'https://search.bilibili.com/all?keyword=%E8%8B%B1%E6%B1%89%E4%BA%92%E8%AF%91%E7%BF%BB%E8%AF%91%E7%90%86%E8%AE%BA%E4%B8%8E%E5%AE%9E%E8%B7%B5', 2870)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('学术英语写作', '学术英语课堂', '外语提升', '学术英语,论文摘要,英文写作,投稿', 'INTERMEDIATE',
 '["英语","俄语","日语","德语","法语","西班牙语","朝鲜语","翻译","汉语国际教育","国际经济与贸易","计算机科学与技术","软件工程","人工智能","大数据科学与技术","电子信息工程","通信工程","自动化","电气工程及其自动化","机械工程","机械设计制造及其自动化","车辆工程","测控技术与仪器","材料科学与工程","材料成型及控制工程","能源与动力工程","土木工程","建筑学","城乡规划","风景园林","水利水电工程","测绘工程","化学工程与工艺","制药工程","环境工程","生物工程","食品科学与工程","纺织工程","轻化工程","交通运输","交通工程","船舶与海洋工程","航空航天工程","飞行器设计与工程","飞行器动力工程","核工程与核技术","安全工程","工业工程","物联网工程","网络工程","信息安全","数字媒体技术","智能科学与技术","机器人工程","数据科学与大数据技术","光电信息科学与工程","微电子科学与工程","集成电路设计与集成系统","电子科学与技术","数学与应用数学","信息与计算科学","物理学","应用物理学","化学","应用化学","生物科学","生物技术","生态学","天文学","地理科学","大气科学","海洋科学","地质学","地球物理学","心理学","统计学","临床医学","口腔医学","基础医学","预防医学","中医学","中西医临床医学","药学","中药学","护理学","医学检验技术","医学影像学","麻醉学","康复治疗学","法医学","针灸推拿学","农学","园艺","植物保护","动物科学","动物医学","林学","园林","水产养殖学","草业科学","茶学","烟草"]', '英文摘要与论文结构，写 SCI 与毕设的第一关',
 'https://search.bilibili.com/all?keyword=%E5%AD%A6%E6%9C%AF%E8%8B%B1%E8%AF%AD%E5%86%99%E4%BD%9C%E8%AF%BE%E7%A8%8B', 3230)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('第二外语学习方法与跨文化交际', '外语课堂', '外语提升', '二外,跨文化交际,语言学习,文化', 'BEGINNER',
 '["英语","俄语","日语","德语","法语","西班牙语","朝鲜语","翻译","汉语国际教育","国际经济与贸易","旅游管理","酒店管理"]', '语言学习策略与跨文化沟通，外语类专业通识',
 'https://search.bilibili.com/all?keyword=%E7%AC%AC%E4%BA%8C%E5%A4%96%E8%AF%AD%E4%B8%8E%E8%B7%A8%E6%96%87%E5%8C%96%E4%BA%A4%E9%99%85', 2880)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('考研数学全程 · 张宇', '张宇', '考研升学', '考研数学,高数,线代,概率,真题', 'ADVANCED',
 '["*"]', '按题型建立解题体系，考研数学长线备考',
 'https://search.bilibili.com/all?keyword=%E5%BC%A0%E5%AE%87%E8%80%83%E7%A0%94%E6%95%B0%E5%AD%A6%E5%85%A8%E7%A8%8B', 3240)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('考研政治 · 徐涛全程', '徐涛', '考研升学', '考研政治,马原,毛中特,史纲,时政', 'BEGINNER',
 '["*"]', '把政治讲成能理解的逻辑，而不是纯背诵',
 'https://search.bilibili.com/all?keyword=%E5%BE%90%E6%B6%9B%E8%80%83%E7%A0%94%E6%94%BF%E6%B2%BB%E5%85%A8%E7%A8%8B', 3250)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('考研英语 · 唐迟阅读', '唐迟', '考研升学', '考研英语,阅读,长难句,真题', 'INTERMEDIATE',
 '["*"]', '阅读方法论与真题精讲，考研英语提分主线',
 'https://search.bilibili.com/all?keyword=%E5%94%90%E8%BF%9F%E8%80%83%E7%A0%94%E8%8B%B1%E8%AF%AD%E9%98%85%E8%AF%BB', 3260)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('心理学导论 · 普通心理学', '心理学陈老师', '大学基础课', '普通心理学,感觉,知觉,记忆,动机', 'BEGINNER',
 '["心理学","教育学","学前教育","小学教育","特殊教育","社会工作","社会学","护理学","临床医学","教育技术学"]', '心理学第一门课，把研究对象与主要流派讲清楚',
 'https://search.bilibili.com/all?keyword=%E6%99%AE%E9%80%9A%E5%BF%83%E7%90%86%E5%AD%A6%E5%AF%BC%E8%AE%BA%E8%AF%BE%E7%A8%8B', 2890)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('实验心理学 · 心理统计与 SPSS 实操', '心理学考研小甜', '大学基础课', '实验心理学,变量控制,心理统计,SPSS', 'INTERMEDIATE',
 '["心理学","教育学","学前教育","小学教育","特殊教育","社会工作","社会学","护理学","临床医学","教育技术学","统计学"]', '从实验设计到数据统计，心理学实证研究入门',
 'https://search.bilibili.com/all?keyword=%E5%AE%9E%E9%AA%8C%E5%BF%83%E7%90%86%E5%AD%A6%E5%BF%83%E7%90%86%E7%BB%9F%E8%AE%A1SPSS', 2900)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('普通心理学 · 彭聃龄教材精讲（考研312）', '心理学考研晴子', '考研升学', '普通心理学,彭聃龄,考研312,心理学统考', 'INTERMEDIATE',
 '["心理学","教育学","学前教育","小学教育","特殊教育"]', '312 统考第一门主干课，按彭聃龄教材逐讲梳理',
 'https://search.bilibili.com/all?keyword=%E5%BD%AD%E8%81%83%E9%BE%84%E6%99%AE%E9%80%9A%E5%BF%83%E7%90%86%E5%AD%A6%E8%80%83%E7%A0%94312', 2910)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('社会心理学 · 经典理论与实验', '心理学的阿源', '大学基础课', '社会心理学,从众,归因,认知失调,群体', 'BEGINNER',
 '["心理学","教育学","学前教育","小学教育","特殊教育","社会工作","社会学","护理学","临床医学","教育技术学","传播学"]', '把从众、服从、归因这些经典实验讲透',
 'https://search.bilibili.com/all?keyword=%E7%A4%BE%E4%BC%9A%E5%BF%83%E7%90%86%E5%AD%A6%E7%BB%8F%E5%85%B8%E5%AE%9E%E9%AA%8C', 2920)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('发展心理学 · 毕生发展全程', '心理学考研小甜', '考研升学', '发展心理学,毕生发展,皮亚杰,儿童心理', 'BEGINNER',
 '["心理学","教育学","学前教育","小学教育","特殊教育","社会工作","社会学","护理学","临床医学","教育技术学"]', '从婴幼儿到老年的心理发展脉络',
 'https://search.bilibili.com/all?keyword=%E5%8F%91%E5%B1%95%E5%BF%83%E7%90%86%E5%AD%A6%E6%AF%95%E7%94%9F%E5%8F%91%E5%B1%95', 2930)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('心理咨询与治疗 · 入门导论', '壹心理课堂', '大学基础课', '心理咨询,倾听技术,个案,咨询伦理', 'INTERMEDIATE',
 '["心理学","教育学","学前教育","小学教育","特殊教育","社会工作","社会学","护理学","临床医学","教育技术学"]', '咨询伦理、倾听技术与常见流派入门',
 'https://search.bilibili.com/all?keyword=%E5%BF%83%E7%90%86%E5%92%A8%E8%AF%A2%E4%B8%8E%E6%B2%BB%E7%96%97%E5%85%A5%E9%97%A8', 2940)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('心理学考研 312 综合串讲', '心理学考研社', '考研升学', '心理学考研,312统考,普心,实验,统计', 'ADVANCED',
 '["心理学","教育学","学前教育","小学教育","特殊教育"]', '七门科目串成一张网，统考冲刺阶段用',
 'https://search.bilibili.com/all?keyword=%E5%BF%83%E7%90%86%E5%AD%A6%E8%80%83%E7%A0%94312%E7%BB%BC%E5%90%88%E4%B8%B2%E8%AE%B2', 2950)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('法考客观题精讲 · 民法刑法', '众合教育', '考研升学', '法考,客观题,民法,刑法,真题', 'ADVANCED',
 '["法学","知识产权","监狱学","政治学与行政学","国际政治","社会学","社会工作","思想政治教育","行政管理","公共管理"]', '两大实体法的高频考点与真题拆解',
 'https://search.bilibili.com/all?keyword=%E4%BC%97%E5%90%88%E6%B3%95%E8%80%83%E5%AE%A2%E8%A7%82%E9%A2%98%E6%B0%91%E6%B3%95%E5%88%91%E6%B3%95', 2960)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('教师资格证 · 科目一科目二全程', '粉笔教育', '考研升学', '教师资格证,综合素质,教育知识与能力', 'BEGINNER',
 '["教育学","学前教育","小学教育","特殊教育","体育教育","运动训练","社会体育指导与管理","教育技术学"]', '科一科二一次梳理，师范生考证主线课',
 'https://search.bilibili.com/all?keyword=%E7%B2%89%E7%AC%94%E6%95%99%E5%B8%88%E8%B5%84%E6%A0%BC%E8%AF%81%E7%A7%91%E7%9B%AE%E4%B8%80%E7%A7%91%E7%9B%AE%E4%BA%8C', 2970)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('初级会计实务 + 经济法基础', '之了课堂', '考研升学', '初级会计,会计实务,经济法,考证', 'BEGINNER',
 '["会计学","财务管理","税收学","财政学","金融学","经济学","工商管理","人力资源管理","市场营销","信息管理与信息系统","电子商务","物流管理","工程管理","工程造价","公共管理","行政管理","劳动与社会保障","土地资源管理","旅游管理","酒店管理","会展经济与管理","供应链管理","工业工程"]', '两科联报的完整精讲，财会方向第一张证',
 'https://search.bilibili.com/all?keyword=%E4%B9%8B%E4%BA%86%E8%AF%BE%E5%A0%82%E5%88%9D%E7%BA%A7%E4%BC%9A%E8%AE%A1%E5%AE%9E%E5%8A%A1', 2360)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('西医综合 · 贺银成全程', '贺银成', '考研升学', '西医综合,生理,病理,内科,外科,考研', 'ADVANCED',
 '["临床医学","基础医学","口腔医学","医学影像学","麻醉学","预防医学"]', '西综各科串联复习，临床考研的经典课程',
 'https://search.bilibili.com/all?keyword=%E8%B4%BA%E9%93%B6%E6%88%90%E8%A5%BF%E5%8C%BB%E7%BB%BC%E5%90%88', 2980)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('口腔执业医师 · 全程精讲', '口腔医考', '考研升学', '口腔执业医师,口内,口外,修复,考证', 'ADVANCED',
 '["口腔医学"]', '按考试科目串讲，口腔方向执业资格备考',
 'https://search.bilibili.com/all?keyword=%E5%8F%A3%E8%85%94%E6%89%A7%E4%B8%9A%E5%8C%BB%E5%B8%88%E5%85%A8%E7%A8%8B%E7%B2%BE%E8%AE%B2', 2990)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);

INSERT INTO bilibili_resource (title, uploader, category, keywords, difficulty,
    suitable_major, description, url, sort_order) VALUES
('计算机 408 统考 · 王道四件套', '王道论坛', '考研升学', '408,数据结构,组成原理,操作系统,计网', 'ADVANCED',
 '["计算机科学与技术","软件工程","人工智能","网络工程","信息安全","数据科学与大数据技术","智能科学与技术","物联网工程"]', '四门科目一次打通，计科考研的标准配置',
 'https://search.bilibili.com/all?keyword=%E7%8E%8B%E9%81%93%E8%AE%A1%E7%AE%97%E6%9C%BA408%E7%BB%9F%E8%80%83', 3000)
ON DUPLICATE KEY UPDATE uploader=VALUES(uploader), category=VALUES(category), keywords=VALUES(keywords), difficulty=VALUES(difficulty), suitable_major=VALUES(suitable_major), description=VALUES(description), url=VALUES(url), sort_order=VALUES(sort_order);


-- 清理早期版本遗留、专业映射已过时或已下架的课程（幂等）
DELETE FROM bilibili_resource WHERE title NOT IN (
    '高等数学 · 宋浩老师全程课', '线性代数 · 宋浩老师全程课', '概率论与数理统计 · 宋浩老师', '大学物理 · 不挂科系列', '大学化学 · 无机化学基础', '普通生物学 · 陈阅增教材精讲',
    '学术写作与文献检索', 'AI 编程助手与 Prompt 工程', '大学生时间管理与学习方法', '信息素养与文献管理 Zotero', 'C语言 · 鹏哥 C 语言系统课', 'C++ 面向对象程序设计 · 黑马',
    'Java 入门 · 尚硅谷宋红康全套', 'Python 入门 · 黑马程序员全套', '前端三件套 HTML+CSS+JS · 黑马', 'Vue3 + Element Plus 项目实战', '数据结构 · 王道考研全程', '操作系统 · 哈工大李治军',
    '计算机组成原理 · 王道考研', '计算机网络 · 湖科大教书匠微课堂', '编译原理 · 哈工大课程', '算法与刷题 · 代码随想录', 'MySQL 数据库 · 尚硅谷全套', 'Linux · 韩顺平一周实战',
    'Git 与 GitHub 版本管理实战', 'SpringBoot 企业级开发 · 尚硅谷', 'Docker 与容器化部署入门', '软件工程与 UML 建模', '单片机 STM32 · 江科大自化协', '机器学习 · 吴恩达公开课（中英字幕）',
    '深度学习与生成式 AI · 李宏毅全程', 'PyTorch 深度学习实战入门', '数据分析 · NumPy + Pandas 全套', 'SQL 数据分析实战', '统计学 · 贾俊平教材精讲', 'SPSS 统计分析实操',
    'R 语言与统计建模', 'OpenCV 计算机视觉入门', '自然语言处理入门', '大模型应用开发 LangChain', '数据挖掘导论', '数学分析 · 陈纪修全程',
    '高等代数 · 丘维声', '常微分方程 · 教材精讲', '实变函数入门', '数值分析与计算方法', '运筹学 · 清华教材精讲', '力学 · 赵凯华新概念物理',
    '电磁学 · 赵凯华', '光学 · 赵凯华', '量子力学 · 曾谨言', '理论力学 · 哈工大', '材料力学 · 刘鸿文', '固体物理 · 黄昆',
    '天文学导论', '气象学与气候学基础', '海洋科学导论', '地质学与地球物理基础', '无机化学 · 吉林大学宋天佑', '有机化学 · 李景宁',
    '分析化学 · 武汉大学', '物理化学 · 傅献彩', '结构化学 · 周公度', '仪器分析', '化工原理 · 陈敏恒', '材料科学基础 · 潘金生',
    '高分子化学与物理', '环境监测与分析', '电路 · 邱关源教材精讲', '模拟电子技术基础 · 华成英', '数字电子技术基础 · 阎石', '信号与系统 · 吴大正',
    '数字信号处理 · 程佩青', '自动控制原理 · 胡寿松', '电机与拖动基础', '电力系统分析 · 何仰赞', '电磁场与电磁波', '半导体物理与器件',
    '集成电路设计导论', '机械原理 · 孙桓', '机械设计 · 濮良贵', '工程图学与画法几何', '热力学与传热学', '流体力学基础',
    '汽车构造与原理', '结构力学 · 龙驭球', '混凝土结构设计原理', '建筑制图与 AutoCAD', '中外建筑史', '城市规划原理',
    '工程测量学', '水力学 · 吴持恭', '工程力学与材料力学综合', '工程训练与金工实习', '工程伦理与项目管理', '人体解剖学 · 系统解剖全程',
    '生理学 · 人卫版教材精讲', '医学微生物与免疫学', '病理学 · 人卫版', '病理生理学', '药理学 · 人卫版', '诊断学 · 物理诊断',
    '内科学 · 人卫版', '外科学总论', '医学统计学与流行病学', '医学伦理与卫生法规', '循证医学与文献检索', '口腔解剖生理学',
    '口腔组织病理学', '牙体牙髓病学', '口腔修复学', '基础护理学 · 人卫版', '内科护理学', '医学影像学 · 放射诊断',
    '临床检验基础', '临床麻醉学', '康复评定与治疗技术', '法医学 · 法医病理', '中医基础理论', '中药学 · 教材精讲',
    '方剂学 · 邓中甲', '针灸学 · 经络腧穴', '预防医学 · 公共卫生导论', '微观经济学 · 高鸿业', '宏观经济学 · 高鸿业', '计量经济学 · 李子奈',
    '金融学 · 黄达', '公司金融与财务管理', '证券投资学', '会计学原理 · 基础会计', '中级财务会计', '成本与管理会计',
    '审计学原理', '管理学原理 · 周三多', '组织行为学', '市场营销学 · 科特勒', '人力资源管理概论', '供应链管理',
    '物流与仓储管理', '电子商务概论', '管理信息系统', '财政学与税法', '国际贸易实务', '保险学原理',
    '工程经济学与造价管理', '旅游与酒店管理概论', '法理学 · 张文显', '宪法学', '刑法学 · 罗翔说刑法', '民法学 · 魏振瀛',
    '行政法与行政诉讼法', '民事诉讼法', '知识产权法', '社会学概论', '社会调查研究方法', '社会工作概论',
    '政治学原理', '思想政治教育原理', '教育学原理 · 王道俊', '教育心理学', '课程与教学论', '学前教育学与儿童发展',
    '特殊教育导论', '运动解剖学', '运动生理学', '运动训练学', '申论与公文写作 · 系统课', '中国古代文学史 · 袁行霈版',
    '中国现代文学三十年', '现代汉语 · 黄伯荣廖序东', '古代汉语 · 王力', '文学概论 · 童庆炳', '中国通史 · 古代史', '世界近代史',
    '考古学概论', '文物与博物馆学导论', '史学理论与方法', '中国哲学史 · 冯友兰', '西方哲学史 · 赵敦华', '逻辑学导论',
    '宗教学导论', '伦理学导论', '新闻学概论', '传播学教程 · 郭庆光', '广告学概论', '广播电视概论',
    '普通话与播音发声', '摄影基础与构图', '中外美术史', '艺术概论', '乐理与视唱练耳', '中国音乐史与欣赏',
    '戏剧影视文学与剧本创作', '设计基础 · 三大构成', '素描与手绘基础', '植物学', '植物生理学', '动物学',
    '动物生理学', '生物化学 · 王镜岩', '分子生物学', '细胞生物学', '遗传学 · 刘祖洞', '微生物学',
    '生态学基础', '土壤肥料学', '作物栽培学与耕作学', '农业昆虫与植物病理', '动物营养与饲料', '兽医临床诊断',
    '森林生态与林木育种', '园林植物与景观设计', '鱼类学与水产养殖', '草业科学概论', '茶学概论', '烟草栽培与加工',
    '食品化学', '食品微生物与加工工艺', '发酵工程与生物工艺', '生物统计学与试验设计', 'Photoshop 从入门到精通', 'Illustrator 矢量设计 · oeasy',
    '视频剪辑 Premiere 入门到实战', 'After Effects 动效入门', 'C4D 三维设计入门', 'UI 设计与 Figma 实战', 'SketchUp 与 Revit 建筑表现', '动画运动规律',
    '数字媒体艺术概论', 'Excel 从入门到精通 · 王佩丰 24 讲', 'PPT 设计与汇报表达', '大学生求职：简历与面试实战', '职场沟通与协作表达', '大学生职业规划与决策',
    '英语四六级全程班', '英语口语零基础到流利表达', '英语语法精讲 · 英语兔', '日语入门 · 标准日本语初级', '法语入门 · 零基础语音', '德语入门 · 零基础语音',
    '西班牙语入门', '朝鲜语 / 韩语入门', '俄语入门', '翻译理论与实践 · 英汉互译', '学术英语写作', '第二外语学习方法与跨文化交际',
    '考研数学全程 · 张宇', '考研政治 · 徐涛全程', '考研英语 · 唐迟阅读', '心理学导论 · 普通心理学', '实验心理学 · 心理统计与 SPSS 实操', '普通心理学 · 彭聃龄教材精讲（考研312）',
    '社会心理学 · 经典理论与实验', '发展心理学 · 毕生发展全程', '心理咨询与治疗 · 入门导论', '心理学考研 312 综合串讲', '法考客观题精讲 · 民法刑法', '教师资格证 · 科目一科目二全程',
    '初级会计实务 + 经济法基础', '西医综合 · 贺银成全程', '口腔执业医师 · 全程精讲', '计算机 408 统考 · 王道四件套'
);
