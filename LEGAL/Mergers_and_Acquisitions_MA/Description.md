# Mergers_and_Acquisitions_MA

**Purpose:** Detects sensitive M&A content across strategy, legal and finance workstreams.
**Detection Logic:** Keywords for deals with emphasis on 'Due Diligence' + M&A terms proximity.
**Typical Examples:** CIMs, SPA drafts, valuation models, data room exports.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)