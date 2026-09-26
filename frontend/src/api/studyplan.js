import request from '../utils/request'

export function getStudyPlanApi() {
  return request.get('/study-plan')
}

export function generateStudyPlanApi(days = 7) {
  return request.post('/study-plan/generate', null, { params: { days } })
}

export function recordStudyApi(data) {
  return request.post('/study-plan/record', data)
}
