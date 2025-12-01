# Training_and_Certification_Records

**Purpose:** Detects employee training and certification documentation.
**Detection Logic:** ≥2 training terms; or 1 training term + context.
**Typical Examples:** Certificates, LMS exports, attendance lists.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)