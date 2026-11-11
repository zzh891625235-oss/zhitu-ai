<template>
  <div class="assistant-page">
    <div class="page-hero">
      <h1><el-icon><ChatDotRound /></el-icon> AI成长助手</h1>
      <p>学习答疑 · 职业规划 · 竞赛咨询 · 模拟面试</p>
      <div class="agent-intro">
        <span class="ai-chip">Function Calling</span>
        <span class="ai-chip">RAG 检索</span>
        <span class="ai-chip">结果可溯源</span>
        每轮回答都会<b>真实调用工具</b>去查你的档案、课程进度、竞赛与打卡记录，
        并把依据逐条列出来，供你核对。
      </div>
      <div class="ai-mode" :class="aiStatus.configured ? 'online' : 'offline'">
        <span class="mode-dot"></span>
        <span v-if="aiStatus.configured">已接入真实大模型 · {{ aiStatus.model }}</span>
        <span v-else>离线模板模式 · 在「API设置」中填入 Key 即可启用真实大模型</span>
      </div>
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
        <div class="mode-tools">
          <el-button text size="small" :disabled="!messages.length" @click="handleClear">
            <el-icon><Delete /></el-icon>&nbsp;清空当前对话
          </el-button>
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
              <div v-if="msg.role === 'ai' && msg.thinking && msg.phase" class="msg-phase">
                <span class="phase-spin"></span>{{ msg.phase }}
              </div>
              <div class="msg-text md-body" v-html="renderMarkdown(msg.content)"></div>
              <span v-if="msg.role === 'ai' && loading && idx === messages.length - 1" class="caret"></span>
              <AgentTrace v-if="msg.trace" :mode="msg.trace.mode" :steps="msg.trace.steps"
                :citations="msg.trace.citations" :verify="msg.trace.verify" />
              <div class="msg-time">
                <span v-if="msg.role === 'ai' && msg.real === false" class="offline-tag">离线模板</span>
                <el-button v-if="msg.role === 'ai' && msg.content && ttsSupported" text size="small"
                  class="tts-btn" @click="speakMsg(msg)">{{ speakingId === msg.id ? '停止' : '朗读' }}</el-button>
                <span v-if="msg.time">{{ msg.time }}</span>
              </div>
            </div>
          </div>

          <div v-if="showTyping" class="msg-row ai">
            <div class="msg-avatar"><span>AI</span></div>
            <div class="msg-bubble ai typing">
              <span class="typing-dot"></span>
              <span class="typing-dot"></span>
              <span class="typing-dot"></span>
            </div>
          </div>
        </div>

        <div class="chat-input-area">
          <el-input v-model="inputText" placeholder="输入你的问题，Enter 发送..." size="large"
            type="textarea" :rows="1" resize="none" :autosize="{ minRows: 1, maxRows: 4 }"
            @keydown.enter.exact.prevent="sendMessage()" :disabled="loading">
          </el-input>
          <VoiceBar class="input-voice" :text="lastAnswer" @text="t => (inputText = t)" />
          <el-button type="primary" class="send-btn" @click="sendMessage()" :loading="loading" :icon="Promotion" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, nextTick, onMounted } from 'vue'
import { ChatDotRound, Promotion, Delete } from '@element-plus/icons-vue'
import { getHistoryApi, clearHistoryApi, getAiStatusApi } from '../api/ai'
import { agentStreamApi } from '../api/agent'
import AgentTrace from '../components/AgentTrace.vue'
import VoiceBar from '../components/VoiceBar.vue'
import { speak, stopSpeak, ttsSupported } from '../utils/speech'
import { getProfileApi } from '../api/profile'
import { buildQuickQuestions, resolveDirectionData } from '../data/majorDirection'
import { renderMarkdown } from '../utils/markdown'
import { ElMessage, ElMessageBox } from 'element-plus'

const currentMode = ref('GENERAL')
const messages = ref([])
const inputText = ref('')
const loading = ref(false)
const msgContainer = ref(null)
const aiStatus = reactive({ configured: false, model: '', keySource: 'NONE' })
const speakingId = ref(null)

/** 最近一条 AI 回答，供输入区的朗读按钮使用 */
const lastAnswer = computed(() => {
  for (let i = messages.value.length - 1; i >= 0; i--) {
    const m = messages.value[i]
    if (m.role === 'ai' && m.content) return m.content
  }
  return ''
})

// 学生专业方向：默认通用方向，快捷提问随之切换，避免出现与专业无关的技术问题
const direction = ref(resolveDirectionData(''))

const modes = computed(() => {
  const q = buildQuickQuestions(direction.value.key)
  return [
    { id: 'GENERAL', icon: '🤖', name: '通用问答', desc: '学习成长咨询',
      welcome: `你好！我是智途AI助手。当前按「${direction.value.label}」方向为你提供建议，有任何学习、成长、规划的问题，尽管问我！`,
      quickQuestions: q.GENERAL },
    { id: 'LEARNING', icon: '📖', name: '学习导师', desc: '概念解释+答疑',
      welcome: '我是你的AI学习导师。遇到不懂的知识点，我会用通俗的方式帮你理解！',
      quickQuestions: q.LEARNING },
    { id: 'CAREER', icon: '💼', name: '职业规划', desc: '就业发展方向',
      welcome: '我是你的职业规划顾问。帮你分析发展方向、准备面试、规划未来。',
      quickQuestions: q.CAREER },
    { id: 'COMPETITION', icon: '🏆', name: '竞赛咨询', desc: '比赛策略+准备',
      welcome: '我是竞赛辅导老师。帮你选择适合的比赛、制定备赛策略！',
      quickQuestions: q.COMPETITION },
    { id: 'INTERVIEW', icon: '🎤', name: '模拟面试', desc: '岗位面试演练',
      welcome: '我是你的模拟面试官。我会像真实面试一样提问，并在你回答后给出具体点评。\n\n准备好了就说「开始面试」，我先了解一下你的目标岗位。',
      quickQuestions: q.INTERVIEW }
  ]
})

const currentModeObj = computed(() => modes.value.find(m => m.id === currentMode.value) || modes.value[0])
const showTyping = computed(() => {
  if (!loading.value || !messages.value.length) return false
  const last = messages.value[messages.value.length - 1]
  return last.role === 'ai' && !last.content
})

function timeNow() {
  return new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
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
      messages.value.push({ role: 'user', content: h.question, time: (h.createdAt || '').substring(11, 16) })
      messages.value.push({ role: 'ai', content: h.answer, time: (h.createdAt || '').substring(11, 16) })
    })
  } catch (e) {
    // 历史加载失败不影响新对话
  }
  scrollBottom()
}

async function sendMessage(quick) {
  const text = (quick || inputText.value).trim()
  if (!text || loading.value) return

  messages.value.push({ role: 'user', content: text, time: timeNow(), id: uid() })
  inputText.value = ''
  loading.value = true
  scrollBottom()

  // trace 独立成 reactive：工具调用、引用、校验事件各自到达，需要分别驱动视图更新
  const aiMsg = reactive({
    role: 'ai', content: '', time: timeNow(), real: null, thinking: true, phase: '', id: uid(),
    trace: reactive({ mode: '', steps: [], citations: [], verify: null })
  })
  messages.value.push(aiMsg)

  try {
    await agentStreamApi(text, currentMode.value, {
      onStatus: t => { aiMsg.phase = t; scrollBottom() },
      onCitations: items => { aiMsg.trace.citations = items; scrollBottom() },
      onMode: mode => { aiMsg.trace.mode = mode },
      onToolCall: node => {
        aiMsg.trace.steps.push({ name: node.name, purpose: node.purpose, preview: '', ok: true, dataDomain: node.purpose })
        scrollBottom()
      },
      onToolResult: node => {
        // 同名工具可能被多次调用，回填到最近一条还没结果的记录上
        for (let i = aiMsg.trace.steps.length - 1; i >= 0; i--) {
          const step = aiMsg.trace.steps[i]
          if (step.name === node.name && !step.preview) {
            step.preview = node.preview
            step.ok = node.ok
            break
          }
        }
        scrollBottom()
      },
      onDelta: delta => { aiMsg.content += delta; scrollBottom() },
      onVerify: v => { aiMsg.trace.verify = v },
      onDone: meta => {
        aiMsg.real = meta.real
        if (meta.real) aiStatus.configured = true
      },
      onBlocked: reason => { aiMsg.content = reason; aiMsg.blocked = true },
      onError: msg => { if (!aiMsg.content) aiMsg.content = msg }
    })
  } catch (e) {
    if (!aiMsg.content) {
      aiMsg.content = '抱歉，AI 服务暂时不可用。请检查后端服务是否启动，或稍后重试。'
    }
  } finally {
    loading.value = false
    aiMsg.thinking = false
    aiMsg.phase = ''
    scrollBottom()
  }
}

/** 消息自增编号：用于标记当前正在朗读的是哪一条 */
let seq = 0
function uid() { return ++seq }

/** 朗读某条回答；再点一次停止 */
function speakMsg(msg) {
  if (speakingId.value === msg.id) {
    stopSpeak()
    speakingId.value = null
    return
  }
  const started = speak(msg.content, { onEnd: () => { speakingId.value = null } })
  speakingId.value = started ? msg.id : null
}

async function handleClear() {
  try {
    await ElMessageBox.confirm('确定要清空当前模式的对话记录吗？', '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await clearHistoryApi(currentMode.value)
    messages.value = []
    ElMessage.success('已清空')
  } catch (e) {
    messages.value = []
  }
}

onMounted(async () => {
  try {
    Object.assign(aiStatus, (await getAiStatusApi()).data || {})
  } catch (e) {
    // 状态获取失败时按离线模式展示
  }
  // 先拿到专业方向，保证快捷提问与专业一致
  try {
    const profile = (await getProfileApi()).data
    direction.value = resolveDirectionData(profile?.majorName || '')
  } catch (e) {
    // 档案读取失败时保持通用方向的快捷提问
  }
  await switchMode('GENERAL')
})
</script>

<style scoped>
.assistant-page { max-width: 1200px; margin: 0 auto; }
.page-hero { text-align: center; padding: 28px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.agent-intro {
  display: flex; align-items: center; justify-content: center; flex-wrap: wrap; gap: 6px;
  margin: 10px auto 0; max-width: 720px; font-size: 12px; color: var(--text-muted); line-height: 1.6;
}
.agent-intro b { color: var(--primary); font-weight: 600; }
.ai-chip {
  font-size: 10.5px; padding: 2px 8px; border-radius: 20px;
  background: rgba(139,195,74,.10); color: var(--primary); border: 1px solid rgba(139,195,74,.22);
}

.ai-mode {
  display: inline-flex; align-items: center; gap: 7px; margin-top: 12px;
  padding: 5px 14px; border-radius: 20px; font-size: 12px;
}
.ai-mode.online { background: rgba(102,187,106,.10); color: #66BB6A; }
.ai-mode.offline { background: rgba(245,165,36,.10); color: #F5C97A; }
.mode-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }

.assistant-layout { display: grid; grid-template-columns: 240px 1fr; gap: 20px; margin-bottom: 40px; }

.mode-panel { display: flex; flex-direction: column; gap: 8px; }
.mode-item {
  padding: 14px 16px; border-radius: var(--radius-sm); cursor: pointer;
  display: flex; align-items: center; gap: 12px; transition: all .2s;
  border: 1.5px solid transparent;
}
.mode-item:hover { background: var(--slate-50); }
.mode-item.active { background: rgba(139,195,74,.06); border-color: var(--primary); }
.mode-icon { font-size: 22px; }
.mode-name { font-size: 14px; font-weight: 600; }
.mode-desc { font-size: 11px; color: var(--text-muted); }
.mode-tools { margin-top: 8px; text-align: center; }

.chat-panel { background:var(--glass); border-radius: var(--radius-lg); border: 1px solid var(--border); display: flex; flex-direction: column; height: 640px; }
.chat-header { padding: 16px 20px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; font-size: 15px; font-weight: 600; }

.chat-messages { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 16px; }
.chat-welcome { text-align: center; padding: 40px 0; }
.welcome-icon { font-size: 48px; margin-bottom: 12px; }
.chat-welcome p { color: var(--text-secondary); margin-bottom: 20px; white-space: pre-line; }
.quick-qs { display: flex; flex-wrap: wrap; justify-content: center; gap: 8px; }
.quick-q {
  padding: 8px 16px; background: var(--slate-50); border-radius: 20px;
  cursor: pointer; font-size: 13px; color: var(--primary); transition: all .2s;
}
.quick-q:hover { background: rgba(139,195,74,.12); }

.msg-row { display: flex; gap: 10px; }
.msg-row.user { flex-direction: row-reverse; }
.msg-avatar {
  width: 32px; height: 32px; border-radius: 10px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 700; color: #fff;
}
.msg-row.user .msg-avatar { background: var(--primary); color: var(--void); }
.msg-row.ai .msg-avatar { background: #A855F7; }

.msg-bubble {
  max-width: 78%; padding: 12px 16px; border-radius: 14px; font-size: 14px; line-height: 1.7;
}
.msg-bubble.user { background: var(--primary); color: var(--void); border-bottom-right-radius: 4px; }
.msg-bubble.ai { background: rgba(255,255,255,.035); color: var(--text-secondary); border-bottom-left-radius: 4px; }
.msg-time { font-size: 10px; opacity: .5; margin-top: 6px; display: flex; gap: 8px; justify-content: flex-end; align-items: center; }
.offline-tag { color: #F5C97A; opacity: .9; }
.msg-bubble.typing { display: flex; gap: 4px; padding: 14px 18px; }
.typing-dot { width: 6px; height: 6px; border-radius: 50%; background: #B0B5BD; animation: bounce 1.4s infinite; }
.typing-dot:nth-child(2) { animation-delay: .2s; }
.typing-dot:nth-child(3) { animation-delay: .4s; }
@keyframes bounce { 0%,80%,100% { transform: translateY(0); } 40% { transform: translateY(-6px); } }

.caret {
  display: inline-block; width: 2px; height: 14px; vertical-align: middle;
  background: var(--signal); margin-left: 2px; animation: blink 1s steps(2) infinite;
}
@keyframes blink { 0%,100% { opacity: 1; } 50% { opacity: 0; } }

.chat-input-area { padding: 14px 20px; border-top: 1px solid var(--border); display: flex; gap: 10px; align-items: flex-end; }
.send-btn { height: 40px; width: 46px; flex-shrink: 0; }

/* Markdown 正文样式（v-html 内容需要 :deep 才能命中） */
.msg-text :deep(p) { margin: 0 0 8px; }
.msg-text :deep(p:last-child) { margin-bottom: 0; }
.msg-text :deep(h3), .msg-text :deep(h4) { font-size: 14px; font-weight: 600; margin: 12px 0 6px; color: #fff; }
.msg-text :deep(h3:first-child), .msg-text :deep(h4:first-child) { margin-top: 0; }
.msg-text :deep(ul) { margin: 6px 0; padding-left: 18px; }
.msg-text :deep(li) { margin: 3px 0; list-style: disc; }
.msg-text :deep(li.md-ordered) { list-style: decimal; }
.msg-text :deep(strong) { color: #fff; font-weight: 600; }
.msg-text :deep(a) { color: var(--primary); text-decoration: none; border-bottom: 1px dashed var(--primary); word-break: break-all; }
.msg-text :deep(a:hover) { color: #7FF3E4; }
.msg-text :deep(code) {
  background: rgba(139,195,74,.12); color: #A5D66A; padding: 1px 5px;
  border-radius: 4px; font-size: 12.5px; font-family: Consolas, Monaco, monospace;
}
.msg-text :deep(.md-code) {
  background: rgba(0,0,0,.35); border: 1px solid var(--border); border-radius: 8px;
  padding: 10px 12px; overflow-x: auto; margin: 8px 0;
}
.msg-text :deep(.md-code code) { background: none; color: #C8E6A0; padding: 0; font-size: 12.5px; line-height: 1.6; }
.msg-text :deep(.md-table) { border-collapse: collapse; margin: 8px 0; font-size: 12.5px; width: 100%; }
.msg-text :deep(.md-table th), .msg-text :deep(.md-table td) { border: 1px solid var(--border); padding: 5px 8px; text-align: left; }
.msg-text :deep(.md-table th) { background: rgba(255,255,255,.04); color: #fff; font-weight: 600; }
.msg-text :deep(blockquote) {
  border-left: 2px solid var(--signal); padding-left: 10px; margin: 8px 0;
  color: var(--fog); font-size: 13px;
}

.msg-phase { display: flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--primary); margin-bottom: 6px; }
.phase-spin { width: 10px; height: 10px; border-radius: 50%; border: 1.5px solid rgba(139,195,74,.3); border-top-color: var(--primary); animation: spin .8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.tts-btn { height: 20px; padding: 0 6px; font-size: 10.5px; }
.input-voice { padding-bottom: 4px; }

/* 移动端：模式面板横向滚动，聊天区占满高度 */
@media (max-width: 820px) {
  .assistant-layout { grid-template-columns: 1fr; gap: 12px; }
  .mode-panel { flex-direction: row; overflow-x: auto; padding-bottom: 4px; }
  .mode-item { flex: 0 0 auto; padding: 10px 14px; }
  .mode-desc { display: none; }
  .mode-tools { display: none; }
  .chat-panel { height: calc(100vh - 300px); min-height: 420px; }
  .msg-bubble { max-width: 88%; }
}
</style>
