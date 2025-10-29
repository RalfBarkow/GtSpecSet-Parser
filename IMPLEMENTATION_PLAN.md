
## Phase 0 — Repo & Baseline
- [ ] Add `BaselineOfGtSpecSetParser` with groups:
      `core = { GtSpecSet-Model, GtSpecSet-Parser }`, `default = { core }`.
- [ ] README: working Metacello snippet `github://…/src`.

## Phase 1 — Model & Parser
- [ ] `GtSpecSetSplitResult` with: `source/parts/order`, `writeFiles`, `writeFilesIn:`,
      helpers `needsWrite:with:`, `writeAll:to:`, `validatedParts`.
- [ ] `GtSpecSetMarkdownParserAdapter` (class side):
      `priority`, `headingNames`, `headingRegex`, `matches:`, `parse:`, `skeletonFor:`.
- [ ] Strict H1 detection, `trimBoth` for titles.

## Phase 2 — Examples & Tests
- [ ] Examples: `exampleMasterText`, `exampleParse`, `GtSpecSetSplitResult class>>gtExampleWriteToTemp`.
- [ ] Tests: `matches` gate, parse splits, idempotent write, bad `parts` guard.

## Phase 3 — GT Integration
- [ ] Optional `install` to register with `GtInputParserRegistry` if present.
- [ ] `<gtView>` on split result (list sections + “Write files” action). *(optional)*

## Phase 4 — CI & Hygiene
- [ ] smalltalkCI + GitHub Actions.
- [ ] LICENSE, .gitignore, CONTRIBUTING.

## DoD
- One-line Metacello load works; examples green; CI green; README “Quick start” works.
