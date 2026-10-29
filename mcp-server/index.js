#!/usr/bin/env node
/**
 * 智途AI 的 MCP Server（stdio 传输）。
 *
 * ── 这是干什么的 ────────────────────────────────────────────────
 * MCP（Model Context Protocol）是让大模型客户端（Claude Desktop、Cursor、
 * 支持 MCP 的 IDE 插件等）发现并调用外部工具的开放协议。
 * 这个进程把智途AI 后端的 8 个 Agent 工具「翻译」成 MCP 工具，
 * 于是学生在任意 MCP 客户端里就能直接问：
 *   「我这学期该报哪个竞赛？」→ 客户端自动调用 find_competitions → 拿到真实赛事列表。
 *
 * ── 为什么不把工具实现搬过来 ──────────────────────────────────
 * 刻意不分叉：本进程不含任何业务逻辑，只做协议转换（tools/list → GET /api/agent/tools，
 * tools/call → POST /api/agent/tools/invoke）。
 * 工具实现、数据权限、防幻觉校验仍然只有后端一份，
 * 不会出现「改了后端，MCP 这边还留着旧逻辑」这种两套代码各自漂移的问题。
 *
 * ── 运行 ────────────────────────────────────────────────────────
 *   ZHITU_BASE_URL=http://localhost:8080 ZHITU_TOKEN=学生的JWT node index.js
 * 在客户端的 MCP 配置里注册：
 *   { "mcpServers": { "zhitu-ai": { "command": "node", "args": ["此处填绝对路径/index.js"],
 *       "env": { "ZHITU_BASE_URL": "http://localhost:8080", "ZHITU_TOKEN": "eyJ..." } } } }
 */

const BASE_URL = process.env.ZHITU_BASE_URL || 'http://localhost:8080'
const TOKEN = process.env.ZHITU_TOKEN || ''

/**
 * 后端返回的 Result<T> 包装：code=200 表示业务成功，否则 message 是错误原因。
 * MCP 要求「工具执行失败」也要返回正常响应 + isError，而不是抛协议错误，
 * 这样模型能看到失败原因并自行决定重试还是换条路。
 */
async function callBackend(pathname, body) {
  const response = await fetch(`${BASE_URL}${pathname}`, {
    method: body ? 'POST' : 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(TOKEN ? { Authorization: `Bearer ${TOKEN}` } : {})
    },
    ...(body ? { body: JSON.stringify(body) } : {})
  })
  if (!response.ok) {
    throw new Error(`后端返回 HTTP ${response.status}`)
  }
  return response.json()
}

function ok(id, result) {
  send({ jsonrpc: '2.0', id, result })
}

function fail(id, code, message) {
  send({ jsonrpc: '2.0', id, error: { code, message } })
}

function send(message) {
  process.stdout.write(JSON.stringify(message) + '\n')
}

/** 把工具执行结果包成 MCP 要求的 content 结构 */
function toolContent(payload) {
  return {
    content: [{ type: 'text', text: typeof payload === 'string' ? payload : JSON.stringify(payload, null, 2) }],
    isError: false
  }
}

async function handle(request) {
  const { id, method, params = {} } = request

  switch (method) {
    case 'initialize':
      return ok(id, {
        protocolVersion: params.protocolVersion || '2024-11-05',
        capabilities: { tools: { listChanged: false } },
        serverInfo: { name: 'zhitu-ai', version: '1.0.0' }
      })

    // MCP 握手后的确认通知，不需要响应
    case 'notifications/initialized':
      return

    case 'tools/list': {
      const envelope = await callBackend('/api/agent/tools')
      if (envelope.code !== 200) {
        return fail(id, -32000, envelope.message || '读取工具清单失败')
      }
      // 后端的 manifest 已经是 {name, description, inputSchema} 形态，直接透传
      return ok(id, { tools: envelope.data.tools })
    }

    case 'tools/call': {
      const name = params.name
      if (!name) {
        return fail(id, -32602, '缺少工具名 name')
      }
      const envelope = await callBackend('/api/agent/tools/invoke', {
        name,
        arguments: params.arguments || {}
      })
      if (envelope.code !== 200) {
        // 用 isError 而不是 JSON-RPC error：让模型知道调用失败并读懂原因
        return ok(id, {
          content: [{ type: 'text', text: `工具调用失败：${envelope.message || '未知错误'}` }],
          isError: true
        })
      }
      return ok(id, toolContent(envelope.data.result))
    }

    case 'ping':
      return ok(id, {})

    default:
      return fail(id, -32601, `不支持的方法：${method}`)
  }
}

/** 主循环：按行读取 stdin，逐条处理，任何单条异常都不应该让进程退出 */
async function main() {
  let buffer = ''
  process.stdin.setEncoding('utf8')
  for await (const chunk of process.stdin) {
    buffer += chunk
    const lines = buffer.split('\n')
    buffer = lines.pop() || ''
    for (const line of lines) {
      const trimmed = line.trim()
      if (!trimmed) continue
      try {
        await handle(JSON.parse(trimmed))
      } catch (e) {
        const parsed = safeParse(trimmed)
        if (parsed && parsed.id !== undefined) {
          fail(parsed.id, -32603, String((e && e.message) || e))
        } else {
          process.stderr.write(`处理消息失败：${e && e.message}\n`)
        }
      }
    }
  }
}

function safeParse(text) {
  try {
    return JSON.parse(text)
  } catch (e) {
    return null
  }
}

main().catch(e => {
  process.stderr.write(`MCP Server 异常退出：${e && e.stack}\n`)
  process.exit(1)
})
