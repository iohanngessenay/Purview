# bv_Disciplinary_or_Legal_Records

**Purpose:** Detects disciplinary case materials and HR legal records.
**Detection Logic:** ≥3 disciplinary terms or ≥2 with HR/legal context.
**Typical Examples:** Warning letters, termination letters, PIP documentation.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)