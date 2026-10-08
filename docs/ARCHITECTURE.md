# 智途AI · 架构说明

本文档说明系统的分层结构、AI 能力的接入方式，以及几个关键设计取舍。

---

## 一、整体分层

```
┌─────────────────────────────────────────────────────────────┐
│  表现层  Vue 3 + Element Plus + ECharts                       │
│  · views/      11 个业务页面，全部按需加载（路由级代码分割）      │
│  · layouts/    主布局：顶部导航 + 3D 背景 + 页面过渡             │
│  · stores/     Pinia：用户态与 token 管理                       │
│  · api/        接口封装，统一经 utils/request.js（axios 实例）   │
│  · utils/      请求拦截、Markdown 渲染                          │
└───────────────────────────┬─────────────────────────────────┘
                            │  HTTP / JWT (Authorization: Bearer)
┌───────────────────────────▼─────────────────────────────────┐
│  接口层  Controller（12 个）                                   │
│  · 只做参数提取、调用 Service、包装 Result                      │
│  · 通过 Authentication 拿到 userId，不信任前端传入的用户标识      │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│  业务层  Service / ServiceImpl                                 │
│  · StudentProfileService  学情 → AI 画像                       │
│  · FourYearPlanService    学情 → 四年规划                       │
│  · StudyPlanService       打卡数据 → AI 分析 → 计划重排          │
│  · CompetitionRecommendService  画像 → 竞赛匹配打分             │
│  · ResumeService          档案 + 记录 → 结构化简历               │
└──────┬────────────────────────────────────┬──────────────────┘
       │                                    │
┌──────▼───────────────┐        ┌───────────▼──────────────────┐
│  数据访问层           │        │  AI 服务层                    │
│  MyBatis-Plus Mapper │        │  AIService（接口）            │
│  · 字段自动填充        │        │   └ DeepSeekProvider（实现）   │
│  · 逻辑简单，无 XML    │        │      兼容 OpenAI 协议          │
└──────┬───────────────┘        └───────────┬──────────────────┘
       │                                    │
┌──────▼───────────────┐        ┌───────────▼──────────────────┐
│  MySQL 8.x（14 张表） │        │  DeepSeek / OpenAI / 千问     │
└──────────────────────┘        └──────────────────────────────┘
```

---

## 二、一次 AI 请求的完整链路

以「生成大学四年规划」为例：

```
前端 Plan.vue
  └─ generatePlanApi()                    POST /api/ai/generate-plan
       └─ JwtAuthFilter                   校验 Token，把 userId 放进 SecurityContext
            └─ PlanController             从 Authentication 取 userId（不信任请求体）
                 └─ FourYearPlanServiceImpl
                      ├─ 读 student_profile + user
                      ├─ 按 majorId 查 major 表拿**真实专业名**（不再硬编码）
                      ├─ 拼装提示词，强制约束 JSON 结构
                      ├─ aiService.chatForUser(userId, ...)
                      │    └─ DeepSeekProvider
                      │         ├─ 先查 user_settings（用户自备 Key 优先）
                      │         ├─ 未配置 → 直接降级为规则模板，并记录「本次非大模型」
                      │         ├─ 已配置 → 调用 chat/completions，失败按 maxRetries 重试
                      │         └─ 全部失败 → 降级模板，同样记录状态
                      ├─ 解析返回 JSON（截取首个 { 到末个 }）
                      ├─ 解析失败 → 走规则兜底模板
                      └─ 覆盖式写入 ai_plan（同用户同类型只保留最新一份）
  └─ 前端渲染四年时间线，当前年级从档案动态读取
```

---

## 三、AI 服务层设计

### 3.1 为什么要有 `AIService` 接口

平台有 6 处能力依赖大模型（画像、四年规划、动态计划、竞赛推荐、简历、助手对话）。
如果每处都直接调用 HTTP 接口，换厂商就要改 6 个地方。

因此定义单一接口：

```java
public interface AIService {
    String chat(String systemPrompt, String userMessage);
    String chatWithKey(String sp, String um, String apiKey, String apiUrl, String model);
    String chatForUser(Long userId, String sp, String um);
    String chatStreamForUser(Long userId, String sp, String um, Consumer<String> onDelta);
    String getUserApiKey(Long userId);
    Map<String, Object> status(Long userId);
}
```

切换服务商只需改 `application.yml`：

```yaml
ai:
  api-url: https://dashscope.aliyuncs.com/compatible-mode/v1   # 换成千问
  model: qwen-plus
```

业务代码零改动。

### 3.2 Key 的优先级与隔离

```
用户自备 Key（user_settings 表，按 user_id 隔离）
        ↓ 未配置时
系统级 Key（application.yml / 环境变量）
        ↓ 也没有
离线模板模式
```

设计要点：
- 返回给前端的 Key 做了脱敏（`sk-1****abcd`），完整 Key 不出后端
- 用户表里存的 Key 与业务数据在同一个库，但接口层不提供「查询他人设置」的入口
- 每次请求只查一次 `user_settings`（早期实现会查 3 次，属于典型的 N+1 查询）

### 3.3 降级策略：宁可说清楚，也不假装

这是本项目一个刻意的设计选择。

很多 AI 演示项目会在调用失败时返回一段写死的文案，界面上看起来仍然「像 AI 生成的」。
智途AI 反过来做：

1. 降级时把该用户最近一次调用标记为 `lastCallReal = false`
2. 通过 `GET /api/ai/status` 暴露给前端
3. 前端在 AI 助手顶部展示「离线模板模式」徽章，每条降级回答下方标注「离线模板」

这样评审和学生都能准确知道自己看到的是什么。

### 3.4 流式输出为什么不用 SSE

标准 SSE 的格式是：

```
data: 第一行内容
data: 第二行内容

```

模型回答里有大量换行（Markdown 列表、代码块都要换行）。若直接把含 `\n` 的字符串
写进 `data:`，换行后的内容会因为缺少 `data:` 前缀而被 EventSource 丢弃。

同时 `EventSource` 无法自定义请求头，带不了 `Authorization`。

因此改用 **NDJSON**（每行一个完整 JSON 对象）：

```
{"type":"delta","text":"**链表 vs 数组**\n\n"}
{"type":"delta","text":"| 维度 | 数组 | 链表 |\n"}
{"type":"done","text":"{\"real\":true}"}
```

前端用 `fetch` + `ReadableStream` 按行解析，既能完整保留换行，
也能携带 Token，还能在 `done` 事件里回传「本次是否为真实大模型输出」。

---

## 四、数据模型要点

| 设计点 | 说明 |
| --- | --- |
| 统一专业 ID | `student_profile.major_id`、`course.major_id` 都关联 `major.id`（175 个专业），全链路共用一套 ID |
| 一对一表用唯一键 | `student_profile`、`resume`、`user_settings` 都对 `user_id` 建了唯一索引，防止并发写入产生重复记录 |
| 学习记录去重 | `learning_record` 对 `(user_id, course_id)` 建唯一键，进度更新用「有则更新、无则插入」 |
| 幂等种子数据 | 三个 SQL 脚本均可重复执行：结构用 `IF NOT EXISTS`，字典与业务数据用 `ON DUPLICATE KEY UPDATE` |
| JSON 字段 | `ai_portrait`、`ai_plan.content`、`resume.content` 存 AI 原始输出的 JSON 文本 |

---

## 五、前端工程要点

| 设计点 | 说明 |
| --- | --- |
| 设计系统统一 | `assets/style.css` 定义深色玻璃主题变量；早期各页面从不同模板拼来，引用了大量未定义变量（导致文字看不见），已通过「兼容别名层」统一收口 |
| 路由级分包 | 所有页面 `() => import(...)`，Vite 自动按页面切 chunk |
| ECharts 按需引入 | 只注册 `RadarChart + RadarComponent + TooltipComponent + CanvasRenderer`，避免把整个 echarts 打进首屏 |
| 图表生命周期 | `resize` 监听只在 `onMounted` 注册一次，`onUnmounted` 移除并销毁实例，避免内存泄漏 |
| 移动端适配 | 导航在窄屏折成第二行横向滚动；栅格降列；聊天区高度按视口计算 |
| Markdown 渲染 | 自写轻量渲染器（标题/列表/表格/代码块/引用），先 HTML 转义再渲染，可安全用于 `v-html` |

---

## 六、安全设计

| 项目 | 措施 |
| --- | --- |
| 密码存储 | BCrypt 加盐哈希，`/api/user/profile` 返回前显式置空密码字段 |
| 身份识别 | 一律从 JWT 解析出的 `userId` 获取，不接受前端传入的用户 ID |
| 接口鉴权 | `SecurityConfig` 白名单仅放行注册/登录/健康检查/专业/课程/竞赛，其余全部要求认证 |
| 权限分级 | `/api/admin/**` 要求 `ROLE_ADMIN`。JWT 中携带角色，`JwtAuthFilter` 将其转换为 Spring Security 权限（`ADMIN` → `ROLE_ADMIN`）；旧 Token 不含角色时按 `STUDENT` 兜底，不会让老用户集体掉线 |
| 越权防护 | 通知的「标记已读」会校验归属；管理员不能修改自己的角色，也不能删除自己或最后一名管理员 |
| SQL 注入 | 全部使用 MyBatis-Plus 条件构造器，无字符串拼接 SQL |
| XSS | AI 返回内容先 HTML 转义再渲染 Markdown；`v-html` 内容不可信但已转义 |
| 配置外置 | 数据库密码、JWT secret、AI Key 全部支持环境变量覆盖，仓库内不存放真实密钥 |

---

## 七、当前边界与后续方向

已明确知道但尚未完成的部分：

1. **知识点级进度**：`knowledge_point` 表已建模并录入示例数据，UI 仍停留在课程级进度
2. **微信登录**：需要微信开放平台资质，当前未实现（前端此前的死接口已移除）
3. **权限粒度**：只有 `STUDENT` / `ADMIN` 两级。管理员能看统计与用户列表，
   但看不到他人的画像、规划等隐私内容——这是有意的边界，不是遗漏
4. **Docker 编排未实测**：文件已按标准写好，但开发机没有 Docker，未在真实容器中跑过
5. **数据覆盖面**：课程已按 18 个专业方向铺到全部 175 个专业（约 3950 条），竞赛 47 条
   并按 `suitable_major` 参与专业匹配；但方向划分是「够用」而非「精确」——
   同一方向内不同专业的课程完全一致，尚未做到一专业一套课程表
6. **岗位与薪资数据**：发展方向页的薪资区间、考研方向是保守编写的参考文案，
   不是统计结果，页面已明确标注「参考区间」

这些不是遗漏，而是有意识地记录下来，避免假装项目已经完成。

---

## 八、工程化配套

| 能力 | 位置 | 说明 |
| --- | --- | --- |
| 数据库初始化 | `scripts/init-db.ps1` / `.sh` | 三个 SQL 依次执行，可重复运行 |
| 一键启停 | `scripts/start-dev.*` / `stop-dev.*` | 依赖检查 + 前后端启动 |
| Mock AI 服务 | `scripts/mock-ai-server.mjs` | 兼容 OpenAI 协议，无 Key 也能验证完整 AI 链路 |
| 专业字典生成 | `scripts/gen-majors.mjs` | 由前端 `majors.js` 生成 `database/majors.sql` |
| 课程数据生成 | `scripts/gen-courses.mjs` + `scripts/course-templates.mjs` | 读后端 `MajorDirection.java` 的正则，把 18 个方向的课程模板铺到 175 个专业。改模板后重跑即可，避免 175 份课程表与后端方向判断漂移 |
| 单元测试 | `backend/src/test`、`frontend/src/utils/*.test.mjs` | 后端 52 个、前端 12 个 |
| 容器编排 | `docker-compose.yml` + 两个 Dockerfile | 含 nginx 流式与 SPA 路由配置 |
