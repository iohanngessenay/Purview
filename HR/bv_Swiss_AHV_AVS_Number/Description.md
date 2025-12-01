# bv_Swiss_AHV_AVS_Number

**Purpose:** Detects Swiss social insurance numbers within HR files and communications.
**Detection Logic:** Regex for AHV/AVS number combined with HR/identity context terms for precision.
**Typical Examples:** Contracts, payroll exports, ID scans, onboarding forms.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)