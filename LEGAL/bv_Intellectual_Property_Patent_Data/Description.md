# bv_Intellectual_Property_Patent_Data

**Purpose:** Detects patent numbers and intellectual property references in R&D and legal documents.
**Detection Logic:** Regex for patent identifiers + IP keywords in proximity.
**Typical Examples:** Patent filings, invention disclosures, licensing docs.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)