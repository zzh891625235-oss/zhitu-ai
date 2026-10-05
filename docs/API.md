# 智途AI · API 接口文档

- **Base URL**：`http://localhost:8080/api`
- **鉴权方式**：除标注「公开」的接口外，均需在请求头携带 JWT
  ```
  Authorization: Bearer <token>
  ```
- **统一响应结构**：
  ```json
  { "code": 200, "message": "success", "data": {} }
  ```
  `code` 为 `200` 表示成功；`400/401/404/500` 分别表示参数错误、未登录或登录失效、资源不存在、服务端异常。
  前端 axios 拦截器已经统一处理：非 200 会弹出 `message`，401 会清除 token 并跳转登录页。

---

## 一、认证与用户

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| POST | `/auth/register` | 注册（成功后直接返回 token，无需再登录） | 公开 |
| POST | `/auth/login` | 登录 | 公开 |
| GET | `/user/profile` | 获取当前用户基本信息（密码字段已置空） | 需要 |

**注册 / 登录请求体**

```json
{ "phone": "13800000000", "password": "123456", "nickname": "林知途" }
```

`nickname` 仅注册时可选，缺省为「同学」。

**响应 `data`**

```json
{ "token": "eyJhbGci...", "userId": 1, "nickname": "林知途", "role": "STUDENT" }
```

---

## 二、学生档案与 AI 画像

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| POST | `/profile` | 保存 / 更新档案（同一用户唯一，重复调用即更新） | 需要 |
| GET | `/profile` | 获取档案（附带 `majorName`） | 需要 |
| POST | `/ai/generate-portrait` | 生成 AI 学生画像并落库 | 需要 |
| GET | `/ai/portrait` | 获取已生成的画像 | 需要 |

**保存档案请求体**（字段与 `student_profile` 表一致）

```json
{
  "school": "华中科技大学",
  "majorId": 1,
  "grade": "大二",
  "gpa": "良好",
  "programmingLevel": "INTERMEDIATE",
  "javaLevel": "INTERMEDIATE",
  "pythonLevel": "BASIC",
  "cppLevel": "BASIC",
  "dsLevel": "BASIC",
  "dbLevel": "INTERMEDIATE",
  "webLevel": "INTERMEDIATE",
  "aiLevel": "BEGINNER",
  "englishLevel": "INTERMEDIATE",
  "interests": "[\"Java后端\",\"Web开发\"]",
  "careerGoal": "就业"
}
```

- `majorId`：整数，取自 `GET /majors` 返回的 `id`
- 能力等级取值：`BEGINNER` / `BASIC` / `INTERMEDIATE` / `ADVANCED`
- `interests`：JSON 数组的**字符串形式**
- `careerGoal`：`就业` / `考研` / `保研` / `考公` / `创业` / `暂未确定`

**画像响应 `data`**

```json
{
  "summary": "总体评价",
  "strengths": ["优势1", "优势2"],
  "weaknesses": ["短板1", "短板2"],
  "scores": { "programming": 72, "algorithm": 48, "project": 58,
              "competition": 35, "ai": 28, "english": 65, "overall": 51 },
  "suggestions": ["建议1", "建议2"],
  "threeMonthPlan": ["第1个月…", "第2个月…", "第3个月…"]
}
```

> 未配置 API Key 或调用失败时，返回规则模板生成的画像，结构完全一致。
> 可通过 `GET /ai/status` 判断当前是否为真实大模型输出。

---

## 三、专业与课程

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| GET | `/majors` | 专业字典（175 个，按 `sortOrder` 升序） | 公开 |
| GET | `/courses?majorId=1` | 某专业的课程列表（附带当前用户进度） | 公开 |
| GET | `/courses/{id}` | 课程详情 | 公开 |
| POST | `/courses/{id}/progress` | 更新学习进度 | 需要 |

**课程列表响应 `data`**（数组元素）

```json
{
  "id": 3, "name": "数据结构", "description": "线性表、栈、队列、树、图",
  "difficulty": "INTERMEDIATE", "semester": "大二上", "category": "核心基础",
  "sortOrder": 3, "progress": 60, "status": "IN_PROGRESS"
}
```

`status` 取值：`NOT_STARTED` / `IN_PROGRESS` / `COMPLETED`

**更新进度请求体**

```json
{ "progress": 80 }
```

服务端会把 `progress` 收敛到 `0–100`，并按是否达到 100 自动切换 `status`。

---

## 四、竞赛

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| GET | `/competitions` | 竞赛列表（支持筛选参数） | 公开 |
| GET | `/competitions/{id}` | 竞赛详情 | 公开 |

> 种子数据中的报名 / 比赛时间使用相对当前日期的表达式生成，
> 因此任何时间演示都能看到有效的报名倒计时。

---

## 五、AI 规划与推荐

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| POST | `/ai/generate-plan` | 生成大学四年规划（覆盖旧规划） | 需要 |
| GET | `/plan/four-year` | 获取已生成的四年规划 | 需要 |
| POST | `/ai/recommend-competitions` | 基于画像生成竞赛推荐与匹配度评分 | 需要 |
| POST | `/ai/generate-resume` | 生成 AI 简历（覆盖旧简历） | 需要 |
| GET | `/resume` | 获取已生成的简历 | 需要 |

**四年规划响应 `data`**

```json
{
  "overview": "总体概述",
  "freshman":  { "theme": "打好基础", "goals": [], "courses": [], "skills": [], "competitions": [], "tips": "" },
  "sophomore": { "theme": "核心能力建设", "goals": [], "courses": [], "skills": [], "competitions": [], "tips": "" },
  "junior":    { "theme": "实习与实战", "goals": [], "courses": [], "skills": [], "competitions": [], "tips": "" },
  "senior":    { "theme": "收获成果", "goals": [], "courses": [], "skills": [], "competitions": [], "tips": "" },
  "risks": ["风险提醒"],
  "certificates": ["推荐证书"]
}
```

**简历响应 `data`**

```json
{
  "name": "林知途",
  "education": { "school": "华中科技大学", "major": "计算机科学与技术", "grade": "大二" },
  "skills": [], "courses": [], "projects": [], "competitions": [], "certificates": [],
  "advantages": "个人优势",
  "targetPosition": "Java 后端开发工程师（实习）"
}
```

---

## 六、动态学习计划

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| POST | `/study-plan/generate?days=7` | 生成 / 刷新未来 N 天计划 | 需要 |
| GET | `/study-plan` | 获取当前计划 | 需要 |
| POST | `/study-plan/record` | 记录学习并触发 AI 分析 | 需要 |

**记录学习请求体**

```json
{ "content": "复习线性表", "minutes": 45, "courseId": 3 }
```

`minutes` 缺省 30，`courseId` 缺省 1；两类取值都做了宽松转换，传 `null` 或字符串不会报错。

**分析响应 `data`**

```json
{
  "level": "good",
  "emoji": "👍",
  "comment": "本周学习节奏稳定…",
  "suggestion": "建议下周把算法练习提到每天 1 小时",
  "totalMinutes": 320,
  "completedCount": 5
}
```

---

## 七、成长档案

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| POST | `/growth/record` | 添加一条成长记录 | 需要 |
| GET | `/growth/archive` | 获取成长档案汇总 | 需要 |

**添加记录请求体**

```json
{
  "recordType": "PROJECT",
  "title": "校园二手交易平台",
  "description": "Spring Boot + Vue 3 前后端分离",
  "recordDate": "2026-03-01",
  "evidenceUrl": "https://github.com/..."
}
```

`recordType` 取值：`PROJECT` / `COMPETITION` / `CERTIFICATE` / `INTERNSHIP` / `HONOR`

**汇总响应 `data`**

```json
{
  "records": { "PROJECT": [ { "id": "1", "title": "", "description": "", "date": "" } ] },
  "totalStudyMinutes": 6720,
  "coursesLearned": 6,
  "totalRecords": 6
}
```

---

## 八、AI 助手（含流式与模拟面试）

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| POST | `/ai/chat` | 一次性返回完整回答 | 需要 |
| POST | `/ai/chat-stream` | **流式返回**（NDJSON） | 需要 |
| GET | `/ai/chat-history?type=GENERAL` | 对话历史（最多 20 条） | 需要 |
| DELETE | `/ai/chat-history?type=GENERAL` | 清空该模式的对话历史 | 需要 |
| GET | `/ai/status` | AI 服务状态 | 需要 |

**对话模式 `type`**

| 值 | 模式 | 说明 |
| --- | --- | --- |
| `GENERAL` | 通用问答 | 学习成长咨询（默认） |
| `LEARNING` | 学习导师 | 概念解释与答疑 |
| `CAREER` | 职业规划 | 就业方向与求职建议 |
| `COMPETITION` | 竞赛咨询 | 赛事选择与备赛策略 |
| `INTERVIEW` | 模拟面试 | 面试官提问 + 逐条点评 |

**请求体**

```json
{ "question": "链表和数组有什么区别", "type": "LEARNING" }
```

### 流式接口说明

`POST /ai/chat-stream` 返回 `application/x-ndjson`，**每行一个完整 JSON 对象**：

```
{"type":"delta","text":"**链表 vs 数组**\n\n"}
{"type":"delta","text":"| 维度 | 数组 | 链表 |\n"}
{"type":"done","text":"{\"real\":true}"}
```

| `type` | 含义 |
| --- | --- |
| `delta` | 增量文本片段，前端追加到当前气泡 |
| `done` | 结束标记，`text` 是 JSON 字符串，字段 `real` 表示本次是否为真实大模型输出 |
| `error` | 服务异常提示 |

**为什么不用 SSE**：模型输出包含大量换行，SSE 的 `data:` 单行格式会丢掉换行后的内容；
且 `EventSource` 无法自定义 `Authorization` 头。NDJSON + `fetch` 流式读取可以同时解决这两个问题。

**AI 状态响应 `data`**

```json
{
  "provider": "deepseek",
  "model": "deepseek-chat",
  "configured": false,
  "keySource": "NONE",
  "lastCallReal": false
}
```

- `configured`：是否具备可用的 API Key
- `keySource`：`USER`（用户自备）/ `SYSTEM`（系统配置）/ `NONE`（未配置）
- `lastCallReal`：该用户最近一次调用是否真的命中大模型

---

## 九、AI 设置

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| GET | `/settings` | 读取用户 AI 配置（Key 已脱敏） | 需要 |
| PUT | `/settings` | 保存用户 AI 配置 | 需要 |
| POST | `/settings/test` | 测试当前配置能否连通 | 需要 |

**保存请求体**

```json
{
  "apiKey": "sk-xxxxxxxx",
  "apiUrl": "https://api.deepseek.com/v1",
  "model": "deepseek-chat"
}
```

`apiKey` 为空时不会覆盖已保存的 Key，便于前端在不回显完整 Key 的前提下只改地址或模型。

**读取响应 `data`**

```json
{ "apiKey": "sk-1****abcd", "apiUrl": "https://api.deepseek.com/v1",
  "model": "deepseek-chat", "hasKey": true }
```

**测试连接响应 `data`**

```json
{ "status": "ok", "message": "API连接成功！AI服务已就绪" }
```

失败时 `status` 为 `error`，`message` 为具体原因。

---

## 十、站内通知

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| GET | `/notifications` | 通知列表（最新 20 条） | 需要 |
| GET | `/notifications/unread-count` | 未读数量（导航栏红点） | 需要 |
| PUT | `/notifications/{id}/read` | 标记单条已读 | 需要 |
| PUT | `/notifications/read-all` | 全部标记已读 | 需要 |

**通知对象**

```json
{
  "id": 1, "userId": 1,
  "title": "蓝桥杯报名即将截止",
  "content": "你关注的赛事报名将于 40 天后截止…",
  "isRead": false,
  "createdAt": "2026-10-05T12:14:02"
}
```

标记已读时会校验通知归属，通过猜 ID 修改他人通知状态会返回 `404`。

---

## 十一、管理后台

整组接口要求 `ADMIN` 角色（`SecurityConfig` 中限定 `/api/admin/**`）。
普通学生访问会得到 `403`，响应体同样是统一结构。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/admin/stats` | 平台总览统计 |
| GET | `/admin/users?keyword=&page=1&size=10` | 用户列表（搜索 + 分页） |
| PUT | `/admin/users/{id}/role` | 修改用户角色 |
| DELETE | `/admin/users/{id}` | 删除用户及其全部关联数据 |

**统计响应 `data`（节选）**

```json
{
  "userCount": 2, "majorCount": 175, "courseCount": 53, "competitionCount": 10,
  "profileCount": 1, "portraitCount": 1, "planCount": 1, "resumeCount": 1,
  "chatCount": 0, "growthCount": 6,
  "todayUsers": 2,
  "registerTrend": [ { "date": "2026-09-29", "count": 0 } ],
  "chatByType": { "GENERAL": 3, "INTERVIEW": 1 }
}
```

**用户列表响应 `data`**

```json
{
  "records": [
    { "id": 1, "phone": "13800000000", "nickname": "林知途", "role": "STUDENT",
      "hasProfile": true, "school": "华中科技大学", "grade": "大二",
      "careerGoal": "就业", "majorName": "计算机科学与技术",
      "createdAt": "2026-10-05T12:14:02" }
  ],
  "total": 2, "page": 1, "size": 10, "pages": 1
}
```

- 响应中**绝不包含密码字段**
- `keyword` 同时匹配手机号与昵称
- `size` 上限为 50，防止一次拉取过多数据

**修改角色请求体**

```json
{ "role": "ADMIN" }
```

约束与反馈：

| 场景 | 结果 |
| --- | --- |
| 修改自己的角色 | `400 不能修改自己的角色，请让另一位管理员操作` |
| 把最后一名管理员降级 | `400 系统至少需要保留一名管理员` |
| 角色值不是 ADMIN / STUDENT | `400 角色只能是 ADMIN 或 STUDENT` |
| 成功 | `200 角色已更新为 ADMIN，该用户需重新登录后生效` |

> JWT 是无状态的，已签发的 Token 里仍带着旧角色，因此被修改的用户**需要重新登录**才会生效。

**删除用户**

会级联清理该用户在 9 张表里的全部数据（通知、成长记录、学习计划、学习记录、对话、规划、简历、AI 配置、学生档案），
整体在一个事务内完成。以下情况会被拒绝：

- 删除自己 → `400 不能删除自己的账号`
- 删除最后一名管理员 → `400 系统至少需要保留一名管理员`

---

## 十二、健康检查

| 方法 | 路径 | 说明 | 鉴权 |
| --- | --- | --- | --- |
| GET | `/health` | 服务健康检查 | 公开 |

---

## 附：快速自测（复制即用）

```bash
# 1. 登录拿 token
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800000000","password":"123456"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 2. 查档案（应包含 majorName）
curl -s http://localhost:8080/api/profile -H "Authorization: Bearer $TOKEN"

# 3. 查 AI 状态
curl -s http://localhost:8080/api/ai/status -H "Authorization: Bearer $TOKEN"

# 4. 试流式对话
curl -N -X POST http://localhost:8080/api/ai/chat-stream \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"question":"链表和数组有什么区别","type":"LEARNING"}'
```
