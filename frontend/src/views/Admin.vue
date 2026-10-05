<template>
  <div class="admin-page">
    <div class="page-hero">
      <h1><el-icon><DataAnalysis /></el-icon> 管理后台</h1>
      <p>平台运营数据与用户管理</p>
    </div>

    <!-- 关键指标 -->
    <div class="metric-grid">
      <div class="metric" v-for="m in metrics" :key="m.label">
        <span class="m-icon" :style="{ background: m.bg, color: m.color }">{{ m.icon }}</span>
        <div class="m-body">
          <span class="m-value">{{ m.value }}</span>
          <span class="m-label">{{ m.label }}</span>
        </div>
      </div>
    </div>

    <!-- 图表 -->
    <div class="chart-grid">
      <el-card shadow="never">
        <template #header><span class="ct">近 7 天注册趋势</span></template>
        <div ref="trendChart" class="chart-box"></div>
      </el-card>
      <el-card shadow="never">
        <template #header><span class="ct">AI 助手使用分布</span></template>
        <div v-if="chatEmpty" class="chart-empty">暂无对话数据</div>
        <div v-show="!chatEmpty" ref="chatChart" class="chart-box"></div>
      </el-card>
    </div>

    <!-- 用户管理 -->
    <el-card shadow="never">
      <template #header>
        <div class="user-head">
          <span class="ct">用户管理</span>
          <el-input v-model="keyword" placeholder="搜索手机号或昵称" size="small"
            class="search-input" clearable @keyup.enter="loadUsers(1)" @clear="loadUsers(1)">
            <template #append>
              <el-button :icon="Search" @click="loadUsers(1)" />
            </template>
          </el-input>
        </div>
      </template>

      <el-table :data="users" v-loading="loading" style="width:100%">
        <el-table-column prop="id" label="ID" width="55" />
        <el-table-column prop="nickname" label="昵称" min-width="80" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机号" width="115" />
        <el-table-column label="专业 / 年级" min-width="145">
          <template #default="{ row }">
            <span v-if="row.hasProfile">{{ row.majorName || '未填写' }} · {{ row.grade || '未填写' }}</span>
            <span v-else class="muted">未初始化档案</span>
          </template>
        </el-table-column>
        <el-table-column label="角色" width="80">
          <template #default="{ row }">
            <el-tag :type="row.role === 'ADMIN' ? 'danger' : 'info'" size="small" effect="plain">
              {{ row.role === 'ADMIN' ? '管理员' : '学生' }}
            </el-tag>
          </template>
        </el-table-column>
        <!-- 日期与时间分两行，避免为了放下 "2026-10-05 12:38" 而撑宽表格 -->
        <el-table-column label="注册时间" width="100">
          <template #default="{ row }">
            <div class="time-cell">
              <span>{{ formatTime(row.createdAt).slice(0, 10) }}</span>
              <span class="time-sub">{{ formatTime(row.createdAt).slice(11) }}</span>
            </div>
          </template>
        </el-table-column>
        <!-- 用图标按钮 + tooltip 代替文字按钮：
             两个中文按钮并排需要近 180px，在窄屏下会把表格挤到横向滚动 -->
        <el-table-column label="操作" width="90" align="center">
          <template #default="{ row }">
            <el-tooltip :content="row.role === 'ADMIN' ? '降为学生' : '设为管理员'" placement="top">
              <el-button size="small" text :icon="Switch" @click="handleToggleRole(row)" />
            </el-tooltip>
            <el-tooltip content="删除该用户及其全部数据" placement="top">
              <el-button size="small" text type="danger" :icon="Delete" @click="handleDelete(row)" />
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="page"
        :page-size="size"
        :total="total"
        layout="prev, pager, next, total"
        class="pager"
        @current-change="loadUsers" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { DataAnalysis, Search, Switch, Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as echarts from 'echarts/core'
import { LineChart, PieChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import { getAdminStatsApi, getAdminUsersApi, updateUserRoleApi, deleteUserApi } from '../api/admin'

// 按需注册图表模块，避免把整个 echarts 打进这个页面的 chunk
echarts.use([LineChart, PieChart, GridComponent, TooltipComponent, LegendComponent, CanvasRenderer])

const stats = ref(null)
const users = ref([])
const loading = ref(false)
const keyword = ref('')
const page = ref(1)
const size = ref(10)
const total = ref(0)

const trendChart = ref(null)
const chatChart = ref(null)
let trendInstance = null
let chatInstance = null

const CHAT_LABELS = {
  GENERAL: '通用问答',
  LEARNING: '学习导师',
  CAREER: '职业规划',
  COMPETITION: '竞赛咨询',
  INTERVIEW: '模拟面试'
}

const metrics = computed(() => {
  const s = stats.value || {}
  return [
    { icon: '👥', label: '注册用户', value: s.userCount ?? 0, bg: 'rgba(139,195,74,.12)', color: '#8BC34A' },
    { icon: '🧠', label: '已生成画像', value: s.portraitCount ?? 0, bg: 'rgba(102,187,106,.10)', color: '#66BB6A' },
    { icon: '🎯', label: '四年规划', value: s.planCount ?? 0, bg: 'rgba(168,85,247,.12)', color: '#A855F7' },
    { icon: '📄', label: 'AI 简历', value: s.resumeCount ?? 0, bg: 'rgba(245,165,36,.12)', color: '#F5A524' },
    { icon: '💬', label: 'AI 对话', value: s.chatCount ?? 0, bg: 'rgba(139,195,74,.10)', color: '#8BC34A' },
    { icon: '🏅', label: '成长记录', value: s.growthCount ?? 0, bg: 'rgba(239,83,80,.10)', color: '#EF5350' },
    { icon: '📚', label: '课程总数', value: s.courseCount ?? 0, bg: 'rgba(255,255,255,.06)', color: '#B0B5BD' },
    { icon: '🏆', label: '竞赛总数', value: s.competitionCount ?? 0, bg: 'rgba(255,255,255,.06)', color: '#B0B5BD' }
  ]
})

const chatEmpty = computed(() => {
  const map = stats.value?.chatByType || {}
  return Object.keys(map).length === 0
})

function formatTime(value) {
  if (!value) return '—'
  return String(value).replace('T', ' ').substring(0, 16)
}

async function loadStats() {
  try {
    stats.value = (await getAdminStatsApi()).data
    await nextTick()
    renderTrend()
    renderChat()
  } catch (e) {
    ElMessage.error('统计数据加载失败')
  }
}

async function loadUsers(pageNo) {
  if (typeof pageNo === 'number') page.value = pageNo
  loading.value = true
  try {
    const res = await getAdminUsersApi({ keyword: keyword.value, page: page.value, size: size.value })
    users.value = res.data.records || []
    total.value = res.data.total || 0
  } catch (e) {
    ElMessage.error('用户列表加载失败')
  } finally {
    loading.value = false
  }
}

async function handleToggleRole(row) {
  const next = row.role === 'ADMIN' ? 'STUDENT' : 'ADMIN'
  const label = next === 'ADMIN' ? '管理员' : '学生'
  try {
    await ElMessageBox.confirm(
      `确定将「${row.nickname}」设为${label}吗？对方需要重新登录后才会生效。`,
      '确认操作', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    const res = await updateUserRoleApi(row.id, next)
    ElMessage.success(res.message || '角色已更新')
    await Promise.all([loadUsers(), loadStats()])
  } catch (e) {
    // 拦截器已提示具体原因
  }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(
      `确定删除用户「${row.nickname}」吗？该用户的画像、规划、简历等全部数据会一并删除，且不可恢复。`,
      '危险操作',
      { type: 'warning', confirmButtonText: '确认删除', confirmButtonClass: 'el-button--danger' })
  } catch (e) {
    return
  }
  try {
    await deleteUserApi(row.id)
    ElMessage.success('用户已删除')
    // 删除后当前页可能空了，回退一页更自然
    if (users.value.length === 1 && page.value > 1) page.value -= 1
    await Promise.all([loadUsers(), loadStats()])
  } catch (e) {
    // 拦截器已提示具体原因
  }
}

function renderTrend() {
  const trend = stats.value?.registerTrend || []
  if (!trendChart.value) return
  if (!trendInstance) trendInstance = echarts.init(trendChart.value)
  trendInstance.setOption({
    grid: { left: 38, right: 16, top: 18, bottom: 26 },
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: trend.map(i => String(i.date).substring(5)),
      axisLine: { lineStyle: { color: 'rgba(255,255,255,.1)' } },
      axisLabel: { color: 'rgba(255,255,255,.4)', fontSize: 11 }
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
      splitLine: { lineStyle: { color: 'rgba(255,255,255,.05)' } },
      axisLabel: { color: 'rgba(255,255,255,.4)', fontSize: 11 }
    },
    series: [{
      type: 'line',
      smooth: true,
      symbolSize: 6,
      data: trend.map(i => i.count),
      itemStyle: { color: '#8BC34A' },
      lineStyle: { color: '#8BC34A', width: 2 },
      areaStyle: {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(139,195,74,.22)' },
            { offset: 1, color: 'rgba(139,195,74,0)' }
          ]
        }
      }
    }]
  }, true)
}

function renderChat() {
  const map = stats.value?.chatByType || {}
  if (!chatChart.value || Object.keys(map).length === 0) return
  if (!chatInstance) chatInstance = echarts.init(chatChart.value)

  const data = Object.keys(map).map(key => ({
    name: CHAT_LABELS[key] || key,
    value: map[key]
  }))

  chatInstance.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c} 次 ({d}%)' },
    legend: {
      bottom: 0,
      textStyle: { color: 'rgba(255,255,255,.45)', fontSize: 11 },
      itemWidth: 8, itemHeight: 8
    },
    color: ['#8BC34A', '#66BB6A', '#A855F7', '#F5A524', '#4DD0C4'],
    series: [{
      type: 'pie',
      radius: ['42%', '66%'],
      center: ['50%', '44%'],
      avoidLabelOverlap: true,
      label: { show: false },
      data
    }]
  }, true)
}

function handleResize() {
  trendInstance?.resize()
  chatInstance?.resize()
}

onMounted(async () => {
  await Promise.all([loadStats(), loadUsers(1)])
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  if (trendInstance) { trendInstance.dispose(); trendInstance = null }
  if (chatInstance) { chatInstance.dispose(); chatInstance = null }
})
</script>

<style scoped>
.admin-page { max-width: 1200px; margin: 0 auto; }
.page-hero { text-align: center; padding: 32px 0 24px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.metric-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 18px; }
.metric {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  border-radius: var(--radius); background: var(--glass);
  border: 1px solid var(--border); backdrop-filter: blur(24px);
  transition: border-color .3s;
}
.metric:hover { border-color: rgba(255,255,255,.09); }
.m-icon { width: 36px; height: 36px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 17px; flex-shrink: 0; }
.m-value { display: block; font-size: 19px; font-weight: 500; color: #fff; line-height: 1.2; }
.m-label { display: block; font-size: 11px; color: var(--fog); margin-top: 2px; }

.chart-grid { display: grid; grid-template-columns: 1.4fr 1fr; gap: 12px; margin-bottom: 18px; }
.chart-box { width: 100%; height: 240px; }
.chart-empty { height: 240px; display: flex; align-items: center; justify-content: center; color: var(--fog); font-size: 13px; }
.ct { font-size: 14px; font-weight: 400; color: #fff; }

.user-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.search-input { width: 240px; }
.pager { margin-top: 16px; justify-content: flex-end; }
.muted { color: var(--fog); font-size: 12px; }
.time-cell { display: flex; flex-direction: column; line-height: 1.35; font-size: 12.5px; }
.time-sub { font-size: 11px; color: var(--fog); }

/* Element Plus 表格在深色主题下的适配 */
:deep(.el-table) { background: transparent; color: var(--mist); --el-table-border-color: transparent; }
:deep(.el-table tr), :deep(.el-table__body-wrapper), :deep(.el-table__header-wrapper) { background: transparent; }
:deep(.el-table th.el-table__cell) { background: rgba(255,255,255,.03); color: var(--fog); font-weight: 500; font-size: 12px; }
:deep(.el-table td.el-table__cell) { border-bottom: 1px solid var(--border-soft); font-size: 13px; }
:deep(.el-table__inner-wrapper::before) { display: none; }
:deep(.el-table--enable-row-hover .el-table__body tr:hover > td.el-table__cell) { background: rgba(255,255,255,.03); }
:deep(.el-table__empty-block) { background: transparent; }
:deep(.el-table__empty-text) { color: var(--fog); }
:deep(.el-pagination) { --el-pagination-bg-color: transparent; --el-pagination-text-color: var(--mist); --el-pagination-button-bg-color: rgba(255,255,255,.04); }
:deep(.el-pagination__total) { color: var(--fog); }

@media (max-width: 1000px) {
  .metric-grid { grid-template-columns: repeat(2, 1fr); }
  .chart-grid { grid-template-columns: 1fr; }
}
@media (max-width: 640px) {
  .user-head { flex-direction: column; align-items: stretch; }
  .search-input { width: 100%; }
}
</style>
