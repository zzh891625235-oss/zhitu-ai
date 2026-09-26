<template>
  <div class="init-page">
    <div class="init-container">
      <div class="init-header">
        <span class="init-badge">Z</span>
        <h2>AI成长档案初始化</h2>
        <p>帮助AI更好地了解你，生成专属成长规划</p>
      </div>

      <el-steps :active="activeStep" finish-status="success" align-center style="margin-bottom:40px">
        <el-step title="基础信息" />
        <el-step title="学习情况" />
        <el-step title="兴趣方向" />
        <el-step title="未来目标" />
      </el-steps>

      <!-- Step 1: 基础信息 -->
      <el-form v-if="activeStep === 0" ref="form1" :model="form" :rules="rules1" label-width="100px">
        <el-form-item label="学校" prop="school">
          <el-input v-model="form.school" placeholder="请输入学校名称" />
        </el-form-item>
        <el-form-item label="专业" prop="majorId">
          <el-select v-model="form.majorId" placeholder="请选择专业" style="width:100%">
            <el-option v-for="m in majors" :key="m.id" :label="m.name" :value="m.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-select v-model="form.grade" placeholder="请选择年级" style="width:100%">
            <el-option label="大一" value="大一" />
            <el-option label="大二" value="大二" />
            <el-option label="大三" value="大三" />
            <el-option label="大四" value="大四" />
          </el-select>
        </el-form-item>
        <el-form-item label="当前成绩">
          <el-select v-model="form.gpa" placeholder="请选择" style="width:100%">
            <el-option label="优秀 (前20%)" value="优秀" />
            <el-option label="良好 (前50%)" value="良好" />
            <el-option label="中等" value="中等" />
            <el-option label="待提升" value="待提升" />
          </el-select>
        </el-form-item>
      </el-form>

      <!-- Step 2: 学习情况 -->
      <div v-if="activeStep === 1" class="step-content">
        <div class="level-grid">
          <div class="level-item" v-for="item in skillItems" :key="item.key">
            <label>{{ item.label }}</label>
            <el-radio-group v-model="form[item.key]">
              <el-radio-button value="BEGINNER">零基础</el-radio-button>
              <el-radio-button value="BASIC">入门</el-radio-button>
              <el-radio-button value="INTERMEDIATE">中等</el-radio-button>
              <el-radio-button value="ADVANCED">熟练</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </div>

      <!-- Step 3: 兴趣方向 -->
      <div v-if="activeStep === 2" class="step-content">
        <p class="step-tip">选择你感兴趣的方向（可多选）</p>
        <el-checkbox-group v-model="form.interests" class="interest-grid">
          <el-checkbox v-for="item in interestOptions" :key="item" :label="item" :value="item" border />
        </el-checkbox-group>
      </div>

      <!-- Step 4: 未来目标 -->
      <div v-if="activeStep === 3" class="step-content">
        <p class="step-tip">选择你的未来目标</p>
        <el-radio-group v-model="form.careerGoal" class="goal-grid">
          <el-radio v-for="item in goals" :key="item.value" :value="item.value" border>
            <div class="goal-item">
              <span class="goal-icon">{{ item.icon }}</span>
              <span>{{ item.label }}</span>
            </div>
          </el-radio>
        </el-radio-group>
      </div>

      <!-- 操作按钮 -->
      <div class="step-actions">
        <el-button v-if="activeStep > 0" @click="activeStep--">上一步</el-button>
        <el-button v-if="activeStep < 3" type="primary" @click="nextStep">下一步</el-button>
        <el-button v-if="activeStep === 3" type="primary" @click="handleSubmit" :loading="submitting">
          {{ submitting ? 'AI正在分析你的数据...' : '完成初始化，AI生成画像' }}
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getMajorsApi } from '../api/major'
import { saveProfileApi, generatePortraitApi } from '../api/profile'

const router = useRouter()
const activeStep = ref(0)
const submitting = ref(false)
const majors = ref([])

const skillItems = [
  { key: 'programmingLevel', label: '编程基础' },
  { key: 'javaLevel', label: 'Java基础' },
  { key: 'pythonLevel', label: 'Python基础' },
  { key: 'cppLevel', label: 'C/C++基础' },
  { key: 'dsLevel', label: '数据结构基础' },
  { key: 'dbLevel', label: '数据库基础' },
  { key: 'webLevel', label: 'Web开发基础' },
  { key: 'aiLevel', label: 'AI基础' },
  { key: 'englishLevel', label: '英语水平' },
]

const interestOptions = [
  'Web开发', 'AI/机器学习', '大数据', 'Java后端', 'Python',
  '算法/ACM', '前端开发', '后端开发', '数据分析', '计算机视觉',
  'NLP', '网络安全', '云计算', '嵌入式', '游戏开发'
]

const goals = [
  { value: '就业', label: '就业', icon: '💼' },
  { value: '考研', label: '考研', icon: '📚' },
  { value: '保研', label: '保研', icon: '⭐' },
  { value: '考公', label: '考公', icon: '🏛' },
  { value: '创业', label: '创业', icon: '🚀' },
  { value: '暂未确定', label: '暂未确定', icon: '🤔' },
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
  school: [{ required: true, message: '请输入学校' }],
  majorId: [{ required: true, message: '请选择专业' }],
  grade: [{ required: true, message: '请选择年级' }]
}

onMounted(async () => {
  try {
    const res = await getMajorsApi()
    majors.value = res.data
  } catch (e) {
    // 降级使用默认数据
    majors.value = [
      { id: 1, name: '计算机科学与技术' },
      { id: 2, name: '软件工程' },
      { id: 3, name: '人工智能' },
      { id: 4, name: '大数据' },
      { id: 5, name: '电子信息工程' },
    ]
  }
})

function nextStep() {
  if (activeStep.value === 0) {
    if (!form.school || !form.majorId || !form.grade) {
      ElMessage.warning('请完善基础信息')
      return
    }
  }
  activeStep.value++
}

async function handleSubmit() {
  if (!form.careerGoal) {
    ElMessage.warning('请选择你的未来目标')
    return
  }
  submitting.value = true
  try {
    // 1. 保存档案
    await saveProfileApi({
      school: form.school,
      majorId: form.majorId,
      grade: form.grade,
      gpa: form.gpa,
      programmingLevel: form.programmingLevel,
      javaLevel: form.javaLevel,
      pythonLevel: form.pythonLevel,
      cppLevel: form.cppLevel,
      dsLevel: form.dsLevel,
      dbLevel: form.dbLevel,
      webLevel: form.webLevel,
      aiLevel: form.aiLevel,
      englishLevel: form.englishLevel,
      interests: JSON.stringify(form.interests),
      careerGoal: form.careerGoal
    })
    ElMessage.success('档案保存成功')
    // 2. AI生成画像
    await generatePortraitApi()
    ElMessage.success('AI画像生成完成！')
    // 3. 跳转首页
    router.push('/')
  } catch (e) {
    ElMessage.error('保存失败，请重试')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.init-page {
  min-height: 100vh; background: #f0f2f5;
  display: flex; align-items: center; justify-content: center;
  padding: 40px 20px;
}
.init-container {
  width: 700px; padding: 48px 40px;
  background: #fff; border-radius: 16px;
  box-shadow: 0 4px 24px rgba(0,0,0,.08);
}
.init-header { text-align: center; margin-bottom: 36px; }
.init-badge {
  display: inline-flex; width: 56px; height: 56px; border-radius: 16px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  align-items: center; justify-content: center;
  color: #fff; font-size: 28px; font-weight: bold; margin-bottom: 16px;
}
.init-header h2 { font-size: 22px; margin-bottom: 8px; }
.init-header p { color: #999; font-size: 14px; }
.step-content { min-height: 300px; }
.step-tip { color: #999; font-size: 14px; margin-bottom: 20px; }
.level-grid { display: flex; flex-direction: column; gap: 20px; }
.level-item label { display: block; font-weight: 500; margin-bottom: 8px; font-size: 14px; }
.interest-grid { display: flex; flex-wrap: wrap; gap: 10px; }
.goal-grid { display: flex; flex-wrap: wrap; gap: 16px; }
.goal-item { display: flex; flex-direction: column; align-items: center; gap: 4px; padding: 8px; }
.goal-icon { font-size: 28px; }
.step-actions { margin-top: 32px; display: flex; justify-content: center; gap: 16px; }
</style>
