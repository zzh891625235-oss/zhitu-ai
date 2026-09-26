# 智途AI —— 大学生成长规划平台

> 让每一名大学生，都拥有一份属于自己的大学四年成长路线。

## 项目简介

智途AI是一个面向大学生的AI个性化成长规划平台。它不只是简单的"AI聊天网站"，而是让AI真正参与平台核心业务——根据学生的专业、年级、基础能力、兴趣方向和职业目标，由AI自动生成学生画像、四年规划、学习路线、竞赛推荐、动态学习计划和AI简历。

## 核心创新

- **AI学生画像** — 根据真实学情数据生成多维度能力评估
- **AI大学四年规划** — 大一到大四分阶段、分目标的系统规划
- **AI动态规划** — 根据实际学习进度，AI实时调整后续计划
- **AI竞赛推荐** — 学生画像驱动的个性化赛事匹配
- **AI简历生成** — 基于成长档案自动生成结构化的求职简历

## 技术架构

```
Vue 3 前端
    ↕ Axios / JWT
Spring Boot 后端
    ↕
MySQL + AI Service (DeepSeek/Qwen/OpenAI)
```

- 前端: Vue 3 + Vite + Element Plus + ECharts + Pinia
- 后端: Spring Boot 3 + Spring Security + MyBatis-Plus + JWT
- 数据库: MySQL 8.x
- AI: 统一AI服务接口，支持DeepSeek/Qwen/OpenAI兼容API

## 项目结构

```
zhitu-ai/
├── frontend/          # Vue 3 前端
│   ├── src/
│   │   ├── views/     # 页面组件
│   │   ├── router/    # 路由配置
│   │   ├── stores/    # Pinia状态管理
│   │   ├── api/       # API接口封装
│   │   ├── utils/     # 工具函数
│   │   └── layouts/   # 布局组件
│   └── package.json
├── backend/           # Spring Boot 后端
│   ├── src/main/java/com/zhitu/
│   │   ├── controller/  # 控制器
│   │   ├── service/     # 业务服务
│   │   ├── mapper/      # MyBatis数据访问
│   │   ├── entity/      # 实体类
│   │   ├── dto/         # 数据传输对象
│   │   ├── config/      # Spring配置
│   │   ├── ai/          # AI服务接口
│   │   └── utils/       # 工具类
│   └── pom.xml
├── database/          # 数据库脚本
│   ├── schema.sql     # 建表脚本
│   └── data.sql       # 种子数据
└── docs/              # 项目文档
```

## 环境要求

- JDK 17+
- Node.js 18+
- MySQL 8.x
- Maven 3.8+

## 快速开始

### 1. 创建数据库

```sql
-- 使用 MySQL 客户端执行
source database/schema.sql;
source database/data.sql;
```

### 2. 启动后端

```bash
cd backend
mvn spring-boot:run
```

### 3. 启动前端

```bash
cd frontend
npm install
npm run dev
```

访问 http://localhost:3000

### 4. 配置AI服务

在 `backend/src/main/resources/application.yml` 中或通过环境变量设置:

```bash
export AI_API_KEY=your-api-key
```

## 开发阶段

- [x] 第一阶段: 项目初始化 (前端/后端/数据库/Git)
- [ ] 第二阶段: 用户系统 (注册/登录/JWT)
- [ ] 第三阶段: 学生画像
- [ ] 第四阶段: AI大学四年规划
- [ ] 第五阶段: 专业学习模块
- [ ] 第六阶段: 竞赛中心
- [ ] 第七阶段: AI竞赛推荐
- [ ] 第八阶段: AI动态规划
- [ ] 第九阶段: 成长档案
- [ ] 第十阶段: AI简历
- [ ] 第十一阶段: 管理员后台
- [ ] 第十二阶段: 微信登录
- [ ] 第十三阶段: 部署上线
