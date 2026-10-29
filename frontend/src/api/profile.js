import request from '../utils/request'

// AI 生成类接口单独放宽超时：后端连接 10s + 读取最长 120s，
// 而全局默认只有 30s，配了真实 Key 时极易在 axios 侧先超时，
// 表现为「AI正在生成…」转很久最后报「生成失败」。
const AI_TIMEOUT = 120000

/** 保存学生档案 */
export function saveProfileApi(data) {
  return request.post('/profile', data)
}

/** 获取学生档案 */
export function getProfileApi() {
  return request.get('/profile')
}

/** AI生成学生画像 */
export function generatePortraitApi() {
  return request.post('/ai/generate-portrait', null, { timeout: AI_TIMEOUT })
}

/** 获取AI画像 */
export function getPortraitApi() {
  return request.get('/ai/portrait')
}
