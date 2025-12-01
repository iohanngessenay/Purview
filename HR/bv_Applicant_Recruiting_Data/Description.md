# bv_Applicant_Recruiting_Data

**Purpose:** Detects recruiting and applicant-related documents and emails.
**Detection Logic:** ≥2 recruiting terms in proximity; or 1 in title + 1 in body.
**Typical Examples:** CVs, cover letters, interview notes, candidate profiles.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)