# Data_Processing_Agreements_DPA

**Purpose:** Detects DPAs and data protection addenda defining controller/processor roles.
**Detection Logic:** Primary DPA terms + role/context terms in proximity.
**Typical Examples:** Signed DPAs, SCC annexes, TOMs.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)