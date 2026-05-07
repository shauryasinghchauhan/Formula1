// Query: Races
// Purpose: Race schedule dimension table for the 2026 season.
// Source: Jolpica Ergast mirror — /2026/races.json
// Refresh cadence: Once per week is fine; schedule rarely changes mid-season.

let
    Source = Json.Document(Web.Contents("https://api.jolpi.ca/ergast/f1/2026/races.json?limit=1000")),
    Races = Source[MRData][RaceTable][Races],
    ToTable = Table.FromList(Races, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Expanded = Table.ExpandRecordColumn(ToTable, "Column1",
        {"season", "round", "raceName", "date", "time", "Circuit"},
        {"Season", "Round", "RaceName", "Date", "Time", "Circuit"}),
    ExpandCircuit = Table.ExpandRecordColumn(Expanded, "Circuit",
        {"circuitId", "circuitName", "Location"},
        {"CircuitId", "CircuitName", "Location"}),
    ExpandLocation = Table.ExpandRecordColumn(ExpandCircuit, "Location",
        {"locality", "country", "lat", "long"},
        {"City", "Country", "Lat", "Long"}),
    Typed = Table.TransformColumnTypes(ExpandLocation, {
        {"Season", Int64.Type},
        {"Round", Int64.Type},
        {"Date", type date},
        {"Lat", type number},
        {"Long", type number}
    })
in
    Typed
