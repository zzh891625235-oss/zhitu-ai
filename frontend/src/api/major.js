import request from '../utils/request'

export function getMajorsApi() {
  return request.get('/majors')
}
