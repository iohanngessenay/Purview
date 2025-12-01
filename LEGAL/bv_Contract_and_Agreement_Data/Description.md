# bv_Contract_and_Agreement_Data

**Purpose:** Detects contracts, agreements and binding terms defining obligations between parties.
**Detection Logic:** Keyword proximity: ≥3 primary terms within ~100 chars, or ≥2 primary + ≥1 context term.
**Typical Examples:** MSA, SOW, framework agreements, addenda, termination clauses.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)