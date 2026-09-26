<template>
  <div class="courses-page">
    <div class="page-hero">
      <h1><el-icon><Reading /></el-icon> 专业知识地图</h1>
      <p>计算机科学与技术 · 完整学习路线</p>
    </div>

    <!-- 统计条 -->
    <div class="stats-bar" v-if="courses.length">
      <div class="stat-mini">
        <span class="stat-num">{{ completedCount }}</span>
        <span class="stat-txt">已掌握</span>
      </div>
      <div class="stat-mini">
        <span class="stat-num">{{ inProgressCount }}</span>
        <span class="stat-txt">学习中</span>
      </div>
      <div class="stat-mini">
        <span class="stat-num">{{ notStartedCount }}</span>
        <span class="stat-txt">未开始</span>
      </div>
      <div class="stat-mini accent">
        <span class="stat-num">{{ totalProgress }}%</span>
        <span class="stat-txt">总进度</span>
      </div>
    </div>

    <!-- 知识地图 -->
    <div class="knowledge-map" v-if="courses.length">
      <div class="map-track">
        <div class="track-line"></div>
        <div class="track-progress" :style="{ height: totalProgress + '%' }"></div>

        <div class="course-node" v-for="(course, idx) in courses" :key="course.id"
          :class="[statusClass(course), 'pos-' + (idx % 2)]"
          :style="{ top: ((idx / (courses.length - 1)) * 100) + '%' }">
          <!-- 连接点 -->
          <div class="node-connector" :class="statusClass(course)"></div>

          <!-- 课程卡片 -->
          <div class="node-card" :class="statusClass(course)" @click="openDetail(course)">
            <div class="card-top">
              <span class="card-category">{{ course.category }}</span>
              <el-tag :type="diffTag(course.difficulty)" size="small" effect="plain">
                {{ diffLabel(course.difficulty) }}
              </el-tag>
            </div>
            <h4 class="card-name">{{ course.name }}</h4>
            <p class="card-desc">{{ course.description }}</p>
            <div class="card-bottom">
              <span class="card-semester">{{ course.semester }}</span>
              <div class="card-progress">
                <el-progress :percentage="course.progress || 0" :stroke-width="6"
                  :color="progressColor(course)" :show-text="false" />
                <span class="progress-num">{{ course.progress || 0 }}%</span>
              </div>
            </div>
            <div class="card-status-badge" v-if="course.progress >= 100">✓</div>
            <div class="card-status-dot" v-else-if="course.progress > 0"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- 课程详情弹窗 -->
    <el-dialog v-model="dialogVisible" :title="selectedCourse?.name" width="500px" destroy-on-close>
      <div v-if="selectedCourse" class="detail-body">
        <div class="detail-meta">
          <el-tag>{{ selectedCourse.category }}</el-tag>
          <el-tag :type="diffTag(selectedCourse.difficulty)">{{ diffLabel(selectedCourse.difficulty) }}</el-tag>
          <el-tag type="info">{{ selectedCourse.semester }}</el-tag>
        </div>
        <p class="detail-desc">{{ selectedCourse.description }}</p>
        <div class="detail-progress">
          <span>当前进度</span>
          <el-slider v-model="sliderProgress" :max="100" :step="10" show-stops
            :marks="progressMarks" @change="handleProgressChange" />
        </div>
      </div>
      <template #footer>
        <el-button @click="dialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleProgressChange(sliderProgress)">
          更新进度
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Reading } from '@element-plus/icons-vue'
import { getCoursesApi, updateProgressApi } from '../api/course'
import { ElMessage } from 'element-plus'

const courses = ref([])
const dialogVisible = ref(false)
const selectedCourse = ref(null)
const sliderProgress = ref(0)

const completedCount = computed(() => courses.value.filter(c => c.progress >= 100).length)
const inProgressCount = computed(() => courses.value.filter(c => c.progress > 0 && c.progress < 100).length)
const notStartedCount = computed(() => courses.value.filter(c => c.progress === 0).length)
const totalProgress = computed(() => {
  if (!courses.value.length) return 0
  const sum = courses.value.reduce((s, c) => s + (c.progress || 0), 0)
  return Math.round(sum / courses.value.length)
})

const progressMarks = { 0: '0%', 25: '', 50: '50%', 75: '', 100: '✓' }

function statusClass(c) {
  if (c.progress >= 100) return 'completed'
  if (c.progress > 0) return 'in-progress'
  return 'pending'
}
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
function progressColor(c) {
  if (c.progress >= 100) return '#00D2A0'
  if (c.progress > 0) return '#6C5CE7'
  return '#E8ECF1'
}

onMounted(async () => {
  try {
    courses.value = (await getCoursesApi(1)).data
  } catch (e) {
    ElMessage.error('加载课程失败')
  }
})

function openDetail(course) {
  selectedCourse.value = course
  sliderProgress.value = course.progress || 0
  dialogVisible.value = true
}

async function handleProgressChange(val) {
  if (!selectedCourse.value) return
  try {
    await updateProgressApi(selectedCourse.value.id, val)
    selectedCourse.value.progress = val
    const idx = courses.value.findIndex(c => c.id === selectedCourse.value.id)
    if (idx >= 0) courses.value[idx].progress = val
    ElMessage.success('进度已更新')
    dialogVisible.value = false
  } catch (e) {
    ElMessage.error('更新失败')
  }
}
</script>

<style scoped>
.courses-page { max-width: 1100px; margin: 0 auto; }

.page-hero { text-align: center; padding: 36px 0 24px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.stats-bar { display: flex; justify-content: center; gap: 32px; margin-bottom: 40px; }
.stat-mini { text-align: center; }
.stat-num { display: block; font-size: 26px; font-weight: 700; color: var(--text); }
.stat-mini.accent .stat-num { color: var(--primary); }
.stat-txt { display: block; font-size: 12px; color: var(--text-muted); margin-top: 2px; }

/* 知识地图 - 双列时间线 */
.knowledge-map { position: relative; padding: 20px 0 60px; }
.map-track { position: relative; min-height: 1200px; }
.track-line {
  position: absolute; left: 50%; top: 0; bottom: 0;
  width: 3px; background: var(--border); transform: translateX(-50%);
  border-radius: 2px;
}
.track-progress {
  position: absolute; left: 50%; top: 0;
  width: 3px; transform: translateX(-50%); border-radius: 2px;
  background: linear-gradient(to bottom, var(--primary), var(--accent));
  transition: height .6s cubic-bezier(.4,0,.2,1);
}

.course-node { position: absolute; width: 44%; transition: all .3s; }
.course-node.pos-0 { left: 0; padding-right: 32px; text-align: right; }
.course-node.pos-1 { right: 0; padding-left: 32px; }

/* 连接点 */
.node-connector {
  position: absolute; top: 28px; width: 14px; height: 14px; border-radius: 50%;
  border: 3px solid var(--border); background: #fff; z-index: 2;
  transition: all var(--transition);
}
.pos-0 .node-connector { right: -8px; }
.pos-1 .node-connector { left: -8px; }
.node-connector.completed { background: var(--success); border-color: var(--success); box-shadow: 0 0 0 4px rgba(0,210,160,.2); }
.node-connector.in-progress { background: var(--primary); border-color: var(--primary); box-shadow: 0 0 0 4px rgba(108,92,231,.2); }

/* 课程卡片 */
.node-card {
  background: #fff; border-radius: var(--radius); padding: 18px 20px;
  border: 1.5px solid var(--border); cursor: pointer;
  transition: all var(--transition); position: relative; overflow: hidden;
}
.node-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
.node-card.completed { border-color: rgba(0,210,160,.3); background: rgba(0,210,160,.02); }
.node-card.in-progress { border-color: rgba(108,92,231,.3); background: rgba(108,92,231,.02); }

.card-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.pos-0 .card-top { flex-direction: row-reverse; }
.card-category { font-size: 11px; color: var(--text-muted); font-weight: 500; text-transform: uppercase; letter-spacing: .5px; }
.card-name { font-size: 16px; font-weight: 600; margin-bottom: 4px; }
.card-desc { font-size: 12px; color: var(--text-muted); margin-bottom: 12px; line-height: 1.5; }
.card-bottom { display: flex; align-items: center; gap: 12px; }
.pos-0 .card-bottom { flex-direction: row-reverse; }
.card-semester { font-size: 12px; color: var(--text-muted); white-space: nowrap; }
.card-progress { flex: 1; display: flex; align-items: center; gap: 8px; }
.card-progress :deep(.el-progress) { flex: 1; }
.progress-num { font-size: 12px; font-weight: 600; color: var(--text-secondary); min-width: 32px; }

.card-status-badge {
  position: absolute; top: 10px; right: 10px;
  width: 24px; height: 24px; border-radius: 50%;
  background: var(--success); color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700;
}
.card-status-dot {
  position: absolute; top: 14px; right: 14px;
  width: 10px; height: 10px; border-radius: 50%;
  background: var(--primary);
  animation: pulse 2s infinite;
}

.detail-body { display: flex; flex-direction: column; gap: 16px; }
.detail-meta { display: flex; gap: 8px; }
.detail-desc { color: var(--text-secondary); font-size: 14px; line-height: 1.8; }
.detail-progress { display: flex; align-items: center; gap: 16px; }
.detail-progress span { font-size: 13px; color: var(--text-muted); white-space: nowrap; }
.detail-progress :deep(.el-slider) { flex: 1; }
</style>
