import { defineStore } from 'pinia'
import { ref } from 'vue'
import { loginApi, registerApi, getUserProfileApi } from '../api/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(null)

  // 登录
  async function login(phone, password) {
    const res = await loginApi(phone, password)
    token.value = res.data.token
    localStorage.setItem('token', res.data.token)
    await fetchUserInfo()
    return res
  }

  // 注册
  async function register(data) {
    const res = await registerApi(data)
    token.value = res.data.token
    localStorage.setItem('token', res.data.token)
    await fetchUserInfo()
    return res
  }

  // 获取用户信息
  async function fetchUserInfo() {
    try {
      const res = await getUserProfileApi()
      userInfo.value = res.data
    } catch (e) {
      // token过期则清除
      logout()
    }
  }

  // 退出登录
  function logout() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
  }

  return { token, userInfo, login, register, fetchUserInfo, logout }
})
