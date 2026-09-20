<#
.SYNOPSIS
  Apply portable client defaults (resource pack order, shaderpack) to a Prism instance.
.DESCRIPTION
  Only settings that should travel between machines. Video settings, memory and
  Sodium tuning are per machine and are deliberately not touched.
.EXAMPLE
  .\scripts\apply-client-defaults.ps1 -Instance "SchmoeClient-1.2.0-mc26.3"
#>
param(
    [Parameter(Mandatory)][string]$Instance
)

$ErrorActionPreference = "Stop"
$root = Join-Path $env:APPDATA "PrismLauncher\instances"
$dir  = Join-Path $root $Instance

if (-not (Test-Path (Join-Path $dir "instance.cfg"))) {
    Write-Host "Available instances:" -ForegroundColor Yellow
    Get-ChildItem $root -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
    throw "'$Instance' is not a Prism instance."
}

$game = Join-Path $dir "minecraft"
if (-not (Test-Path (Join-Path $game "mods"))) {
    throw "Launch '$Instance' once before applying defaults."
}

$optionsPath = Join-Path $game "options.txt"
if (-not (Test-Path $optionsPath)) { throw "No options.txt in $game. Launch it once." }

$want = (Get-Content -Raw "client-defaults\resourcePacks.txt").Trim()
$lines = @(Get-Content $optionsPath)

if ($lines -match "^resourcePacks:") {
    $lines = $lines | ForEach-Object {
        if ($_ -match "^resourcePacks:") { $want } else { $_ }
    }
} else {
    $lines += $want
}
[System.IO.File]::WriteAllText($optionsPath, (($lines -join "`n") + "`n"))
Write-Host "Applied resource pack order" -ForegroundColor Green

if (Test-Path "client-defaults\iris.properties") {
    $cfg = Join-Path $game "config"
    if (-not (Test-Path $cfg)) { New-Item -ItemType Directory -Path $cfg | Out-Null }
    Copy-Item "client-defaults\iris.properties" (Join-Path $cfg "iris.properties") -Force
    Write-Host "Applied shaderpack selection" -ForegroundColor Green
}

Write-Host "`nNot touched (set these per machine):" -ForegroundColor Cyan
Write-Host "  render distance, graphics settings, memory allocation, Sodium tuning"
