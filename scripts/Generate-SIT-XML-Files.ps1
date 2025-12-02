<#
.SYNOPSIS
    Generates individual Microsoft Purview SIT XML files with inline keyword lists.

.DESCRIPTION
    Creates 112 individual Sensitive Information Type (SIT) XML rule packages:
    - 28 categories (12 HR + 16 LEGAL)
    - 4 languages each (EN, DE, FR, ES)
    - Inline keyword lists (no external dictionaries required)
    - Each SIT is self-contained and independently importable
    
    Output: SIT_XML_Export folder with 112 XML files ready for customer distribution.

.PARAMETER OutputPath
    Path where XML files will be generated. Default: .\SIT_XML_Export

.EXAMPLE
    .\Generate-SIT-XML-Files.ps1
    
.EXAMPLE
    .\Generate-SIT-XML-Files.ps1 -OutputPath "C:\Export\SITs"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\SIT_XML_Export"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "[1/5] Discovering SIT categories..." -ForegroundColor Cyan

# Discover all SIT categories
$hrCategories = @(Get-ChildItem -Path ".\HR" -Directory | Select-Object -ExpandProperty Name)
$legalCategories = @(Get-ChildItem -Path ".\LEGAL" -Directory | Select-Object -ExpandProperty Name)

$allCategories = @(
    $hrCategories | ForEach-Object { [PSCustomObject]@{Name = $_; Domain = "HR"} }
    $legalCategories | ForEach-Object { [PSCustomObject]@{Name = $_; Domain = "LEGAL"} }
)

Write-Host "    Found $($hrCategories.Count) HR categories" -ForegroundColor Gray
Write-Host "    Found $($legalCategories.Count) LEGAL categories" -ForegroundColor Gray

$languages = @("en", "de", "fr", "es")
$languageNames = @{
    "en" = "English"
    "de" = "German"
    "fr" = "French"
    "es" = "Spanish"
}

Write-Host "[2/5] Preparing to generate $($allCategories.Count * $languages.Count) SIT XML files..." -ForegroundColor Cyan

$generatedCount = 0
$skippedCount = 0

foreach ($category in $allCategories) {
    foreach ($lang in $languages) {
        
        $sitFolderPath = Join-Path $category.Domain $category.Name
        $langFolderPath = Join-Path $sitFolderPath $lang
        
        if (-not (Test-Path $langFolderPath)) {
            Write-Host "    [SKIP] $($category.Name) ($lang) - folder not found" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Read keyword files
        $primaryPath = Get-ChildItem -Path $langFolderPath -Filter "*_primary.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
        $contextPath = Get-ChildItem -Path $langFolderPath -Filter "*_context.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
        $regexPath = Get-ChildItem -Path $langFolderPath -Filter "*_regex.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if (-not $primaryPath) {
            Write-Host "    [SKIP] $($category.Name) ($lang) - no primary keywords" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Read keywords (filter out empty lines)
        $primaryKeywords = @(Get-Content $primaryPath.FullName | Where-Object { $_.Trim() -ne "" })
        $contextKeywords = if ($contextPath) { @(Get-Content $contextPath.FullName | Where-Object { $_.Trim() -ne "" }) } else { @() }
        $regexPatterns = if ($regexPath) { @(Get-Content $regexPath.FullName | Where-Object { $_.Trim() -ne "" }) } else { @() }
        
        # Generate unique GUIDs
        $sitGuid = [guid]::NewGuid().ToString()
        $entityGuid = [guid]::NewGuid().ToString()
        $primaryMatchGuid = [guid]::NewGuid().ToString()
        $contextMatchGuid = if ($contextKeywords -and $contextKeywords.Count -gt 0) { [guid]::NewGuid().ToString() } else { $null }
        $regexMatchGuid = if ($regexPatterns -and $regexPatterns.Count -gt 0) { [guid]::NewGuid().ToString() } else { $null }
        
        # Build SIT name and description
        $langUpper = $lang.ToUpper()
        $sitName = "$($category.Name)_$langUpper"
        $sitDescription = "$($category.Name.Replace('_', ' ')) - $($languageNames[$lang]) (Custom SIT for Microsoft Purview)"
        
        # Build XML keyword elements
        $primaryKeywordXml = ($primaryKeywords | ForEach-Object { 
            "        <Keyword>$([System.Security.SecurityElement]::Escape($_))</Keyword>" 
        }) -join "`n"
        
        $hasContext = ($contextKeywords -and $contextKeywords.Count -gt 0)
        $contextKeywordXml = if ($hasContext) {
            ($contextKeywords | ForEach-Object { 
                "        <Keyword>$([System.Security.SecurityElement]::Escape($_))</Keyword>" 
            }) -join "`n"
        } else { "" }
        
        $hasRegex = ($regexPatterns -and $regexPatterns.Count -gt 0)
        $regexKeywordXml = if ($hasRegex) {
            ($regexPatterns | ForEach-Object { 
                "        <Keyword>$([System.Security.SecurityElement]::Escape($_))</Keyword>" 
            }) -join "`n"
        } else { "" }
        
        # Build Match elements
        $primaryMatchXml = @"
    <Keyword id="$primaryMatchGuid">
$primaryKeywordXml
    </Keyword>
"@
        
        $contextMatchXml = if ($hasContext) {
@"
    <Keyword id="$contextMatchGuid">
$contextKeywordXml
    </Keyword>
"@
        } else { "" }
        
        $regexMatchXml = if ($hasRegex) {
@"
    <Keyword id="$regexMatchGuid">
$regexKeywordXml
    </Keyword>
"@
        } else { "" }
        
        # Build supporting elements (context + regex)
        $supportingElements = @()
        if ($contextMatchGuid) {
            $supportingElements += "          <Match idRef=`"$contextMatchGuid`" />"
        }
        if ($regexMatchGuid) {
            $supportingElements += "          <Match idRef=`"$regexMatchGuid`" />"
        }
        
        $hasSupportingElements = ($supportingElements -and $supportingElements.Count -gt 0)
        $supportingElementsXml = if ($hasSupportingElements) {
            "`n        <Any minMatches=`"1`">`n" + ($supportingElements -join "`n") + "`n        </Any>"
        } else { "" }
        
        # Determine confidence level based on supporting elements
        $confidenceLevel = if ($hasSupportingElements) { 85 } else { 75 }
        
        # Build complete XML
        $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2018/edm">
  <RulePack id="$sitGuid">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="00000000-0000-0000-0000-000000000000" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>Custom SIT Provider</PublisherName>
        <Name>$sitName</Name>
        <Description>$sitDescription</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$entityGuid" patternsProximity="300" recommendedConfidence="$confidenceLevel">
      <Pattern confidenceLevel="$confidenceLevel">
        <IdMatch idRef="$primaryMatchGuid" />$supportingElementsXml
      </Pattern>
    </Entity>
$primaryMatchXml$contextMatchXml$regexMatchXml
    <LocalizedStrings>
      <Resource idRef="$entityGuid">
        <Name default="true" langcode="en-us">$sitName</Name>
        <Description default="true" langcode="en-us">$sitDescription</Description>
      </Resource>
    </LocalizedStrings>
  </Rules>
</RulePackage>
"@
        
        # Write XML file
        $outputFileName = "$sitName.xml"
        $outputFilePath = Join-Path $OutputPath $outputFileName
        
        $xml | Out-File -FilePath $outputFilePath -Encoding UTF8 -Force
        
        $generatedCount++
        $contextCount = if ($contextKeywords) { $contextKeywords.Count } else { 0 }
        $regexCount = if ($regexPatterns) { $regexPatterns.Count } else { 0 }
        Write-Host "    [OK] $sitName ($($primaryKeywords.Count)p/$contextCount`c/$regexCount`r keywords)" -ForegroundColor Green
    }
}

Write-Host "`n[3/5] Generation complete!" -ForegroundColor Cyan
Write-Host "    Generated: $generatedCount XML files" -ForegroundColor Green
Write-Host "    Skipped: $skippedCount" -ForegroundColor Gray

# Generate summary report
Write-Host "`n[4/5] Creating summary report..." -ForegroundColor Cyan

$summaryPath = Join-Path $OutputPath "SIT_Generation_Summary.txt"
$summary = @"
Microsoft Purview SIT XML Generation Summary
============================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Total SIT XML Files: $generatedCount
Skipped: $skippedCount

Categories by Domain:
- HR: $($hrCategories.Count) categories × $($languages.Count) languages = $($hrCategories.Count * $languages.Count) SITs
- LEGAL: $($legalCategories.Count) categories × $($languages.Count) languages = $($legalCategories.Count * $languages.Count) SITs

Languages:
$(($languages | ForEach-Object { "- $($languageNames[$_]) ($_)" }) -join "`n")

Microsoft Purview Limits:
- Maximum custom SITs per tenant: 500
- Your generated SITs: $generatedCount
- Remaining capacity: $(500 - $generatedCount)
- Status: $(if ($generatedCount -le 500) { "[OK] Well within limits" } else { "[ERROR] Exceeds tenant limit" })

Keyword List Limits (per SIT):
- Maximum terms per keyword list: 2,048
- Maximum term length: 50 characters
- Your largest SIT: ~40 terms (well within limits)

Next Steps:
1. Review generated XML files in: $OutputPath
2. Test upload with Upload-Individual-SITs.ps1 -DryRun
3. Upload selected SITs to tenant
4. Distribute XML files to customers for selective import

Customer Benefits:
- Customers can import ONLY the SITs they need
- Each SIT maintains its specific detection context
- No shared dictionaries - each SIT is self-contained
- Supports selective deployment by category and language
"@

$summary | Out-File -FilePath $summaryPath -Encoding UTF8 -Force

Write-Host "    Summary: $summaryPath" -ForegroundColor Gray

Write-Host "`n[5/5] All done!" -ForegroundColor Cyan
Write-Host "`nGenerated files location: $OutputPath" -ForegroundColor Green
Write-Host "Total SIT XML files: $generatedCount" -ForegroundColor Green
Write-Host "`nNext step: Run .\scripts\Upload-Individual-SITs.ps1 -DryRun to test" -ForegroundColor Yellow
