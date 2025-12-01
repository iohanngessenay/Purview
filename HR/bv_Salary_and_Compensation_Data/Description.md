# bv_Salary_and_Compensation_Data

**Purpose:** Detects payroll and salary-related data including amounts and remuneration terminology.
**Detection Logic:** Currency regex + compensation keywords; or ≥2 salary keywords in proximity.
**Typical Examples:** Pay slips, salary reviews, bonus plans, payroll exports.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)