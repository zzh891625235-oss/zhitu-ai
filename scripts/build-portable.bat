@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0.."

echo ============================================
echo   智途AI 一体化打包
echo ============================================
echo.

echo [1/4] 构建前端产物...
cd frontend
call npm run build
if errorlevel 1 (
  echo [失败] 前端构建出错
  pause
  exit /b 1
)
cd ..

echo [2/4] 同步静态资源到后端...
if exist "backend\src\main\resources\static\assets" rmdir /s /q "backend\src\main\resources\static\assets"
xcopy /e /i /y "frontend\dist\assets" "backend\src\main\resources\static\assets" >nul
copy /y "frontend\dist\index.html" "backend\src\main\resources\static\index.html" >nul

echo [3/4] 打包后端（含前端产物）...
cd backend
call mvn -DskipTests package
if errorlevel 1 (
  echo [失败] 后端打包出错
  pause
  exit /b 1
)
cd ..

echo [4/4] 更新便携版目录...
if not exist "智途AI-便携版" mkdir "智途AI-便携版"
copy /y "backend\target\zhitu-ai-1.0.0.jar" "智途AI-便携版\zhitu-ai.jar" >nul

echo.
echo ============================================
echo   打包完成！
echo   产物：智途AI-便携版\zhitu-ai.jar
echo   运行：双击 智途AI-便携版\启动智途AI.bat
echo ============================================
pause
