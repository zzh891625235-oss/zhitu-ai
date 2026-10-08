// ============================================================
// 生成「按专业方向铺开的课程数据」，写回 database/data.sql
//
// 背景：
//   课程表 course 用 major_id 关联专业。全平台有 175 个专业，
//   如果每个专业手写一份课程，data.sql 会长到无法维护。
//   实际上同一方向的课程高度重合，所以这里只维护一份「方向 → 课程」
//   模板（scripts/course-templates.mjs），再用 SQL 把模板铺到该方向
//   下的每一个专业上：
//
//     INSERT INTO course (...)
//     SELECT m.id, c.name, ... FROM major m
//     CROSS JOIN (SELECT ... UNION ALL SELECT ...) c
//     WHERE m.name REGEXP '<方向正则>'
//     ON DUPLICATE KEY UPDATE ...
//
//   依赖 course 表的唯一键 uk_course_major_name (major_id, name)，
//   因此可以安全重复执行。
//
// 方向正则与优先级直接从后端 MajorDirection.java 里解析，避免两边漂移。
//
// 用法：node scripts/gen-courses.mjs
// ============================================================

import { readFileSync, writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

import { COURSE_TEMPLATES, COMMON_COURSES } from './course-templates.mjs'
import { allMajors } from '../frontend/src/data/majors.js'

const here = dirname(fileURLToPath(import.meta.url))
const root = join(here, '..')

const JAVA_FILE = join(root, 'backend/src/main/java/com/zhitu/ai/MajorDirection.java')
const DATA_SQL = join(root, 'database/data.sql')
const BEGIN_MARK = '-- >>> GENERATED:courses >>>'
const END_MARK = '-- <<< GENERATED:courses <<<'

// ------------------------------------------------------------
// 1. 解析后端的方向定义（顺序 = 优先级，先匹配到的胜出）
// ------------------------------------------------------------
const javaSrc = readFileSync(JAVA_FILE, 'utf8')

const directions = []
const declRe = /private static final MajorDirection (\w+) = new MajorDirection\(\s*\n\s*"([^"]+)",\s*\n\s*"([^"]+)",/g
let m
while ((m = declRe.exec(javaSrc)) !== null) {
  directions.push({ key: m[1], label: m[2], regex: m[3] })
}
if (directions.length === 0) {
  throw new Error('未能从 MajorDirection.java 解析出任何方向，请检查文件格式是否被改动')
}

// ALL 数组决定优先级
const allMatch = javaSrc.match(/MajorDirection\[\]\s+ALL\s*=\s*\{([\s\S]*?)\}/)
if (!allMatch) throw new Error('未找到 MajorDirection.java 中的 ALL 数组')
const order = allMatch[1]
  .split(',')
  .map((s) => s.replace(/\/\/.*$/gm, '').trim())
  .filter((s) => /^\w+$/.test(s))

const byKey = new Map(directions.map((d) => [d.key, d]))
const ordered = order.map((k) => byKey.get(k)).filter(Boolean)

// ------------------------------------------------------------
// 2. 模板与方向定义必须一一对应
// ------------------------------------------------------------
const missing = ordered.filter((d) => d.key !== 'GENERAL' && !COURSE_TEMPLATES[d.key])
if (missing.length) {
  throw new Error(
    '以下方向在 MajorDirection.java 里有定义，但 scripts/course-templates.mjs 缺少课程模板：' +
      missing.map((d) => d.key).join(', ')
  )
}
const unknown = Object.keys(COURSE_TEMPLATES).filter((k) => !byKey.has(k))
if (unknown.length) {
  throw new Error(
    '以下课程模板在后端 MajorDirection.java 里没有对应方向（拼写错误？）：' + unknown.join(', ')
  )
}

// ------------------------------------------------------------
// 3. 校验：每个专业必须都能匹配到某个方向（GENERAL 视为未覆盖）
// ------------------------------------------------------------
function resolve(major) {
  for (const d of ordered) {
    if (d.key === 'GENERAL') continue
    if (new RegExp(d.regex).test(major)) return d
  }
  return null
}

const unmatched = []
const counts = new Map()
for (const major of allMajors) {
  const d = resolve(major)
  if (!d) unmatched.push(major)
  else counts.set(d.key, (counts.get(d.key) || 0) + 1)
}
if (unmatched.length) {
  throw new Error('以下专业没有任何方向能匹配，需要补充正则：' + unmatched.join('、'))
}

// ------------------------------------------------------------
// 4. 生成 SQL
// ------------------------------------------------------------
function sqlStr(s) {
  return "'" + String(s).replace(/'/g, "''") + "'"
}

function courseBlock({ label, regex, extraWhere }, courses, comment) {
  const rows = courses
    .map((c, i) => {
      if (c.length !== 5) throw new Error('课程字段数不是 5：' + JSON.stringify(c))
      const [name, desc, difficulty, semester, category] = c
      const head = i === 0 ? '    SELECT ' : '    UNION ALL SELECT '
      return (
        head +
        [
          `${sqlStr(name)} AS name`,
          `${sqlStr(desc)} AS description`,
          `${sqlStr(difficulty)} AS difficulty`,
          `${sqlStr(semester)} AS semester`,
          `${sqlStr(category)} AS category`,
          `${i + 1} AS sort_order`,
        ].join(', ')
      )
    })
    .join('\n')

  // 注意：这里必须始终有 WHERE。
  // MySQL 把 CROSS JOIN 当作 INNER JOIN 的同义词，写「) c」之后紧跟
  // 「ON DUPLICATE KEY UPDATE」时，解析器会把 ON 当成 JOIN 的 ON 条件，
  // 报 ERROR 1064 ... near 'KEY UPDATE'。加一个恒真的 WHERE 1 = 1 把
  // FROM 子句收口，就不会有歧义。
  const where = regex
    ? `WHERE m.name REGEXP ${sqlStr(regex)}` + (extraWhere ? `\n  AND ${extraWhere}` : '')
    : 'WHERE 1 = 1'

  return [
    `-- ${comment}`,
    'INSERT INTO course (major_id, name, description, difficulty, semester, category, sort_order)',
    'SELECT m.id, c.name, c.description, c.difficulty, c.semester, c.category, c.sort_order',
    'FROM major m',
    'CROSS JOIN (',
    rows,
    ') c',
    where,
    'ON DUPLICATE KEY UPDATE',
    '    description = VALUES(description), difficulty = VALUES(difficulty),',
    '    semester = VALUES(semester), category = VALUES(category), sort_order = VALUES(sort_order);',
    '',
  ]
    .filter((l) => l !== null)
    .join('\n')
}

const parts = []
parts.push('-- ' + COMMON_COURSES.length + ' 门通识课，铺给全部 ' + allMajors.length + ' 个专业')
parts.push('')
parts.push(courseBlock({ label: '通识课程', regex: null }, COMMON_COURSES, '通识课程 · 所有专业'))
parts.push('-- 以下按专业方向逐块铺开；顺序与 MajorDirection.java 的优先级一致')
parts.push('')
for (const d of ordered) {
  if (d.key === 'GENERAL') continue
  const courses = COURSE_TEMPLATES[d.key]
  // 优先级：排在前面、且已经匹配过的方向不再重复铺课。
  // 数据库里的 REGEXP 是各自独立的，不像 MajorDirection.resolve() 那样「先匹配先胜」，
  // 不加这段排除的话，像「化学工程与工艺」会同时命中 CHEM 和 SCIENCE 两个方向，
  // 拿到两份课程（其中还有细胞生物学这种完全不相干的课）。
  const prior = ordered
    .slice(0, ordered.indexOf(d))
    .filter((x) => x.key !== 'GENERAL')
    .map((x) => x.regex)
  const conds = []
  if (d.key === 'IT') {
    // 前 5 个专业（计算机 / 软件工程 / 人工智能 / 大数据 / 电子信息）在 data.sql
    // 上半部分是手写的、更细的课程表，这里跳过它们避免覆盖。
    conds.push('m.id NOT IN (1, 2, 3, 4, 5)')
  }
  if (prior.length) {
    conds.push(`m.name NOT REGEXP ${sqlStr(prior.join('|'))}`)
  }
  parts.push(
    courseBlock(
      { label: d.label, regex: d.regex, extraWhere: conds.length ? conds.join('\n  AND ') : null },
      courses,
      `${d.label} · ${counts.get(d.key) || 0} 个专业`
    )
  )
}

const generated = [BEGIN_MARK, ...parts, END_MARK].join('\n')

// ------------------------------------------------------------
// 5. 写回 data.sql（只替换标记之间的内容）
// ------------------------------------------------------------
let sql = readFileSync(DATA_SQL, 'utf8')
const b = sql.indexOf(BEGIN_MARK)
const e = sql.indexOf(END_MARK)
if (b < 0 || e < 0 || e < b) {
  throw new Error(`database/data.sql 里找不到生成标记，请先手工加入：\n${BEGIN_MARK}\n${END_MARK}`)
}
sql = sql.slice(0, b) + generated + sql.slice(e + END_MARK.length)
writeFileSync(DATA_SQL, sql, 'utf8')

// ------------------------------------------------------------
// 6. 报告
// ------------------------------------------------------------
console.log('方向数：' + ordered.length)
console.log('通识课：' + COMMON_COURSES.length)
let total = COMMON_COURSES.length * allMajors.length
for (const d of ordered) {
  if (d.key === 'GENERAL') continue
  const n = COURSE_TEMPLATES[d.key].length
  const c = counts.get(d.key) || 0
  total += n * c
  console.log(`  ${d.key.padEnd(12)} ${String(c).padStart(3)} 个专业 x ${String(n).padStart(2)} 门 = ${String(c * n).padStart(4)} 行  (${d.label})`)
}
console.log(`已写回 database/data.sql，预计课程总行数 ≈ ${total}`)
