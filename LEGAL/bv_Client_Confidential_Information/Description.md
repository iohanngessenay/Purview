# bv_Client_Confidential_Information

**Purpose:** Detects client-privileged or confidential legal communications and materials.
**Detection Logic:** Header/footer privilege notices, or ≥2 primary terms + context within proximity.
**Typical Examples:** Attorney–client emails, privileged memos, client deliverables marked confidential.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)