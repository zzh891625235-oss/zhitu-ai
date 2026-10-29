import request from '../utils/request'

// ============================================================
// Agent（工具调用 + RAG + 安全护栏）
// ============================================================

/** 工具清单：OpenAI tools 协议 + MCP inputSchema 双形态 */
export function getAgentToolsApi() {
  return request.get('/agent/tools')
}

/** 直接执行一次工具调用（对接外部 MCP 客户端 / 单独调试某个工具） */
export function invokeAgentToolApi(name, args = {}) {
  return request.post('/agent/tools/invoke', { name, arguments: args })
}

/** RAG 索引统计，用于确认检索真的在工作 */
export function getRagStatsApi() {
  return request.get('/agent/rag-stats')
}

/**
 * Agent 流式对话（NDJSON 事件流）。
 *
 * 与普通对话（/api/ai/chat-stream）的区别：这里除了正文 delta，
 * 还会收到 RAG 引用、工具调用轨迹、事实校验结果三类事件，
 * 前端据此把「AI 是怎么得到这个答案的」完整展示出来。
 *
 * @param {string} question 问题
 * @param {string} scene    场景：GENERAL / LEARNING / CAREER / COMPETITION / INTERVIEW
 * @param {object} handlers { onStatus, onCitations, onMode, onToolCall, onToolResult,
 *                            onDelta, onVerify, onDone, onBlocked, onError }
 */
export async function agentStreamApi(question, scene = 'GENERAL', handlers = {}) {
  const token = localStorage.getItem('token')
  const response = await fetch('/api/agent/chat-stream', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    body: JSON.stringify({ question, scene })
  })

  if (response.status === 401) {
    localStorage.removeItem('token')
    window.location.href = '/login'
    throw new Error('登录状态已失效')
  }
  if (!response.ok || !response.body) {
    throw new Error(`请求失败（HTTP ${response.status}）`)
  }

  const reader = response.body.getReader()
  const decoder = new TextDecoder('utf-8')
  let buffer = ''

  for (;;) {
    const { done, value } = await reader.read()
    if (done) break

    buffer += decoder.decode(value, { stream: true })
    const lines = buffer.split('\n')
    buffer = lines.pop()

    for (const line of lines) {
      const trimmed = line.trim()
      if (!trimmed) continue
      let node
      try {
        node = JSON.parse(trimmed)
      } catch (e) {
        continue
      }
      dispatchAgentEvent(node, handlers)
    }
  }
  return true
}

/** 把单个事件分发给对应的回调 */
function dispatchAgentEvent(node, h) {
  switch (node.type) {
    case 'status':
      h.onStatus && h.onStatus(node.text || '', node.phase)
      break
    case 'citations':
      h.onCitations && h.onCitations(node.items || [])
      break
    case 'mode':
      h.onMode && h.onMode(node.mode, node.text || '')
      break
    case 'tool_call':
      h.onToolCall && h.onToolCall(node)
      break
    case 'tool_result':
      h.onToolResult && h.onToolResult(node)
      break
    case 'delta':
      h.onDelta && h.onDelta(node.text || '')
      break
    case 'verify':
      h.onVerify && h.onVerify(node)
      break
    case 'done':
      h.onDone && h.onDone(node)
      break
    case 'blocked':
      h.onBlocked && h.onBlocked(node.reason || '')
      break
    case 'error':
      h.onError && h.onError(node.text || 'AI 服务异常')
      break
    default:
      break
  }
}

// ============================================================
// 多模态（图片识别自动录入）
// ============================================================

/** 当前环境是否支持图像理解 */
export function getVisionCapabilityApi() {
  return request.get('/multimodal/capability')
}

/** 上传证书 / 奖状图片，由视觉模型抽取字段 */
export function parseImageApi(file) {
  const form = new FormData()
  form.append('file', file)
  return request.post('/multimodal/parse', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
    timeout: 120000
  })
}

/** 把核对过的识别结果写入成长档案 */
export function commitImageRecordApi(data) {
  return request.post('/multimodal/commit', data)
}

/** 工具名的中文展示 */
export const TOOL_LABELS = {
  get_student_profile: '读取学籍档案',
  get_ability_portrait: '读取能力画像',
  list_courses_with_progress: '查询课程进度',
  find_competitions: '检索对口竞赛',
  get_study_progress: '查询计划执行情况',
  get_growth_records: '盘点成长档案',
  search_knowledge_base: '检索知识库',
  get_four_year_plan: '读取四年规划'
}

/** 数据来源的中文展示 */
export const SOURCE_LABELS = {
  competition: '竞赛库',
  course: '课程库',
  major: '专业库',
  corpus: '成长方法'
}
