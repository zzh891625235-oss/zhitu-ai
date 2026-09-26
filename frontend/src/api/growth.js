import request from '../utils/request'

export function getArchiveApi() {
  return request.get('/growth/archive')
}

export function addGrowthRecordApi(data) {
  return request.post('/growth/record', data)
}
