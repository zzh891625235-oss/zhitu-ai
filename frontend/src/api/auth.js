import request from '../utils/request'

export function loginApi(phone, password) {
  return request.post('/auth/login', { phone, password })
}

export function registerApi(data) {
  return request.post('/auth/register', data)
}

export function getUserProfileApi() {
  return request.get('/user/profile')
}
