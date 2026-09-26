import request from '../utils/request'

export function getCoursesApi(majorId = 1) {
  return request.get('/courses', { params: { majorId } })
}

export function getCourseDetailApi(id) {
  return request.get(`/courses/${id}`)
}

export function updateProgressApi(courseId, progress) {
  return request.post(`/courses/${courseId}/progress`, { progress })
}
