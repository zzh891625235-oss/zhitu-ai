<template>
  <div class="comp-page">
    <div class="page-hero">
      <h1><el-icon><TrophyBase /></el-icon> 竞赛中心</h1>
      <p>发现适合你的比赛，AI智能推荐参赛计划</p>
    </div>

    <!-- 标签切换 -->
    <div class="tab-bar">
      <div class="tab-item" :class="{ active: activeTab === 'all' }" @click="activeTab = 'all'">
        <el-icon><List /></el-icon> 全部竞赛
      </div>
      <div class="tab-item" :class="{ active: activeTab === 'ai' }" @click="switchToAI">
        <el-icon><MagicStick /></el-icon> AI智能推荐
        <span class="tab-badge" v-if="recommendations.length">{{ recommendations.length }}</span>
      </div>
    </div>

    <!-- 全部竞赛视图 -->
    <template v-if="activeTab === 'all'">
      <div class="filter-bar">
        <el-input v-model="searchText" placeholder="搜索竞赛..." :prefix-icon="Search" clearable class="search-input" />
        <el-select v-model="filterType" placeholder="竞赛类型" clearable>
          <el-option label="全部" value="" />
          <el-option v-for="t in typeOptions" :key="t" :label="t" :value="t" />
        </el-select>
        <el-select v-model="filterDiff" placeholder="难度" clearable>
          <el-option label="入门" value="BEGINNER" />
          <el-option label="进阶" value="INTERMEDIATE" />
          <el-option label="高级" value="ADVANCED" />
        </el-select>
        <div class="major-switch" v-if="hasMajorInfo">
          <el-switch v-model="onlyMatch" size="default" />
          <span class="major-switch-label">只看对口我的专业</span>
        </div>
      </div>

      <div class="major-tip" v-if="hasMajorInfo">
        <el-icon><InfoFilled /></el-icon>
        已按你的专业「<strong>{{ myMajorName }}</strong>」筛选：{{ matchedCount }} 场对口
        <span class="tip-note">（含面向全校的比赛）</span>
        <template v-if="relatedCount">
          · 另有 {{ relatedCount }} 场同方向比赛，关闭筛选可见
        </template>
      </div>

      <div class="comp-grid">
        <div class="comp-card" v-for="comp in filteredComps" :key="comp.id" :class="'diff-' + comp.difficulty">
          <div class="card-accent" :class="'diff-' + comp.difficulty"></div>
          <div class="card-body">
            <div class="card-header-row">
              <el-tag :type="diffTag(comp.difficulty)" size="small" effect="dark" round>{{ diffLabel(comp.difficulty) }}</el-tag>
              <el-tag v-if="comp.matchLevel === 'EXACT'" type="success" size="small" effect="plain" round>对口我的专业</el-tag>
              <el-tag v-else-if="comp.matchLevel === 'OPEN'" size="small" effect="plain" round>不限专业</el-tag>
              <el-tag v-else-if="comp.matchLevel === 'RELATED'" type="info" size="small" effect="plain" round>同方向专业</el-tag>
              <span class="card-type">{{ comp.type }}</span>
            </div>
            <h3 class="card-title">{{ comp.name }}</h3>
            <p class="card-desc">{{ comp.description }}</p>
            <div class="card-majors" v-if="majorList(comp).length">
              <span class="majors-label">适合专业</span>
              <span class="major-chip" v-for="m in majorList(comp).slice(0, 3)" :key="m"
                    :class="{ mine: m === myMajorName }">{{ m }}</span>
              <span class="major-more" v-if="majorList(comp).length > 3">等 {{ majorList(comp).length }} 个专业</span>
            </div>
            <div class="card-dates">
              <div class="date-item">
                <el-icon><Calendar /></el-icon>
                <div><span class="date-label">报名截止</span><span class="date-val">{{ comp.registrationEnd }}</span></div>
              </div>
              <div class="date-item">
                <el-icon><Timer /></el-icon>
                <div><span class="date-label">比赛时间</span><span class="date-val">{{ comp.competitionStart }}</span></div>
              </div>
            </div>
            <div class="countdown-bar">
              <div class="countdown-text" v-if="getDaysLeft(comp) > 0">距截止 <strong>{{ getDaysLeft(comp) }}</strong> 天</div>
              <div class="countdown-text expired" v-else>已截止</div>
              <el-progress :percentage="countdownPercent(comp)" :stroke-width="6"
                :color="getDaysLeft(comp) > 30 ? '#66BB6A' : getDaysLeft(comp) > 7 ? 'var(--amber)' : '#EF5350'" :show-text="false" />
            </div>
          </div>
          <div class="card-footer">
            <el-button size="small" @click="openUrl(comp.officialUrl)" text type="primary">官网 <el-icon><Link /></el-icon></el-button>
            <el-button size="small" type="primary" round @click="handleJoin(comp)">{{ joinedIds.includes(comp.id) ? '已加入 ✓' : '加入我的计划' }}</el-button>
          </div>
        </div>
      </div>
    </template>

    <!-- AI推荐视图 -->
    <template v-if="activeTab === 'ai'">
      <div v-if="loadingRec" class="rec-loading">
        <el-icon class="loading-icon" :size="40"><Loading /></el-icon>
        <p>AI正在分析你的能力和竞赛数据...</p>
      </div>

      <div v-else-if="recommendations.length" class="rec-grid">
        <div class="rec-card" v-for="(rec, idx) in recommendations" :key="rec.competitionId">
          <div class="rec-rank">{{ idx + 1 }}</div>
          <div class="rec-body">
            <div class="rec-header">
              <h3>{{ rec.name }}</h3>
              <div class="rec-score-ring">
                <svg viewBox="0 0 80 80" width="80" height="80">
                  <circle cx="40" cy="40" r="34" fill="none" stroke="#E8ECF1" stroke-width="6"/>
                  <circle cx="40" cy="40" r="34" fill="none" :stroke="scoreColor(rec.score)"
                    stroke-width="6" stroke-linecap="round"
                    :stroke-dasharray="2 * Math.PI * 34"
                    :stroke-dashoffset="2 * Math.PI * 34 * (1 - rec.score / 100)"
                    transform="rotate(-90 40 40)" class="score-ring"/>
                </svg>
                <span class="score-num">{{ rec.score }}</span>
                <span class="score-label">匹配度</span>
              </div>
            </div>

            <div class="rec-tags">
              <el-tag :type="diffTag(rec.difficulty)" size="small">{{ diffLabel(rec.difficulty) }}</el-tag>
              <el-tag type="info" size="small">{{ rec.type }}</el-tag>
              <el-tag v-if="rec.matchLevel === 'EXACT'" type="success" size="small" effect="plain">对口我的专业</el-tag>
              <el-tag v-else-if="rec.matchLevel === 'OPEN'" size="small" effect="plain">不限专业</el-tag>
              <el-tag v-if="rec.daysLeft > 0" type="success" size="small">剩余{{ rec.daysLeft }}天</el-tag>
            </div>

            <div class="rec-reasons">
              <div class="reason-title">🎯 为什么推荐给你？</div>
              <div class="reason-item" v-for="(r, i) in rec.reasons" :key="i">
                <span class="reason-dot"></span>{{ r }}
              </div>
            </div>

            <div class="rec-action">
              <el-button size="small" text type="primary" @click="openUrl(rec.officialUrl)">官网</el-button>
              <el-button size="small" type="primary" round @click="handleJoin(rec)">加入计划</el-button>
              <span class="rec-prep">建议准备 {{ rec.recommendDays }} 天</span>
            </div>
          </div>
        </div>
      </div>

      <el-empty v-else description="点击上方「AI智能推荐」生成个性化推荐">
        <el-button type="primary" @click="fetchRecommendations">立即生成</el-button>
      </el-empty>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { TrophyBase, Search, Calendar, Timer, List, MagicStick, Link, Loading, InfoFilled } from '@element-plus/icons-vue'
import { getCompetitionsApi } from '../api/competition'
import { recommendCompetitionsApi } from '../api/recommend'
import { getProfileApi } from '../api/profile'
import { ElMessage } from 'element-plus'

const activeTab = ref('all')
const competitions = ref([])
const recommendations = ref([])
const loadingRec = ref(false)
const searchText = ref('')
const filterType = ref('')
const filterDiff = ref('')
const joinedIds = ref([])

// 专业对口过滤：默认只看对口，避免土木/护理/会计的学生一进来就看到满屏程序设计竞赛
const onlyMatch = ref(true)
const myMajorName = ref('')

const hasMajorInfo = computed(() => !!myMajorName.value)
// 「对口」只算精确对口的和面向全校的；仅同方向的比赛不算，否则统计学会看到地质技能竞赛
const isMyMatch = (c) => c.matchLevel === 'EXACT' || c.matchLevel === 'OPEN'
const matchedCount = computed(() => competitions.value.filter(isMyMatch).length)
const relatedCount = computed(() => competitions.value.filter(c => c.matchLevel === 'RELATED').length)

/** suitable_major 是 JSON 数组，['*'] 表示不限专业，这里不展示成「适合专业」 */
function majorList(comp) {
  if (!comp.suitableMajor) return []
  try {
    const arr = JSON.parse(comp.suitableMajor)
    return Array.isArray(arr) ? arr.filter(m => m !== '*') : []
  } catch (e) {
    return []
  }
}

const filteredComps = computed(() => competitions.value.filter(c => {
  if (onlyMatch.value && hasMajorInfo.value && !isMyMatch(c)) return false
  if (searchText.value && !c.name.includes(searchText.value)) return false
  if (filterType.value && c.type !== filterType.value) return false
  if (filterDiff.value && c.difficulty !== filterDiff.value) return false
  return true
}))

// 类型下拉从后端返回的竞赛数据里派生，保证任何类型都能被筛到（数据库里已有 20+ 种类型）
const typeOptions = computed(() => {
  const seen = []
  for (const c of competitions.value) {
    if (c.type && !seen.includes(c.type)) seen.push(c.type)
  }
  return seen
})

function diffTag(d) {
  if (d === 'BEGINNER') return 'success'; if (d === 'INTERMEDIATE') return 'warning'; return 'danger'
}
function diffLabel(d) {
  if (d === 'BEGINNER') return '入门'; if (d === 'INTERMEDIATE') return '进阶'; return '高级'
}
function scoreColor(s) {
  if (s >= 80) return '#66BB6A'; if (s >= 60) return 'var(--signal)'; return 'var(--amber)'
}
function getDaysLeft(comp) {
  if (!comp.registrationEnd) return 0
  return Math.ceil((new Date(comp.registrationEnd) - new Date()) / 86400000)
}
function countdownPercent(comp) {
  if (!comp.registrationStart || !comp.registrationEnd) return 100
  const total = new Date(comp.registrationEnd) - new Date(comp.registrationStart)
  const elapsed = Date.now() - new Date(comp.registrationStart)
  return Math.min(100, Math.max(0, Math.round(elapsed / total * 100)))
}
function openUrl(url) { if (url) window.open(url, '_blank') }
function handleJoin(comp) {
  const id = comp.competitionId || comp.id
  const idx = joinedIds.value.indexOf(id)
  if (idx >= 0) { joinedIds.value.splice(idx, 1); ElMessage.info('已移出计划') }
  else { joinedIds.value.push(id); ElMessage.success('已加入成长计划！') }
}

async function fetchRecommendations() {
  loadingRec.value = true
  try {
    const res = await recommendCompetitionsApi()
    recommendations.value = res.data
  } catch (e) { ElMessage.error('推荐失败，请先完成档案初始化') }
  finally { loadingRec.value = false }
}
async function switchToAI() {
  activeTab.value = 'ai'
  if (!recommendations.value.length) await fetchRecommendations()
}

onMounted(async () => {
  await loadMajorContext()
  try { competitions.value = (await getCompetitionsApi()).data }
  catch (e) { ElMessage.error('加载竞赛数据失败') }
})

/**
 * 取当前用户的专业名，用于「只看对口我的专业」。
 * 后端 /competitions 会自动按登录用户的档案专业标注 matchMyMajor，
 * 这里取专业名只是为了展示与高亮。未初始化档案时静默跳过。
 */
async function loadMajorContext() {
  try {
    const p = (await getProfileApi()).data
    if (p && p.majorName) myMajorName.value = p.majorName
  } catch (e) {
    // 新用户还没建档，正常浏览全部竞赛
  }
}
</script>

<style scoped>
.comp-page { max-width: 1200px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

/* 标签切换 */
.tab-bar { display: flex; justify-content: center; gap: 4px; margin-bottom: 28px; background: rgba(255,255,255,.04); border-radius: 12px; padding: 4px; width: fit-content; margin-left: auto; margin-right: auto; }
.tab-item {
  display: flex; align-items: center; gap: 6px; padding: 10px 22px; border-radius: 10px;
  cursor: pointer; font-size: 14px; font-weight: 500; color: var(--text-secondary); transition: all .2s;
}
.tab-item.active { background:var(--glass); color: var(--primary); box-shadow: var(--shadow-sm); }
.tab-item:hover:not(.active) { color: var(--text); }
.tab-badge {
  background: var(--primary); color: #fff; border-radius: 10px;
  padding: 1px 7px; font-size: 11px; font-weight: 600;
}

.filter-bar { display: flex; gap: 12px; margin-bottom: 14px; justify-content: center; align-items: center; flex-wrap: wrap; }
.search-input { width: 320px; }
/* el-select 在 flex 容器里会撑满一行，这里给固定宽度 */
.filter-bar :deep(.el-select) { width: 150px; }
@media (max-width: 560px) {
  .search-input { width: 100%; }
  .filter-bar :deep(.el-select) { width: calc(50% - 6px); }
}

/* 专业对口 */
.major-switch { display: flex; align-items: center; gap: 8px; padding: 0 4px; }
.major-switch-label { font-size: 13px; color: var(--text-secondary); white-space: nowrap; }
.major-tip {
  display: flex; align-items: center; justify-content: center; gap: 6px;
  font-size: 12.5px; color: var(--text-secondary); margin-bottom: 24px;
}
.major-tip strong { color: var(--primary); font-weight: 600; }
.major-tip .tip-note { color: var(--fog); }

.card-majors { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-top: 12px; }
.majors-label { font-size: 11px; color: var(--fog); flex-shrink: 0; }
.major-chip {
  font-size: 11px; padding: 2px 8px; border-radius: 6px;
  background: rgba(255,255,255,.05); color: var(--text-secondary);
  border: 1px solid var(--border); white-space: nowrap;
}
.major-chip.mine { color: var(--primary); border-color: var(--primary); background: rgba(79,209,197,.08); }
.major-more { font-size: 11px; color: var(--fog); }

.comp-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(min(360px, 100%), 1fr)); gap: 22px; }
.comp-card { background:var(--glass); border-radius: var(--radius-lg); overflow: hidden; border: 1px solid var(--border); transition: all var(--transition); }
.comp-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }
.card-accent { height: 4px; }
.card-accent.diff-BEGINNER { background: linear-gradient(90deg, #66BB6A, #55EFC4); }
.card-accent.diff-INTERMEDIATE { background: linear-gradient(90deg, var(--amber), #FF9F43); }
.card-accent.diff-ADVANCED { background: linear-gradient(90deg, #EF5350, #EE5A24); }
.card-body { padding: 20px 22px; }
.card-header-row { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.card-type { font-size: 12px; color: var(--text-muted); }
.card-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; line-height: 1.4; }
.card-desc { font-size: 12px; color: var(--text-muted); margin-bottom: 14px; line-height: 1.5; }
.card-dates { display: flex; gap: 24px; margin-bottom: 14px; }
.date-item { display: flex; align-items: flex-start; gap: 8px; font-size: 13px; }
.date-label { display: block; font-size: 11px; color: var(--text-muted); }
.date-val { display: block; color: var(--text-secondary); font-weight: 500; }
.countdown-bar { }
.countdown-text { font-size: 13px; margin-bottom: 4px; color: var(--text-secondary); }
.countdown-text strong { color: var(--primary); font-size: 16px; }
.countdown-text.expired { color: #EF5350; }
.card-footer { display: flex; align-items: center; justify-content: space-between; padding: 14px 22px; border-top: 1px solid var(--border); background: rgba(255,255,255,.02); }

/* AI推荐 */
.rec-loading { text-align: center; padding: 80px 0; }
.loading-icon { animation: spin 1.5s linear infinite; color: var(--primary); }
@keyframes spin { to { transform: rotate(360deg); } }
.rec-loading p { margin-top: 16px; color: var(--text-secondary); }

.rec-grid { display: flex; flex-direction: column; gap: 20px; }
.rec-card {
  display: flex; gap: 20px; background:var(--glass); border-radius: var(--radius-lg);
  border: 1px solid var(--border); padding: 24px; transition: all var(--transition);
}
.rec-card:hover { box-shadow: var(--shadow-lg); }
.rec-rank {
  width: 42px; height: 42px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px; font-weight: 800; color: #fff; flex-shrink: 0;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
}
.rec-body { flex: 1; }
.rec-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
.rec-header h3 { font-size: 18px; font-weight: 600; }

.rec-score-ring { position: relative; display: flex; align-items: center; justify-content: center; }
.score-ring { transition: stroke-dashoffset 1s ease; }
.score-num {
  position: absolute; font-size: 20px; font-weight: 800; color: var(--text);
}
.score-label { position: absolute; bottom: 16px; font-size: 10px; color: var(--text-muted); }

.rec-tags { display: flex; gap: 8px; margin-bottom: 14px; }
.rec-reasons { background: rgba(255,255,255,.025); border-radius: var(--radius-sm); padding: 14px 16px; margin-bottom: 14px; }
.reason-title { font-weight: 600; font-size: 13px; margin-bottom: 10px; }
.reason-item { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--text-secondary); margin-bottom: 6px; }
.reason-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--primary); flex-shrink: 0; }
.rec-action { display: flex; align-items: center; gap: 12px; }
.rec-prep { font-size: 12px; color: var(--text-muted); margin-left: auto; }
</style>
