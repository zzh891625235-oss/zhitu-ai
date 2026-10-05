# ============================================================
# 智途AI —— 本地开发环境一键启动（Windows / PowerShell）
#
# 用法：
#   powershell -ExecutionPolicy Bypass -File scripts/start-dev.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/start-dev.ps1 -InitDb
#   powershell -ExecutionPolicy Bypass -File scripts/start-dev.ps1 -DryRun
#
# 参数：
#   -InitDb       启动前先执行数据库初始化（等价于 init-db.ps1）
#   -DbPort       数据库端口，默认 3306
#   -DbPassword   数据库密码，默认 123456
#   -DryRun       只打印将要执行的命令，不真正启动
#
# 会在两个新窗口中分别启动后端与前端，便于单独查看日志。
# ============================================================
param(
    [switch]$InitDb,
    [switch]$DryRun,
    [int]$DbPort = 3306,
    [string]$DbPassword = '123456'
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$backendDir = Join-Path $projectRoot 'backend'
$frontendDir = Join-Path $projectRoot 'frontend'

Write-Host '智途AI 开发环境启动检查' -ForegroundColor Cyan
Write-Host ''

# ---------- 1. 依赖检查 ----------
$missing = @()
foreach ($item in @(
    @{ Name = 'java'; Hint = '请安装 JDK 8 或以上' },
    @{ Name = 'mvn';  Hint = '请安装 Maven 3.6 以上' },
    @{ Name = 'node'; Hint = '请安装 Node.js 18 以上' },
    @{ Name = 'npm';  Hint = '请安装 Node.js 18 以上' }
)) {
    if (-not (Get-Command $item.Name -ErrorAction SilentlyContinue)) {
        Write-Host "[缺少] $($item.Name) —— $($item.Hint)" -ForegroundColor Red
        $missing += $item.Name
    } else {
        Write-Host "[就绪] $($item.Name)" -ForegroundColor Green
    }
}
if ($InitDb -and -not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Write-Host '[缺少] mysql —— 请把 MySQL 的 bin 目录加入 PATH' -ForegroundColor Red
    $missing += 'mysql'
}
if ($missing.Count -gt 0) {
    Write-Host ''
    Write-Host '请先补齐上面的依赖再重试。' -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $backendDir) -or -not (Test-Path $frontendDir)) {
    Write-Host "[错误] 未找到 backend / frontend 目录，请确认脚本位于项目的 scripts 目录下。" -ForegroundColor Red
    exit 1
}

# ---------- 2. 组装命令 ----------
$backendCommand = "`$env:DB_PORT='$DbPort'; `$env:DB_PASSWORD='$DbPassword'; " +
                  "cd '$backendDir'; mvn spring-boot:run"

$frontendCommand = "cd '$frontendDir'; " +
                   "if (-not (Test-Path node_modules)) { npm install --no-audit --no-fund }; " +
                   "npm run dev"

# ---------- 3. 演练模式 ----------
if ($DryRun) {
    Write-Host ''
    Write-Host '[演练模式] 以下命令不会真正执行：' -ForegroundColor Yellow
    Write-Host "  后端: $backendCommand"
    Write-Host "  前端: $frontendCommand"
    if ($InitDb) {
        Write-Host "  初始化数据库: scripts/init-db.ps1 -DbPort $DbPort -DbPassword ***"
    }
    exit 0
}

# ---------- 4. 可选：初始化数据库 ----------
if ($InitDb) {
    Write-Host ''
    Write-Host '正在初始化数据库...' -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptDir 'init-db.ps1') `
        -DbPort $DbPort -DbPassword $DbPassword
}

# ---------- 5. 启动 ----------
Write-Host ''
Write-Host '正在启动后端与前端（各自打开一个新窗口）...' -ForegroundColor Cyan

Start-Process powershell -ArgumentList '-NoExit', '-Command', $backendCommand
Start-Sleep -Seconds 3
Start-Process powershell -ArgumentList '-NoExit', '-Command', $frontendCommand

Write-Host ''
Write-Host '已启动。等待约 30 秒后访问：' -ForegroundColor Green
Write-Host '  前端  http://localhost:3000'
Write-Host '  后端  http://localhost:8080/api/health'
Write-Host '  账号  13800000000 / 123456（学生）   13900000000 / 123456（管理员）'
Write-Host ''
Write-Host '提示：没有配置 AI_API_KEY 时系统运行在离线模板模式，界面会明确标注。'
