
## Background
- Narrative path idea: author marks sections that linearize content → our adapter operationalizes this by splitting a master doc into canonical files used across repos.
- GT parsing conventions: class-side adapters with `matches:/priority/parse:` simplify discovery and selection.

## Design Notes
- Strict H1 is deliberate for robustness; can be relaxed later (case-insensitive, aliases).
- Writer is idempotent: compares contents before overwriting to play well with VCS.

## Related Work / Future
- Front-matter capture → future metadata channel (owners, tags).
- Merge/consolidate tool: inverse operation (combine four files back to master).
- Optional YAML/JSON schema for headings map.
- Registry variability across GT versions → keep registration guarded.

## Open Questions
- Should we support additional sections (e.g., `# DECISIONS`)? If yes, via configurable map.
- Should `parse:` repair minor heading mistakes (e.g., extra spaces) or fail fast?
