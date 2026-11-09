import request from '../utils/request'

/** B 站课堂 · 分类统计 */
export function getBilibiliCategoriesApi() {
  return request.get('/bilibili/categories')
}

/** B 站课堂 · 资源列表（可按分类/关键词过滤） */
export function getBilibiliResourcesApi(params = {}) {
  return request.get('/bilibili/resources', { params })
}

/** B 站课堂 · 按我的专业个性化推荐 */
export function getBilibiliRecommendApi() {
  return request.get('/bilibili/recommend')
}
