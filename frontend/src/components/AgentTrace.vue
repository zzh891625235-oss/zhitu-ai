<template>
  <div class="agent-trace" v-if="visible">
    <div class="trace-head" @click="open = !open">
      <span class="trace-badge" :class="mode === 'LLM_DRIVEN' ? 'llm' : 'rule'">
        <span class="dot"></span>{{ modeLabel }}
      </span>
      <span class="trace-summary">
        <template v-if="citations.length">检索 {{ citations.length }} 条资料</template>
        <template v-else-if="verify">未命中本地知识库</template>
        <template v-if="steps.length"> · 调用 {{ steps.length }} 个工具</template>
        <template v-if="verify && verify.checkedFacts"> · 核对 {{ verify.checkedFacts }} 条事实</template>
      </span>
      <span class="trace-toggle">{{ open ? '收起' : '查看依据' }}<el-icon><ArrowDown /></el-icon></span>
    </div>

    <div class="trace-body" v-show="open">
      <!-- 工具调用轨迹 -->
      <div class="trace-block" v-if="steps.length">
        <div class="block-title">调用了这些工具（数据来自真实记录）</div>
        <div class="step" v-for="(s, i) in steps" :key="i">
          <div class="step-idx">{{ i + 1 }}</div>
          <div class="step-main">
            <div class="step-name">
              {{ toolLabel(s.name) }}
              <span class="step-domain">{{ s.dataDomain }}</span>
            </div>
            <div class="step-preview">{{ s.preview }}</div>
          </div>
          <div class="step-flag" v-if="s.ok">✓</div>
        </div>
      </div>

      <!-- RAG 引用来源 -->
      <div class="trace-block" v-if="citations.length">
        <div class="block-title">参考来源（点击标题可在竞赛中心 / 课程地图核对）</div>
        <div class="cite" v-for="(c, i) in citations" :key="c.id">
          <span class="cite-idx">[{{ i + 1 }}]</span>
          <span class="cite-src">{{ sourceLabel(c.source) }}</span>
          <span class="cite-title">{{ c.title }}</span>
          <span class="cite-score">相关度 {{ c.score }}</span>
          <div class="cite-excerpt">{{ c.excerpt }}</div>
        </div>
      </div>

      <!-- RAG 零命中时的诚实提示：不假装用了知识库 -->
      <div class="trace-block trace-nohit" v-else-if="verify">
        <div class="block-title">知识库检索</div>
        <div class="nohit-text">本次提问未在本地知识库（竞赛库 / 课程库 / 方法语料）中检索到相关内容，
          以上回答来自大模型通用知识，具体赛事名与数字请以官方渠道为准。</div>
      </div>

      <!-- 事实一致性校验 -->
      <div class="trace-verify" v-if="verify" :class="suspects.length ? 'warn' : 'ok'">
        <template v-if="suspects.length">
          ⚠️ 有 {{ suspects.length }} 处说法未在资料库中命中，请自行核实：{{ suspects.join('、') }}
        </template>
        <template v-else>
          ✓ 已核对：回答中提到的具体信息均可在上述资料中找到出处
        </template>
      </div>

      <div class="trace-foot" v-if="mode === 'RULE_DRIVEN'">
        说明：当前未连接大模型，工具选择由本地规则完成，但上方数据全部来自平台真实记录。
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ArrowDown } from '@element-plus/icons-vue'
import { TOOL_LABELS, SOURCE_LABELS } from '../api/agent'

const props = defineProps({
  mode: { type: String, default: '' },
  steps: { type: Array, default: () => [] },
  citations: { type: Array, default: () => [] },
  verify: { type: Object, default: null },
  phase: { type: String, default: '' }
})

const open = ref(false)

const visible = computed(() => props.steps.length > 0 || props.citations.length > 0 || !!props.verify)
const modeLabel = computed(() => (props.mode === 'LLM_DRIVEN' ? '大模型自主调用工具' : '本地规则编排'))
const suspects = computed(() => (props.verify && props.verify.suspects) || [])

function toolLabel(name) {
  return TOOL_LABELS[name] || name
}
function sourceLabel(src) {
  return SOURCE_LABELS[src] || src
}
</script>

<style scoped>
.agent-trace {
  margin-top: 10px; border: 1px solid var(--border); border-radius: 10px;
  background: rgba(255, 255, 255, .025); overflow: hidden; font-size: 12px;
}
.trace-head {
  display: flex; align-items: center; gap: 10px; padding: 8px 12px;
  cursor: pointer; user-select: none;
}
.trace-head:hover { background: rgba(255, 255, 255, .03); }
.trace-badge {
  display: inline-flex; align-items: center; gap: 5px; padding: 2px 8px;
  border-radius: 20px; font-size: 11px; font-weight: 600;
}
.trace-badge.llm { background: rgba(139, 195, 74, .12); color: var(--primary); }
.trace-badge.rule { background: rgba(245, 165, 36, .12); color: #F5C97A; }
.trace-badge .dot { width: 5px; height: 5px; border-radius: 50%; background: currentColor; }
.trace-summary { color: var(--text-muted); flex: 1; }
.trace-toggle { color: var(--primary); display: inline-flex; align-items: center; gap: 3px; font-size: 11px; }
.trace-toggle :deep(svg) { width: 12px; height: 12px; }

.trace-body { padding: 0 12px 12px; display: flex; flex-direction: column; gap: 14px; }
.block-title { color: var(--text-muted); font-size: 11px; margin-bottom: 7px; }

.step { display: flex; gap: 9px; align-items: flex-start; }
.step-idx {
  width: 18px; height: 18px; border-radius: 50%; flex-shrink: 0;
  background: rgba(139, 195, 74, .14); color: var(--primary);
  display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 700;
}
.step-main { flex: 1; min-width: 0; }
.step-name { font-weight: 600; color: #fff; font-size: 12px; }
.step-domain { color: var(--text-muted); font-weight: 400; margin-left: 6px; font-size: 10.5px; }
.step-preview {
  color: var(--fog); margin-top: 3px; line-height: 1.5; font-size: 11px;
  word-break: break-all; max-height: 54px; overflow: hidden;
}
.step-flag { color: var(--primary); font-size: 11px; }

.cite { margin-bottom: 8px; padding-left: 4px; border-left: 2px solid rgba(139, 195, 74, .3); padding-left: 8px; }
.cite-idx { color: var(--primary); font-weight: 700; margin-right: 4px; }
.cite-src {
  font-size: 10px; padding: 1px 5px; border-radius: 4px; margin-right: 5px;
  background: rgba(255, 255, 255, .06); color: var(--text-secondary);
}
.cite-title { color: #fff; font-weight: 600; }
.cite-score { color: var(--text-muted); margin-left: 6px; font-size: 10.5px; }
.cite-excerpt { color: var(--fog); margin-top: 2px; line-height: 1.5; font-size: 11px; }
.trace-nohit .nohit-text { color: var(--text-muted); line-height: 1.6; font-size: 11.5px; }

.trace-verify { padding: 7px 10px; border-radius: 8px; line-height: 1.5; font-size: 11.5px; }
.trace-verify.ok { background: rgba(102, 187, 106, .09); color: #8CD79A; }
.trace-verify.warn { background: rgba(245, 165, 36, .1); color: #F5C97A; }

.trace-foot { color: var(--text-muted); font-size: 11px; border-top: 1px dashed var(--border); padding-top: 8px; }
</style>
