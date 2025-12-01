# Expense_or_Reimbursement_Records

**Purpose:** Detects expense and reimbursement documents containing amounts or expense terminology.
**Detection Logic:** Currency regex + ≥2 expense terms; or ≥2 expense terms without amount.
**Typical Examples:** Expense spreadsheets, scanned receipts, reimbursement emails.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)