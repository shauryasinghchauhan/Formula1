// Query: Drivers
// Purpose: Drivers dimension. References Results to stay in sync as drivers appear in race data.
// Add to this query: any manual columns like headshot URL, country flag emoji, etc.

let
    Source = Results,
    Selected = Table.SelectColumns(Source,
        {"DriverId", "DriverCode", "DriverName", "DriverNationality", "DriverNumber"}),
    Distinct = Table.Distinct(Selected),
    Sorted = Table.Sort(Distinct, {{"DriverName", Order.Ascending}})
in
    Sorted
