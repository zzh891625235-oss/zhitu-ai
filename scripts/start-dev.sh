#!/usr/bin/env bash
# ============================================================
# 智途AI —— 本地开发环境一键启动（macOS / Linux）
#
# 用法：
#   bash scripts/start-dev.sh
#   INIT_DB=1 bash scripts/start-dev.sh        # 先初始化数据库
#   DRY_RUN=1 bash scripts/start-dev.sh        # 只打印命令
#   DB_PORT=3307 DB_PASSWORD=xxx bash scripts/start-dev.sh
#
# 后端与前端在后台运行，日志写到 logs/ 目录：
#   tail -f logs/backend.log
#   tail -f logs/frontend.log
# 停止： bash scripts/stop-dev.sh
# ============================================================
set -euo pipefail

DB_PORT="${DB_PORT:-3306}"
DB_PASSWORD="${DB_PASSWORD:-123456}"
INIT_DB="${INIT_DB:-0}"
DRY_RUN="${DRY_RUN:-0}"
FRONTEND_PORT="${FRONTEND_PORT:-3000}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
LOG_DIR="$PROJECT_ROOT/logs"

echo "智途AI 开发环境启动检查"
echo

# ---------- 1. 依赖检查 ----------
missing=0
for cmd in java mvn node npm; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[就绪] $cmd"
    else
        echo "[缺少] $cmd" >&2
        missing=1
    fi
done
if [ "$INIT_DB" = "1" ] && ! command -v mysql >/dev/null 2>&1; then
    echo "[缺少] mysql —— 请把 MySQL 的 bin 目录加入 PATH" >&2
    missing=1
fi
if [ "$missing" = "1" ]; then
    echo
    echo "请先补齐上面的依赖再重试。" >&2
    exit 1
fi

# ---------- 2. 演练模式 ----------
if [ "$DRY_RUN" = "1" ]; then
    echo
    echo "[演练模式] 即将执行："
    echo "  初始化数据库: ${INIT_DB}"
    echo "  后端: cd $BACKEND_DIR && DB_PORT=$DB_PORT mvn spring-boot:run"
    echo "  前端: cd $FRONTEND_DIR && npm run dev"
    exit 0
fi

# ---------- 3. 可选：初始化数据库 ----------
if [ "$INIT_DB" = "1" ]; then
    echo
    echo "正在初始化数据库..."
    DB_PASSWORD="$DB_PASSWORD" DB_PORT="$DB_PORT" bash "$SCRIPT_DIR/init-db.sh"
fi

# ---------- 4. 启动 ----------
mkdir -p "$LOG_DIR"

echo
echo "正在启动后端..."
(
    cd "$BACKEND_DIR"
    DB_PORT="$DB_PORT" DB_PASSWORD="$DB_PASSWORD" \
        nohup mvn spring-boot:run > "$LOG_DIR/backend.log" 2>&1 &
    echo $! > "$LOG_DIR/backend.pid"
)
echo "  后端 PID: $(cat "$LOG_DIR/backend.pid")   日志: logs/backend.log"

echo "正在启动前端..."
(
    cd "$FRONTEND_DIR"
    if [ ! -d node_modules ]; then
        echo "  首次运行，正在安装依赖..."
        npm install --no-audit --no-fund >> "$LOG_DIR/frontend.log" 2>&1
    fi
    nohup npm run dev > "$LOG_DIR/frontend.log" 2>&1 &
    echo $! > "$LOG_DIR/frontend.pid"
)
echo "  前端 PID: $(cat "$LOG_DIR/frontend.pid")   日志: logs/frontend.log"

echo
echo "已启动。等待约 30 秒后访问："
echo "  前端  http://localhost:$FRONTEND_PORT"
echo "  后端  http://localhost:8080/api/health"
echo "  账号  13800000000 / 123456（学生）   13900000000 / 123456（管理员）"
echo
echo "停止服务： bash scripts/stop-dev.sh"
