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
            <span class="hero-tag" v-if="profile">
              <span class="tag-dot"></span>{{ profile.grade }} · {{ majorName }}
            </span>
            <span class="hero-tag accent">
              <span class="tag-dot"></span>{{ portrait ? 'AI画像已生成' : '等待AI分析' }}
            </span>
          </div>
        </div>
        <div class="hero-right">
          <div class="score-ring" v-if="portrait?.scores">
            <svg viewBox="0 0 120 120" class="ring-svg">
              <circle cx="60" cy="60" r="52" fill="none" stroke="rgba(255,255,255,.15)" stroke-width="8"/>
              <circle cx="60" cy="60" r="52" fill="none" stroke="rgba(255,255,255,.9)"
                stroke-width="8" stroke-linecap="round"
                :stroke-dasharray="2 * Math.PI * 52"
                :stroke-dashoffset="2 * Math.PI * 52 * (1 - overallScore / 100)"
                transform="rotate(-90 60 60)" class="ring-progress"/>
            </svg>
            <div class="ring-text">
              <span class="ring-score">{{ overallScore }}</span>
              <span class="ring-label">综合分</span>
            </div>
          </div>
        </div>
      </div>
      <div class="hero-particles">
        <span v-for="i in 12" :key="i" class="particle" :style="particleStyle(i)"></span>
      </div>
    </section>

    <!-- 统计卡片 -->
    <section class="stats-row">
      <div class="stat-card" v-for="stat in stats" :key="stat.label"
        :style="{ '--accent': stat.color }">
        <div class="stat-icon"><el-icon :size="22"><component :is="stat.icon" /></el-icon></div>
        <div class="stat-info">
          <span class="stat-value">{{ stat.value }}</span>
          <span class="stat-label">{{ stat.label }}</span>
        </div>
      </div>
    </section>

    <!-- 主内容区 -->
    <div class="content-grid">
      <!-- AI画像分析 -->
      <el-card class="dash-card portrait-card" shadow="never">
        <template #header>
          <div class="card-head">
            <div class="card-head-left">
              <div class="card-icon" style="background:rgba(108,92,231,.1);color:var(--primary)">
                <el-icon><MagicStick /></el-icon>
              </div>
              <span>AI学生画像</span>
            </div>
            <el-tag v-if="portrait" type="primary" size="small" effect="plain" round>AI分析</el-tag>
          </div>
        </template>
        <div v-if="portrait" class="portrait-body">
          <p class="portrait-text">{{ portrait.summary }}</p>
          <div class="trait-columns">
            <div class="trait-col good">
              <div class="trait-title">✅ 优势</div>
              <ul><li v-for="(s,i) in portrait.strengths" :key="i">{{ s }}</li></ul>
            </div>
            <div class="trait-col warn">
              <div class="trait-title">🎯 待提升</div>
              <ul><li v-for="(w,i) in portrait.weaknesses" :key="i">{{ w }}</li></ul>
            </div>
          </div>
        </div>
        <el-empty v-else description="尚未生成AI画像" :image-size="70">
          <el-button type="primary" size="small" @click="$router.push('/init')">去初始化</el-button>
        </el-empty>
      </el-card>

      <!-- AI建议 -->
      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head">
            <div class="card-head-left">
              <div class="card-icon" style="background:rgba(0,206,201,.1);color:var(--accent)">
                <el-icon><Sunny /></el-icon>
              </div>
              <span>AI今日建议</span>
            </div>
          </div>
        </template>
        <div v-if="portrait?.suggestions" class="suggestions">
          <div class="suggest-item" v-for="(sug, idx) in portrait.suggestions" :key="idx"
            :class="'priority-' + idx">
            <span class="suggest-num">{{ idx + 1 }}</span>
            <span class="suggest-text">{{ sug }}</span>
          </div>
        </div>
        <el-empty v-else description="完成AI画像后获取建议" :image-size="60" />
      </el-card>

      <!-- 能力雷达图 -->
      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head">
            <div class="card-head-left">
              <div class="card-icon" style="background:rgba(84,160,255,.1);color:var(--info)">
                <el-icon><TrendCharts /></el-icon>
              </div>
              <span>能力雷达图</span>
            </div>
          </div>
        </template>
        <div ref="radarChart" class="radar-container"></div>
      </el-card>

      <!-- 三月规划 -->
      <el-card class="dash-card" shadow="never">
        <template #header>
          <div class="card-head">
            <div class="card-head-left">
              <div class="card-icon" style="background:rgba(254,202,87,.15);color:var(--warning)">
                <el-icon><Calendar /></el-icon>
              </div>
              <span>三月成长计划</span>
            </div>
          </div>
        </template>
        <div v-if="portrait?.threeMonthPlan" class="timeline">
          <div class="tl-item" v-for="(plan, idx) in portrait.threeMonthPlan" :key="idx">
            <div class="tl-dot" :class="'phase-' + idx"></div>
            <div class="tl-content">
              <div class="tl-month">第{{ idx + 1 }}个月</div>
              <div class="tl-text">{{ plan }}</div>
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无计划" :image-size="60" />
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useUserStore } from '../stores/user'
import { MagicStick, Sunny, TrendCharts, Calendar, Reading, TrophyBase, Timer, Medal } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { getProfileApi, getPortraitApi } from '../api/profile'

const userStore = useUserStore()
const radarChart = ref(null)
const profile = ref(null)
const portrait = ref(null)
let chartInstance = null

const majors = ['', '计算机科学与技术', '软件工程', '人工智能', '大数据', '电子信息工程']
const majorName = computed(() => profile.value?.majorId ? majors[profile.value.majorId] || '' : '')
const overallScore = computed(() => portrait.value?.scores?.overall || 0)

const hours = new Date().getHours()
const greetingText = computed(() => {
  if (!portrait.value) return '完成AI档案初始化，获取专属成长规划'
  const g = hours < 12 ? '早上好' : hours < 18 ? '下午好' : '晚上好'
  return `${g}！${portrait.value.summary?.substring(0, 40) || '你的大学成长路线已就绪'}...`
})

const stats = computed(() => [
  { icon: Medal, value: overallScore.value + '分', label: '综合能力', color: '#6C5CE7' },
  { icon: Reading, value: '12门', label: '推荐课程', color: '#00CEC9' },
  { icon: TrophyBase, value: '6个', label: '推荐竞赛', color: '#FECA57' },
  { icon: Timer, value: '90天', label: '行动计划', color: '#FF6B6B' },
])

const particleStyle = (i) => ({
  left: `${Math.random() * 100}%`,
  top: `${Math.random() * 100}%`,
  animationDelay: `${Math.random() * 3}s`,
  animationDuration: `${2 + Math.random() * 4}s`,
  width: `${4 + Math.random() * 8}px`,
  height: `${4 + Math.random() * 8}px`,
})

onMounted(async () => {
  try { profile.value = (await getProfileApi()).data } catch (e) {}
  try { portrait.value = (await getPortraitApi()).data } catch (e) {}
  await nextTick()
  renderRadar()
})

watch(portrait, async () => {
  await nextTick()
  renderRadar()
})

function renderRadar() {
  if (!radarChart.value) return
  if (chartInstance) chartInstance.dispose()
  chartInstance = echarts.init(radarChart.value)
  const scores = portrait.value?.scores || {}
  chartInstance.setOption({
    radar: {
      indicator: [
        { name: '编程', max: 100 }, { name: '算法', max: 100 },
        { name: '项目', max: 100 }, { name: '竞赛', max: 100 },
        { name: 'AI', max: 100 }, { name: '英语', max: 100 }
      ],
      center: ['50%', '52%'], radius: '72%',
      axisName: { color: '#636E72', fontSize: 12 },
      splitArea: { areaStyle: { color: ['rgba(108,92,231,.02)', 'rgba(108,92,231,.04)'] } }
    },
    series: [{
      type: 'radar',
      data: [{
        value: [scores.programming||30, scores.algorithm||30, scores.project||30,
                scores.competition||30, scores.ai||30, scores.english||30],
        name: '当前能力', areaStyle: { color: 'rgba(108,92,231,.3)' },
        lineStyle: { color: '#6C5CE7', width: 2.5 },
        itemStyle: { color: '#6C5CE7' }
      }]
    }]
  })
  window.addEventListener('resize', () => chartInstance?.resize())
}
</script>

<style scoped>
.dashboard { display: flex; flex-direction: column; gap: 24px; }

/* 欢迎横幅 */
.hero-banner {
  position: relative; overflow: hidden;
  background: linear-gradient(135deg, #6C5CE7 0%, #5A4BD1 40%, #4834D4 100%);
  border-radius: var(--radius-xl); padding: 42px 48px; color: #fff;
}
.hero-glow {
  position: absolute; top: -40%; right: -10%;
  width: 400px; height: 400px; border-radius: 50%;
  background: radial-gradient(circle, rgba(255,255,255,.12), transparent);
}
.hero-content { position: relative; z-index: 1; display: flex; align-items: center; justify-content: space-between; }
.hero-greeting { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; }
.greeting-hand { font-size: 36px; animation: float 2s ease-in-out infinite; }
.hero-left h1 { font-size: 28px; font-weight: 700; }
.hero-sub { font-size: 15px; opacity: .85; margin-top: 4px; max-width: 500px; }
.hero-tags { display: flex; gap: 10px; }
.hero-tag {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 6px 16px; border-radius: 20px;
  background: rgba(255,255,255,.15); font-size: 13px; font-weight: 500;
}
.hero-tag.accent { background: rgba(85,239,196,.2); }
.tag-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--accent-light); }
.tag-dot { background: #fff; }
.hero-tag.accent .tag-dot { background: var(--accent-light); }

/* SVG 评分环 */
.ring-svg { width: 120px; height: 120px; }
.ring-progress { transition: stroke-dashoffset 1.2s cubic-bezier(.4,0,.2,1); }
.ring-text {
  position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%);
  text-align: center;
}
.ring-score { display: block; font-size: 28px; font-weight: 800; }
.ring-label { display: block; font-size: 11px; opacity: .7; }
.hero-right { position: relative; }

/* 浮动粒子 */
.hero-particles { position: absolute; inset: 0; pointer-events: none; }
.particle {
  position: absolute; border-radius: 50%; background: rgba(255,255,255,.25);
  animation: particleDrift linear infinite;
}
@keyframes particleDrift {
  0% { opacity: 0; transform: translateY(0); }
  50% { opacity: 1; }
  100% { opacity: 0; transform: translateY(-60px); }
}

/* 统计卡片 */
.stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; }
.stat-card {
  background: #fff; border-radius: var(--radius); padding: 22px 24px;
  display: flex; align-items: center; gap: 16px;
  border: 1px solid var(--border); transition: all var(--transition);
  position: relative; overflow: hidden;
}
.stat-card::before {
  content: ''; position: absolute; left: 0; top: 0; bottom: 0;
  width: 4px; background: var(--accent); border-radius: 0 4px 4px 0;
}
.stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
.stat-icon {
  width: 46px; height: 46px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  background: rgba(108,92,231,.08); color: var(--accent);
}
.stat-info { display: flex; flex-direction: column; }
.stat-value { font-size: 22px; font-weight: 700; color: var(--text); }
.stat-label { font-size: 13px; color: var(--text-muted); margin-top: 2px; }

/* 内容网格 */
.content-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

.dash-card {
  border-radius: var(--radius) !important; border: 1px solid var(--border) !important;
  transition: all var(--transition);
}
.dash-card:hover { box-shadow: var(--shadow-lg); }

.card-head { display: flex; align-items: center; justify-content: space-between; width: 100%; }
.card-head-left { display: flex; align-items: center; gap: 10px; font-size: 16px; font-weight: 600; }
.card-icon {
  width: 34px; height: 34px; border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
}

/* AI画像 */
.portrait-body { display: flex; flex-direction: column; gap: 16px; }
.portrait-text { font-size: 14px; color: var(--text-secondary); line-height: 1.8; }
.trait-columns { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.trait-col { padding: 14px; border-radius: var(--radius-sm); font-size: 13px; }
.trait-col.good { background: rgba(0,210,160,.06); }
.trait-col.warn { background: rgba(254,202,87,.08); }
.trait-title { font-weight: 600; margin-bottom: 8px; }
.trait-col ul { padding-left: 16px; }
.trait-col li { color: var(--text-secondary); margin-bottom: 5px; }

/* AI建议 */
.suggestions { display: flex; flex-direction: column; gap: 12px; }
.suggest-item {
  display: flex; align-items: center; gap: 14px;
  padding: 14px 16px; border-radius: var(--radius-sm);
  background: #F8F9FB; transition: all var(--transition);
}
.suggest-item:hover { background: #F0F1F5; }
.suggest-num {
  width: 26px; height: 26px; border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700; color: #fff; flex-shrink: 0;
}
.priority-0 .suggest-num { background: var(--primary); }
.priority-1 .suggest-num { background: var(--accent); }
.priority-2 .suggest-num { background: var(--warning); }
.suggest-text { font-size: 14px; color: var(--text-secondary); }

.radar-container { width: 100%; height: 280px; }

/* 时间线 */
.timeline { display: flex; flex-direction: column; gap: 0; }
.tl-item { display: flex; gap: 16px; padding: 14px 0; position: relative; }
.tl-item:not(:last-child)::after {
  content: ''; position: absolute; left: 14px; top: 40px; bottom: 0;
  width: 2px; background: var(--border);
}
.tl-dot {
  width: 30px; height: 30px; border-radius: 10px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700; color: #fff; margin-top: 2px;
}
.phase-0 { background: var(--primary); }
.phase-1 { background: var(--accent); }
.phase-2 { background: var(--warning); color: var(--text); }
.tl-month { font-size: 12px; color: var(--text-muted); margin-bottom: 2px; }
.tl-text { font-size: 14px; color: var(--text-secondary); }
</style>
