@echo off
setlocal
cd /d "%~dp0"
title 智途AI 数据库初始化

echo.
echo  ============================================================
echo    智途AI · 数据库初始化
echo  ============================================================
echo.
echo    将依次执行 database 目录下的三个脚本:
echo      1. schema.sql   建库建表
echo      2. majors.sql   专业字典（175 个专业）
echo      3. data.sql     课程 / 竞赛 / 演示账号
echo.
echo    三个脚本均可重复执行，不会产生重复数据。
echo.

where mysql >nul 2>nul
if errorlevel 1 (
    echo   [缺少] mysql 命令
    echo.
    echo   请把 MySQL 的 bin 目录加入 PATH 环境变量，例如:
    echo     C:\Program Files\MySQL\MySQL Server 8.0\bin
    echo.
    pause
    exit /b 1
)

echo   提示: 如果数据库密码不是默认的 123456,
echo         可用命令行执行并指定密码:
echo         scripts\init-db.ps1 -DbPassword 你的密码
echo.
echo   如果提示 Unknown column 之类的结构错误（旧数据库结构过时），
echo   重新运行本文件即可 —— 脚本会自动补齐缺失的列与唯一索引。
echo   若仍然失败，可改为删库重建（会清空该库数据）：
echo         init-db.bat -Reset
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0scripts\init-db.ps1" %*
if errorlevel 1 (
    echo.
    echo   [失败] 初始化未成功，请查看上方错误信息。
    pause
    exit /b 1
)

echo.
echo  完成后即可双击 start.bat 启动项目。
echo.
pause
exit /b 0
