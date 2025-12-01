# bv_Medical_or_Health_Information

**Purpose:** Detects HR-managed medical information and sickness documentation.
**Detection Logic:** ≥2 health terms + HR context; or 1 health + 1 context.
**Typical Examples:** Sick notes, occupational health letters, medical reports in HR files.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)