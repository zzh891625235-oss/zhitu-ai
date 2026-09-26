<template>
  <div class="comp-page">
    <div class="page-hero">
      <h1><el-icon><TrophyBase /></el-icon> 竞赛中心</h1>
      <p>发现适合你的比赛，AI智能推荐参赛计划</p>
    </div>

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <el-input v-model="searchText" placeholder="搜索竞赛..." :prefix-icon="Search" clearable class="search-input" />
      <el-select v-model="filterType" placeholder="竞赛类型" clearable>
        <el-option label="算法编程" value="算法编程" />
        <el-option label="数学建模" value="数学建模" />
        <el-option label="创新创业" value="创新创业" />
        <el-option label="综合" value="综合" />
      </el-select>
      <el-select v-model="filterDiff" placeholder="难度" clearable>
        <el-option label="入门" value="BEGINNER" />
        <el-option label="进阶" value="INTERMEDIATE" />
        <el-option label="高级" value="ADVANCED" />
      </el-select>
    </div>

    <!-- 统计 -->
    <div class="comp-stats">
      <div class="comp-stat" v-for="s in stats" :key="s.label">
        <span class="cs-num" :style="{color:s.color}">{{ s.value }}</span>
        <span class="cs-label">{{ s.label }}</span>
      </div>
    </div>

    <!-- 竞赛卡片网格 -->
    <div class="comp-grid">
      <div class="comp-card" v-for="comp in filteredComps" :key="comp.id"
        :class="'diff-' + comp.difficulty">
        <!-- 顶部色条 -->
        <div class="card-accent" :class="'diff-' + comp.difficulty"></div>

        <div class="card-body">
          <div class="card-header-row">
            <el-tag :type="diffTag(comp.difficulty)" size="small" effect="dark" round>
              {{ diffLabel(comp.difficulty) }}
            </el-tag>
            <span class="card-type">{{ comp.type }}</span>
          </div>

          <h3 class="card-title">{{ comp.name }}</h3>
          <p class="card-desc">{{ comp.description }}</p>

          <!-- 时间信息 -->
          <div class="card-dates">
            <div class="date-item">
              <el-icon><Calendar /></el-icon>
              <div>
                <span class="date-label">报名截止</span>
                <span class="date-val">{{ comp.registrationEnd }}</span>
              </div>
            </div>
            <div class="date-item">
              <el-icon><Timer /></el-icon>
              <div>
                <span class="date-label">比赛时间</span>
                <span class="date-val">{{ comp.competitionStart }}</span>
              </div>
            </div>
          </div>

          <!-- 倒计时 -->
          <div class="countdown-bar">
            <div class="countdown-text" v-if="getDaysLeft(comp) > 0">
              距截止 <strong>{{ getDaysLeft(comp) }}</strong> 天
            </div>
            <div class="countdown-text expired" v-else>已截止</div>
            <el-progress :percentage="countdownPercent(comp)" :stroke-width="6"
              :color="getDaysLeft(comp) > 30 ? '#00D2A0' : getDaysLeft(comp) > 7 ? '#FECA57' : '#FF6B6B'"
              :show-text="false" />
          </div>

          <!-- 推荐准备 -->
          <div class="card-recommend">
            <el-icon><Clock /></el-icon>
            <span>推荐准备 {{ comp.recommendDays }} 天</span>
          </div>
        </div>

        <div class="card-footer">
          <el-button size="small" @click="openUrl(comp.officialUrl)" text type="primary">
            官网 <el-icon><Link /></el-icon>
          </el-button>
          <el-button size="small" type="primary" round @click="handleJoin(comp)">
            {{ joinedIds.includes(comp.id) ? '已加入 ✓' : '加入我的计划' }}
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { TrophyBase, Search, Calendar, Timer, Clock, Link } from '@element-plus/icons-vue'
import { getCompetitionsApi } from '../api/competition'
import { ElMessage } from 'element-plus'

const competitions = ref([])
const searchText = ref('')
const filterType = ref('')
const filterDiff = ref('')
const joinedIds = ref([])

const stats = computed(() => [
  { value: competitions.value.length, label: '全部竞赛', color: '#6C5CE7' },
  { value: competitions.value.filter(c => getDaysLeft(c) > 0).length, label: '报名中', color: '#00D2A0' },
  { value: '6', label: '已推荐', color: '#FECA57' },
  { value: joinedIds.value.length, label: '已加入', color: '#FF6B6B' },
])

const filteredComps = computed(() => {
  return competitions.value.filter(c => {
    if (searchText.value && !c.name.includes(searchText.value)) return false
    if (filterType.value && c.type !== filterType.value) return false
    if (filterDiff.value && c.difficulty !== filterDiff.value) return false
    return true
  })
})

function diffTag(d) {
  if (d === 'BEGINNER') return 'success'
  if (d === 'INTERMEDIATE') return 'warning'
  return 'danger'
}
function diffLabel(d) {
  if (d === 'BEGINNER') return '入门'
  if (d === 'INTERMEDIATE') return '进阶'
  return '高级'
}
function getDaysLeft(comp) {
  if (!comp.registrationEnd) return 0
  const end = new Date(comp.registrationEnd)
  const now = new Date()
  return Math.ceil((end - now) / (1000 * 60 * 60 * 24))
}
function countdownPercent(comp) {
  if (!comp.registrationStart || !comp.registrationEnd) return 100
  const start = new Date(comp.registrationStart)
  const end = new Date(comp.registrationEnd)
  const now = new Date()
  const total = end - start
  const elapsed = now - start
  return Math.min(100, Math.max(0, Math.round((elapsed / total) * 100)))
}

function openUrl(url) { if (url) window.open(url, '_blank') }

function handleJoin(comp) {
  const idx = joinedIds.value.indexOf(comp.id)
  if (idx >= 0) {
    joinedIds.value.splice(idx, 1)
    ElMessage.info('已移出计划')
  } else {
    joinedIds.value.push(comp.id)
    ElMessage.success('已加入我的成长计划！AI将生成备赛方案')
  }
}

onMounted(async () => {
  try { competitions.value = (await getCompetitionsApi()).data }
  catch (e) { ElMessage.error('加载竞赛数据失败') }
})
</script>

<style scoped>
.comp-page { max-width: 1200px; margin: 0 auto; }

.page-hero { text-align: center; padding: 36px 0 24px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.filter-bar { display: flex; gap: 12px; margin-bottom: 28px; justify-content: center; }
.search-input { width: 320px; }

.comp-stats { display: flex; justify-content: center; gap: 40px; margin-bottom: 32px; }
.comp-stat { text-align: center; }
.cs-num { display: block; font-size: 28px; font-weight: 700; }
.cs-label { display: block; font-size: 12px; color: var(--text-muted); margin-top: 2px; }

.comp-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 22px; }

.comp-card {
  background: #fff; border-radius: var(--radius-lg); overflow: hidden;
  border: 1px solid var(--border); transition: all var(--transition);
  display: flex; flex-direction: column;
}
.comp-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }

.card-accent { height: 4px; }
.card-accent.diff-BEGINNER { background: linear-gradient(90deg, #00D2A0, #55EFC4); }
.card-accent.diff-INTERMEDIATE { background: linear-gradient(90deg, #FECA57, #FF9F43); }
.card-accent.diff-ADVANCED { background: linear-gradient(90deg, #FF6B6B, #EE5A24); }

.card-body { padding: 20px 22px; flex: 1; }
.card-header-row { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.card-type { font-size: 12px; color: var(--text-muted); }
.card-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; line-height: 1.4; }
.card-desc { font-size: 12px; color: var(--text-muted); margin-bottom: 14px; line-height: 1.5; }

.card-dates { display: flex; gap: 24px; margin-bottom: 14px; }
.date-item { display: flex; align-items: flex-start; gap: 8px; font-size: 13px; }
.date-label { display: block; font-size: 11px; color: var(--text-muted); }
.date-val { display: block; color: var(--text-secondary); font-weight: 500; }

.countdown-bar { margin-bottom: 12px; }
.countdown-text { font-size: 13px; margin-bottom: 4px; color: var(--text-secondary); }
.countdown-text strong { color: var(--primary); font-size: 16px; }
.countdown-text.expired { color: #FF6B6B; }

.card-recommend {
  display: flex; align-items: center; gap: 6px;
  font-size: 12px; color: var(--accent); background: rgba(0,206,201,.06);
  padding: 8px 12px; border-radius: 8px;
}

.card-footer {
  display: flex; align-items: center; justify-content: space-between;
  padding: 14px 22px; border-top: 1px solid var(--border); background: #FAFBFC;
}
</style>
