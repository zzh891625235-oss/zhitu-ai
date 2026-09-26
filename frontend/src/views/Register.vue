<template>
  <div class="auth-page">
    <div class="auth-bg">
      <div class="bg-orb orb-1"></div>
      <div class="bg-orb orb-2"></div>
      <div class="bg-orb orb-3"></div>
      <div class="bg-grid"></div>
    </div>

    <div class="auth-card">
      <div class="card-brand">
        <div class="brand-icon">Z</div>
        <h1>创建账号</h1>
        <p>加入智途AI，开启你的大学成长之旅</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" class="auth-form">
        <el-form-item prop="nickname">
          <el-input v-model="form.nickname" placeholder="昵称（选填）" size="large"
            :prefix-icon="User" class="custom-input" />
        </el-form-item>
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="手机号" size="large"
            :prefix-icon="Phone" class="custom-input" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码（至少6位）" size="large"
            :prefix-icon="Lock" show-password class="custom-input" />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" placeholder="确认密码" size="large"
            :prefix-icon="Lock" show-password class="custom-input" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="submit-btn" @click="handleRegister" :loading="loading">
            <span v-if="!loading">注 册</span>
          </el-button>
        </el-form-item>
      </el-form>

      <div class="card-footer">
        <span>已有账号？</span>
        <router-link to="/login" class="link">立即登录 →</router-link>
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
      phone: form.phone, password: form.password, nickname: form.nickname || undefined
    })
    ElMessage.success('注册成功！正在生成你的AI画像...')
    router.push('/init')
  } catch (e) {} finally { loading.value = false }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh; display: flex; align-items: center; justify-content: center;
  position: relative; overflow: hidden;
}
.auth-bg { position: absolute; inset: 0; z-index: 0; }
.bg-orb {
  position: absolute; border-radius: 50%; filter: blur(80px); opacity: .5;
  animation: float 8s ease-in-out infinite;
}
.orb-1 { width: 500px; height: 500px; background: radial-gradient(circle, rgba(108,92,231,.4), transparent); top: -15%; right: -10%; }
.orb-2 { width: 400px; height: 400px; background: radial-gradient(circle, rgba(0,206,201,.35), transparent); bottom: -10%; left: -8%; animation-delay: -3s; }
.orb-3 { width: 350px; height: 350px; background: radial-gradient(circle, rgba(254,202,87,.3), transparent); top: 40%; left: 50%; animation-delay: -6s; }
.bg-grid { position: absolute; inset: 0; background-image: linear-gradient(rgba(108,92,231,.04) 1px, transparent 1px), linear-gradient(90deg, rgba(108,92,231,.04) 1px, transparent 1px); background-size: 60px 60px; }
@keyframes float {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -30px) scale(1.05); }
  66% { transform: translate(-20px, 20px) scale(.95); }
}

.auth-card {
  position: relative; z-index: 1; width: 420px; padding: 40px 42px;
  background: rgba(255,255,255,.85); backdrop-filter: blur(24px) saturate(180%);
  -webkit-backdrop-filter: blur(24px) saturate(180%);
  border-radius: var(--radius-xl); border: 1px solid rgba(255,255,255,.6);
  box-shadow: var(--shadow-xl);
}
.card-brand { text-align: center; margin-bottom: 32px; }
.brand-icon {
  display: inline-flex; width: 56px; height: 56px; border-radius: 16px;
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
  align-items: center; justify-content: center;
  color: #fff; font-size: 28px; font-weight: 800;
  margin-bottom: 14px; box-shadow: 0 8px 24px rgba(108,92,231,.3);
  animation: pulse 3s infinite;
}
.card-brand h1 { font-size: 24px; color: var(--text); font-weight: 800; letter-spacing: 2px; }
.card-brand p { color: var(--text-secondary); font-size: 13px; margin-top: 6px; }

.custom-input :deep(.el-input__wrapper) {
  border-radius: 12px; background: rgba(108,92,231,.04);
  box-shadow: none !important; border: 1.5px solid transparent !important;
  transition: all var(--transition);
}
.custom-input :deep(.el-input__wrapper:hover) { border-color: var(--primary-light) !important; }
.custom-input :deep(.el-input__wrapper.is-focus) { border-color: var(--primary) !important; background: #fff; box-shadow: 0 0 0 3px rgba(108,92,231,.1) !important; }

.submit-btn { width: 100%; height: 48px; border-radius: 12px !important; font-size: 16px !important; letter-spacing: 4px; }

.card-footer { text-align: center; margin-top: 24px; font-size: 14px; color: var(--text-secondary); }
.link { color: var(--primary); margin-left: 6px; font-weight: 600; }
</style>
