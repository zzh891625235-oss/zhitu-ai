<template>
  <div class="main-layout">
    <!-- 全局动态背景：成长知识网络 -->
    <AppBackground />

    <header class="header">
      <div class="header-inner">
        <div class="logo" @click="$router.push('/home')">
          <span class="logo-dot"></span>
          <span class="logo-word">ZHITU</span>
        </div>
        <nav class="nav">
          <router-link to="/home" class="nav-item" exact-active-class="active">首页</router-link>
          <router-link to="/home/plan" class="nav-item" active-class="active">AI成长规划</router-link>
          <router-link to="/home/courses" class="nav-item" active-class="active">专业学习</router-link>
          <router-link to="/home/bilibili" class="nav-item" active-class="active">B站课堂</router-link>
          <router-link to="/home/competitions" class="nav-item" active-class="active">竞赛中心</router-link>
          <router-link to="/home/career" class="nav-item" active-class="active">发展方向</router-link>
          <router-link to="/home/assistant" class="nav-item" active-class="active">AI助手</router-link>
          <router-link to="/home/growth" class="nav-item" active-class="active">成长档案</router-link>
          <router-link to="/home/resume" class="nav-item" active-class="active">AI简历</router-link>
        </nav>

        <div class="header-right">
          <!-- 站内通知 -->
          <el-popover placement="bottom-end" :width="330" trigger="click" @show="loadNotifications">
            <template #reference>
              <div class="icon-btn notify-btn" title="通知">
                <el-icon :size="15"><Bell /></el-icon>
                <span v-if="unread > 0" class="badge">{{ unread > 99 ? '99+' : unread }}</span>
              </div>
            </template>
            <div class="notify-panel">
              <div class="np-head">
                <span>通知</span>
                <el-button text size="small" :disabled="unread === 0" @click="handleReadAll">全部已读</el-button>
              </div>
              <div class="np-body" v-if="notifications.length">
                <div v-for="n in notifications" :key="n.id" class="np-item"
                  :class="{ unread: !n.isRead }" @click="handleRead(n)">
                  <div class="np-title">{{ n.title }}</div>
                  <div class="np-content">{{ n.content }}</div>
                  <div class="np-time">{{ formatNotifyTime(n.createdAt) }}</div>
                </div>
              </div>
              <div v-else class="np-empty">暂无通知</div>
            </div>
          </el-popover>

          <!-- 管理员入口：仅 ADMIN 角色可见，后端 /api/admin/** 也会二次校验 -->
          <router-link v-if="isAdmin" to="/home/admin" class="icon-btn" title="管理后台">
            <el-icon :size="15"><DataAnalysis /></el-icon>
          </router-link>

          <router-link to="/home/settings" class="icon-btn" title="API设置">
            <el-icon :size="15"><Setting /></el-icon>
          </router-link>

          <el-dropdown trigger="click" placement="bottom-end">
            <div class="user-chip">
              <el-avatar :size="26" icon="UserFilled" />
              <span>{{ userStore.userInfo?.nickname || '同学' }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="$router.push('/home/growth')"><el-icon><User /></el-icon>我的档案</el-dropdown-item>
                <el-dropdown-item @click="$router.push('/init')"><el-icon><Edit /></el-icon>更新档案</el-dropdown-item>
                <el-dropdown-item @click="$router.push('/home/settings')"><el-icon><Setting /></el-icon>API设置</el-dropdown-item>
                <el-dropdown-item v-if="isAdmin" @click="$router.push('/home/admin')"><el-icon><DataAnalysis /></el-icon>管理后台</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout"><el-icon><SwitchButton /></el-icon>退出</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>

    <main class="main-content">
      <!-- 档案未建立时，所有模块顶部都给一条明确的下一步引导，而不是让人面对空页面 -->
      <div v-if="showProfileTip" class="profile-tip">
        <span class="pt-icon">✦</span>
        <span class="pt-text">还没建立 AI 成长档案，规划、简历和竞赛推荐暂时无法按你的专业生成。</span>
        <el-button size="small" type="primary" round @click="router.push('/init')">去完善档案</el-button>
        <button class="pt-close" title="本次不再提示" @click="dismissProfileTip">×</button>
      </div>
      <!-- 模块切换时的一道信号扫光，把上一页和下一页「连」起来 -->
      <div class="route-sweep" :key="route.path"></div>
      <router-view v-slot="{ Component }">
        <transition name="page"><component :is="Component" /></transition>
      </router-view>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { Setting, User, Edit, SwitchButton, Bell, DataAnalysis } from '@element-plus/icons-vue'
import { getNotificationsApi, getUnreadCountApi, markReadApi, markAllReadApi } from '../api/notification'
import { getProfileApi } from '../api/profile'
import AppBackground from '../components/AppBackground.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const notifications = ref([])
const unread = ref(0)
const showProfileTip = ref(false)
const PROFILE_TIP_KEY = 'zhitu_profile_tip_dismissed'
let pollTimer = null

const isAdmin = computed(() => (userStore.userInfo?.role || localStorage.getItem('role')) === 'ADMIN')

onMounted(async () => {
  if (!userStore.userInfo) await userStore.fetchUserInfo()
  await loadUnread()
  await checkProfileReady()
  // 通知不是实时性很强的功能，60 秒轮询一次即可
  pollTimer = setInterval(loadUnread, 60000)
})

/** 初始化完成后从 /init 回来，或切换到别的模块时，重新确认提示条是否该收起 */
watch(() => route.path, () => {
  if (!sessionStorage.getItem(PROFILE_TIP_KEY)) checkProfileReady()
})

async function checkProfileReady() {
  if (sessionStorage.getItem(PROFILE_TIP_KEY)) return
  try {
    const p = (await getProfileApi()).data
    showProfileTip.value = !p || !p.majorId
  } catch (e) {
    showProfileTip.value = false
  }
}

function dismissProfileTip() {
  showProfileTip.value = false
  sessionStorage.setItem(PROFILE_TIP_KEY, '1')
}

onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer)
})

async function loadUnread() {
  try {
    unread.value = (await getUnreadCountApi()).data?.count || 0
  } catch (e) {
    // 静默失败：未读数拿不到不应影响主流程
  }
}

async function loadNotifications() {
  try {
    notifications.value = (await getNotificationsApi()).data || []
  } catch (e) {
    notifications.value = []
  }
}

async function handleRead(item) {
  if (item.isRead) return
  try {
    await markReadApi(item.id)
    item.isRead = true
    unread.value = Math.max(0, unread.value - 1)
  } catch (e) {
    // 失败时保持原状
  }
}

async function handleReadAll() {
  try {
    await markAllReadApi()
    notifications.value.forEach(n => { n.isRead = true })
    unread.value = 0
  } catch (e) {
    // 失败时保持原状
  }
}

function formatNotifyTime(value) {
  if (!value) return ''
  return String(value).replace('T', ' ').substring(5, 16)
}

function handleLogout() {
  userStore.logout()
  router.push('/')
}
</script>

<style scoped>
.main-layout{display:flex;flex-direction:column;min-height:100vh;position:relative}

/* 未初始化档案的全局引导条：细、可关闭、不遮挡内容 */
.profile-tip{
  display:flex;align-items:center;gap:10px;max-width:1200px;width:calc(100% - 48px);
  margin:14px auto 0;padding:9px 14px;border-radius:10px;font-size:12.5px;
  color:#F5C97A;background:rgba(245,165,36,.08);border:1px solid rgba(245,165,36,.24);
}
.profile-tip .pt-icon{color:#F5C97A;flex-shrink:0;font-size:13px}
.profile-tip .pt-text{flex:1;min-width:0;overflow-wrap:anywhere;line-height:1.5}
.pt-close{
  margin-left:2px;background:transparent;border:0;color:inherit;opacity:.55;
  cursor:pointer;font-size:17px;line-height:1;padding:2px 4px;flex-shrink:0;
}
.pt-close:hover{opacity:1}
@media (max-width:820px){
  .profile-tip{width:calc(100% - 24px);flex-wrap:wrap}
}

/* 信号扫光：每次切模块从左侧扫过一条绿线 */
.route-sweep{position:absolute;top:0;left:0;right:0;height:1px;pointer-events:none;overflow:hidden;z-index:2}
.route-sweep::after{content:'';position:absolute;top:0;left:0;width:38%;height:100%;background:linear-gradient(90deg,transparent,rgba(139,195,74,.75),transparent);animation:sweep 1.1s cubic-bezier(.16,1,.3,1) forwards}
@keyframes sweep{0%{transform:translateX(-110%);opacity:0}18%{opacity:1}100%{transform:translateX(300%);opacity:0}}

.header{position:sticky;top:0;z-index:100;background:rgba(8,10,9,.55);backdrop-filter:blur(20px) saturate(1.2);-webkit-backdrop-filter:blur(20px) saturate(1.2);border-bottom:1px solid rgba(255,255,255,.04)}
.header-inner{max-width:1200px;margin:0 auto;display:flex;align-items:center;padding:0 28px;height:52px;gap:20px}
.logo{display:flex;align-items:center;gap:8px;cursor:pointer}
.logo-dot{width:5px;height:5px;border-radius:50%;background:var(--signal);animation:breathe 4s ease-in-out infinite}
.logo-word{font-size:13px;font-weight:500;color:#fff;letter-spacing:.15em}
.nav{display:flex;gap:2px;flex:1;overflow-x:auto}
.nav::-webkit-scrollbar{display:none}
.nav-item{padding:5px 12px;border-radius:6px;font-size:12.5px;font-weight:400;color:var(--mist);white-space:nowrap;transition:all var(--transition)}
.nav-item:hover{color:#fff;background:rgba(255,255,255,.03)}
.nav-item.active{color:var(--signal);background:var(--signal-dim);font-weight:500}
.header-right{display:flex;align-items:center;gap:4px;margin-left:auto}
.icon-btn{width:30px;height:30px;border-radius:6px;display:flex;align-items:center;justify-content:center;color:var(--mist);transition:all var(--transition);position:relative}
.icon-btn:hover{color:#fff;background:rgba(255,255,255,.04)}
.notify-btn{cursor:pointer}
.badge{position:absolute;top:1px;right:1px;min-width:14px;height:14px;padding:0 3px;border-radius:7px;background:#EF5350;color:#fff;font-size:9px;line-height:14px;text-align:center;font-weight:600}
.user-chip{display:flex;align-items:center;gap:6px;cursor:pointer;padding:2px 8px 2px 2px;border-radius:16px;font-size:13px;color:var(--mist);transition:all var(--transition)}
.user-chip:hover{background:rgba(255,255,255,.04);color:#fff}
.main-content{flex:1;max-width:1200px;width:100%;margin:0 auto;padding:24px;position:relative;z-index:1}

/* 通知面板（popover 内容） */
.notify-panel{max-height:400px;display:flex;flex-direction:column}
.np-head{display:flex;align-items:center;justify-content:space-between;padding-bottom:8px;border-bottom:1px solid var(--border-soft);font-size:13px;color:#fff}
.np-body{overflow-y:auto;margin-top:4px}
.np-item{padding:9px 10px;border-radius:7px;cursor:pointer;transition:background .2s}
.np-item:hover{background:rgba(255,255,255,.04)}
.np-item.unread{background:rgba(139,195,74,.06)}
.np-title{font-size:13px;color:#fff;font-weight:500;margin-bottom:3px;display:flex;align-items:center;gap:6px}
.np-item.unread .np-title::before{content:'';width:5px;height:5px;border-radius:50%;background:var(--signal);flex-shrink:0}
.np-content{font-size:12px;color:var(--mist);line-height:1.55;font-weight:300}
.np-time{font-size:10px;color:var(--fog);margin-top:4px}
.np-empty{text-align:center;padding:32px 0;color:var(--fog);font-size:13px}

/* 移动端：导航换行成第二行横向滚动，避免 8 个菜单项被挤压换行错乱 */
@media (max-width:820px){
  .header-inner{flex-wrap:wrap;height:auto;min-height:50px;padding:0 14px;gap:8px;padding-top:6px}
  .logo-word{display:none}
  .header-right{margin-left:auto}
  .nav{order:3;flex:1 0 100%;gap:0;padding-bottom:6px}
  .nav-item{padding:6px 11px;font-size:12px}
  .main-content{padding:14px}
}
</style>
