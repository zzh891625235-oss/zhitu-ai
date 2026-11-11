@echo off
setlocal
title ZhituAI Portable Demo (ASCII fallback)
cd /d "%~dp0"

echo ========================================
echo   ZhituAI - Portable Demo
echo   ASCII fallback launcher: works on any Windows code page.
echo ========================================
echo.

if not exist "zhitu-ai.jar" goto nojar
where java >nul 2>nul
if errorlevel 1 goto nojava

set "PORT="
for %%P in (8080 8090 8091 8092 8093) do (
    if not defined PORT (
        netstat -ano | findstr /C:":%%P " | findstr /C:"LISTENING" >nul
        if errorlevel 1 set "PORT=%%P"
    )
)
if not defined PORT set "PORT=8090"

echo [OK] Java found. Starting service (first run takes 5-10 s) ...
echo      URL: http://localhost:%PORT%
if not "%PORT%"=="8080" echo      Port 8080 is busy, using %PORT% instead.
echo.
echo Demo account: 13800000000 / 123456
echo Close this window to stop the service.
echo.

start "" cmd /c "timeout /t 8 /nobreak >nul & start http://localhost:%PORT%"
java -jar zhitu-ai.jar --spring.profiles.active=demo --server.port=%PORT%

echo.
echo Service stopped.
pause
exit /b 0

:nojar
echo [Missing file] zhitu-ai.jar was not found in this folder.
echo Please extract the WHOLE zip package first, and keep this .bat
echo in the same folder as zhitu-ai.jar.
pause
exit /b 1

:nojava
echo [Java not found] Java 8+ is required (JDK 17 recommended).
echo Install on Windows: winget install EclipseAdoptium.Temurin.17.JDK
echo Or download from https://adoptium.net
echo Then reopen this window and double-click the launcher again.
pause
exit /b 1
