<template>
  <div class="courses-page">
    <div class="page-hero">
      <h1><el-icon><Reading /></el-icon> 专业知识地图</h1>
      <p>{{ majorName || '我的专业' }} · 完整学习路线</p>
    </div>

    <!-- 空状态分两种原因：没选专业要引导初始化，选了专业但缺数据才说「补充中」。
         以前两者共用一个文案，评委用新账号进来会误以为课程库根本没做完。 -->
    <div class="major-notice" v-if="loaded && !courses.length">
      <el-icon><InfoFilled /></el-icon>
      <template v-if="!majorId">
        <span>还没有选择专业。完成 AI 成长档案初始化后，这里会自动生成属于你专业的完整课程地图。</span>
        <el-button size="small" type="primary" round @click="$router.push('/init')">去完善档案</el-button>
      </template>
      <template v-else>
        <span>「{{ majorName || '该专业' }}」的课程数据正在补充中，敬请期待。</span>
      </template>
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

        <!-- 按行排布：两张卡片占一行，行高由内容撑开，课程再多也不会互相压叠 -->
        <div class="course-node" v-for="(course, idx) in courses" :key="course.id"
          :class="[statusClass(course), 'pos-' + (idx % 2)]"
          :style="{ '--row': Math.floor(idx / 2) + 1 }">
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
import { Reading, InfoFilled } from '@element-plus/icons-vue'
import { getCoursesApi, updateProgressApi } from '../api/course'
import { getProfileApi } from '../api/profile'
import { ElMessage } from 'element-plus'

const courses = ref([])
const dialogVisible = ref(false)
const selectedCourse = ref(null)
const sliderProgress = ref(0)
const majorName = ref('')
const majorId = ref(null)
const loaded = ref(false)

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
  if (c.progress >= 100) return '#66BB6A'
  if (c.progress > 0) return 'var(--signal)'
  return 'rgba(255,255,255,.18)'
}

onMounted(async () => {
  // 只加载学生本人专业的课程；未初始化档案时引导去初始化，不做其它专业兜底
  try {
    const profile = (await getProfileApi()).data
    if (profile?.majorId) {
      majorId.value = profile.majorId
      majorName.value = profile.majorName || ''
    }
  } catch (e) {
    // 档案尚未初始化
  }

  if (majorId.value == null) {
    loaded.value = true
    return
  }

  try {
    courses.value = (await getCoursesApi(majorId.value)).data || []
  } catch (e) {
    ElMessage.error('加载课程失败')
  } finally {
    loaded.value = true
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

.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.stats-bar { display: flex; justify-content: center; gap: 32px; margin-bottom: 40px; }
.major-notice {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  max-width: 640px; margin: 0 auto 28px; padding: 12px 18px;
  border-radius: var(--radius); font-size: 13px; color: #F5C97A;
  background: rgba(245,165,36,.10); border: 1px solid rgba(245,165,36,.22);
  flex-wrap: wrap; gap: 8px; text-align: center;
}
.stat-mini { text-align: center; }
.stat-num { display: block; font-size: 26px; font-weight: 700; color: var(--text); }
.stat-mini.accent .stat-num { color: var(--primary); }
.stat-txt { display: block; font-size: 12px; color: var(--text-muted); margin-top: 2px; }

/* 知识地图 - 双列时间线
   行高完全由卡片内容撑开：早期实现用固定 1200px 高度 + 绝对定位按百分比
   分布节点，专业课程一多（十几门）分配到的间距小于卡片实际高度，相邻卡片
   就会上下压叠。改成 CSS Grid 后，每两门课占一行、行高自适应，永不重叠。 */
.knowledge-map { position: relative; padding: 20px 0 60px; }
.map-track {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-auto-rows: auto;
  column-gap: 0;
  row-gap: 22px;
  align-items: stretch;
  padding: 8px 0;
}
.track-line {
  position: absolute; left: 50%; top: 0; bottom: 0;
  width: 3px; background: var(--border); transform: translateX(-50%);
  border-radius: 2px;
}
.track-progress {
  position: absolute; left: 50%; top: 0;
  width: 3px; transform: translateX(-50%); border-radius: 2px;
  background: linear-gradient(to bottom, var(--primary), #A855F7);
  transition: height .6s cubic-bezier(.4,0,.2,1);
}

.course-node { position: relative; width: auto; min-width: 0; grid-row: var(--row); transition: all .3s; }
.course-node.pos-0 { grid-column: 1; padding-right: 32px; text-align: right; }
.course-node.pos-1 { grid-column: 2; padding-left: 32px; }

/* 连接点 */
.node-connector {
  position: absolute; top: 28px; width: 14px; height: 14px; border-radius: 50%;
  border: 3px solid var(--border); background:var(--glass); z-index: 2;
  transition: all var(--transition);
}
.pos-0 .node-connector { right: -8px; }
.pos-1 .node-connector { left: -8px; }
.node-connector.completed { background: var(--success); border-color: var(--success); box-shadow: 0 0 0 4px rgba(0,210,160,.2); }
.node-connector.in-progress { background: var(--primary); border-color: var(--primary); box-shadow: 0 0 0 4px rgba(139,195,74,.2); }

/* 课程卡片 */
.node-card {
  background:var(--glass); border-radius: var(--radius); padding: 18px 20px;
  border: 1.5px solid var(--border); cursor: pointer;
  transition: all var(--transition); position: relative; overflow: hidden;
  /* 同一行的两张卡片等高，底部进度条水平对齐 */
  height: 100%; display: flex; flex-direction: column;
}
.node-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
.node-card.completed { border-color: rgba(0,210,160,.3); background: rgba(0,210,160,.02); }
.node-card.in-progress { border-color: rgba(139,195,74,.3); background: rgba(139,195,74,.02); }

/* 右上角的完成徽标是绝对定位，右侧留出空间避免压住类别/难度标签 */
.card-top { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 8px; min-width: 0; padding-right: 30px; }
.pos-0 .card-top { flex-direction: row-reverse; }
.card-top :deep(.el-tag) { flex-shrink: 0; }
.card-category {
  font-size: 11px; color: var(--text-muted); font-weight: 500;
  text-transform: uppercase; letter-spacing: .5px;
  min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.card-name { font-size: 16px; font-weight: 600; margin-bottom: 4px; overflow-wrap: anywhere; }
.card-desc {
  font-size: 12px; color: var(--text-muted); margin-bottom: 12px; line-height: 1.5;
  flex: 1; overflow-wrap: anywhere; word-break: break-word;
}
.card-bottom { display: flex; align-items: center; gap: 12px; min-width: 0; margin-top: auto; }
.pos-0 .card-bottom { flex-direction: row-reverse; }
.card-semester { font-size: 12px; color: var(--text-muted); white-space: nowrap; flex-shrink: 0; }
.card-progress { flex: 1; min-width: 0; display: flex; align-items: center; gap: 8px; }
.card-progress :deep(.el-progress) { flex: 1; min-width: 0; }
.progress-num { font-size: 12px; font-weight: 600; color: var(--text-secondary); min-width: 32px; flex-shrink: 0; }

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

/* 窄屏收成单列时间线：竖线靠左，卡片依次排列，避免两列被挤到文字折行重叠 */
@media (max-width: 820px) {
  .map-track { grid-template-columns: 1fr; row-gap: 16px; }
  .course-node.pos-0, .course-node.pos-1 {
    grid-column: 1; grid-row: auto;
    padding-left: 36px; padding-right: 0; text-align: left;
  }
  .pos-0 .card-top, .pos-0 .card-bottom { flex-direction: row; }
  .pos-0 .node-connector, .pos-1 .node-connector { left: 0; right: auto; }
  .track-line, .track-progress { left: 7px; }
  .stats-bar { gap: 20px; }
}
</style>
