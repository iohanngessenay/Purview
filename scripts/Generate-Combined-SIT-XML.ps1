<#
.SYNOPSIS
    Generates a SINGLE Microsoft Purview SIT XML file containing all 28 SITs.

.DESCRIPTION
    Microsoft limits tenants to 10 custom rule packages. This script creates ONE
    rule package XML file containing all 28 SITs (12 HR + 16 LEGAL) to stay within
    the limit.
    
    - Single XML file with 28 Entities (SITs)
    - Each SIT contains multilingual keywords (EN, DE, FR, ES, IT)
    - Complies with 10 rule package limit
    
    Output: Single file "All_SITs_Combined.xml"

.PARAMETER OutputPath
    Path where the combined XML file will be generated.

.PARAMETER Languages
    Languages to include. Default: all 5 (en, de, fr, es, it)

.EXAMPLE
    .\Generate-Combined-SIT-XML.ps1
    
.EXAMPLE
    .\Generate-Combined-SIT-XML.ps1 -Languages @("en","de","fr")
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = (Join-Path $env:USERPROFILE "Downloads\SIT_Upload"),

    [Parameter(Mandatory=$false)]
    [ValidateSet("en", "de", "fr", "es", "it")]
    [string[]]$Languages = @("en", "de", "fr", "es", "it")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Combined SIT XML Generator" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Get project root
$ProjectRoot = Split-Path -Parent $PSScriptRoot

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Language mapping
$languageNames = @{
    "en" = "English"
    "de" = "German"
    "fr" = "French"
    "es" = "Spanish"
    "it" = "Italian"
}

$langFullNames = ($Languages | ForEach-Object { $languageNames[$_] }) -join ", "
$langAbbrev = ($Languages | ForEach-Object { $_.ToUpper() }) -join "/"

Write-Host "[1/5] Discovering SIT categories..." -ForegroundColor Cyan

# Discover categories
$hrCategories = @(Get-ChildItem -Path (Join-Path $ProjectRoot "HR") -Directory)
$legalCategories = @(Get-ChildItem -Path (Join-Path $ProjectRoot "LEGAL") -Directory)

Write-Host "    Found $($hrCategories.Count) HR categories" -ForegroundColor Gray
Write-Host "    Found $($legalCategories.Count) LEGAL categories" -ForegroundColor Gray

$allCategories = $hrCategories + $legalCategories

Write-Host "`n[2/5] Generating combined XML with $($allCategories.Count) SITs..." -ForegroundColor Cyan

# Function to escape XML special characters
function Escape-Xml {
    param([string]$text)
    return $text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
}

# Generate GUIDs
$rulePackGuid = [guid]::NewGuid().ToString()
$publisherGuid = [guid]::NewGuid().ToString()

# Build all entities
$allEntitiesXml = ""
$allKeywordsXml = ""
$allLocalizedStringsXml = ""

foreach ($category in $allCategories) {
    # Collect all keywords from all selected languages
    $allPrimaryKeywords = @()
    $allContextKeywords = @()
    $foundLanguages = @()
    
    foreach ($lang in $Languages) {
        $langPath = Join-Path $category.FullName $lang
        if (Test-Path $langPath) {
            # Read primary keywords
            $primaryFiles = Get-ChildItem -Path $langPath -Filter "*primary.txt" -ErrorAction SilentlyContinue
            if ($primaryFiles) {
                $primaryContent = Get-Content $primaryFiles[0].FullName -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($primaryContent) {
                    $allPrimaryKeywords += $primaryContent | Where-Object { $_.Trim() -ne "" }
                    $foundLanguages += $lang
                }
            }
            
            # Read context keywords
            $contextFiles = Get-ChildItem -Path $langPath -Filter "*context.txt" -ErrorAction SilentlyContinue
            if ($contextFiles) {
                $contextContent = Get-Content $contextFiles[0].FullName -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($contextContent) {
                    $allContextKeywords += $contextContent | Where-Object { $_.Trim() -ne "" }
                }
            }
        }
    }
    
    if ($allPrimaryKeywords.Count -eq 0) {
        continue
    }
    
    # Generate unique GUIDs for this SIT
    $entityGuid = [guid]::NewGuid().ToString()
    $primaryMatchGuid = "Keyword_Primary_$($category.Name)_ML"
    $contextMatchGuid = "Keyword_Context_$($category.Name)_ML"
    
    $hasContext = $allContextKeywords.Count -gt 0
    
    # Build keyword XML
    $primaryKeywordXml = ($allPrimaryKeywords | ForEach-Object { 
        "      <Term>$(Escape-Xml $_)</Term>" 
    }) -join "`n"
    
    $contextKeywordXml = if ($hasContext) {
        ($allContextKeywords | ForEach-Object { 
            "      <Term>$(Escape-Xml $_)</Term>" 
        }) -join "`n"
    } else { "" }
    
    # Build patterns
    $patternsXml = ""
    if ($hasContext) {
        $patternsXml += @"

      <Pattern confidenceLevel="85">
        <IdMatch idRef="$primaryMatchGuid" />
        <Match idRef="$contextMatchGuid" />
      </Pattern>
"@
    }
    
    $patternsXml += @"

      <Pattern confidenceLevel="75">
        <IdMatch idRef="$primaryMatchGuid" />
      </Pattern>
"@
    
    $recommendedConfidence = if ($hasContext) { 85 } else { 75 }
    
    # Build Entity
    $allEntitiesXml += @"

    <Entity id="$entityGuid" patternsProximity="300" recommendedConfidence="$recommendedConfidence">$patternsXml
    </Entity>
"@
    
    # Build Keywords
    $allKeywordsXml += @"

    <Keyword id="$primaryMatchGuid">
      <Group matchStyle="word">
$primaryKeywordXml
      </Group>
    </Keyword>
"@
    
    if ($hasContext) {
        $allKeywordsXml += @"

    <Keyword id="$contextMatchGuid">
      <Group matchStyle="word">
$contextKeywordXml
      </Group>
    </Keyword>
"@
    }
    
    # Build LocalizedStrings
    $sitDisplayName = "$($category.Name.Replace('_', ' '))"
    $allLocalizedStringsXml += @"

      <Resource idRef="$entityGuid">
        <Name default="true" langcode="en-us">$sitDisplayName</Name>
        <Description default="true" langcode="en-us">$sitDisplayName - Multilingual detection ($langAbbrev)</Description>
      </Resource>
"@
    
    Write-Host "    [OK] $sitDisplayName ($($allPrimaryKeywords.Count)p/$($allContextKeywords.Count)c keywords)" -ForegroundColor Green
}

Write-Host "`n[3/5] Building combined XML structure..." -ForegroundColor Cyan

# Build complete combined XML
$combinedXml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2011/mce">
  <RulePack id="$rulePackGuid">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="$publisherGuid" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>baseVISION</PublisherName>
        <Name>Combined SIT Package - All Categories</Name>
        <Description>Combined package with $($allCategories.Count) multilingual SITs (HR + LEGAL). Languages: $langFullNames</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>$allEntitiesXml$allKeywordsXml
    <LocalizedStrings>$allLocalizedStringsXml
    </LocalizedStrings>
  </Rules>
</RulePackage>
"@

Write-Host "[4/5] Writing combined XML file..." -ForegroundColor Cyan

$outputFilePath = Join-Path $OutputPath "All_SITs_Combined.xml"
$utf8WithBom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($outputFilePath, $combinedXml, $utf8WithBom)

Write-Host "    [OK] File created: All_SITs_Combined.xml" -ForegroundColor Green

# Create summary
$summaryPath = Join-Path $OutputPath "Combined_SIT_Summary.txt"
$summary = @"
Microsoft Purview Combined SIT Package - Generation Summary
===========================================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Output File: All_SITs_Combined.xml
Total SITs in Package: $($allCategories.Count)

Why Single File?
- Microsoft limit: 10 custom rule packages per tenant
- This approach: 1 rule package containing $($allCategories.Count) SITs
- Remaining capacity: 9 more rule packages available

SIT Categories Included:
- HR: $($hrCategories.Count) categories
- LEGAL: $($legalCategories.Count) categories

Languages: $langFullNames

Next Steps:
1. Review the generated file: All_SITs_Combined.xml
2. Upload with: .\Upload-SITs-From-Folder.ps1
3. All $($allCategories.Count) SITs will be imported as one package

Microsoft Purview Portal:
https://purview.microsoft.com -> Information Protection -> Classifiers -> Sensitive info types
"@

[System.IO.File]::WriteAllText($summaryPath, $summary, [System.Text.Encoding]::UTF8)

Write-Host "`n[5/5] Complete!" -ForegroundColor Green
Write-Host "`nGenerated:" -ForegroundColor Cyan
Write-Host "  File: $outputFilePath" -ForegroundColor White
Write-Host "  SITs: $($allCategories.Count) sensitive information types" -ForegroundColor White
Write-Host "  Size: $([Math]::Round((Get-Item $outputFilePath).Length / 1KB, 2)) KB" -ForegroundColor White
Write-Host "`nNext step:" -ForegroundColor Yellow
Write-Host "  .\Upload-SITs-From-Folder.ps1 -InputPath '$OutputPath'" -ForegroundColor White
Write-Host "`n========================================`n" -ForegroundColor Cyan
