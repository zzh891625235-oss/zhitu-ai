import request from '../utils/request'

const AI_TIMEOUT = 120000

export function generateResumeApi() {
  return request.post('/ai/generate-resume', null, { timeout: AI_TIMEOUT })
}

export function getResumeApi() {
  return request.get('/resume')
}
