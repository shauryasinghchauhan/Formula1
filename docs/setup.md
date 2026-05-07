# Setup

Step-by-step to get the project running locally.

## Prerequisites

- **Power BI Desktop** — latest version (the November 2024+ release has improved PBIP support).
- **Git** — for version control.
- **HTML Content custom visual** — install from AppSource inside Power BI Desktop. Search for "HTML Content" by Daniel Marsh-Patrick.

## First-time setup

1. Clone this repo.

2. Open Power BI Desktop. Go to **File → Options and settings → Options → Preview features** and enable **"Power BI Project (.pbip) save option"** if not already on.

3. Create a new Power BI file. Save it as `pbip/F1SeasonTracker.pbip` from this repo's root.

4. In the Power Query editor, create the queries in this order (each one's M code is in `power-query/`):
   - `Races` (paste from `power-query/Races.pq`)
   - `Results`
   - `Qualifying`
   - `CurrentRound` (this one returns a single number, not a table — load as connection-only)
   - `MaxRound` parameter (Manage Parameters → New → Type: Decimal Number, Current Value: result of `CurrentRound`)
   - `StandingsSnapshot`
   - `Drivers` (depends on Results)
   - `Constructors` (depends on Results)

5. In the model view, set up relationships:
   - `Results[DriverId]` → `Drivers[DriverId]` (single direction, many-to-one)
   - `Results[ConstructorId]` → `Constructors[ConstructorId]`
   - `Results[Round]` → `Races[Round]`
   - `StandingsSnapshot[DriverId]` → `Drivers[DriverId]`
   - `StandingsSnapshot[Round]` → `Races[Round]`
   - `Qualifying[DriverId]` → `Drivers[DriverId]`
   - `Qualifying[Round]` → `Races[Round]`

6. Create a "Measures" table (Home → Enter Data → name it `Measures`, leave empty, load). Hide the dummy column. All DAX measures from `dax/` go into this table.

7. Paste the DAX measures from each `.dax` file. Group them in display folders matching the file names.

## Verifying the build

After loading, the model should report:
- `Races`: ~24 rows
- `Results`: ~480 rows after a full season (24 × 20)
- `StandingsSnapshot`: ~480 rows after a full season
- `Drivers`: ~22 rows (counting mid-season swaps)
- `Constructors`: 11 rows for 2026

If `Results` is empty, the season may not have started — Ergast publishes data once each race weekend completes.

## First refresh

Set the web data source credential to **Anonymous**:
- File → Options and settings → Data source settings → select the Jolpica URL → Edit Permissions → Anonymous.

Then **Home → Refresh**.

## Publishing to Power BI Service

Optional. Once published:
1. In the workspace, go to dataset → Settings → Data source credentials → set anonymous.
2. Schedule refresh: Mondays at 09:00 local time.
