# Emergency_Contact_Information

**Purpose:** Detects emergency contact details stored in HR records.
**Detection Logic:** ≥2 emergency/personal contact terms; or 1 + HR folder context.
**Typical Examples:** Employee master data sheets, contact forms, onboarding packs.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)