// Query: LapPositions
// Purpose: Lap-by-lap position data for ALL completed races in the season.
// Source: Jolpica Ergast mirror — /2026/{round}/laps.json (called once per round)
// Depends on: MaxRound parameter (already used by StandingsSnapshot)
//
// Returns: One row per (Round, Lap, Driver) showing position and lap time.
// Powers the lap-position spaghetti chart on the Race Analysis page.
//
// PERFORMANCE NOTE: This pulls ~1,400 rows per race × completed rounds.
// For a full 24-race season: ~33,000 rows. Refresh takes 1-2 minutes.
// API rate limiting may slow it further; if 429 errors occur, add
// Function.InvokeAfter delays between rounds.

let
    GetRoundLaps = ( round as number ) =>
        let
            Url = "https://api.jolpi.ca/ergast/f1/2026/" & Number.ToText ( round ) & "/laps.json?limit=2000",
            Source = Json.Document ( Web.Contents ( Url ) ),
            Races = Source[MRData][RaceTable][Races],
            Result =
                if List.Count ( Races ) = 0 then
                    null
                else
                    Races{0}[Laps]
        in
            Result,

    Rounds = List.Numbers ( 1, MaxRound ),
    AllRoundsList =
        List.Transform (
            Rounds,
            each [ Round = _, LapsList = GetRoundLaps ( _ ) ]
        ),
    ToTable = Table.FromRecords ( AllRoundsList ),
    FilterNonNull = Table.SelectRows ( ToTable, each [LapsList] <> null ),
    ExpandLapsList = Table.ExpandListColumn ( FilterNonNull, "LapsList" ),
    ExpandLapRecord = Table.ExpandRecordColumn ( ExpandLapsList, "LapsList",
        { "number", "Timings" },
        { "Lap", "Timings" } ),
    ExpandTimings = Table.ExpandListColumn ( ExpandLapRecord, "Timings" ),
    ExpandTimingsRecord = Table.ExpandRecordColumn ( ExpandTimings, "Timings",
        { "driverId", "position", "time" },
        { "DriverId", "Position", "LapTime" } ),
    Reordered = Table.SelectColumns ( ExpandTimingsRecord,
        { "Round", "Lap", "DriverId", "Position", "LapTime" } ),
    Typed = Table.TransformColumnTypes ( Reordered, {
        { "Round", Int64.Type },
        { "Lap", Int64.Type },
        { "DriverId", type text },
        { "Position", Int64.Type },
        { "LapTime", type text }
    } )
in
    Typed
