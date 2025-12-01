# Legal_Opinion_Counsel_Memorandum

**Purpose:** Detects formal legal opinions or counsel memoranda prepared for clients or internal stakeholders.
**Detection Logic:** Primary opinion terms with legal context; title/header weighting for 'Legal Opinion'.
**Typical Examples:** Opinion letters, internal memos, advisory notes.

**Confidence Mapping (suggested):**
- High ≈ 85% — strict pattern / ≥2 primary + context term within proximity
- Medium ≈ 65% — ≥2 primary terms or looser pattern
- Low ≈ 40% — single primary term (title/header/body)