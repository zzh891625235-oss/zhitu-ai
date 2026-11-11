<template>
  <div class="resume-page">
    <div class="page-hero">
      <h1><el-icon><Document /></el-icon> AI简历</h1>
      <p>基于你的成长档案，AI自动生成专业简历</p>
    </div>

    <div class="resume-actions" v-if="!resume">
      <el-button type="primary" size="large" round @click="handleGenerate" :loading="genLoading">
        {{ genLoading ? 'AI分析中...' : '✨ AI生成我的简历' }}
      </el-button>
    </div>

    <!-- 简历预览 -->
    <div v-if="resume" class="resume-preview">
      <div class="resume-toolbar">
        <el-button size="small" round @click="handleGenerate" :loading="genLoading">🔄 重新生成</el-button>
        <el-button size="small" type="primary" plain round @click="openEdit">✏️ 在线编辑</el-button>
        <el-button size="small" round @click="handleDownload">⬇ 下载简历文件</el-button>
        <el-button size="small" round @click="handlePrint">🖨 打印 / 导出 PDF</el-button>
      </div>

      <!-- A4简历纸 -->
      <div class="resume-paper" id="resumePaper">
        <div class="paper-header">
          <h1>{{ resume.name }}</h1>
          <div class="paper-contact">
            <span>{{ resume.education?.school }}</span>
            <span>{{ resume.education?.major }}</span>
            <span>{{ resume.education?.grade }}</span>
          </div>
          <div class="paper-target">
            <el-tag type="primary" effect="dark" round>🎯 {{ resume.targetPosition }}</el-tag>
          </div>
        </div>

        <div class="paper-section" v-if="resume.advantages">
          <h3>个人优势</h3>
          <p>{{ resume.advantages }}</p>
        </div>

        <div class="paper-section" v-if="resume.skills?.length">
          <h3>专业技能</h3>
          <div class="skill-tags">
            <span class="skill-tag" v-for="s in resume.skills" :key="s">{{ s }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.courses?.length">
          <h3>核心课程</h3>
          <div class="skill-tags">
            <span class="skill-tag course" v-for="c in resume.courses" :key="c">{{ c }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.projects?.length">
          <h3>项目经历</h3>
          <div class="paper-item" v-for="(p, i) in resume.projects" :key="i">
            <div class="item-dot"></div>
            <span>{{ p }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.competitions?.length">
          <h3>竞赛经历</h3>
          <div class="paper-item" v-for="(c, i) in resume.competitions" :key="i">
            <div class="item-dot comp"></div>
            <span>{{ c }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.certificates?.length">
          <h3>证书</h3>
          <div class="paper-item" v-for="(c, i) in resume.certificates" :key="i">
            <div class="item-dot cert"></div>
            <span>{{ c }}</span>
          </div>
        </div>
      </div>
    </div>

    <el-empty v-if="!resume && !genLoading" description="AI会根据你的学习记录、项目经历和竞赛成绩自动生成简历" :image-size="100" />

    <!-- 在线编辑：生成后还能按真实经历改，改动会写回数据库 -->
    <el-dialog v-model="editVisible" title="在线编辑简历" width="700px" class="resume-edit-dialog"
      :close-on-click-modal="false" top="6vh">
      <el-form label-position="top" class="resume-form">
        <div class="form-row">
          <el-form-item label="姓名"><el-input v-model="form.name" maxlength="40" placeholder="姓名" /></el-form-item>
          <el-form-item label="意向岗位"><el-input v-model="form.targetPosition" maxlength="80" placeholder="例如：算法工程师" /></el-form-item>
        </div>
        <div class="form-row three">
          <el-form-item label="学校"><el-input v-model="form.school" placeholder="学校" /></el-form-item>
          <el-form-item label="专业"><el-input v-model="form.major" placeholder="专业" /></el-form-item>
          <el-form-item label="年级"><el-input v-model="form.grade" placeholder="例如：大三" /></el-form-item>
        </div>
        <el-form-item label="个人优势">
          <el-input v-model="form.advantages" type="textarea" :rows="3" maxlength="600" show-word-limit
            placeholder="用两三句话概括你的优势" />
        </el-form-item>
        <el-form-item v-for="f in listFields" :key="f.key" :label="f.label + '（每行一项）'">
          <el-input v-model="form[f.key]" type="textarea" :rows="3" :placeholder="f.placeholder" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSave">保存简历</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { Document } from '@element-plus/icons-vue'
import { generateResumeApi, getResumeApi, saveResumeApi } from '../api/resume'
import { ElMessage } from 'element-plus'

const resume = ref(null)
const genLoading = ref(false)
const saving = ref(false)
const editVisible = ref(false)

const listFields = [
  { key: 'skills', label: '专业技能', placeholder: '例如：Python / SPSS / 文献检索' },
  { key: 'courses', label: '核心课程', placeholder: '例如：普通心理学' },
  { key: 'projects', label: '项目经历', placeholder: '例如：校园心理普查数据分析' },
  { key: 'competitions', label: '竞赛经历', placeholder: '例如：全国大学生心理科学知识竞赛' },
  { key: 'certificates', label: '证书', placeholder: '例如：大学英语六级' },
]

const emptyForm = () => ({
  name: '', targetPosition: '', school: '', major: '', grade: '', advantages: '',
  skills: '', courses: '', projects: '', competitions: '', certificates: ''
})
const form = ref(emptyForm())

onMounted(async () => {
  try { resume.value = (await getResumeApi()).data } catch (e) {}
})
onUnmounted(() => document.body.classList.remove('resume-print'))

async function handleGenerate() {
  genLoading.value = true
  try {
    resume.value = (await generateResumeApi()).data
    ElMessage.success('AI简历生成完成！')
  } catch (e) {
    // 409「未初始化档案」已由全局拦截器弹出可跳转引导，这里不重复报错
    if (!/档案|初始化/.test(e?.message || '')) ElMessage.error('生成失败，请稍后重试')
  } finally { genLoading.value = false }
}

function openEdit() {
  const r = resume.value || {}
  form.value = {
    name: r.name || '',
    targetPosition: r.targetPosition || '',
    school: r.education?.school || '',
    major: r.education?.major || '',
    grade: r.education?.grade || '',
    advantages: r.advantages || '',
    skills: (r.skills || []).join('\n'),
    courses: (r.courses || []).join('\n'),
    projects: (r.projects || []).join('\n'),
    competitions: (r.competitions || []).join('\n'),
    certificates: (r.certificates || []).join('\n'),
  }
  editVisible.value = true
}

const splitLines = v => String(v || '').split('\n').map(s => s.trim()).filter(Boolean)

async function handleSave() {
  saving.value = true
  try {
    const f = form.value
    const payload = {
      name: f.name, targetPosition: f.targetPosition, advantages: f.advantages,
      education: { school: f.school, major: f.major, grade: f.grade },
      skills: splitLines(f.skills), courses: splitLines(f.courses),
      projects: splitLines(f.projects), competitions: splitLines(f.competitions),
      certificates: splitLines(f.certificates),
    }
    resume.value = (await saveResumeApi(payload)).data
    editVisible.value = false
    ElMessage.success('简历已保存，刷新页面后依然保留')
  } catch (e) {
    ElMessage.error('保存失败，请稍后重试')
  } finally { saving.value = false }
}

const ESC_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ESC_MAP[c])

/** 生成一份完全独立、白底 A4 的 HTML 简历，双击即可打开或另存为 PDF */
function buildResumeHtml(r) {
  const arr = k => (Array.isArray(r[k]) ? r[k] : []).filter(x => String(x || '').trim())
  const tags = items => items.length
    ? `<div class="tags">${items.map(i => `<span>${esc(i)}</span>`).join('')}</div>` : ''
  const list = items => items.length
    ? `<ul>${items.map(i => `<li>${esc(i)}</li>`).join('')}</ul>` : ''
  const sec = (title, inner) => inner ? `<section><h2>${esc(title)}</h2>${inner}</section>` : ''
  const edu = r.education || {}
  const sections = [
    sec('个人优势', r.advantages ? `<p>${esc(r.advantages)}</p>` : ''),
    sec('专业技能', tags(arr('skills'))),
    sec('核心课程', tags(arr('courses'))),
    sec('项目经历', list(arr('projects'))),
    sec('竞赛经历', list(arr('competitions'))),
    sec('证书', list(arr('certificates'))),
  ].filter(Boolean).join('\n')

  return `<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(r.name || '同学')} - 个人简历</title>
<style>
@page{size:A4;margin:16mm}
*{box-sizing:border-box}
body{font-family:"Microsoft YaHei","PingFang SC",Arial,sans-serif;color:#1a1a1a;background:#fff;margin:0;line-height:1.7}
.paper{max-width:780px;margin:0 auto;padding:32px 36px}
h1{font-size:28px;letter-spacing:3px;margin:0 0 8px;text-align:center}
.contact{text-align:center;color:#555;font-size:13px;margin-bottom:10px}
.contact span{margin:0 10px}
.target{text-align:center;font-size:13px;color:#2b6cb0;margin:0 0 22px}
hr{border:0;border-top:2px solid #2b6cb0;margin:0 0 22px}
section{margin-bottom:20px;break-inside:avoid;page-break-inside:avoid}
h2{font-size:16px;border-left:4px solid #2b6cb0;padding-left:10px;margin:0 0 10px}
p{margin:0;font-size:13.5px}
.tags{display:flex;flex-wrap:wrap;gap:8px}
.tags span{border:1px solid #cbd5e0;border-radius:14px;padding:3px 12px;font-size:12.5px}
ul{margin:0;padding-left:20px}li{font-size:13.5px;margin-bottom:5px}
@media print{body{background:#fff}.paper{padding:0;max-width:none}}
</style></head><body><div class="paper">
<h1>${esc(r.name || '同学')}</h1>
<div class="contact"><span>${esc(edu.school || '')}</span><span>${esc(edu.major || '')}</span><span>${esc(edu.grade || '')}</span></div>
<div class="target">意向岗位：${esc(r.targetPosition || '未填写')}</div><hr />
${sections}
</div></body></html>`
}

function handleDownload() {
  if (!resume.value) return
  const blob = new Blob([buildResumeHtml(resume.value)], { type: 'text/html;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  const safeName = String(resume.value.name || '学生').replace(/[\\/:*?"<>|]/g, '').trim() || '学生'
  a.href = url
  a.download = `智途AI-简历-${safeName}.html`
  document.body.appendChild(a)
  a.click()
  a.remove()
  setTimeout(() => URL.revokeObjectURL(url), 1500)
  ElMessage.success('已下载独立简历文件，可直接打开或另存为 PDF')
}

function handlePrint() {
  // 只在打印期间给 body 打标记，全局 @media print 据此切白底并隐藏导航/工具栏
  document.body.classList.add('resume-print')
  window.print()
  setTimeout(() => document.body.classList.remove('resume-print'), 600)
}
</script>

<style scoped>
.resume-page { max-width: 900px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.resume-actions { text-align: center; margin-bottom: 32px; }

.resume-toolbar { display: flex; justify-content: center; flex-wrap: wrap; gap: 10px; margin-bottom: 28px; }

/* A4纸 */
.resume-paper {
  max-width: 800px; margin: 0 auto; background:var(--glass);
  padding: 48px 52px; border-radius: 4px;
  box-shadow: 0 4px 30px rgba(0,0,0,.1);
}
.paper-header { text-align: center; border-bottom: 2px solid var(--primary); padding-bottom: 20px; margin-bottom: 24px; }
.paper-header h1 { font-size: 26px; font-weight: 700; letter-spacing: 2px; }
.paper-contact { display: flex; justify-content: center; gap: 20px; margin-top: 10px; font-size: 14px; color: var(--text-secondary); }
.paper-target { margin-top: 14px; }

.paper-section { margin-bottom: 22px; }
.paper-section h3 {
  font-size: 16px; font-weight: 700; color: var(--primary);
  border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;
}
.paper-section p { font-size: 14px; color: var(--text-secondary); line-height: 1.8; }

.skill-tags { display: flex; flex-wrap: wrap; gap: 8px; }
.skill-tag {
  padding: 4px 14px; border-radius: 20px; background: rgba(139,195,74,.08);
  font-size: 13px; color: var(--primary); font-weight: 500;
}
.skill-tag.course { background: rgba(77,208,196,.10); color: #4DD0C4; }

.paper-item { display: flex; align-items: center; gap: 10px; font-size: 14px; color: var(--text-secondary); margin-bottom: 8px; }
.item-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--primary); flex-shrink: 0; }
.item-dot.comp { background: var(--amber); }
.item-dot.cert { background: #66BB6A; }

@media (max-width:820px) {
  .resume-paper { padding: 26px 20px; }
  .paper-header h1 { font-size: 21px; }
  .paper-contact { flex-wrap: wrap; gap: 10px; }
  .resume-toolbar { flex-wrap: wrap; }
}
</style>
