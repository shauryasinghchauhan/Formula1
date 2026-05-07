# Data Model

## Schema overview

Star schema with three fact tables sharing common dimensions.

```
                ┌─────────────┐
                │  DimDate    │      (optional, mark Races as date table instead)
                └──────┬──────┘
                       │
   ┌─────────────┐     │      ┌──────────────────┐
   │ DimDrivers  │─────┼──────│  DimConstructors │
   └──────┬──────┘     │      └────────┬─────────┘
          │            │               │
          │     ┌──────┴──────┐        │
          ├─────┤ FactResults ├────────┤
          │     └──────┬──────┘        │
          │            │               │
          │     ┌──────┴──────┐        │
          ├─────┤FactStandings│        │
          │     │  Snapshot   │        │
          │     └──────┬──────┘        │
          │            │               │
          │     ┌──────┴──────┐        │
          └─────┤FactQualify  ├────────┘
                └──────┬──────┘
                       │
                ┌──────┴──────┐
                │  DimRaces   │
                └─────────────┘
```

## Tables

### Fact tables

**Results** — One row per driver per race.
- Grain: (Season, Round, DriverId)
- Measures: points, position, grid, fastest lap, status
- Cardinality: ~480/season

**Qualifying** — One row per driver per qualifying session.
- Grain: (Season, Round, DriverId)
- Measures: Q1/Q2/Q3 times, qualifying position
- Cardinality: ~480/season

**StandingsSnapshot** — Driver standings AS OF each round.
- Grain: (Round, DriverId)
- Measures: points, position, wins
- Cardinality: ~480/season after final round
- Powers the championship progression line chart

### Dimension tables

**Drivers** — DriverId, code, name, nationality, number.
**Constructors** — ConstructorId, name, nationality, team color hex.
**Races** — Season, Round, RaceName, Date, Circuit, Country, lat/long.

## Relationships

| From | To | Cardinality | Direction |
|---|---|---|---|
| Results[DriverId] | Drivers[DriverId] | Many-to-one | Single |
| Results[ConstructorId] | Constructors[ConstructorId] | Many-to-one | Single |
| Results[Round] | Races[Round] | Many-to-one | Single |
| StandingsSnapshot[DriverId] | Drivers[DriverId] | Many-to-one | Single |
| StandingsSnapshot[Round] | Races[Round] | Many-to-one | Single |
| Qualifying[DriverId] | Drivers[DriverId] | Many-to-one | Single |
| Qualifying[Round] | Races[Round] | Many-to-one | Single |

**Bidirectional filters: don't.** They cause ambiguity with the snapshot table.

## Notes on edge cases

- **Mid-season driver changes**: Ergast assigns a different `driverId` only if the driver is genuinely new. A reserve driver subbing in (e.g., for illness) keeps their existing ID. `Drivers` dimension built from `Results` will pick them up.
- **DNS (Did Not Start)**: Status field will read "Did not start" — these rows have a Grid position but no Position.
- **Disqualifications**: PositionText is "D", Position is blank, Points is 0.
- **Sprint races**: The `/sprint.json` endpoint provides these separately. Currently not in the model — add `SprintResults` query if you want sprint-points-included views.
