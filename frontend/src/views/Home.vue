<template>
  <div class="dashboard">
    <!-- 未配置 AI Key 时的引导：先让用户知道当前是规则模板，再引导去配置 -->
    <div class="ai-guide" v-if="aiConfigured === false">
      <el-icon :size="16"><InfoFilled /></el-icon>
      <div class="ag-text">
        <b>当前是「规则模板模式」</b>
        <span>内容按你的专业方向生成，但不够个性化。配置 AI API Key 后，可获得针对你个人情况的深度分析。</span>
      </div>
      <el-button type="primary" size="small" @click="$router.push('/home/settings')">去配置</el-button>
    </div>
    <section class="welcome">
      <div class="wl-left">
        <p class="wl-greet">{{ greetingText }}</p>
        <h1>{{ userStore.userInfo?.nickname||'同学' }}</h1>
        <p class="wl-desc" v-if="portrait">{{ portrait.summary?.substring(0,90) }}</p>
        <p class="wl-desc" v-else>完成档案初始化，让AI为你生成专属大学四年成长规划</p>
        <div class="wl-meta" v-if="profile"><span>{{ profile.grade }}</span><span class="wl-sep"></span><span>{{ majorName }}</span><span class="wl-sep"></span><span class="wl-st">{{ portrait?'AI画像已生成':'等待初始化' }}</span></div>
        <el-button v-if="!portrait" type="primary" @click="$router.push('/init')" style="margin-top:16px">开始AI档案初始化</el-button>
      </div>
      <div class="wl-right" v-if="portrait?.scores">
        <div class="ring"><svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="52" fill="none" stroke="rgba(255,255,255,.04)" stroke-width="6"/><circle cx="60" cy="60" r="52" fill="none" stroke="#8BC34A" stroke-width="6" stroke-linecap="round" :stroke-dasharray="2*Math.PI*52" :stroke-dashoffset="2*Math.PI*52*(1-overall/100)" transform="rotate(-90 60 60)" class="ring-fill"/></svg><div class="ring-c"><span class="ring-n">{{ overall }}</span><span class="ring-l">综合分</span></div></div>
      </div>
    </section>

    <section class="loop" v-if="profile">
      <div class="loop-track"><div class="ln" v-for="(n,i) in loopNodes" :key="i" :class="{done:i<=loopDone}" :style="{'--i':i}"><span class="ln-dot"></span><span class="ln-ico">{{ n.icon }}</span><span class="ln-lbl">{{ n.label }}</span></div></div>
      <div class="loop-bar"><div class="loop-fill" :style="{width:loopPercent+'%'}"></div></div>
      <p class="loop-hint">{{ loopHint }}</p>
    </section>

    <div class="stats" v-if="profile">
      <div class="st" v-for="s in stats" :key="s.label"><div class="st-ic" :style="{background:s.bg,color:s.color}"><el-icon :size="15"><component :is="s.icon"/></el-icon></div><div><span class="st-v">{{ s.value }}</span><span class="st-l">{{ s.label }}</span></div></div>
    </div>

    <div class="grid" v-if="profile">
      <div class="col">
        <el-card shadow="never"><template #header><span class="ct">AI学生画像</span></template>
          <div v-if="portrait"><p class="pt">{{ portrait.summary }}</p><div class="trs"><div class="tr good"><span class="tr-l">优势</span><span>{{ portrait.strengths?.join('、') }}</span></div><div class="tr warn"><span class="tr-l">待提升</span><span>{{ portrait.weaknesses?.join('、') }}</span></div></div></div>
          <el-empty v-else description="完成档案初始化后自动生成" :image-size="60"><el-button type="primary" size="small" @click="$router.push('/init')">去初始化</el-button></el-empty>
        </el-card>
        <el-card shadow="never" style="margin-top:12px"><template #header><span class="ct">今日建议</span></template>
          <div v-if="portrait?.suggestions?.length" class="suggs"><div class="sg" v-for="(s,i) in portrait.suggestions.slice(0,4)" :key="i"><span class="sg-n">{{i+1}}</span><span>{{s}}</span></div></div>
          <el-empty v-else description="生成画像后获取建议" :image-size="50"/>
        </el-card>
      </div>
      <div class="col">
        <el-card shadow="never"><template #header><span class="ct">能力雷达</span></template><div ref="radarChart" class="radar-box"></div></el-card>
        <el-card shadow="never" style="margin-top:12px"><template #header><span class="ct">快速入口</span></template>
          <div class="qks"><div class="qk" v-for="q in quicks" :key="q.label" @click="$router.push(q.to)"><span class="qk-ic">{{q.icon}}</span><span>{{q.label}}</span></div></div>
        </el-card>
      </div>
    </div>
    <div v-else-if="profile===null" style="text-align:center;padding:60px 0;color:var(--fog)"><p>还没有成长档案</p><el-button type="primary" @click="$router.push('/init')" style="margin-top:12px">开始AI档案初始化</el-button></div>
  </div>
</template>

<script setup>
import { ref,computed,onMounted,onUnmounted,nextTick,watch } from 'vue'; import { useUserStore } from '../stores/user'; import { Medal,Reading,TrophyBase,Timer,InfoFilled } from '@element-plus/icons-vue'; import * as echarts from 'echarts/core'; import { RadarChart } from 'echarts/charts'; import { RadarComponent,TooltipComponent } from 'echarts/components'; import { CanvasRenderer } from 'echarts/renderers'; import { getProfileApi,getPortraitApi } from '../api/profile'; import { getPlanApi } from '../api/plan'; import { getStudyPlanApi } from '../api/studyplan'; import { getAiStatusApi } from '../api/ai'
// 按需注册 ECharts 模块，避免把整个 echarts（约 1MB）打进首屏包
echarts.use([RadarChart,RadarComponent,TooltipComponent,CanvasRenderer])
const userStore=useUserStore(); const radarChart=ref(null); const profile=ref(null); const portrait=ref(null); const hasPlan=ref(false); const hasRecords=ref(false); const aiConfigured=ref(null); let chartInstance=null
const majorName=computed(()=>profile.value?.majorName||'')
const overall=computed(()=>{const s=portrait.value?.scores;if(!s)return 0;const v=[s.programming,s.algorithm,s.project,s.competition,s.ai,s.english].filter(x=>x>0);return v.length?Math.round(v.reduce((a,b)=>a+b)/v.length):0})
const h=new Date().getHours(); const greetingText=computed(()=>h<12?'早上好':h<18?'下午好':'晚上好')
const loopNodes=[{icon:'📋',label:'学生数据'},{icon:'🧠',label:'AI画像'},{icon:'🎯',label:'AI规划'},{icon:'✏️',label:'学习执行'},{icon:'📊',label:'AI分析'},{icon:'🔄',label:'动态调整'}]
const loopDone=computed(()=>{let d=0;if(profile.value)d=1;if(portrait.value)d=2;if(hasPlan.value)d=3;if(hasRecords.value)d=5;return d})
const loopPercent=computed(()=>Math.min(100,(loopDone.value/5)*100))
const loopHint=computed(()=>{if(!portrait.value)return '完成档案初始化，开启AI成长闭环';if(!hasPlan.value)return 'AI画像已生成 — 去生成你的四年规划';if(!hasRecords.value)return '规划就绪 — 开始打卡，AI动态调整';return '闭环运转中 — AI持续分析学习数据'})
const stats=computed(()=>[{icon:Medal,value:overall.value+'分',label:'综合能力',bg:'rgba(139,195,74,.12)',color:'#8BC34A'},{icon:Reading,value:'12门',label:'推荐课程',bg:'rgba(102,187,106,.08)',color:'#66BB6A'},{icon:TrophyBase,value:'6个',label:'推荐竞赛',bg:'rgba(168,85,247,.12)',color:'#A855F7'},{icon:Timer,value:loopPercent.value+'%',label:'闭环完成',bg:'rgba(239,83,80,.08)',color:'#EF5350'}])
const quicks=[{icon:'🎯',label:'四年规划',to:'/home/plan'},{icon:'📖',label:'知识地图',to:'/home/courses'},{icon:'🏆',label:'竞赛推荐',to:'/home/competitions'},{icon:'🤖',label:'AI助手',to:'/home/assistant'},{icon:'📊',label:'学习打卡',to:'/home/growth'},{icon:'📄',label:'AI简历',to:'/home/resume'}]
onMounted(async()=>{try{profile.value=(await getProfileApi()).data}catch(e){}try{portrait.value=(await getPortraitApi()).data}catch(e){}try{await getPlanApi();hasPlan.value=true}catch(e){}try{const p=(await getStudyPlanApi()).data;hasRecords.value=p.length>0}catch(e){}try{aiConfigured.value=(await getAiStatusApi()).data?.configured===true}catch(e){}await nextTick();renderRadar();window.addEventListener('resize',handleResize)})
onUnmounted(()=>{window.removeEventListener('resize',handleResize);if(chartInstance){chartInstance.dispose();chartInstance=null}})
watch(portrait,async()=>{await nextTick();renderRadar()})
function handleResize(){chartInstance?.resize()}
function renderRadar(){
  if(!radarChart.value)return
  if(!chartInstance)chartInstance=echarts.init(radarChart.value)
  const s=portrait.value?.scores||{}
  // 维度名随专业变化：土木专业不该看到「编程 / 算法」这种无关标签，
  // 后端在降级画像里会给出 dimensionLabels，没有时回退到计算机方向的默认值
  const labels=portrait.value?.dimensionLabels||['编程','算法','项目','竞赛','AI','英语']
  chartInstance.setOption({
    radar:{
      indicator:labels.slice(0,6).map(name=>({name,max:100})),
      center:['50%','52%'],radius:'65%',
      axisName:{color:'rgba(255,255,255,.3)',fontSize:12},
      splitArea:{areaStyle:{color:['rgba(139,195,74,.01)','rgba(139,195,74,.03)']}}
    },
    series:[{type:'radar',data:[{
      value:[s.programming||20,s.algorithm||20,s.project||20,s.competition||20,s.ai||20,s.english||20],
      areaStyle:{color:'rgba(139,195,74,.15)'},
      lineStyle:{color:'#8BC34A',width:2},
      itemStyle:{color:'#8BC34A'}
    }]}]
  },true)
}
</script>

<style scoped>
.dashboard{display:flex;flex-direction:column;gap:24px}
.ai-guide{display:flex;align-items:center;gap:12px;padding:12px 16px;border-radius:var(--radius);background:rgba(245,165,36,.08);border:1px solid rgba(245,165,36,.2);color:#F5C97A}
.ai-guide .ag-text{display:flex;flex-direction:column;gap:3px;flex:1}
.ai-guide b{font-weight:600;font-size:13px}
.ai-guide span{color:var(--mist);font-size:12.5px;line-height:1.5}
.ai-guide .el-button{flex-shrink:0}
.welcome{display:flex;align-items:flex-start;justify-content:space-between;padding:8px 0 0}.wl-left{flex:1}.wl-greet{font-size:13px;color:var(--mist);font-weight:400;margin-bottom:4px}.wl-left h1{font-size:30px;font-weight:300;color:#fff;margin-bottom:8px;letter-spacing:.02em}.wl-desc{font-size:14px;color:var(--mist);max-width:500px;line-height:1.7;font-weight:300}.wl-meta{display:flex;align-items:center;gap:8px;margin-top:10px;font-size:12px;color:var(--fog)}.wl-sep{width:3px;height:3px;border-radius:50%;background:rgba(255,255,255,.08)}.wl-st{color:#66BB6A}
.ring{position:relative;width:120px;height:120px;flex-shrink:0}.ring-fill{transition:stroke-dashoffset 1.2s cubic-bezier(.4,0,.2,1)}.ring-c{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);text-align:center}.ring-n{display:block;font-size:26px;font-weight:300;color:#8BC34A}.ring-l{display:block;font-size:10px;color:var(--fog);margin-top:2px;letter-spacing:.06em}
.loop{background:var(--glass);border:1px solid var(--border);border-radius:var(--radius-lg);padding:24px 32px 18px;backdrop-filter:blur(24px)}.loop-track{display:flex;align-items:center;justify-content:space-between}.ln{display:flex;flex-direction:column;align-items:center;gap:6px;font-size:11px;color:rgba(255,255,255,.08);text-align:center;flex:1;opacity:0;animation:fadein .4s cubic-bezier(.22,.61,.36,1) forwards;animation-delay:calc(var(--i)*.12s)}.ln.done{color:#8BC34A}.ln-dot{width:4px;height:4px;border-radius:50%;background:rgba(255,255,255,.08)}.ln.done .ln-dot{background:#8BC34A}.ln-ico{font-size:20px;filter:grayscale(1);opacity:.3;transition:all .4s}.ln.done .ln-ico{filter:grayscale(0);opacity:1}.ln-lbl{font-weight:400}.ln.done .ln-lbl{font-weight:500}.loop-bar{height:2px;background:rgba(255,255,255,.03);border-radius:1px;margin:14px 0 6px;overflow:hidden}.loop-fill{height:100%;border-radius:1px;background:#8BC34A;transition:width .8s cubic-bezier(.4,0,.2,1)}.loop-hint{text-align:center;font-size:11px;color:var(--fog);font-weight:300}@keyframes fadein{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}.st{display:flex;align-items:center;gap:10px;padding:14px 16px;border-radius:var(--radius);background:var(--glass);border:1px solid var(--border);backdrop-filter:blur(24px);transition:border-color .3s}.st:hover{border-color:rgba(255,255,255,.08)}.st-ic{width:34px;height:34px;border-radius:8px;display:flex;align-items:center;justify-content:center}.st-v{display:block;font-size:16px;font-weight:500;color:#fff;line-height:1.2}.st-l{display:block;font-size:10px;color:var(--fog);margin-top:1px;letter-spacing:.04em}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;align-items:start;margin-bottom:32px}.ct{font-size:14px;font-weight:400;color:#fff;letter-spacing:.02em}.pt{font-size:13px;color:var(--mist);line-height:1.75;margin-bottom:14px;font-weight:300}.trs{display:flex;flex-direction:column;gap:8px}.tr{display:flex;align-items:flex-start;gap:8px;padding:8px 10px;border-radius:6px;font-size:12px}.tr.good{background:rgba(102,187,106,.08)}.tr.warn{background:rgba(239,83,80,.08)}.tr-l{font-weight:500;color:#fff;flex-shrink:0;min-width:32px}.tr span:last-child{color:var(--mist);line-height:1.6;font-weight:300}.suggs{display:flex;flex-direction:column;gap:6px}.sg{display:flex;align-items:flex-start;gap:10px;padding:8px 12px;border-radius:6px;font-size:12px;color:var(--mist);line-height:1.6;background:rgba(255,255,255,.02);font-weight:300}.sg-n{width:18px;height:18px;border-radius:4px;display:flex;align-items:center;justify-content:center;background:#8BC34A;color:#fff;font-size:10px;font-weight:500;flex-shrink:0}.radar-box{width:100%;height:280px}.qks{display:grid;grid-template-columns:1fr 1fr;gap:6px}.qk{display:flex;align-items:center;gap:8px;padding:10px 12px;border-radius:8px;cursor:pointer;font-size:12px;color:var(--mist);background:rgba(255,255,255,.015);border:1px solid rgba(255,255,255,.03);transition:all .3s;font-weight:300}.qk:hover{border-color:rgba(255,255,255,.1);color:#fff}.qk-ic{font-size:15px}

/* 移动端：统计卡两列，主内容单列堆叠 */
@media (max-width:820px){
  .stats{grid-template-columns:repeat(2,1fr)}
  .grid{grid-template-columns:1fr}
  .welcome{flex-direction:column;gap:18px}
  .wl-left h1{font-size:24px}
  .ring{width:96px;height:96px}
  .loop{padding:18px 16px 14px}
  .ln-lbl{display:none}
  .ln-ico{font-size:18px}
}
</style>
