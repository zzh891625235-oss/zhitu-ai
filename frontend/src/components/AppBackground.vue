<template>
  <!--
    全局动态背景 —— 「成长知识网络」

    设计意图：
      学生成长本身就是一张不断扩张的关系网：课程、技能、竞赛、规划节点之间
      由 AI 建立连接。这里用缓慢漂移的节点 + 呼吸式连线 + 沿边走的光脉冲
      把这件事可视化，且不抢内容的注意力。

    层级：aurora(光) → canvas(网络) → grid(刻度) → vignette(压角)
    性能：单 canvas、40fps 上限、节点数按屏幕面积自适应、
          切到后台自动停、尊重 prefers-reduced-motion。
  -->
  <div class="app-bg" aria-hidden="true">
    <div class="ab-aurora ab-a"></div>
    <div class="ab-aurora ab-b"></div>
    <div class="ab-aurora ab-c"></div>
    <canvas ref="cv" class="ab-canvas"></canvas>
    <div class="ab-grid"></div>
    <div class="ab-vignette"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRoute } from 'vue-router'

const TAU = Math.PI * 2
const LINK = 172          // 连线半径（px）
const LINK2 = LINK * LINK
const MAX_PULSES = 6      // 同时存在的脉冲上限，避免视觉过载
const FPS = 40

const cv = ref(null)
const route = useRoute()

let ctx = null
let W = 0
let H = 0
let dpr = 1
let nodes = []
let pulses = []
let raf = 0
let last = 0
let reduced = false
let running = true
let resizeTimer = null
let X = []
let Y = []
let mouseX = 0
let mouseY = 0
let tMouseX = 0
let tMouseY = 0

const rnd = (a, b) => a + Math.random() * (b - a)

function nodeCount () {
  const area = window.innerWidth * window.innerHeight
  return Math.max(38, Math.min(104, Math.round(area / 19000)))
}

function pickNode () {
  return Math.floor(Math.random() * nodes.length)
}

/** 在 i 附近随机找一个邻居，形成一条「有意义的连接」 */
function neighborOf (i, maxDist) {
  const a = nodes[i]
  if (!a) return -1
  const pool = []
  for (let j = 0; j < nodes.length; j++) {
    if (j === i) continue
    if (Math.hypot(nodes[j].x - a.x, nodes[j].y - a.y) < maxDist) pool.push(j)
  }
  if (!pool.length) return -1
  return pool[Math.floor(Math.random() * pool.length)]
}

function spawnPulse (from) {
  if (pulses.length >= MAX_PULSES || !nodes.length) return
  const to = neighborOf(from, LINK * 1.15)
  if (to < 0) return
  pulses.push({ from, to, t: 0, speed: rnd(0.007, 0.015) })
}

function reset () {
  const n = nodeCount()
  nodes = []
  for (let i = 0; i < n; i++) {
    nodes.push({
      x: Math.random() * W,
      y: Math.random() * H,
      vx: rnd(-0.07, 0.07),
      vy: rnd(-0.07, 0.07),
      r: rnd(0.7, 1.9),
      z: rnd(0.3, 1),        // 景深，决定视差强度与基础亮度
      a: 0,                  // 激活度 0~1
      ph: rnd(0, TAU)
    })
  }
  X = new Array(n)
  Y = new Array(n)
  pulses = []
  // 开场就点亮几处，避免第一眼是死图
  for (let i = 0; i < 3; i++) {
    const idx = pickNode()
    if (nodes[idx]) nodes[idx].a = 0.8
    spawnPulse(idx)
  }
}

function resize () {
  const el = cv.value
  if (!el) return
  const prevW = W
  const prevH = H
  dpr = Math.min(window.devicePixelRatio || 1, 1.6)
  W = window.innerWidth
  H = window.innerHeight
  el.width = Math.round(W * dpr)
  el.height = Math.round(H * dpr)
  el.style.width = W + 'px'
  el.style.height = H + 'px'
  ctx = el.getContext('2d')
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0)

  if (!nodes.length) {
    reset()
  } else {
    // 保持原有构图，只做等比缩放，避免窗口拉伸时网络整体重排
    const sx = prevW ? W / prevW : 1
    const sy = prevH ? H / prevH : 1
    for (const p of nodes) {
      p.x *= sx
      p.y *= sy
    }
  }
  if (reduced) draw(0)
}

function draw (dt) {
  if (!ctx) return
  const d = dt || 1
  ctx.clearRect(0, 0, W, H)

  // 鼠标视差：缓动跟随，让背景有「在后面」的纵深
  mouseX += (tMouseX - mouseX) * Math.min(1, 0.045 * d)
  mouseY += (tMouseY - mouseY) * Math.min(1, 0.045 * d)
  const offX = mouseX * 26
  const offY = mouseY * 26

  const n = nodes.length

  // 1. 推进节点状态
  for (let i = 0; i < n; i++) {
    const p = nodes[i]
    p.x += p.vx * d
    p.y += p.vy * d
    if (p.x < -30) p.x = W + 30
    else if (p.x > W + 30) p.x = -30
    if (p.y < -30) p.y = H + 30
    else if (p.y > H + 30) p.y = -30
    p.a *= Math.pow(0.956, d)
    p.ph += 0.006 * d
    X[i] = p.x + offX * p.z
    Y[i] = p.y + offY * p.z
  }

  // 2. 基础连线（两档亮度批量绘制，避免上千次 stroke）
  for (let pass = 0; pass < 2; pass++) {
    const isNear = pass === 0
    const maxD2 = isNear ? LINK2 * 0.34 : LINK2
    const minD2 = isNear ? 0 : LINK2 * 0.34
    ctx.beginPath()
    for (let i = 0; i < n; i++) {
      const ai = nodes[i].a
      for (let j = i + 1; j < n; j++) {
        const dx = X[i] - X[j]
        const dy = Y[i] - Y[j]
        const d2 = dx * dx + dy * dy
        if (d2 > maxD2 || d2 < minD2) continue
        // 已激活的边由第 3 步单独绘制（带颜色），这里跳过
        if (ai > 0.04 || nodes[j].a > 0.04) continue
        ctx.moveTo(X[i], Y[i])
        ctx.lineTo(X[j], Y[j])
      }
    }
    ctx.strokeStyle = isNear ? 'rgba(255,255,255,.072)' : 'rgba(255,255,255,.032)'
    ctx.lineWidth = 1
    ctx.stroke()
  }

  // 3. 被激活的连线（信号绿色，靠近端点的更亮）
  for (let i = 0; i < n; i++) {
    const ai = nodes[i].a
    for (let j = i + 1; j < n; j++) {
      const act = Math.max(ai, nodes[j].a)
      if (act <= 0.04) continue
      const dx = X[i] - X[j]
      const dy = Y[i] - Y[j]
      const d2 = dx * dx + dy * dy
      if (d2 > LINK2) continue
      const alpha = Math.min(0.46, act * (1 - d2 / LINK2) * 0.6)
      ctx.strokeStyle = 'rgba(139,195,74,' + alpha.toFixed(3) + ')'
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(X[i], Y[i])
      ctx.lineTo(X[j], Y[j])
      ctx.stroke()
    }
  }

  // 4. 节点
  for (let i = 0; i < n; i++) {
    const p = nodes[i]
    const act = p.a
    const r = p.r * (1 + act * 1.5)
    const alpha = 0.16 + p.z * 0.36 + act * 0.45

    if (act > 0.16) {
      const g = ctx.createRadialGradient(X[i], Y[i], 0, X[i], Y[i], r * 7)
      g.addColorStop(0, 'rgba(139,195,74,' + (0.3 * act).toFixed(3) + ')')
      g.addColorStop(1, 'rgba(139,195,74,0)')
      ctx.fillStyle = g
      ctx.beginPath()
      ctx.arc(X[i], Y[i], r * 7, 0, TAU)
      ctx.fill()
    }

    ctx.fillStyle = act > 0.1
      ? 'rgba(196,240,150,' + Math.min(1, alpha).toFixed(3) + ')'
      : 'rgba(255,255,255,' + Math.min(1, alpha).toFixed(3) + ')'
    ctx.beginPath()
    ctx.arc(X[i], Y[i], r, 0, TAU)
    ctx.fill()
  }

  // 5. 沿连线游走的光脉冲 —— 体现「AI 正在建立连接」
  for (let k = pulses.length - 1; k >= 0; k--) {
    const pl = pulses[k]
    pl.t += pl.speed * d
    if (pl.t > 1.15) { pulses.splice(k, 1); continue }

    const t = Math.min(1, pl.t)
    const ax = X[pl.from]
    const ay = Y[pl.from]
    const bx = X[pl.to]
    const by = Y[pl.to]
    const cx = ax + (bx - ax) * t
    const cy = ay + (by - ay) * t
    const tail = Math.max(0, t - 0.3)
    const tx = ax + (bx - ax) * tail
    const ty = ay + (by - ay) * tail

    const grad = ctx.createLinearGradient(tx, ty, cx, cy)
    grad.addColorStop(0, 'rgba(139,195,74,0)')
    grad.addColorStop(1, 'rgba(200,242,150,.85)')
    ctx.strokeStyle = grad
    ctx.lineWidth = 1.4
    ctx.beginPath()
    ctx.moveTo(tx, ty)
    ctx.lineTo(cx, cy)
    ctx.stroke()

    ctx.fillStyle = 'rgba(226,255,190,.95)'
    ctx.beginPath()
    ctx.arc(cx, cy, 1.6, 0, TAU)
    ctx.fill()

    if (pl.t >= 1) {
      // 抵达即点亮，并有一定概率继续生长 —— 连接会自己蔓延开来
      if (nodes[pl.to]) nodes[pl.to].a = 1
      pulses.splice(k, 1)
      if (Math.random() < 0.55) spawnPulse(pl.to)
    }
  }

  // 6. 网络静默时自动续上新脉冲，保证画面始终「活着」
  if (pulses.length === 0 && n) spawnPulse(pickNode())
}

function tick (ts) {
  raf = requestAnimationFrame(tick)
  if (!running) return
  if (!last) last = ts
  const delta = ts - last
  if (delta < 1000 / FPS) return
  last = ts
  draw(Math.min(delta / 16.667, 3))
}

/** 切换模块时触发一次「连接涟漪」，让页面之间的过渡有连续感 */
function surge () {
  if (!nodes.length || reduced) return
  for (let i = 0; i < 3; i++) {
    const idx = pickNode()
    if (nodes[idx]) nodes[idx].a = 1
    spawnPulse(idx)
  }
}

function onMove (e) {
  tMouseX = (e.clientX / window.innerWidth - 0.5) * 2
  tMouseY = (e.clientY / window.innerHeight - 0.5) * 2
}

function onVisibility () {
  if (document.hidden) {
    running = false
    if (raf) { cancelAnimationFrame(raf); raf = 0 }
  } else if (!reduced) {
    running = true
    last = 0
    if (!raf) raf = requestAnimationFrame(tick)
  }
}

function onResize () {
  if (resizeTimer) clearTimeout(resizeTimer)
  resizeTimer = setTimeout(resize, 180)
}

onMounted(() => {
  reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  resize()
  if (reduced) {
    draw(0)
    return
  }
  window.addEventListener('mousemove', onMove, { passive: true })
  window.addEventListener('resize', onResize)
  document.addEventListener('visibilitychange', onVisibility)
  raf = requestAnimationFrame(tick)
})

onBeforeUnmount(() => {
  running = false
  if (raf) cancelAnimationFrame(raf)
  if (resizeTimer) clearTimeout(resizeTimer)
  window.removeEventListener('mousemove', onMove)
  window.removeEventListener('resize', onResize)
  document.removeEventListener('visibilitychange', onVisibility)
})

// 每次换模块都带来一小波光，背景因此「跟着走」而不是重新开始
watch(() => route.path, () => {
  setTimeout(surge, 120)
})
</script>

<style scoped>
.app-bg {
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  pointer-events: none;
  background: #030303;
}

/* 极缓的三团光雾：给纯黑一点色温层次，不参与重绘（纯 transform 动画） */
.ab-aurora {
  position: absolute;
  border-radius: 50%;
  will-change: transform;
  transform: translate3d(0, 0, 0);
}
.ab-a {
  width: 78vw; height: 78vw;
  left: -26vw; top: -30vw;
  background: radial-gradient(circle, rgba(139, 195, 74, .16) 0%, rgba(139, 195, 74, 0) 66%);
  animation: ab-drift-a 34s ease-in-out infinite alternate;
}
.ab-b {
  width: 64vw; height: 64vw;
  right: -22vw; top: 14vh;
  background: radial-gradient(circle, rgba(64, 145, 120, .13) 0%, rgba(64, 145, 120, 0) 66%);
  animation: ab-drift-b 47s ease-in-out infinite alternate;
}
.ab-c {
  width: 60vw; height: 60vw;
  left: 22vw; bottom: -30vw;
  background: radial-gradient(circle, rgba(139, 195, 74, .1) 0%, rgba(139, 195, 74, 0) 70%);
  animation: ab-drift-c 59s ease-in-out infinite alternate;
}

.ab-canvas {
  position: absolute;
  inset: 0;
  display: block;
}

/* 极淡的刻度网格，呼应「精密 · 仪器」的视觉基调 */
.ab-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255, 255, 255, .018) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, .018) 1px, transparent 1px);
  background-size: 72px 72px;
  -webkit-mask-image: radial-gradient(ellipse 78% 68% at 50% 38%, #000 12%, transparent 78%);
  mask-image: radial-gradient(ellipse 78% 68% at 50% 38%, #000 12%, transparent 78%);
}

.ab-vignette {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 135% 105% at 50% 44%, rgba(0, 0, 0, 0) 34%, rgba(0, 0, 0, .5) 100%),
    linear-gradient(180deg, rgba(0, 0, 0, .3) 0%, rgba(0, 0, 0, 0) 20%, rgba(0, 0, 0, .32) 100%);
}

@keyframes ab-drift-a {
  0%   { transform: translate3d(0, 0, 0) scale(1); }
  100% { transform: translate3d(6vw, 5vh, 0) scale(1.12); }
}
@keyframes ab-drift-b {
  0%   { transform: translate3d(0, 0, 0) scale(1.06); }
  100% { transform: translate3d(-7vw, -6vh, 0) scale(1); }
}
@keyframes ab-drift-c {
  0%   { transform: translate3d(0, 0, 0) scale(1); }
  100% { transform: translate3d(4vw, -7vh, 0) scale(1.15); }
}

@media (max-width: 820px) {
  .ab-grid { background-size: 56px 56px; }
  .ab-a, .ab-b, .ab-c { opacity: .8; }
}
</style>
