# Regulatory_Filings_Submissions

**Purpose:** Detects references to formal filings/submissions to regulators or authorities.
**Detection Logic:** Regex for form/designations + filing numbers with filing context.
**Typical Examples:** SEC/FINMA filings, submissions, disclosures.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)