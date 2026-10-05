<template>
  <div class="init-page">
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
        <div class="skills"><div class="sk" v-for="it in skillItems" :key="it.key"><span class="sk-lbl">{{it.emoji}} {{it.label}}</span><el-radio-group v-model="form[it.key]" size="small"><el-radio-button value="BEGINNER">零基础</el-radio-button><el-radio-button value="BASIC">入门</el-radio-button><el-radio-button value="INTERMEDIATE">中等</el-radio-button><el-radio-button value="ADVANCED">熟练</el-radio-button></el-radio-group></div></div>
      </div>

      <div v-if="activeStep===2" class="step-body">
        <p class="step-hint">选择你感兴趣的方向，AI会据此推荐学习路线和竞赛</p>
        <el-checkbox-group v-model="form.interests" class="interests"><el-checkbox v-for="it in interestOptions" :key="it" :label="it" :value="it" border/></el-checkbox-group>
      </div>

      <div v-if="activeStep===3" class="step-body">
        <p class="step-hint">不用现在就决定，AI会根据你的情况给出分析</p>
        <div class="goals"><div v-for="it in goals" :key="it.value" class="gl" :class="{picked:form.careerGoal===it.value}" @click="form.careerGoal=it.value"><span class="gl-emoji">{{it.icon}}</span><span class="gl-name">{{it.label}}</span><span class="gl-desc">{{it.desc}}</span></div></div>
      </div>

      <div class="step-acts">
        <el-button v-if="activeStep>0" @click="activeStep--" size="large">上一步</el-button><span v-else></span>
        <el-button v-if="activeStep<3" type="primary" size="large" @click="nextStep">下一步</el-button>
        <el-button v-if="activeStep===3" type="primary" size="large" @click="handleSubmit" :loading="submitting">{{submitting?'AI正在分析...':(isEdit?'保存修改，重新生成画像':'完成，生成AI画像')}}</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref,reactive,onMounted } from 'vue'; import { useRouter,useRoute } from 'vue-router'; import { ElMessage } from 'element-plus'; import { Check } from '@element-plus/icons-vue'; import { saveProfileApi,generatePortraitApi,getProfileApi } from '../api/profile'; import { getMajorsApi } from '../api/major'; import { universities } from '../data/universities'
const router=useRouter(); const route=useRoute(); const activeStep=ref(0); const submitting=ref(false); const isEdit=ref(false); const schoolLoading=ref(false); const schoolOptions=ref(universities.slice(0,80))
const majorOptions=ref([]); const majorLoading=ref(false)
const steps=[{title:'基础信息',desc:'学校与专业'},{title:'学习情况',desc:'能力评估'},{title:'兴趣方向',desc:'个性化推荐'},{title:'未来目标',desc:'路线规划'}]
const skillItems=[{key:'programmingLevel',label:'编程基础',emoji:'💻'},{key:'javaLevel',label:'Java基础',emoji:'☕'},{key:'pythonLevel',label:'Python基础',emoji:'🐍'},{key:'cppLevel',label:'C/C++基础',emoji:'⚡'},{key:'dsLevel',label:'数据结构',emoji:'🔗'},{key:'dbLevel',label:'数据库',emoji:'🗄'},{key:'webLevel',label:'Web开发',emoji:'🌐'},{key:'aiLevel',label:'AI基础',emoji:'🤖'},{key:'englishLevel',label:'英语水平',emoji:'📖'}]
const interestOptions=['Web开发','AI/机器学习','大数据','Java后端','Python','算法/ACM','前端开发','后端开发','数据分析','计算机视觉','NLP','网络安全','云计算','嵌入式','游戏开发']
const goals=[{value:'就业',label:'就业',icon:'💼',desc:'进入企业'},{value:'考研',label:'考研',icon:'📚',desc:'继续深造'},{value:'保研',label:'保研',icon:'⭐',desc:'推免读研'},{value:'考公',label:'考公',icon:'🏛',desc:'公务员'},{value:'创业',label:'创业',icon:'🚀',desc:'自主创业'},{value:'暂未确定',label:'暂未确定',icon:'🤔',desc:'先探索'}]
const grades=['大一','大二','大三','大四','研一','研二','研三']
const form=reactive({school:'',majorId:'',grade:'',gpa:'',programmingLevel:'BEGINNER',javaLevel:'BEGINNER',pythonLevel:'BEGINNER',cppLevel:'BEGINNER',dsLevel:'BEGINNER',dbLevel:'BEGINNER',webLevel:'BEGINNER',aiLevel:'BEGINNER',englishLevel:'BEGINNER',interests:[],careerGoal:''})
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
  loadMajors()
  try{
    const res=await getProfileApi()
    if(res.data){
      isEdit.value=true
      Object.assign(form,{
        school:res.data.school||'',majorId:res.data.majorId||'',grade:res.data.grade||'',gpa:res.data.gpa||'',
        programmingLevel:res.data.programmingLevel||'BEGINNER',javaLevel:res.data.javaLevel||'BEGINNER',
        pythonLevel:res.data.pythonLevel||'BEGINNER',cppLevel:res.data.cppLevel||'BEGINNER',
        dsLevel:res.data.dsLevel||'BEGINNER',dbLevel:res.data.dbLevel||'BEGINNER',
        webLevel:res.data.webLevel||'BEGINNER',aiLevel:res.data.aiLevel||'BEGINNER',
        englishLevel:res.data.englishLevel||'BEGINNER',
        interests:res.data.interests?JSON.parse(res.data.interests):[],careerGoal:res.data.careerGoal||''
      })
    }
  }catch(e){}
})

function nextStep(){if(activeStep.value===0){if(!form.school||!form.majorId||!form.grade){ElMessage.warning('请完善基础信息');return}}activeStep.value++}

async function handleSubmit(){
  if(!form.careerGoal){ElMessage.warning('请选择你的未来目标');return}
  submitting.value=true
  try{
    await saveProfileApi({school:form.school,majorId:form.majorId,grade:form.grade,gpa:form.gpa,programmingLevel:form.programmingLevel,javaLevel:form.javaLevel,pythonLevel:form.pythonLevel,cppLevel:form.cppLevel,dsLevel:form.dsLevel,dbLevel:form.dbLevel,webLevel:form.webLevel,aiLevel:form.aiLevel,englishLevel:form.englishLevel,interests:JSON.stringify(form.interests),careerGoal:form.careerGoal})
    await generatePortraitApi()
    ElMessage.success(isEdit.value?'档案已更新，AI重新生成了画像':'AI画像生成完成')
    setTimeout(()=>router.push('/home'),500)
  }catch(e){ElMessage.error('保存失败，请重试')}finally{submitting.value=false}
}
</script>

<style scoped>
.init-page{min-height:calc(100vh - 120px);display:flex;align-items:flex-start;justify-content:center;padding:40px 20px}
.init-card{width:700px;background:var(--glass);border-radius:var(--radius-xl);padding:38px 44px;border:1px solid var(--border);backdrop-filter:blur(32px);-webkit-backdrop-filter:blur(32px)}
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
