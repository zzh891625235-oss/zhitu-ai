<template>
  <div class="login-page">
    <div class="login-card">
      <div class="card-header">
        <div class="logo-area">
          <span class="logo-badge">Z</span>
          <h1>智途AI</h1>
        </div>
        <p class="subtitle">AI大学生成长规划平台</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" class="login-form">
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" size="large" :prefix-icon="Phone" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" size="large"
            :prefix-icon="Lock" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="login-btn" @click="handleLogin" :loading="loading">
            登 录
          </el-button>
        </el-form-item>
      </el-form>

      <div class="card-footer">
        <span>还没有账号？</span>
        <router-link to="/register" class="link">立即注册</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'
import { Phone, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const formRef = ref(null)
const form = reactive({ phone: '', password: '' })
const rules = {
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await userStore.login(form.phone, form.password)
    ElMessage.success('登录成功')
    router.push('/')
  } catch (e) {
    // 错误已在拦截器中处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #5b8def 100%);
}
.login-card {
  width: 420px; padding: 48px 40px;
  background: #fff; border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.15);
}
.card-header { text-align: center; margin-bottom: 36px; }
.logo-area { display: flex; align-items: center; justify-content: center; gap: 12px; }
.logo-badge {
  width: 48px; height: 48px; border-radius: 14px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 26px; font-weight: bold;
}
.card-header h1 { font-size: 28px; color: #333; font-weight: 700; }
.subtitle { color: #999; font-size: 14px; margin-top: 8px; }
.login-btn { width: 100%; }
.card-footer { text-align: center; margin-top: 24px; font-size: 14px; color: #999; }
.link { color: #667eea; margin-left: 4px; font-weight: 500; }
</style>
