# 智途AI · 部署与运行手册

本文档说明三种运行方式、如何在没有 API Key 的情况下验证完整 AI 链路，以及生产环境注意事项。

---

## 一、三种运行方式

| 方式 | 适用场景 | 命令 |
| --- | --- | --- |
| 一键脚本 | 本地开发，最省事 | `scripts/start-dev.ps1` / `start-dev.sh` |
| 手动启动 | 需要在 IDE 里调试 | 见下方「手动启动」 |
| Docker Compose | 部署演示、交付评审 | `docker compose up -d --build` |

---

## 二、本地开发（推荐）

### 2.1 一键脚本（推荐）

**Windows：双击项目根目录的 bat 文件即可，不需要敲任何命令**

| 文件 | 作用 |
| --- | --- |
| `init-db.bat` | 初始化数据库（首次使用先运行这个） |
| `start.bat` | 启动前后端，并自动打开浏览器 |
| `start.bat check` | 只检查环境与端口占用，不启动服务 |
| `start.bat init` | 先初始化数据库，再启动 |

`start.bat` 会依次完成：检查 java / mvn / node / npm → 检查 8080、3000 端口是否被占用 →
首次运行时安装前端依赖 → 分别在两个新窗口启动后端和前端 → 约 35 秒后打开浏览器。

> 如果数据库密码不是默认的 `123456`，先设置环境变量再双击：
> 在命令行执行 `set DB_PASSWORD=你的密码` 后运行 `start.bat`，或直接用下面的 PowerShell 脚本。

**macOS / Linux：**

```bash
bash scripts/init-db.sh          # 首次：初始化数据库
bash scripts/start-dev.sh        # 启动前后端（日志在 logs/）
bash scripts/stop-dev.sh         # 停止
```

也可以直接调用 PowerShell 脚本，支持更多参数：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/init-db.ps1 -DbPort 3307 -DbPassword 你的密码
powershell -ExecutionPolicy Bypass -File scripts/start-dev.ps1 -InitDb
powershell -ExecutionPolicy Bypass -File scripts/start-dev.ps1 -DryRun   # 只打印将要执行的命令
```

启动后访问 http://localhost:3000

### 2.2 手动启动

```bash
# 后端
cd backend
mvn spring-boot:run

# 前端（另开一个终端）
cd frontend
npm install
npm run dev
```

数据库账号不是默认值时，先设置环境变量：

```bash
# Windows
set DB_USERNAME=root && set DB_PASSWORD=你的密码

# macOS / Linux
export DB_USERNAME=root DB_PASSWORD=你的密码
```

---

## 三、Docker Compose 部署

```bash
# 可选：先准备 .env 配置真实 AI Key（不配也能跑，走离线模板模式）
cp .env.example .env

docker compose up -d --build
docker compose logs -f backend      # 查看后端日志
docker compose down                 # 停止（加 -v 会同时删除数据库卷）
```

| 服务 | 地址 | 说明 |
| --- | --- | --- |
| frontend | http://localhost:3000 | nginx 托管静态文件，并把 `/api` 反代到后端 |
| backend | http://localhost:8080 | Spring Boot |
| mysql | localhost:3307 | 默认映射到 3307，避免和本机已装的 MySQL 冲突 |

**三个脚本的初始化顺序**由文件名前缀锁定（`01-schema.sql` → `02-majors.sql` → `03-data.sql`），
因为 MySQL 容器的 `docker-entrypoint-initdb.d` 是按文件名字典序执行的。

### 几个容易踩的点

1. **AI 流式输出必须关闭 nginx 缓冲**——`frontend/nginx.conf` 里已设置 `proxy_buffering off`。
   如果自己写反代配置，漏了这一条打字机效果就会消失（内容被攒成一整块才返回）。
2. **前端是 history 路由**——必须有 `try_files $uri $uri/ /index.html`，
   否则刷新 `/home/admin` 这类深层路径会 404。
3. **数据库数据在具名卷里**——`docker compose down`（不带 `-v`）不会丢数据；
   但种子脚本只在**首次**创建数据卷时执行，改了 SQL 需要 `down -v` 重建。

> **诚实说明**：本项目的开发环境没有安装 Docker，因此这份编排文件**未能在真实容器中运行验证过**。
> 配置本身按标准写法编写并逐条加了注释，但首次使用请预留排查时间。
> 本地开发与接口链路是完整验证过的。

---

## 四、没有 API Key 时如何验证完整 AI 链路

这是本项目提供的一个实用工具。真实调用大模型的代码路径（HTTP 请求构造、JSON 解析、
流式 SSE 解析、失败重试、状态标记）都可以在没有 Key 的情况下验证：

```bash
# 1. 启动本地 mock AI 服务（兼容 OpenAI Chat Completions 协议）
node scripts/mock-ai-server.mjs

# 2. 让后端指向它
#    Windows
set AI_API_KEY=sk-mock && set AI_API_URL=http://localhost:8899/v1 && set AI_MODEL=mock-model
#    macOS / Linux
export AI_API_KEY=sk-mock AI_API_URL=http://localhost:8899/v1 AI_MODEL=mock-model

# 3. 启动后端，然后正常使用平台
cd backend && mvn spring-boot:run
```

mock 服务会按 system 提示词判断业务类型，返回**结构完全正确**的应答，
因此画像、四年规划、简历、竞赛推荐、学习计划、流式对话都能真实跑通。

判断依据：所有 mock 返回内容都带 `[MOCK-AI]` 前缀。

- 看到 `[MOCK-AI]` → 说明请求真实走完了 HTTP 与流式解析链路
- 没看到 → 说明走了离线模板（降级路径）

也可以直接查接口：

```bash
curl -s http://localhost:8080/api/ai/status -H "Authorization: Bearer $TOKEN"
# {"configured":true,"keySource":"SYSTEM","lastCallReal":true,...}
```

`lastCallReal` 为 `true` 表示最近一次调用真的命中了大模型。

---

## 五、运行测试

```bash
# 后端：138 个单元测试
cd backend && mvn test

# 前端：12 个单元测试（用 Node 内置测试运行器，无需额外依赖）
cd frontend && npm test
```

测试覆盖的重点：

| 测试 | 守住什么 |
| --- | --- |
| `ResultTest` | `Result.success("中文提示")` 必须走 message 而不是被当成 data（曾经丢过 7 处提示） |
| `PasswordUtilsTest` | BCrypt 加盐；**并校验 `data.sql` 里的演示账号哈希确实对应 `123456`** |
| `JwtUtilsTest` | Token 解析、角色读取、旧 Token 无角色时的兜底、篡改与过期必须被拒 |
| `DeepSeekProviderTest` | Key 优先级、占位 Key 不算已配置、连不上时必须如实标记为「非真实 AI」 |
| `markdown.test.mjs` | 表格/代码块/列表渲染；**渲染前必须做 HTML 转义（XSS 防护）** |

---

## 六、生产环境注意事项

| 项目 | 建议 |
| --- | --- |
| `JWT_SECRET` | **必须替换**。默认值写在仓库里，任何人都能伪造 Token |
| `DB_PASSWORD` | 不要用 `123456`，也不要提交进仓库 |
| `SQL_LOG_IMPL` | 改为 `org.apache.ibatis.logging.nologging.NoLoggingImpl`，否则学生数据会打进日志 |
| `AI_API_KEY` | 通过环境变量注入，不要写进 `application.yml` 后提交 |
| 管理员账号 | `13900000000` 是演示账号，正式上线前请改密码或删除 |
| 竞赛日期 | `data.sql` 用的是相对当前日期的表达式（保证演示总有倒计时），正式环境请替换为官方公布日期 |
| HTTPS | 前端已带基础安全响应头，但 Token 走明文传输，对外必须套 HTTPS |
| 备份 | 备份 `zhitu_ai` 库；用户档案与成长记录是平台最有价值的数据 |

---

## 七、常见问题排查

| 现象 | 排查方向 |
| --- | --- |
| **执行 `data.sql` 报 `Unknown column 'xxx' in 'field list'`** | 你的数据库是**旧结构**（用更早的脚本或手工建的）。`schema.sql` 末尾已内置幂等迁移：会自动补齐缺失的列，并补建唯一索引（补齐前会先去重），直接重新运行 `init-db` 即可。若仍失败，用 `init-db.ps1 -Reset`（或 `init-db.bat -Reset`）删库重建 |
| 重复执行后数据翻倍 | 同上原因——旧表缺少唯一键导致 `ON DUPLICATE KEY UPDATE` 失效。重新运行一次 `init-db` 即可补上唯一索引并去重 |
| 页面提示「请先完成档案初始化」 | 正常业务提示，去 `/init` 完善档案即可 |
| 所有 AI 结果都不带个性化 | 检查是否处于离线模板模式：看 AI 助手顶部的模式徽章，或查 `/api/ai/status` |
| 流式对话变成一次性返回 | 反向代理的缓冲没关（nginx 需 `proxy_buffering off`） |
| 刷新深层路由出现 404 | SPA 路由回退缺失（nginx 需 `try_files ... /index.html`） |
| 「API 设置」保存报错 | 检查 `user_settings` 表是否存在，执行 `database/schema.sql` |
| 课程页显示的是计算机方向的课 | 老版本的行为，已修复。若仍出现，说明课程数据没更新：重新执行 `database/data.sql`（课程已覆盖全部 175 个专业） |
| 竞赛推荐给护理学学生推了程序设计竞赛 | 老版本的行为，已修复。`suitable_major` 现在真正参与匹配，确认后端已用最新代码重启 |
| 中文在 Windows 控制台显示乱码 | PowerShell 控制台编码问题，不影响数据本身；用浏览器或 `curl` 输出到文件查看 |
