# bv_Sanctions_Export_Control_References

**Purpose:** Detects sanctions and export control references, lists and screening outputs.
**Detection Logic:** ≥2 sanctions terms or primary + compliance context within proximity.
**Typical Examples:** Screening results, embargo notices, licensing docs.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)