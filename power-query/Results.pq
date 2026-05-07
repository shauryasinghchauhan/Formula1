// Query: Results
// Purpose: Main fact table — one row per driver per race.
// Source: Jolpica Ergast mirror — /2026/results.json
// Notes:
//   - Status field includes "Finished", "+1 Lap" (counts as classified), DNF reasons
//   - FastestLap fields are blank for early-season races where no FL bonus point applies
//   - Position is blank for DNFs; PositionText carries "R" (retired), "D" (disqualified), etc.

let
    Source = Json.Document(Web.Contents("https://api.jolpi.ca/ergast/f1/2026/results.json?limit=1000")),
    Races = Source[MRData][RaceTable][Races],
    ToTable = Table.FromList(Races, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    ExpandRace = Table.ExpandRecordColumn(ToTable, "Column1",
        {"season", "round", "raceName", "date", "Results"},
        {"Season", "Round", "RaceName", "Date", "Results"}),
    ExpandResults = Table.ExpandListColumn(ExpandRace, "Results"),
    ExpandResultRecord = Table.ExpandRecordColumn(ExpandResults, "Results",
        {"number", "position", "positionText", "points", "Driver", "Constructor",
         "grid", "laps", "status", "Time", "FastestLap"},
        {"DriverNumber", "Position", "PositionText", "Points", "Driver", "Constructor",
         "Grid", "Laps", "Status", "RaceTime", "FastestLap"}),
    ExpandDriver = Table.ExpandRecordColumn(ExpandResultRecord, "Driver",
        {"driverId", "code", "givenName", "familyName", "nationality"},
        {"DriverId", "DriverCode", "GivenName", "FamilyName", "DriverNationality"}),
    ExpandConstructor = Table.ExpandRecordColumn(ExpandDriver, "Constructor",
        {"constructorId", "name", "nationality"},
        {"ConstructorId", "ConstructorName", "ConstructorNationality"}),
    ExpandFL = Table.ExpandRecordColumn(ExpandConstructor, "FastestLap",
        {"rank", "lap", "Time"},
        {"FLRank", "FLLap", "FLTimeRecord"}),
    ExpandFLTime = Table.ExpandRecordColumn(ExpandFL, "FLTimeRecord",
        {"time"},
        {"FLTime"}),
    AddDriverName = Table.AddColumn(ExpandFLTime, "DriverName",
        each [GivenName] & " " & [FamilyName], type text),
    Typed = Table.TransformColumnTypes(AddDriverName, {
        {"Season", Int64.Type},
        {"Round", Int64.Type},
        {"Position", Int64.Type},
        {"Points", type number},
        {"Grid", Int64.Type},
        {"Laps", Int64.Type},
        {"DriverNumber", Int64.Type},
        {"Date", type date}
    })
in
    Typed
