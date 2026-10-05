#!/usr/bin/env node
/**
 * ============================================================
 * 本地 Mock AI 服务 —— 兼容 OpenAI Chat Completions 协议
 *
 * 用途：
 *   1. 没有真实 API Key 时，验证「配置了 Key 之后」的完整 AI 链路
 *      （请求构造 → 响应解析 → 流式 SSE → 状态标记）
 *   2. 作为开发调试工具：不再因为 Key 额度用尽而中断开发
 *
 * 用法：
 *   node scripts/mock-ai-server.mjs
 *   # 然后让后端指向它：
 *   #   AI_API_KEY=sk-mock  AI_API_URL=http://localhost:8899/v1
 *
 * 说明：
 *   * 返回内容统一带 [MOCK-AI] 前缀，便于和「离线模板模式」区分 ——
 *     看到这个前缀就说明请求真的走完了 HTTP 与流式解析链路。
 *   * 按 system 提示词判断业务类型，返回对应结构的 JSON，
 *     因此画像 / 规划 / 简历 / 竞赛推荐 / 学习计划都能真实跑通。
 * ============================================================
 */
import http from 'node:http'

const PORT = Number(process.env.MOCK_AI_PORT || 8899)
const CHUNK_SIZE = Number(process.env.MOCK_AI_CHUNK || 12)
const CHUNK_DELAY = Number(process.env.MOCK_AI_DELAY || 25)

// ================================================================
// 各业务类型的应答内容
// ================================================================

const PORTRAIT = {
  summary: '[MOCK-AI] 你是一名基础扎实、方向明确的大二学生。Java 与数据库达到中级水平，Web 开发有实践经验，具备冲击后端岗位的潜力。当前主要短板是算法训练量不足与 AI 方向尚未入门。',
  strengths: ['[MOCK-AI] Java 与面向对象基础扎实', '已有 Web 全栈实践经验', '学习主动性强'],
  weaknesses: ['算法刷题量偏少', '项目缺少可量化成果', 'AI 方向尚未入门'],
  scores: { programming: 74, algorithm: 52, project: 60, competition: 38, ai: 30, english: 66, overall: 53 },
  suggestions: ['[MOCK-AI] 刷完 LeetCode Hot 100', '把课程项目升级为可部署的完整项目', '每周固定 2 小时英语听力'],
  threeMonthPlan: ['第1个月：算法系统复习，完成 60 题', '第2个月：完成一个完整项目并上线', '第3个月：报名蓝桥杯并备赛']
}

const FOUR_YEAR_PLAN = {
  overview: '[MOCK-AI] 以就业为目标，围绕 Java 后端构建竞争力：大二打牢算法与工程基础，大三用实习和项目完成转变。',
  freshman: {
    theme: '打好基础，探索方向',
    goals: ['[MOCK-AI] 掌握一门语言', '通过英语四级'],
    courses: ['C语言程序设计', '高等数学'],
    skills: ['C 语言基础', 'Git'],
    competitions: ['校级编程竞赛'],
    tips: '大一不要急着追新技术，把基础打牢。'
  },
  sophomore: {
    theme: '核心能力建设',
    goals: ['掌握数据结构与算法', '完成一个完整项目'],
    courses: ['数据结构', '数据库原理', 'Java程序设计'],
    skills: ['Java / Spring Boot', 'MySQL', 'Vue 3'],
    competitions: ['蓝桥杯', '传智杯'],
    tips: '大二是能力爆发期，数据结构必须学扎实。'
  },
  junior: {
    theme: '实习与深度实战',
    goals: ['拿到后端实习', '完成两个有深度的项目'],
    courses: ['操作系统', '计算机网络'],
    skills: ['Redis', 'Docker'],
    competitions: ['互联网+创新创业大赛'],
    tips: '大三的实习是校招最重要的加分项。'
  },
  senior: {
    theme: '收获成果',
    goals: ['完成秋招签约', '完成毕业设计'],
    courses: ['毕业设计'],
    skills: ['简历与面试表达'],
    competitions: [],
    tips: '第一份工作优先选能快速成长的团队。'
  },
  risks: ['[MOCK-AI] 数据结构不扎实会拖累后续算法与面试', '缺少实习会让简历在初筛被过滤'],
  certificates: ['大学英语四六级', '软件设计师']
}

const RESUME = {
  name: '[MOCK-AI] 同学',
  education: { school: '华中科技大学', major: '计算机科学与技术', grade: '大二' },
  skills: ['[MOCK-AI] Java / Spring Boot', 'MySQL 与索引优化', 'Vue 3 / Vite', 'Git'],
  courses: ['数据结构', '数据库原理', 'Java程序设计'],
  projects: ['[MOCK-AI] 校园二手交易平台 — Spring Boot + Vue 3，独立完成数据库与接口开发'],
  competitions: ['[MOCK-AI] 蓝桥杯省赛三等奖'],
  certificates: ['大学英语四级'],
  advantages: '[MOCK-AI] 具备扎实的 Java 与数据库基础，有两个完整项目经验。',
  targetPosition: 'Java 后端开发工程师（实习）'
}

const COMPETITION_RECOMMEND = [
  { competitionId: 1, score: 92, reasons: ['[MOCK-AI] 难度与你当前水平匹配', '准备时间充裕'] },
  { competitionId: 7, score: 88, reasons: ['[MOCK-AI] 入门友好，适合第一次参赛'] },
  { competitionId: 3, score: 61, reasons: ['[MOCK-AI] 含金量高，可作为长期目标'] }
]

const STUDY_PLAN = [
  { day: 1, course: '数据结构', task: '[MOCK-AI] 复习线性表，手写单链表反转', duration: '60分钟' },
  { day: 2, course: '算法设计与分析', task: '[MOCK-AI] 动态规划入门：01 背包', duration: '45分钟' },
  { day: 3, course: 'Spring Boot框架', task: '[MOCK-AI] 补上统一异常处理与参数校验', duration: '50分钟' },
  { day: 4, course: '数据库原理', task: '[MOCK-AI] 索引原理与执行计划分析', duration: '45分钟' },
  { day: 5, course: '计算机网络', task: '[MOCK-AI] TCP 三次握手整理成笔记', duration: '40分钟' },
  { day: 6, course: '数据结构', task: '[MOCK-AI] 二叉树非递归遍历专项', duration: '60分钟' },
  { day: 7, course: 'Web前端开发', task: '[MOCK-AI] 完成移动端响应式改造', duration: '50分钟' }
]

const CHAT_TEXT = `**来自 Mock AI 服务的回答**

这是一段用于验证链路的示例内容，包含 Markdown 的常见结构：

1. **列表项**：验证有序列表渲染
2. **表格**：见下方
3. **代码块**：见下方

| 结构 | 复杂度 |
| --- | --- |
| 数组随机访问 | O(1) |
| 链表插入删除 | O(1) |

\`\`\`java
Map<String, Object> body = new LinkedHashMap<>();
body.put("stream", true);
\`\`\`

> 看到 \`[MOCK-AI]\` 前缀，说明请求真实走完了 HTTP 调用与流式解析链路。`

// ================================================================
// 按 system 提示词分派业务类型
// ================================================================

function buildContent(messages) {
  const system = messages
    .filter(m => m.role === 'system')
    .map(m => m.content || '')
    .join('\n')

  // 顺序重要：先匹配更具体的业务提示词
  if (system.includes('学生画像') || system.includes('职业发展规划专家')) {
    return JSON.stringify(PORTRAIT)
  }
  if (system.includes('成长规划专家') || system.includes('大学四年成长规划')) {
    return JSON.stringify(FOUR_YEAR_PLAN)
  }
  if (system.includes('简历专家')) {
    return JSON.stringify(RESUME)
  }
  if (system.includes('竞赛推荐专家')) {
    return JSON.stringify(COMPETITION_RECOMMEND)
  }
  if (system.includes('学习计划专家')) {
    return JSON.stringify(STUDY_PLAN)
  }
  return CHAT_TEXT
}

/** 按 Unicode 字符切块（避免把 emoji / 中文切成半个字） */
function splitChunks(text) {
  const chars = Array.from(text)
  const chunks = []
  for (let i = 0; i < chars.length; i += CHUNK_SIZE) {
    chunks.push(chars.slice(i, i + CHUNK_SIZE).join(''))
  }
  return chunks.length ? chunks : ['']
}

function sendOnce(res, content) {
  res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' })
  res.end(JSON.stringify({
    id: 'mock-completion',
    object: 'chat.completion',
    created: Math.floor(Date.now() / 1000),
    model: 'mock-model',
    choices: [{ index: 0, message: { role: 'assistant', content }, finish_reason: 'stop' }]
  }))
}

function sendStream(res, content) {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream; charset=utf-8',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  })

  const chunks = splitChunks(content)
  let index = 0

  const timer = setInterval(() => {
    if (index >= chunks.length) {
      clearInterval(timer)
      res.write('data: [DONE]\n\n')
      res.end()
      return
    }
    const payload = {
      id: 'mock-completion',
      object: 'chat.completion.chunk',
      model: 'mock-model',
      choices: [{ index: 0, delta: { content: chunks[index++] } }]
    }
    res.write(`data: ${JSON.stringify(payload)}\n\n`)
  }, CHUNK_DELAY)

  res.on('close', () => clearInterval(timer))
}

// ================================================================
// HTTP 服务
// ================================================================

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url.startsWith('/v1/models')) {
    // 供「测试连接」功能使用
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' })
    res.end(JSON.stringify({ object: 'list', data: [{ id: 'mock-model', object: 'model' }] }))
    return
  }

  if (req.method !== 'POST' || !req.url.includes('/chat/completions')) {
    res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' })
    res.end(JSON.stringify({ error: { message: 'not found', type: 'invalid_request_error' } }))
    return
  }

  let raw = ''
  req.on('data', chunk => { raw += chunk })
  req.on('end', () => {
    let body
    try {
      body = JSON.parse(raw)
    } catch (e) {
      res.writeHead(400, { 'Content-Type': 'application/json; charset=utf-8' })
      res.end(JSON.stringify({ error: { message: 'invalid JSON body' } }))
      return
    }

    const content = buildContent(body.messages || [])
    console.log(`[mock-ai] ${body.stream ? 'stream' : 'once  '} model=${body.model} chars=${content.length}`)

    if (body.stream) {
      sendStream(res, content)
    } else {
      sendOnce(res, content)
    }
  })
})

server.listen(PORT, () => {
  console.log(`Mock AI 服务已启动: http://localhost:${PORT}/v1`)
  console.log('让后端指向它：AI_API_KEY=sk-mock  AI_API_URL=http://localhost:' + PORT + '/v1')
})
