# WezTerm 설정 파일 복사
Copy-Item -Path "wezterm-windows.lua" -Destination "$HOME\.wezterm.lua" -Force
Write-Host "WezTerm config installed to $HOME\.wezterm.lua"

# gsudo 설치 확인 (관리자 탭 Ctrl+Shift+T 에 필요)
if (-not (Get-Command gsudo -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "gsudo not found. Installing via winget..." -ForegroundColor Yellow
    winget install gerardog.gsudo
    if ($LASTEXITCODE -eq 0) {
        Write-Host "gsudo installed successfully." -ForegroundColor Green
    } else {
        Write-Host "gsudo installation failed. Install manually: winget install gerardog.gsudo" -ForegroundColor Red
    }
} else {
    Write-Host "gsudo is already installed." -ForegroundColor Green
}
