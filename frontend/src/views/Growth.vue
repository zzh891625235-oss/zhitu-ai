<template>
  <div class="growth-page">
    <div class="page-hero">
      <h1><el-icon><DataAnalysis /></el-icon> AI动态规划</h1>
      <p>记录每天学习，AI分析并动态调整你的成长计划</p>
    </div>

    <!-- 学习打卡 -->
    <div class="checkin-section">
      <el-card shadow="never" class="checkin-card">
        <template #header>
          <div class="card-head"><el-icon><Edit /></el-icon> 今日学习打卡</div>
        </template>
        <div class="checkin-form">
          <el-input v-model="recordContent" placeholder="学了什么？（如：Java多态、链表反转）" size="large" class="checkin-input" />
          <div class="checkin-row">
            <el-input-number v-model="recordMinutes" :min="5" :max="480" :step="5" size="large" />
            <span class="checkin-unit">分钟</span>
            <el-select v-model="recordCourseId" placeholder="关联课程" size="large" style="width:200px">
              <el-option v-for="c in courseOptions" :key="c.id" :label="c.name" :value="c.id" />
            </el-select>
            <el-button type="primary" size="large" @click="handleCheckin" :loading="checkingIn">
              打卡记录 <el-icon><Check /></el-icon>
            </el-button>
          </div>
        </div>
      </el-card>
    </div>

    <!-- AI分析面板 -->
    <div class="analysis-panel" v-if="analysis">
      <div class="analysis-card" :class="analysis.mood">
        <div class="analysis-emoji">
          {{ analysis.mood === 'excellent' ? '🔥' : analysis.mood === 'good' ? '👍' : '💪' }}
        </div>
        <div class="analysis-info">
          <h3>AI学习分析</h3>
          <p>{{ analysis.consistency }}</p>
          <div class="analysis-stats">
            <span>📊 累计 {{ analysis.totalMinutes }} 分钟</span>
            <span>📚 覆盖 {{ analysis.coursesCovered }} 门课程</span>
            <span>📝 {{ analysis.recordCount }} 条记录</span>
          </div>
          <p class="analysis-suggest">{{ analysis.suggestion }}</p>
        </div>
      </div>
    </div>

    <!-- 学习计划 -->
    <div class="plan-section">
      <div class="plan-header">
        <h3><el-icon><Calendar /></el-icon> 未来学习计划</h3>
        <el-button type="primary" size="small" round @click="handleGenerate" :loading="generating">
          {{ plan.length ? '🔄 AI重新规划' : '✨ AI生成计划' }}
        </el-button>
      </div>

      <div class="plan-timeline" v-if="plan.length">
        <div class="plan-day" v-for="(item, idx) in plan" :key="idx"
          :class="{ today: idx === 0, completed: item.completed }">
          <div class="day-marker">
            <div class="day-dot" :class="{ done: item.completed }"></div>
            <div class="day-line" v-if="idx < plan.length - 1"></div>
          </div>
          <div class="day-card" @click="toggleComplete(item)">
            <div class="day-label">{{ formatDate(item.date) }}</div>
            <div class="day-task">{{ item.content }}</div>
            <div class="day-check" v-if="item.completed">✓</div>
          </div>
        </div>
      </div>

      <el-empty v-else description="点击上方按钮，让AI为你生成学习计划" :image-size="80" />
    </div>

    <!-- 历史记录 -->
    <div class="records-section">
      <h3><el-icon><Timer /></el-icon> 最近学习记录</h3>
      <div class="record-list" v-if="recentRecords.length">
        <div class="record-item" v-for="r in recentRecords" :key="r.id">
          <span class="rec-time">{{ formatTime(r.createdAt) }}</span>
          <span class="rec-content">{{ r.notes }}</span>
          <span class="rec-minutes">{{ r.studyMinutes }}分钟</span>
        </div>
      </div>
      <el-empty v-else description="还没有学习记录，开始今天的打卡吧" :image-size="60" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { DataAnalysis, Edit, Check, Calendar, Timer } from '@element-plus/icons-vue'
import { getStudyPlanApi, generateStudyPlanApi, recordStudyApi } from '../api/studyplan'
import { ElMessage } from 'element-plus'

const plan = ref([])
const analysis = ref(null)
const recentRecords = ref([])
const generating = ref(false)
const checkingIn = ref(false)
const recordContent = ref('')
const recordMinutes = ref(30)
const recordCourseId = ref(1)

const courseOptions = [
  { id:1,name:'C语言程序设计' },{ id:2,name:'Python程序设计' },{ id:3,name:'数据结构' },
  { id:4,name:'算法设计与分析' },{ id:5,name:'数据库原理' },{ id:6,name:'Java程序设计' },
  { id:7,name:'Web前端开发' },{ id:8,name:'Spring Boot框架' }
]

function formatDate(d) {
  const date = new Date(d)
  const today = new Date()
  const diff = Math.ceil((date - today) / 86400000)
  if (diff === 0) return '今天'
  if (diff === 1) return '明天'
  if (diff === 2) return '后天'
  return `${date.getMonth()+1}/${date.getDate()} 周${'日一二三四五六'[date.getDay()]}`
}
function formatTime(t) {
  if (!t) return ''
  return new Date(t).toLocaleTimeString('zh-CN', {hour:'2-digit',minute:'2-digit'})
}

function toggleComplete(item) {
  item.completed = !item.completed
}

onMounted(async () => {
  try { plan.value = (await getStudyPlanApi()).data } catch (e) {}
})

async function handleGenerate() {
  generating.value = true
  try {
    plan.value = (await generateStudyPlanApi(7)).data
    ElMessage.success('AI学习计划已生成')
  } catch (e) { ElMessage.error('生成失败') }
  finally { generating.value = false }
}

async function handleCheckin() {
  if (!recordContent.value.trim()) {
    ElMessage.warning('请输入学习内容'); return
  }
  checkingIn.value = true
  try {
    const res = await recordStudyApi({
      content: recordContent.value,
      minutes: recordMinutes.value,
      courseId: recordCourseId.value
    })
    analysis.value = res.data
    ElMessage.success('打卡成功！AI已分析你的学习情况')
    recordContent.value = ''
  } catch (e) { ElMessage.error('打卡失败') }
  finally { checkingIn.value = false }
}
</script>

<style scoped>
.growth-page { max-width: 900px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 24px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

/* 打卡 */
.checkin-section { margin-bottom: 24px; }
.card-head { display: flex; align-items: center; gap: 8px; font-size: 16px; font-weight: 600; }
.checkin-form { display: flex; flex-direction: column; gap: 14px; }
.checkin-input { width: 100%; }
.checkin-row { display: flex; align-items: center; gap: 12px; }
.checkin-unit { font-size: 14px; color: var(--text-secondary); white-space: nowrap; }

/* AI分析 */
.analysis-panel { margin-bottom: 28px; }
.analysis-card {
  display: flex; gap: 20px; padding: 24px; border-radius: var(--radius-lg);
  border: 1px solid var(--border); transition: all var(--transition);
}
.analysis-card.excellent { background: linear-gradient(135deg, rgba(0,210,160,.08), rgba(85,239,196,.04)); border-color: rgba(0,210,160,.2); }
.analysis-card.good { background: linear-gradient(135deg, rgba(108,92,231,.06), rgba(162,155,254,.03)); border-color: rgba(108,92,231,.15); }
.analysis-card.needs_effort { background: linear-gradient(135deg, rgba(254,202,87,.08), rgba(255,159,67,.04)); border-color: rgba(254,202,87,.2); }
.analysis-emoji { font-size: 42px; }
.analysis-info h3 { font-size: 18px; margin-bottom: 6px; }
.analysis-info p { font-size: 14px; color: var(--text-secondary); }
.analysis-stats { display: flex; gap: 20px; margin: 10px 0; font-size: 13px; color: var(--text-secondary); }
.analysis-suggest { background: rgba(255,255,255,.7); padding: 10px 14px; border-radius: 8px; font-size: 13px; color: var(--primary); }

/* 学习计划时间线 */
.plan-section { margin-bottom: 28px; }
.plan-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.plan-header h3 { font-size: 18px; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.plan-timeline { display: flex; flex-direction: column; }
.plan-day { display: flex; gap: 16px; }
.day-marker { display: flex; flex-direction: column; align-items: center; width: 32px; }
.day-dot {
  width: 14px; height: 14px; border-radius: 50%; border: 2.5px solid var(--border);
  background: #fff; flex-shrink: 0; margin-top: 18px;
}
.day-dot.done { background: var(--success); border-color: var(--success); }
.day-line { width: 2px; flex: 1; background: var(--border); min-height: 20px; }

.day-card {
  flex: 1; padding: 14px 18px; border: 1px solid var(--border);
  border-radius: var(--radius-sm); margin-bottom: 6px; cursor: pointer;
  display: flex; align-items: center; justify-content: space-between;
  transition: all var(--transition);
}
.day-card:hover { border-color: var(--primary-light); }
.plan-day.today .day-card { border-color: var(--primary); background: rgba(108,92,231,.03); }
.plan-day.completed .day-card { opacity: .6; }
.day-label { font-weight: 600; font-size: 14px; min-width: 80px; }
.day-task { flex: 1; font-size: 14px; color: var(--text-secondary); margin-left: 12px; }
.day-check {
  width: 24px; height: 24px; border-radius: 50%; background: var(--success);
  color: #fff; display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700;
}

/* 历史记录 */
.records-section { margin-bottom: 40px; }
.records-section h3 { font-size: 18px; font-weight: 600; margin-bottom: 14px; display: flex; align-items: center; gap: 8px; }
.record-item {
  display: flex; align-items: center; gap: 16px; padding: 12px 16px;
  background: #F8F9FB; border-radius: 8px; margin-bottom: 8px;
  font-size: 14px;
}
.rec-time { color: var(--text-muted); font-size: 13px; min-width: 48px; }
.rec-content { flex: 1; color: var(--text-secondary); }
.rec-minutes { color: var(--primary); font-weight: 600; font-size: 13px; }
</style>
