import request from '../utils/request'

export function getCompetitionsApi(params = {}) {
  return request.get('/competitions', { params })
}

export function getCompetitionDetailApi(id) {
  return request.get(`/competitions/${id}`)
}
