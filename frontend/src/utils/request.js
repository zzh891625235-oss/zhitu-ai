import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'

const request = axios.create({
  baseURL: '/api',
  timeout: 30000
})

/**
 * 「未初始化档案」统一引导。
 * 后端用 409 + ProfileNotReadyException 明确告诉前端：这不是故障，
 * 而是用户还没走完初始化流程。这里给一个可以直接跳过去的按钮，
 * 而不是甩一句红色报错让人不知道下一步做什么。
 * 短时间内并发触发只弹一次，避免一个页面同时发多个生成请求时叠弹窗。
 */
let guidePending = false
let lastGuideAt = 0
function guideToProfileInit(message) {
  const now = Date.now()
  if (guidePending || now - lastGuideAt < 4000) return
  guidePending = true
  lastGuideAt = now
  ElMessageBox.confirm(
    message || '请先完成 AI 成长档案初始化，系统才能按你的专业和年级生成个性化内容。',
    '还差一步：完善成长档案',
    { confirmButtonText: '去初始化', cancelButtonText: '稍后再说', type: 'info' }
  ).then(() => { window.location.href = '/init' })
    .catch(() => {})
    .finally(() => { guidePending = false })
}

// 请求拦截器 - 添加Token
request.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 响应拦截器 - 统一处理错误
request.interceptors.response.use(
  response => {
    const res = response.data
    if (res.code !== 200) {
      // 409 且文案与档案相关时走可跳转引导，其余 409 仍按普通业务错误提示
      if (res.code === 409 && /档案|初始化/.test(res.message || '')) {
        guideToProfileInit(res.message)
      } else {
        ElMessage.error(res.message || '请求失败')
      }
      return Promise.reject(new Error(res.message))
    }
    return res
  },
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default request
