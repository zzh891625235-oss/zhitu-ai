# ============================================================
# 智途AI 前端镜像（多阶段构建）
#
# 构建：docker build -t zhitu-frontend ./frontend
# 产物：静态文件交给 nginx 托管，并把 /api 反向代理到后端容器
# ============================================================

# ---------- 构建阶段 ----------
FROM node:18-alpine AS build
WORKDIR /app

# 依赖清单单独一层，package-lock.json 未变时可复用缓存
COPY package*.json ./
RUN npm ci --no-audit --no-fund

COPY . .
RUN npm run build

# ---------- 运行阶段 ----------
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
