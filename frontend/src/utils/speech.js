/**
 * 浏览器语音能力封装（Web Speech API）。
 *
 * 之所以单独抽成工具模块：语音朗读会被 AI 助手、竞赛推荐理由、
 * 简历预览等多处复用，各写一份 speechSynthesis 逻辑迟早会出现
 * 「一边在说话、另一边又起一句」的互相打断。
 * 这里统一持有状态，并保证同一时刻只有一段话在播。
 */

export const ttsSupported = typeof window !== 'undefined' && 'speechSynthesis' in window

export const srSupported = typeof window !== 'undefined'
  && !!(window.SpeechRecognition || window.webkitSpeechRecognition)

/**
 * 去掉 Markdown 记号。
 * 直接把 `**加粗**`、`# 标题`、[1] 引用编号念出来的话，听起来会非常糟。
 */
export function stripMarkdown(text) {
  if (!text) return ''
  return text
    .replace(/```[\s\S]*?```/g, '')
    .replace(/`([^`]*)`/g, '$1')
    .replace(/\[(\d+)\]/g, '')
    .replace(/^[#>\-\*\s]+/gm, '')
    .replace(/[*_~]/g, '')
    .replace(/\n{2,}/g, '。')
    .replace(/\n/g, '，')
    .trim()
}

/**
 * 朗读一段文本。重复调用会先停掉上一段。
 * @returns {boolean} 是否真的开始朗读（浏览器不支持时返回 false）
 */
export function speak(text, options = {}) {
  if (!ttsSupported || !text) return false
  const plain = stripMarkdown(text)
  if (!plain) return false

  window.speechSynthesis.cancel()
  const utterance = new SpeechSynthesisUtterance(plain)
  utterance.lang = options.lang || 'zh-CN'
  utterance.rate = options.rate || 1.05
  utterance.pitch = options.pitch || 1
  utterance.onend = () => options.onEnd && options.onEnd()
  utterance.onerror = () => options.onEnd && options.onEnd()
  window.speechSynthesis.speak(utterance)
  return true
}

/** 停止朗读 */
export function stopSpeak() {
  if (!ttsSupported) return
  window.speechSynthesis.cancel()
}

/** 是否正在朗读 */
export function isSpeaking() {
  return ttsSupported && window.speechSynthesis.speaking
}

/**
 * 创建一次性语音识别器。
 * 返回 null 表示浏览器不支持 —— 调用方应当禁用入口而不是假装能用。
 */
export function createRecognizer(handlers = {}) {
  if (!srSupported) return null
  const Ctor = window.SpeechRecognition || window.webkitSpeechRecognition
  const recognizer = new Ctor()
  recognizer.lang = handlers.lang || 'zh-CN'
  recognizer.interimResults = true
  recognizer.continuous = false

  recognizer.onresult = event => {
    let transcript = ''
    for (let i = event.resultIndex; i < event.results.length; i++) {
      transcript += event.results[i][0].transcript
    }
    if (handlers.onPartial) handlers.onPartial(transcript)
    if (event.results[event.results.length - 1].isFinal && handlers.onFinal) {
      handlers.onFinal(transcript.trim())
    }
  }
  recognizer.onerror = () => handlers.onError && handlers.onError()
  recognizer.onend = () => handlers.onEnd && handlers.onEnd()
  return recognizer
}
