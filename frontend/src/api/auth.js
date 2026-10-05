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

// 说明：微信登录（/auth/wechat/*）目前尚未实现。
// 这里原本保留了 3 个调用该接口的函数，但后端并没有对应路由，
// 属于「调用必定 404」的死代码，已移除以免误导。
// 若后续要接入，需要先申请微信开放平台资质，然后：
//   1. 后端实现 /auth/wechat/url 与 /auth/wechat/login 两个接口
//   2. 前端新增回调页接收 code 并换取 token
