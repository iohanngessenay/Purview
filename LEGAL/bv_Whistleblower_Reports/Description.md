# bv_Whistleblower_Reports

**Purpose:** Detects whistleblowing and ethics intake materials containing sensitive allegations.
**Detection Logic:** ≥2 primary terms or presence with investigation/confidential context.
**Typical Examples:** Hotline submissions, case summaries, retaliation notices.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)