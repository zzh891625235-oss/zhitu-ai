import request from '../utils/request'

export function generateResumeApi() {
  return request.post('/ai/generate-resume')
}

export function getResumeApi() {
  return request.get('/resume')
}
