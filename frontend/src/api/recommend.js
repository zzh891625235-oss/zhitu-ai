import request from '../utils/request'

const AI_TIMEOUT = 120000

export function recommendCompetitionsApi() {
  return request.post('/ai/recommend-competitions', null, { timeout: AI_TIMEOUT })
}
