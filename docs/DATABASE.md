# 智途AI · 数据库设计

- **数据库**：MySQL 8.x，字符集 `utf8mb4` / `utf8mb4_unicode_ci`
- **库名**：`zhitu_ai`
- **表数量**：14 张
- **脚本分层**（执行顺序不可颠倒）：

| 文件 | 职责 | 幂等性 |
| --- | --- | --- |
| `schema.sql` | 建库建表，纯 DDL，不含业务数据 | `CREATE TABLE IF NOT EXISTS` |
| `majors.sql` | 专业字典（175 个专业 / 12 个学科门类） | `ON DUPLICATE KEY UPDATE` |
| `data.sql` | 课程、竞赛、知识点、演示账号与示例业务数据 | `ON DUPLICATE KEY UPDATE` / 先删后插 |

三个脚本可以反复执行，不会产生重复数据，也不会破坏其它账号的数据。

---

## 一、表关系总览

```
user ──1:1── student_profile ──N:1── major
  │                │
  │                └── ai_portrait (JSON，AI 画像)
  │
  ├──1:1── user_settings        （用户自备 AI Key）
  ├──1:N── ai_plan              （FOUR_YEAR / STUDY / COMPETITION）
  ├──1:N── learning_record ──N:1── course ──N:1── major
  │                                   └──1:N── knowledge_point
  ├──1:N── study_plan           （每日任务与打卡）
  ├──1:N── growth_record        （项目/竞赛/证书/实习/荣誉）
  ├──1:N── ai_chat              （按 chat_type 分组的历史对话）
  ├──1:1── resume
  └──1:N── notification

competition                     （独立字典表，通过 suitable_major 与专业弱关联）
```

---

## 二、表结构说明

### 1. `user` — 用户

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | BIGINT PK | 自增主键 |
| `phone` | VARCHAR(20) | 登录账号，唯一索引 `uk_phone` |
| `password` | VARCHAR(255) | BCrypt 哈希，**不存明文** |
| `nickname` | VARCHAR(50) | 昵称，注册时缺省为「同学」 |
| `avatar` | VARCHAR(500) | 头像地址 |
| `role` | VARCHAR(20) | `STUDENT` / `ADMIN`（管理员功能预留） |

### 2. `user_settings` — 用户级 AI 配置

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `user_id` | BIGINT | 唯一索引 `uk_user_id`，一个用户一条 |
| `api_key` | VARCHAR(255) | 用户自备 Key，优先级高于系统配置 |
| `api_url` | VARCHAR(255) | 兼容 OpenAI 协议的接口地址 |
| `model` | VARCHAR(100) | 模型名 |

> 这张表曾经在建表脚本中缺失，导致「API 设置」页保存必然失败，已补上。

### 3. `major` — 专业字典

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | BIGINT PK | **显式指定**（1–175），保证 `course.major_id` 引用稳定 |
| `name` | VARCHAR(100) | 唯一索引 `uk_major_name`，如「计算机科学与技术」 |
| `category` | VARCHAR(50) | 学科门类：工学 / 理学 / 医学 / 管理学 … |

前 5 条固定为：1 计算机科学与技术、2 软件工程、3 人工智能、4 大数据科学与技术、5 电子信息工程。

> `majors.sql` 由 `frontend/src/data/majors.js` 通过 `.tmp/gen-majors.mjs` 生成，
> 避免手工维护 175 条数据出错。

### 4. `student_profile` — 学生档案（1:1）

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `user_id` | BIGINT | 唯一索引 `uk_user_id` |
| `school` | VARCHAR(100) | 学校 |
| `major_id` | BIGINT | 关联 `major.id`（**全链路统一用专业表主键**） |
| `grade` | VARCHAR(20) | 大一 / 大二 / 大三 / 大四 / 研一… |
| `gpa` | VARCHAR(10) | 成绩水平：优秀 / 良好 / 中等 / 待提升 |
| `*_level` | VARCHAR(20) | 9 项能力自评：`BEGINNER` / `BASIC` / `INTERMEDIATE` / `ADVANCED` |
| `interests` | TEXT | 兴趣方向，JSON 数组的字符串形式 |
| `career_goal` | VARCHAR(50) | 就业 / 考研 / 保研 / 考公 / 创业 / 暂未确定 |
| `ai_portrait` | JSON | AI 画像原始输出 |

> 早期实现把专业名哈希成一个数字存进 `major_id`，导致首页专业名永远为空、
> 课程页永远显示计算机专业的课。现已改为统一引用 `major.id`。

### 5. `course` — 课程

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `major_id` | BIGINT | 关联 `major.id` |
| `name` | VARCHAR(200) | 课程名 |
| `difficulty` | VARCHAR(20) | `BEGINNER` / `INTERMEDIATE` / `ADVANCED` |
| `semester` | VARCHAR(20) | 建议修读学期，如「大二上」 |
| `category` | VARCHAR(50) | 编程基础 / 核心基础 / AI方向 … |
| `sort_order` | INT | 学习地图中的顺序 |

唯一索引 `uk_course_major_name (major_id, name)` 保证重复执行种子脚本不会插入重复课程。

当前覆盖 5 个方向共 **53 门课程**：计算机 12、软件工程 10、人工智能 11、大数据 10、电子信息 10。

### 6. `knowledge_point` — 知识点

课程下的学习节点，支持 `parent_id` 自关联形成树。

> **当前状态**：表已建模并录入「数据结构」的 6 个知识点示例，
> 但 UI 仍停留在课程级进度，尚未接入知识点级进度追踪，属于预留扩展点。

### 7. `competition` — 竞赛字典

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `name` | VARCHAR(200) | 唯一索引 `uk_competition_name` |
| `type` | VARCHAR(50) | 算法编程 / 数学建模 / 创新创业 / 电子设计 / 英语 |
| `suitable_major` | VARCHAR(500) | 适配专业，JSON 数组字符串 |
| `registration_start/end` | DATE | 报名起止 |
| `competition_start/end` | DATE | 比赛起止 |
| `difficulty` | VARCHAR(20) | `BEGINNER` / `INTERMEDIATE` / `ADVANCED` |
| `official_url` | VARCHAR(500) | 官网 |
| `recommend_days` | INT | 建议提前备赛天数 |

> 种子数据中的日期使用 `DATE_SUB(CURDATE(), INTERVAL n DAY)` 这类相对表达式生成，
> 保证任何时间演示都有「报名中」的赛事和有效的倒计时。
> **正式部署时需替换为赛事官方公布的固定日期。**

### 8. `ai_plan` — AI 规划结果

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `user_id` | BIGINT | 索引 `idx_user_plan (user_id, plan_type)` |
| `plan_type` | VARCHAR(50) | `FOUR_YEAR` / `STUDY` / `COMPETITION` |
| `content` | JSON | AI 返回的结构化规划 |
| `start_date` / `end_date` | DATE | 规划周期 |

同一用户同一类型只保留最新一份（生成前先删除旧的）。

### 9. `learning_record` — 课程学习进度

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `user_id` + `course_id` | BIGINT | 唯一索引 `uk_user_course`，防止并发产生重复记录 |
| `progress` | INT | 0–100 |
| `study_minutes` | INT | 累计学习分钟数 |
| `status` | VARCHAR(20) | `IN_PROGRESS` / `COMPLETED` |

### 10. `study_plan` — 每日学习计划

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `plan_date` | DATE | 计划日期，索引 `idx_user_date (user_id, plan_date)` |
| `content` | VARCHAR(500) | 当日任务描述 |
| `is_completed` | TINYINT(1) | 是否打卡完成 |

### 11. `growth_record` — 成长档案

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `record_type` | VARCHAR(50) | `PROJECT` / `COMPETITION` / `CERTIFICATE` / `INTERNSHIP` / `HONOR` |
| `title` | VARCHAR(200) | 记录标题 |
| `description` | TEXT | 详细描述 |
| `record_date` | DATE | 发生时间 |
| `evidence_url` | VARCHAR(500) | 佐证链接（GitHub / 证书图片等） |

### 12. `ai_chat` — AI 对话记录

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `chat_type` | VARCHAR(50) | 与对话模式对应：`GENERAL` / `LEARNING` / `CAREER` / `COMPETITION` / `INTERVIEW` |
| `question` / `answer` | TEXT | 问答内容 |

历史按 `user_id + chat_type` 查询，倒序取最近 20 条。

### 13. `resume` — AI 简历（1:1）

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `user_id` | BIGINT | 唯一索引 `uk_user_id` |
| `content` | JSON | 结构化简历（教育背景 / 技能 / 项目 / 竞赛 / 证书…） |
| `template` | VARCHAR(50) | 模板标识，预留多模板切换 |

### 14. `notification` — 站内通知

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `user_id` | BIGINT | 索引 `idx_user_read (user_id, is_read)` |
| `title` / `content` | VARCHAR | 通知标题与正文 |
| `is_read` | TINYINT(1) | 是否已读 |

> 导航栏通知铃铛、未读红点与「标记已读 / 全部已读」交互已接入（`NotificationController`），
> 标记已读会校验通知归属，防止通过猜 ID 修改他人通知。

---

## 三、演示数据说明

`data.sql` 会创建一个完整的演示账号，让评审登录后所有页面都有内容：

| 项目 | 内容 |
| --- | --- |
| 账号 | `13800000000` / `123456`（密码为 BCrypt 哈希，非明文） |
| 档案 | 华中科技大学 · 计算机科学与技术 · 大二 · 就业方向 |
| 画像 | 含 6 维评分（综合 51 分）、3 条优势、3 条短板、4 条建议、3 个月计划 |
| 四年规划 | 大一到大四完整分阶段内容 + 3 条风险提醒 + 3 项证书推荐 |
| 学习计划 | 今天起 7 天的每日任务 |
| 学习进度 | 6 门课程记录，累计 6720 分钟 |
| 成长档案 | 2 个项目 + 1 个竞赛 + 1 个证书 + 1 项荣誉 + 1 段实习 |
| 简历 | 完整结构化简历，含意向岗位 |
| 通知 | 3 条站内通知 |

---

## 四、常用运维 SQL

```sql
USE zhitu_ai;

-- 查看各表数据量
SELECT 'major' t, COUNT(*) c FROM major
UNION ALL SELECT 'course', COUNT(*) FROM course
UNION ALL SELECT 'competition', COUNT(*) FROM competition
UNION ALL SELECT 'user', COUNT(*) FROM user
UNION ALL SELECT 'student_profile', COUNT(*) FROM student_profile;

-- 查看某学生的完整档案
SELECT u.nickname, p.school, m.name AS major, p.grade, p.career_goal
FROM user u
JOIN student_profile p ON p.user_id = u.id
LEFT JOIN major m ON m.id = p.major_id
WHERE u.phone = '13800000000';

-- 查看某学生的课程进度
SELECT c.name, c.semester, lr.progress, lr.status
FROM learning_record lr
JOIN course c ON c.id = lr.course_id
WHERE lr.user_id = 1
ORDER BY lr.progress DESC;

-- 重置演示账号的密码为 123456（忘记密码时）
UPDATE user SET password = '$2a$10$Cdp6ZQ1X9bqElozp94P3j.iTnR6Wpp/fVEhfjtyjd/CeeiWnHGBGG'
WHERE phone = '13800000000';
```
