<#
.SYNOPSIS
  Migrate the pack to a new Minecraft version and report what did and did not port.
.EXAMPLE
  .\scripts\bump-version.ps1 -McVersion 26.4
.NOTES
  Makes no destructive decisions. It branches, migrates, updates and reports.
  Removing entries that did not port is a judgment call and stays manual.
#>
param(
    [Parameter(Mandatory)][string]$McVersion
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path "pack.toml")) { throw "Run this from the repo root." }
if (@(git status --porcelain).Count -gt 0) { throw "Working tree is dirty. Commit or stash first." }

$branch = "mc-$McVersion"
if (@(git branch --list $branch).Count -gt 0) { throw "Branch '$branch' already exists." }

Write-Host "`n=== Branching to $branch ===" -ForegroundColor Cyan
git checkout -b $branch

Write-Host "`n=== Migrating to Minecraft $McVersion ===" -ForegroundColor Cyan
packwiz migrate minecraft $McVersion

$pack = Get-Content -Raw "pack.toml"
if ($pack -notmatch "minecraft = ""$([regex]::Escape($McVersion))""") {
    git checkout main
    git branch -D $branch
    throw "pack.toml does not show $McVersion. Migration failed; branch removed."
}

New-Item -ItemType Directory -Path "out" -Force | Out-Null
$log = "out\update-$McVersion.log"

Write-Host "`n=== Updating all entries ===" -ForegroundColor Cyan
packwiz update --all -y 2>&1 | Tee-Object -FilePath $log
packwiz refresh

$changed = @(git diff --name-only -- mods resourcepacks shaderpacks)
$all = @(Get-ChildItem mods,resourcepacks,shaderpacks -Filter *.pw.toml -ErrorAction SilentlyContinue |
         ForEach-Object { $_.Directory.Name + "/" + $_.Name })
$unchanged = @($all | Where-Object { $_ -notin $changed })

$noBuild = @(Select-String -Path $log -Pattern "Failed to check updates for (.+?):" |
             ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object -Unique)

Write-Host "`n======== REPORT: Minecraft $McVersion ========" -ForegroundColor Yellow
Write-Host "`nUPDATED to a $McVersion build ($($changed.Count)):" -ForegroundColor Green
$changed | ForEach-Object { Write-Host "  $_" }

Write-Host "`nNO $McVersion BUILD - decide whether to remove ($($noBuild.Count)):" -ForegroundColor Red
$noBuild | ForEach-Object { Write-Host "  $_" }

Write-Host "`nUnchanged but already compatible ($($unchanged.Count - $noBuild.Count) of $($unchanged.Count) unchanged):" -ForegroundColor Gray
Write-Host "  (unchanged entries not listed above are fine as-is)"

if (Test-Path "PENDING.md") {
    Write-Host "`n======== RE-TEST THESE ========" -ForegroundColor Magenta
    Write-Host "PENDING.md lists entries removed in earlier versions."
    Write-Host "Try re-adding them now:`n"
    Select-String -Path "PENDING.md" -Pattern '^\| ([a-z0-9-]+) \|' |
        ForEach-Object { $_.Matches[0].Groups[1].Value } |
        Sort-Object -Unique |
        Where-Object { $_ -ne "slug" } |
        ForEach-Object { Write-Host "  packwiz modrinth add $_ -y" }
}

Write-Host "`nLog saved to $log" -ForegroundColor Cyan
Write-Host "Nothing was removed. Review the report, then remove what did not port." -ForegroundColor Cyan
