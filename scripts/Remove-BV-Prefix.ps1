# Remove-BV-Prefix.ps1
# Removes all bv_ and BV_ prefixes from folder names and file content

param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

function Remove-BVPrefix {
    param(
        [string]$Path,
        [bool]$DryRun
    )
    
    Write-Host "Processing: $Path" -ForegroundColor Cyan
    
    # Get all directories with bv_ prefix
    $folders = Get-ChildItem -Path $Path -Directory -Recurse | Where-Object { $_.Name -like "bv_*" } | Sort-Object -Property FullName -Descending
    
    foreach ($folder in $folders) {
        $oldName = $folder.Name
        $newName = $oldName -replace "^bv_", ""
        
        if (-not $DryRun) {
            Rename-Item -Path $folder.FullName -NewName $newName -Force
            Write-Host "  Renamed folder: $oldName -> $newName" -ForegroundColor Green
        } else {
            Write-Host "  [WhatIf] Would rename folder: $oldName -> $newName" -ForegroundColor Yellow
        }
    }
    
    # Now process all text and markdown files to remove BV_ prefix from content
    $files = Get-ChildItem -Path $Path -File -Recurse -Include *.txt,*.md
    
    foreach ($file in $files) {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if ($content) {
            $newContent = $content -replace "BV_", ""
            
            if ($content -ne $newContent) {
                if (-not $DryRun) {
                    Set-Content -Path $file.FullName -Value $newContent -NoNewline
                    Write-Host "  Updated file content: $($file.Name)" -ForegroundColor Green
                } else {
                    Write-Host "  [WhatIf] Would update file content: $($file.Name)" -ForegroundColor Yellow
                }
            }
        }
    }
    
    Write-Host "  Completed: $Path" -ForegroundColor Cyan
    Write-Host ""
}

Remove-BVPrefix -Path $RootPath -DryRun:$WhatIf
