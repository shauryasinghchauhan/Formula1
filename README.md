# F1 2026 Season Tracker

A Power BI dashboard tracking the 2026 Formula 1 season — driver and constructor standings, race results, qualifying performance, and head-to-head teammate analysis.

Built on Ergast API data (via the Jolpica community mirror) with custom HTML visuals for team-branded styling.

## Stack

- **Power BI Desktop** (PBIP format for git-friendliness)
- **Power Query (M)** for ETL
- **DAX** for measures
- **HTML Content** custom visual (Daniel Marsh-Patrick) for styled leaderboards
- **Python** (optional) for ad-hoc data exploration via FastF1

## Repo layout

## Getting started

1. Install Power BI Desktop (latest version).
2. Install the **HTML Content** custom visual from AppSource.
3. Open `pbip/F1SeasonTracker.pbip` (after creating it — see `docs/setup.md`).
4. Refresh the data model.

## Data source

All data comes from the Jolpica Ergast mirror: `https://api.jolpi.ca/ergast/f1/`.
No authentication required — set the web data source credential to **Anonymous** in Power BI.

## Refresh schedule

Weekly, Mondays after each Grand Prix. See `docs/refresh-strategy.md`.

## Contributing

This is a personal project but PRs welcome. See `CLAUDE.md` if using Claude Code.

## License

MIT — see `LICENSE`.