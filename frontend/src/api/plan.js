import request from '../utils/request'

// AI 生成类接口放宽超时，避免真实大模型耗时超过全局 30s 被 axios 提前掐断
const AI_TIMEOUT = 120000

/** AI生成四年规划 */
export function generatePlanApi() {
  return request.post('/ai/generate-plan', null, { timeout: AI_TIMEOUT })
}

/** 获取四年规划 */
export function getPlanApi() {
  return request.get('/plan/four-year')
}
