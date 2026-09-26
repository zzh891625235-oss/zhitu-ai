<template>
  <div class="main-layout">
    <header class="header">
      <div class="header-bg"></div>
      <div class="header-inner">
        <div class="logo" @click="$router.push('/')">
          <div class="logo-icon"><span>Z</span></div>
          <div class="logo-text"><span class="logo-main">智途</span><span class="logo-sub">AI</span></div>
        </div>
        <nav class="nav">
          <router-link to="/" class="nav-item" exact-active-class="active"><el-icon><HomeFilled /></el-icon><span>首页</span></router-link>
          <router-link to="/plan" class="nav-item" active-class="active"><el-icon><MagicStick /></el-icon><span>AI成长规划</span></router-link>
          <router-link to="/courses" class="nav-item" active-class="active"><el-icon><Reading /></el-icon><span>专业学习</span></router-link>
          <router-link to="/competitions" class="nav-item" active-class="active"><el-icon><TrophyBase /></el-icon><span>竞赛中心</span></router-link>
          <router-link to="/career" class="nav-item" active-class="active"><el-icon><Compass /></el-icon><span>发展方向</span></router-link>
          <router-link to="/assistant" class="nav-item" active-class="active"><el-icon><ChatDotRound /></el-icon><span>AI助手</span></router-link>
          <router-link to="/growth" class="nav-item" active-class="active"><el-icon><DataAnalysis /></el-icon><span>成长档案</span></router-link>
          <router-link to="/resume" class="nav-item" active-class="active"><el-icon><Document /></el-icon><span>AI简历</span></router-link>
        </nav>
        <div class="header-right">
          <el-dropdown trigger="click">
            <div class="user-chip">
              <el-avatar :size="34" icon="UserFilled" class="user-avatar" />
              <span class="user-name">{{ userStore.userInfo?.nickname || '同学' }}</span>
              <el-icon class="chevron"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="$router.push('/growth')"><el-icon><User /></el-icon> 我的档案</el-dropdown-item>
                <el-dropdown-item @click="$router.push('/init')"><el-icon><Edit /></el-icon> 更新档案</el-dropdown-item>
                <el-dropdown-item @click="$router.push('/settings')"><el-icon><Setting /></el-icon> API设置</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout"><el-icon><SwitchButton /></el-icon> 退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="page" mode="out-in"><component :is="Component" /></transition>
      </router-view>
    </main>
    <footer class="footer">
      <div class="footer-inner">
        <div class="footer-brand"><span class="footer-logo">Z</span><span>智途AI · 大学生成长规划平台</span></div>
        <p>让每一名大学生，都拥有一份属于自己的大学四年成长路线</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { onMounted } from 'vue'
import { HomeFilled,MagicStick,Reading,TrophyBase,Compass,ChatDotRound,DataAnalysis,Document,ArrowDown,User,Edit,Setting,SwitchButton } from '@element-plus/icons-vue'
const router = useRouter(); const userStore = useUserStore()
onMounted(async () => { if (!userStore.userInfo) await userStore.fetchUserInfo() })
function handleLogout() { userStore.logout(); router.push('/login') }
</script>

<style scoped>
.main-layout{display:flex;flex-direction:column;min-height:100vh}
.header{position:sticky;top:0;z-index:100;backdrop-filter:blur(20px) saturate(180%);-webkit-backdrop-filter:blur(20px) saturate(180%);border-bottom:1px solid rgba(255,255,255,.2)}
.header-bg{position:absolute;inset:0;background:linear-gradient(135deg,rgba(108,92,231,.92),rgba(90,75,209,.92));z-index:-1}
.header-inner{max-width:1440px;margin:0 auto;display:flex;align-items:center;padding:0 28px;height:64px}
.logo{display:flex;align-items:center;cursor:pointer;margin-right:32px;flex-shrink:0}
.logo-icon{width:38px;height:38px;border-radius:12px;background:rgba(255,255,255,.18);display:flex;align-items:center;justify-content:center;margin-right:10px;transition:all var(--transition)}
.logo-icon span{color:#fff;font-size:20px;font-weight:800}
.logo:hover .logo-icon{transform:rotate(-8deg) scale(1.05)}
.logo-text{display:flex;align-items:baseline;gap:4px}
.logo-main{color:#fff;font-size:19px;font-weight:700;letter-spacing:1px}
.logo-sub{color:var(--accent-light);font-size:11px;font-weight:700;background:rgba(85,239,196,.2);padding:2px 6px;border-radius:4px}
.nav{display:flex;gap:2px;flex:1;overflow-x:auto}
.nav::-webkit-scrollbar{display:none}
.nav-item{display:flex;align-items:center;gap:6px;color:rgba(255,255,255,.75);padding:8px 14px;border-radius:10px;font-size:13.5px;font-weight:500;transition:all var(--transition);white-space:nowrap;position:relative}
.nav-item:hover{color:#fff;background:rgba(255,255,255,.12)}
.nav-item.active{color:#fff;background:rgba(255,255,255,.18);box-shadow:0 2px 12px rgba(0,0,0,.1)}
.nav-item.active::after{content:'';position:absolute;bottom:4px;left:50%;transform:translateX(-50%);width:20px;height:3px;border-radius:2px;background:var(--accent-light)}
.header-right{margin-left:auto;display:flex;align-items:center;gap:14px}
.user-chip{display:flex;align-items:center;gap:8px;cursor:pointer;padding:4px 12px 4px 4px;border-radius:24px;background:rgba(255,255,255,.1);transition:all var(--transition)}
.user-chip:hover{background:rgba(255,255,255,.2)}
.user-avatar{border:2px solid rgba(255,255,255,.3)}
.user-name{color:#fff;font-size:14px;font-weight:500;max-width:80px;overflow:hidden;text-overflow:ellipsis}
.chevron{color:rgba(255,255,255,.6);font-size:12px}
.main-content{flex:1;max-width:1440px;width:100%;margin:0 auto;padding:28px}
.page-enter-active{animation:fadeInUp .3s cubic-bezier(.4,0,.2,1)}
.page-leave-active{animation:fadeInUp .15s cubic-bezier(.4,0,.2,1) reverse}
@keyframes fadeInUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
.footer{background:#fff;border-top:1px solid var(--border);padding:28px;text-align:center}
.footer-inner{color:var(--text-muted);font-size:13px}
.footer-brand{display:flex;align-items:center;justify-content:center;gap:8px;margin-bottom:6px}
.footer-logo{display:inline-flex;width:24px;height:24px;border-radius:6px;background:linear-gradient(135deg,var(--primary),var(--primary-dark));align-items:center;justify-content:center;color:#fff;font-size:13px;font-weight:700}
</style>
