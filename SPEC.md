
## Project
**Name:** GtSpecSet-Parser  
**Goal:** A GT input parser that splits a “master” Markdown file into four files — `SPEC.md`, `IMPLEMENTATION_PLAN.md`, `RESEARCH.md`, `WORKLOG.md` — using strict H1 markers.

## Scope
- **In:** class-side adapter `GtSpecSetMarkdownParserAdapter` with `priority`, `matches:`, `parse:`; model `GtSpecSetSplitResult` with idempotent writer; Baseline; examples + tests; optional registry hook.
- **Out (v1):** front-matter handling, mixed case headings, non-Markdown inputs, GUI authoring.

## Rules
- Headings must be exactly:
  - `# SPEC`
  - `# IMPLEMENTATION_PLAN`
  - `# RESEARCH`
  - `# WORKLOG`
- Parsing is line-based; the adapter builds a parts dictionary and writes only when content changes.

## Acceptance Criteria
- Given a master file with those four H1s, `parse:` returns a `GtSpecSetSplitResult` whose `parts` has keys `#SPEC`, `#IMPLEMENTATION_PLAN`, `#RESEARCH`, `#WORKLOG`.
- `writeFilesIn:` creates/updates the four files **idempotently**.
- `matches:` returns true only for `.md|.markdown` files that contain at least one valid H1.
- Examples run green in GT; tests pass in CI.
- Baseline loads `Model` then `Parser`.

## Non-Goals / Risks
- Non-goal: content validation beyond section presence.
- Risks: malformed masters; polluted `parts`; registry differences across GT images (guarded registration).
