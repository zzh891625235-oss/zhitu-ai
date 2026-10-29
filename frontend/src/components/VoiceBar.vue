<template>
  <div class="voice-bar">
    <el-tooltip :content="listening ? '停止录音' : '语音输入（Chrome / Edge 支持）'">
      <el-button circle size="small" :type="listening ? 'danger' : 'default'"
        :disabled="!srSupported" @click="toggleListen">
        <el-icon><Microphone /></el-icon>
      </el-button>
    </el-tooltip>
    <el-tooltip :content="speaking ? '停止朗读' : '朗读这条回答'">
      <el-button circle size="small" :type="speaking ? 'primary' : 'default'"
        :disabled="!text || !ttsSupported" @click="toggleSpeak">
        <el-icon><VideoPlay /></el-icon>
      </el-button>
    </el-tooltip>
    <span class="voice-tip live" v-if="listening">正在聆听…</span>
    <span class="voice-tip" v-else-if="partial">{{ partial }}</span>
    <span class="voice-tip warn" v-else-if="!srSupported && !ttsSupported">当前浏览器不支持语音能力</span>
  </div>
</template>

<script setup>
import { ref, onUnmounted } from 'vue'
import { Microphone, VideoPlay } from '@element-plus/icons-vue'
import { speak, stopSpeak, createRecognizer, ttsSupported, srSupported } from '../utils/speech'

/**
 * 语音输入 / 语音朗读。
 *
 * 走的是浏览器原生 Web Speech API，不需要后端参与：
 * 识别在本地完成，朗读也只是把文本交给系统语音合成引擎。
 * 好处很实在——不必部署 ASR / TTS 服务，学生的语音数据也不会离开本机。
 *
 * Firefox 目前不支持 SpeechRecognition，此时按钮自动禁用并给出说明，
 * 而不是假装能用然后点下去没反应。
 */
const props = defineProps({ text: { type: String, default: '' } })
const emit = defineEmits(['text'])

const listening = ref(false)
const speaking = ref(false)
const partial = ref('')
let recognizer = null

function toggleListen() {
  if (listening.value) {
    stopListen()
    return
  }
  if (!recognizer) {
    recognizer = createRecognizer({
      onFinal: text => {
        if (text) emit('text', text)
        stopListen()
      },
      onPartial: text => { partial.value = text },
      onEnd: stopListen,
      onError: stopListen
    })
  }
  if (!recognizer) return
  try {
    recognizer.start()
    listening.value = true
  } catch (e) {
    listening.value = false
  }
}

function stopListen() {
  listening.value = false
  partial.value = ''
  if (recognizer) {
    try { recognizer.stop() } catch (e) { /* 未启动时 stop 会抛错，忽略 */ }
  }
}

function toggleSpeak() {
  if (speaking.value) {
    stopSpeak()
    speaking.value = false
    return
  }
  const started = speak(props.text, { onEnd: () => { speaking.value = false } })
  speaking.value = started
}

onUnmounted(() => {
  stopListen()
  stopSpeak()
})
</script>

<style scoped>
.voice-bar { display: flex; align-items: center; gap: 8px; min-width: 0; }
.voice-tip { font-size: 11px; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.voice-tip.live { color: #F56C6C; }
.voice-tip.warn { color: #F5C97A; }
</style>
