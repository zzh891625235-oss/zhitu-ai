import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  // Landing — 纯介绍页
  { path: '/', name: 'Landing', component: () => import('../views/Landing.vue'), meta: { title: '智途AI' } },

  // 仪表盘 + 所有功能页（需要 MainLayout）
  {
    path: '/home',
    component: () => import('../layouts/MainLayout.vue'),
    children: [
      { path: '', name: 'Home', component: () => import('../views/Home.vue'), meta: { title: '首页' } },
      { path: 'plan', name: 'Plan', component: () => import('../views/Plan.vue'), meta: { title: 'AI成长规划' } },
      { path: 'courses', name: 'Courses', component: () => import('../views/Courses.vue'), meta: { title: '专业学习' } },
      { path: 'competitions', name: 'Competitions', component: () => import('../views/Competitions.vue'), meta: { title: '竞赛中心' } },
      { path: 'career', name: 'Career', component: () => import('../views/Career.vue'), meta: { title: '发展方向' } },
      { path: 'assistant', name: 'Assistant', component: () => import('../views/Assistant.vue'), meta: { title: 'AI助手' } },
      { path: 'growth', name: 'Growth', component: () => import('../views/Growth.vue'), meta: { title: '成长档案' } },
      { path: 'resume', name: 'Resume', component: () => import('../views/Resume.vue'), meta: { title: 'AI简历' } },
      { path: 'settings', name: 'Settings', component: () => import('../views/Settings.vue'), meta: { title: 'API设置' } },
      { path: 'admin', name: 'Admin', component: () => import('../views/Admin.vue'), meta: { title: '管理后台', requiresAdmin: true } },
    ]
  },

  { path: '/login', name: 'Login', component: () => import('../views/Login.vue'), meta: { title: '登录' } },
  { path: '/register', name: 'Register', component: () => import('../views/Register.vue'), meta: { title: '注册' } },
  { path: '/init', name: 'InitProfile', component: () => import('../views/InitProfile.vue'), meta: { title: 'AI成长档案初始化' } },
  { path: '/sylva', name: 'SylvaView', component: () => import('../views/SylvaView.vue'), meta: { title: 'Sylva' } },

  // 未知路径回首页，避免出现空白页
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({ history: createWebHistory(), routes })

const publicPaths = ['/', '/login', '/register', '/sylva']

router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - 智途AI` : '智途AI'

  const token = localStorage.getItem('token')

  if (!token && !publicPaths.includes(to.path)) {
    return next('/login')
  }
  if (token && (to.path === '/login' || to.path === '/register')) {
    return next('/home')
  }
  // 管理后台：前端只做引导性拦截（避免普通学生误入后看到一片报错），
  // 真正的权限校验在后端 —— /api/admin/** 要求 ROLE_ADMIN。
  if (to.meta.requiresAdmin && localStorage.getItem('role') !== 'ADMIN') {
    return next('/home')
  }
  next()
})

export default router
