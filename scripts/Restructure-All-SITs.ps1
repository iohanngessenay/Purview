# Restructure-All-SITs.ps1
# Applies restructuring to all SIT folders in HR and LEGAL categories

param(
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

$scriptPath = Join-Path $PSScriptRoot "Restructure-SITs.ps1"
$repoRoot = Split-Path $PSScriptRoot -Parent

# Get all SIT folders in HR
$hrPath = Join-Path $repoRoot "HR"
$hrFolders = Get-ChildItem -Path $hrPath -Directory | Where-Object { $_.Name -like "bv_*" }

Write-Host "Found $($hrFolders.Count) HR SIT folders" -ForegroundColor Cyan
Write-Host ""

foreach ($folder in $hrFolders) {
    & $scriptPath -SitPath $folder.FullName -WhatIf:$WhatIf
}

# Get all SIT folders in LEGAL
$legalPath = Join-Path $repoRoot "LEGAL"
$legalFolders = Get-ChildItem -Path $legalPath -Directory | Where-Object { $_.Name -like "bv_*" }

Write-Host "Found $($legalFolders.Count) LEGAL SIT folders" -ForegroundColor Cyan
Write-Host ""

foreach ($folder in $legalFolders) {
    & $scriptPath -SitPath $folder.FullName -WhatIf:$WhatIf
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Restructuring Complete!" -ForegroundColor Green
Write-Host "Total SIT folders processed: $($hrFolders.Count + $legalFolders.Count)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
