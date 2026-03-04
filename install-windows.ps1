# 실행 정책 우회 (스크립트 서명 없이 실행)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# WezTerm 설정 파일 복사
Copy-Item -Path "wezterm-windows.lua" -Destination "$HOME\.wezterm.lua" -Force
Write-Host "WezTerm config installed to $HOME\.wezterm.lua"

