import request from '../utils/request'

/** 平台总览统计（用户、内容、AI 使用量、注册趋势） */
export function getAdminStatsApi() {
  return request.get('/admin/stats')
}

/** 用户列表：支持关键词搜索与分页 */
export function getAdminUsersApi(params = {}) {
  return request.get('/admin/users', { params })
}

/** 修改用户角色（对方需重新登录后生效） */
export function updateUserRoleApi(id, role) {
  return request.put(`/admin/users/${id}/role`, { role })
}

/** 删除用户及其全部关联数据 */
export function deleteUserApi(id) {
  return request.delete(`/admin/users/${id}`)
}
