# Add-Languages.ps1
# Adds new language folders to all SIT directories by copying from English

param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Languages,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

function Add-LanguageFolders {
    param(
        [string]$Path,
        [string[]]$LangCodes,
        [bool]$DryRun
    )
    
    Write-Host "Processing: $Path" -ForegroundColor Cyan
    
    # Get all SIT folders
    $sitFolders = Get-ChildItem -Path $Path -Directory -Recurse -Depth 1 | Where-Object { 
        (Test-Path (Join-Path $_.FullName "en")) -and 
        (Test-Path (Join-Path $_.FullName "de"))
    }
    
    foreach ($sitFolder in $sitFolders) {
        $enFolder = Join-Path $sitFolder.FullName "en"
        
        foreach ($lang in $LangCodes) {
            $newLangFolder = Join-Path $sitFolder.FullName $lang
            
            if (Test-Path $newLangFolder) {
                Write-Host "  Skipping $($sitFolder.Name)/$lang - already exists" -ForegroundColor Gray
                continue
            }
            
            if (-not $DryRun) {
                # Copy English folder as template
                Copy-Item -Path $enFolder -Destination $newLangFolder -Recurse -Force
                Write-Host "  Created: $($sitFolder.Name)/$lang (copied from en/)" -ForegroundColor Green
            } else {
                Write-Host "  [WhatIf] Would create: $($sitFolder.Name)/$lang" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host ""
    Write-Host "Language addition complete!" -ForegroundColor Cyan
}

Add-LanguageFolders -Path $RootPath -LangCodes $Languages -DryRun:$WhatIf
