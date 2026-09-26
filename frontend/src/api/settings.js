import request from '../utils/request'

export function getSettingsApi() { return request.get('/settings') }
export function saveSettingsApi(data) { return request.put('/settings', data) }
export function testConnectionApi() { return request.post('/settings/test') }
