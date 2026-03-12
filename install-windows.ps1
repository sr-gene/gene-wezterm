# Install PowerShell 7 (pwsh) if not already installed
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PowerShell 7..." -ForegroundColor Cyan
    winget install Microsoft.PowerShell --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "PowerShell 7 already installed." -ForegroundColor Green
}

# Copy WezTerm config
Copy-Item -Path "wezterm-windows.lua" -Destination "$HOME\.wezterm.lua" -Force
Write-Host "WezTerm config installed to $HOME\.wezterm.lua"

# Copy clipboard helper script (required for smart paste image support)
Copy-Item -Path "wezterm_clipboard.ps1" -Destination "$HOME\.wezterm_clipboard.ps1" -Force
Write-Host "Clipboard helper installed to $HOME\.wezterm_clipboard.ps1"

# Add OSC 7 (current directory reporting) to PowerShell profile
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$osc7Block = @'

# PSReadLine key handlers
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key RightArrow -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete

# WezTerm OSC 7 - report current directory to tab title
function Send-WezTermOSC7 {
    $path = (Get-Location).Path
    if ($path -match '^[A-Za-z]:') {
        $uriPath = '/' + $path.Replace('\', '/')
        [Console]::Write("`e]7;file://$($env:COMPUTERNAME)$uriPath`e\")
    }
}

# Emit OSC 7 on every cd (covers manual cd and z jumps that call Set-Location)
function Set-Location {
    Microsoft.PowerShell.Management\Set-Location @args
    Send-WezTermOSC7
}

# Wrap whatever prompt is active (preserves Oh My Posh / starship styling)
$private:_basePrompt = ${function:prompt}
function prompt {
    $result = if ($null -ne $private:_basePrompt) { & $private:_basePrompt } else { "PS $PWD> " }
    Send-WezTermOSC7
    $result
}

# Emit OSC 7 immediately at profile load so WezTerm knows starting CWD
Send-WezTermOSC7
'@

# Install glow (markdown viewer) via winget if not already installed
if (-not (Get-Command glow -ErrorAction SilentlyContinue)) {
    Write-Host "Installing glow..." -ForegroundColor Cyan
    winget install charmbracelet.glow --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "glow already installed." -ForegroundColor Green
}

$marker = 'Send-WezTermOSC7'
if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -Pattern $marker -Quiet)) {
    Write-Host "OSC 7 already in PowerShell profile." -ForegroundColor Green
} else {
    Add-Content -Path $PROFILE -Value $osc7Block
    Write-Host "OSC 7 added to PowerShell profile: $PROFILE" -ForegroundColor Green
}
