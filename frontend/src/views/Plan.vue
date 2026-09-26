<template>
  <div class="plan-page">
    <div class="plan-hero">
      <div class="plan-hero-content">
        <h1><el-icon><MagicStick /></el-icon> AI大学四年规划</h1>
        <p>基于你的专业、兴趣和目标，AI为你量身定制的四年成长路线</p>
      </div>
      <el-button v-if="!plan" type="primary" size="large" round @click="handleGenerate" :loading="generating">
        {{ generating ? 'AI正在生成规划...' : '✨ 生成我的四年规划' }}
      </el-button>
    </div>

    <!-- 规划总览 -->
    <div v-if="plan" class="plan-overview">
      <div class="overview-card">
        <el-icon :size="28"><Aim /></el-icon>
        <p>{{ plan.overview }}</p>
      </div>
    </div>

    <!-- 四年规划时间线 -->
    <div v-if="plan" class="year-timeline">
      <div class="year-card" v-for="(year, key, idx) in years" :key="key"
        :class="['year-' + idx, { active: isCurrentYear(key) }]">
        <div class="year-bar" :style="{ background: yearColors[idx] }"></div>
        <div class="year-header">
          <div class="year-badge" :style="{ background: yearColors[idx] }">
            {{ yearLabels[key] }}
          </div>
          <h3>{{ year.theme }}</h3>
          <el-tag v-if="isCurrentYear(key)" type="danger" size="small" effect="dark" round>当前阶段</el-tag>
        </div>

        <div class="year-body">
          <!-- 学习目标 -->
          <div class="year-section">
            <div class="section-title"><el-icon><Flag /></el-icon> 学习目标</div>
            <div class="tag-group">
              <span class="item-tag" v-for="g in year.goals" :key="g">{{ g }}</span>
            </div>
          </div>

          <!-- 推荐课程 -->
          <div class="year-section">
            <div class="section-title"><el-icon><Reading /></el-icon> 推荐课程</div>
            <div class="tag-group">
              <span class="item-tag course" v-for="c in year.courses" :key="c">{{ c }}</span>
            </div>
          </div>

          <!-- 技能提升 -->
          <div class="year-section">
            <div class="section-title"><el-icon><CircleCheck /></el-icon> 技能提升</div>
            <div class="tag-group">
              <span class="item-tag skill" v-for="s in year.skills" :key="s">{{ s }}</span>
            </div>
          </div>

          <!-- 推荐竞赛 -->
          <div class="year-section" v-if="year.competitions && year.competitions.length">
            <div class="section-title"><el-icon><TrophyBase /></el-icon> 推荐竞赛</div>
            <div class="tag-group">
              <span class="item-tag comp" v-for="c in year.competitions" :key="c">{{ c }}</span>
            </div>
          </div>

          <!-- 建议 -->
          <div class="year-tip" v-if="year.tips">
            <el-icon><ChatLineSquare /></el-icon>
            <span>{{ year.tips }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 风险提醒 -->
    <div v-if="plan?.risks" class="risks-section">
      <el-card shadow="never" class="risks-card">
        <template #header>
          <div class="section-header"><el-icon><WarningFilled /></el-icon> 风险提醒</div>
        </template>
        <div class="risk-list">
          <div class="risk-item" v-for="(r, i) in plan.risks" :key="i">
            <span class="risk-num">{{ i + 1 }}</span>
            <span>{{ r }}</span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 推荐证书 -->
    <div v-if="plan?.certificates" class="certs-section">
      <el-card shadow="never">
        <template #header>
          <div class="section-header"><el-icon><Medal /></el-icon> 推荐考取证书</div>
        </template>
        <div class="certs-grid">
          <div class="cert-item" v-for="(c, i) in plan.certificates" :key="i">
            <span class="cert-icon">{{ ['📜','🏅','📋','💼'][i] || '📌' }}</span>
            <span>{{ c }}</span>
          </div>
        </div>
      </el-card>
    </div>

    <el-empty v-if="!plan && !generating" description="点击上方按钮，让AI为你生成专属大学四年规划" :image-size="100" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { generatePlanApi, getPlanApi } from '../api/plan'
import { ElMessage } from 'element-plus'
import { MagicStick, Aim, Flag, Reading, CircleCheck, TrophyBase, ChatLineSquare, WarningFilled, Medal } from '@element-plus/icons-vue'

const plan = ref(null)
const generating = ref(false)

const yearLabels = { freshman: '大一', sophomore: '大二', junior: '大三', senior: '大四' }
const yearColors = ['#6C5CE7', '#00CEC9', '#FECA57', '#FF6B6B']

const years = computed(() => {
  if (!plan.value) return {}
  const { overview, risks, certificates, ...y } = plan.value
  return y
})

const currentGrade = ref('大二')
function isCurrentYear(key) {
  const map = { freshman: '大一', sophomore: '大二', junior: '大三', senior: '大四' }
  return map[key] === currentGrade.value
}

onMounted(async () => {
  try {
    plan.value = (await getPlanApi()).data
  } catch (e) {}
})

async function handleGenerate() {
  generating.value = true
  try {
    const res = await generatePlanApi()
    plan.value = res.data
    ElMessage.success('AI四年规划生成完成！')
  } catch (e) {
    ElMessage.error('生成失败，请确保已完成档案初始化')
  } finally {
    generating.value = false
  }
}
</script>

<script>
import { computed } from 'vue'
</script>

<style scoped>
.plan-page { max-width: 1000px; margin: 0 auto; }

.plan-hero {
  text-align: center; padding: 48px 0 32px;
}
.plan-hero h1 {
  font-size: 28px; font-weight: 700; display: flex;
  align-items: center; justify-content: center; gap: 10px;
  margin-bottom: 8px;
}
.plan-hero p { color: var(--text-secondary); font-size: 15px; margin-bottom: 24px; }

.plan-overview { margin-bottom: 32px; }
.overview-card {
  display: flex; align-items: center; gap: 14px;
  padding: 20px 24px; background: linear-gradient(135deg, rgba(108,92,231,.06), rgba(0,206,201,.06));
  border-radius: var(--radius); border: 1px solid rgba(108,92,231,.15);
}
.overview-card p { font-size: 15px; color: var(--text-secondary); line-height: 1.7; }

/* 四年时间线 */
.year-timeline { display: flex; flex-direction: column; gap: 20px; margin-bottom: 32px; }
.year-card {
  background: #fff; border-radius: var(--radius-lg);
  border: 1px solid var(--border); overflow: hidden;
  transition: all var(--transition);
}
.year-card:hover { box-shadow: var(--shadow-lg); }
.year-card.active { border-color: rgba(108,92,231,.3); box-shadow: 0 4px 24px rgba(108,92,231,.1); }
.year-bar { height: 4px; }
.year-header {
  padding: 20px 24px 0; display: flex; align-items: center; gap: 12px;
}
.year-badge {
  padding: 5px 14px; border-radius: 20px; color: #fff;
  font-size: 13px; font-weight: 600;
}
.year-header h3 { font-size: 18px; font-weight: 600; flex: 1; }

.year-body { padding: 16px 24px 24px; }
.year-section { margin-bottom: 16px; }
.section-title {
  font-size: 13px; font-weight: 600; color: var(--text-secondary);
  display: flex; align-items: center; gap: 6px; margin-bottom: 10px;
}
.tag-group { display: flex; flex-wrap: wrap; gap: 8px; }
.item-tag {
  padding: 5px 14px; border-radius: 20px; font-size: 13px;
  background: #F5F6FA; color: var(--text-secondary);
}
.item-tag.course { background: rgba(108,92,231,.08); color: var(--primary); }
.item-tag.skill { background: rgba(0,206,201,.08); color: #008F8B; }
.item-tag.comp { background: rgba(254,202,87,.12); color: #B8860B; }

.year-tip {
  display: flex; align-items: flex-start; gap: 8px;
  padding: 14px; background: #FFFDF5; border-radius: var(--radius-sm);
  border: 1px solid rgba(254,202,87,.3); font-size: 13px; color: #8B6914;
}

.risks-section, .certs-section { margin-bottom: 24px; }
.section-header { display: flex; align-items: center; gap: 8px; font-size: 16px; font-weight: 600; }
.risk-list { display: flex; flex-direction: column; gap: 12px; }
.risk-item { display: flex; align-items: center; gap: 12px; font-size: 14px; color: var(--text-secondary); }
.risk-num {
  width: 24px; height: 24px; border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  background: rgba(255,107,107,.1); color: #FF6B6B;
  font-weight: 700; font-size: 12px; flex-shrink: 0;
}

.certs-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.cert-item { display: flex; align-items: center; gap: 10px; padding: 14px; background: #F8F9FB; border-radius: var(--radius-sm); font-size: 14px; }
.cert-icon { font-size: 22px; }
</style>
