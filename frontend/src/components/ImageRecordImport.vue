<template>
  <div class="image-import">
    <div class="import-head">
      <div>
        <div class="import-title">
          <el-icon><Camera /></el-icon> 证书 / 奖状，拍照自动录入
        </div>
        <div class="import-sub">
          视觉模型读取图片并填好字段，<b>入库前请务必核对</b>；识别不出时也能手动补录。
        </div>
      </div>
      <div class="import-actions">
        <input ref="fileRef" type="file" accept="image/*" hidden @change="handleFile" />
        <el-button size="small" :loading="parsing" @click="pick">
          <el-icon><Upload /></el-icon>&nbsp;选择图片
        </el-button>
      </div>
    </div>

    <!-- 识别失败 / 不支持时的提示，引导手动填写，不假装成功 -->
    <div class="import-note warn" v-if="notice">
      <el-icon><Warning /></el-icon> {{ notice }}
    </div>

    <!-- 识别结果表单 -->
    <div class="import-form" v-if="form">
      <div class="form-row">
        <el-select v-model="form.recordType" size="small" style="width:130px">
          <el-option label="项目经历" value="PROJECT" />
          <el-option label="竞赛获奖" value="COMPETITION" />
          <el-option label="证书" value="CERTIFICATE" />
          <el-option label="实习经历" value="INTERNSHIP" />
          <el-option label="荣誉奖项" value="HONOR" />
        </el-select>
        <el-input v-model="form.title" size="small" placeholder="名称" />
      </div>
      <div class="form-row">
        <el-date-picker v-model="form.date" type="date" size="small" value-format="YYYY-MM-DD"
          placeholder="日期" style="width:150px" />
        <el-input v-model="form.description" size="small" :rows="2" type="textarea"
          placeholder="你在其中做了什么（会原样写进简历，建议量化）" />
      </div>
      <div class="form-row actions">
        <span class="conf" v-if="confidence">
          识别置信度 {{ confidence }}
          <el-tag size="small" :type="lowConfidence ? 'warning' : 'success'" effect="plain">
            {{ lowConfidence ? '请重点核对' : '较高' }}
          </el-tag>
        </span>
        <el-button size="small" @click="cancel">取消</el-button>
        <el-button size="small" type="primary" :loading="saving" @click="save">确认入库</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { Camera, Upload, Warning } from '@element-plus/icons-vue'
import { parseImageApi, commitImageRecordApi } from '../api/agent'
import { ElMessage } from 'element-plus'

/**
 * 图片识别录入成长档案。
 *
 * 设计上刻意留了两道「人工确认」：
 *  1. 模型抽出的字段一定先摊开给用户改，不在后台静默写库；
 *  2. 置信度低于 0.6 时给出醒目提示。
 * 简历是要拿去求职的，一条张冠李戴的获奖记录代价远高于多敲三十秒键盘。
 */
const emit = defineEmits(['saved'])

const fileRef = ref(null)
const parsing = ref(false)
const saving = ref(false)
const form = ref(null)
const notice = ref('')

const confidence = computed(() => (form.value && form.value.confidence ? Math.round(form.value.confidence * 100) + '%' : ''))
const lowConfidence = computed(() => (form.value && form.value.confidence || 0) < 0.6)

function pick() {
  fileRef.value && fileRef.value.click()
}

async function handleFile(e) {
  const file = e.target.files && e.target.files[0]
  e.target.value = ''
  if (!file) return
  if (!file.type.startsWith('image/')) {
    notice.value = '请选择图片文件'
    return
  }
  if (file.size > 5 * 1024 * 1024) {
    notice.value = '图片不能超过 5MB'
    return
  }

  parsing.value = true
  notice.value = ''
  try {
    const res = await parseImageApi(file)
    const data = res.data || {}
    if (data.success === false) {
      notice.value = data.reason || '没能识别出内容，可直接在这里手动填写'
      openManualForm(data.raw ? String(data.raw).slice(0, 80) : '')
      return
    }
    const rec = data.record || {}
    form.value = reactive({
      recordType: pickType(rec.recordType),
      title: rec.title || '',
      date: rec.date || new Date().toISOString().split('T')[0],
      description: rec.description || '',
      confidence: rec.confidence || 0
    })
    notice.value = ''
  } catch (err) {
    notice.value = (err && err.message) || '识别服务暂时不可用，可手动填写'
    openManualForm('')
  } finally {
    parsing.value = false
  }
}

/** 识别失败时不留白——把表单摆出来让用户自己填，入口不白点 */
function openManualForm(raw) {
  form.value = reactive({
    recordType: 'COMPETITION',
    title: raw ? `未识别-${raw}` : '',
    date: new Date().toISOString().split('T')[0],
    description: '',
    confidence: 0
  })
}

function pickType(t) {
  return ['PROJECT', 'COMPETITION', 'CERTIFICATE', 'INTERNSHIP', 'HONOR'].indexOf(t) >= 0 ? t : 'COMPETITION'
}

function cancel() {
  form.value = null
  notice.value = ''
}

async function save() {
  if (!form.value || !form.value.title.trim()) {
    ElMessage.warning('请填写名称')
    return
  }
  saving.value = true
  try {
    await commitImageRecordApi({
      recordType: form.value.recordType,
      title: form.value.title,
      date: form.value.date,
      description: form.value.description
    })
    ElMessage.success('已加入成长档案')
    emit('saved')
    cancel()
  } catch (e) {
    ElMessage.error('保存失败，请稍后重试')
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.image-import {
  border: 1px dashed var(--border); border-radius: 10px; padding: 14px 16px;
  background: rgba(255, 255, 255, .02); margin-bottom: 18px;
}
.import-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; }
.import-title { font-size: 13.5px; font-weight: 600; display: flex; align-items: center; gap: 6px; }
.import-sub { font-size: 11.5px; color: var(--text-muted); margin-top: 4px; line-height: 1.5; }
.import-sub b { color: var(--primary); }
.import-actions { flex-shrink: 0; }

.import-note {
  margin-top: 10px; font-size: 12px; display: flex; align-items: center; gap: 6px;
  padding: 7px 10px; border-radius: 8px;
}
.import-note.warn { background: rgba(245, 165, 36, .1); color: #F5C97A; }

.import-form { margin-top: 12px; display: flex; flex-direction: column; gap: 9px; }
.form-row { display: flex; gap: 9px; align-items: flex-start; }
.form-row :deep(.el-input) { flex: 1; }
.form-row.actions { justify-content: flex-end; align-items: center; }
.conf { margin-right: auto; font-size: 11.5px; color: var(--text-muted); display: inline-flex; gap: 6px; align-items: center; }

@media (max-width: 640px) {
  .form-row { flex-direction: column; }
  .form-row :deep(.el-date-picker) { width: 100% !important; }
  .import-head { flex-direction: column; }
}
</style>
