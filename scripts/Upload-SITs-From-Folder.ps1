<#
.SYNOPSIS
    Uploads SIT XML files from a folder to Microsoft Purview tenant.

.DESCRIPTION
    Uploads custom Sensitive Information Type (SIT) XML files to a Microsoft 365 tenant
    using Security & Compliance PowerShell. Simply place the XML files you want to upload
    in the input folder and run the script.
    
    Prerequisites:
    - ExchangeOnlineManagement PowerShell module
    - Compliance Administrator or equivalent role
    - SIT XML files in the input folder

.PARAMETER InputPath
    Path containing SIT XML files to upload. Default: User's Downloads\SIT_Upload folder

.PARAMETER DryRun
    Validate XML files without uploading to tenant

.EXAMPLE
    .\Upload-Individual-SITs.ps1
    Upload all XML files from Downloads\SIT_Upload folder

.EXAMPLE
    .\Upload-Individual-SITs.ps1 -DryRun
    Validate all XML files without uploading

.EXAMPLE
    .\Upload-Individual-SITs.ps1 -InputPath "C:\MyCustomPath\XMLs"
    Upload from a custom folder
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$InputPath = (Join-Path $env:USERPROFILE "Downloads\SIT_Upload"),
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Microsoft Purview SIT Upload Tool" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check if input folder exists
Write-Host "[1/5] Checking upload folder..." -ForegroundColor Cyan

if (-not (Test-Path $InputPath)) {
    Write-Host "    Creating upload folder: $InputPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $InputPath -Force | Out-Null
    Write-Host "    [INFO] Upload folder created!" -ForegroundColor Green
    Write-Host "    [ACTION REQUIRED] Please place your SIT XML files in:" -ForegroundColor Yellow
    Write-Host "    $InputPath" -ForegroundColor White
    Write-Host "    Then run this script again.`n" -ForegroundColor Yellow
    
    # Open the folder for user convenience
    Start-Process explorer.exe -ArgumentList $InputPath
    exit 0
}

Write-Host "    [OK] Upload folder exists: $InputPath" -ForegroundColor Green

# Step 2: Discover XML files
Write-Host "`n[2/5] Discovering SIT XML files..." -ForegroundColor Cyan

$allXmlFiles = @(Get-ChildItem -Path $InputPath -Filter "*.xml" -ErrorAction SilentlyContinue)

if ($allXmlFiles.Count -eq 0) {
    Write-Host "    [WARNING] No XML files found in upload folder" -ForegroundColor Yellow
    Write-Host "    Please place your SIT XML files in:" -ForegroundColor Yellow
    Write-Host "    $InputPath" -ForegroundColor White
    Write-Host "    Then run this script again.`n" -ForegroundColor Yellow
    
    # Open the folder for user convenience
    Start-Process explorer.exe -ArgumentList $InputPath
    exit 0
}

Write-Host "    Found $($allXmlFiles.Count) XML file(s)" -ForegroundColor Green
foreach ($file in $allXmlFiles) {
    Write-Host "      - $($file.Name)" -ForegroundColor Gray
}

# Step 3: Check PowerShell module
Write-Host "`n[3/5] Checking ExchangeOnlineManagement module..." -ForegroundColor Cyan

$module = Get-Module -ListAvailable -Name ExchangeOnlineManagement | Select-Object -First 1

if (-not $module) {
    Write-Host "    [ERROR] ExchangeOnlineManagement module not found" -ForegroundColor Red
    Write-Host "    Install with: Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

Write-Host "    [OK] Module found: Version $($module.Version)" -ForegroundColor Green

# Step 4: Validate XML files
Write-Host "`n[4/5] Validating XML files..." -ForegroundColor Cyan

$validFiles = @()
$invalidFiles = @()

foreach ($file in $allXmlFiles) {
    try {
        [xml]$xmlContent = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Basic validation
        if (-not $xmlContent.RulePackage) {
            throw "Missing RulePackage element"
        }
        if (-not $xmlContent.RulePackage.Rules) {
            throw "Missing Rules element"
        }
        
        $validFiles += $file
        Write-Host "    [OK] $($file.BaseName)" -ForegroundColor Green
    }
    catch {
        $invalidFiles += [PSCustomObject]@{
            File = $file.BaseName
            Error = $_.Exception.Message
        }
        Write-Host "    [ERROR] $($file.BaseName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n    Valid: $(@($validFiles).Count) | Invalid: $(@($invalidFiles).Count)" -ForegroundColor Gray

if (@($validFiles).Count -eq 0) {
    Write-Host "    [ERROR] No valid XML files to upload" -ForegroundColor Red
    exit 1
}

# Step 4: Connect to tenant (skip in DryRun mode)
if ($DryRun) {
    Write-Host "\n[4/5] [DRYRUN] Skipping tenant connection\n" -ForegroundColor Yellow
} else {
    Write-Host "\n[4/5] Connecting to Security & Compliance Center..." -ForegroundColor Cyan
    
    try {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        Connect-IPPSSession -ErrorAction Stop
        Write-Host "    [OK] Connected to tenant`n" -ForegroundColor Green
    }
    catch {
        Write-Host "    [ERROR] Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Ensure you have Compliance Administrator permissions" -ForegroundColor Yellow
        exit 1
    }
}

# Step 5: Upload SITs
Write-Host "[5/5] Uploading SITs to tenant..." -ForegroundColor Cyan

$uploadResults = @{
    Success = @()
    Failed = @()
    Skipped = @()
}

foreach ($file in $validFiles) {
    $sitName = $file.BaseName
    
    if ($DryRun) {
        Write-Host "    [DRYRUN] Would upload: $sitName" -ForegroundColor Yellow
        $uploadResults.Skipped += $sitName
        continue
    }
    
    try {
        # Read XML file as bytes to preserve UTF-8 BOM
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        
        # Upload using New-DlpSensitiveInformationTypeRulePackage
        New-DlpSensitiveInformationTypeRulePackage -FileData $fileBytes -ErrorAction Stop | Out-Null
        
        Write-Host "    [OK] $sitName" -ForegroundColor Green
        $uploadResults.Success += $sitName
        
        # Throttling protection
        Start-Sleep -Milliseconds 500
    }
    catch {
        $errorMessage = $_.Exception.Message
        
        # Check if SIT already exists
        if ($errorMessage -like "*already exists*" -or $errorMessage -like "*duplicate*") {
            Write-Host "    [SKIP] $sitName (already exists)" -ForegroundColor Yellow
            $uploadResults.Skipped += $sitName
        }
        else {
            Write-Host "    [FAIL] $sitName - $errorMessage" -ForegroundColor Red
            $uploadResults.Failed += [PSCustomObject]@{
                SIT = $sitName
                Error = $errorMessage
            }
        }
    }
}

# Step 6: Summary
Write-Host "\nUpload summary:" -ForegroundColor Cyan
Write-Host "    Success: $(@($uploadResults.Success).Count)" -ForegroundColor Green
Write-Host "    Skipped: $(@($uploadResults.Skipped).Count)" -ForegroundColor Yellow
Write-Host "    Failed: $(@($uploadResults.Failed).Count)" -ForegroundColor $(if (@($uploadResults.Failed).Count -gt 0) { "Red" } else { "Gray" })

if (@($uploadResults.Failed).Count -gt 0) {
    Write-Host "`nFailed uploads:" -ForegroundColor Red
    $uploadResults.Failed | ForEach-Object {
        Write-Host "    - $($_.SIT): $($_.Error)" -ForegroundColor Red
    }
}

if ($DryRun) {
    Write-Host "`n[DRYRUN] No changes made to tenant" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to upload SITs" -ForegroundColor Yellow
}
else {
    Write-Host "`n[OK] Upload complete!" -ForegroundColor Green
    Write-Host "View SITs in Microsoft Purview portal:" -ForegroundColor Gray
    Write-Host "https://purview.microsoft.com -> Information Protection -> Classifiers -> Sensitive info types" -ForegroundColor Gray
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
