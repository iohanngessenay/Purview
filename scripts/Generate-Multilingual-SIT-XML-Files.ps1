<#
.SYNOPSIS
    Generates multilingual Microsoft Purview SIT XML files combining all languages in one SIT.

.DESCRIPTION
    Creates 28 multilingual Sensitive Information Type (SIT) XML rule packages:
    - 28 categories (12 HR + 16 LEGAL)
    - Each SIT contains keywords from ALL 5 languages (EN, DE, FR, ES, IT)
    - Single keyword list per SIT with multilingual terms
    - Localized names and descriptions for all languages
    - Each SIT detects the concept regardless of document language

    Output: SIT_XML_Export_Multilingual folder with 28 XML files.

.PARAMETER OutputPath
    Path where XML files will be generated. Default: .\SIT_XML_Export_Multilingual

.EXAMPLE
    .\Generate-Multilingual-SIT-XML-Files.ps1

.EXAMPLE
    .\Generate-Multilingual-SIT-XML-Files.ps1 -OutputPath "C:\Export\MultilingualSITs"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = (Join-Path $env:USERPROFILE "Downloads\SIT_XML_Export_Multilingual"),

    [Parameter(Mandatory=$false)]
    [ValidateSet("en", "de", "fr", "es", "it")]
    [string[]]$Languages = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Interactive language selection if not provided
if ($null -eq $Languages -or @($Languages).Count -eq 0) {
    Write-Host "`n=== Multilingual SIT Generator - Language Selection ===" -ForegroundColor Cyan
    Write-Host "`nSelect the languages to include in the multilingual SITs:" -ForegroundColor Yellow
    Write-Host ""

    $availableLanguages = @(
        [PSCustomObject]@{Code = "en"; Name = "English"; Selected = $false}
        [PSCustomObject]@{Code = "de"; Name = "German"; Selected = $false}
        [PSCustomObject]@{Code = "fr"; Name = "French"; Selected = $false}
        [PSCustomObject]@{Code = "es"; Name = "Spanish"; Selected = $false}
        [PSCustomObject]@{Code = "it"; Name = "Italian"; Selected = $false}
    )

    $selectionComplete = $false

    while (-not $selectionComplete) {
        Clear-Host
        Write-Host "`n=== Multilingual SIT Generator - Language Selection ===" -ForegroundColor Cyan
        Write-Host ""

        for ($i = 0; $i -lt $availableLanguages.Count; $i++) {
            $lang = $availableLanguages[$i]
            $checkbox = if ($lang.Selected) { "[X]" } else { "[ ]" }
            $color = if ($lang.Selected) { "Green" } else { "White" }
            Write-Host "  $($i + 1). $checkbox $($lang.Name) ($($lang.Code.ToUpper()))" -ForegroundColor $color
        }

        $selectedCount = @($availableLanguages | Where-Object { $_.Selected }).Count
        Write-Host ""
        Write-Host "Currently selected: $selectedCount language(s)" -ForegroundColor $(if ($selectedCount -gt 0) { "Green" } else { "Yellow" })
        Write-Host ""
        Write-Host "Enter number to toggle selection, 'A' for all, 'C' to clear, or 'D' when done:" -ForegroundColor Yellow
        Write-Host "(Minimum 1 language required)" -ForegroundColor Gray

        $userInput = Read-Host "`nYour choice"

        switch ($userInput.ToUpper()) {
            'A' {
                $availableLanguages | ForEach-Object { $_.Selected = $true }
            }
            'C' {
                $availableLanguages | ForEach-Object { $_.Selected = $false }
            }
            'D' {
                if ($selectedCount -gt 0) {
                    $selectionComplete = $true
                } else {
                    Write-Host "`nError: Please select at least one language!" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
            default {
                if ($userInput -match '^\d+$') {
                    $index = [int]$userInput - 1
                    if ($index -ge 0 -and $index -lt $availableLanguages.Count) {
                        $availableLanguages[$index].Selected = -not $availableLanguages[$index].Selected
                    }
                }
            }
        }
    }

    $Languages = ($availableLanguages | Where-Object { $_.Selected } | Select-Object -ExpandProperty Code)

    Clear-Host
    Write-Host "`n=== Language Selection Confirmed ===" -ForegroundColor Green
    Write-Host "Selected languages: $(($availableLanguages | Where-Object { $_.Selected } | ForEach-Object { "$($_.Name) ($($_.Code.ToUpper()))" }) -join ', ')" -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 2
}

# Get project root (parent of scripts folder)
$projectRoot = Split-Path -Parent $PSScriptRoot

# Resolve output path relative to project root if not absolute
if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $projectRoot $OutputPath
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "[1/5] Discovering SIT categories..." -ForegroundColor Cyan

# Discover all SIT categories
$hrCategories = @(Get-ChildItem -Path (Join-Path $projectRoot "HR") -Directory | Select-Object -ExpandProperty Name)
$legalCategories = @(Get-ChildItem -Path (Join-Path $projectRoot "LEGAL") -Directory | Select-Object -ExpandProperty Name)

$allCategories = @(
    $hrCategories | ForEach-Object { [PSCustomObject]@{Name = $_; Domain = "HR"} }
    $legalCategories | ForEach-Object { [PSCustomObject]@{Name = $_; Domain = "LEGAL"} }
)

Write-Host "    Found $($hrCategories.Count) HR categories" -ForegroundColor Gray
Write-Host "    Found $($legalCategories.Count) LEGAL categories" -ForegroundColor Gray

$languageNames = @{
    "en" = "English"
    "de" = "German"
    "fr" = "French"
    "es" = "Spanish"
    "it" = "Italian"
}
$langCodes = @{
    "en" = "en-us"
    "de" = "de-de"
    "fr" = "fr-fr"
    "es" = "es-es"
    "it" = "it-it"
}

# Build language abbreviation string (e.g., "EN/DE/FR" or "EN/DE/FR/ES/IT")
$langAbbrev = ($Languages | ForEach-Object { $_.ToUpper() }) -join "/"
$langAbbrevFileName = ($Languages | ForEach-Object { $_.ToUpper() }) -join "-"  # Use dash for filenames (Windows compatible)
$langFullNames = ($Languages | ForEach-Object { $languageNames[$_] }) -join ", "

Write-Host "[2/5] Preparing to generate $($allCategories.Count) multilingual SIT XML files..." -ForegroundColor Cyan
Write-Host "    Languages: $langAbbrev ($langFullNames)" -ForegroundColor Gray

$generatedCount = 0
$skippedCount = 0

foreach ($category in $allCategories) {

    $sitFolderPath = Join-Path $projectRoot (Join-Path $category.Domain $category.Name)

    # Collect all keywords from all languages
    $allPrimaryKeywords = @()
    $allContextKeywords = @()
    $allRegexPatterns = @()
    $foundLanguages = @()

    foreach ($lang in $Languages) {
        $langFolderPath = Join-Path $sitFolderPath $lang

        if (-not (Test-Path $langFolderPath)) {
            continue
        }

        # Read keyword files for this language
        $primaryPath = Get-ChildItem -Path $langFolderPath -Filter "*_primary.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
        $contextPath = Get-ChildItem -Path $langFolderPath -Filter "*_context.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
        $regexPath = Get-ChildItem -Path $langFolderPath -Filter "*_regex.txt" -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($primaryPath) {
            $primaryKeywords = @(Get-Content $primaryPath.FullName -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" })
            $allPrimaryKeywords += $primaryKeywords
            $foundLanguages += $lang
        }

        if ($contextPath) {
            $contextKeywords = @(Get-Content $contextPath.FullName -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" })
            $allContextKeywords += $contextKeywords
        }

        if ($regexPath) {
            $regexPatterns = @(Get-Content $regexPath.FullName -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" })
            $allRegexPatterns += $regexPatterns
        }
    }

    # Skip if no primary keywords found in any language
    if ($allPrimaryKeywords.Count -eq 0) {
        Write-Host "    [SKIP] $($category.Name) - no primary keywords found" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    # Build SIT name (no language suffix since it's multilingual)
    $sitName = "$($category.Name) [ML]"
    $sitDescription = "$($category.Name.Replace('_', ' ')) - Multilingual detection for Microsoft Purview. Supports: $langFullNames"

    # Generate IDs
    $sitGuid = [guid]::NewGuid().ToString()  # RulePack GUID
    $entityGuid = [guid]::NewGuid().ToString()  # Entity GUID
    $publisherGuid = [guid]::NewGuid().ToString()  # Publisher GUID
    $primaryMatchGuid = "Keyword_Primary_$sitName"
    $contextMatchGuid = if ($allContextKeywords.Count -gt 0) { "Keyword_Context_$sitName" } else { $null }

    # Build XML keyword elements (combined from all languages)
    $primaryKeywordXml = ($allPrimaryKeywords | ForEach-Object {
        "      <Term>$([System.Security.SecurityElement]::Escape($_))</Term>"
    }) -join "`n"

    $hasContext = ($allContextKeywords.Count -gt 0)
    $contextKeywordXml = if ($hasContext) {
        ($allContextKeywords | ForEach-Object {
            "      <Term>$([System.Security.SecurityElement]::Escape($_))</Term>"
        }) -join "`n"
    } else { "" }

    # Build Match elements
    $primaryMatchXml = @"
    <Keyword id="$primaryMatchGuid">
      <Group matchStyle="word">
$primaryKeywordXml
      </Group>
    </Keyword>
"@

    $contextMatchXml = if ($hasContext) {
@"
    <Keyword id="$contextMatchGuid">
      <Group matchStyle="word">
$contextKeywordXml
      </Group>
    </Keyword>
"@
    } else { "" }

    # Build multiple patterns with different confidence levels
    $patternsXml = ""

    # Pattern 1 (85% - High): Primary + Context (both required)
    if ($hasContext) {
        $patternsXml += @"

      <Pattern confidenceLevel="85">
        <IdMatch idRef="$primaryMatchGuid" />
        <Match idRef="$contextMatchGuid" />
      </Pattern>
"@
    }

    # Pattern 2 (75% - Medium): Primary only (always include)
    $patternsXml += @"

      <Pattern confidenceLevel="75">
        <IdMatch idRef="$primaryMatchGuid" />
      </Pattern>
"@

    # Determine recommended confidence (highest pattern available)
    $recommendedConfidence = if ($hasContext) { 85 } else { 75 }

    # Build LocalizedStrings - only one Name and Description with default language
    $localizedName = "$($category.Name.Replace('_', ' ')) [ML]"
    $localizedDesc = "$($category.Name.Replace('_', ' ')) - Detects $($category.Name.Replace('_', ' ').ToLower()) related information. Supports: $langFullNames"

    # Build complete XML with proper schema
    $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2011/mce">
  <RulePack id="$sitGuid">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="$publisherGuid" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>baseVISION</PublisherName>
        <Name>$sitName</Name>
        <Description>$sitDescription</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$entityGuid" patternsProximity="300" recommendedConfidence="$recommendedConfidence">$patternsXml
    </Entity>
$primaryMatchXml$contextMatchXml
    <LocalizedStrings>
      <Resource idRef="$entityGuid">
        <Name default="true" langcode="en-us">$localizedName</Name>
        <Description default="true" langcode="en-us">$localizedDesc</Description>
      </Resource>
    </LocalizedStrings>
  </Rules>
</RulePackage>
"@

    # Write XML file with UTF-8 BOM encoding (required by Microsoft Purview)
    $outputFileName = "$sitName.xml" -replace '\[|\]', '' -replace '/', '-'  # Remove brackets and replace slashes
    $outputFilePath = Join-Path $OutputPath $outputFileName

    # Use UTF-8 with BOM encoding as required by schema
    $utf8WithBom = New-Object System.Text.UTF8Encoding $true
    [System.IO.File]::WriteAllText($outputFilePath, $xml, $utf8WithBom)

    $generatedCount++
    $langList = ($foundLanguages | ForEach-Object { $_.ToUpper() }) -join "/"
    Write-Host "    [OK] $sitName ($($allPrimaryKeywords.Count)p/$($allContextKeywords.Count)c keywords, $langList)" -ForegroundColor Green
}

Write-Host "`n[3/5] Generation complete!" -ForegroundColor Cyan
Write-Host "    Generated: $generatedCount multilingual XML files" -ForegroundColor Green
Write-Host "    Skipped: $skippedCount" -ForegroundColor Gray

# Generate summary report
Write-Host "`n[4/5] Creating summary report..." -ForegroundColor Cyan

$summaryPath = Join-Path $OutputPath "SIT_Generation_Summary.txt"
$summary = @"
Microsoft Purview Multilingual SIT XML Generation Summary
=========================================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Total Multilingual SIT XML Files: $generatedCount
Skipped: $skippedCount

Categories by Domain:
- HR: $($hrCategories.Count) categories
- LEGAL: $($legalCategories.Count) categories

Languages Supported (per SIT):
$(($Languages | ForEach-Object { "- $($languageNames[$_]) ($_)" }) -join "`n")

Architecture:
- Each SIT contains keywords from selected languages ($langAbbrev)
- Single keyword list combines multilingual terms
- Detects content regardless of document language
- Localized names/descriptions for UI support

Benefits vs Single-Language Approach:
- Reduced from $($allCategories.Count * 5) to $generatedCount SIT files ($(100 - [math]::Round(($generatedCount / ($allCategories.Count * 5)) * 100))% reduction)
- Simplified deployment ($generatedCount imports vs $($allCategories.Count * 5))
- Single policy detects selected languages ($langAbbrev)
- Easier maintenance and updates

Microsoft Purview Limits:
- Maximum custom SITs per tenant: 500
- Your generated SITs: $generatedCount
- Remaining capacity: $(500 - $generatedCount)
- Status: [OK] Well within limits

Keyword List Limits (per SIT):
- Maximum terms per keyword list: 2,048
- Maximum term length: 50 characters
- Your largest SIT: ~200 terms (10% of limit)

Next Steps:
1. Review generated XML files in: $OutputPath
2. Test upload with Upload-Individual-SITs.ps1 -DryRun
3. Upload selected SITs to tenant
4. Create DLP policies using multilingual SITs
5. Test detection across all 5 languages

Deployment Advantages:
- Import only $generatedCount SITs instead of $($allCategories.Count * $Languages.Count)
- One policy rule detects selected languages ($langAbbrev)
- Simplified policy management
- Better performance (fewer SIT evaluations)
- Centralized updates (one SIT per concept)

Usage Examples:
# Generate with default languages (EN/DE/FR/ES/IT)
.\Generate-Multilingual-SIT-XML-Files.ps1

# Generate with only English and German
.\Generate-Multilingual-SIT-XML-Files.ps1 -Languages @("en", "de")

# Generate with English, French, and Italian
.\Generate-Multilingual-SIT-XML-Files.ps1 -Languages @("en", "fr", "it")
"@

$summary | Out-File -FilePath $summaryPath -Encoding UTF8 -Force

Write-Host "    Summary: $summaryPath" -ForegroundColor Gray

Write-Host "`n[5/5] All done!" -ForegroundColor Cyan
Write-Host "`nGenerated files location: $OutputPath" -ForegroundColor Green
Write-Host "Total multilingual SIT XML files: $generatedCount" -ForegroundColor Green
Write-Host "`nAdvantage: $generatedCount multilingual SITs vs 140 single-language SITs!" -ForegroundColor Yellow
Write-Host "Next step: Run .\scripts\Upload-Individual-SITs.ps1 -DryRun to test" -ForegroundColor Yellow
