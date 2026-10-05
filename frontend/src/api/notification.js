import request from '../utils/request'

/** 通知列表（最新 20 条） */
export function getNotificationsApi() {
  return request.get('/notifications')
}

/** 未读数量 */
export function getUnreadCountApi() {
  return request.get('/notifications/unread-count')
}

/** 标记单条已读 */
export function markReadApi(id) {
  return request.put(`/notifications/${id}/read`)
}

/** 全部标记已读 */
export function markAllReadApi() {
  return request.put('/notifications/read-all')
}
