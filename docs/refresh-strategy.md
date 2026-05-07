# Refresh Strategy

## When to refresh

- **Mondays after a Grand Prix weekend.** Ergast/Jolpica typically have results within a few hours of the race, but waiting until Monday gives time for any data corrections.
- **Manually after a sprint weekend** if you want the sprint points reflected immediately.
- **No refresh needed** during the off-season (December–February).

## Power BI Service schedule

If publishing to the Service:

1. Workspace → Dataset → **Settings** → **Scheduled refresh**
2. Frequency: **Weekly**, Mondays
3. Time: **09:00 local** (gives time for any post-race data corrections)
4. Data source credentials: **Anonymous** (Jolpica is a public API)

## Incremental refresh

Not necessary for this scale. Full refresh of the entire 2026 season fits in seconds.

If extending to multi-season historical (1950–present, ~26,000 results), set up incremental refresh on `Results` and `StandingsSnapshot`:
- RangeStart / RangeEnd parameters
- Store: complete years older than 1 year
- Refresh: rolling 1-year window

## Failure modes

The Jolpica API is generally reliable but has occasional issues:

- **429 rate limit**: rare for our query volume, but possible on the StandingsSnapshot loop. Mitigation: add `Function.InvokeAfter` delays between rounds, or load StandingsSnapshot less frequently than other queries.
- **Schema changes**: Ergast format is stable; Jolpica mirrors it exactly. Watch the Jolpica GitHub issues if a refresh suddenly breaks.
- **Empty StandingsLists for a round**: Handled in StandingsSnapshot.pq with a null check.

## Rolling forward to 2027

When the time comes:
1. Update the season number in each `.pq` file (`/2026/` → `/2027/`).
2. OR (recommended) parameterize the season — add a `Season` parameter, change the URLs to use `& Season &`.
3. Update `MaxRound` parameter back to 1.
4. Review `Constructors.pq` for team changes.
