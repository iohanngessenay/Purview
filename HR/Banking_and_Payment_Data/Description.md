# Banking_and_Payment_Data

**Purpose:** Detects banking details in HR context such as IBAN or salary account information.
**Detection Logic:** IBAN regex plus banking keywords in proximity; or IBAN alone for medium confidence.
**Typical Examples:** Bank details forms, payroll bank exports, account change requests.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)