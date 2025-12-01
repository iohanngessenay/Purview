# bv_Legal_Invoice_Billing

**Purpose:** Detects legal invoices and billing references tied to matters or retainers.
**Detection Logic:** Regex for invoice numbering + law billing context.
**Typical Examples:** PDF invoices, billing summaries, matter statements.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)