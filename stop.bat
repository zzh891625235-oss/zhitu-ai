@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title 智途AI 停止服务

echo.
echo  ============================================================
echo    智途AI · 停止服务
echo  ============================================================
echo.

set FOUND=0
set KILLED=0

for %%P in (8080 3000) do (
    for /f "tokens=5" %%A in ('netstat -ano ^| findstr ":%%P " ^| findstr "LISTENING"') do (
        set FOUND=1
        echo   正在结束端口 %%P 上的进程 PID %%A ...
        taskkill /PID %%A /T /F >nul 2>nul
        if not errorlevel 1 set KILLED=1
    )
)

echo.
if "%FOUND%"=="0" (
    echo   没有发现正在运行的服务，无需停止。
) else (
    echo   已停止。端口 8080 / 3000 现在应该已经释放。
    echo   如果窗口还留着，直接关掉即可。
)

echo.
echo   完成后可双击 start.bat 重新启动。
echo.
pause
exit /b 0