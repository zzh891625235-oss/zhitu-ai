/**
 * 轻量 Markdown 渲染工具。
 *
 * 大模型的回答普遍包含标题、列表、表格、代码块等结构，
 * 若只把换行替换成 <br>，表格和代码块会糊成一片。
 * 这里手写一个够用的 Markdown 子集渲染器，
 * 避免为演示项目额外引入 marked / markdown-it 等依赖。
 *
 * 安全性：渲染前先做 HTML 转义，因此返回值可安全用于 v-html。
 */

const ESCAPE_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }

function escapeHtml(text) {
  return String(text).replace(/[&<>"']/g, ch => ESCAPE_MAP[ch])
}

function renderTable(block) {
  const lines = block.trim().split('\n').filter(line => line.trim())
  if (lines.length < 2) return block

  const toCells = line => line.replace(/^\||\|$/g, '').split('|').map(cell => cell.trim())
  const head = toCells(lines[0])
  const body = lines.slice(2).map(toCells)

  const thead = `<thead><tr>${head.map(c => `<th>${c}</th>`).join('')}</tr></thead>`
  const tbody = `<tbody>${body
    .map(row => `<tr>${row.map(c => `<td>${c}</td>`).join('')}</tr>`)
    .join('')}</tbody>`

  return `<table class="md-table">${thead}${tbody}</table>`
}

export function renderMarkdown(text) {
  if (!text) return ''

  let html = escapeHtml(text)

  // 1. 先摘出代码块，避免其中的 * | # 等符号被后续规则误伤
  const codeBlocks = []
  html = html.replace(/```[a-zA-Z0-9+#-]*\n?([\s\S]*?)```/g, (match, code) => {
    codeBlocks.push(`<pre class="md-code"><code>${code.replace(/\n$/, '')}</code></pre>`)
    return `\n\n@@CODEBLOCK${codeBlocks.length - 1}@@\n\n`
  })

  // 2. 表格（必须在列表、行内样式之前处理，否则 | 会被破坏）
  html = html.replace(/(?:^\|.*\|[ \t]*\n\|[ \t:|-]+\|[ \t]*\n(?:\|.*\|[ \t]*\n?)*)/gm, renderTable)

  // 3. 标题
  html = html.replace(/^###[ \t]+(.+)$/gm, '<h4>$1</h4>')
  html = html.replace(/^##?[ \t]+(.+)$/gm, '<h3>$1</h3>')

  // 4. 引用
  html = html.replace(/^&gt;[ \t]?(.+)$/gm, '<blockquote>$1</blockquote>')

  // 5. 列表：先转成 li，再把连续的 li 包进 ul
  html = html.replace(/^[ \t]*[-*][ \t]+(.+)$/gm, '<li>$1</li>')
  html = html.replace(/^[ \t]*\d+\.[ \t]+(.+)$/gm, '<li class="md-ordered">$1</li>')
  html = html.replace(/(?:<li[^>]*>[\s\S]*?<\/li>\n?)+/g, block => `<ul>${block.replace(/\n/g, '')}</ul>`)

  // 6. 行内样式
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  html = html.replace(/`([^`\n]+)`/g, '<code>$1</code>')

  // 7. 段落：以空行分段，块级元素不再包裹 p
  html = html
    .split(/\n{2,}/)
    .map(para => {
      const trimmed = para.trim()
      if (!trimmed) return ''
      if (/^<(h3|h4|ul|ol|table|pre|blockquote)|^@@CODEBLOCK/.test(trimmed)) return trimmed
      return `<p>${trimmed.replace(/\n/g, '<br>')}</p>`
    })
    .join('')

  // 8. 还原代码块
  return html.replace(/@@CODEBLOCK(\d+)@@/g, (match, index) => codeBlocks[Number(index)] || '')
}

export default renderMarkdown
