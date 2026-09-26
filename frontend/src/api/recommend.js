import request from '../utils/request'

export function recommendCompetitionsApi() {
  return request.post('/ai/recommend-competitions')
}
