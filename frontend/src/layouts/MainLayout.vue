<template>
  <div class="main-layout">
    <!-- 顶部导航 -->
    <header class="header">
      <div class="header-inner">
        <div class="logo" @click="$router.push('/')">
          <span class="logo-icon">Z</span>
          <span class="logo-text">智途AI</span>
        </div>
        <nav class="nav">
          <router-link to="/" class="nav-item">首页</router-link>
          <router-link to="/plan" class="nav-item">AI成长规划</router-link>
          <router-link to="/courses" class="nav-item">专业学习</router-link>
          <router-link to="/competitions" class="nav-item">竞赛中心</router-link>
          <router-link to="/career" class="nav-item">发展方向</router-link>
          <router-link to="/assistant" class="nav-item">AI助手</router-link>
          <router-link to="/growth" class="nav-item">成长档案</router-link>
          <router-link to="/resume" class="nav-item">AI简历</router-link>
        </nav>
        <div class="header-right">
          <el-dropdown>
            <span class="user-tag">
              <el-avatar :size="32" icon="UserFilled" />
              <span class="nickname">{{ userStore.userInfo?.nickname || '同学' }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="$router.push('/growth')">我的档案</el-dropdown-item>
                <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>

    <!-- 内容区域 -->
    <main class="main-content">
      <router-view />
    </main>

    <!-- 底部 -->
    <footer class="footer">
      <p>让每一名大学生，都拥有一份属于自己的大学四年成长路线</p>
      <p class="footer-copy">&copy; 2026 智途AI - AI大学生成长规划平台</p>
    </footer>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { onMounted } from 'vue'

const router = useRouter()
const userStore = useUserStore()

onMounted(async () => {
  if (!userStore.userInfo) {
    await userStore.fetchUserInfo()
  }
})

function handleLogout() {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.main-layout { display: flex; flex-direction: column; min-height: 100vh; }

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 2px 12px rgba(102, 126, 234, 0.3);
  position: sticky; top: 0; z-index: 100;
}
.header-inner {
  max-width: 1400px; margin: 0 auto;
  display: flex; align-items: center;
  padding: 0 24px; height: 60px;
}
.logo {
  display: flex; align-items: center; cursor: pointer;
  margin-right: 40px; flex-shrink: 0;
}
.logo-icon {
  width: 36px; height: 36px; border-radius: 10px;
  background: rgba(255,255,255,0.2);
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 22px; font-weight: bold; margin-right: 10px;
}
.logo-text {
  color: #fff; font-size: 20px; font-weight: 700;
  letter-spacing: 1px;
}
.nav { display: flex; gap: 4px; flex: 1; }
.nav-item {
  color: rgba(255,255,255,0.85); padding: 8px 14px; border-radius: 8px;
  font-size: 14px; transition: all 0.2s; white-space: nowrap;
}
.nav-item:hover, .nav-item.router-link-active {
  background: rgba(255,255,255,0.15); color: #fff;
}
.header-right { margin-left: auto; }
.user-tag { display: flex; align-items: center; gap: 8px; cursor: pointer; color: #fff; }
.nickname { font-size: 14px; max-width: 80px; overflow: hidden; text-overflow: ellipsis; }

.main-content { flex: 1; max-width: 1400px; width: 100%; margin: 0 auto; padding: 24px; }

.footer {
  text-align: center; padding: 24px; background: #fff;
  border-top: 1px solid #eee; color: #999; font-size: 13px;
}
.footer-copy { margin-top: 4px; font-size: 12px; }
</style>
