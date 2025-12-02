# Purview Upload Guide

## Microsoft Purview Limits (Official Documentation)

### Critical Limits
**Keyword Dictionaries**:
- **1MB total** for all dictionaries combined (post-compression)
- **Maximum 50 SITs** that use keyword dictionaries
- **Dictionaries can be REUSED** across multiple SITs

### Your Setup: Shared Dictionary Architecture

**24 shared dictionaries** (~30KB total) in `Purview_Shared_Dictionaries/`:
- HR_Primary_EN/DE/FR/ES (4 dictionaries)
- HR_Context_EN/DE/FR/ES (4 dictionaries)
- HR_Regex_EN/DE/FR/ES (4 dictionaries)
- LEGAL_Primary_EN/DE/FR/ES (4 dictionaries)
- LEGAL_Context_EN/DE/FR/ES (4 dictionaries)
- LEGAL_Regex_EN/DE/FR/ES (4 dictionaries)

**28 SITs** (12 HR + 16 LEGAL) - each references the shared dictionaries above
- Well within the 50 SIT limit

---

## Upload to Microsoft Purview

### Prerequisites

```powershell
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
```

**Required Role**: Global Administrator or Compliance Administrator

### Upload Dictionaries

```powershell
# Preview first (dry run)
.\scripts\Upload-Shared-Dictionaries.ps1 -DryRun

# Upload to your tenant
.\scripts\Upload-Shared-Dictionaries.ps1
```

This uploads all 24 dictionary files from `Purview_Shared_Dictionaries/` to your tenant.

---

## Maintaining Dictionaries

To add/update terms:

1. **Edit the dictionary files directly** in `Purview_Shared_Dictionaries/`
   - Example: Add new HR primary terms to `HR_Primary_EN.txt`
2. **Re-upload** using the upload script
3. **Purview automatically updates** all SITs that reference that dictionary

**No regeneration needed** - dictionary files are your source of truth!

## Step 3: Create SITs in Purview Portal

1. Navigate to: [Microsoft Purview Portal](https://purview.microsoft.com)
2. Go to: **Information Protection** > **Classifiers** > **Sensitive info types**
3. Click: **Create sensitive info type**

### Example: HR_ApplicantRecruiting SIT

**Name**: `HR_ApplicantRecruiting`

**Pattern 1 (High Confidence - 85%)**:
- **Primary Element**: Keyword Dictionary
  - Select: `HR_Primary_EN` OR `HR_Primary_DE` OR `HR_Primary_FR` OR `HR_Primary_ES`
- **Supporting Element**: Keyword Dictionary
  - Select: `HR_Context_EN` OR `HR_Context_DE` OR `HR_Context_FR` OR `HR_Context_ES`
- **Character Proximity**: 300
- **Confidence Level**: High (85%)

**Pattern 2 (Medium Confidence - 65%)**:
- **Primary Element**: Same as above (HR_Primary_*)
- **No supporting elements**
- **Confidence Level**: Medium (65%)

### Repeat for All 28 SITs

**HR SITs (12)**:
- HR_ApplicantRecruiting
- HR_BankingPayment
- HR_DisciplinaryRecords
- HR_EmergencyContact
- HR_EmployeeContract
- HR_ExpenseReimbursement
- HR_IDPassport
- HR_MedicalHealth
- HR_PerformanceReview
- HR_SalaryCompensation
- HR_SwissAHV
- HR_TrainingCertification

**LEGAL SITs (16)**:
- LEGAL_BoardGovernance
- LEGAL_ClientConfidential
- LEGAL_ComplianceInvestigations
- LEGAL_ContractAgreement
- LEGAL_CourtCase
- LEGAL_DataProcessingAgreement
- LEGAL_IntellectualProperty
- LEGAL_LitigationFiles
- LEGAL_LegalInvoice
- LEGAL_LegalOpinion
- LEGAL_MergersAcquisitions
- LEGAL_NDA
- LEGAL_RegulatoryCompliance
- LEGAL_RegulatoryFilings
- LEGAL_SanctionsExport
- LEGAL_Whistleblower

---

## Testing

After creating SITs:

1. Go to: **Information Protection** > **Classifiers** > **Sensitive info types**
2. Find your custom SIT
3. Click: **Test**
4. Upload sample documents or paste sample text
5. Verify detection accuracy

---

## Summary

✅ **24 shared dictionaries** uploaded once  
✅ **28 custom SITs** created (each references shared dictionaries)  
✅ **Well within limits**: 28/50 SITs, 30KB/1024KB size  
✅ **Multilingual**: EN, DE, FR, ES support  
✅ **Scalable**: Easy to add more SITs using existing dictionaries

## Critical Limits & Best Practices (Microsoft Learn)

### Tenant-Wide Limits
⚠️ **IMPORTANT**: All keyword dictionaries in your tenant combined must be < 1MB (post-compression)
- **Your current export**: 29KB (260 dictionaries) ✅ Well within limit
- **Headroom remaining**: ~970KB for growth

### Per-Dictionary Best Practices
✅ **DO**:
- Keep dictionaries focused and specific to one SIT + one language
- Use .txt files with one term per line (Unicode encoding)
- Reuse dictionaries across multiple SITs when possible
- Test with sample data before full deployment

❌ **AVOID**:
- Mixing languages in one dictionary (create separate dictionaries)
- Including confidential/sensitive data in dictionary names
- Very short terms (< 3 characters) - increases false positives
- Purely numeric terms
- Terms with repeated characters (AAA, 111)

### Why Keyword Dictionaries for Your SITs?

| Feature | Keyword List | Keyword Dictionary ✅ |
|---------|-------------|-------------------|
| **Max Terms** | 2,048 | ~1,000,000 chars |
| **Max Term Length** | 50 characters | Unlimited |
| **Tenant Limit** | N/A | 1MB total |
| **Management** | UI or PowerShell XML | Upload .txt/.csv |
| **Reusability** | Per SIT | Across multiple SITs |
| **Multi-language** | Limited | Excellent |

**Your scenario**: 28 SITs × 4 languages × 2-3 term types = Perfect for dictionaries

## Dictionary Naming Convention

All dictionaries uploaded to Purview follow this naming format:
```
{Category}_{SITName}_{Language}_{Type}
```

**Examples**:
- `HR_ApplicantRecruiting_EN_Context`
- `HR_ApplicantRecruiting_EN_Primary`
- `LEGAL_BoardGovernance_DE_Context`
- `LEGAL_ClientConfidential_FR_Primary`
- `HR_SalaryCompensation_ES_Regex`

**Benefits**:
- ✅ Clear identification of SIT category (HR/LEGAL)
- ✅ Readable SIT name (PascalCase)
- ✅ Language indicator (EN/DE/FR/ES)
- ✅ Term type (Context/Primary/Regex)
- ✅ No naming conflicts across 260+ dictionaries

## Uploading to Microsoft Purview

### Step 1: Automated Upload (Recommended)

Use the automated script to upload all 260+ dictionaries directly from your SIT folders:

```powershell
# Preview what will be uploaded (dry run)
.\scripts\Upload-To-Purview.ps1 -TenantId "your-tenant-id" -DryRun

# Upload all dictionaries to your tenant
.\scripts\Upload-To-Purview.ps1 -TenantId "your-tenant-id"
```

**What it does**:
- ✅ Scans all HR and LEGAL SIT folders
- ✅ Generates proper dictionary names automatically
- ✅ Validates total size against 1MB limit
- ✅ Uploads all dictionaries with progress tracking
- ✅ Handles throttling and errors gracefully
- ✅ Provides detailed upload summary

**Prerequisites**:
```powershell
# Install Exchange Online Management module (one-time)
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
```

**Required Role**: Global Administrator or Compliance Administrator

---

### Step 2: Create SITs in Purview Portal

1. **Navigate to**: [Microsoft Purview Portal](https://purview.microsoft.com)
2. **Go to**: Information Protection > Classifiers > Sensitive info types
3. **Click**: Create sensitive info type

### Step 3: For Each SIT (e.g., HR_ApplicantRecruiting)

After uploading dictionaries, create SITs that reference them:

#### Option A: Single Multi-Language SIT (Recommended)
Create ONE SIT that detects all languages:

**Name**: `HR_ApplicantRecruiting_MultiLang`

**Pattern 1 (High Confidence)**:
- Primary Element: Keyword Dictionary
  - Select: `HR_ApplicantRecruiting_EN_Primary`
  - **OR** `HR_ApplicantRecruiting_DE_Primary`
  - **OR** `HR_ApplicantRecruiting_FR_Primary`
  - **OR** `HR_ApplicantRecruiting_ES_Primary`
- Supporting Element: Keyword Dictionary
  - Select corresponding context dictionaries
- Character Proximity: 300
- Confidence Level: High (85%)

**Pattern 2 (Medium Confidence)**:
- Primary Element: Same dictionaries as above
- No supporting elements
- Confidence Level: Medium (65%)

#### Option B: Separate SIT Per Language
Create 4 SITs:
- `HR_ApplicantRecruiting_EN`
- `HR_ApplicantRecruiting_DE`
- `HR_ApplicantRecruiting_FR`
- `HR_ApplicantRecruiting_ES`

---

### Manual Upload (Alternative)

If you prefer manual upload via the portal:

1. **Navigate to**: [Microsoft Purview Portal](https://purview.microsoft.com)
2. **Go to**: Data Classification > Classifiers > Keyword dictionaries
3. **Click**: Create keyword dictionary
4. Upload `.txt` files from your SIT folders directly:
   - `.\HR\Applicant_Recruiting_Data\en\context.txt` → Name as `HR_ApplicantRecruiting_EN_Context`
   - `.\HR\Applicant_Recruiting_Data\en\primary.txt` → Name as `HR_ApplicantRecruiting_EN_Primary`
   - etc.

---

### PowerShell Manual Upload (Advanced)

For individual dictionary uploads:

```powershell
# Connect to Security & Compliance Center
Connect-IPPSSession

# Upload a single dictionary
$filePath = ".\HR\Applicant_Recruiting_Data\en\context.txt"
$dictionaryName = "HR_ApplicantRecruiting_EN_Context"
New-DlpKeywordDictionary -Name $dictionaryName -FileData ([System.IO.File]::ReadAllBytes($filePath))

# Get the dictionary GUID for verification
Get-DlpKeywordDictionary -Name $dictionaryName
```

## Best Practices

### Naming Convention
- **SIT Name**: `{Category}_{SIT_Name}_{Language}` (if separate)
- **Dictionary Name**: `{SIT_Name}_{Lang}_{Type}` 
  - Example: `Applicant_Recruiting_Data_en_primary`

### Confidence Levels
Based on your Description.md files:
- **High (85%)**: ≥2 primary terms + context term within proximity
- **Medium (65%)**: ≥2 primary terms OR looser pattern  
- **Low (40%)**: Single primary term in title/header/body

### Character Proximity
- Recommended: **300 characters**
- Adjustable based on testing

### Instance Count
- **Min**: 1
- **Max**: 500 (or "Any" for unlimited)

## Limits to Watch

| Limit | Value |
|-------|-------|
| Custom SITs (Portal) | 500 |
| Keyword Dictionary Size (Tenant) | 1MB post-compression |
| Keyword Dictionary-based SITs | 50 per tenant |
| Terms in Keyword List | 2,048 |
| Rule Packages | 10 |

## Testing Your SITs

1. **Portal**: Use the built-in test feature
   - Upload sample documents
   - Verify detection and confidence levels

2. **DLP Policy**: Create test policy
   - Apply to small set of users
   - Monitor incidents
   - Adjust patterns as needed

## Automation Opportunities

1. **PowerShell Script**: Batch create all SITs
2. **API Integration**: Automate dictionary updates
3. **CI/CD Pipeline**: Version control + auto-deploy changes

## Next Steps

1. Run export script
2. Review generated dictionary files
3. Create 1-2 SITs as proof of concept
4. Test with sample documents
5. Refine patterns based on results
6. Scale to remaining SITs

---

## Questions to Consider

1. **Do you want one multi-language SIT or separate per language?**
   - Multi-language: Easier management, one policy rule
   - Separate: More granular control, language-specific thresholds

2. **What confidence thresholds matter for your compliance?**
   - Adjust based on false positive tolerance

3. **Will you use DLP, Information Protection, or both?**
   - Determines policy configuration approach
