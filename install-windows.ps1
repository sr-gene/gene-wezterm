# Bypass execution policy for this process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Copy WezTerm config
Copy-Item -Path "wezterm-windows.lua" -Destination "$HOME\.wezterm.lua" -Force
Write-Host "WezTerm config installed to $HOME\.wezterm.lua"

# Add OSC 7 (current directory reporting) to PowerShell profile
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$osc7Block = @'

# WezTerm OSC 7 - report current directory to tab title
function Set-WezTermOSC7 {
    $p = $executionContext.SessionState.Path.CurrentLocation.Path
    $e = [char]27
    $uri = "file:///$($env:COMPUTERNAME)/" + ($p -replace '\\','/')
    Write-Host -NoNewline "$e]7;$uri$e\"
}

if (-not $function:prompt_original) {
    $function:prompt_original = $function:prompt
    function prompt {
        Set-WezTermOSC7
        prompt_original
    }
}
'@

# Install glow (markdown viewer) via winget if not already installed
if (-not (Get-Command glow -ErrorAction SilentlyContinue)) {
    Write-Host "Installing glow..." -ForegroundColor Cyan
    winget install charmbracelet.glow --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "glow already installed." -ForegroundColor Green
}

$marker = '# WezTerm OSC 7'
if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -Pattern $marker -Quiet)) {
    Write-Host "OSC 7 already in PowerShell profile." -ForegroundColor Green
} else {
    Add-Content -Path $PROFILE -Value $osc7Block
    Write-Host "OSC 7 added to PowerShell profile: $PROFILE" -ForegroundColor Green
}
