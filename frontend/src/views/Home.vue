<template>
  <div class="dashboard">
    <!-- 欢迎横幅 -->
    <section class="hero-banner">
      <div class="hero-glow"></div>
      <div class="hero-content">
        <div class="hero-left">
          <div class="hero-greeting">
            <span class="greeting-hand">👋</span>
            <div>
              <h1>你好，{{ userStore.userInfo?.nickname || '同学' }}</h1>
              <p class="hero-sub">{{ greetingText }}</p>
            </div>
          </div>
          <div class="hero-tags">
            <span class="hero-tag" v-if="profile"><span class="tag-dot"></span>{{ profile.grade }} · {{ majorName }}</span>
            <span class="hero-tag accent"><span class="tag-dot"></span>{{ portrait ? 'AI画像已生成' : '等待AI分析' }}</span>
          </div>
        </div>
        <div class="hero-right">
          <div class="score-ring" v-if="portrait?.scores">
            <svg viewBox="0 0 120 120" class="ring-svg">
              <circle cx="60" cy="60" r="52" fill="none" stroke="rgba(255,255,255,.15)" stroke-width="8"/>
              <circle cx="60" cy="60" r="52" fill="none" stroke="rgba(255,255,255,.9)" stroke-width="8" stroke-linecap="round"
                :stroke-dasharray="2 * Math.PI * 52"
                :stroke-dashoffset="2 * Math.PI * 52 * (1 - overallScore / 100)"
                transform="rotate(-90 60 60)" class="ring-progress"/>
            </svg>
            <div class="ring-text"><span class="ring-score">{{ overallScore }}</span><span class="ring-label">综合分</span></div>
          </div>
        </div>
      </div>
    </section>

    <!-- AI成长闭环 -->
    <section class="flow-section">
      <h3 class="section-h">🔄 AI成长闭环</h3>
      <div class="flow-chain">
        <div class="flow-node done"><div class="fn-icon">📋</div><span>学生数据</span></div>
        <div class="flow-arrow">→</div>
        <div class="flow-node" :class="{ done: portrait }"><div class="fn-icon">🧠</div><span>AI画像</span></div>
        <div class="flow-arrow">→</div>
        <div class="flow-node" :class="{ done: hasPlan }"><div class="fn-icon">🎯</div><span>AI规划</span></div>
        <div class="flow-arrow">→</div>
        <div class="flow-node" :class="{ done: hasRecords }"><div class="fn-icon">✏️</div><span>学习执行</span></div>
        <div class="flow-arrow">→</div>
        <div class="flow-node" :class="{ done: hasRecords }"><div class="fn-icon">📊</div><span>AI分析</span></div>
        <div class="flow-arrow curved">↻</div>
        <div class="flow-node restart" :class="{ done: hasRecords }"><div class="fn-icon">🔄</div><span>动态调整</span></div>
      </div>
      <div class="flow-bar"><div class="flow-fill" :style="{ width: flowProgress + '%' }"></div></div>
      <p class="flow-tip">{{ flowTip }}</p>
    </section>

    <!-- 统计 -->
    <section class="stats-row">
      <div class="stat-card" v-for="s in stats" :key="s.label" :style="{'--accent':s.color}">
        <div class="stat-icon"><el-icon :size="22"><component :is="s.icon" /></el-icon></div>
        <div class="stat-info"><span class="stat-value">{{ s.value }}</span><span class="stat-label">{{ s.label }}</span></div>
      </div>
    </section>

    <!-- 主内容 -->
    <div class="content-grid">
      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head"><div class="card-icon" style="background:rgba(108,92,231,.1);color:var(--primary)"><el-icon><MagicStick /></el-icon></div><span>AI学生画像</span></div>
        </template>
        <div v-if="portrait">
          <p class="portrait-text">{{ portrait.summary }}</p>
          <div class="trait-columns">
            <div class="trait-col good"><div class="trait-title">✅ 优势</div><ul><li v-for="s in portrait.strengths" :key="s">{{ s }}</li></ul></div>
            <div class="trait-col warn"><div class="trait-title">🎯 待提升</div><ul><li v-for="w in portrait.weaknesses" :key="w">{{ w }}</li></ul></div>
          </div>
        </div>
        <el-empty v-else description="尚未生成"><el-button size="small" type="primary" @click="$router.push('/init')">去初始化</el-button></el-empty>
      </el-card>

      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head"><div class="card-icon" style="background:rgba(0,206,201,.1);color:var(--accent)"><el-icon><Sunny /></el-icon></div><span>AI今日建议</span></div>
        </template>
        <div v-if="portrait?.suggestions" class="suggestions">
          <div class="suggest-item" v-for="(sug,idx) in portrait.suggestions" :key="idx" :class="'p-'+idx">
            <span class="sug-num">{{ idx+1 }}</span><span class="sug-text">{{ sug }}</span>
          </div>
        </div>
        <el-empty v-else description="完成画像后获取" :image-size="60" />
      </el-card>

      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head"><div class="card-icon" style="background:rgba(84,160,255,.1);color:var(--info)"><el-icon><TrendCharts /></el-icon></div><span>能力雷达图</span></div>
        </template>
        <div ref="radarChart" class="radar-container"></div>
      </el-card>

      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head"><div class="card-icon" style="background:rgba(254,202,87,.15);color:var(--warning)"><el-icon><Calendar /></el-icon></div><span>快速入口</span></div>
        </template>
        <div class="quick-links">
          <div class="qlink" @click="$router.push('/plan')"><span>🎯</span> 四年规划</div>
          <div class="qlink" @click="$router.push('/courses')"><span>📖</span> 知识地图</div>
          <div class="qlink" @click="$router.push('/competitions')"><span>🏆</span> 竞赛推荐</div>
          <div class="qlink" @click="$router.push('/assistant')"><span>🤖</span> AI助手</div>
          <div class="qlink" @click="$router.push('/growth')"><span>📊</span> 学习打卡</div>
          <div class="qlink" @click="$router.push('/resume')"><span>📄</span> AI简历</div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useUserStore } from '../stores/user'
import { MagicStick, Sunny, TrendCharts, Calendar, UserFilled, Medal, Reading, TrophyBase, Timer } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { getProfileApi, getPortraitApi } from '../api/profile'
import { getPlanApi } from '../api/plan'
import { getStudyPlanApi } from '../api/studyplan'

const userStore = useUserStore()
const radarChart = ref(null)
const profile = ref(null)
const portrait = ref(null)
const hasPlan = ref(false)
const hasRecords = ref(false)
let chartInstance = null

const majors = ['', '计算机科学与技术', '软件工程', '人工智能', '大数据', '电子信息工程']
const majorName = computed(() => profile.value?.majorId ? majors[profile.value.majorId] || '' : '')
const overallScore = computed(() => portrait.value?.scores?.overall || 0)

const hours = new Date().getHours()
const greetingText = computed(() => {
  if (!portrait.value) return '完成AI档案初始化，获取专属成长规划'
  const g = hours < 12 ? '早上好' : hours < 18 ? '下午好' : '晚上好'
  return g + '！' + (portrait.value.summary?.substring(0, 40) || '你的大学成长路线已就绪') + '...'
})

const flowProgress = computed(() => {
  let p = 20; // 学生数据 always done
  if (portrait.value) p += 20;
  if (hasPlan.value) p += 20;
  if (hasRecords.value) p += 20;
  return p;
})
const flowTip = computed(() => {
  if (!portrait.value) return '完成档案初始化 → AI生成画像 → 开启四年规划'
  if (!hasPlan.value) return '画像已生成！去「AI成长规划」页面生成你的四年规划'
  if (!hasRecords.value) return '规划已就绪！开始每天学习打卡，AI会根据你的进度动态调整'
  return '闭环运转中！AI持续分析你的学习数据，自动优化后续计划 ✨'
})

const stats = computed(() => [
  { icon: Medal, value: overallScore.value + '分', label: '综合能力', color: '#6C5CE7' },
  { icon: Reading, value: '12门', label: '推荐课程', color: '#00CEC9' },
  { icon: TrophyBase, value: '6个', label: '推荐竞赛', color: '#FECA57' },
  { icon: Timer, value: flowProgress.value + '%', label: '闭环完成', color: '#FF6B6B' },
])

onMounted(async () => {
  try { profile.value = (await getProfileApi()).data } catch (e) {}
  try { portrait.value = (await getPortraitApi()).data } catch (e) {}
  try { await getPlanApi(); hasPlan.value = true } catch (e) {}
  try { const p = (await getStudyPlanApi()).data; hasRecords.value = p.length > 0 } catch (e) {}
  await nextTick(); renderRadar()
})

watch(portrait, async () => { await nextTick(); renderRadar() })

function renderRadar() {
  if (!radarChart.value) return
  if (chartInstance) chartInstance.dispose()
  chartInstance = echarts.init(radarChart.value)
  const s = portrait.value?.scores || {}
  chartInstance.setOption({
    radar: {
      indicator: [{name:'编程',max:100},{name:'算法',max:100},{name:'项目',max:100},{name:'竞赛',max:100},{name:'AI',max:100},{name:'英语',max:100}],
      center: ['50%','52%'], radius: '72%', axisName: { color: '#636E72', fontSize: 12 },
      splitArea: { areaStyle: { color: ['rgba(108,92,231,.02)','rgba(108,92,231,.04)'] } }
    },
    series: [{ type: 'radar', data: [{ value: [s.programming||30,s.algorithm||30,s.project||30,s.competition||30,s.ai||30,s.english||30], name:'当前', areaStyle:{color:'rgba(108,92,231,.3)'}, lineStyle:{color:'#6C5CE7',width:2.5}, itemStyle:{color:'#6C5CE7'} }] }]
  })
  window.addEventListener('resize', () => chartInstance?.resize())
}
</script>

<style scoped>
.dashboard { display: flex; flex-direction: column; gap: 20px; }

.hero-banner {
  position: relative; overflow: hidden;
  background: linear-gradient(135deg, #6C5CE7 0%, #5A4BD1 40%, #4834D4 100%);
  border-radius: var(--radius-xl); padding: 38px 44px; color: #fff;
}
.hero-glow { position: absolute; top: -40%; right: -10%; width: 400px; height: 400px; border-radius: 50%; background: radial-gradient(circle, rgba(255,255,255,.12), transparent); }
.hero-content { position: relative; z-index: 1; display: flex; align-items: center; justify-content: space-between; }
.hero-greeting { display: flex; align-items: center; gap: 14px; margin-bottom: 14px; }
.greeting-hand { font-size: 34px; animation: float 2s ease-in-out infinite; }
.hero-left h1 { font-size: 26px; font-weight: 700; }
.hero-sub { font-size: 14px; opacity: .85; max-width: 500px; }
.hero-tags { display: flex; gap: 10px; }
.hero-tag { display: inline-flex; align-items: center; gap: 8px; padding: 5px 14px; border-radius: 20px; background: rgba(255,255,255,.15); font-size: 13px; }
.hero-tag.accent { background: rgba(85,239,196,.2); }
.tag-dot { width: 6px; height: 6px; border-radius: 50%; background: #fff; }
.hero-tag.accent .tag-dot { background: var(--accent-light); }
.ring-svg { width: 120px; height: 120px; }
.ring-progress { transition: stroke-dashoffset 1.2s ease; }
.ring-text { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%); text-align: center; }
.ring-score { display: block; font-size: 28px; font-weight: 800; }
.ring-label { display: block; font-size: 11px; opacity: .7; }
.hero-right { position: relative; }

/* 闭环流程 */
.flow-section { background: #fff; border-radius: var(--radius); padding: 24px 32px; border: 1px solid var(--border); }
.section-h { font-size: 16px; font-weight: 700; margin-bottom: 16px; text-align: center; }
.flow-chain { display: flex; align-items: center; justify-content: center; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
.flow-node {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  padding: 10px 14px; border-radius: var(--radius-sm); background: #F0F1F5;
  font-size: 12px; color: var(--text-muted); min-width: 72px; transition: all .3s;
}
.flow-node.done { background: rgba(108,92,231,.08); color: var(--primary); }
.flow-node.restart { border: 2px dashed var(--border); background: transparent; }
.flow-node.restart.done { border-color: var(--accent); background: rgba(0,206,201,.05); color: var(--accent); }
.fn-icon { font-size: 20px; }
.flow-arrow { font-size: 18px; color: var(--primary); font-weight: 700; }
.flow-arrow.curved { font-size: 22px; color: var(--accent); }
.flow-bar { height: 6px; background: #F0F1F5; border-radius: 3px; margin-bottom: 6px; }
.flow-fill { height: 100%; background: linear-gradient(90deg, var(--primary), var(--accent)); border-radius: 3px; transition: width .6s ease; }
.flow-tip { text-align: center; font-size: 13px; color: var(--text-muted); }

.stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.stat-card {
  background: #fff; border-radius: var(--radius); padding: 20px;
  display: flex; align-items: center; gap: 14px; border: 1px solid var(--border);
  position: relative; overflow: hidden; transition: all var(--transition);
}
.stat-card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: var(--accent); border-radius: 0 4px 4px 0; }
.stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
.stat-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; background: rgba(108,92,231,.08); color: var(--accent); }
.stat-value { font-size: 20px; font-weight: 700; display: block; }
.stat-label { font-size: 12px; color: var(--text-muted); display: block; }

.content-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.dash-card { border-radius: var(--radius) !important; border: 1px solid var(--border) !important; }
.card-head { display: flex; align-items: center; gap: 10px; font-size: 16px; font-weight: 600; }
.card-icon { width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }

.portrait-text { font-size: 14px; color: var(--text-secondary); line-height: 1.8; margin-bottom: 14px; }
.trait-columns { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.trait-col { padding: 12px; border-radius: 8px; font-size: 13px; }
.trait-col.good { background: rgba(0,210,160,.06); }
.trait-col.warn { background: rgba(254,202,87,.08); }
.trait-title { font-weight: 600; margin-bottom: 6px; }
.trait-col ul { padding-left: 16px; }
.trait-col li { color: var(--text-secondary); margin-bottom: 4px; }

.suggestions { display: flex; flex-direction: column; gap: 10px; }
.suggest-item { display: flex; align-items: center; gap: 12px; padding: 12px 14px; border-radius: 8px; background: #F8F9FB; font-size: 14px; }
.sug-num { width: 24px; height: 24px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; color: #fff; flex-shrink: 0; }
.p-0 .sug-num { background: var(--primary); }
.p-1 .sug-num { background: var(--accent); }
.p-2 .sug-num { background: var(--warning); }

.radar-container { width: 100%; height: 280px; }

.quick-links { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.qlink { display: flex; align-items: center; gap: 8px; padding: 12px 14px; border-radius: 10px; cursor: pointer; background: #F8F9FB; font-size: 14px; transition: all .2s; }
.qlink:hover { background: rgba(108,92,231,.08); color: var(--primary); }
.qlink span { font-size: 18px; }
</style>
