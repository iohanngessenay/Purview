# Legal_Case_Litigation_Files

**Purpose:** Detects materials related to disputes, court matters, arbitration or mediation.
**Detection Logic:** ≥2 primary terms + context within ~150 chars; or ≥2 primary terms in same paragraph.
**Typical Examples:** Statements of claim, court orders, settlement drafts, arbitration files.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)