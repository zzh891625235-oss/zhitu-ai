#!/usr/bin/env bash
# ============================================================
# 智途AI —— 停止由 start-dev.sh 启动的后端与前端
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$(dirname "$SCRIPT_DIR")/logs"

stopped=0
for name in backend frontend; do
    pid_file="$LOG_DIR/$name.pid"
    if [ -f "$pid_file" ]; then
        pid="$(cat "$pid_file")"
        if kill -0 "$pid" >/dev/null 2>&1; then
            # 结束整个进程组：mvn / npm 会派生子进程，只杀父进程会留下孤儿
            kill -TERM -"$pid" >/dev/null 2>&1 || kill -TERM "$pid" >/dev/null 2>&1 || true
            sleep 1
            kill -KILL -"$pid" >/dev/null 2>&1 || true
            echo "已停止 $name (PID $pid)"
            stopped=1
        else
            echo "$name 未在运行 (PID $pid)"
        fi
        rm -f "$pid_file"
    else
        echo "未找到 $name 的 PID 文件，可能未通过 start-dev.sh 启动"
    fi
done

if [ "$stopped" = "0" ]; then
    echo "没有需要停止的进程。"
fi
