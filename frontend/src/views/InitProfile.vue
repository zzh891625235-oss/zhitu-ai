<template>
  <div class="init-page">
    <div class="init-bg">
      <div class="bg-shape shape-1"></div>
      <div class="bg-shape shape-2"></div>
    </div>

    <div class="init-card">
      <div class="init-header">
        <div class="init-badge">
          <span>AI</span>
        </div>
        <h2>AI成长档案初始化</h2>
        <p>帮助AI更好地了解你，为你生成专属成长画像与规划</p>
      </div>

      <!-- 进度指示器 -->
      <div class="steps-container">
        <div class="custom-steps">
          <div v-for="(step, idx) in steps" :key="idx"
            class="custom-step"
            :class="{ active: idx === activeStep, done: idx < activeStep }"
            @click="idx < activeStep ? activeStep = idx : null">
            <div class="step-circle">
              <el-icon v-if="idx < activeStep"><Check /></el-icon>
              <span v-else>{{ idx + 1 }}</span>
            </div>
            <div class="step-info">
              <span class="step-title">{{ step.title }}</span>
              <span class="step-desc">{{ step.desc }}</span>
            </div>
          </div>
          <div class="step-line" :style="{ width: (activeStep / (steps.length - 1)) * 100 + '%' }"></div>
        </div>
      </div>

      <!-- Step 1: 基础信息 -->
      <div v-if="activeStep === 0" class="step-body">
        <el-form ref="form1" :model="form" :rules="rules1" label-width="90px" class="init-form">
          <el-form-item label="学校" prop="school">
            <el-input v-model="form.school" placeholder="输入你的学校名称" size="large" />
          </el-form-item>
          <el-form-item label="专业" prop="majorId">
            <el-select v-model="form.majorId" placeholder="选择你的专业" size="large" style="width:100%">
              <el-option v-for="m in majors" :key="m.id" :label="m.name" :value="m.id" />
            </el-select>
          </el-form-item>
          <el-form-item label="年级" prop="grade">
            <div class="grade-cards">
              <div v-for="g in ['大一','大二','大三','大四']" :key="g"
                class="grade-card" :class="{ selected: form.grade === g }"
                @click="form.grade = g">
                <span class="grade-emoji">{{ g === '大一' ? '🌱' : g === '大二' ? '🌿' : g === '大三' ? '🌳' : '🎓' }}</span>
                <span>{{ g }}</span>
              </div>
            </div>
          </el-form-item>
          <el-form-item label="成绩水平">
            <el-select v-model="form.gpa" placeholder="当前成绩水平" size="large" style="width:100%">
              <el-option label="🌟 优秀 (前20%)" value="优秀" />
              <el-option label="👍 良好 (前50%)" value="良好" />
              <el-option label="📊 中等" value="中等" />
              <el-option label="📈 待提升" value="待提升" />
            </el-select>
          </el-form-item>
        </el-form>
      </div>

      <!-- Step 2: 学习情况 -->
      <div v-if="activeStep === 1" class="step-body">
        <div class="level-grid">
          <div class="level-item" v-for="item in skillItems" :key="item.key">
            <div class="level-label">{{ item.emoji }} {{ item.label }}</div>
            <el-radio-group v-model="form[item.key]" class="level-radios">
              <el-radio-button value="BEGINNER">零基础</el-radio-button>
              <el-radio-button value="BASIC">入门</el-radio-button>
              <el-radio-button value="INTERMEDIATE">中等</el-radio-button>
              <el-radio-button value="ADVANCED">熟练</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </div>

      <!-- Step 3: 兴趣方向 -->
      <div v-if="activeStep === 2" class="step-body">
        <p class="step-tip">选择你感兴趣的方向（可多选），AI会根据兴趣推荐学习路线</p>
        <el-checkbox-group v-model="form.interests" class="interest-grid">
          <el-checkbox v-for="item in interestOptions" :key="item" :label="item" :value="item" border class="interest-chip" />
        </el-checkbox-group>
      </div>

      <!-- Step 4: 未来目标 -->
      <div v-if="activeStep === 3" class="step-body">
        <p class="step-tip">你的目标是什么？AI会据此定制专属成长路线</p>
        <div class="goal-cards">
          <div v-for="item in goals" :key="item.value"
            class="goal-card" :class="{ selected: form.careerGoal === item.value }"
            @click="form.careerGoal = item.value">
            <span class="goal-emoji">{{ item.icon }}</span>
            <span class="goal-label">{{ item.label }}</span>
            <span class="goal-desc">{{ item.desc }}</span>
          </div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="step-actions">
        <el-button v-if="activeStep > 0" @click="activeStep--" size="large" round>上一步</el-button>
        <div class="step-dots">
          <span v-for="i in 4" :key="i" class="dot" :class="{ active: i - 1 === activeStep, done: i - 1 < activeStep }"></span>
        </div>
        <el-button v-if="activeStep < 3" type="primary" size="large" round @click="nextStep">
          下一步 <el-icon><ArrowRight /></el-icon>
        </el-button>
        <el-button v-if="activeStep === 3" type="primary" size="large" round @click="handleSubmit" :loading="submitting" class="finish-btn">
          {{ submitting ? 'AI正在分析中...' : '完成初始化，AI生成画像' }}
          <el-icon v-if="!submitting"><MagicStick /></el-icon>
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Check, ArrowRight, MagicStick } from '@element-plus/icons-vue'
import { getMajorsApi } from '../api/major'
import { saveProfileApi, generatePortraitApi } from '../api/profile'

const router = useRouter()
const activeStep = ref(0)
const submitting = ref(false)
const majors = ref([])

const steps = [
  { title: '基础信息', desc: '学校与专业' },
  { title: '学习情况', desc: '能力评估' },
  { title: '兴趣方向', desc: '个性化推荐' },
  { title: '未来目标', desc: '路线规划' },
]

const skillItems = [
  { key: 'programmingLevel', label: '编程基础', emoji: '💻' },
  { key: 'javaLevel', label: 'Java基础', emoji: '☕' },
  { key: 'pythonLevel', label: 'Python基础', emoji: '🐍' },
  { key: 'cppLevel', label: 'C/C++基础', emoji: '⚡' },
  { key: 'dsLevel', label: '数据结构', emoji: '🔗' },
  { key: 'dbLevel', label: '数据库基础', emoji: '🗄' },
  { key: 'webLevel', label: 'Web开发', emoji: '🌐' },
  { key: 'aiLevel', label: 'AI基础', emoji: '🤖' },
  { key: 'englishLevel', label: '英语水平', emoji: '📖' },
]

const interestOptions = [
  'Web开发', 'AI/机器学习', '大数据', 'Java后端', 'Python',
  '算法/ACM', '前端开发', '后端开发', '数据分析', '计算机视觉',
  'NLP', '网络安全', '云计算', '嵌入式', '游戏开发'
]

const goals = [
  { value: '就业', label: '就业', icon: '💼', desc: '进入企业工作' },
  { value: '考研', label: '考研', icon: '📚', desc: '继续深造' },
  { value: '保研', label: '保研', icon: '⭐', desc: '推免读研' },
  { value: '考公', label: '考公', icon: '🏛', desc: '公务员' },
  { value: '创业', label: '创业', icon: '🚀', desc: '自主创业' },
  { value: '暂未确定', label: '暂未确定', icon: '🤔', desc: '先探索' },
]

const form = reactive({
  school: '', majorId: null, grade: '', gpa: '',
  programmingLevel: 'BEGINNER', javaLevel: 'BEGINNER',
  pythonLevel: 'BEGINNER', cppLevel: 'BEGINNER',
  dsLevel: 'BEGINNER', dbLevel: 'BEGINNER',
  webLevel: 'BEGINNER', aiLevel: 'BEGINNER',
  englishLevel: 'BEGINNER', interests: [], careerGoal: ''
})

const rules1 = {
  school: [{ required: true, message: '请输入学校名称', trigger: 'blur' }],
  majorId: [{ required: true, message: '请选择专业', trigger: 'change' }],
  grade: [{ required: true, message: '请选择年级', trigger: 'change' }]
}

onMounted(async () => {
  try { majors.value = (await getMajorsApi()).data }
  catch (e) {
    majors.value = [
      { id: 1, name: '计算机科学与技术' }, { id: 2, name: '软件工程' },
      { id: 3, name: '人工智能' }, { id: 4, name: '大数据' },
      { id: 5, name: '电子信息工程' },
    ]
  }
})

function nextStep() {
  if (activeStep.value === 0) {
    if (!form.school || !form.majorId || !form.grade) {
      ElMessage.warning('请完善基础信息'); return
    }
  }
  activeStep.value++
}

async function handleSubmit() {
  if (!form.careerGoal) { ElMessage.warning('请选择你的未来目标'); return }
  submitting.value = true
  try {
    await saveProfileApi({
      school: form.school, majorId: form.majorId, grade: form.grade,
      gpa: form.gpa, programmingLevel: form.programmingLevel,
      javaLevel: form.javaLevel, pythonLevel: form.pythonLevel,
      cppLevel: form.cppLevel, dsLevel: form.dsLevel,
      dbLevel: form.dbLevel, webLevel: form.webLevel,
      aiLevel: form.aiLevel, englishLevel: form.englishLevel,
      interests: JSON.stringify(form.interests), careerGoal: form.careerGoal
    })
    await generatePortraitApi()
    ElMessage.success({ message: '🎉 AI画像生成完成！', duration: 3000 })
    setTimeout(() => router.push('/'), 500)
  } catch (e) { ElMessage.error('保存失败，请重试') }
  finally { submitting.value = false }
}
</script>

<style scoped>
.init-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; position: relative; background: #F5F6FA; padding: 40px 20px; }
.init-bg { position: absolute; inset: 0; overflow: hidden; pointer-events: none; }
.bg-shape { position: absolute; border-radius: 50%; opacity: .08; }
.shape-1 { width: 600px; height: 600px; background: var(--primary); top: -20%; right: -15%; }
.shape-2 { width: 400px; height: 400px; background: var(--accent); bottom: -10%; left: -10%; }

.init-card {
  position: relative; z-index: 1; width: 720px;
  background: #fff; border-radius: var(--radius-xl);
  padding: 44px 48px; box-shadow: var(--shadow-xl);
}
.init-header { text-align: center; margin-bottom: 36px; }
.init-badge {
  display: inline-flex; width: 60px; height: 60px; border-radius: 18px;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  align-items: center; justify-content: center; margin-bottom: 16px;
  box-shadow: 0 8px 24px rgba(108,92,231,.3);
}
.init-badge span { color: #fff; font-size: 22px; font-weight: 800; }
.init-header h2 { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
.init-header p { color: var(--text-secondary); font-size: 14px; }

/* 自定义步骤条 */
.steps-container { margin-bottom: 36px; }
.custom-steps { display: flex; position: relative; align-items: flex-start; }
.custom-step { flex: 1; text-align: center; cursor: pointer; position: relative; z-index: 1; }
.step-circle {
  width: 40px; height: 40px; border-radius: 12px; margin: 0 auto 8px;
  display: flex; align-items: center; justify-content: center;
  background: #F0F1F5; color: var(--text-muted); font-weight: 700;
  font-size: 15px; transition: all var(--transition);
}
.custom-step.active .step-circle { background: var(--primary); color: #fff; box-shadow: 0 4px 14px rgba(108,92,231,.3); }
.custom-step.done .step-circle { background: var(--success); color: #fff; }
.step-info { font-size: 13px; }
.step-title { display: block; font-weight: 600; color: var(--text-secondary); }
.step-desc { display: block; font-size: 11px; color: var(--text-muted); margin-top: 2px; }
.custom-step.active .step-title { color: var(--primary); }
.custom-step.done .step-title { color: var(--success); }

.step-line {
  position: absolute; top: 20px; left: 10%; height: 3px;
  background: var(--success); border-radius: 2px; transition: width .4s ease;
  z-index: 0;
}

.step-body { min-height: 280px; }

/* 年级卡片 */
.grade-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
.grade-card {
  padding: 16px 8px; border-radius: var(--radius-sm); text-align: center;
  border: 2px solid var(--border); cursor: pointer; transition: all var(--transition);
  display: flex; flex-direction: column; align-items: center; gap: 6px;
}
.grade-card:hover { border-color: var(--primary-light); }
.grade-card.selected { border-color: var(--primary); background: rgba(108,92,231,.04); }
.grade-emoji { font-size: 28px; }

.level-grid { display: flex; flex-direction: column; gap: 16px; }
.level-item { display: flex; align-items: center; justify-content: space-between; }
.level-label { width: 120px; font-weight: 500; font-size: 14px; flex-shrink: 0; }
.level-radios { flex: 1; }

.step-tip { color: var(--text-secondary); font-size: 14px; margin-bottom: 20px; }
.interest-grid { display: flex; flex-wrap: wrap; gap: 10px; }
.interest-chip { border-radius: 10px !important; padding: 8px 14px !important; }

/* 目标卡片 */
.goal-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
.goal-card {
  padding: 20px 12px; border-radius: var(--radius); text-align: center;
  border: 2px solid var(--border); cursor: pointer; transition: all var(--transition);
}
.goal-card:hover { border-color: var(--primary-light); transform: translateY(-2px); }
.goal-card.selected {
  border-color: var(--primary); background: rgba(108,92,231,.06);
  box-shadow: 0 4px 16px rgba(108,92,231,.12);
}
.goal-emoji { display: block; font-size: 32px; margin-bottom: 6px; }
.goal-label { display: block; font-weight: 600; font-size: 14px; }
.goal-desc { display: block; font-size: 11px; color: var(--text-muted); margin-top: 4px; }

.step-actions { display: flex; align-items: center; justify-content: space-between; margin-top: 36px; }
.step-dots { display: flex; gap: 8px; }
.dot { width: 8px; height: 8px; border-radius: 50%; background: var(--border); transition: all var(--transition); }
.dot.active { background: var(--primary); width: 10px; height: 10px; }
.dot.done { background: var(--success); }
.finish-btn { background: linear-gradient(135deg, var(--primary), #5A4BD1) !important; }

.init-form :deep(.el-form-item__label) { font-weight: 500; color: var(--text-secondary); }
</style>
