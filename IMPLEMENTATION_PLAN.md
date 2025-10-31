# IMPLEMENTATION_PLAN
# Implementation Plan — SPEC-set Markdown Adapter (GtSpecSet-Parser)

## Goal
Markdown files whose first non-empty line is one of `# SPEC`, `# IMPLEMENTATION_PLAN`, `# RESEARCH`, `# WORKLOG` must:
1) be recognized by our adapter (not GtNullInputParser),
2) parse into a model, and
3) optionally split/write to four files.

## Current State (2025-10-31)
- Parser core + split model exist and examples are green.
- **Issue:** In GT *Why & matches*, **candidates = empty**, so **GtNullInputParser** wins.
  This is a **registration / context** problem (adapter not present on the input’s context).

## Phases

### Phase 0 — Repo hygiene ✅
- Packages created: `GtSpecSet-Parser`, `GtSpecSet-Model`.
- Baseline loads cleanly.

### Phase 1 — Parser core ✅
- `priority` set (lower is stronger).
- `firstNonEmptyLineFrom:ifNone:` trims BOM/blank lines.
- `matches:` checks strict headers.

### Phase 2 — Model + Writer ✅
- `GtSpecSetSplitResult` introduced.
- `splitText:` and `writeFilesIn:` implemented.
- Examples: `exampleParse`, `gtExampleWriteToTemp`.

### Phase 3 — GT integration (registration + Why view) 🔴 **ACTIVE**
**Problem to solve:** adapter not visible to the `GtInputFile`’s **context** → candidates = #().

**Work done this phase:**
- Added `<gtExample>` diagnostics:
  - `exampleRegistryHealth` (shows where adapter is registered).
  - `exampleWhyMemorySPEC` (baseline why check).
  - `exampleWhyMemorySPEC_fixed` (registers on the *input* context, then asks “why”).
- Utility: `installEverywhere` (idempotent), `valueFor:in:ifAbsent:`.

**Next steps (ordered):**
1. **Baseline hook**: ensure adapter is present after load.
   - Add a post-load DoIt or class-side `install` invoked by Baseline.
   - Acceptance: fresh image → open a `# SPEC` file → candidates includes our adapter.
2. **Context contract check**:
   - Inspect `GtInputFile>>context` and selection pipeline.
   - If contexts intentionally isolate parsers, add a **fallback**:
     - extension on `GtInputFile` or a small registry bridge so that empty candidate sets are supplemented from `GtInputParserRegistry default` / `GtInputParsers`.
   - Add a minimal shim only if needed (keep upstream semantics).
3. **Tests/examples** for selection:
   - Example that builds a `GtInputFile` and asserts:
     - `candidateParsers notEmpty`.
     - includes: `GtSpecSetMarkdownParserAdapter`.
     - winner = our adapter when header matches.
4. **Docs**:
   - Document the diagnostics and the registration contract in README.

**Acceptance criteria for Phase 3:**
- “Parsers (why & matches)” shows **candidates ≠ empty** and **winner = GtSpecSetMarkdownParserAdapter** for each header.
- The three diagnostics examples are green in a fresh image.

### Phase 4 — Space Runner integration (defer)
- Trigger split/write from Space Runner workflow.

## Automated Verification
- Run all `<gtExample>`s in the package must be green.
- Programmatic Why check must confirm winner = our adapter.

## Manual Verification
- Open real files (`SPEC.md`, etc.) → Why view shows our adapter as winner.

## Notes / Mapping to Commands
- Use **/debug** to capture a concise report of the empty-candidates root cause and registry state.
- After Phase 3, run **/validate_plan** to produce a validation report with acceptance checks and remaining manual items. :contentReference[oaicite:1]{index=1}
- Commit using **/commit** guidance (atomic, focused message). :contentReference[oaicite:2]{index=2}
