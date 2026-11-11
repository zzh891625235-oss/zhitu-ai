@echo off
setlocal
title Publish ZhituAI Repository
cd /d "%~dp0.."

echo ============================================================
echo   ZhituAI - publish repository to GitHub / Gitee
echo   ASCII-only launcher: safe on any Windows code page
echo ============================================================
echo.
echo Before you start:
echo   1. Create an EMPTY PUBLIC repository on GitHub or Gitee.
echo      Do NOT initialize it with README / license / .gitignore.
echo   2. Copy its HTTPS URL, for example
echo      https://gitee.com/yourname/zhitu-ai.git
echo   3. This folder MUST contain the .git directory.
echo      Use "ZhiTuAI-GitRepo.zip", not the submission zip.
echo.

where git >nul 2>nul
if errorlevel 1 goto nogit
git rev-parse --is-inside-work-tree >nul 2>nul
if errorlevel 1 goto norepo

set "REPO_URL="
set /p "REPO_URL=Paste the EMPTY repository HTTPS URL here: "
if "%REPO_URL%"=="" goto nourl

echo.
echo [1/3] Setting remote origin ...
git remote remove origin >nul 2>nul
git remote add origin "%REPO_URL%"
if errorlevel 1 goto fail

echo [2/3] Renaming local branch to main ...
git branch -M main

echo [3/3] Pushing all commits (about 70 MB, please wait) ...
git push -u origin main
if errorlevel 1 goto pushfail

echo.
echo [SUCCESS] Repository published.
echo Verify in a browser (incognito / signed out):
echo   - repository is Public
echo   - README renders correctly
echo   - full commit history is visible
echo   - no API keys, no .env, no data/ folder
echo.
pause
exit /b 0

:nogit
echo [ERROR] git was not found. Install Git for Windows: https://git-scm.com
pause
exit /b 1

:norepo
echo [ERROR] .git directory not found in this folder.
echo Please fully extract "ZhiTuAI-GitRepo.zip" and run this script
echo from the scripts folder inside it.
echo The submission zip does NOT contain .git.
pause
exit /b 1

:nourl
echo [ERROR] No URL entered. Nothing was changed.
pause
exit /b 1

:pushfail
echo.
echo [PUSH FAILED] Common causes:
echo   - Login required: GitHub needs a Personal Access Token as password;
echo     Gitee needs account + private token.
echo   - Network blocked: Gitee is usually faster from China.
echo   - Remote is not empty: recreate it WITHOUT a README.
echo   - Wrong URL: run this script again with the correct URL.
echo.
pause
exit /b 1

:fail
echo [ERROR] Could not set remote origin. Check the URL.
pause
exit /b 1
