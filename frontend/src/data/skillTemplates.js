/**
 * 专业方向 → 能力自评项 + 兴趣方向
 *
 * 为什么需要这个：
 *   让临床医学的学生自评「Java 基础」「数据结构」、再从
 *   「Web开发 / 算法/ACM」里挑兴趣方向，是没有意义的。
 *   不同专业关注的东西完全不同，所以按方向给出对应的选项。
 *
 * 约定：
 *   - 计算机 / 电子信息方向：沿用 student_profile 表里已有的 9 个字段
 *     （programmingLevel、javaLevel ...），与历史数据完全兼容
 *   - 其它方向：使用本文件的通用模板，结果以 JSON 存入 skillAssessment 字段
 *
 * 后端会优先读取 skillAssessment，没有时才回退到那 9 个字段。
 */

/** 自评等级：值与后端约定一致，不随专业变化 */
export const LEVEL_OPTIONS = [
  { value: 'BEGINNER', label: '零基础' },
  { value: 'BASIC', label: '入门' },
  { value: 'INTERMEDIATE', label: '中等' },
  { value: 'ADVANCED', label: '熟练' }
]

/** 计算机 / 电子信息方向：沿用数据库里已有的字段名 */
export const IT_SKILLS = [
  { key: 'programmingLevel', label: '编程基础', emoji: '💻' },
  { key: 'javaLevel', label: 'Java基础', emoji: '☕' },
  { key: 'pythonLevel', label: 'Python基础', emoji: '🐍' },
  { key: 'cppLevel', label: 'C/C++基础', emoji: '⚡' },
  { key: 'dsLevel', label: '数据结构', emoji: '🔗' },
  { key: 'dbLevel', label: '数据库', emoji: '🗄' },
  { key: 'webLevel', label: 'Web开发', emoji: '🌐' },
  { key: 'aiLevel', label: 'AI基础', emoji: '🤖' },
  { key: 'englishLevel', label: '英语水平', emoji: '📖' }
]

const IT_INTERESTS = [
  'Web开发', 'AI/机器学习', '大数据', 'Java后端', 'Python',
  '算法/ACM', '前端开发', '后端开发', '数据分析', '计算机视觉',
  'NLP', '网络安全', '云计算', '嵌入式', '游戏开发'
]

/** 判定为计算机 / 电子信息方向的专业名关键词 */
const IT_PATTERN = /计算机|软件工程|人工智能|大数据|数据科学|网络工程|信息安全|物联网|数字媒体技术|智能科学|集成电路|微电子|电子信息|通信工程|电子科学|光电信息|电磁场|机器人工程/

/** 其它方向的模板，按顺序匹配，越具体的越靠前 */
const TEMPLATES = [
  {
    id: 'medical',
    name: '医学类',
    match: /医学|临床|口腔|护理|药学|中药|中医|麻醉|影像|康复|检验|预防|法医|针灸|养生/,
    skills: [
      { key: 'basicMedLevel', label: '基础医学知识', emoji: '🫀' },
      { key: 'clinicalLevel', label: '临床 / 操作技能', emoji: '🩺' },
      { key: 'anatomyLevel', label: '解剖与形态学', emoji: '🦴' },
      { key: 'pharmLevel', label: '药理知识', emoji: '💊' },
      { key: 'experimentLevel', label: '实验技能', emoji: '🧪' },
      { key: 'readingLevel', label: '文献阅读', emoji: '📄' },
      { key: 'englishLevel', label: '医学英语', emoji: '📖' }
    ],
    interests: ['临床诊疗', '医学影像', '药物研发', '公共卫生', '医学科研', '健康管理', '医患沟通', '医疗信息化']
  },
  {
    id: 'business',
    name: '经管类',
    match: /工商管理|会计|财务|人力资源|市场营销|信息管理|电子商务|物流|工程管理|工程造价|公共管理|行政管理|劳动与社会保障|土地资源|旅游管理|酒店管理|会展|供应链|经济学|金融|保险|国际经济与贸易|财政|税收|投资|经济统计|国民经济|资源与环境经济/,
    skills: [
      { key: 'econLevel', label: '经济学基础', emoji: '📈' },
      { key: 'accountingLevel', label: '会计 / 财务知识', emoji: '🧾' },
      { key: 'dataLevel', label: '数据分析（Excel/SQL）', emoji: '📊' },
      { key: 'caseLevel', label: '案例分析与决策', emoji: '🧠' },
      { key: 'communicationLevel', label: '沟通与表达', emoji: '🗣' },
      { key: 'internshipLevel', label: '实习 / 实践经验', emoji: '💼' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['市场营销', '财务会计', '金融投资', '人力资源', '供应链管理', '创业', '商业分析', '咨询', '国际贸易']
  },
  {
    id: 'law',
    name: '法学类',
    match: /法学|知识产权|监狱学|政治学|国际政治|社会学|社会工作|思想政治教育|治安学|侦查学/,
    skills: [
      { key: 'statuteLevel', label: '法条掌握', emoji: '📕' },
      { key: 'caseLevel', label: '案例分析', emoji: '⚖️' },
      { key: 'logicLevel', label: '逻辑推理', emoji: '🧩' },
      { key: 'writingLevel', label: '法律文书写作', emoji: '✍️' },
      { key: 'debateLevel', label: '表达与辩论', emoji: '🗣' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['民商法', '刑法', '国际法', '知识产权', '诉讼实务', '企业法务', '公务员', '社会政策']
  },
  {
    id: 'education',
    name: '教育类',
    match: /教育学|学前教育|小学教育|特殊教育|体育教育|运动训练|社会体育|教育技术/,
    skills: [
      { key: 'pedagogyLevel', label: '教育理论基础', emoji: '📚' },
      { key: 'psychologyLevel', label: '心理学基础', emoji: '🧠' },
      { key: 'teachingLevel', label: '教学 / 授课技能', emoji: '🎓' },
      { key: 'designLevel', label: '课程与活动设计', emoji: '📝' },
      { key: 'expressionLevel', label: '语言表达', emoji: '🗣' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['学科教学', '教育研究', '教育管理', '心理咨询', '课程设计', '教育科技', '特殊教育']
  },
  {
    id: 'art',
    name: '艺术类',
    match: /音乐|美术|绘画|雕塑|设计|动画|戏剧|影视|广播电视编导|播音|摄影|舞蹈/,
    skills: [
      { key: 'skillLevel', label: '专业技能', emoji: '🎨' },
      { key: 'portfolioLevel', label: '作品集积累', emoji: '🖼' },
      { key: 'aestheticLevel', label: '审美与创意', emoji: '✨' },
      { key: 'softwareLevel', label: '专业软件工具', emoji: '🖥' },
      { key: 'theoryLevel', label: '艺术史与理论', emoji: '📘' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['视觉设计', '影视制作', '音乐表演', '美术创作', '动画', '摄影', '策展', '数字媒体艺术']
  },
  {
    id: 'agriculture',
    name: '农学类',
    match: /农学|园艺|植物保护|植物科学|动物科学|动物医学|林学|园林|水产|草业|茶学|烟草/,
    skills: [
      { key: 'biologyLevel', label: '生物学基础', emoji: '🧬' },
      { key: 'fieldLevel', label: '田间 / 实践技能', emoji: '🌾' },
      { key: 'experimentLevel', label: '实验与检测', emoji: '🔬' },
      { key: 'theoryLevel', label: '专业理论基础', emoji: '📘' },
      { key: 'readingLevel', label: '文献阅读', emoji: '📄' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['作物栽培', '动物养殖', '植物保护', '食品加工', '农业信息化', '园林设计', '生态修复']
  },
  {
    id: 'science',
    name: '理工类',
    match: /数学|物理|化学|生物科学|生物技术|生态|天文|地理|大气|海洋|地质|地球物理|统计|机械|土木|建筑|城乡规划|风景园林|材料|环境|能源|动力|电气|自动化|测绘|化工|制药|食品|纺织|交通|船舶|航空|航天|飞行器|核工程|安全工程|工业工程|水利/,
    skills: [
      { key: 'mathLevel', label: '数学基础', emoji: '📐' },
      { key: 'theoryLevel', label: '专业理论基础', emoji: '📘' },
      { key: 'experimentLevel', label: '实验 / 实践技能', emoji: '🔬' },
      { key: 'computeLevel', label: '计算与编程工具', emoji: '🖥' },
      { key: 'drawingLevel', label: '工程制图 / 设计', emoji: '📏' },
      { key: 'readingLevel', label: '文献阅读', emoji: '📄' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['科研深造', '工程技术', '实验研究', '数据分析', '产品研发', '学术写作', '项目管理']
  },
  {
    id: 'foreign',
    name: '外语类',
    match: /英语|日语|德语|法语|俄语|西班牙语|葡萄牙语|阿拉伯语|朝鲜语|越南语|泰语|蒙古语|印度尼西亚语|翻译|商务英语|外国语言文学/,
    skills: [
      { key: 'listeningLevel', label: '听力理解', emoji: '🎧' },
      { key: 'speakingLevel', label: '口语表达', emoji: '🗣' },
      { key: 'vocabLevel', label: '词汇量与阅读', emoji: '📚' },
      { key: 'translationLevel', label: '翻译实践', emoji: '🔀' },
      { key: 'writingLevel', label: '外语写作', emoji: '✍️' },
      { key: 'secondLangLevel', label: '第二外语', emoji: '🌐' },
      { key: 'cultureLevel', label: '跨文化沟通', emoji: '🌍' }
    ],
    interests: ['口笔译', '跨境电商', '国际贸易', '国际传播', '语言教学', '同声传译', '本地化与语言服务', '出国留学']
  },
  {
    id: 'humanities',
    name: '人文社科类',
    match: /汉语言|汉语国际|新闻|广播电视学|广告|传播|编辑出版|网络与新媒体|历史|考古|文物|世界史|哲学|逻辑学|宗教学|伦理学/,
    skills: [
      { key: 'writingLevel', label: '写作能力', emoji: '✍️' },
      { key: 'readingLevel', label: '文献阅读与检索', emoji: '📄' },
      { key: 'researchLevel', label: '研究方法', emoji: '🔍' },
      { key: 'expressionLevel', label: '表达与沟通', emoji: '🗣' },
      { key: 'criticalLevel', label: '批判性思维', emoji: '🧠' },
      { key: 'englishLevel', label: '英语水平', emoji: '📖' }
    ],
    interests: ['学术研究', '出版编辑', '新闻传播', '文案策划', '翻译', '文化创意', '公共关系', '教育']
  }
]

/** 未能匹配任何方向时的通用项 */
const GENERAL_TEMPLATE = {
  id: 'general',
  name: '通用学术能力',
  skills: [
    { key: 'theoryLevel', label: '专业理论基础', emoji: '📘' },
    { key: 'practiceLevel', label: '实践 / 动手能力', emoji: '🔧' },
    { key: 'readingLevel', label: '文献阅读与检索', emoji: '📄' },
    { key: 'writingLevel', label: '写作与表达', emoji: '✍️' },
    { key: 'teamworkLevel', label: '团队协作', emoji: '🤝' },
    { key: 'englishLevel', label: '英语水平', emoji: '📖' }
  ],
  interests: ['学术研究', '实践应用', '创新创业', '公共服务', '跨领域发展', '考公考研']
}

/**
 * 根据专业名解析出该用哪套自评项与兴趣项。
 *
 * @param {string} majorName 专业名称
 * @returns {{id:string,name:string,skills:Array,interests:Array,isIT:boolean}}
 */
export function resolveSkillTemplate(majorName = '') {
  const name = String(majorName || '')

  if (IT_PATTERN.test(name)) {
    return {
      id: 'it',
      name: '计算机 / 电子信息',
      skills: IT_SKILLS,
      interests: IT_INTERESTS,
      isIT: true
    }
  }
  for (const template of TEMPLATES) {
    if (template.match.test(name)) {
      return { ...template, isIT: false }
    }
  }
  return { ...GENERAL_TEMPLATE, isIT: false }
}

export default resolveSkillTemplate
