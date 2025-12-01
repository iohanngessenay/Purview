# bv_Regulatory_and_Compliance_References

**Purpose:** Detects references to laws, standards and supervisory frameworks with compliance context.
**Detection Logic:** Framework acronym + compliance context within ~100 chars, or multiple frameworks.
**Typical Examples:** Compliance reports, audit findings, regulatory assessments.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)