<#
.SYNOPSIS
    Uploads individual SIT XML files to Microsoft Purview tenant.

.DESCRIPTION
    Uploads custom Sensitive Information Type (SIT) XML files to a Microsoft 365 tenant
    using Security & Compliance PowerShell. Supports selective upload by category, language,
    or specific SIT names.
    
    Prerequisites:
    - ExchangeOnlineManagement PowerShell module
    - Compliance Administrator or equivalent role
    - Generated XML files from Generate-SIT-XML-Files.ps1

.PARAMETER InputPath
    Path containing SIT XML files. Default: .\SIT_XML_Export

.PARAMETER DryRun
    Validate XML files without uploading to tenant

.PARAMETER Category
    Upload only SITs matching category name (supports wildcards)
    Example: -Category "Applicant*" or -Category "*Salary*"

.PARAMETER Language
    Upload only SITs for specific language(s)
    Valid values: EN, DE, FR, ES

.PARAMETER SITName
    Upload specific SIT(s) by exact name (supports wildcards)
    Example: -SITName "Applicant_Recruiting_Data_EN"

.EXAMPLE
    .\Upload-Individual-SITs.ps1 -DryRun
    Validate all XML files without uploading

.EXAMPLE
    .\Upload-Individual-SITs.ps1 -Language EN
    Upload only English SITs

.EXAMPLE
    .\Upload-Individual-SITs.ps1 -Category "*Salary*" -Language EN,DE
    Upload Salary-related SITs in English and German

.EXAMPLE
    .\Upload-Individual-SITs.ps1 -SITName "Applicant_Recruiting_Data_EN"
    Upload a specific SIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$InputPath = "",  # Will be set to project root default
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [string]$Category,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("EN", "DE", "FR", "ES")]
    [string[]]$Language,
    
    [Parameter(Mandatory=$false)]
    [string]$SITName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Get project root (parent of scripts folder)
$projectRoot = Split-Path -Parent $PSScriptRoot

# Set default input path if not provided
if ([string]::IsNullOrEmpty($InputPath)) {
    $InputPath = Join-Path $projectRoot "SIT_XML_Export"
}
# Resolve relative paths
elseif (-not [System.IO.Path]::IsPathRooted($InputPath)) {
    $InputPath = Join-Path $projectRoot $InputPath
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Microsoft Purview SIT Upload Tool" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Discover XML files
Write-Host "[1/6] Discovering SIT XML files..." -ForegroundColor Cyan

if (-not (Test-Path $InputPath)) {
    Write-Host "    [ERROR] Input path not found: $InputPath" -ForegroundColor Red
    Write-Host "    Run Generate-SIT-XML-Files.ps1 first to create XML files" -ForegroundColor Yellow
    exit 1
}

$allXmlFiles = Get-ChildItem -Path $InputPath -Filter "*.xml" | Where-Object { $_.Name -ne "SIT_Generation_Summary.txt" }

if ($allXmlFiles.Count -eq 0) {
    Write-Host "    [ERROR] No XML files found in $InputPath" -ForegroundColor Red
    exit 1
}

Write-Host "    Found $($allXmlFiles.Count) XML files" -ForegroundColor Gray

# Apply filters
$filteredFiles = $allXmlFiles

if ($SITName) {
    $filteredFiles = $filteredFiles | Where-Object { $_.BaseName -like $SITName }
    Write-Host "    Filtered by SIT name '$SITName': $($filteredFiles.Count) files" -ForegroundColor Gray
}

if ($Category) {
    $filteredFiles = $filteredFiles | Where-Object { $_.BaseName -like "*$Category*" }
    Write-Host "    Filtered by category '$Category': $($filteredFiles.Count) files" -ForegroundColor Gray
}

if ($Language) {
    $languagePattern = ($Language | ForEach-Object { "*_$_" }) -join "|"
    $filteredFiles = $filteredFiles | Where-Object { 
        $name = $_.BaseName
        $Language | ForEach-Object { $name -like "*_$_" } | Where-Object { $_ } | Select-Object -First 1
    }
    Write-Host "    Filtered by language(s) '$($Language -join ', ')': $($filteredFiles.Count) files" -ForegroundColor Gray
}

if ($filteredFiles.Count -eq 0) {
    Write-Host "    [ERROR] No XML files match the specified filters" -ForegroundColor Red
    exit 1
}

Write-Host "    [OK] $($filteredFiles.Count) SIT(s) selected for upload`n" -ForegroundColor Green

# Step 2: Check PowerShell module
Write-Host "[2/6] Checking ExchangeOnlineManagement module..." -ForegroundColor Cyan

$module = Get-Module -ListAvailable -Name ExchangeOnlineManagement | Select-Object -First 1

if (-not $module) {
    Write-Host "    [ERROR] ExchangeOnlineManagement module not found" -ForegroundColor Red
    Write-Host "    Install with: Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

Write-Host "    [OK] Module found: Version $($module.Version)`n" -ForegroundColor Green

# Step 3: Validate XML files
Write-Host "[3/6] Validating XML files..." -ForegroundColor Cyan

$validFiles = @()
$invalidFiles = @()

foreach ($file in $filteredFiles) {
    try {
        [xml]$xmlContent = Get-Content $file.FullName -Raw
        
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

Write-Host "`n    Valid: $($validFiles.Count) | Invalid: $($invalidFiles.Count)" -ForegroundColor Gray

if ($validFiles.Count -eq 0) {
    Write-Host "    [ERROR] No valid XML files to upload" -ForegroundColor Red
    exit 1
}

# Step 4: Connect to tenant (skip in DryRun mode)
if ($DryRun) {
    Write-Host "`n[4/6] [DRYRUN] Skipping tenant connection`n" -ForegroundColor Yellow
} else {
    Write-Host "`n[4/6] Connecting to Security & Compliance Center..." -ForegroundColor Cyan
    
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
Write-Host "[5/6] Uploading SITs to tenant..." -ForegroundColor Cyan

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
        # Read XML content
        [xml]$xmlContent = Get-Content $file.FullName -Raw
        
        # Upload using New-DlpSensitiveInformationTypeRulePackage
        $rulePackageXml = $xmlContent.OuterXml
        
        New-DlpSensitiveInformationTypeRulePackage -FileData ([System.Text.Encoding]::UTF8.GetBytes($rulePackageXml)) -ErrorAction Stop | Out-Null
        
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
Write-Host "`n[6/6] Upload summary:" -ForegroundColor Cyan
Write-Host "    Success: $($uploadResults.Success.Count)" -ForegroundColor Green
Write-Host "    Skipped: $($uploadResults.Skipped.Count)" -ForegroundColor Yellow
Write-Host "    Failed: $($uploadResults.Failed.Count)" -ForegroundColor $(if ($uploadResults.Failed.Count -gt 0) { "Red" } else { "Gray" })

if ($uploadResults.Failed.Count -gt 0) {
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
