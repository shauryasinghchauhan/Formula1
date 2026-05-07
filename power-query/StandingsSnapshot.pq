// Query: StandingsSnapshot
// Purpose: Driver standings AS OF each round. Powers the championship progression line chart.
// Source: Jolpica Ergast mirror — /2026/{round}/driverStandings.json (called once per round)
//
// PARAMETER REQUIRED: This query depends on a parameter named `MaxRound` (Int64)
// Set it to the number of completed rounds. Default to 1 at season start.
// The helper query CurrentRound.pq can derive this dynamically.

let
    GetRoundStandings = (round as number) =>
        let
            url = "https://api.jolpi.ca/ergast/f1/2026/" & Number.ToText(round) & "/driverStandings.json",
            Source = Json.Document(Web.Contents(url)),
            Lists = Source[MRData][StandingsTable][StandingsLists],
            Result = if List.Count(Lists) = 0 then null else Lists{0}[DriverStandings]
        in
            Result,
    Rounds = List.Numbers(1, MaxRound),
    AllStandings = List.Transform(Rounds, each [Round = _, Standings = GetRoundStandings(_)]),
    ToTable = Table.FromRecords(AllStandings),
    FilterNonNull = Table.SelectRows(ToTable, each [Standings] <> null),
    ExpandStandings = Table.ExpandListColumn(FilterNonNull, "Standings"),
    ExpandRecord = Table.ExpandRecordColumn(ExpandStandings, "Standings",
        {"position", "points", "wins", "Driver", "Constructors"},
        {"Position", "Points", "Wins", "Driver", "Constructors"}),
    ExpandDriver = Table.ExpandRecordColumn(ExpandRecord, "Driver",
        {"driverId"},
        {"DriverId"}),
    GetTeam = Table.AddColumn(ExpandDriver, "ConstructorId",
        each try [Constructors]{0}[constructorId] otherwise null, type text),
    Cleaned = Table.RemoveColumns(GetTeam, {"Constructors"}),
    Typed = Table.TransformColumnTypes(Cleaned, {
        {"Round", Int64.Type},
        {"Position", Int64.Type},
        {"Points", type number},
        {"Wins", Int64.Type}
    })
in
    Typed
