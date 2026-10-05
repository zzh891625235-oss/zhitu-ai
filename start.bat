@echo off
setlocal
cd /d "%~dp0"
title 智途AI 一键启动

echo.
echo  ============================================================
echo    智途AI · 大学生成长规划平台
echo    一键启动
echo  ============================================================
echo.

REM ============================================================
REM  1. 环境检查
REM ============================================================
set MISSING=0

where java >nul 2>nul
if errorlevel 1 (
    echo   [缺少] java  —— 请安装 JDK 8 或以上，并把 bin 目录加入 PATH
    set MISSING=1
) else (
    echo   [就绪] java
)

where mvn >nul 2>nul
if errorlevel 1 (
    echo   [缺少] mvn   —— 请安装 Maven 3.6 以上，并把 bin 目录加入 PATH
    set MISSING=1
) else (
    echo   [就绪] mvn
)

where node >nul 2>nul
if errorlevel 1 (
    echo   [缺少] node  —— 请安装 Node.js 18 以上
    set MISSING=1
) else (
    echo   [就绪] node
)

where npm >nul 2>nul
if errorlevel 1 (
    echo   [缺少] npm   —— 请安装 Node.js 18 以上
    set MISSING=1
) else (
    echo   [就绪] npm
)

if "%MISSING%"=="1" (
    echo.
    echo   请先补齐上面的依赖，安装完成后重新双击本文件。
    echo.
    pause
    exit /b 1
)

REM ============================================================
REM  2. 可选：先初始化数据库
REM     用法： start.bat init
REM ============================================================
if /i "%~1"=="init" (
    echo.
    echo   正在初始化数据库...
    echo.
    powershell -ExecutionPolicy Bypass -File "%~dp0scripts\init-db.ps1"
    if errorlevel 1 (
        echo.
        echo   [失败] 数据库初始化未成功，请查看上方错误信息。
        pause
        exit /b 1
    )
    echo.
    echo   数据库初始化完成，继续启动服务...
)

REM 数据库连接参数（可在运行本文件前用 set DB_PORT=xxx 覆盖）
if not defined DB_PORT set DB_PORT=3306
if not defined DB_PASSWORD set DB_PASSWORD=123456
REM ============================================================
REM  3. 检查服务端口是否已被占用
REM ============================================================
set PORT_BUSY=0

netstat -ano | findstr ":8080 " | findstr "LISTENING" >nul 2>nul
if not errorlevel 1 (
    echo.
    echo   [警告] 8080 端口已被占用，后端可能已经在运行。
    set PORT_BUSY=1
)

netstat -ano | findstr ":3000 " | findstr "LISTENING" >nul 2>nul
if not errorlevel 1 (
    echo.
    echo   [警告] 3000 端口已被占用，前端可能已经在运行。
    set PORT_BUSY=1
)

if "%PORT_BUSY%"=="1" (
    if /i not "%~1"=="force" (
        echo.
        echo   请先停止正在运行的服务，二选一：
        echo     1^) 关闭标题为「智途AI 后端」「智途AI 前端」的窗口
        echo     2^) 直接双击项目根目录的 stop.bat
        echo.
        echo   确认要再启动一份的话，请执行:  start.bat force
        echo.
        pause
        exit /b 1
    )
    echo.
    echo   [force] 已忽略端口占用，继续启动。
)

REM ============================================================
REM ============================================================
REM  3.5 检查模式：只做环境与端口检查，不启动任何服务
REM      用法： start.bat check
REM ============================================================
if /i "%~1"=="check" (
    echo.
    echo   [检查模式] 环境与端口检查完成，未启动任何服务。
    echo.
    pause
    exit /b 0
)
REM  4. 前端依赖（首次运行需要安装）
REM ============================================================
if not exist "frontend\node_modules" (
    echo.
    echo   首次运行，正在安装前端依赖，可能需要几分钟，请耐心等待...
    pushd frontend
    call npm install --no-audit --no-fund
    popd
    if errorlevel 1 (
        echo.
        echo   [失败] 前端依赖安装失败，请检查网络后重试。
        pause
        exit /b 1
    )
    echo   前端依赖安装完成。
)

REM ============================================================
REM  5. 启动后端与前端（各开一个新窗口）
REM ============================================================
echo.
echo   正在启动后端（新窗口）...
REM 注意：不要把 set 写进下面的 cmd /k 里。
REM cmd 的 "set X=v && cmd" 会把 && 前的空格一起算进变量值，
REM 导致密码实际变成 "123456 "（带尾随空格）而认证失败。
REM start 创建的新窗口会继承本脚本的环境变量，因此这里直接启动即可。
start "智途AI 后端" /D "%~dp0backend" cmd /k "mvn spring-boot:run"

timeout /t 3 /nobreak >nul

echo   正在启动前端（新窗口）...
start "智途AI 前端" /D "%~dp0frontend" cmd /k "npm run dev"

REM ============================================================
REM  6. 提示信息
REM ============================================================
echo.
echo  ============================================================
echo    启动完成
echo  ============================================================
echo.
echo    前端地址 : http://localhost:3000
echo    后端地址 : http://localhost:8080/api/health
echo.
echo    演示账号 : 13800000000 / 123456   （学生，已预置完整数据）
echo    管理账号 : 13900000000 / 123456   （管理员，可进管理后台）
echo.
echo    说明:
echo      * 未配置 AI Key 时系统运行在「离线模板模式」，界面会明确标注
echo      * 可登录后在「API 设置」页面填入自己的 Key，即可启用真实大模型
echo      * 首次启动后端需要下载依赖，可能要等 1-2 分钟
echo.
echo    约 35 秒后会自动打开浏览器，若显示连接失败请稍等后手动刷新。
echo.

timeout /t 35 /nobreak
start "" http://localhost:3000

echo.
echo  关闭本窗口不会停止服务。
echo  需要停止时，分别到「智途AI 后端」「智途AI 前端」窗口按 Ctrl+C。
echo.
pause
exit /b 0

:finish
echo.
echo   已取消。
echo.
pause
exit /b 0
