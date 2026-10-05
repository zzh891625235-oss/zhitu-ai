# ============================================================
# 智途AI —— 停止开发环境（Windows / PowerShell）
#
# 用法：
#   powershell -ExecutionPolicy Bypass -File scripts/stop-dev.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/stop-dev.ps1 -Ports 8080,3000
#
# Windows 下 start-dev.ps1 是把服务跑在独立窗口里的，
# 这里改为按端口定位监听进程并结束，比维护 PID 文件更可靠。
# ============================================================
param(
    [int[]]$Ports = @(8080, 3000)
)

$ErrorActionPreference = 'Continue'

$stopped = 0
foreach ($port in $Ports) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($conn) {
        $processId = $conn.OwningProcess | Select-Object -First 1
        $proc = Get-Process -Id $processId -ErrorAction SilentlyContinue
        $name = if ($proc) { $proc.ProcessName } else { 'unknown' }
        Write-Host "端口 $port 被 $name (PID $processId) 占用，正在结束..." -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        $stopped++
    } else {
        Write-Host "端口 $port 未被占用" -ForegroundColor DarkGray
    }
}

if ($stopped -eq 0) {
    Write-Host '没有需要停止的进程。' -ForegroundColor Green
} else {
    Write-Host "已结束 $stopped 个进程。" -ForegroundColor Green
}
