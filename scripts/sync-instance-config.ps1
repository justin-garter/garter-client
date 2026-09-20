<#
.SYNOPSIS
  Copy Minecraft options and mod configs between two Prism Launcher instances.
.EXAMPLE
  .\scripts\sync-instance-config.ps1 -FromInstance "GarterClient-1.0.0-mc26.2" -ToInstance "Garter Client 26.3"
#>
param(
    [Parameter(Mandatory)][string]$FromInstance,
    [Parameter(Mandatory)][string]$ToInstance
)

$ErrorActionPreference = "Stop"
$root = Join-Path $env:APPDATA "PrismLauncher\instances"

function Resolve-GameDir([string]$name) {
    $dir = Join-Path $root $name
    if (-not (Test-Path (Join-Path $dir "instance.cfg"))) {
        Write-Host "Available instances:" -ForegroundColor Yellow
        Get-ChildItem $root -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
        throw "'$name' is not a Prism instance (no instance.cfg)."
    }
    $game = Join-Path $dir "minecraft"
    if (-not (Test-Path (Join-Path $game "mods"))) {
        throw "'$name' has no mods folder. Launch it once before syncing."
    }
    return $game
}

$src = Resolve-GameDir $FromInstance
$dst = Resolve-GameDir $ToInstance

$dstConfig = Join-Path $dst "config"
if (-not (Test-Path $dstConfig)) { New-Item -ItemType Directory -Path $dstConfig | Out-Null }

Copy-Item (Join-Path $src "options.txt") -Destination (Join-Path $dst "options.txt") -Force
Copy-Item (Join-Path $src "config\*") -Destination ($dstConfig + "\") -Recurse -Force

Write-Host "Synced options.txt and config\" -ForegroundColor Green
Write-Host "  from: $src"
Write-Host "  to:   $dst"
