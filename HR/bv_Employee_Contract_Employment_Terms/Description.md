# bv_Employee_Contract_Employment_Terms

**Purpose:** Detects employment contracts and key terms of employment.
**Detection Logic:** Keyword proximity: ≥3 primary terms within ~100 chars, or ≥2 primary + ≥1 HR context term.
**Typical Examples:** Contracts, addenda, probation/notice letters.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)