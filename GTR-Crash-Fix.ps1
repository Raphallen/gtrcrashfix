# Script created by Afallen, to fix random crashes due to LiveKernelEvent 117 in Kernel

# Allow this script to be executed in the system
Set-ExecutionPolicy Unrestricted -Scope Process

# Run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Pause
    Exit
}

Write-Host "Applying fixes for trgame.exe random crashes..." -ForegroundColor Cyan

# Fix #2 - Increase TDR Timeout
Write-Host "Setting TDR Timeout to 10 seconds..."
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$tdrValue = "TdrDelay"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name $tdrValue -Value 10 -Type DWord

# Fix #3 - Disable Fullscreen Optimizations for trgame.exe
Write-Host "Disabling Fullscreen Optimizations..."
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$gamePath = Join-Path -Path $scriptFolder -ChildPath "trgame.exe"

if (Test-Path $gamePath) {
    $gameRegPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    Set-ItemProperty -Path $gameRegPath -Name $gamePath -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS"
    Write-Host "Fullscreen optimizations disabled for: $gamePath" -ForegroundColor Green
} else {
    Write-Host "trgame.exe not found in the script's folder! Skipping Fullscreen Optimization fix." -ForegroundColor Yellow
}

# Fix #4 - Disable Hardware-Accelerated GPU Scheduling (HAGS)
Write-Host "Disabling Hardware-Accelerated GPU Scheduling..."
$hagsRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$hagsValue = "HwSchMode"
Set-ItemProperty -Path $hagsRegPath -Name $hagsValue -Value 0 -Type DWord

# Need Restart
Write-Host "Fixes applied! A restart is required for changes to take effect." -ForegroundColor Magenta
$restart = Read-Host "Restart now? (Y/N)"
if ($restart -match "[Yy]") {
    Restart-Computer
} else {
    Write-Host "Restart later to apply changes." -ForegroundColor Yellow
}
