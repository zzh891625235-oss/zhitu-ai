import { defineStore } from 'pinia'
import { ref } from 'vue'
import { loginApi, registerApi, getUserProfileApi } from '../api/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(null)

  /**
   * 角色同时写入 localStorage：
   * 路由守卫是同步执行的，拿不到尚未加载完成的 store 数据。
   * 这里只用于前端展示与页面引导，接口权限始终由后端校验。
   */
  function persistRole(role) {
    if (role) {
      localStorage.setItem('role', role)
    }
  }

  async function login(phone, password) {
    const res = await loginApi(phone, password)
    token.value = res.data.token
    localStorage.setItem('token', res.data.token)
    persistRole(res.data.role)
    await fetchUserInfo()
    return res
  }

  async function register(data) {
    const res = await registerApi(data)
    token.value = res.data.token
    localStorage.setItem('token', res.data.token)
    persistRole(res.data.role)
    await fetchUserInfo()
    return res
  }

  async function fetchUserInfo() {
    try {
      const res = await getUserProfileApi()
      userInfo.value = res.data
      persistRole(res.data?.role)
      return userInfo.value
    } catch (e) {
      // 单次失败不立即清除 token：可能只是网络抖动。
      // 若确实是登录态失效，后续请求会拿到 401，由 request 拦截器统一跳转登录页。
      userInfo.value = null
      return null
    }
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('role')
  }

  return { token, userInfo, login, register, fetchUserInfo, logout }
})
