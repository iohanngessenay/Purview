# bv_Non_Disclosure_Agreement_NDA

**Purpose:** Detects NDA documents and clauses establishing confidentiality obligations.
**Detection Logic:** Title/header emphasis for NDA terms; proximity of multiple confidentiality terms in body.
**Typical Examples:** Signed NDAs, NDA templates, confidentiality undertakings in contracts.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)