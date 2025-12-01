# bv_Board_or_Corporate_Governance_Documents

**Purpose:** Detects board-level documents such as minutes, resolutions and corporate statutes.
**Detection Logic:** ≥3 governance terms in proximity or title + body combination.
**Typical Examples:** Board packs, resolutions, articles, bylaws.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)