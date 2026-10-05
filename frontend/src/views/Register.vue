<template>
  <div class="auth-page">
    <div class="auth-bg"><div class="bg-glow"></div></div>
    <div class="auth-card">
      <div class="brand"><span class="brand-dot"></span><h1>创建账号</h1><p>开启你的AI成长之旅</p></div>
      <el-form ref="formRef" :model="form" :rules="rules" @keyup.enter="handleRegister">
        <div class="fg"><label>手机号</label><el-input v-model="form.phone" placeholder="输入手机号" size="large"/></div>
        <div class="fg"><label>昵称</label><el-input v-model="form.nickname" placeholder="给自己取个名字" size="large"/></div>
        <div class="fg"><label>密码</label><el-input v-model="form.password" type="password" placeholder="至少6位" size="large" show-password/></div>
        <div class="fg"><label>确认密码</label><el-input v-model="form.confirmPassword" type="password" placeholder="再次输入密码" size="large" show-password/></div>
        <el-button type="primary" size="large" class="submit-btn" @click="handleRegister" :loading="loading">注册</el-button>
      </el-form>
      <div class="foot"><span>已有账号？</span><router-link to="/login" class="link">去登录</router-link></div>
    </div>
    <p class="quote">让每一名大学生，都拥有一份属于自己的大学四年成长路线</p>
  </div>
</template>

<script setup>
import { ref,reactive } from 'vue'; import { useRouter } from 'vue-router'; import { useUserStore } from '../stores/user'; import { ElMessage } from 'element-plus'
const router=useRouter(); const userStore=useUserStore(); const loading=ref(false); const formRef=ref(null)
const form=reactive({phone:'',nickname:'',password:'',confirmPassword:''}); const rules={phone:[{required:true,message:'请输入手机号',trigger:'blur'}],nickname:[{required:true,message:'请输入昵称',trigger:'blur'}],password:[{required:true,min:6,message:'密码至少6位',trigger:'blur'}],confirmPassword:[{required:true,validator:(r,v,cb)=>v!==form.password?cb(new Error('两次密码不一致')):cb(),trigger:'blur'}]}
async function handleRegister(){const v=await formRef.value.validate().catch(()=>false);if(!v)return;loading.value=true;try{await userStore.register({phone:form.phone,nickname:form.nickname,password:form.password});ElMessage.success('注册成功！');router.push('/init')}catch(e){}finally{loading.value=false}}
</script>

<style scoped>
.auth-page{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;background:var(--void);position:relative;padding:24px;gap:20px}
.auth-bg{position:absolute;inset:0;overflow:hidden;pointer-events:none}.bg-glow{position:absolute;top:30%;left:50%;transform:translate(-50%,-50%);width:600px;height:600px;background:radial-gradient(circle,rgba(139,195,74,.04) 0%,transparent 70%)}
.auth-card{width:380px;padding:36px 34px 28px;background:var(--glass);border:1px solid var(--border);border-radius:14px;position:relative;z-index:1;backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px)}
.brand{text-align:center;margin-bottom:28px}.brand-dot{display:inline-block;width:5px;height:5px;border-radius:50%;background:var(--signal);margin-bottom:14px;animation:breathe 4s ease-in-out infinite}.brand h1{font-size:22px;font-weight:300;color:#fff;letter-spacing:.04em}.brand p{font-size:12px;color:var(--fog);margin-top:4px;font-weight:300}
.fg{display:flex;flex-direction:column;gap:4px;margin-bottom:12px}.fg label{font-size:11px;font-weight:500;color:var(--mist);letter-spacing:.06em;text-transform:uppercase}
.submit-btn{width:100%;height:44px;font-size:14px!important;font-weight:400!important;letter-spacing:.04em}
.foot{text-align:center;margin-top:16px;font-size:13px;color:var(--fog);font-weight:300}.link{color:var(--signal);margin-left:4px;font-weight:400}.link:hover{opacity:.8}
.quote{font-size:12px;color:var(--fog);text-align:center;position:relative;z-index:1;font-weight:300}
</style>
