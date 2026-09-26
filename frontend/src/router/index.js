import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
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
    ]
  },
  { path: '/login', name: 'Login', component: () => import('../views/Login.vue'), meta: { title: '登录' } },
  { path: '/register', name: 'Register', component: () => import('../views/Register.vue'), meta: { title: '注册' } },
  { path: '/init', name: 'InitProfile', component: () => import('../views/InitProfile.vue'), meta: { title: 'AI成长档案初始化' } },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫 - 未登录跳转登录页
router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `智途AI - ${to.meta.title}` : '智途AI'
  const token = localStorage.getItem('token')
  if (!token && to.path !== '/login' && to.path !== '/register') {
    next('/login')
  } else {
    next()
  }
})

export default router
