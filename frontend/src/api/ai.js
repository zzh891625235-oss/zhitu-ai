import request from '../utils/request'

export function chatApi(question, type = 'GENERAL') {
  return request.post('/ai/chat', { question, type })
}

export function getHistoryApi(type = 'GENERAL') {
  return request.get('/ai/chat-history', { params: { type } })
}
