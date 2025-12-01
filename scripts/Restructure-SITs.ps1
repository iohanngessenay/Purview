# Restructure-SITs.ps1
# Reorganizes SIT folders from mixed DE/EN files to language-based folder structure

param(
    [Parameter(Mandatory=$true)]
    [string]$SitPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

function Restructure-SIT {
    param(
        [string]$Path,
        [bool]$DryRun
    )
    
    Write-Host "Processing: $Path" -ForegroundColor Cyan
    
    if (-not (Test-Path $Path)) {
        Write-Error "Path does not exist: $Path"
        return
    }
    
    # Create language directories
    $enDir = Join-Path $Path "en"
    $deDir = Join-Path $Path "de"
    
    if (-not $DryRun) {
        New-Item -Path $enDir -ItemType Directory -Force | Out-Null
        New-Item -Path $deDir -ItemType Directory -Force | Out-Null
        Write-Host "  Created language directories" -ForegroundColor Green
    } else {
        Write-Host "  [WhatIf] Would create: en/ and de/" -ForegroundColor Yellow
    }
    
    # Get all files in the directory
    $files = Get-ChildItem -Path $Path -File
    
    foreach ($file in $files) {
        $fileName = $file.Name
        
        # Skip Description.md - keep it at root
        if ($fileName -eq "Description.md") {
            Write-Host "  Keeping Description.md at root" -ForegroundColor Gray
            continue
        }
        
        # Determine language and new filename
        $newFileName = ""
        $targetDir = ""
        
        if ($fileName -match "_DE\.txt$") {
            # German file
            $targetDir = $deDir
            if ($fileName -match "Context_DE\.txt$") {
                $newFileName = "context.txt"
            } elseif ($fileName -match "Primary_DE\.txt$") {
                $newFileName = "primary.txt"
            }
        } elseif ($fileName -match "_EN\.txt$") {
            # English file
            $targetDir = $enDir
            if ($fileName -match "Context_EN\.txt$") {
                $newFileName = "context.txt"
            } elseif ($fileName -match "Primary_EN\.txt$") {
                $newFileName = "primary.txt"
            }
        } elseif ($fileName -eq "Regex_Patterns.txt") {
            # Copy regex patterns to both language directories
            if (-not $DryRun) {
                Copy-Item -Path $file.FullName -Destination (Join-Path $enDir "regex_patterns.txt")
                Copy-Item -Path $file.FullName -Destination (Join-Path $deDir "regex_patterns.txt")
                Remove-Item -Path $file.FullName
                Write-Host "  Copied Regex_Patterns.txt to both en/ and de/ as regex_patterns.txt" -ForegroundColor Green
            } else {
                Write-Host "  [WhatIf] Would copy Regex_Patterns.txt to en/regex_patterns.txt and de/regex_patterns.txt" -ForegroundColor Yellow
            }
            continue
        }
        
        # Move the file
        if ($newFileName -and $targetDir) {
            $destination = Join-Path $targetDir $newFileName
            if (-not $DryRun) {
                Move-Item -Path $file.FullName -Destination $destination -Force
                Write-Host "  Moved: $fileName -> $($targetDir.Split('\')[-1])/$newFileName" -ForegroundColor Green
            } else {
                Write-Host "  [WhatIf] Would move: $fileName -> $($targetDir.Split('\')[-1])/$newFileName" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "  Completed: $Path" -ForegroundColor Cyan
    Write-Host ""
}

# Process single SIT or all SITs in a category
if (Test-Path $SitPath -PathType Container) {
    Restructure-SIT -Path $SitPath -DryRun:$WhatIf
} else {
    Write-Error "Invalid path: $SitPath"
}
