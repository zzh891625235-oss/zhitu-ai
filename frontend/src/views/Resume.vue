<template>
  <div class="resume-page">
    <div class="page-hero">
      <h1><el-icon><Document /></el-icon> AI简历</h1>
      <p>基于你的成长档案，AI自动生成专业简历</p>
    </div>

    <div class="resume-actions" v-if="!resume">
      <el-button type="primary" size="large" round @click="handleGenerate" :loading="genLoading">
        {{ genLoading ? 'AI分析中...' : '✨ AI生成我的简历' }}
      </el-button>
    </div>

    <!-- 简历预览 -->
    <div v-if="resume" class="resume-preview">
      <div class="resume-toolbar">
        <el-button type="primary" size="small" round @click="handleGenerate" :loading="genLoading">
          🔄 重新生成
        </el-button>
        <el-button size="small" round @click="handlePrint">🖨 打印/导出PDF</el-button>
      </div>

      <!-- A4简历纸 -->
      <div class="resume-paper" id="resumePaper">
        <div class="paper-header">
          <h1>{{ resume.name }}</h1>
          <div class="paper-contact">
            <span>{{ resume.education?.school }}</span>
            <span>{{ resume.education?.major }}</span>
            <span>{{ resume.education?.grade }}</span>
          </div>
          <div class="paper-target">
            <el-tag type="primary" effect="dark" round>🎯 {{ resume.targetPosition }}</el-tag>
          </div>
        </div>

        <div class="paper-section" v-if="resume.advantages">
          <h3>个人优势</h3>
          <p>{{ resume.advantages }}</p>
        </div>

        <div class="paper-section" v-if="resume.skills?.length">
          <h3>专业技能</h3>
          <div class="skill-tags">
            <span class="skill-tag" v-for="s in resume.skills" :key="s">{{ s }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.courses?.length">
          <h3>核心课程</h3>
          <div class="skill-tags">
            <span class="skill-tag course" v-for="c in resume.courses" :key="c">{{ c }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.projects?.length">
          <h3>项目经历</h3>
          <div class="paper-item" v-for="(p, i) in resume.projects" :key="i">
            <div class="item-dot"></div>
            <span>{{ p }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.competitions?.length">
          <h3>竞赛经历</h3>
          <div class="paper-item" v-for="(c, i) in resume.competitions" :key="i">
            <div class="item-dot comp"></div>
            <span>{{ c }}</span>
          </div>
        </div>

        <div class="paper-section" v-if="resume.certificates?.length">
          <h3>证书</h3>
          <div class="paper-item" v-for="(c, i) in resume.certificates" :key="i">
            <div class="item-dot cert"></div>
            <span>{{ c }}</span>
          </div>
        </div>
      </div>
    </div>

    <el-empty v-if="!resume && !genLoading" description="AI会根据你的学习记录、项目经历和竞赛成绩自动生成简历" :image-size="100" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Document } from '@element-plus/icons-vue'
import { generateResumeApi, getResumeApi } from '../api/resume'
import { ElMessage } from 'element-plus'

const resume = ref(null)
const genLoading = ref(false)

onMounted(async () => {
  try { resume.value = (await getResumeApi()).data } catch (e) {}
})

async function handleGenerate() {
  genLoading.value = true
  try {
    resume.value = (await generateResumeApi()).data
    ElMessage.success('AI简历生成完成！')
  } catch (e) { ElMessage.error('请先完善成长档案（学习记录、项目、竞赛等）') }
  finally { genLoading.value = false }
}

function handlePrint() { window.print() }
</script>

<style scoped>
.resume-page { max-width: 900px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 24px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.resume-actions { text-align: center; margin-bottom: 32px; }

.resume-toolbar { display: flex; justify-content: center; gap: 12px; margin-bottom: 28px; }

/* A4纸 */
.resume-paper {
  max-width: 800px; margin: 0 auto; background: #fff;
  padding: 48px 52px; border-radius: 4px;
  box-shadow: 0 4px 30px rgba(0,0,0,.1);
}
.paper-header { text-align: center; border-bottom: 2px solid var(--primary); padding-bottom: 20px; margin-bottom: 24px; }
.paper-header h1 { font-size: 26px; font-weight: 700; letter-spacing: 2px; }
.paper-contact { display: flex; justify-content: center; gap: 20px; margin-top: 10px; font-size: 14px; color: var(--text-secondary); }
.paper-target { margin-top: 14px; }

.paper-section { margin-bottom: 22px; }
.paper-section h3 {
  font-size: 16px; font-weight: 700; color: var(--primary);
  border-left: 3px solid var(--primary); padding-left: 10px; margin-bottom: 12px;
}
.paper-section p { font-size: 14px; color: var(--text-secondary); line-height: 1.8; }

.skill-tags { display: flex; flex-wrap: wrap; gap: 8px; }
.skill-tag {
  padding: 4px 14px; border-radius: 20px; background: rgba(108,92,231,.08);
  font-size: 13px; color: var(--primary); font-weight: 500;
}
.skill-tag.course { background: rgba(0,206,201,.08); color: #008F8B; }

.paper-item { display: flex; align-items: center; gap: 10px; font-size: 14px; color: var(--text-secondary); margin-bottom: 8px; }
.item-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--primary); flex-shrink: 0; }
.item-dot.comp { background: #FECA57; }
.item-dot.cert { background: #00D2A0; }
</style>
