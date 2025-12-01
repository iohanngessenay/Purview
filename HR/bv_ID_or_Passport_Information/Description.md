# bv_ID_or_Passport_Information

**Purpose:** Detects personal identification documents in HR archives and emails.
**Detection Logic:** Regex for typical ID/passport numbers + ID keywords in proximity.
**Typical Examples:** ID scans, work/residence permits for onboarding or visa management.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)