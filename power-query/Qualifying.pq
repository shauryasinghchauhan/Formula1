// Query: Qualifying
// Purpose: Qualifying results — one row per driver per qualifying session.
// Source: Jolpica Ergast mirror — /2026/qualifying.json
// Notes:
//   - Q1, Q2, Q3 are time strings ("1:23.456") or null if driver didn't reach that segment
//   - Drivers eliminated in Q1 will have Q2 and Q3 null
//   - For grid-penalty-adjusted analysis, join to Results[Grid] not QualiPosition

let
    Source = Json.Document(Web.Contents("https://api.jolpi.ca/ergast/f1/2026/qualifying.json?limit=1000")),
    Races = Source[MRData][RaceTable][Races],
    ToTable = Table.FromList(Races, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    ExpandRace = Table.ExpandRecordColumn(ToTable, "Column1",
        {"season", "round", "QualifyingResults"},
        {"Season", "Round", "QualifyingResults"}),
    ExpandQ = Table.ExpandListColumn(ExpandRace, "QualifyingResults"),
    ExpandQRecord = Table.ExpandRecordColumn(ExpandQ, "QualifyingResults",
        {"position", "Driver", "Constructor", "Q1", "Q2", "Q3"},
        {"QualiPosition", "Driver", "Constructor", "Q1", "Q2", "Q3"}),
    ExpandDriver = Table.ExpandRecordColumn(ExpandQRecord, "Driver",
        {"driverId"},
        {"DriverId"}),
    ExpandConstructor = Table.ExpandRecordColumn(ExpandDriver, "Constructor",
        {"constructorId"},
        {"ConstructorId"}),
    Typed = Table.TransformColumnTypes(ExpandConstructor, {
        {"Season", Int64.Type},
        {"Round", Int64.Type},
        {"QualiPosition", Int64.Type}
    })
in
    Typed
