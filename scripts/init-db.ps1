# ============================================================
# 智途AI —— 数据库一键初始化脚本（Windows / PowerShell）
#
# 用法：
#   powershell -ExecutionPolicy Bypass -File scripts/init-db.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/init-db.ps1 -DbPassword 你的密码
#   powershell -ExecutionPolicy Bypass -File scripts/init-db.ps1 -Reset   # 删库重建（会清空数据）
#
# 依次执行 database 目录下的三个脚本：
#   schema.sql  建库建表
#   majors.sql  专业字典（175 个专业）
#   data.sql    课程 / 竞赛 / 知识点 / 演示账号
# 三个脚本均可重复执行，不会产生重复数据。
#
# 注意：本文件必须保存为「UTF-8 with BOM」，
#       否则 Windows PowerShell 5.1 会按 GBK 解析中文导致语法错误。
# ============================================================
param(
    [string]$DbHost = 'localhost',
    [int]$DbPort = 3306,
    [string]$DbUser = 'root',
    [string]$DbPassword = '123456',
    [switch]$Reset
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$databaseDir = Join-Path (Split-Path -Parent $scriptDir) 'database'

if (-not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Write-Host '[错误] 未找到 mysql 命令，请先把 MySQL 的 bin 目录加入 PATH。' -ForegroundColor Red
    Write-Host '       例如：C:\Program Files\MySQL\MySQL Server 8.0\bin'
    exit 1
}

if (-not (Test-Path $databaseDir)) {
    Write-Host "[错误] 未找到数据库脚本目录：$databaseDir" -ForegroundColor Red
    exit 1
}

Write-Host '正在初始化智途AI数据库...' -ForegroundColor Cyan
Write-Host "  主机: $DbHost`:$DbPort    用户: $DbUser"
Write-Host ''

# 通过 MYSQL_PWD 环境变量传密码：命令行传 --password 会让 mysql 向 stderr
# 打印安全告警，而 $ErrorActionPreference='Stop' 会把它当成致命错误中断脚本。
$env:MYSQL_PWD = $DbPassword
# -Reset：先删除整个数据库再重建。
# 用于表结构与当前脚本差异过大、自动补齐也救不回来的情况。
# 注意：会清空该库的所有数据。
if ($Reset) {
    Write-Host '==> 删除已有数据库（-Reset）' -ForegroundColor Yellow
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & mysql --host=$DbHost --port=$DbPort --user=$DbUser -e 'DROP DATABASE IF EXISTS zhitu_ai' 2>&1 |
        Where-Object { $_ -notmatch 'Using a password on the command line' }
    $ErrorActionPreference = $prevPref
    Write-Host '    已删除，接下来重新创建'
    Write-Host ''
}

$failed = $false
# mysql 客户端的 source 命令在 Windows 下无法打开含中文或空格的路径，
# 因此先切到 database 目录，只使用纯 ASCII 的相对文件名。
Push-Location $databaseDir
try {
    foreach ($file in @('schema.sql', 'majors.sql', 'data.sql')) {
        if (-not (Test-Path $file)) {
            Write-Host "[跳过] 文件不存在：$file" -ForegroundColor Yellow
            continue
        }

        Write-Host "==> 执行 $file" -ForegroundColor Green

        # 外部命令的 stderr 在 Stop 模式下会被当作异常抛出，这里临时放开
        $previous = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & mysql --host=$DbHost --port=$DbPort --user=$DbUser `
            --default-character-set=utf8mb4 -e "source $file" 2>&1 |
            Where-Object { $_ -notmatch 'Using a password on the command line' }
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $previous

        if ($exitCode -ne 0) {
            Write-Host "[失败] $file 执行出错，请检查上方 MySQL 报错信息。" -ForegroundColor Red
            $failed = $true
            break
        }
    }
} finally {
    Pop-Location
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

if ($failed) {
    exit 1
}

Write-Host ''
Write-Host '数据库初始化完成！' -ForegroundColor Cyan
Write-Host '演示账号：13800000000    密码：123456' -ForegroundColor Yellow
Write-Host '接下来可以启动后端：cd backend; mvn spring-boot:run'
