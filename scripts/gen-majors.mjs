// ============================================================
// 专业字典生成工具
//
// 把 frontend/src/data/majors.js 中的专业列表转换成 database/majors.sql，
// 避免手工维护 175 条专业数据时出错。
//
// 用法（在项目根目录执行）：
//   node scripts/gen-majors.mjs
//
// 修改专业列表的流程：
//   1. 编辑 frontend/src/data/majors.js
//   2. 执行本脚本重新生成 database/majors.sql
//   3. 重新执行 scripts/init-db.ps1（或 init-db.sh）导入数据库
//
// 注意：生成的专业 ID 是按顺序显式指定的（1..N），
// 前 5 个固定为 计算机科学与技术 / 软件工程 / 人工智能 /
// 大数据科学与技术 / 电子信息工程，data.sql 中的课程数据依赖这一顺序。
// ============================================================
import { writeFileSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'

const scriptDir = dirname(fileURLToPath(import.meta.url))
const projectRoot = resolve(scriptDir, '..')

const srcPath = resolve(projectRoot, 'frontend/src/data/majors.js')
const outPath = resolve(projectRoot, 'database/majors.sql')

const { majorCategories } = await import(pathToFileURL(srcPath).href)

const seen = new Set()
const rows = []
let id = 0

for (const category of majorCategories) {
  for (const name of category.majors) {
    if (seen.has(name)) continue // 同名专业只保留首个学科门类
    seen.add(name)
    id += 1
    rows.push(`(${id}, '${name}', '${category.label}', ${id})`)
  }
}

const sql = `-- ============================================================
-- 智途AI · 大学生成长规划平台
-- 02 / 03 —— 专业字典数据（DML）
-- 共 ${id} 个专业，覆盖 ${majorCategories.length} 个学科门类
--
-- 本文件由 frontend/src/data/majors.js 生成，请勿手工编辑；
-- 需要调整专业列表时修改该 js，然后执行：
--     node scripts/gen-majors.mjs
--
-- 显式指定 id，保证 course.major_id 等外键引用稳定可预测。
-- 可安全重复执行（依赖 major.name 唯一键）。
-- ============================================================

USE zhitu_ai;

INSERT INTO major (id, name, category, sort_order) VALUES
${rows.join(',\n')}
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category = VALUES(category),
    sort_order = VALUES(sort_order);
`

writeFileSync(outPath, sql, 'utf8')
console.log(`已生成 ${outPath}`)
console.log(`  专业数量：${id}`)
console.log(`  学科门类：${majorCategories.length}`)
