$ErrorActionPreference = 'Stop'
$taskPort = 4173
$taskRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Get-NetTCPConnection -LocalPort $taskPort -State Listen -ErrorAction SilentlyContinue) {
  Start-Process "http://localhost:$taskPort"
  exit 0
}

$python = Get-Command py -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python -ErrorAction SilentlyContinue }
if (-not $python) { throw 'ไม่พบ Python: เปิดโฟลเดอร์นี้ด้วย VS Code Live Server แทน' }

Start-Process -FilePath $python.Source -ArgumentList '-m', 'http.server', "$taskPort", '--directory', $taskRoot -WindowStyle Hidden
Start-Sleep -Milliseconds 700
Start-Process "http://localhost:$taskPort"
