<template>
  <div class="auth-page">
    <AppBackground />
    <div class="auth-card">
      <div class="brand"><span class="brand-dot"></span><h1>登录</h1><p>AI大学生成长规划平台</p></div>
      <el-form ref="formRef" :model="form" :rules="rules" @keyup.enter="handleLogin">
        <div class="fg"><label>手机号</label><el-input v-model="form.phone" placeholder="输入手机号" size="large"/></div>
        <div class="fg"><label>密码</label><el-input v-model="form.password" type="password" placeholder="输入密码" size="large" show-password/></div>
        <el-button type="primary" size="large" class="submit-btn" @click="handleLogin" :loading="loading">登录</el-button>
      </el-form>
      <div class="foot"><span>还没有账号？</span><router-link to="/register" class="link">注册</router-link></div>
      <div class="demo-tip">
        <el-button text size="small" :loading="demoLoading" @click="handleDemoLogin">
          <el-icon><MagicStick /></el-icon>&nbsp;使用演示账号一键体验
        </el-button>
      </div>
    </div>
    <p class="quote">让每一名大学生，都拥有一份属于自己的大学四年成长路线</p>
  </div>
</template>

<script setup>
import { ref,reactive } from 'vue'; import { useRouter } from 'vue-router'; import { useUserStore } from '../stores/user'; import { ElMessage } from 'element-plus'; import { MagicStick } from '@element-plus/icons-vue'; import AppBackground from '../components/AppBackground.vue'
const router=useRouter(); const userStore=useUserStore(); const loading=ref(false); const formRef=ref(null); const demoLoading=ref(false)
const form=reactive({phone:'',password:''}); const rules={phone:[{required:true,message:'请输入手机号',trigger:'blur'}],password:[{required:true,message:'请输入密码',trigger:'blur'}]}
async function handleLogin(){const v=await formRef.value.validate().catch(()=>false);if(!v)return;loading.value=true;try{await userStore.login(form.phone,form.password);ElMessage.success('欢迎回来');router.push('/home')}catch(e){}finally{loading.value=false}}

// 演示账号由 database/data.sql 创建，方便评审老师快速体验完整功能
async function handleDemoLogin(){
  demoLoading.value=true
  try{
    await userStore.login('13800000000','123456')
    ElMessage.success('已进入演示账号')
    router.push('/home')
  }catch(e){
    ElMessage.warning('演示账号登录失败，请先执行 database 目录下的三个 SQL 脚本导入数据')
  }finally{demoLoading.value=false}
}
</script>

<style scoped>
.auth-page{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;background:var(--void);position:relative;padding:24px;gap:20px}
.auth-bg{position:absolute;inset:0;overflow:hidden;pointer-events:none}.bg-glow{position:absolute;top:30%;left:50%;transform:translate(-50%,-50%);width:600px;height:600px;background:radial-gradient(circle,rgba(139,195,74,.04) 0%,transparent 70%)}
.auth-card{width:380px;max-width:100%;padding:40px 34px 32px;background:var(--glass);border:1px solid var(--border);border-radius:14px;position:relative;z-index:1;backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px)}
.brand{text-align:center;margin-bottom:32px}.brand-dot{display:inline-block;width:5px;height:5px;border-radius:50%;background:#8BC34A;margin-bottom:14px;animation:breathe 4s ease-in-out infinite}.brand h1{font-size:22px;font-weight:300;color:#fff;letter-spacing:.04em}.brand p{font-size:12px;color:var(--fog);margin-top:4px;font-weight:300}
.fg{display:flex;flex-direction:column;gap:4px;margin-bottom:14px}.fg label{font-size:11px;font-weight:500;color:var(--mist);letter-spacing:.06em;text-transform:uppercase}
.submit-btn{width:100%;height:44px;font-size:14px!important;font-weight:400!important;letter-spacing:.04em}
.foot{text-align:center;margin-top:18px;font-size:13px;color:var(--fog);font-weight:300}.link{color:#8BC34A;margin-left:4px;font-weight:400}.link:hover{opacity:.8}
.demo-tip{text-align:center;margin-top:6px;padding-top:14px;border-top:1px solid var(--border-soft)}
.quote{font-size:12px;color:var(--fog);text-align:center;position:relative;z-index:1;font-weight:300;letter-spacing:.02em}

@media (max-width:480px){
  .auth-page{padding:16px}
  .auth-card{padding:30px 22px 24px}
}
</style>
