<template>
  <div class="settings-page">
    <div class="page-hero">
      <h1>API 设置</h1>
      <p>配置你自己的 AI Key，让画像、规划、助手真正跑起来</p>
    </div>

    <el-card shadow="never" class="settings-card">
      <div class="provider-tabs">
        <div class="p-tab" :class="{active:provider==='deepseek'}" @click="switchProvider('deepseek')">
          <span class="pt-icon">🔮</span>
          <div><b>DeepSeek</b><small>deepseek-chat</small></div>
        </div>
        <div class="p-tab" :class="{active:provider==='openai'}" @click="switchProvider('openai')">
          <span class="pt-icon">🤖</span>
          <div><b>OpenAI</b><small>gpt-4o / gpt-3.5</small></div>
        </div>
        <div class="p-tab" :class="{active:provider==='qwen'}" @click="switchProvider('qwen')">
          <span class="pt-icon">☁️</span>
          <div><b>通义千问</b><small>qwen-turbo / plus</small></div>
        </div>
        <div class="p-tab" :class="{active:provider==='custom'}" @click="switchProvider('custom')">
          <span class="pt-icon">⚙️</span>
          <div><b>自定义</b><small>兼容OpenAI格式</small></div>
        </div>
      </div>

      <el-form label-width="100px" class="settings-form">
        <el-form-item label="API Key">
          <el-input v-model="form.apiKey" type="password" show-password
            placeholder="sk-xxxxxxxxxxxxxxxx" size="large" />
          <div class="form-tip">你的 Key 仅保存在你自己的账号下</div>
        </el-form-item>
        <el-form-item label="API 地址">
          <el-input v-model="form.apiUrl" size="large" />
        </el-form-item>
        <el-form-item label="模型名称">
          <el-input v-model="form.model" size="large" />
        </el-form-item>
      </el-form>

      <div class="settings-actions">
        <el-button size="large" @click="handleTest" :loading="testing">
          <el-icon><Connection /></el-icon> 测试连接
        </el-button>
        <el-button type="primary" size="large" @click="handleSave" :loading="saving">
          保存设置
        </el-button>
      </div>

      <div v-if="testResult" class="test-result" :class="testResult.status">
        <el-icon :size="20"><component :is="testResult.status==='ok'?'SuccessFilled':'WarningFilled'" /></el-icon>
        <span>{{ testResult.message }}</span>
      </div>

      <div class="status-badge" :class="{ active: hasKey }">
        <span class="sb-dot"></span>
        {{ hasKey ? '已配置个人 API Key' : '未配置 — 当前使用系统离线模式' }}
      </div>
    </el-card>

    <div class="info-card">
      <h3>如何获取 API Key？</h3>
      <div class="info-steps">
        <div class="info-step">
          <span class="is-num">1</span>
          <div>
            <b>DeepSeek</b>
            <p>访问 <a href="https://platform.deepseek.com" target="_blank">platform.deepseek.com</a> 注册，在「API Keys」页面创建。新用户通常有免费额度。</p>
          </div>
        </div>
        <div class="info-step">
          <span class="is-num">2</span>
          <div>
            <b>通义千问</b>
            <p>访问 <a href="https://dashscope.console.aliyun.com" target="_blank">阿里云灵积</a>，开通模型服务获取 Key。</p>
          </div>
        </div>
        <div class="info-step">
          <span class="is-num">3</span>
          <div>
            <b>配置到智途</b>
            <p>将 Key 粘贴到上方输入框，点击测试连接，通过后保存即可。</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Connection, SuccessFilled, WarningFilled } from '@element-plus/icons-vue'
import { getSettingsApi, saveSettingsApi, testConnectionApi } from '../api/settings'
import { ElMessage } from 'element-plus'

const provider = ref('deepseek')
const hasKey = ref(false)
const saving = ref(false)
const testing = ref(false)
const testResult = ref(null)

const form = reactive({ apiKey: '', apiUrl: 'https://api.deepseek.com/v1', model: 'deepseek-chat' })

const providers = {
  deepseek: { url: 'https://api.deepseek.com/v1', model: 'deepseek-chat' },
  openai: { url: 'https://api.openai.com/v1', model: 'gpt-4o' },
  qwen: { url: 'https://dashscope.aliyuncs.com/compatible-mode/v1', model: 'qwen-plus' },
  custom: { url: '', model: '' },
}

function switchProvider(key) {
  provider.value = key
  form.apiUrl = providers[key].url
  form.model = providers[key].model
}

onMounted(async () => {
  try {
    const res = await getSettingsApi()
    if (res.data.hasKey) {
      hasKey.value = true
      form.apiKey = res.data.apiKey
      form.apiUrl = res.data.apiUrl || form.apiUrl
      form.model = res.data.model || form.model
    }
  } catch (e) {}
})

async function handleSave() {
  saving.value = true
  try {
    await saveSettingsApi({ apiKey: form.apiKey, apiUrl: form.apiUrl, model: form.model })
    hasKey.value = true
    ElMessage.success('设置已保存')
  } catch (e) {} finally { saving.value = false }
}

async function handleTest() {
  if (!form.apiKey) { ElMessage.warning('请先填写 API Key'); return }
  testing.value = true; testResult.value = null
  try {
    await saveSettingsApi({ apiKey: form.apiKey, apiUrl: form.apiUrl, model: form.model })
    const res = await testConnectionApi()
    testResult.value = res.data
  } catch (e) {} finally { testing.value = false }
}
</script>

<style scoped>
.settings-page { max-width: 680px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; color: var(--slate-900); }
.page-hero p { color: var(--slate-500); margin-top: 6px; font-size: 14px; }

.settings-card { border-radius: var(--radius-lg); margin-bottom: 24px; }

.provider-tabs { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 28px; }
.p-tab {
  padding: 12px 10px; border-radius: var(--radius-sm);
  border: 2px solid var(--border); cursor: pointer;
  display: flex; align-items: center; gap: 10px; transition: all .2s;
}
.p-tab:hover { border-color: var(--ocean-light); }
.p-tab.active { border-color: var(--signal); background: var(--ocean-pale); }
.pt-icon { font-size: 24px; }
.p-tab b { display: block; font-size: 13px; color: var(--slate-900); }
.p-tab small { display: block; font-size: 11px; color: var(--slate-400); }

.form-tip { font-size: 12px; color: var(--slate-400); margin-top: 4px; }
.settings-actions { display: flex; gap: 12px; justify-content: center; margin-bottom: 16px; }
.test-result {
  display: flex; align-items: center; gap: 8px;
  padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px;
}
.test-result.ok { background: var(--teal-pale); color: #66BB6A; }
.test-result.error { background: var(--rose-pale); color: #EF5350; }

.status-badge {
  display: flex; align-items: center; gap: 8px;
  padding: 12px 16px; border-radius: 8px; font-size: 13px;
  background: var(--amber-pale); color: #F5C97A;
}
.status-badge.active { background: var(--teal-pale); color: #66BB6A; }
.sb-dot { width: 8px; height: 8px; border-radius: 50%; background: #F5A524; }
.status-badge.active .sb-dot { background: #66BB6A; }

.info-card { background:var(--glass); border-radius: var(--radius-lg); border: 1px solid var(--border); padding: 24px; }
.info-card h3 { font-size: 16px; color: var(--slate-900); margin-bottom: 16px; }
.info-steps { display: flex; flex-direction: column; gap: 14px; }
.info-step { display: flex; gap: 12px; font-size: 14px; }
.is-num {
  width: 28px; height: 28px; border-radius: 8px;
  background: var(--ocean-pale); color: var(--signal);
  display: flex; align-items: center; justify-content: center;
  font-weight: 700; font-size: 13px; flex-shrink: 0;
}
.info-step b { display: block; margin-bottom: 2px; color: var(--slate-900); }
.info-step p { color: var(--slate-500); font-size: 13px; line-height: 1.6; }
.info-step a { color: var(--signal); }

@media (max-width:820px) {
  .provider-tabs { grid-template-columns: repeat(2, 1fr); }
  .page-hero h1 { font-size: 22px; }
  .settings-actions { flex-direction: column; }
  .settings-actions .el-button { width: 100%; }
}
</style>
