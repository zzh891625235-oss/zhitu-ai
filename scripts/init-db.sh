#!/usr/bin/env bash
# ============================================================
# 智途AI —— 数据库一键初始化脚本（macOS / Linux）
#
# 用法：
#   bash scripts/init-db.sh
#   DB_PASSWORD=你的密码 bash scripts/init-db.sh
#
# 依次执行 database 目录下的三个脚本：
#   schema.sql  建库建表
#   majors.sql  专业字典（175 个专业）
#   data.sql    课程 / 竞赛 / 知识点 / 演示账号
# 三个脚本均可重复执行，不会产生重复数据。
# ============================================================
set -euo pipefail

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USERNAME:-root}"
DB_PASSWORD="${DB_PASSWORD:-123456}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATABASE_DIR="$(dirname "$SCRIPT_DIR")/database"

if ! command -v mysql >/dev/null 2>&1; then
    echo "[错误] 未找到 mysql 命令，请先把 MySQL 的 bin 目录加入 PATH。" >&2
    exit 1
fi

if [ ! -d "$DATABASE_DIR" ]; then
    echo "[错误] 未找到数据库脚本目录：$DATABASE_DIR" >&2
    exit 1
fi

echo "正在初始化智途AI数据库..."
echo "  主机: ${DB_HOST}:${DB_PORT}    用户: ${DB_USER}"
echo

for file in schema.sql majors.sql data.sql; do
    full_path="$DATABASE_DIR/$file"
    if [ ! -f "$full_path" ]; then
        echo "[跳过] 文件不存在：$file"
        continue
    fi

    echo "==> 执行 $file"
    mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" \
        --password="$DB_PASSWORD" --default-character-set=utf8mb4 \
        -e "source $full_path" 2>&1 | grep -v 'Using a password on the command line' || true

    if [ "${PIPESTATUS[0]}" != "0" ]; then
        echo "[失败] $file 执行出错，请检查上方 MySQL 报错信息。" >&2
        exit 1
    fi
done

echo
echo "数据库初始化完成！"
echo "演示账号：13800000000    密码：123456"
echo "接下来可以启动后端：cd backend && mvn spring-boot:run"
