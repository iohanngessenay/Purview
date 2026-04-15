# Purview Custom SIT Toolkit

A collection of **multilingual keyword definitions** and **PowerShell scripts** for generating and uploading custom [Sensitive Information Types (SITs)](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions) to **Microsoft Purview**.

Covers **40 categories** across HR, Legal, Finance, and IT Security domains in **6 languages** (English, German, French, Spanish, Italian, Portuguese).

## Why This Exists

Microsoft Purview ships with many built-in SITs (credit card numbers, SSNs, etc.), but offers limited coverage for **domain-specific** document classification — things like salary records, NDAs, litigation files, or recruiting data. This toolkit fills that gap with curated keyword lists and ready-to-import XML rule packages.

## SIT Categories

### HR (12)

| Category | Description |
|---|---|
| Applicant Recruiting Data | CVs, cover letters, interview notes, candidate profiles |
| Banking and Payment Data | Employee bank details, payment information |
| Disciplinary or Legal Records | Warnings, disciplinary actions, employee legal records |
| Emergency Contact Information | Emergency contacts on file for employees |
| Employee Contract / Employment Terms | Employment contracts, terms of engagement |
| Expense or Reimbursement Records | Expense reports, reimbursement claims |
| ID or Passport Information | Identity documents, passport details |
| Medical or Health Information | Health records, medical certificates |
| Performance Review and Evaluation | Appraisals, performance assessments |
| Salary and Compensation Data | Payroll, salary, bonus information |
| Swiss AHV/AVS Number | Swiss social security numbers |
| Training and Certification Records | Training records, professional certifications |

### Legal (16)

| Category | Description |
|---|---|
| Board or Corporate Governance Documents | Board minutes, governance records |
| Client Confidential Information | Privileged client data |
| Compliance Investigations | Internal compliance reviews and investigations |
| Contract and Agreement Data | MSAs, SOWs, framework agreements, addenda |
| Court or Case Identifiers | Court docket numbers, case references |
| Data Processing Agreements (DPA) | GDPR/data processing agreements |
| Intellectual Property / Patent Data | Patents, IP filings, trade secrets |
| Legal Case / Litigation Files | Active litigation, legal proceedings |
| Legal Invoice / Billing | Legal fee invoices, billing records |
| Legal Opinion / Counsel Memorandum | Internal legal opinions, counsel memos |
| Mergers and Acquisitions (M&A) | M&A deal documents, due diligence |
| Non-Disclosure Agreement (NDA) | Confidentiality and non-disclosure agreements |
| Regulatory and Compliance References | Regulatory frameworks, compliance standards |
| Regulatory Filings / Submissions | Filings with regulatory authorities |
| Sanctions / Export Control References | Sanctions lists, export control data |
| Whistleblower Reports | Whistleblower submissions, anonymous reports |

### Finance (6)

| Category | Description |
|---|---|
| Audit Report Data | Internal/external audit reports, findings, opinions |
| Tax Filing Records | Tax returns, declarations, assessments, fiscal documents |
| Budget and Forecast Data | Budgets, forecasts, variance analysis, financial projections |
| Invoice and Purchase Order | Invoices, POs, procurement, accounts payable/receivable |
| Financial Statements | Balance sheets, P&L, cash flow, IFRS/GAAP reports |
| Credit and Loan Records | Loan agreements, credit facilities, debt instruments |

### IT Security (6)

| Category | Description |
|---|---|
| Credentials and Secrets | Passwords, API keys, tokens, certificates, private keys |
| Incident Report Data | Security incidents, breach reports, incident response |
| Vulnerability Assessment | Vulnerability scans, penetration tests, CVE/CVSS data |
| Network and Infrastructure Data | Network diagrams, IP schemes, firewall/server configs |
| Access Control Records | IAM, RBAC, permissions, privilege management, access reviews |
| Security Audit Logs | SIEM data, event logs, monitoring, audit trails |

## Repository Structure

```
├── HR/                          # 12 HR SIT categories
│   └── <Category>/
│       ├── Description.md       # Detection logic & confidence mapping
│       ├── en/                  # English keywords
│       │   ├── *_primary.txt    # Primary detection keywords
│       │   └── *_context.txt    # Contextual/corroborating keywords
│       ├── de/                  # German
│       ├── fr/                  # French
│       ├── es/                  # Spanish
│       ├── it/                  # Italian
│       └── pt/                  # Portuguese
├── LEGAL/                       # 16 Legal SIT categories (same structure)
├── FINANCE/                     # 6 Finance SIT categories (same structure)
├── IT_SECURITY/                 # 6 IT Security SIT categories (same structure)
└── scripts/
    ├── Generate-SIT-XML-Files.ps1              # Per-language individual XML files
    ├── Generate-Multilingual-SIT-XML-Files.ps1 # Multilingual XML (one SIT per category)
    ├── Generate-Combined-SIT-XML.ps1           # Single XML with all 40 SITs combined
    ├── Upload-Individual-SITs.ps1              # Upload individual XMLs to tenant
    └── Upload-SITs-From-Folder.ps1             # Upload all XMLs from a folder
```

## Getting Started

### Prerequisites

- **PowerShell 5.1+** (Windows) or **PowerShell 7+** (cross-platform)
- **[ExchangeOnlineManagement](https://www.powershellgallery.com/packages/ExchangeOnlineManagement)** module (for uploading to tenant)
- **Compliance Administrator** role (or equivalent) in your Microsoft 365 tenant

```powershell
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
```

### Generate SIT XML Files

**Option 1 — Combined (recommended):** All 40 SITs in a single rule package XML. This is the preferred approach since Microsoft limits tenants to **10 custom rule packages**.

```powershell
.\scripts\Generate-Combined-SIT-XML.ps1
```

**Option 2 — Multilingual per-category:** One XML per category with keywords from selected languages merged into a single SIT.

```powershell
.\scripts\Generate-Multilingual-SIT-XML-Files.ps1
```

**Option 3 — Individual per-language:** Separate XML files per category and language (up to 240 files).

```powershell
.\scripts\Generate-SIT-XML-Files.ps1
```

### Upload to Microsoft Purview

Upload the generated XML to your tenant:

```powershell
# Upload from default folder
.\scripts\Upload-SITs-From-Folder.ps1

# Dry run (validate without uploading)
.\scripts\Upload-SITs-From-Folder.ps1 -DryRun

# Upload individual SITs with filters
.\scripts\Upload-Individual-SITs.ps1 -Language EN -Category "*Salary*"
```

## Customization

### Adding Keywords

Edit the `*_primary.txt` and `*_context.txt` files in the appropriate language folder. One keyword or phrase per line.

### Adding a Language

Create a new language subfolder (e.g., `pt/`) under each category with `*_primary.txt` and `*_context.txt` files, then update the scripts' language validation sets.

### Adding a Category

Create a new folder under `HR/` or `LEGAL/` following the existing structure. The scripts auto-discover categories from the directory layout.

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome — whether it's new categories, additional languages, keyword improvements, or bug fixes. Please open an issue or submit a pull request.
