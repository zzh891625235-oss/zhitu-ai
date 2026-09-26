<template>
  <div class="home-page">
    <!-- 欢迎区 -->
    <div class="welcome-card">
      <div class="welcome-left">
        <h1>你好，{{ userStore.userInfo?.nickname || '同学' }} <span class="wave">👋</span></h1>
        <p class="welcome-sub">{{ welcomeText }}</p>
        <div class="welcome-tags">
          <el-tag type="primary" effect="dark" round>{{ profile?.grade || '新生' }}</el-tag>
          <el-tag effect="dark" round>{{ majorName }}</el-tag>
        </div>
      </div>
      <div class="welcome-right">
        <div class="progress-ring-area">
          <el-progress type="dashboard" :percentage="overallScore" :color="colors" :width="140">
            <template #default>
              <span class="progress-label">综合能力</span>
              <span class="progress-value">{{ overallScore }}分</span>
            </template>
          </el-progress>
        </div>
      </div>
    </div>

    <!-- 大学四年进度 -->
    <el-card class="section-card" shadow="never">
      <template #header><span class="card-title">大学四年进度</span></template>
      <div class="year-progress">
        <div class="year-item" v-for="item in years" :key="item.label">
          <div class="year-label">{{ item.label }}</div>
          <el-progress :percentage="item.progress" :stroke-width="14" :color="item.color" />
        </div>
      </div>
    </el-card>

    <div class="home-grid">
      <!-- AI学生画像 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><MagicStick /></el-icon> AI学生画像</span>
        </template>
        <div class="portrait-content" v-if="portrait">
          <p class="portrait-summary">{{ portrait.summary }}</p>
          <div class="portrait-section" v-if="portrait.strengths?.length">
            <div class="section-label">✅ 优势</div>
            <ul><li v-for="s in portrait.strengths" :key="s">{{ s }}</li></ul>
          </div>
          <div class="portrait-section" v-if="portrait.weaknesses?.length">
            <div class="section-label">⚠️ 待提升</div>
            <ul><li v-for="w in portrait.weaknesses" :key="w">{{ w }}</li></ul>
          </div>
        </div>
        <el-empty v-else description="尚未生成AI画像，请先完成档案初始化" :image-size="80">
          <el-button type="primary" size="small" @click="$router.push('/init')">去初始化</el-button>
        </el-empty>
      </el-card>

      <!-- 今日任务 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><List /></el-icon> AI建议</span>
        </template>
        <div class="ai-tips" v-if="portrait?.suggestions">
          <div class="tip-item" v-for="(sug, idx) in portrait.suggestions" :key="idx">
            <el-tag :type="idx === 0 ? 'primary' : idx === 1 ? 'success' : 'warning'" size="small">
              {{ idx + 1 }}
            </el-tag>
            <span>{{ sug }}</span>
          </div>
        </div>
        <el-empty v-else description="完成AI画像后获取个性化建议" :image-size="60" />
      </el-card>

      <!-- 能力雷达图 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><TrendCharts /></el-icon> 能力雷达图</span>
        </template>
        <div ref="radarChart" style="width:100%;height:280px"></div>
      </el-card>

      <!-- 三月规划 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><Calendar /></el-icon> 三月成长计划</span>
        </template>
        <el-timeline v-if="portrait?.threeMonthPlan">
          <el-timeline-item
            v-for="(plan, idx) in portrait.threeMonthPlan"
            :key="idx"
            :timestamp="'第' + (idx + 1) + '个月'"
            placement="top"
          >
            {{ plan }}
          </el-timeline-item>
        </el-timeline>
        <el-empty v-else description="暂无计划" :image-size="60" />
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useUserStore } from '../stores/user'
import { MagicStick, List, TrendCharts, Calendar } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { getProfileApi, getPortraitApi } from '../api/profile'

const userStore = useUserStore()
const radarChart = ref(null)
const profile = ref(null)
const portrait = ref(null)

const colors = [
  { color: '#f56c6c', percentage: 20 },
  { color: '#e6a23c', percentage: 40 },
  { color: '#5cb87a', percentage: 70 },
  { color: '#1989fa', percentage: 85 },
  { color: '#667eea', percentage: 100 }
]

const majors = ['', '计算机科学与技术', '软件工程', '人工智能', '大数据', '电子信息工程']
const majorName = computed(() => {
  if (profile.value?.majorId) return majors[profile.value.majorId] || '未知专业'
  return '加载中...'
})

const overallScore = computed(() => {
  if (portrait.value?.scores?.overall) return portrait.value.scores.overall
  return 0
})

const welcomeText = computed(() => {
  if (portrait.value?.summary) return portrait.value.summary.substring(0, 50) + '...'
  if (profile.value) return '你的大学成长路线已就绪，继续加油！'
  return '完成AI档案初始化，获取专属成长规划'
})

const years = [
  { label: '大一', progress: 95, color: '#67c23a' },
  { label: '大二', progress: 68, color: '#409eff' },
  { label: '大三', progress: 15, color: '#e6a23c' },
  { label: '大四', progress: 0, color: '#909399' }
]

onMounted(async () => {
  // 加载档案
  try {
    profile.value = (await getProfileApi()).data
  } catch (e) {
    // 尚未初始化
  }
  // 加载AI画像
  try {
    portrait.value = (await getPortraitApi()).data
  } catch (e) {
    // 尚未生成
  }
  // 绘制雷达图
  await nextTick()
  renderRadar()
})

function renderRadar() {
  if (!radarChart.value) return
  const chart = echarts.init(radarChart.value)
  const scores = portrait.value?.scores || {}
  chart.setOption({
    radar: {
      indicator: [
        { name: '编程能力', max: 100 },
        { name: '算法能力', max: 100 },
        { name: '项目能力', max: 100 },
        { name: '竞赛能力', max: 100 },
        { name: 'AI能力', max: 100 },
        { name: '英语能力', max: 100 }
      ],
      center: ['50%', '55%'],
      radius: '70%'
    },
    series: [{
      type: 'radar',
      data: [{
        value: [
          scores.programming || 30,
          scores.algorithm || 30,
          scores.project || 30,
          scores.competition || 30,
          scores.ai || 30,
          scores.english || 30
        ],
        name: '当前能力'
      }],
      areaStyle: { color: 'rgba(102, 126, 234, 0.25)' },
      lineStyle: { color: '#667eea', width: 2 },
      itemStyle: { color: '#667eea' }
    }]
  })
  window.addEventListener('resize', () => chart.resize())
}
</script>

<style scoped>
.home-page { display: flex; flex-direction: column; gap: 20px; }

.welcome-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px; padding: 36px 40px;
  display: flex; align-items: center; justify-content: space-between;
  color: #fff;
}
.welcome-left h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
.wave { display: inline-block; animation: wave 1.5s infinite; }
@keyframes wave { 0%,100% { transform: rotate(0deg) } 25% { transform: rotate(20deg) } 75% { transform: rotate(-20deg) } }
.welcome-sub { font-size: 15px; opacity: .9; margin-bottom: 16px; max-width: 500px; }
.welcome-tags { display: flex; gap: 8px; }
.progress-label { display: block; font-size: 12px; color: #999; }
.progress-value { display: block; font-size: 22px; font-weight: 700; color: #333; }

.section-card { border-radius: 12px; }
.card-title { font-size: 16px; font-weight: 600; display: flex; align-items: center; gap: 6px; }

.year-progress { display: flex; flex-direction: column; gap: 16px; padding: 4px 0; }
.year-item { display: flex; align-items: center; gap: 16px; }
.year-label { width: 50px; text-align: right; font-size: 14px; color: #666; flex-shrink: 0; }
.year-item :deep(.el-progress) { flex: 1; }

.home-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

.portrait-content { font-size: 14px; }
.portrait-summary { color: #555; line-height: 1.7; margin-bottom: 16px; }
.portrait-section { margin-bottom: 12px; }
.section-label { font-weight: 600; margin-bottom: 6px; }
.portrait-section ul { margin: 0; padding-left: 18px; }
.portrait-section li { color: #666; margin-bottom: 4px; }

.ai-tips { display: flex; flex-direction: column; gap: 14px; }
.tip-item { display: flex; align-items: center; gap: 10px; font-size: 14px; }
</style>
