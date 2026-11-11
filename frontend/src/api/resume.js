import request from '../utils/request'

const AI_TIMEOUT = 120000

export function generateResumeApi() {
  return request.post('/ai/generate-resume', null, { timeout: AI_TIMEOUT })
}

export function getResumeApi() {
  return request.get('/resume')
}

/** 保存在线编辑后的简历（PUT /resume，后端按白名单清洗字段） */
export function saveResumeApi(data) {
  return request.put('/resume', data)
}
