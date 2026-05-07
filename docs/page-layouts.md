# Page Layouts

Four pages, each with a clear focus. Page order matches reader flow: overview → detail → analysis.

## Page 1: Championship Overview

The landing page. Should answer "who's winning, by how much, and is the title decided?" in one glance.

**Layout (16:9, 1280×720 grid):**

```
┌──────────────────────────────────────────────────────────┐
│  [Title: 2026 Season Tracker]      [Last updated: card]  │
├────────────────┬───────────────────┬─────────────────────┤
│ Leader card    │ Gap to P2 card    │ Races remaining card│
├────────────────┴───────────────────┼─────────────────────┤
│                                    │                     │
│  HTML Leaderboard (top 20 drivers) │  Constructor bar    │
│                                    │  chart (top 10)     │
│                                    │                     │
├────────────────────────────────────┴─────────────────────┤
│  Cumulative points by round (line chart, top 5 drivers)  │
└──────────────────────────────────────────────────────────┘
```

**Visuals:**
- KPI cards: `Drivers[DriverName]` filtered by `[Current Championship Position] = 1`, `[Points Gap to Leader]`, `[Races Remaining]`.
- HTML Content visual bound to `Leaderboard HTML`.
- Bar chart: `Constructors[ConstructorName]` × `[Total Points]`, color by `Constructors[TeamColor]`.
- Line chart: `Races[Round]` (X) × `[Cumulative Points]` (Y), legend `Drivers[DriverName]`, filtered to top 5.

## Page 2: Race Results

A single-race deep dive. Slicer at top to pick the round.

```
┌──────────────────────────────────────────────────────────┐
│  [Round slicer]                                          │
├──────────────────────────────────────────────────────────┤
│  HTML Podium (top 3 of selected round)                   │
├──────────────────────────────────────┬───────────────────┤
│  Results table:                      │  Fastest lap card │
│   Pos | Driver | Team | Grid | Pts   ├───────────────────┤
│                                      │  DNF list         │
└──────────────────────────────────────┴───────────────────┘
```

**Visuals:**
- Slicer: `Races[RaceName]` (single select).
- HTML Content: `Podium HTML`.
- Table: Position, DriverName, ConstructorName, Grid, Points, Status.
- Card: driver name where `[Fastest Laps] > 0`.
- Table filtered to DNFs only: DriverName, Status.

## Page 3: Driver Deep Dive

Driver-centric. Slicer to pick driver.

```
┌──────────────────────────────────────────────────────────┐
│  [Driver slicer]    Driver name + number (large)         │
├──────────┬──────────┬──────────┬──────────┬──────────────┤
│ Champ    │ Wins     │ Podiums  │ Avg      │ Teammate     │
│ Position │          │          │ Finish   │ H2H          │
├──────────┴──────────┴──────────┴──────────┴──────────────┤
│  Points per race (bar chart)                             │
├──────────────────────────────────────────────────────────┤
│  Quali vs race position (clustered column, per round)    │
└──────────────────────────────────────────────────────────┘
```

**Visuals:**
- Slicer: `Drivers[DriverName]` (single select, mandatory).
- KPI cards using all the foundational and championship measures.
- Bar chart: `Races[Round]` × `[Total Points]` (filtered by selected driver via slicer).
- Clustered column: Round × (QualiPosition, Position).

## Page 4: Constructor Battle

Team-level analysis.

```
┌──────────────────────────────────────────────────────────┐
│  [Constructor slicer (multi-select)]                     │
├──────────────────────────────────────────────────────────┤
│  Cumulative team points by round (line chart)            │
├──────────────────────────────────┬───────────────────────┤
│  Stacked column:                 │  Reliability:         │
│  driver contribution per team    │  DNF rate per team    │
└──────────────────────────────────┴───────────────────────┘
```

**Visuals:**
- Slicer: `Constructors[ConstructorName]` (multi-select).
- Line chart: Round × team cumulative points.
- Stacked column: Constructor × Points, stacked by DriverName.
- Bar: Constructor × DNF rate (`DIVIDE([DNFs], COUNTROWS(Results))`).

## Theme

Dark theme works well for F1 branding. Suggested palette:
- Background: `#0F0F12`
- Card background: `#1A1A1F`
- Primary text: `#FFFFFF`
- Secondary text: `#888888`
- Accent (use sparingly): `#FF1801` (F1 red)
