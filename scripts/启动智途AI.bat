@echo off
chcp 936 >nul
setlocal
title 智途AI - 一体化演示版
cd /d "%~dp0"

rem 本文件必须保存为 ANSI/GBK 编码（不能存成 UTF-8），否则 cmd 会按 936 代码页读成乱码。
rem 若中文仍显示乱码，请改用同目录的纯英文脚本 start-en.bat。

echo ========================================
echo   智途AI - 大学生成长规划平台
echo   一体化演示版（免装 MySQL / Node / Maven）
echo ========================================
echo.

if not exist "zhitu-ai.jar" goto nojar

where java >nul 2>nul
if errorlevel 1 goto nojava

rem 自动挑一个空闲端口：8080 被占用时依次尝试 8090~8093
set "PORT="
for %%P in (8080 8090 8091 8092 8093) do (
    if not defined PORT (
        netstat -ano | findstr /C:":%%P " | findstr /C:"LISTENING" >nul
        if errorlevel 1 set "PORT=%%P"
    )
)
if not defined PORT set "PORT=8090"

echo [OK] 已检测到 Java，正在启动服务（首次启动需初始化数据库，约 5-10 秒）
echo      访问地址： http://localhost:%PORT%
if not "%PORT%"=="8080" echo      提示：8080 已被占用，已自动改用 %PORT%
echo.
echo 演示账号：13800000000 / 123456
echo 关闭本窗口即可停止服务
echo.

start "" cmd /c "timeout /t 8 /nobreak >nul & start http://localhost:%PORT%"

java -jar zhitu-ai.jar --spring.profiles.active=demo --server.port=%PORT%

echo.
echo 服务已停止。若启动失败，请把本窗口的报错信息发给开发者。
pause
exit /b 0

:nojar
echo [缺少文件] 当前目录没有找到 zhitu-ai.jar
echo.
echo 请确认：
echo   1. 已经把压缩包完整解压（不要只复制这一个 bat 文件）
echo   2. 本 bat 与 zhitu-ai.jar 在同一个文件夹里
echo   3. 不要在压缩软件窗口里直接双击，要先解压出来
echo.
pause
exit /b 1

:nojava
echo [缺少 Java] 这台电脑还没有安装 Java，无法启动。
echo.
echo 解决办法（Windows 10 / 11）：
echo   1. 命令行执行： winget install EclipseAdoptium.Temurin.17.JDK
echo      或到 https://adoptium.net 下载 JDK 17 安装
echo   2. 安装完成后，重新打开本窗口再双击「启动智途AI.bat」
echo.
echo 已装过 Java 却仍看到本提示？请执行 java -version 确认，
echo 或检查环境变量 PATH 是否包含 Java 的 bin 目录。
echo.
pause
exit /b 1
