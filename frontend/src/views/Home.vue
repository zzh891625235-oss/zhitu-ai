<template>
  <div class="home-page">
    <!-- 欢迎区 -->
    <div class="welcome-card">
      <div class="welcome-left">
        <h1>你好，{{ userStore.userInfo?.nickname || '同学' }} <span class="wave">&#x1F44B;</span></h1>
        <p class="welcome-sub">你的大学成长路线已经生成，继续加油！</p>
        <div class="welcome-tags">
          <el-tag type="primary" effect="dark" round>大二</el-tag>
          <el-tag effect="dark" round>计算机科学与技术</el-tag>
        </div>
      </div>
      <div class="welcome-right">
        <div class="progress-ring-area">
          <el-progress type="dashboard" :percentage="68" :color="colors" :width="140">
            <template #default="{ percentage }">
              <span class="progress-label">成长进度</span>
              <span class="progress-value">{{ percentage }}%</span>
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
      <!-- AI今日建议 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><MagicStick /></el-icon> AI今日建议</span>
        </template>
        <div class="ai-tips">
          <div class="tip-item">
            <el-tag type="primary" size="small">学习</el-tag>
            <span>今天建议完成：Spring Boot 基础学习</span>
          </div>
          <div class="tip-item">
            <el-tag type="success" size="small">竞赛</el-tag>
            <span>传智杯报名进行中，距离截止还有 65 天</span>
          </div>
          <div class="tip-item">
            <el-tag type="warning" size="small">提醒</el-tag>
            <span>你的数据结构进度偏低，建议本周补上</span>
          </div>
        </div>
      </el-card>

      <!-- 今日任务 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><List /></el-icon> 今日任务</span>
        </template>
        <div class="task-list">
          <div class="task-item" v-for="task in todayTasks" :key="task.id">
            <el-checkbox v-model="task.done" />
            <span :class="{ done: task.done }">{{ task.content }}</span>
          </div>
        </div>
      </el-card>

      <!-- 推荐竞赛 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><Trophy /></el-icon> 推荐竞赛</span>
        </template>
        <div class="comp-list">
          <div class="comp-item" v-for="comp in competitions" :key="comp.id">
            <div class="comp-name">{{ comp.name }}</div>
            <div class="comp-meta">
              <el-tag :type="comp.difficulty === 'BEGINNER' ? 'success' : 'warning'" size="small">
                {{ comp.difficulty }}
              </el-tag>
              <span class="comp-days">距截止 {{ comp.daysLeft }} 天</span>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 能力雷达图 -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <span class="card-title"><el-icon><TrendCharts /></el-icon> 能力雷达图</span>
        </template>
        <div ref="radarChart" style="width:100%;height:280px"></div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useUserStore } from '../stores/user'
import { MagicStick, List, Trophy, TrendCharts } from '@element-plus/icons-vue'
import * as echarts from 'echarts'

const userStore = useUserStore()
const radarChart = ref(null)
const colors = [
  { color: '#f56c6c', percentage: 20 },
  { color: '#e6a23c', percentage: 40 },
  { color: '#5cb87a', percentage: 70 },
  { color: '#1989fa', percentage: 85 },
  { color: '#667eea', percentage: 100 }
]

const years = [
  { label: '大一', progress: 95, color: '#67c23a' },
  { label: '大二', progress: 68, color: '#409eff' },
  { label: '大三', progress: 15, color: '#e6a23c' },
  { label: '大四', progress: 0, color: '#909399' }
]

const todayTasks = ref([
  { id: 1, content: 'Spring Boot 基础 - 入门概念', done: false },
  { id: 2, content: '数据结构 - 链表复习', done: false },
  { id: 3, content: '算法每日一题 - LeetCode', done: true },
  { id: 4, content: '英语单词背诵30个', done: false }
])

const competitions = ref([
  { id: 1, name: '传智杯全国大学生IT技能大赛', difficulty: 'BEGINNER', daysLeft: 65 },
  { id: 2, name: '蓝桥杯软件和信息技术大赛', difficulty: 'INTERMEDIATE', daysLeft: 80 },
  { id: 3, name: 'ACM-ICPC程序设计竞赛', difficulty: 'ADVANCED', daysLeft: 35 }
])

onMounted(async () => {
  await nextTick()
  if (radarChart.value) {
    const chart = echarts.init(radarChart.value)
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
        data: [{ value: [68, 45, 52, 40, 55, 63], name: '当前能力' }],
        areaStyle: { color: 'rgba(102, 126, 234, 0.25)' },
        lineStyle: { color: '#667eea', width: 2 },
        itemStyle: { color: '#667eea' }
      }]
    })
    window.addEventListener('resize', () => chart.resize())
  }
})
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
@keyframes wave { 0%, 100% { transform: rotate(0deg); } 25% { transform: rotate(20deg); } 75% { transform: rotate(-20deg); } }
.welcome-sub { font-size: 15px; opacity: 0.9; margin-bottom: 16px; }
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
.ai-tips { display: flex; flex-direction: column; gap: 14px; }
.tip-item { display: flex; align-items: center; gap: 10px; font-size: 14px; }

.task-list { display: flex; flex-direction: column; gap: 12px; }
.task-item { display: flex; align-items: center; gap: 10px; font-size: 14px; }
.task-item .done { text-decoration: line-through; color: #999; }

.comp-list { display: flex; flex-direction: column; gap: 14px; }
.comp-item { padding: 12px; background: #f8f9fa; border-radius: 8px; }
.comp-name { font-size: 14px; font-weight: 500; margin-bottom: 6px; }
.comp-meta { display: flex; align-items: center; gap: 10px; }
.comp-days { font-size: 12px; color: #999; }
</style>
