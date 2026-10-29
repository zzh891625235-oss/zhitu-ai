# -*- coding: utf-8 -*-
"""
生成 backend/src/main/resources/db/competition-seed-h2.sql —— 竞赛字典种子数据。

用法（在项目根目录或任意位置均可）：
    python scripts/gen-competition-seed.py

设计要点：
  * 专业名必须严格取自 database/majors.sql 的 175 个专业，脚本会校验，
    出现表外专业名直接报错退出——这类脏数据只能靠方向兜底匹配，
    正是「竞赛与专业不对应」的根源。
  * 校验每个专业至少 2 场精确对口赛事。
  * 输出 MERGE ... KEY(name) 语句，幂等 upsert，保留竞赛 id。

维护方式：
  * 修改已有赛事 —— 改下面 FIX 字典里的专业名单
  * 新增赛事    —— 往 NEW 列表追加一条
  * 改完重新执行本脚本，再重新打包 jar
"""
import os, re, json, sys, io

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------- 1. 读取 175 个专业 ----------
majors = []
for m in re.finditer(r"\((\d+), '([^']+)', '([^']+)'",
                     open(ROOT + '/database/majors.sql', encoding='utf-8').read()):
    majors.append(m.group(2))
MAJOR_SET = set(majors)
assert len(majors) == 175, len(majors)

# ---------- 2. 解析已有竞赛（优先 data-h2.sql，已拆分时读 competition-seed-h2.sql） ----------
sql = open(ROOT + '/backend/src/main/resources/db/data-h2.sql', encoding='utf-8').read()
BLOCK = re.compile(
    r"\('([^']+)',\s*\n\s*'([^']*)',\s*\n\s*'([^']*)',\s*'(\[[^']*\])',\s*'([^']*)',\s*\n"
    r"\s*DATEADD\('DAY', (-?\d+), CURRENT_DATE\), DATEADD\('DAY', (-?\d+), CURRENT_DATE\),\s*\n"
    r"\s*DATEADD\('DAY', (-?\d+), CURRENT_DATE\), DATEADD\('DAY', (-?\d+), CURRENT_DATE\),\s*\n"
    r"\s*'([A-Z]+)', '([^']*)', (\d+)\)")

SEED_PATH = ROOT + '/backend/src/main/resources/db/competition-seed-h2.sql'
existing = {}
for m in BLOCK.finditer(sql):
    existing[m.group(1)] = {
        'name': m.group(1), 'desc': m.group(2), 'type': m.group(3),
        'majors': json.loads(m.group(4)), 'grade': m.group(5),
        'off': (int(m.group(6)), int(m.group(7)), int(m.group(8)), int(m.group(9))),
        'diff': m.group(10), 'url': m.group(11), 'days': int(m.group(12)),
    }

if not existing:
    # 竞赛段已从 data-h2.sql 拆出，改从上一版种子文件读取，保证脚本可重复执行
    seed = open(SEED_PATH, encoding='utf-8').read()
    MERGE = re.compile(
        r"MERGE INTO competition \(name, description, type, suitable_major, suitable_grade,\s*\n"
        r"\s*registration_start, registration_end, competition_start, competition_end,\s*\n"
        r"\s*difficulty, official_url, recommend_days\) KEY\(name\) VALUES\s*\n"
        r"\('((?:[^']|'')*)',\s*\n"
        r"\s*'((?:[^']|'')*)',\s*\n"
        r"\s*'((?:[^']|'')*)', '(\[[^']*\])', '((?:[^']|'')*)',\s*\n"
        r"\s*DATEADD\('DAY', (-?\d+), CURRENT_DATE\), DATEADD\('DAY', (-?\d+), CURRENT_DATE\),\s*\n"
        r"\s*DATEADD\('DAY', (-?\d+), CURRENT_DATE\), DATEADD\('DAY', (-?\d+), CURRENT_DATE\),\s*\n"
        r"\s*'([A-Z]+)', '((?:[^']|'')*)', (\d+)\);")
    for m in MERGE.finditer(seed):
        nm = m.group(1).replace("''", "'")
        existing[nm] = {
            'name': nm, 'desc': m.group(2).replace("''", "'"), 'type': m.group(3).replace("''", "'"),
            'majors': json.loads(m.group(4)), 'grade': m.group(5).replace("''", "'"),
            'off': (int(m.group(6)), int(m.group(7)), int(m.group(8)), int(m.group(9))),
            'diff': m.group(10), 'url': m.group(11).replace("''", "'"), 'days': int(m.group(12)),
        }

print(f'解析到已有竞赛: {len(existing)} 条')

# ---------- 3. 修正 / 扩充原有竞赛的专业名单 ----------
# 只列需要改的；未列出的保持原样（原样里若有无效名会在下面统一校验）
FIX = {
 '蓝桥杯全国软件和信息技术专业人才大赛': [
   '计算机科学与技术','软件工程','人工智能','大数据科学与技术','数据科学与大数据技术',
   '网络工程','信息安全','物联网工程','智能科学与技术','数字媒体技术','电子信息工程','通信工程'],
 '中国高校计算机大赛-团体程序设计天梯赛': [
   '计算机科学与技术','软件工程','人工智能','网络工程','信息安全','物联网工程',
   '数据科学与大数据技术','智能科学与技术','电子信息工程'],
 'ACM-ICPC 国际大学生程序设计竞赛': [
   '计算机科学与技术','软件工程','人工智能','网络工程','信息安全','数据科学与大数据技术','智能科学与技术'],
 '中国大学生计算机设计大赛': [
   '计算机科学与技术','软件工程','数字媒体技术','人工智能','数字媒体艺术','动画',
   '教育技术学','广播电视编导','视觉传达设计'],
 '全国大学生数学建模竞赛': [
   '计算机科学与技术','软件工程','人工智能','大数据科学与技术','数据科学与大数据技术',
   '数学与应用数学','信息与计算科学','统计学','经济学','金融学','经济统计学','物理学'],
 '中国国际大学生创新大赛（互联网+）': [
   '计算机科学与技术','软件工程','人工智能','工商管理','市场营销','电子商务',
   '信息管理与信息系统','经济学','金融学','机械工程','材料科学与工程','农学'],
 '传智杯全国大学生IT技能大赛': [
   '计算机科学与技术','软件工程','人工智能','大数据科学与技术','数据科学与大数据技术',
   '网络工程','物联网工程','数字媒体技术','电子商务','信息管理与信息系统'],
 '全国大学生电子设计竞赛': [
   '电子信息工程','通信工程','自动化','物联网工程','电子科学与技术','微电子科学与工程',
   '集成电路设计与集成系统','光电信息科学与工程','机器人工程','测控技术与仪器','计算机科学与技术'],
 '华为ICT大赛': [
   '计算机科学与技术','软件工程','通信工程','电子信息工程','网络工程','信息安全',
   '物联网工程','大数据科学与技术','数据科学与大数据技术','集成电路设计与集成系统','自动化'],
 '全国大学生结构设计竞赛': ['土木工程','建筑学','水利水电工程','工程管理','工程造价','风景园林'],
 '全国大学生先进成图技术与产品信息建模创新大赛': [
   '土木工程','建筑学','城乡规划','机械工程','机械设计制造及其自动化','车辆工程',
   '工业工程','测绘工程','机器人工程','风景园林'],
 '全国周培源大学生力学竞赛': [
   '土木工程','机械工程','水利水电工程','航空航天工程','机械设计制造及其自动化',
   '船舶与海洋工程','材料科学与工程','核工程与核技术'],
 '全国大学生BIM应用技能大赛': ['土木工程','建筑学','城乡规划','工程管理','工程造价','风景园林','环境设计'],
 '全国大学生机械创新设计大赛': [
   '机械工程','机械设计制造及其自动化','车辆工程','机器人工程','材料成型及控制工程',
   '工业工程','材料科学与工程','自动化'],
 '全国大学生智能汽车竞赛': [
   '自动化','电气工程及其自动化','测控技术与仪器','电子信息工程','车辆工程','机器人工程',
   '计算机科学与技术','软件工程','人工智能','机械工程'],
 '中国大学生工程实践与创新能力大赛': [
   '机械工程','自动化','电气工程及其自动化','工业工程','土木工程','车辆工程',
   '机器人工程','航空航天工程','船舶与海洋工程'],
 '全国大学生节能减排社会实践与科技竞赛': [
   '能源与动力工程','环境工程','电气工程及其自动化','化学工程与工艺','材料科学与工程',
   '土木工程','核工程与核技术','安全工程'],
 '全国大学生金相技能大赛': ['材料科学与工程','材料成型及控制工程','机械工程','应用化学','化学工程与工艺'],
 '全国大学生化工设计竞赛': [
   '化学工程与工艺','制药工程','生物工程','应用化学','环境工程','安全工程','能源与动力工程'],
 '全国大学生化学实验竞赛': [
   '化学','应用化学','化学工程与工艺','制药工程','材料科学与工程','生物工程','环境工程'],
 '全国大学生生命科学竞赛': [
   '生物科学','生物技术','生物工程','食品科学与工程','基础医学','农学','动物科学',
   '药学','预防医学','生态学','水产养殖学'],
 '全国大学生食品科技创新大赛': ['食品科学与工程','生物工程','化学工程与工艺','生物技术','预防医学'],
 '全国大学生纺织类创新创业大赛': ['纺织工程','轻化工程','材料科学与工程','服装与服饰设计','产品设计'],
 '中国大学生医学技术技能大赛': [
   '临床医学','护理学','药学','预防医学','中医学','麻醉学','口腔医学','医学影像学',
   '中西医临床医学','康复治疗学','医学检验技术','针灸推拿学'],
 '全国大学生基础医学创新研究暨实验设计论坛': [
   '基础医学','临床医学','预防医学','医学检验技术','法医学','口腔医学','麻醉学',
   '中西医临床医学','药学','中医学'],
 '全国大学生药苑论坛': ['药学','中药学','制药工程','生物工程','化学工程与工艺','临床医学'],
 '全国大学生动物医学专业技能大赛': ['动物医学','动物科学','水产养殖学','生物科学'],
 '全国大学生植物生产类实践技能竞赛': ['农学','园艺','植物保护','茶学','烟草','林学','园林','草业科学'],
 '全国大学生市场调查与分析大赛': [
   '市场营销','工商管理','会计学','财务管理','统计学','经济统计学','经济学',
   '人力资源管理','电子商务','信息管理与信息系统','公共管理','国际经济与贸易','社会学'],
 '全国大学生物流设计大赛': [
   '物流管理','供应链管理','交通运输','电子商务','工业工程','交通工程','信息管理与信息系统'],
 '中金所杯全国大学生金融知识大赛': [
   '金融学','金融工程','投资学','保险学','经济学','经济统计学','财务管理','会计学',
   '数学与应用数学','统计学'],
 '全国大学生会计信息化技能大赛': ['会计学','财务管理','税收学','工商管理','财政学','国民经济管理'],
 '全国大学生模拟法庭竞赛': ['法学','知识产权','监狱学','政治学与行政学','社会学','社会工作'],
 '全国学生学宪法讲宪法活动': ['法学','知识产权','思想政治教育','政治学与行政学','行政管理','国际政治','社会学'],
 '田家炳杯全国师范院校师范生教学技能竞赛': [
   '教育学','学前教育','小学教育','特殊教育','体育教育','汉语言文学','数学与应用数学',
   '英语','汉语言','物理学','化学','历史学','思想政治教育','地理科学','生物科学'],
 '全国大学生广告艺术大赛': [
   '广告学','视觉传达设计','数字媒体艺术','传播学','广播电视学','网络与新媒体',
   '动画','产品设计','环境设计','摄影','广播电视编导','新闻学'],
 '全国大学生工业设计大赛': ['产品设计','视觉传达设计','环境设计','工业工程','机械工程','数字媒体艺术','动画'],
 '全国大学生艺术展演': [
   '音乐学','音乐表演','美术学','绘画','雕塑','播音与主持艺术','戏剧影视文学','广播电视编导','动画'],
 '中国大学生物理学术竞赛': [
   '物理学','应用物理学','材料科学与工程','电子信息工程','光电信息科学与工程','核工程与核技术'],
 '全国大学生统计建模大赛': [
   '统计学','经济统计学','数学与应用数学','应用化学','经济学','金融学','保险学',
   '大数据科学与技术','数据科学与大数据技术','信息与计算科学'],
 '外研社杯全国大学生英语挑战赛': ['英语','翻译','汉语国际教育','*'],
 '中华经典诵写讲大赛': ['汉语言文学','汉语言','汉语国际教育','历史学','哲学','思想政治教育','文物与博物馆学','*'],
}

for name, mj in FIX.items():
    assert name in existing, f'未找到原有竞赛: {name}'
    existing[name]['majors'] = mj

# 类型微调
TYPE_FIX = {'全国大学生纺织类创新创业大赛': '纺织设计'}

# ---------- 4. 新增赛事 ----------
NEW = [
 dict(name='全国大学生信息安全竞赛',
      desc='信息安全领域最具权威的学科竞赛，含作品赛与创新实践能力赛，考察攻防与安全开发',
      type='信息安全', majors=['信息安全','网络工程','计算机科学与技术','软件工程','物联网工程','通信工程'],
      grade='不限', off=(-6, 46, 78, 80), diff='ADVANCED', url='http://www.ciscn.cn/', days=75),
 dict(name='全国大学生集成电路创新创业大赛',
      desc='集成电路领域规模最大的赛事，覆盖设计、制造、封测与应用全链条',
      type='电子设计', majors=['集成电路设计与集成系统','微电子科学与工程','电子科学与技术','电子信息工程','光电信息科学与工程','自动化'],
      grade='大二及以上', off=(13, 63, 100, 102), diff='ADVANCED', url='https://univ.ciciec.com/', days=90),
 dict(name='全国大学生光电设计竞赛',
      desc='光电类专业的代表性赛事，需完成光电系统设计与实物制作',
      type='电子设计', majors=['光电信息科学与工程','电子科学与技术','应用物理学','物理学','测控技术与仪器','电子信息工程'],
      grade='大二及以上', off=(-9, 41, 75, 77), diff='INTERMEDIATE', url='https://www.gdjyc.org/', days=75),
 dict(name='全国大学生智能技术应用大赛',
      desc='面向智能科学与技术的应用型竞赛，涵盖机器学习、机器人、智能系统等方向',
      type='人工智能', majors=['智能科学与技术','人工智能','机器人工程','自动化','计算机科学与技术','数据科学与大数据技术'],
      grade='不限', off=(8, 53, 86, 88), diff='INTERMEDIATE', url='https://www.caai.cn/', days=75),
 dict(name='中国大学生服务外包创新创业大赛',
      desc='教育部等主办的创新创业赛事，以企业真实命题为主，看重落地与工程能力',
      type='创新创业', majors=['数据科学与大数据技术','大数据科学与技术','软件工程','信息管理与信息系统','电子商务','计算机科学与技术'],
      grade='不限', off=(-16, 34, 66, 70), diff='INTERMEDIATE', url='http://www.fwwb.org.cn/', days=60),
 dict(name='中国大学生飞行器设计创新大赛',
      desc='航空航天类专业的核心赛事，需完成飞行器设计、制作与飞行验证',
      type='航空航天', majors=['航空航天工程','飞行器设计与工程','飞行器动力工程','机械设计制造及其自动化','自动化'],
      grade='大二及以上', off=(19, 89, 130, 133), diff='ADVANCED', url='https://www.csaa.org.cn/', days=120),
 dict(name='全国大学生船舶与海洋工程设计大赛',
      desc='船舶与海洋工程领域的专业赛事，围绕船型设计与海洋结构物展开',
      type='机械控制', majors=['船舶与海洋工程','海洋科学','机械工程','水利水电工程','材料科学与工程'],
      grade='大二及以上', off=(11, 61, 96, 98), diff='ADVANCED', url='https://www.csy.org.cn/', days=90),
 dict(name='全国大学生交通科技大赛',
      desc='交通运输类专业最高规格赛事，围绕交通规划、安全与智能交通选题',
      type='土木建筑', majors=['交通工程','交通运输','土木工程','城乡规划','物流管理','测绘工程'],
      grade='不限', off=(-7, 43, 76, 78), diff='INTERMEDIATE', url='http://www.nactrans.com.cn/', days=75),
 dict(name='全国大学生核科技竞赛',
      desc='核工程与核技术方向的专业竞赛，涵盖反应堆物理、辐射防护与核安全',
      type='能源核工', majors=['核工程与核技术','能源与动力工程','物理学','材料科学与工程','安全工程'],
      grade='大三及以上', off=(26, 86, 128, 130), diff='ADVANCED', url='https://www.cns.org.cn/', days=120),
 dict(name='全国大学生安全科学与工程实践创新大赛',
      desc='安全工程专业的实践类竞赛，围绕风险评估、应急管理与安全设计展开',
      type='机械控制', majors=['安全工程','环境工程','化学工程与工艺','土木工程','工业工程'],
      grade='不限', off=(6, 51, 84, 86), diff='INTERMEDIATE', url='https://www.china-safety.org.cn/', days=75),
 dict(name='全国大学生城市设计竞赛',
      desc='城乡规划与建筑类专业的重要赛事，以真实地块为命题完成城市设计方案',
      type='土木建筑', majors=['城乡规划','建筑学','风景园林','环境设计','园林'],
      grade='大三及以上', off=(-11, 39, 72, 75), diff='ADVANCED', url='https://www.planning.org.cn/', days=90),
 dict(name='全国大学生测绘地理信息创新创业大赛',
      desc='测绘与地理信息类的专业赛事，涵盖测量、遥感、GIS 开发等方向',
      type='土木建筑', majors=['测绘工程','地理科学','土木工程','土地资源管理','地质学','城乡规划'],
      grade='不限', off=(14, 64, 98, 100), diff='INTERMEDIATE', url='https://www.csgpc.org/', days=75),
 dict(name='中国大学生材料热处理创新创业大赛',
      desc='材料类专业的行业赛事，围绕热处理工艺与材料性能展开',
      type='材料', majors=['材料科学与工程','材料成型及控制工程','机械工程','化学工程与工艺','应用化学'],
      grade='大二及以上', off=(-13, 37, 70, 72), diff='INTERMEDIATE', url='https://www.chts.org.cn/', days=75),
 dict(name='全国大学生纱线设计大赛',
      desc='纺织工程专业的特色赛事，考察纱线结构与纺纱工艺的设计能力',
      type='纺织设计', majors=['纺织工程','轻化工程','服装与服饰设计','材料科学与工程'],
      grade='不限', off=(9, 54, 88, 90), diff='INTERMEDIATE', url='https://www.ctes.cn/', days=60),
 dict(name='全国大学生非织造材料开发与应用大赛',
      desc='非织造材料方向的行业赛事，覆盖材料开发、工艺设计与终端应用',
      type='纺织设计', majors=['纺织工程','轻化工程','材料科学与工程','化学工程与工艺'],
      grade='大二及以上', off=(-4, 44, 78, 80), diff='INTERMEDIATE', url='https://www.cnia.org.cn/', days=75),
 dict(name='全国大学生食品工程虚拟仿真大赛',
      desc='食品工程原理的仿真操作竞赛，考察工艺计算与单元操作能力',
      type='食品轻工', majors=['食品科学与工程','生物工程','化学工程与工艺','生物技术'],
      grade='不限', off=(17, 67, 100, 102), diff='INTERMEDIATE', url='https://www.cifst.org.cn/', days=60),
 dict(name='全国护理专业本科临床技能大赛',
      desc='护理学专业最高规格的技能竞赛，覆盖基础护理与专科护理操作',
      type='医学技能', majors=['护理学','康复治疗学','临床医学','麻醉学'],
      grade='大三及以上', off=(-8, 42, 76, 79), diff='ADVANCED', url='https://www.cna-cast.org.cn/', days=90),
 dict(name='全国大学生护理学专业创新创业大赛',
      desc='护理学方向的创新创业赛事，涵盖临床护理创新、健康管理与护理器械',
      type='医学技能', majors=['护理学','康复治疗学','临床医学','预防医学'],
      grade='不限', off=(20, 74, 108, 110), diff='INTERMEDIATE', url='https://www.cna-cast.org.cn/', days=75),
 dict(name='全国大学生医学影像技术实践技能大赛',
      desc='医学影像技术方向的实践技能竞赛，考察影像检查与设备操作规范',
      type='医学技能', majors=['医学影像学','医学检验技术','临床医学','生物工程'],
      grade='大三及以上', off=(12, 62, 95, 97), diff='INTERMEDIATE', url='https://www.cma.org.cn/', days=75),
 dict(name='全国大学生口腔医学技能大赛',
      desc='口腔医学专业的临床技能竞赛，含口腔内科、外科与修复操作考核',
      type='医学技能', majors=['口腔医学','临床医学'],
      grade='大三及以上', off=(5, 55, 90, 92), diff='ADVANCED', url='https://www.cndent.com/', days=90),
 dict(name='全国大学生中医药创新创业大赛',
      desc='中医药方向的创新创业赛事，涵盖中药研发、中医诊疗与健康产品',
      type='药学', majors=['中医学','中药学','针灸推拿学','中西医临床医学','药学','制药工程'],
      grade='不限', off=(-15, 35, 68, 72), diff='INTERMEDIATE', url='https://www.catcm.org.cn/', days=75),
 dict(name='全国大学生茶艺技能大赛',
      desc='茶学专业的特色技能竞赛，考察茶艺展示、茶叶审评与茶文化传播',
      type='农林', majors=['茶学','园艺','农学','食品科学与工程'],
      grade='不限', off=(10, 58, 90, 92), diff='BEGINNER', url='https://www.caass.org.cn/', days=60),
 dict(name='全国大学生草学技能大赛',
      desc='草业科学专业的实践技能竞赛，覆盖草地资源、牧草育种与生态修复',
      type='农林', majors=['草业科学','农学','园艺','林学','生态学'],
      grade='大二及以上', off=(-6, 40, 74, 76), diff='INTERMEDIATE', url='https://www.caass.org.cn/', days=60),
 dict(name='全国大学生林学专业技能大赛',
      desc='林学与园林类专业的实践竞赛，考察森林调查、苗木识别与园林设计',
      type='农林', majors=['林学','园林','生态学','植物保护','风景园林','地理科学'],
      grade='不限', off=(21, 76, 112, 115), diff='INTERMEDIATE', url='https://www.csf.org.cn/', days=75),
 dict(name='全国大学生乡村振兴创意大赛',
      desc='面向乡村振兴的综合性赛事，农学、规划、经管、设计类专业均可参与',
      type='综合', majors=['农学','园艺','植物保护','林学','园林','动物科学','水产养殖学','茶学','烟草','草业科学','城乡规划','电子商务','旅游管理'],
      grade='不限', off=(-18, 32, 66, 70), diff='BEGINNER', url='https://www.moe.gov.cn/', days=60),
 dict(name='全国大学生动物科学专业技能大赛',
      desc='动物科学专业的技能竞赛，覆盖饲料配方、繁殖技术与养殖管理',
      type='农林', majors=['动物科学','动物医学','水产养殖学','生物科学'],
      grade='大二及以上', off=(9, 57, 90, 92), diff='INTERMEDIATE', url='https://www.caav.org.cn/', days=60),
 dict(name='全国大学生水产技能大赛',
      desc='水产养殖学专业的技能竞赛，考察水质检测、鱼病诊断与养殖操作',
      type='农林', majors=['水产养殖学','动物科学','海洋科学','生物科学','环境工程'],
      grade='不限', off=(-10, 36, 70, 72), diff='INTERMEDIATE', url='https://www.csfish.org.cn/', days=60),
 dict(name='全国大学生法律职业能力大赛',
      desc='法学专业的综合能力竞赛，含法律文书写作、案例分析与会展辩论',
      type='法学', majors=['法学','知识产权','监狱学','政治学与行政学','社会学'],
      grade='大二及以上', off=(15, 65, 98, 100), diff='INTERMEDIATE', url='https://www.chinalaw.org.cn/', days=75),
 dict(name='全国大学生环境资源模拟法庭大赛',
      desc='以环境资源案件为命题的模拟法庭赛事，法学与环境类专业交叉参赛',
      type='法学', majors=['法学','知识产权','环境工程','行政管理'],
      grade='大三及以上', off=(-12, 38, 72, 74), diff='ADVANCED', url='https://www.chinalaw.org.cn/', days=75),
 dict(name='全国高校模拟集体谈判大赛',
      desc='劳动关系领域的实践赛事，模拟集体协商与谈判，经管与法学专业通用',
      type='法学', majors=['劳动与社会保障','社会工作','法学','人力资源管理','公共管理','行政管理'],
      grade='不限', off=(7, 52, 86, 88), diff='INTERMEDIATE', url='https://www.mohrss.gov.cn/', days=60),
 dict(name='中国大学生社会调查方法大赛',
      desc='社会学与公共管理类的实证赛事，要求完成完整的社会调查与报告',
      type='经管实务', majors=['社会学','社会工作','行政管理','公共管理','统计学','市场营销','新闻学'],
      grade='不限', off=(-5, 45, 78, 80), diff='INTERMEDIATE', url='https://www.china-csm.org/', days=75),
 dict(name='全国学前教育专业学生教育技能大赛',
      desc='学前教育专业的教学技能竞赛，含活动设计、弹唱跳画与说课',
      type='师范技能', majors=['学前教育','特殊教育','小学教育','教育学'],
      grade='大二及以上', off=(16, 70, 104, 107), diff='INTERMEDIATE', url='https://www.moe.gov.cn/', days=75),
 dict(name='全国高校体育教育专业学生基本功大赛',
      desc='体育教育专业的基本功竞赛，考察运动技能、教学设计与体能',
      type='师范技能', majors=['体育教育','运动训练','社会体育指导与管理'],
      grade='大三及以上', off=(-14, 36, 70, 73), diff='INTERMEDIATE', url='https://www.moe.gov.cn/', days=75),
 dict(name='iTeach全国大学生数字化教育应用创新大赛',
      desc='教育技术方向的创新赛事，聚焦数字化教学资源与教育产品设计',
      type='师范技能', majors=['教育技术学','教育学','小学教育','学前教育','汉语言文学','计算机科学与技术'],
      grade='不限', off=(4, 49, 82, 84), diff='INTERMEDIATE', url='https://www.iteach.org.cn/', days=60),
 dict(name='全国高校心理学专业本科生创新创业论坛',
      desc='心理学专业的学术与创新交流平台，含论文、实践项目与创业方案',
      type='理科基础', majors=['心理学','教育学','社会工作'],
      grade='不限', off=(-9, 41, 75, 77), diff='INTERMEDIATE', url='https://www.cpsbeijing.org/', days=60),
 dict(name='全国大学生人力资源管理知识技能竞赛',
      desc='人力资源管理专业的实务竞赛，模拟招聘、绩效与薪酬方案设计',
      type='经管实务', majors=['人力资源管理','工商管理','公共管理','劳动与社会保障','行政管理'],
      grade='不限', off=(11, 59, 92, 94), diff='BEGINNER', url='https://www.chrm.org.cn/', days=45),
 dict(name='全国大学生旅游策划大赛',
      desc='旅游管理类专业的策划赛事，围绕目的地营销与文旅产品设计',
      type='经管实务', majors=['旅游管理','酒店管理','会展经济与管理','市场营销','公共管理'],
      grade='不限', off=(-3, 47, 80, 82), diff='BEGINNER', url='https://www.cnta.gov.cn/', days=45),
 dict(name='全国大学生国际贸易技能大赛',
      desc='国际经济与贸易专业的实务竞赛，模拟外贸业务流程与商务谈判',
      type='经管实务', majors=['国际经济与贸易','经济学','财政学','税收学','英语'],
      grade='不限', off=(13, 63, 96, 98), diff='INTERMEDIATE', url='https://www.ccpit.org/', days=60),
 dict(name='全国大学生资产评估知识竞赛',
      desc='财政与资产评估方向的竞赛，考察估值方法与实务案例分析',
      type='经管实务', majors=['财政学','税收学','财务管理','投资学','国民经济管理','工程管理','会计学'],
      grade='大二及以上', off=(-17, 33, 66, 68), diff='INTERMEDIATE', url='https://www.cas.org.cn/', days=60),
 dict(name='全国大学生电子商务创新创意及创业挑战赛',
      desc='电子商务领域的三创赛，覆盖商业模式、平台运营与技术实现',
      type='经管实务', majors=['电子商务','市场营销','信息管理与信息系统','计算机科学与技术','工商管理','物流管理'],
      grade='不限', off=(8, 58, 92, 95), diff='INTERMEDIATE', url='https://www.ec.gov.cn/', days=75),
 dict(name='全国大学生土地资源管理技能大赛',
      desc='土地资源管理专业的实务竞赛，涵盖国土调查、规划与估价',
      type='经管实务', majors=['土地资源管理','测绘工程','地理科学','城乡规划','公共管理','工程管理'],
      grade='不限', off=(-8, 38, 72, 74), diff='INTERMEDIATE', url='https://www.mnr.gov.cn/', days=60),
 dict(name='多语种全国口译大赛',
      desc='覆盖英日俄德法西朝等语种的口译赛事，外语类专业均可参加',
      type='英语', majors=['英语','翻译','俄语','日语','德语','法语','西班牙语','朝鲜语','汉语国际教育'],
      grade='不限', off=(18, 68, 102, 104), diff='ADVANCED', url='https://www.tac-online.org.cn/', days=90),
 dict(name='全国大学生新媒体创意大赛',
      desc='新闻传播类专业的作品赛事，覆盖短视频、图文、H5 与数据新闻',
      type='艺术设计', majors=['新闻学','传播学','网络与新媒体','广播电视学','编辑出版学','广告学','汉语言文学'],
      grade='不限', off=(-11, 39, 72, 74), diff='BEGINNER', url='https://www.moe.gov.cn/', days=60),
 dict(name='中国大学生历史学论坛',
      desc='历史学类的学术交流与论文竞赛，覆盖中国史、世界史与考古方向',
      type='人文', majors=['历史学','世界史','考古学','文物与博物馆学','哲学','汉语言文学'],
      grade='不限', off=(12, 62, 96, 98), diff='INTERMEDIATE', url='https://www.cssn.cn/', days=75),
 dict(name='中国大学生哲学论坛',
      desc='哲学类学术论文与思辨竞赛，哲学、逻辑学、伦理学等专业适用',
      type='人文', majors=['哲学','逻辑学','宗教学','伦理学','思想政治教育','汉语言文学'],
      grade='不限', off=(-6, 44, 78, 80), diff='INTERMEDIATE', url='https://www.cssn.cn/', days=75),
 dict(name='中国大学生摄影大赛',
      desc='摄影与影像类专业的作品赛事，覆盖纪实、商业与艺术摄影',
      type='艺术设计', majors=['摄影','数字媒体艺术','视觉传达设计','广播电视编导','动画'],
      grade='不限', off=(7, 54, 88, 90), diff='BEGINNER', url='https://www.cpanet.org.cn/', days=45),
 dict(name='中国大学生动漫创意大赛',
      desc='动画与数字媒体类的创作赛事，覆盖动画短片、漫画与游戏美术',
      type='艺术设计', majors=['动画','数字媒体艺术','视觉传达设计','戏剧影视文学','广播电视编导'],
      grade='不限', off=(-13, 37, 70, 72), diff='INTERMEDIATE', url='https://www.caanet.org.cn/', days=60),
 dict(name='中国国际大学生时装周',
      desc='服装与服饰设计专业的发布与竞赛平台，含毕业设计作品专场',
      type='艺术设计', majors=['服装与服饰设计','产品设计','纺织工程','视觉传达设计'],
      grade='大三及以上', off=(23, 83, 126, 130), diff='INTERMEDIATE', url='https://www.chinafashionweek.org/', days=90),
 dict(name='全国大学生戏剧节',
      desc='戏剧影视类的展演与竞赛，覆盖话剧、短片与播音主持作品',
      type='艺术设计', majors=['戏剧影视文学','广播电视编导','播音与主持艺术','音乐表演','音乐学'],
      grade='不限', off=(-9, 41, 76, 80), diff='INTERMEDIATE', url='https://www.chinatheatre.org.cn/', days=60),
 dict(name='全国大学生天文创新作品竞赛',
      desc='天文方向的创新作品竞赛，含观测、科普与数据处理作品',
      type='理科基础', majors=['天文学','物理学','应用物理学','光电信息科学与工程'],
      grade='不限', off=(10, 60, 94, 96), diff='INTERMEDIATE', url='https://www.cas.cn/', days=60),
 dict(name='全国大学生海洋知识竞赛',
      desc='海洋科学方向的科普与知识竞赛，海洋、生物、地质类专业通用',
      type='理科基础', majors=['海洋科学','水产养殖学','生物科学','地质学','环境工程'],
      grade='不限', off=(-15, 35, 68, 70), diff='BEGINNER', url='https://www.soa.gov.cn/', days=45),
 dict(name='全国大学生地质技能竞赛',
      desc='地质类专业的实践技能竞赛，考察野外地质、岩矿鉴定与地质填图',
      type='理科基础', majors=['地质学','地球物理学','地理科学','测绘工程','土木工程'],
      grade='大二及以上', off=(14, 64, 98, 101), diff='ADVANCED', url='https://www.geosociety.org.cn/', days=90),
 dict(name='全国大学生气象科普作品大赛',
      desc='大气科学方向的科普创作竞赛，涵盖科普文章、短视频与可视化作品',
      type='理科基础', majors=['大气科学','地理科学','应用物理学','生态学','物理学'],
      grade='不限', off=(-4, 46, 79, 81), diff='BEGINNER', url='https://www.cms1924.org/', days=45),
 dict(name='全国大学生生物化学实验技能大赛',
      desc='生物类专业的实验技能竞赛，考察生化分离、分析与检测操作',
      type='生命科学', majors=['生物科学','生物技术','生物工程','应用化学','食品科学与工程','药学'],
      grade='大二及以上', off=(6, 56, 90, 92), diff='INTERMEDIATE', url='https://www.csbmb.org.cn/', days=60),
]

print(f'新增赛事: {len(NEW)} 条')

# ---------- 5. 合并 + 校验 ----------
# NEW 里同名的覆盖旧数据（便于修正个别专业名单），不同名的追加
by_name = dict(existing)
for c in NEW:
    by_name[c['name']] = c
allc = list(by_name.values())
print(f'合并后竞赛总数: {len(allc)} 条（原有 {len(existing)} + 新增 {len(allc) - len(existing)}）')

bad = []
for c in allc:
    for m in c['majors']:
        if m != '*' and m not in MAJOR_SET:
            bad.append((c['name'], m))
if bad:
    print('❌ 存在无效专业名:')
    for n, m in bad:
        print(f'   {n} → {m}')
    sys.exit(1)
print('✅ 所有 suitable_major 均在 175 个专业内')

# 覆盖校验
def resolve(name):
    # 与 MajorDirection.ALL 顺序一致
    REGEX = [
      ('IT', r'计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程'),
      ('CIVIL', r'土木|建筑|城乡规划|风景园林|工程管理|工程造价|测绘|水利|给排水|道路|桥梁|岩土'),
      ('ENGINEERING', r'机械|车辆|自动化|电气|测控|材料|能源|动力|航空航天|飞行器|船舶|核工程|安全工程|工业工程|交通'),
      ('TEXTILE', r'纺织|轻化'),
      ('CHEM', r'化学工程|化工|制药|环境工程|环境科学|生物工程|生物医学工程|材料化学|能源化学'),
      ('FOOD', r'食品|粮食|农产|包装|农业工程'),
      ('PHARMACY', r'药学|中药|药物制剂|临床药学'),
      ('NURSING', r'护理'),
      ('AGRICULTURE', r'农学|园艺|植物|林学|园林|草业|茶学|烟草|种子'),
      ('ANIMAL', r'动物|水产|畜牧|兽医'),
      ('MEDICAL', r'医学|临床|口腔|麻醉|影像|康复|检验|预防|法医|针灸|中医|卫生'),
      ('BUSINESS', r'工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济'),
      ('LAW', r'法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学'),
      ('EDUCATION', r'教育学|学前教育|小学教育|特殊教育|体育教育|运动训练|社会体育|教育技术'),
      ('ART', r'音乐|作曲|美术|绘画|雕塑|设计|动画|戏剧|影视|广播电视编导|播音|摄影|舞蹈|艺术'),
      ('SCIENCE', r'数学|物理|化学|生物科学|生物技术|生态|天文|地理|大气|海洋|地质|地球物理|统计|心理|计算科学'),
      ('HUMANITIES', r'汉语言|汉语国际|英语|俄语|日语|德语|法语|西班牙语|朝鲜语|翻译|新闻|广播电视学|广告|传播|编辑出版|网络与新媒体|历史|考古|文物|世界史|哲学|逻辑学|宗教学|伦理学'),
    ]
    for k, r in REGEX:
        if re.search(r, name): return k
    return 'GENERAL'

def matches(c, major):
    if '*' in c['majors']: return True
    if major in c['majors']: return True
    mine = resolve(major)
    if mine == 'GENERAL': return False
    return any(resolve(s) == mine and resolve(s) != 'GENERAL' for s in c['majors'])

cover = {}
for mj in majors:
    exact = [c['name'] for c in allc if mj in c['majors']]
    anyhit = [c['name'] for c in allc if matches(c, mj) and '*' not in c['majors']]
    cover[mj] = (exact, anyhit)

weak = [(mj, len(e), len(a)) for mj, (e, a) in cover.items() if len(exact) < 2]
print(f'\n精确覆盖 < 2 的专业: {len(weak)} 个')
for mj, ne, na in sorted(weak, key=lambda x: x[1]):
    print(f'   {mj}  精确{ne} 方向{na}')

zero_any = [mj for mj, (e, a) in cover.items() if len(a) == 0]
print(f'\n对口(含方向) 为 0 的专业: {len(zero_any)} 个 {zero_any}')

# ---------- 6. 输出 SQL ----------
def esc(s):
    return s.replace("'", "''")

out = io.StringIO()
out.write("""-- ============================================================
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

""")
for c in allc:
    mj = json.dumps(c['majors'], ensure_ascii=False).replace('", "', '","')
    o = c['off']
    out.write(
        f"MERGE INTO competition (name, description, type, suitable_major, suitable_grade,\n"
        f"    registration_start, registration_end, competition_start, competition_end,\n"
        f"    difficulty, official_url, recommend_days) KEY(name) VALUES\n"
        f"('{esc(c['name'])}',\n"
        f" '{esc(c['desc'])}',\n"
        f" '{esc(TYPE_FIX.get(c['name'], c['type']))}', '{mj}', '{esc(c['grade'])}',\n"
        f" DATEADD('DAY', {o[0]}, CURRENT_DATE), DATEADD('DAY', {o[1]}, CURRENT_DATE),\n"
        f" DATEADD('DAY', {o[2]}, CURRENT_DATE), DATEADD('DAY', {o[3]}, CURRENT_DATE),\n"
        f" '{c['diff']}', '{c['url']}', {c['days']});\n\n")

path = ROOT + '/backend/src/main/resources/db/competition-seed-h2.sql'
open(path, 'w', encoding='utf-8').write(out.getvalue())
print(f'\n✅ 已生成 {path}（{len(allc)} 条竞赛）')
