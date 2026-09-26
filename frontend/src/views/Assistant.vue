<template>
  <div class="assistant-page">
    <div class="page-hero">
      <h1><el-icon><ChatDotRound /></el-icon> AI成长助手</h1>
      <p>学习答疑 · 职业规划 · 竞赛咨询 · 成长建议</p>
    </div>

    <div class="assistant-layout">
      <!-- 左侧模式选择 -->
      <div class="mode-panel">
        <div class="mode-item" v-for="m in modes" :key="m.id"
          :class="{ active: currentMode === m.id }"
          @click="switchMode(m.id)">
          <span class="mode-icon">{{ m.icon }}</span>
          <div>
            <div class="mode-name">{{ m.name }}</div>
            <div class="mode-desc">{{ m.desc }}</div>
          </div>
        </div>
      </div>

      <!-- 右侧聊天区 -->
      <div class="chat-panel">
        <div class="chat-header">
          <span>{{ currentModeObj.icon }} {{ currentModeObj.name }}</span>
          <el-tag size="small" effect="plain">{{ currentModeObj.desc }}</el-tag>
        </div>

        <div class="chat-messages" ref="msgContainer">
          <div v-if="messages.length === 0" class="chat-welcome">
            <div class="welcome-icon">{{ currentModeObj.icon }}</div>
            <p>{{ currentModeObj.welcome }}</p>
            <div class="quick-qs">
              <div class="quick-q" v-for="q in currentModeObj.quickQuestions" :key="q"
                @click="sendMessage(q)">{{ q }}</div>
            </div>
          </div>

          <div v-for="(msg, idx) in messages" :key="idx" :class="['msg-row', msg.role]">
            <div class="msg-avatar">
              <span v-if="msg.role === 'user'">我</span>
              <span v-else>AI</span>
            </div>
            <div class="msg-bubble" :class="msg.role">
              <div class="msg-text" v-html="formatMsg(msg.content)"></div>
              <div class="msg-time">{{ msg.time }}</div>
            </div>
          </div>

          <div v-if="loading" class="msg-row ai">
            <div class="msg-avatar"><span>AI</span></div>
            <div class="msg-bubble ai typing">
              <span class="typing-dot"></span>
              <span class="typing-dot"></span>
              <span class="typing-dot"></span>
            </div>
          </div>
        </div>

        <div class="chat-input-area">
          <el-input v-model="inputText" placeholder="输入你的问题..." size="large"
            @keyup.enter="sendMessage()" :disabled="loading">
            <template #append>
              <el-button type="primary" @click="sendMessage()" :loading="loading" :icon="Promotion" />
            </template>
          </el-input>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from 'vue'
import { ChatDotRound, Promotion } from '@element-plus/icons-vue'
import { chatApi, getHistoryApi } from '../api/ai'
import { ElMessage } from 'element-plus'

const currentMode = ref('GENERAL')
const messages = ref([])
const inputText = ref('')
const loading = ref(false)
const msgContainer = ref(null)

const modes = [
  { id: 'GENERAL', icon: '🤖', name: '通用问答', desc: '学习成长咨询',
    welcome: '你好！我是智途AI助手。有任何学习、成长、规划的问题，尽管问我！',
    quickQuestions: ['我的专业适合参加什么竞赛？', '如何制定学习计划？', '大二应该重点学什么？'] },
  { id: 'LEARNING', icon: '📖', name: '学习导师', desc: '概念解释+答疑',
    welcome: '我是你的AI学习导师。遇到不懂的知识点，我会用通俗的方式帮你理解！',
    quickQuestions: ['什么是Java多态？举个例子', '链表和数组有什么区别？', '解释一下TCP三次握手'] },
  { id: 'CAREER', icon: '💼', name: '职业规划', desc: '就业发展方向',
    welcome: '我是你的职业规划顾问。帮你分析发展方向、准备面试、规划未来。',
    quickQuestions: ['计算机专业有哪些就业方向？', '如何准备大厂秋招？', '考研还是就业？'] },
  { id: 'COMPETITION', icon: '🏆', name: '竞赛咨询', desc: '比赛策略+准备',
    welcome: '我是竞赛辅导老师。帮你选择适合的比赛、制定备赛策略！',
    quickQuestions: ['蓝桥杯怎么准备？', 'ACM和蓝桥杯有什么区别？', '数学建模竞赛需要什么基础？'] },
]

const currentModeObj = computed(() => modes.find(m => m.id === currentMode.value))

function formatMsg(text) {
  if (!text) return ''
  return text.replace(/\n/g, '<br>')
}

function scrollBottom() {
  nextTick(() => {
    if (msgContainer.value) msgContainer.value.scrollTop = msgContainer.value.scrollHeight
  })
}

async function switchMode(id) {
  currentMode.value = id
  messages.value = []
  try {
    const res = await getHistoryApi(id)
    const history = res.data || []
    history.reverse().forEach(h => {
      messages.value.push({ role: 'user', content: h.question, time: h.createdAt?.substring(11,16) || '' })
      messages.value.push({ role: 'ai', content: h.answer, time: h.createdAt?.substring(11,16) || '' })
    })
  } catch (e) {}
  scrollBottom()
}

async function sendMessage(q) {
  const text = q || inputText.value.trim()
  if (!text || loading.value) return
  messages.value.push({ role: 'user', content: text, time: new Date().toLocaleTimeString('zh-CN', {hour:'2-digit',minute:'2-digit'}) })
  inputText.value = ''
  loading.value = true
  scrollBottom()
  try {
    const res = await chatApi(text, currentMode.value)
    messages.value.push({ role: 'ai', content: res.data.answer, time: new Date().toLocaleTimeString('zh-CN', {hour:'2-digit',minute:'2-digit'}) })
  } catch (e) {
    messages.value.push({ role: 'ai', content: '抱歉，AI服务暂时不可用。请稍后重试。', time: '' })
  } finally { loading.value = false; scrollBottom() }
}
</script>

<style scoped>
.assistant-page { max-width: 1200px; margin: 0 auto; }
.page-hero { text-align: center; padding: 28px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.assistant-layout { display: grid; grid-template-columns: 240px 1fr; gap: 20px; margin-bottom: 40px; }

.mode-panel { display: flex; flex-direction: column; gap: 8px; }
.mode-item {
  padding: 14px 16px; border-radius: var(--radius-sm); cursor: pointer;
  display: flex; align-items: center; gap: 12px; transition: all .2s;
  border: 1.5px solid transparent;
}
.mode-item:hover { background: #F5F6FA; }
.mode-item.active { background: rgba(108,92,231,.06); border-color: var(--primary); }
.mode-icon { font-size: 22px; }
.mode-name { font-size: 14px; font-weight: 600; }
.mode-desc { font-size: 11px; color: var(--text-muted); }

.chat-panel { background: #fff; border-radius: var(--radius-lg); border: 1px solid var(--border); display: flex; flex-direction: column; height: 640px; }
.chat-header { padding: 16px 20px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; font-size: 15px; font-weight: 600; }

.chat-messages { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 16px; }
.chat-welcome { text-align: center; padding: 40px 0; }
.welcome-icon { font-size: 48px; margin-bottom: 12px; }
.chat-welcome p { color: var(--text-secondary); margin-bottom: 20px; }
.quick-qs { display: flex; flex-wrap: wrap; justify-content: center; gap: 8px; }
.quick-q {
  padding: 8px 16px; background: #F5F6FA; border-radius: 20px;
  cursor: pointer; font-size: 13px; color: var(--primary); transition: all .2s;
}
.quick-q:hover { background: rgba(108,92,231,.1); }

.msg-row { display: flex; gap: 10px; }
.msg-row.user { flex-direction: row-reverse; }
.msg-avatar {
  width: 32px; height: 32px; border-radius: 10px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 700; color: #fff;
}
.msg-row.user .msg-avatar { background: var(--primary); }
.msg-row.ai .msg-avatar { background: var(--accent); }

.msg-bubble {
  max-width: 75%; padding: 12px 16px; border-radius: 14px; font-size: 14px; line-height: 1.6;
}
.msg-bubble.user { background: var(--primary); color: #fff; border-bottom-right-radius: 4px; }
.msg-bubble.ai { background: #F5F6FA; color: var(--text-secondary); border-bottom-left-radius: 4px; }
.msg-time { font-size: 10px; opacity: .5; margin-top: 4px; text-align: right; }
.msg-bubble.typing { display: flex; gap: 4px; padding: 14px 18px; }
.typing-dot { width: 6px; height: 6px; border-radius: 50%; background: #B0B5BD; animation: bounce 1.4s infinite; }
.typing-dot:nth-child(2) { animation-delay: .2s; }
.typing-dot:nth-child(3) { animation-delay: .4s; }
@keyframes bounce { 0%,80%,100% { transform: translateY(0); } 40% { transform: translateY(-6px); } }

.chat-input-area { padding: 14px 20px; border-top: 1px solid var(--border); }
</style>
