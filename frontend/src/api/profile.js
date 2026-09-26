import request from '../utils/request'

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
  return request.post('/ai/generate-portrait')
}

/** 获取AI画像 */
export function getPortraitApi() {
  return request.get('/ai/portrait')
}
