import request from '../utils/request'

// 与后端 ai.read-timeout(120s) 对齐，避免长回答被 axios 的 30s 默认超时掐断
const AI_TIMEOUT = 120000

export function chatApi(question, type = 'GENERAL') {
  return request.post('/ai/chat', { question, type }, { timeout: AI_TIMEOUT })
}

export function getHistoryApi(type = 'GENERAL') {
  return request.get('/ai/chat-history', { params: { type } })
}

export function clearHistoryApi(type = 'GENERAL') {
  return request.delete('/ai/chat-history', { params: { type } })
}

/** 查询 AI 服务状态：用于区分「真实大模型输出」与「离线模板模式」 */
export function getAiStatusApi() {
  return request.get('/ai/status')
}

/**
 * 流式对话。
 *
 * 后端返回 NDJSON（每行一个 JSON 对象），而不是标准 SSE：
 * 模型输出里有大量换行，SSE 的 data: 单行格式会丢掉换行后的内容。
 * 这里用 fetch + ReadableStream 按行解析，可以完整保留 Markdown 结构，
 * 同时支持携带 Authorization 头（EventSource 无法自定义请求头）。
 *
 * @param {string} question 用户问题
 * @param {string} type     对话模式
 * @param {object} handlers { onDelta, onDone, onError }
 */
export async function streamChatApi(question, type = 'GENERAL', handlers = {}) {
  const { onDelta, onDone, onError } = handlers
  const token = localStorage.getItem('token')

  const response = await fetch('/api/ai/chat-stream', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    body: JSON.stringify({ question, type })
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

  // 逐块读取并按行解析；最后一行可能被截断，留到下一轮拼接
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
      if (node.type === 'delta') {
        if (onDelta) onDelta(node.text || '')
      } else if (node.type === 'done') {
        let meta = {}
        try { meta = JSON.parse(node.text || '{}') } catch (e) { /* 忽略解析失败 */ }
        if (onDone) onDone(meta)
      } else if (node.type === 'error') {
        if (onError) onError(node.text || 'AI 服务异常')
      }
    }
  }

  return true
}
