#!/usr/bin/env bash
# 智途AI 一体化打包：前端构建 → 拷进后端 static → 打 jar → 更新便携版目录
set -e
cd "$(dirname "$0")/.."

echo "============================================"
echo "  智途AI 一体化打包"
echo "============================================"
echo

echo "[1/4] 构建前端产物..."
(cd frontend && npm run build)

echo "[2/4] 同步静态资源到后端..."
rm -rf backend/src/main/resources/static/assets
cp -r frontend/dist/assets backend/src/main/resources/static/
cp frontend/dist/index.html backend/src/main/resources/static/index.html

echo "[3/4] 打包后端（含前端产物）..."
(cd backend && mvn -DskipTests package)

echo "[4/4] 更新便携版目录..."
mkdir -p "智途AI-便携版"
cp backend/target/zhitu-ai-1.0.0.jar "智途AI-便携版/zhitu-ai.jar"

echo
echo "============================================"
echo "  打包完成！"
echo "  产物：智途AI-便携版/zhitu-ai.jar"
echo "  运行：java -jar 智途AI-便携版/zhitu-ai.jar"
echo "============================================"
