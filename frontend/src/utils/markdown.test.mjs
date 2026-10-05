import { test } from 'node:test'
import assert from 'node:assert/strict'
import { renderMarkdown } from './markdown.js'

// 用 Node 内置测试运行器，无需引入 vitest / jest：
//   node --test src/utils/

test('空输入安全返回空字符串', () => {
  assert.equal(renderMarkdown(''), '')
  assert.equal(renderMarkdown(null), '')
  assert.equal(renderMarkdown(undefined), '')
})

test('渲染前先做 HTML 转义（XSS 防护）', () => {
  const html = renderMarkdown('<script>alert(1)</script>')

  assert.ok(!html.includes('<script>'), '不应输出可执行的 script 标签')
  assert.ok(html.includes('&lt;script&gt;'))
})

test('图片与链接中的标签同样被转义', () => {
  const html = renderMarkdown('<img src=x onerror=alert(1)>')

  assert.ok(!html.includes('<img'))
  assert.ok(html.includes('&lt;img'))
})

test('加粗与行内代码', () => {
  assert.ok(renderMarkdown('**重点**').includes('<strong>重点</strong>'))
  assert.ok(renderMarkdown('`code`').includes('<code>code</code>'))
})

test('代码块保留原始内容，内部符号不被行内规则改写', () => {
  const html = renderMarkdown('```java\nint a = 1; // **不是粗体**\n```')

  assert.ok(html.includes('<pre class="md-code">'))
  assert.ok(html.includes('**不是粗体**'), '代码块里的星号应原样保留')
  assert.ok(!html.includes('<strong>不是粗体</strong>'))
})

test('表格渲染为带表头的 table', () => {
  const html = renderMarkdown('| 结构 | 复杂度 |\n| --- | --- |\n| 数组 | O(1) |')

  assert.ok(html.includes('<table class="md-table">'))
  assert.ok(html.includes('<th>结构</th>'))
  assert.ok(html.includes('<td>O(1)</td>'))
})

test('无序列表被包裹在 ul 中', () => {
  const html = renderMarkdown('- 第一项\n- 第二项')

  assert.ok(html.includes('<ul>'))
  assert.ok(html.includes('<li>第一项</li>'))
  assert.ok(html.includes('<li>第二项</li>'))
})

test('有序列表标记为 md-ordered', () => {
  const html = renderMarkdown('1. 第一步\n2. 第二步')

  assert.ok(html.includes('<li class="md-ordered">第一步</li>'))
})

test('空行分段，段内换行转 br', () => {
  const html = renderMarkdown('第一段\n\n第二段')

  assert.ok(html.includes('<p>第一段</p>'))
  assert.ok(html.includes('<p>第二段</p>'))
  assert.ok(renderMarkdown('第一行\n第二行').includes('第一行<br>第二行'))
})

test('引用块', () => {
  const html = renderMarkdown('> 这是提示')

  assert.ok(html.includes('<blockquote>这是提示</blockquote>'))
})

test('标题转为 h3 / h4', () => {
  assert.ok(renderMarkdown('## 二级标题').includes('<h3>二级标题</h3>'))
  assert.ok(renderMarkdown('### 三级标题').includes('<h4>三级标题</h4>'))
})

test('同时包含多种结构时不互相破坏', () => {
  const md = [
    '**要点**',
    '',
    '- 项目一',
    '- 项目二',
    '',
    '| A | B |',
    '| --- | --- |',
    '| 1 | 2 |',
    '',
    '```js',
    'const x = 1;',
    '```'
  ].join('\n')

  const html = renderMarkdown(md)

  assert.ok(html.includes('<strong>要点</strong>'))
  assert.ok(html.includes('<li>项目一</li>'))
  assert.ok(html.includes('<table class="md-table">'))
  assert.ok(html.includes('const x = 1;'))
})
