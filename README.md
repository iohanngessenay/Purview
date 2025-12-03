# Microsoft Purview Custom SIT Library

A collection of pre-configured Sensitive Information Types (SITs) for Microsoft Purview Data Loss Prevention, covering HR and Legal use cases in multiple languages.

**Author:** Iohann Gessenay  
**Publisher:** PurviewInsights SIT  
**Version:** 1.0

---

## Quick Start

### 1. Download or Clone Repository
```powershell
git clone https://github.com/iohanngessenay/Purview.git
cd Purview
```

### 2. Install Prerequisites
```powershell
# Install Exchange Online Management module
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
```

### 3. Generate SIT XML Files
```powershell
.\scripts\Generate-SIT-XML-Files.ps1
```
This creates 112 XML files in `SIT_XML_Export\` folder.

### 4. Connect to Microsoft 365
```powershell
Import-Module ExchangeOnlineManagement
Connect-IPPSSession
```
You need Compliance Administrator role or equivalent.

### 5. Upload SITs to Your Tenant
```powershell
# Test first (no changes made)
.\scripts\Upload-Individual-SITs.ps1 -DryRun

# Upload all SITs
.\scripts\Upload-Individual-SITs.ps1

# Or upload by language
.\scripts\Upload-Individual-SITs.ps1 -Language EN,DE
```

### 6. Verify in Purview Portal
Navigate to: `https://purview.microsoft.com` > Information Protection > Classifiers > Sensitive info types

Filter by publisher: "PurviewInsights SIT"

---

## Overview

This project provides 112 ready-to-use custom SITs for Microsoft Purview, designed to detect sensitive HR and Legal information in documents and emails. Each SIT includes multiple confidence patterns and supports English, German, French, and Spanish.

### Coverage

**HR Categories (12)**
- Applicant & Recruiting Data
- Banking & Payment Information
- Disciplinary & Legal Records
- Emergency Contact Information
- Employee Contracts & Terms
- Expense & Reimbursement Records
- ID & Passport Information
- Medical & Health Information
- Performance Reviews
- Salary & Compensation Data
- Swiss AHV/AVS Numbers
- Training & Certification Records

**Legal Categories (16)**
- Board & Corporate Governance Documents
- Client Confidential Information
- Compliance Investigations
- Contracts & Agreement Data
- Court & Case Identifiers
- Data Processing Agreements (DPA)
- Intellectual Property & Patent Data
- Legal Case & Litigation Files
- Legal Invoices & Billing
- Legal Opinions & Counsel Memoranda
- Mergers & Acquisitions (M&A)
- Non-Disclosure Agreements (NDA)
- Regulatory & Compliance References
- Regulatory Filings & Submissions
- Sanctions & Export Control References
- Whistleblower Reports

### Languages

Each category is available in 4 languages:
- English (EN)
- German (DE)
- French (FR)
- Spanish (ES)

**Total SITs:** 28 categories × 4 languages = 112 SITs

---

## Architecture

### Detection Logic

Each SIT uses a multi-pattern approach for accurate detection:

**Pattern 1 - High Confidence (85%)**
- Primary keywords + Context keywords
- Both must appear within 300 characters
- Fewer false positives

**Pattern 2 - Medium Confidence (75%)**
- Primary keywords only
- Broader detection
- Fallback pattern

### Keyword Structure

Each SIT contains:
- **Primary Keywords:** 5-24 core terms (e.g., "Resume", "CV", "Interview")
- **Context Keywords:** 5-19 supporting terms (e.g., "Job Posting", "Recruitment")
- **Proximity Window:** 300 characters

All keywords use word-boundary matching to avoid partial matches.

### Technical Specifications

- **XML Schema:** `http://schemas.microsoft.com/office/2011/mce`
- **Encoding:** UTF-8 (preserves special characters: ä, é, ñ, etc.)
- **Keyword Limit:** 2,048 terms per SIT (current usage: 5-24 primary + 5-19 context)
- **Character Limit:** 50 characters per term
- **Tenant Limit:** 500 custom SITs maximum (project uses 112)

---

## File Structure

```
Purview/
├── HR/                                    # HR category keyword sources
│   ├── bv_Applicant_Recruiting_Data/
│   │   ├── BV_ApplicantRecruit_Primary_EN.txt
│   │   ├── BV_ApplicantRecruit_Context_EN.txt
│   │   ├── BV_ApplicantRecruit_Primary_DE.txt
│   │   └── ... (DE, FR, ES variants)
│   ├── bv_Banking_and_Payment_Data/
│   └── ... (11 more HR categories)
│
├── LEGAL/                                 # Legal category keyword sources
│   ├── bv_Board_or_Corporate_Governance_Documents/
│   ├── bv_Client_Confidential_Information/
│   └── ... (14 more Legal categories)
│
├── scripts/
│   ├── Generate-SIT-XML-Files.ps1        # XML generation script
│   └── Upload-Individual-SITs.ps1        # Upload script
│
├── SIT_XML_Export/                       # Generated XML files (112 files)
│   ├── Applicant_Recruiting_Data_EN.xml
│   ├── Applicant_Recruiting_Data_DE.xml
│   └── ... (110 more SITs)
│
└── README.md                             # This file
```

---

## Prerequisites

### Required Permissions
- Microsoft 365 tenant with Purview licensing
- Compliance Administrator role (or equivalent)

### PowerShell Requirements
```powershell
# Install ExchangeOnlineManagement module
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# Import module
Import-Module ExchangeOnlineManagement

# Connect to Security & Compliance Center
Connect-IPPSSession
```

---

## Usage

### Step 1: Generate XML Files

Generate all 112 SIT XML files from keyword sources:

```powershell
.\scripts\Generate-SIT-XML-Files.ps1
```

Output location: `SIT_XML_Export\`

### Step 2: Validate (Dry Run)

Test upload without making changes:

```powershell
.\scripts\Upload-Individual-SITs.ps1 -DryRun
```

### Step 3: Upload SITs

**Upload all SITs:**
```powershell
.\scripts\Upload-Individual-SITs.ps1
```

**Upload by language:**
```powershell
# English only
.\scripts\Upload-Individual-SITs.ps1 -Language EN

# Multiple languages
.\scripts\Upload-Individual-SITs.ps1 -Language EN,DE
```

**Upload by category:**
```powershell
# Specific category
.\scripts\Upload-Individual-SITs.ps1 -Category "Applicant_Recruiting_Data"

# Wildcard matching
.\scripts\Upload-Individual-SITs.ps1 -Category "*Salary*"
```

**Upload specific SIT:**
```powershell
.\scripts\Upload-Individual-SITs.ps1 -SITName "Applicant_Recruiting_Data_EN"
```

**Combine filters:**
```powershell
# HR categories in German and French
.\scripts\Upload-Individual-SITs.ps1 -Category "*Banking*","*Salary*" -Language DE,FR
```

---

## Customization

### Adding Keywords

1. Navigate to keyword source file:
   ```
   HR/bv_Category_Name/BV_CategoryName_Primary_EN.txt
   ```

2. Add keywords (one per line):
   ```
   New Keyword Term
   Another Term
   ```

3. Regenerate XML:
   ```powershell
   .\scripts\Generate-SIT-XML-Files.ps1
   ```

### Keyword File Types

- **Primary:** Core terms that trigger detection (required)
- **Context:** Supporting evidence for higher confidence (optional)

### Naming Convention

Files follow the pattern:
```
BV_CategoryAbbreviation_Type_LanguageCode.txt

Examples:
BV_ApplicantRecruit_Primary_EN.txt
BV_Salary_Context_DE.txt
```

---

## Verification

### View Uploaded SITs

1. Navigate to Microsoft Purview portal:
   ```
   https://purview.microsoft.com
   ```

2. Go to: **Information Protection > Classifiers > Sensitive info types**

3. Filter by publisher: **PurviewInsights SIT**

### Test Detection

Use the built-in test feature in Purview portal:
1. Select a custom SIT
2. Click "Test"
3. Paste sample text containing keywords
4. Verify detection and confidence levels

---

## Troubleshooting

### Common Issues

**Error: XML schema validation failed**
- Ensure XML files were regenerated after keyword changes
- Verify UTF-8 encoding is preserved

**Error: Module not found**
```powershell
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
```

**Error: Permission denied**
- Verify Compliance Administrator role assignment
- Re-authenticate: `Connect-IPPSSession`

**Error: SIT already exists**
- Upload script automatically skips duplicates
- To update: Delete existing SIT in portal, then re-upload

### Regeneration

If XML files become corrupted or need updates:

```powershell
# Clean output directory
Remove-Item .\SIT_XML_Export\*.xml -Force

# Regenerate all files
.\scripts\Generate-SIT-XML-Files.ps1
```

---

## Limitations

### Microsoft Purview Limits
- Maximum 500 custom SITs per tenant
- Maximum 2,048 keywords per SIT
- Maximum 50 characters per keyword term
- Maximum 10 rule packages per tenant (this project uses 112 individual rule packages)

### Current Project Stats
- SITs: 112 / 500 (22% of tenant limit)
- Keywords per SIT: 10-43 / 2,048 (2% average usage)
- Languages: 4 supported

---

## XML Structure Reference

Example SIT structure (simplified):

```xml
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2011/mce">
  <RulePack id="[GUID]">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="00000000-0000-0000-0000-000000000000" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>PurviewInsights SIT</PublisherName>
        <Name>Applicant_Recruiting_Data_EN</Name>
        <Description>Applicant Recruiting Data - English</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  
  <Rules>
    <Entity id="[GUID]" patternsProximity="300" recommendedConfidence="85">
      <!-- Pattern 1: High Confidence (85%) -->
      <Pattern confidenceLevel="85">
        <IdMatch idRef="Keyword_Primary_Applicant_Recruiting_Data_EN" />
        <Match idRef="Keyword_Context_Applicant_Recruiting_Data_EN" />
      </Pattern>
      
      <!-- Pattern 2: Medium Confidence (75%) -->
      <Pattern confidenceLevel="75">
        <IdMatch idRef="Keyword_Primary_Applicant_Recruiting_Data_EN" />
      </Pattern>
    </Entity>
    
    <!-- Keyword Definitions -->
    <Keyword id="Keyword_Primary_Applicant_Recruiting_Data_EN">
      <Group matchStyle="word">
        <Term>Application</Term>
        <Term>Curriculum Vitae</Term>
        <Term>CV</Term>
        <Term>Resume</Term>
        <!-- ... more terms -->
      </Group>
    </Keyword>
    
    <Keyword id="Keyword_Context_Applicant_Recruiting_Data_EN">
      <Group matchStyle="word">
        <Term>Job Posting</Term>
        <Term>Recruitment</Term>
        <!-- ... more terms -->
      </Group>
    </Keyword>
    
    <LocalizedStrings>
      <Resource idRef="[Entity GUID]">
        <Name default="true" langcode="en-us">Applicant_Recruiting_Data_EN</Name>
        <Description default="true" langcode="en-us">Applicant Recruiting Data - English</Description>
      </Resource>
    </LocalizedStrings>
  </Rules>
</RulePackage>
```

---

## Script Reference

### Generate-SIT-XML-Files.ps1

**Purpose:** Generate XML files from keyword sources

**Parameters:** None

**Output:**
- 112 XML files in `SIT_XML_Export/`
- Summary report: `SIT_XML_Export/SIT_Generation_Summary.txt`

**Process:**
1. Scans HR/ and LEGAL/ directories
2. Reads keyword files (UTF-8 encoding)
3. Generates unique GUIDs for each SIT
4. Creates XML with multi-pattern structure
5. Validates XML well-formedness

### Upload-Individual-SITs.ps1

**Purpose:** Upload SIT XML files to Microsoft 365 tenant

**Parameters:**
```powershell
-InputPath      # XML files location (default: .\SIT_XML_Export)
-DryRun         # Validate without uploading
-Category       # Filter by category name (supports wildcards)
-Language       # Filter by language: EN, DE, FR, ES
-SITName        # Upload specific SIT (supports wildcards)
```

**Process:**
1. Discovers and filters XML files
2. Validates XML structure
3. Connects to Security & Compliance Center
4. Uploads via New-DlpSensitiveInformationTypeRulePackage
5. Reports success/skipped/failed counts

**Error Handling:**
- Skips duplicate SITs automatically
- Includes 500ms throttling delay
- Detailed error reporting

---

## Best Practices

### Keyword Management
- Keep terms concise (under 50 characters)
- Use specific terms to reduce false positives
- Add context keywords to improve accuracy
- Test detection with sample documents

### Upload Strategy
1. Start with dry run: `-DryRun`
2. Upload one language first for testing: `-Language EN`
3. Verify detection in Purview portal
4. Deploy remaining languages

### Maintenance
- Review detection accuracy quarterly
- Add new terms as business needs evolve
- Remove obsolete keywords
- Regenerate XMLs after keyword changes

---

## License

This project is provided as-is for Microsoft Purview implementations.

---

## Support

For issues or questions related to:
- **Microsoft Purview:** [Microsoft Support](https://learn.microsoft.com/en-us/purview/)
- **Custom SITs:** [Microsoft Documentation](https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type-in-scc-powershell)
- **This Project:** Review documentation and script comments

---

## Version History

**Version 1.0**
- Initial release with 112 SITs
- 28 categories across HR and Legal domains
- 4 languages: EN, DE, FR, ES
- Multi-pattern detection (85% and 75% confidence)
- Automated generation and upload scripts

---

**Created by:** Iohann Gessenay  
**Last Updated:** December 3, 2025
