# Claude Code Context: F1 2026 Season Tracker

This file gives Claude Code the context it needs to work productively on this repo.

## Project goal

A Power BI dashboard tracking the 2026 Formula 1 season. Four pages: Championship Overview, Race Results, Driver Deep Dive, Constructor Battle.

## Key technical decisions

- **PBIP format, not PBIX.** We store the project as PBIP (Power BI Project) so the model and report are JSON/TMDL files that diff well in git. `.pbix` is binary and shouldn't be committed.
- **Data source: Jolpica Ergast mirror** (`https://api.jolpi.ca/ergast/f1/`). The original Ergast API is winding down; Jolpica is the maintained community fork with the same schema.
- **Star schema.** Fact tables: `Results`, `Qualifying`, `StandingsSnapshot`. Dimensions: `Drivers`, `Constructors`, `Races`, `Date`.
- **Single-direction relationships only.** Bidirectional filtering causes ambiguity, especially with the snapshot table.
- **HTML visuals via DAX measures.** Leaderboards, podium graphics, and tire compound icons are built as DAX measures returning HTML strings, rendered via the HTML Content custom visual.

## Repo conventions

### File organization
- `power-query/` — one `.pq` file per query. The file's first comment line names the query. These are reference copies; the actual query lives inside the PBIP file's TMDL.
- `dax/` — measures grouped by purpose (`foundational.dax`, `championship.dax`, `form-trends.dax`, `html-visuals.dax`).
- `docs/` — markdown design docs. `data-model.md` is the source of truth for schema decisions.
- `scripts/python/` — exploratory scripts. Not part of the Power BI pipeline.

### When editing DAX
- Use 4-space indentation.
- Variables: `VAR` always at start of measure body, returns labeled clearly.
- Comments above non-obvious logic, not beside it.
- Keep measures atomic; build complex measures by composing simple ones.

### When editing Power Query
- Use the `let ... in` form. Step names in PascalCase.
- Always type-cast at the end of the query (`Table.TransformColumnTypes`).
- Don't hardcode the season — use a `Season` parameter where possible (currently `2026`).

### Commit message conventions
- `feat(dax): add teammate H2H measure`
- `fix(power-query): handle null pit stops in early rounds`
- `docs: update refresh strategy`
- `chore: update team color hex for Audi`

## What Claude Code can help with

- Writing/refactoring DAX measures (reference: `docs/dax-style-guide.md`).
- Writing/refactoring Power Query M code.
- Building HTML measure templates for new visuals (track maps, podium, tire usage).
- Maintaining the team color and driver headshot reference files in `assets/`.
- Writing Python scripts in `scripts/python/` for data exploration with FastF1.
- Updating documentation when measures or model change.

## What Claude Code should NOT do

- **Don't commit `.pbix` files.** Only PBIP project files (the folder structure with `.Report` and `.SemanticModel` subfolders).
- **Don't put credentials anywhere.** The data source is anonymous; no keys needed.
- **Don't auto-update team data mid-season** without checking. Driver moves and team rebrands happen — flag suggested changes for review rather than rewriting.
- **Don't reformat the entire repo** in one commit. Small, focused changes.

## Common tasks reference

### Adding a new DAX measure
1. Decide which file in `dax/` it belongs in (or create one).
2. Write it with `VAR`s, comments, and a clear `RETURN`.
3. Add it to the PBIP semantic model (manually in Power BI Desktop, or via TMDL editing).
4. Update `docs/measures-catalog.md` if it's user-facing.

### Adding a new Power Query
1. Write the M in `power-query/<query-name>.pq`.
2. Add it to the PBIP via Power BI Desktop's Power Query editor (paste into Advanced Editor).
3. Set up relationships in the model view.
4. Update `docs/data-model.md`.

### Adding a new HTML visual measure
1. Write the DAX in `dax/html-visuals.dax`.
2. The measure should return a complete HTML string.
3. Test in the HTML Content visual.
4. Document the measure's expected filter context in a comment at the top.

## Useful references

- Ergast API docs: https://ergast.com/mrd/
- Jolpica mirror: https://github.com/jolpica/jolpica-f1
- DAX style guide: SQLBI's best practices.
- PBIP format: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview
- HTML Content visual: AppSource ("HTML Content" by Daniel Marsh-Patrick).

## Open questions / decisions to revisit

- **Sprint races in 2026:** scoring and count not finalized in the data yet. The `Points Available` measure assumes ~6 sprints; revisit when calendar firms up.
- **Cadillac entry:** new 11th team. ConstructorId TBD when they appear in API responses.
- **Audi/Sauber rebrand:** watch for whether `constructorId` changes from `sauber` to `audi`.
