# Court_or_Case_Identifiers

**Purpose:** Detects formal court identifiers and case/docket references in legal materials.
**Detection Logic:** Regex for case/docket numbers combined with court/context terms for precision.
**Typical Examples:** Case captions, filings, judgments referencing official IDs.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)