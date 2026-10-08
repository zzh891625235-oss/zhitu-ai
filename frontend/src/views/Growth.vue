<template>
  <div class="growth-page">
    <div class="page-hero">
      <h1><el-icon><DataAnalysis /></el-icon> AI动态规划</h1>
      <p>记录每天学习，AI分析并动态调整你的成长计划</p>
    </div>

    <!-- 标签切换 -->
    <div class="tab-bar">
      <div class="tab-item" :class="{ active: tab === 'plan' }" @click="tab = 'plan'">
        <el-icon><Calendar /></el-icon> 学习计划
      </div>
      <div class="tab-item" :class="{ active: tab === 'archive' }" @click="switchToArchive">
        <el-icon><FolderOpened /></el-icon> 成长档案
      </div>
    </div>

    <!-- 学习计划视图 -->
    <template v-if="tab === 'plan'">
      <div class="checkin-section">
        <el-card shadow="never" class="checkin-card">
          <template #header><div class="card-head"><el-icon><Edit /></el-icon> 今日学习打卡</div></template>
          <div class="checkin-form">
            <el-input v-model="recordContent" placeholder="学了什么？" size="large" />
            <div class="checkin-row">
              <el-input-number v-model="recordMinutes" :min="5" :max="480" :step="5" size="large" />
              <span class="checkin-unit">分钟</span>
              <el-select v-model="recordCourseId" :placeholder="courseOptions.length ? '课程' : '暂无课程数据'" size="large" style="width:180px">
                <el-option v-for="c in courseOptions" :key="c.id" :label="c.name" :value="c.id" />
              </el-select>
              <el-button type="primary" size="large" @click="handleCheckin" :loading="checkingIn">打卡</el-button>
            </div>
          </div>
        </el-card>
      </div>

      <div class="analysis-panel" v-if="analysis">
        <div class="analysis-card" :class="analysis.mood">
          <div class="analysis-emoji">{{ analysis.mood === 'excellent' ? '🔥' : analysis.mood === 'good' ? '👍' : '💪' }}</div>
          <div class="analysis-info">
            <h3>AI学习分析</h3>
            <p>{{ analysis.consistency }}</p>
            <div class="analysis-stats">
              <span>📊 {{ analysis.totalMinutes }}分钟</span>
              <span>📚 {{ analysis.coursesCovered }}门</span>
              <span>📝 {{ analysis.recordCount }}条</span>
            </div>
            <p class="analysis-suggest">{{ analysis.suggestion }}</p>
          </div>
        </div>
      </div>

      <div class="plan-section">
        <div class="plan-header">
          <h3>学习计划</h3>
          <el-button type="primary" size="small" round @click="handleGenerate" :loading="generating">
            {{ plan.length ? '🔄 重新规划' : '✨ AI生成' }}
          </el-button>
        </div>
        <div class="plan-timeline" v-if="plan.length">
          <div class="plan-day" v-for="(item, idx) in plan" :key="idx" :class="{ today: idx === 0 }">
            <div class="day-marker"><div class="day-dot"></div><div class="day-line" v-if="idx < plan.length - 1"></div></div>
            <div class="day-card">
              <div class="day-label">{{ formatDate(item.date) }}</div>
              <div class="day-task">{{ item.content }}</div>
            </div>
          </div>
        </div>
        <el-empty v-else description="AI将根据你的弱项生成学习计划" :image-size="60" />
      </div>
    </template>

    <!-- 成长档案视图 -->
    <template v-if="tab === 'archive'">
      <!-- 统计卡片 -->
      <div class="archive-stats">
        <div class="a-stat"><span class="a-num">{{ archive?.totalStudyMinutes || 0 }}</span><span class="a-label">学习分钟</span></div>
        <div class="a-stat"><span class="a-num">{{ archive?.coursesLearned || 0 }}</span><span class="a-label">已学课程</span></div>
        <div class="a-stat"><span class="a-num">{{ archive?.totalRecords || 0 }}</span><span class="a-label">成长记录</span></div>
      </div>

      <!-- 添加记录 -->
      <el-card shadow="never" class="add-record-card">
        <template #header><div class="card-head"><el-icon><Plus /></el-icon> 添加记录</div></template>
        <div class="add-form">
          <el-select v-model="newType" placeholder="类型" size="default" style="width:140px">
            <el-option label="🏆 竞赛" value="COMPETITION" />
            <el-option label="💻 项目" value="PROJECT" />
            <el-option label="📜 证书" value="CERTIFICATE" />
            <el-option label="💼 实习" value="INTERNSHIP" />
            <el-option label="🎖 获奖" value="AWARD" />
          </el-select>
          <el-input v-model="newTitle" placeholder="标题（如：XX竞赛省级二等奖）" size="default" />
          <el-input v-model="newDesc" placeholder="描述（可选）" size="default" />
          <el-button type="primary" size="default" @click="handleAdd" :loading="adding">添加</el-button>
        </div>
      </el-card>

      <!-- 分类展示 -->
      <div class="archive-records" v-if="archive?.records">
        <div class="archive-group" v-for="(items, type) in archive.records" :key="type">
          <div class="group-header">
            <span class="group-icon">{{ typeIcon(type) }}</span>
            <span class="group-name">{{ typeLabel(type) }}</span>
            <span class="group-count">{{ items.length }}项</span>
          </div>
          <div class="group-items">
            <div class="g-item" v-for="item in items" :key="item.id">
              <span class="gi-title">{{ item.title }}</span>
              <span class="gi-desc" v-if="item.description">{{ item.description }}</span>
              <span class="gi-date">{{ item.date }}</span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="还没有成长记录，开始添加吧" :image-size="60" />
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { DataAnalysis, Edit, Calendar, FolderOpened, Plus, Check } from '@element-plus/icons-vue'
import { getStudyPlanApi, generateStudyPlanApi, recordStudyApi } from '../api/studyplan'
import { getArchiveApi, addGrowthRecordApi } from '../api/growth'
import { getProfileApi } from '../api/profile'
import { getCoursesApi } from '../api/course'
import { ElMessage } from 'element-plus'

const tab = ref('plan')
const plan = ref([])
const analysis = ref(null)
const archive = ref(null)
const generating = ref(false)
const checkingIn = ref(false)
const adding = ref(false)
const recordContent = ref('')
const recordMinutes = ref(30)
const recordCourseId = ref(null)
const newType = ref('COMPETITION')
const newTitle = ref('')
const newDesc = ref('')

// 打卡课程下拉：来自学生本人专业的真实课程（后端 /courses?majorId=）
const courseOptions = ref([])

async function loadCourses() {
  try {
    const profile = (await getProfileApi()).data
    const majorId = profile?.majorId
    if (!majorId) return
    const list = (await getCoursesApi(majorId)).data || []
    courseOptions.value = list.map(c => ({ id: c.id, name: c.name }))
    if (courseOptions.value.length && recordCourseId.value == null) {
      recordCourseId.value = courseOptions.value[0].id
    }
  } catch (e) {
    // 课程拉取失败时保持空列表，不回落任何写死的课程名
  }
}

function formatDate(d) {
  const date = new Date(d); const diff = Math.ceil((date - new Date()) / 86400000)
  if (diff === 0) return '今天'; if (diff === 1) return '明天'
  return `${date.getMonth()+1}/${date.getDate()}`
}
function typeIcon(t) {
  return { COMPETITION:'🏆', PROJECT:'💻', CERTIFICATE:'📜', INTERNSHIP:'💼', AWARD:'🎖' }[t] || '📌'
}
function typeLabel(t) {
  return { COMPETITION:'竞赛经历', PROJECT:'项目经历', CERTIFICATE:'证书', INTERNSHIP:'实习经历', AWARD:'获奖记录' }[t] || t
}

onMounted(async () => {
  try { plan.value = (await getStudyPlanApi()).data } catch (e) {}
  await loadCourses()
})

async function switchToArchive() {
  tab.value = 'archive'
  if (!archive.value) {
    try { archive.value = (await getArchiveApi()).data } catch (e) {}
  }
}

async function handleGenerate() {
  generating.value = true
  try { plan.value = (await generateStudyPlanApi(7)).data; ElMessage.success('计划已生成') }
  catch (e) { ElMessage.error('生成失败') }
  finally { generating.value = false }
}

async function handleCheckin() {
  if (!recordContent.value.trim()) { ElMessage.warning('请输入学习内容'); return }
  checkingIn.value = true
  try {
    const payload = { content: recordContent.value, minutes: recordMinutes.value }
    // 没有可选课程时不传 courseId，避免把计算机方向的课程 id 记到别的专业上
    if (recordCourseId.value != null) payload.courseId = recordCourseId.value
    const res = await recordStudyApi(payload)
    analysis.value = res.data; recordContent.value = ''; ElMessage.success('打卡成功')
  } catch (e) {} finally { checkingIn.value = false }
}

async function handleAdd() {
  if (!newTitle.value.trim()) { ElMessage.warning('请输入标题'); return }
  adding.value = true
  try {
    await addGrowthRecordApi({ recordType: newType.value, title: newTitle.value, description: newDesc.value, recordDate: new Date().toISOString().split('T')[0] })
    newTitle.value = ''; newDesc.value = ''; ElMessage.success('添加成功')
    archive.value = (await getArchiveApi()).data
  } catch (e) {} finally { adding.value = false }
}
</script>

<style scoped>
.growth-page { max-width: 900px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.tab-bar { display: flex; justify-content: center; gap: 4px; margin-bottom: 24px; background: rgba(255,255,255,.04); border-radius: 12px; padding: 4px; width: fit-content; margin-left: auto; margin-right: auto; }
.tab-item { display: flex; align-items: center; gap: 6px; padding: 10px 22px; border-radius: 10px; cursor: pointer; font-size: 14px; font-weight: 500; color: var(--text-secondary); transition: all .2s; }
.tab-item.active { background:var(--glass); color: var(--primary); box-shadow: var(--shadow-sm); }

.card-head { display: flex; align-items: center; gap: 8px; font-size: 16px; font-weight: 600; }
.checkin-form { display: flex; flex-direction: column; gap: 14px; }
.checkin-row { display: flex; align-items: center; gap: 12px; }
.checkin-unit { font-size: 14px; color: var(--text-secondary); }

.analysis-panel { margin-bottom: 24px; }
.analysis-card { display: flex; gap: 20px; padding: 24px; border-radius: var(--radius-lg); border: 1px solid var(--border); }
.analysis-card.excellent { background: rgba(0,210,160,.06); border-color: rgba(0,210,160,.2); }
.analysis-card.good { background: rgba(139,195,74,.04); border-color: rgba(139,195,74,.12); }
.analysis-card.needs_effort { background: rgba(254,202,87,.06); border-color: rgba(254,202,87,.2); }
.analysis-emoji { font-size: 42px; }
.analysis-stats { display: flex; gap: 16px; margin: 8px 0; font-size: 13px; }
.analysis-suggest { background: rgba(255,255,255,.05); padding: 8px 12px; border-radius: 8px; font-size: 13px; color: var(--primary); }

.plan-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.plan-header h3 { font-size: 18px; font-weight: 600; }
.plan-timeline { display: flex; flex-direction: column; }
.plan-day { display: flex; gap: 16px; }
.day-marker { display: flex; flex-direction: column; align-items: center; width: 32px; }
.day-dot { width: 14px; height: 14px; border-radius: 50%; border: 2.5px solid var(--border); background:var(--glass); margin-top: 16px; }
.day-line { width: 2px; flex: 1; background: var(--border); min-height: 16px; }
.day-card { flex: 1; padding: 12px 16px; border: 1px solid var(--border); border-radius: 8px; margin-bottom: 6px; display: flex; align-items: center; gap: 12px; }
.plan-day.today .day-card { border-color: var(--primary); background: rgba(139,195,74,.02); }
.day-label { font-weight: 600; font-size: 14px; min-width: 60px; }
.day-task { font-size: 14px; color: var(--text-secondary); }

.archive-stats { display: flex; justify-content: center; gap: 40px; margin-bottom: 24px; }
.a-stat { text-align: center; }
.a-num { display: block; font-size: 28px; font-weight: 700; color: var(--primary); }
.a-label { display: block; font-size: 12px; color: var(--text-muted); }

.add-record-card { margin-bottom: 24px; }
.add-form { display: flex; gap: 10px; align-items: center; }
.add-form .el-input { flex: 1; }

.archive-records { display: flex; flex-direction: column; gap: 20px; }
.archive-group { background:var(--glass); border-radius: var(--radius); border: 1px solid var(--border); overflow: hidden; }
.group-header { display: flex; align-items: center; gap: 10px; padding: 14px 18px; background: rgba(255,255,255,.02); border-bottom: 1px solid var(--border); }
.group-icon { font-size: 18px; }
.group-name { font-weight: 600; font-size: 15px; }
.group-count { margin-left: auto; font-size: 12px; color: var(--text-muted); }
.group-items { padding: 8px 18px; }
.g-item { display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid var(--slate-50); font-size: 14px; }
.g-item:last-child { border-bottom: none; }
.gi-title { font-weight: 500; min-width: 200px; }
.gi-desc { color: var(--text-muted); flex: 1; font-size: 13px; }
.gi-date { color: var(--text-muted); font-size: 12px; }
</style>
