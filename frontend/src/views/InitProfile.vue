<template>
  <div class="init-page">
    <AppBackground />
    <div class="init-card">
      <div class="init-head">
        <span class="ih-badge">AI</span>
        <h2>{{ isEdit ? '编辑成长档案' : 'AI成长档案初始化' }}</h2>
        <p>{{ isEdit ? '修改你的信息，AI会重新分析并更新画像' : '帮AI了解你，给你最准的画像和最合适的规划' }}</p>
      </div>

      <div class="steps-row">
        <div class="step" v-for="(s,i) in steps" :key="i" :class="{active:i===activeStep,done:i<activeStep}" @click="i<activeStep&&(activeStep=i)">
          <div class="st-num"><el-icon v-if="i<activeStep"><Check/></el-icon><span v-else>{{i+1}}</span></div>
          <div class="st-txt"><span class="st-n">{{s.title}}</span><span class="st-d">{{s.desc}}</span></div>
        </div>
      </div>
      <div class="steps-bar"><div class="steps-fill" :style="{width:(activeStep/(steps.length-1))*100+'%'}"></div></div>

      <div v-if="activeStep===0" class="step-body">
        <el-form ref="f1" :model="form" :rules="r1" label-width="80px">
          <el-form-item label="学校" prop="school">
            <el-select v-model="form.school" placeholder="搜索你的大学" size="large" style="width:100%" filterable remote :remote-method="searchSchool" :loading="schoolLoading">
              <el-option v-for="u in schoolOptions" :key="u" :label="u" :value="u"/>
            </el-select>
          </el-form-item>
          <el-form-item label="专业" prop="majorId">
            <el-select v-model="form.majorId" placeholder="搜索或选择专业" size="large" style="width:100%" filterable :loading="majorLoading">
              <el-option v-for="m in majorOptions" :key="m.id" :label="m.name" :value="m.id">
                <span>{{ m.name }}</span>
                <span class="opt-cat">{{ m.category }}</span>
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="年级">
            <div class="grades">
              <div v-for="g in grades" :key="g" class="gr" :class="{picked:form.grade===g}" @click="form.grade=g"><span>{{g}}</span></div>
            </div>
          </el-form-item>
          <el-form-item label="成绩水平">
            <el-select v-model="form.gpa" placeholder="当前成绩水平" size="large" style="width:100%">
              <el-option label="优秀 (前20%)" value="优秀"/><el-option label="良好 (前50%)" value="良好"/>
              <el-option label="中等" value="中等"/><el-option label="待提升" value="待提升"/>
            </el-select>
          </el-form-item>
        </el-form>
      </div>

      <div v-if="activeStep===1" class="step-body">
        <p class="step-hint">诚实评估就行，零基础也没关系，AI会根据你的起点定制路线</p>
        <div class="skill-scope" v-if="currentTemplate">
          <el-icon><InfoFilled /></el-icon>
          <span>当前按「<b>{{ majorNameOf(form.majorId) || '未选择专业' }}</b>」匹配到 <b>{{ currentTemplate.name }}</b> 能力项，更换专业会自动切换</span>
        </div>
        <div class="skills">
          <div class="sk" v-for="it in currentTemplate.skills" :key="it.key">
            <span class="sk-lbl">{{ it.emoji }} {{ it.label }}</span>
            <el-radio-group v-model="skillValues[it.key]" size="small">
              <el-radio-button v-for="lv in LEVEL_OPTIONS" :key="lv.value" :value="lv.value">{{ lv.label }}</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </div>

      <div v-if="activeStep===2" class="step-body">
        <p class="step-hint">选择你感兴趣的方向，AI会据此推荐学习路线和竞赛</p>
        <el-checkbox-group v-model="form.interests" class="interests"><el-checkbox v-for="it in currentTemplate.interests" :key="it" :label="it" :value="it" border/></el-checkbox-group>
      </div>

      <div v-if="activeStep===3" class="step-body">
        <p class="step-hint">不用现在就决定，AI会根据你的情况给出分析</p>
        <div class="goals"><div v-for="it in goals" :key="it.value" class="gl" :class="{picked:form.careerGoal===it.value}" @click="form.careerGoal=it.value"><span class="gl-emoji">{{it.icon}}</span><span class="gl-name">{{it.label}}</span><span class="gl-desc">{{it.desc}}</span></div></div>
      </div>

      <div class="step-acts">
        <el-button v-if="activeStep>0" @click="activeStep--" size="large">上一步</el-button><span v-else></span>
        <el-button v-if="activeStep<3" type="primary" size="large" @click="nextStep">下一步</el-button>
        <el-button v-if="activeStep===3" type="primary" size="large" @click="handleSubmit" :loading="submitting">{{submitting?'AI正在生成...':(isEdit?'保存修改，重新生成画像':'完成，生成画像与规划')}}</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref,reactive,computed,watch,onMounted } from 'vue'; import { useRouter,useRoute } from 'vue-router'; import { ElMessage } from 'element-plus'; import { Check,InfoFilled } from '@element-plus/icons-vue'; import AppBackground from '../components/AppBackground.vue'; import { saveProfileApi,generatePortraitApi,getProfileApi } from '../api/profile'; import { generatePlanApi } from '../api/plan'; import { getMajorsApi } from '../api/major'; import { universities } from '../data/universities'; import { resolveSkillTemplate,LEVEL_OPTIONS } from '../data/skillTemplates'
const router=useRouter(); const route=useRoute(); const activeStep=ref(0); const submitting=ref(false); const isEdit=ref(false); const schoolLoading=ref(false); const schoolOptions=ref(universities.slice(0,80))
const majorOptions=ref([]); const majorLoading=ref(false)
const steps=[{title:'基础信息',desc:'学校与专业'},{title:'学习情况',desc:'能力评估'},{title:'兴趣方向',desc:'个性化推荐'},{title:'未来目标',desc:'路线规划'}]
const form=reactive({school:'',majorId:'',grade:'',gpa:'',interests:[],careerGoal:''})
// 能力自评项与兴趣方向都随专业变化：
// 计算机/电子信息方向沿用数据库已有的 9 个字段（保持历史数据兼容），
// 其它方向使用通用模板，结果打包成 JSON 存进 skillAssessment 字段。
const skillValues=reactive({})
const currentTemplate=computed(()=>resolveSkillTemplate(majorNameOf(form.majorId)))
function majorNameOf(id){const m=majorOptions.value.find(x=>x.id===id);return m?m.name:''}
function resetSkillValues(source){
  const tpl=currentTemplate.value
  Object.keys(skillValues).forEach(k=>delete skillValues[k])
  tpl.skills.forEach(s=>{skillValues[s.key]=(source&&source[s.key])||'BEGINNER'})
}
// 换专业时清空已选项，避免把「Java基础」的评分带到「药理学」上
watch(()=>currentTemplate.value.id,(n,o)=>{if(o&&n!==o){resetSkillValues();form.interests=[]}})
const goals=[{value:'就业',label:'就业',icon:'💼',desc:'进入企业'},{value:'考研',label:'考研',icon:'📚',desc:'继续深造'},{value:'保研',label:'保研',icon:'⭐',desc:'推免读研'},{value:'考公',label:'考公',icon:'🏛',desc:'公务员'},{value:'创业',label:'创业',icon:'🚀',desc:'自主创业'},{value:'暂未确定',label:'暂未确定',icon:'🤔',desc:'先探索'}]
const grades=['大一','大二','大三','大四','研一','研二','研三']
const r1={school:[{required:true,message:'请选择学校',trigger:'change'}],majorId:[{required:true,message:'请选择专业',trigger:'change'}]}

// 专业列表统一由后端 major 表提供（175 个专业，按学科门类排序），
// value 使用 major.id，与课程、规划等模块共用同一套 ID，不再本地拼接。
async function loadMajors(){
  majorLoading.value=true
  try{
    const res=await getMajorsApi()
    majorOptions.value=res.data||[]
  }catch(e){
    ElMessage.error('专业列表加载失败，请确认后端服务已启动')
  }finally{
    majorLoading.value=false
  }
}

function searchSchool(q){
  schoolLoading.value=true
  if(!q){schoolOptions.value=universities.slice(0,80);schoolLoading.value=false;return}
  schoolOptions.value=universities.filter(u=>u.includes(q)).slice(0,60)
  schoolLoading.value=false
}

onMounted(async()=>{
  // 必须先拿到专业列表，才能确定该用哪一套能力自评项
  await loadMajors()
  try{
    const res=await getProfileApi()
    const data=res.data
    if(data){
      isEdit.value=true
      Object.assign(form,{
        school:data.school||'',majorId:data.majorId||'',grade:data.grade||'',gpa:data.gpa||'',
        interests:data.interests?JSON.parse(data.interests):[],careerGoal:data.careerGoal||''
      })
      // 计算机/电子信息方向：评分就在 student_profile 的那 9 个字段上
      resetSkillValues(data)
      // 其它方向：评分打包在 skillAssessment 里，按标签回填
      if(data.skillAssessment){
        try{
          const saved=JSON.parse(data.skillAssessment)
          const byLabel={}
          ;(saved.items||[]).forEach(i=>{byLabel[i.label]=i.value})
          currentTemplate.value.skills.forEach(s=>{if(byLabel[s.label])skillValues[s.key]=byLabel[s.label]})
        }catch(e){}
      }
    }else{
      resetSkillValues()
    }
  }catch(e){
    resetSkillValues()
  }
})

function nextStep(){if(activeStep.value===0){if(!form.school||!form.majorId||!form.grade){ElMessage.warning('请完善基础信息');return}}activeStep.value++}

async function handleSubmit(){
  if(!form.careerGoal){ElMessage.warning('请选择你的未来目标');return}
  submitting.value=true
  try{
    const tpl=currentTemplate.value
    const payload={school:form.school,majorId:form.majorId,grade:form.grade,gpa:form.gpa,interests:JSON.stringify(form.interests),careerGoal:form.careerGoal}
    if(tpl.isIT){
      // 计算机/电子信息方向：沿用数据库已有的 9 个字段
      Object.assign(payload,skillValues)
    }else{
      // 其它方向：把自评项打包成 JSON，标签一起存下来，便于回显与 AI 理解
      payload.skillAssessment=JSON.stringify({
        template:tpl.name,
        items:tpl.skills.map(s=>({label:s.label,value:skillValues[s.key]||'BEGINNER'}))
      })
    }
    await saveProfileApi(payload)
    await generatePortraitApi()
    // 画像生成后顺带把四年规划也建好：否则回到首页流程条会停在「AI规划」那一步，
    // 后面的学习执行 / 分析环节全是灰的，容易被误解为「还没有这些功能」。
    // 规划生成失败不影响档案与画像的保存结果，仅回首页时会提示补生成。
    let planReady=true
    try{ await generatePlanApi() }catch(e){ planReady=false }
    ElMessage.success(planReady
      ? (isEdit.value?'档案已更新，AI已重新生成画像与四年规划':'AI画像与四年规划已生成')
      : '画像已生成，四年规划稍后可在「AI成长规划」页生成')
    setTimeout(()=>router.push('/home'),500)
  }catch(e){ElMessage.error('保存失败，请重试')}finally{submitting.value=false}
}
</script>

<style scoped>
.init-page{min-height:calc(100vh - 120px);display:flex;align-items:flex-start;justify-content:center;padding:40px 20px}
.init-card{width:700px;max-width:100%;background:var(--glass);border-radius:var(--radius-xl);padding:38px 44px;border:1px solid var(--border);backdrop-filter:blur(32px);-webkit-backdrop-filter:blur(32px);position:relative;z-index:1}
.init-head{text-align:center;margin-bottom:28px}
.ih-badge{display:inline-flex;width:48px;height:48px;border-radius:13px;background:#8BC34A;color:#fff;font-size:19px;font-weight:800;align-items:center;justify-content:center;margin-bottom:12px}
.init-head h2{font-size:21px;font-weight:300;color:#fff;margin-bottom:4px;letter-spacing:.02em}
.init-head p{font-size:13px;color:var(--mist);font-weight:300}
.steps-row{display:flex;position:relative;margin-bottom:8px}
.step{flex:1;text-align:center;display:flex;flex-direction:column;align-items:center;gap:6px;position:relative;z-index:1;cursor:pointer}
.st-num{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.04);color:var(--fog);font-weight:700;font-size:13px;transition:all var(--transition)}
.step.active .st-num{background:#8BC34A;color:#fff}.step.done .st-num{background:#66BB6A;color:#fff}
.st-n{display:block;font-size:12px;font-weight:600;color:var(--fog)}.st-d{display:block;font-size:11px;color:var(--fog);margin-top:1px}
.step.active .st-n{color:#8BC34A}.step.done .st-n{color:#66BB6A}
.steps-bar{height:3px;background:rgba(255,255,255,.04);border-radius:2px;margin-bottom:32px;overflow:hidden}
.steps-fill{height:100%;background:#8BC34A;border-radius:2px;transition:width .4s ease}
.step-body{min-height:260px}
.step-hint{font-size:13px;color:var(--mist);margin-bottom:20px;font-weight:300}
.grades{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}
.gr{padding:10px 4px;border-radius:8px;text-align:center;border:1px solid var(--border);cursor:pointer;transition:all var(--transition);font-size:13px;color:var(--mist)}
.gr:hover{border-color:rgba(255,255,255,.15);color:#fff}
.gr.picked{border-color:#8BC34A;background:rgba(139,195,74,.1);color:#8BC34A}
.skill-scope{display:flex;align-items:center;gap:8px;margin-bottom:18px;padding:10px 14px;border-radius:8px;font-size:12.5px;line-height:1.55;color:var(--mist);background:rgba(139,195,74,.07);border:1px solid rgba(139,195,74,.16)}
.skill-scope b{color:var(--signal);font-weight:600}
.skills{display:flex;flex-direction:column;gap:12px}
.sk{display:flex;align-items:center;justify-content:space-between}
.sk-lbl{width:105px;font-size:13px;color:var(--mist);flex-shrink:0}
.interests{display:flex;flex-wrap:wrap;gap:9px}
.opt-cat{float:right;color:var(--fog);font-size:12px;margin-left:12px}
.goals{display:grid;grid-template-columns:repeat(3,1fr);gap:11px}
.gl{padding:18px 10px;border-radius:var(--radius);text-align:center;border:1px solid var(--border);cursor:pointer;transition:all var(--transition)}
.gl:hover{border-color:rgba(255,255,255,.15)}.gl.picked{border-color:#8BC34A;background:rgba(139,195,74,.1)}
.gl-emoji{display:block;font-size:26px;margin-bottom:4px}.gl-name{display:block;font-size:14px;font-weight:500;color:#fff}.gl-desc{display:block;font-size:11px;color:var(--mist);margin-top:2px}
.step-acts{display:flex;justify-content:space-between;margin-top:28px}

@media (max-width:820px){
  .init-page{padding:16px 0}
  .init-card{width:100%;padding:26px 20px}
  .grades{grid-template-columns:repeat(2,1fr)}
  .goals{grid-template-columns:repeat(2,1fr)}
  .sk{flex-direction:column;align-items:flex-start;gap:6px}
  .sk-lbl{width:auto}
  .st-d{display:none}
}
</style>
