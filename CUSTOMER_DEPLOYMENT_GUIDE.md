# Microsoft Purview Custom SITs - Deployment Guide

## Overview

This package contains **112 custom Sensitive Information Types (SITs)** for Microsoft Purview, organized by:
- **28 categories** (12 HR + 16 LEGAL)
- **4 languages** (English, German, French, Spanish)
- **Self-contained XML files** with inline keyword lists

Each SIT is independently importable, allowing you to deploy only the categories and languages your organization needs.

## What's Included

### HR Categories (12)
- Applicant_Recruiting_Data
- Banking_and_Payment_Data
- Disciplinary_or_Legal_Records
- Emergency_Contact_Information
- Employee_Contract_Employment_Terms
- Expense_or_Reimbursement_Records
- ID_or_Passport_Information
- Medical_or_Health_Information
- Performance_Review_and_Evaluation
- Salary_and_Compensation_Data
- Swiss_AHV_AVS_Number
- Training_and_Certification_Records

### LEGAL Categories (16)
- Board_or_Corporate_Governance_Documents
- Client_Confidential_Information
- Compliance_Investigations
- Contract_and_Agreement_Data
- Court_or_Case_Identifiers
- Data_Processing_Agreements_DPA
- Intellectual_Property_Patent_Data
- Legal_Case_Litigation_Files
- Legal_Invoice_Billing
- Legal_Opinion_Counsel_Memorandum
- Mergers_and_Acquisitions_MA
- Non_Disclosure_Agreement_NDA
- Regulatory_and_Compliance_References
- Regulatory_Filings_Submissions
- Sanctions_Export_Control_References
- Whistleblower_Reports

### Languages
- **EN** - English
- **DE** - German (Deutsch)
- **FR** - French (Français)
- **ES** - Spanish (Español)

## SIT Naming Convention

Each XML file is named: `{Category}_{Language}.xml`

**Examples:**
- `Applicant_Recruiting_Data_EN.xml` - English
- `Salary_and_Compensation_Data_DE.xml` - German
- `Client_Confidential_Information_FR.xml` - French
- `Contract_and_Agreement_Data_ES.xml` - Spanish

## Prerequisites

### Permissions
You must have one of the following roles:
- Compliance Administrator
- Compliance Data Administrator
- Security Administrator
- Organization Management

### PowerShell Requirements
```powershell
# Install ExchangeOnlineManagement module
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# Import the module
Import-Module ExchangeOnlineManagement
```

### Tenant Limits
- **Maximum custom SITs:** 500 per tenant
- **This package:** 112 SITs (22% of limit)
- **Recommended:** Deploy only categories and languages you need

## Deployment Options

### Option 1: Automated Upload (PowerShell Script)

**Upload ALL SITs:**
```powershell
.\Upload-Individual-SITs.ps1
```

**Upload by Language:**
```powershell
# English only
.\Upload-Individual-SITs.ps1 -Language EN

# English and German
.\Upload-Individual-SITs.ps1 -Language EN,DE
```

**Upload by Category:**
```powershell
# All Salary-related SITs
.\Upload-Individual-SITs.ps1 -Category "*Salary*"

# All HR SITs (English)
.\Upload-Individual-SITs.ps1 -Category "*" -Language EN | Where-Object { $_ -like "HR/*" }
```

**Upload Specific SITs:**
```powershell
.\Upload-Individual-SITs.ps1 -SITName "Applicant_Recruiting_Data_EN"
```

**Dry Run (Test Without Uploading):**
```powershell
.\Upload-Individual-SITs.ps1 -DryRun
```

### Option 2: Manual Portal Upload

1. **Sign in to Microsoft Purview portal:**
   - Navigate to: https://purview.microsoft.com
   - Go to: **Information Protection** > **Classifiers** > **Sensitive info types**

2. **Import SIT:**
   - Click **Import sensitive info type**
   - Browse and select the XML file(s) you want to import
   - Click **Import**

3. **Verify Import:**
   - The new SIT(s) will appear in the list
   - Publisher will show as "Custom SIT Provider"

### Option 3: PowerShell Manual Upload

```powershell
# Connect to Security & Compliance Center
Connect-IPPSSession

# Upload a single SIT
$xmlPath = "C:\Path\To\Applicant_Recruiting_Data_EN.xml"
[xml]$xmlContent = Get-Content $xmlPath -Raw
$rulePackageXml = $xmlContent.OuterXml
New-DlpSensitiveInformationTypeRulePackage -FileData ([System.Text.Encoding]::UTF8.GetBytes($rulePackageXml))

# Verify upload
Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }
```

## SIT Configuration Details

### Pattern Structure
Each SIT uses a **single pattern** with:
- **Primary Element:** Keyword list (10-40 terms)
- **Supporting Elements:** Context keywords + regex patterns (when available)
- **Character Proximity:** 300 characters
- **Confidence Level:**
  - **85%** - SITs with supporting elements
  - **75%** - SITs with primary keywords only

### Keyword Lists
- All keywords are **inline** (embedded in XML)
- No external dictionaries required
- Each SIT is completely self-contained
- Well within 2,048 term limit per SIT

### Detection Logic
```
IF primary keywords found (e.g., "recruitment", "candidate")
   AND (context keywords OR regex patterns) found within 300 characters
   THEN confidence = 85%
ELSE IF only primary keywords found
   THEN confidence = 75%
```

## Using SITs in DLP Policies

### Create a DLP Policy

1. **Navigate to Purview portal:**
   - **Information Protection** > **Policies** > **Data loss prevention**

2. **Create policy:**
   - Click **Create policy**
   - Choose **Custom** policy template

3. **Add SITs:**
   - In **Choose info to protect**, click **Add or remove sensitive info types**
   - Search for your custom SITs (e.g., "Applicant_Recruiting_Data_EN")
   - Set instance count and confidence level

4. **Configure actions:**
   - Block access
   - Send notifications
   - Create incident reports
   - Apply sensitivity labels

### Example Policy: Protect HR Data

**Scenario:** Prevent sharing of applicant and salary information externally

**Configuration:**
```
Policy Name: HR Data Protection - Recruitment and Compensation
Locations: Exchange, SharePoint, OneDrive, Teams
SITs:
  - Applicant_Recruiting_Data_EN (confidence: 85%, instances: 1-any)
  - Salary_and_Compensation_Data_EN (confidence: 85%, instances: 1-any)
Actions:
  - Block external sharing
  - Notify user
  - Alert compliance team
```

## SIT Management

### View Deployed SITs
```powershell
# List all custom SITs
Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" } | Format-Table Name, Publisher

# Count deployed SITs
(Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" }).Count

# View specific SIT details
Get-DlpSensitiveInformationType -Identity "Applicant_Recruiting_Data_EN"
```

### Update Existing SITs
```powershell
# Remove old version
Remove-DlpSensitiveInformationType -Identity "Applicant_Recruiting_Data_EN" -Confirm:$false

# Upload new version
.\Upload-Individual-SITs.ps1 -SITName "Applicant_Recruiting_Data_EN"
```

### Remove SITs
```powershell
# Remove single SIT
Remove-DlpSensitiveInformationType -Identity "Applicant_Recruiting_Data_EN" -Confirm:$false

# Remove all custom SITs (CAUTION!)
Get-DlpSensitiveInformationType | Where-Object { $_.Publisher -ne "Microsoft Corporation" } | Remove-DlpSensitiveInformationType -Confirm:$false
```

## Testing SITs

### Test SIT Detection

1. **Navigate to Purview portal:**
   - **Information Protection** > **Classifiers** > **Sensitive info types**

2. **Select SIT and click "Test":**
   - Paste sample text containing keywords
   - View detection results with confidence levels

3. **Example test content for Applicant_Recruiting_Data_EN:**
```
Subject: New Candidate Application - John Smith

We received a new application from John Smith for the Senior Developer position.

Candidate Details:
- Resume attached
- Cover letter included
- References: 3 professional contacts
- Recruiting source: LinkedIn

Please review and schedule an interview.
```

### Expected Results
- **Primary Match:** "application", "candidate", "resume"
- **Context Match:** "recruiting", "interview"
- **Confidence:** 85% (primary + context)

## Best Practices

### Selective Deployment
[OK] **Deploy only what you need**
- Choose relevant categories for your organization
- Select languages your users work with
- Avoid uploading all 112 SITs unless necessary

### Language Considerations
[OK] **Match SIT language to content language**
- Use EN SITs for English content
- Use DE SITs for German content
- Consider deploying multiple languages if you have multilingual content

### Testing Before Production
[OK] **Always test in non-production environment**
1. Deploy to test tenant first
2. Validate detection accuracy
3. Test DLP policies in audit mode
4. Monitor false positives/negatives

### Performance Optimization
[OK] **Minimize SIT count for better performance**
- Each active SIT consumes tenant resources
- Deploy 20-30 SITs maximum for optimal performance
- Remove unused SITs periodically

### Maintenance
[OK] **Regular review and updates**
- Review SIT effectiveness quarterly
- Update keywords based on false positives/negatives
- Remove SITs no longer needed
- Monitor tenant SIT limit (500 total)

## Troubleshooting

### Upload Errors

**Error: "Entity already exists"**
```powershell
# Remove existing SIT first
Remove-DlpSensitiveInformationType -Identity "SIT_Name" -Confirm:$false

# Re-upload
.\Upload-Individual-SITs.ps1 -SITName "SIT_Name"
```

**Error: "Insufficient permissions"**
```
Solution: Ensure you have Compliance Administrator role
Verify: Get-RoleGroupMember "Compliance Data Administrator"
```

**Error: "Maximum SITs exceeded"**
```
Current count: Get-DlpSensitiveInformationType | Measure-Object
Limit: 500 per tenant
Solution: Remove unused SITs to free capacity
```

### Detection Issues

**SIT not detecting expected content:**
1. Check keyword spelling and case sensitivity
2. Verify character proximity (300 chars)
3. Test with exact keywords from XML
4. Review confidence level threshold in policy

**Too many false positives:**
1. Increase confidence level requirement in DLP policy
2. Add more supporting elements (context keywords)
3. Increase instance count threshold
4. Consider using regex patterns for precision

**Too many false negatives:**
1. Lower confidence level requirement
2. Add more primary keywords
3. Decrease instance count threshold
4. Review and expand keyword list

## Support

### Microsoft Documentation
- [Sensitive Information Types](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-learn-about)
- [Create Custom SITs](https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type)
- [DLP Policies](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)

### PowerShell Cmdlets
- `Get-DlpSensitiveInformationType` - List SITs
- `New-DlpSensitiveInformationTypeRulePackage` - Upload SITs
- `Remove-DlpSensitiveInformationType` - Delete SITs
- `Get-DlpCompliancePolicy` - View DLP policies

### Limits and Quotas
- **Custom SITs per tenant:** 500
- **Terms per keyword list:** 2,048
- **Term max length:** 50 characters
- **Regex patterns per SIT:** 20
- **Rule packages:** 10
- **SITs per rule package:** 50

## Appendix: SIT List by Category

### HR SITs (48 total = 12 categories × 4 languages)
```
Applicant_Recruiting_Data_EN/DE/FR/ES
Banking_and_Payment_Data_EN/DE/FR/ES
Disciplinary_or_Legal_Records_EN/DE/FR/ES
Emergency_Contact_Information_EN/DE/FR/ES
Employee_Contract_Employment_Terms_EN/DE/FR/ES
Expense_or_Reimbursement_Records_EN/DE/FR/ES
ID_or_Passport_Information_EN/DE/FR/ES
Medical_or_Health_Information_EN/DE/FR/ES
Performance_Review_and_Evaluation_EN/DE/FR/ES
Salary_and_Compensation_Data_EN/DE/FR/ES
Swiss_AHV_AVS_Number_EN/DE/FR/ES
Training_and_Certification_Records_EN/DE/FR/ES
```

### LEGAL SITs (64 total = 16 categories × 4 languages)
```
Board_or_Corporate_Governance_Documents_EN/DE/FR/ES
Client_Confidential_Information_EN/DE/FR/ES
Compliance_Investigations_EN/DE/FR/ES
Contract_and_Agreement_Data_EN/DE/FR/ES
Court_or_Case_Identifiers_EN/DE/FR/ES
Data_Processing_Agreements_DPA_EN/DE/FR/ES
Intellectual_Property_Patent_Data_EN/DE/FR/ES
Legal_Case_Litigation_Files_EN/DE/FR/ES
Legal_Invoice_Billing_EN/DE/FR/ES
Legal_Opinion_Counsel_Memorandum_EN/DE/FR/ES
Mergers_and_Acquisitions_MA_EN/DE/FR/ES
Non_Disclosure_Agreement_NDA_EN/DE/FR/ES
Regulatory_and_Compliance_References_EN/DE/FR/ES
Regulatory_Filings_Submissions_EN/DE/FR/ES
Sanctions_Export_Control_References_EN/DE/FR/ES
Whistleblower_Reports_EN/DE/FR/ES
```

---

**Package Version:** 1.0  
**Generated:** December 2025  
**Total SITs:** 112 (12 HR + 16 LEGAL) × 4 languages  
**License:** See LICENSE file
