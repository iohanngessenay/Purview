# Compliance_Investigations

**Purpose:** Detects confidential internal investigation records and ethics case materials.
**Detection Logic:** ≥2 investigation terms or presence with compliance/discipline context.
**Typical Examples:** Whistleblower reports, interview notes, findings.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)