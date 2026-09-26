import request from '../utils/request'

/** AI生成四年规划 */
export function generatePlanApi() {
  return request.post('/ai/generate-plan')
}

/** 获取四年规划 */
export function getPlanApi() {
  return request.get('/plan/four-year')
}
