<template>
  <div class="plan-page">
    <div class="plan-hero">
      <h1>AI大学四年规划</h1>
      <p>基于你的专业、基础和兴趣，AI生成专属成长路线。每个阶段有明确目标、课程、技能和竞赛建议。</p>
      <el-button v-if="!plan" type="primary" size="large" @click="handleGenerate" :loading="generating">{{generating?'AI正在生成...':'生成我的四年规划'}}</el-button>
    </div>
    <div v-if="plan" class="plan-intro"><p>{{ plan.overview }}</p></div>
    <div v-if="plan" class="years">
      <div class="yc" v-for="(year,key,idx) in years" :key="key" :class="{current:isCurrentYear(key)}">
        <div class="yc-top"><span class="yc-badge" :style="{background:colors[idx]}">{{idx+1}}</span><div class="yc-head"><h3>{{labels[key]}} · {{year.theme}}</h3><el-tag v-if="isCurrentYear(key)" size="small" effect="dark" round>当前阶段</el-tag></div></div>
        <div class="yc-body">
          <div class="yg" v-if="year.goals?.length"><span class="yl">目标</span><div class="yt"><span class="yt-t" v-for="g in year.goals" :key="g">{{g}}</span></div></div>
          <div class="yg" v-if="year.courses?.length"><span class="yl">课程</span><div class="yt"><span class="yt-t course" v-for="c in year.courses" :key="c">{{c}}</span></div></div>
          <div class="yg" v-if="year.skills?.length"><span class="yl">技能</span><div class="yt"><span class="yt-t skill" v-for="s in year.skills" :key="s">{{s}}</span></div></div>
          <div class="yg" v-if="year.competitions?.length"><span class="yl">竞赛</span><div class="yt"><span class="yt-t comp" v-for="c in year.competitions" :key="c">{{c}}</span></div></div>
          <div v-if="year.tips" class="yc-tip">{{year.tips}}</div>
        </div>
      </div>
    </div>
    <div v-if="plan" class="plan-foot">
      <el-card v-if="plan.risks?.length" shadow="never"><template #header><span class="ct">风险提醒</span></template><div class="rks"><div class="rk" v-for="(r,i) in plan.risks" :key="i"><span class="rk-n">{{i+1}}</span><span>{{r}}</span></div></div></el-card>
      <el-card v-if="plan.certificates?.length" shadow="never"><template #header><span class="ct">推荐证书</span></template><div class="certs"><div class="ce" v-for="(c,i) in plan.certificates" :key="i"><span>{{['📜','🏅','📋','💼'][i]||'📌'}}</span> {{c}}</div></div></el-card>
    </div>
    <el-empty v-if="!plan&&!generating" description="让AI为你生成专属大学四年规划" :image-size="80"/>
  </div>
</template>

<script setup>
import { ref,onMounted,computed } from 'vue'; import { generatePlanApi,getPlanApi } from '../api/plan'; import { getProfileApi } from '../api/profile'; import { ElMessage } from 'element-plus'
const plan=ref(null); const generating=ref(false)
const labels={freshman:'大一',sophomore:'大二',junior:'大三',senior:'大四'}
const colors=['var(--signal)','#66BB6A','#EF5350','#B8860B']
const currentGrade=ref('')
const years=computed(()=>{if(!plan.value)return{};const{overview,risks,certificates,...y}=plan.value;return y})
function isCurrentYear(k){return labels[k]===currentGrade.value}
onMounted(async()=>{
  try{ const profile=(await getProfileApi()).data; currentGrade.value=profile?.grade||'' }catch(e){}
  try{ plan.value=(await getPlanApi()).data }catch(e){}
})
async function handleGenerate(){generating.value=true;try{const res=await generatePlanApi();plan.value=res.data;ElMessage.success('AI四年规划生成完成')}catch(e){ElMessage.error('生成失败，请确保已完成档案初始化')}finally{generating.value=false}}
</script>

<style scoped>
.plan-page{max-width:860px;margin:0 auto}
.plan-hero{text-align:center;padding:32px 0 16px}
.plan-hero h1{font-size:26px;font-weight:700;color:var(--ink);margin-bottom:6px}
.plan-hero p{color:var(--mist);font-size:14px;max-width:500px;margin:0 auto 16px;line-height:1.6}
.plan-intro{padding:14px 20px;border-radius:var(--radius);background:var(--navy-pale);border:1px solid rgba(139,195,74,.1);margin-bottom:24px;font-size:14px;color:var(--mist);line-height:1.7}
.years{display:flex;flex-direction:column;gap:12px;margin-bottom:24px}
.yc{background:var(--glass);border-radius:var(--radius-lg);border:1px solid var(--border);padding:20px 24px;transition:box-shadow var(--transition)}
.yc:hover{box-shadow:var(--shadow-sm)}
.yc.current{border-color:var(--signal);box-shadow:0 0 0 2px rgba(139,195,74,.06)}
.yc-top{display:flex;align-items:center;gap:12px;margin-bottom:14px}
.yc-badge{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:15px;font-weight:700;flex-shrink:0}
.yc-head{flex:1;display:flex;align-items:center;gap:8px}
.yc-head h3{font-size:16px;font-weight:600;color:var(--ink)}
.yc-body{display:flex;flex-direction:column;gap:10px}
.yg{display:flex;align-items:flex-start;gap:10px}
.yl{font-size:12px;font-weight:600;color:var(--mist);min-width:32px;padding-top:4px;flex-shrink:0}
.yt{display:flex;flex-wrap:wrap;gap:5px}
.yt-t{padding:3px 10px;border-radius:20px;font-size:12.5px;background:var(--glass);color:var(--mist)}
.yt-t.course{background:var(--navy-pale);color:var(--signal)}
.yt-t.skill{background:var(--sage-pale);color:#66BB6A}
.yt-t.comp{background:var(--garnet-pale);color:#EF5350}
.yc-tip{padding:8px 12px;border-radius:6px;background:rgba(245,165,36,.10);border-left:2px solid rgba(245,165,36,.45);font-size:12.5px;color:#F5C97A;line-height:1.6}
.plan-foot{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:28px}
.ct{font-size:14px;font-weight:600;color:var(--ink)}
.rks{display:flex;flex-direction:column;gap:8px}
.rk{display:flex;align-items:center;gap:8px;font-size:13.5px;color:var(--mist)}
.rk-n{width:20px;height:20px;border-radius:5px;font-size:11px;font-weight:700;background:var(--garnet-pale);color:#EF5350;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.certs{display:grid;grid-template-columns:1fr 1fr;gap:7px}
.ce{display:flex;align-items:center;gap:6px;padding:9px 10px;border-radius:6px;font-size:13px;color:var(--mist);background:var(--glass)}

@media (max-width:820px){
  .plan-hero h1{font-size:22px}
  .plan-foot{grid-template-columns:1fr}
  .certs{grid-template-columns:1fr}
  .yc{padding:16px 16px}
  .yc-head h3{font-size:14.5px}
}
</style>
