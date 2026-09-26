<template>
  <div class="register-page">
    <div class="register-card">
      <div class="card-header">
        <div class="logo-area">
          <span class="logo-badge">Z</span>
          <h1>创建账号</h1>
        </div>
        <p class="subtitle">加入智途AI，开启你的大学成长之旅</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" class="register-form">
        <el-form-item prop="nickname">
          <el-input v-model="form.nickname" placeholder="昵称（选填）" size="large" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="手机号" size="large" :prefix-icon="Phone" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码（至少6位）" size="large"
            :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" placeholder="确认密码" size="large"
            :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="register-btn" @click="handleRegister" :loading="loading">
            注 册
          </el-button>
        </el-form-item>
      </el-form>

      <div class="card-footer">
        <span>已有账号？</span>
        <router-link to="/login" class="link">立即登录</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'
import { User, Phone, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const formRef = ref(null)
const form = reactive({ phone: '', password: '', confirmPassword: '', nickname: '' })

const validateConfirm = (rule, value, callback) => {
  if (value !== form.password) callback(new Error('两次密码不一致'))
  else callback()
}
const rules = {
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ]
}

async function handleRegister() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await userStore.register({
      phone: form.phone,
      password: form.password,
      nickname: form.nickname || undefined
    })
    ElMessage.success('注册成功')
    router.push('/init')
  } catch (e) {
    // 错误已在拦截器中处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #5b8def 100%);
}
.register-card {
  width: 420px; padding: 40px;
  background: #fff; border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.15);
}
.card-header { text-align: center; margin-bottom: 32px; }
.logo-area { display: flex; align-items: center; justify-content: center; gap: 12px; }
.logo-badge {
  width: 48px; height: 48px; border-radius: 14px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 26px; font-weight: bold;
}
.card-header h1 { font-size: 24px; color: #333; font-weight: 700; }
.subtitle { color: #999; font-size: 14px; margin-top: 6px; }
.register-btn { width: 100%; }
.card-footer { text-align: center; margin-top: 20px; font-size: 14px; color: #999; }
.link { color: #667eea; margin-left: 4px; font-weight: 500; }
</style>
