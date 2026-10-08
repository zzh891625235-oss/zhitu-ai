<template>
  <div class="void" @mousemove="onMouseMove">
    <iframe src="/sylva/scene.html" class="bg-sylva" loading="eager" scrolling="no" allow="autoplay"></iframe>
    <div class="bg-sylva-fade"></div>
    <div class="ambient-light" :style="{background: `radial-gradient(ellipse 100% 100% at ${mx}% ${my}%, rgba(139,195,74,.04) 0%, transparent 55%)`}"></div>

    <header class="nav">
      <div class="nav-inner">
        <a href="/" class="logo"><span class="logo-dot"></span><span class="logo-word">ZHITU</span></a>
        <div class="nav-links"><a href="#about">关于</a><a href="#features">功能</a><a href="#contact">开始</a></div>
        <div class="nav-actions">
          <template v-if="userStore.token"><router-link to="/home" class="nav-cta">控制台</router-link></template>
          <template v-else><span class="nav-link" @click="showLogin = true">登录</span><router-link to="/register" class="nav-cta">免费注册</router-link></template>
        </div>
      </div>
    </header>

    <section class="hero">
      <div class="hero-content">
        <p class="hero-label">AI · 大学成长规划</p>
        <h1 class="hero-headline">每一名大学生<br>都值得一条<span class="txt-signal">专属成长路线</span></h1>
        <p class="hero-sub">智途用AI分析你的专业、技能和目标，自动生成画像、四年规划、竞赛推荐。<br>并根据你的真实进度，持续动态调整。</p>
        <div class="hero-action">
          <router-link to="/register" class="cta"><span>开始你的成长之旅</span><svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></router-link>
          <span class="cta-alt" @click="showLogin = true">已有账号？登录</span>
        </div>
      </div>
      <div class="hero-glow"></div>
    </section>

    <section id="about" class="panel"><div class="panel-inner"><div class="panel-grid-2"><div><p class="panel-label">我们做什么</p><h2 class="panel-heading">AI不只是聊天。<br>它是你的<span class="txt-signal">大学成长规划师</span>。</h2></div><div class="panel-desc"><p>从你填写档案的那一刻起，AI就开始工作——分析你的专业基础、评估你的能力短板、匹配最适合的竞赛、规划四年学习路线。当你的学习数据持续反馈，AI会动态调整后续计划。</p><p>这不是一个套壳的AI对话框。这是一个完整的、持续运转的、以你为中心的成长系统。</p></div></div><div class="panel-grid-3"><div class="pg3-item"><span class="pg3-num">10+</span><span class="pg3-lbl">AI 核心功能模块</span></div><div class="pg3-item"><span class="pg3-num">175</span><span class="pg3-lbl">个专业 · 12 大学科门类</span></div><div class="pg3-item"><span class="pg3-num">闭环</span><span class="pg3-lbl">数据 → AI → 规划 → 反馈</span></div></div></div></section>

    <section id="features" class="panel"><div class="panel-inner"><p class="panel-label">核心能力</p><div class="feat-grid"><div class="fg-item" v-for="(f,i) in features" :key="i"><span class="fg-num">{{ String(i+1).padStart(2,'0') }}</span><div class="fg-divider"></div><div><h3 class="fg-title">{{ f.title }}</h3><p class="fg-desc">{{ f.desc }}</p></div></div></div></div></section>

    <section id="contact" class="panel panel-end"><div class="panel-inner"><h2 class="end-heading">大学四年<br>从今天开始有方向。</h2><router-link to="/register" class="cta cta-large"><span>立即开始</span><svg width="18" height="18" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></router-link></div></section>

    <footer class="footer"><span>智途AI · 让每一名大学生，都拥有一份属于自己的大学四年成长路线</span></footer>

    <el-dialog v-model="showLogin" title="登录" width="360px" :close-on-click-modal="true" center>
      <el-form ref="loginForm" :model="loginData" :rules="loginRules" @keyup.enter="handleLogin" style="padding:4px">
        <el-form-item prop="phone"><el-input v-model="loginData.phone" placeholder="手机号" size="large"/></el-form-item>
        <el-form-item prop="password"><el-input v-model="loginData.password" type="password" placeholder="密码" size="large" show-password/></el-form-item>
        <el-button type="primary" size="large" style="width:100%;height:44px" @click="handleLogin" :loading="loading">登录</el-button>
      </el-form>
      <p style="text-align:center;margin-top:14px;font-size:13px;color:var(--fog)">还没有账号？<router-link to="/register" style="color:#8BC34A" @click="showLogin=false">立即注册</router-link></p>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref,reactive } from 'vue'; import { useRouter } from 'vue-router'; import { useUserStore } from '../stores/user'; import { ElMessage } from 'element-plus'; import { onMounted } from 'vue'
const router=useRouter(); const userStore=useUserStore(); const showLogin=ref(false); const loading=ref(false); const loginForm=ref(null); const mx=ref(50); const my=ref(40)
const loginData=reactive({phone:'',password:''}); const loginRules={phone:[{required:true,message:'请输入手机号',trigger:'blur'}],password:[{required:true,message:'请输入密码',trigger:'blur'}]}
const features=[{title:'AI学生画像',desc:'根据专业、技能和目标，自动生成多维度能力画像和评分。'},{title:'四年成长规划',desc:'大一到大四，每年明确的学习目标、课程、技能路线和竞赛建议。'},{title:'动态调整',desc:'学习进度实时反馈AI，计划随着你的成长不断优化。'},{title:'竞赛智能推荐',desc:'AI匹配能力画像推荐最适合的比赛，生成备赛计划。'},{title:'成长档案',desc:'学习记录、项目经历、获奖证书——完整的大学成长档案。'},{title:'AI简历生成',desc:'根据成长档案自动生成专业简历，支持导出和在线编辑。'}]
function onMouseMove(e){mx.value=(e.clientX/window.innerWidth)*100;my.value=(e.clientY/window.innerHeight)*100}
async function handleLogin(){const v=await loginForm.value?.validate().catch(()=>false);if(!v)return;loading.value=true;try{await userStore.login(loginData.phone,loginData.password);ElMessage.success('欢迎回来');showLogin.value=false;router.push('/home')}catch(e){}finally{loading.value=false}}
onMounted(()=>{if(userStore.token)userStore.fetchUserInfo()})
</script>

<style scoped>
.void{position:relative;background:#0D1110;color:#fff;font-family:'PingFang SC','Microsoft YaHei',system-ui,sans-serif;min-height:100vh;overflow-x:hidden}
.bg-sylva{position:fixed;inset:0;width:100vw;height:100vh;border:none;z-index:0;pointer-events:none;opacity:.7}
.bg-sylva-fade{position:fixed;inset:0;z-index:0;pointer-events:none;background:linear-gradient(180deg,rgba(13,17,16,.15) 0%,rgba(13,17,16,.45) 60%,rgba(13,17,16,.85) 100%)}
.ambient-light{position:fixed;inset:0;z-index:1;pointer-events:none;transition:background 1s ease-out}
.nav{position:fixed;top:0;left:0;right:0;z-index:100;padding:18px 0;background:linear-gradient(rgba(13,17,16,.88) 0%,transparent 100%);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px)}
.nav-inner{max-width:1280px;margin:0 auto;display:flex;align-items:center;padding:0 40px}
.logo{display:flex;align-items:center;gap:10px;text-decoration:none}.logo-dot{width:5px;height:5px;border-radius:50%;background:#8BC34A;animation:breathe 4s ease-in-out infinite}.logo-word{font-size:13px;font-weight:500;letter-spacing:.16em;color:#fff}
.nav-links{display:flex;gap:36px;margin-left:72px}.nav-links a,.nav-link{font-size:13px;color:var(--mist);transition:color .3s;cursor:pointer;text-decoration:none}.nav-links a:hover,.nav-link:hover{color:#fff}
.nav-actions{margin-left:auto;display:flex;align-items:center;gap:16px}.nav-cta{font-size:12.5px;font-weight:500;color:#fff;padding:6px 16px;border-radius:6px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.08);transition:all .3s;text-decoration:none}.nav-cta:hover{background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.14)}
.hero{position:relative;z-index:10;min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:120px 40px 80px;text-align:center}
.hero-content{max-width:860px;animation:reveal 1.2s cubic-bezier(.22,.61,.36,1)}.hero-label{font-size:11px;font-weight:500;letter-spacing:.2em;text-transform:uppercase;color:#8BC34A;margin-bottom:32px;opacity:.8}
.hero-headline{font-size:clamp(42px,7vw,80px);font-weight:300;line-height:1.08;letter-spacing:.02em;color:rgba(255,255,255,.95);margin-bottom:32px}.txt-signal{color:#8BC34A}
.hero-sub{font-size:17px;font-weight:300;line-height:1.75;color:var(--mist);max-width:560px;margin:0 auto 48px}
.hero-action{display:flex;flex-direction:column;align-items:center;gap:14px}.cta{display:inline-flex;align-items:center;gap:10px;font-size:16px;font-weight:400;color:#fff;padding:15px 38px;border-radius:8px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);transition:all .4s cubic-bezier(.22,.61,.36,1);text-decoration:none}.cta:hover{background:rgba(255,255,255,.1);border-color:rgba(255,255,255,.16);gap:14px}.cta-large{padding:18px 48px;font-size:18px}.cta-alt{font-size:13px;color:var(--fog);cursor:pointer;transition:color .3s}.cta-alt:hover{color:var(--mist)}
.hero-glow{position:absolute;bottom:0;left:50%;transform:translateX(-50%);width:700px;height:250px;background:radial-gradient(ellipse,rgba(139,195,74,.05) 0%,transparent 70%);pointer-events:none}
.panel{position:relative;z-index:10;padding:120px 40px}.panel-inner{max-width:960px;margin:0 auto}.panel-label{font-size:10px;font-weight:500;letter-spacing:.22em;text-transform:uppercase;color:#8BC34A;margin-bottom:28px;opacity:.7}
.panel-heading{font-size:clamp(28px,4vw,42px);font-weight:300;line-height:1.25;letter-spacing:.02em;color:rgba(255,255,255,.92)}.panel-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:60px;align-items:start}.panel-desc{display:flex;flex-direction:column;gap:18px}.panel-desc p{font-size:15px;font-weight:300;line-height:1.7;color:var(--mist)}.panel-grid-3{display:grid;grid-template-columns:repeat(3,1fr);gap:32px;margin-top:64px;padding-top:48px;border-top:1px solid rgba(255,255,255,.05)}.pg3-item{display:flex;flex-direction:column;gap:6px}.pg3-num{font-size:32px;font-weight:300;color:#fff}.pg3-lbl{font-size:11px;color:var(--fog);letter-spacing:.06em}
.feat-grid{display:flex;flex-direction:column}.fg-item{display:flex;align-items:flex-start;gap:28px;padding:28px 0;border-bottom:1px solid rgba(255,255,255,.03);transition:all .35s}.fg-item:hover{padding-left:12px;background:rgba(255,255,255,.01);border-radius:6px}.fg-num{font-size:11px;font-weight:500;color:#8BC34A;letter-spacing:.08em;min-width:24px;padding-top:5px;opacity:.6}.fg-divider{width:20px;height:1px;background:rgba(255,255,255,.08);margin-top:14px;flex-shrink:0}.fg-title{font-size:18px;font-weight:400;color:#fff;margin-bottom:4px;letter-spacing:.01em}.fg-desc{font-size:14px;font-weight:300;line-height:1.6;color:var(--mist)}
.panel-end{text-align:center;padding:160px 40px}.end-heading{font-size:clamp(34px,5vw,52px);font-weight:300;line-height:1.2;color:rgba(255,255,255,.92);margin-bottom:44px;letter-spacing:.02em}
.footer{position:relative;z-index:10;padding:40px;text-align:center;border-top:1px solid rgba(255,255,255,.03);font-size:12px;color:var(--fog);letter-spacing:.04em}
@keyframes reveal{from{opacity:0;transform:translateY(40px)}to{opacity:1;transform:translateY(0)}}

@media (max-width:820px){
  .hero-headline{font-size:34px!important}
  .panel{padding:70px 22px}
  .panel-end{padding:90px 22px}
  .panel-grid-2{grid-template-columns:1fr;gap:34px}
  .panel-grid-3{grid-template-columns:1fr;gap:22px;margin-top:40px;padding-top:32px}
  .fg-item{gap:14px;padding:20px 0}
  .fg-divider{display:none}
  .footer{padding:28px 20px}
  .cta{padding:13px 26px;font-size:15px}
  .cta-large{padding:15px 32px;font-size:16px}
}
</style>
