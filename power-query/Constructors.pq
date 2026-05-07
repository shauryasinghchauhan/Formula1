// Query: Constructors
// Purpose: Constructors dimension with team color hex codes for HTML visuals.
// Maintenance: Update TeamColor mapping when teams rebrand or new teams enter.
// 2026 watch list: Audi (Sauber rebrand), Cadillac (new entry).

let
    Source = Results,
    Selected = Table.SelectColumns(Source,
        {"ConstructorId", "ConstructorName", "ConstructorNationality"}),
    Distinct = Table.Distinct(Selected),
    AddColors = Table.AddColumn(Distinct, "TeamColor", each
        if [ConstructorId] = "ferrari" then "#E80020"
        else if [ConstructorId] = "mercedes" then "#27F4D2"
        else if [ConstructorId] = "red_bull" then "#3671C6"
        else if [ConstructorId] = "mclaren" then "#FF8000"
        else if [ConstructorId] = "aston_martin" then "#229971"
        else if [ConstructorId] = "alpine" then "#FF87BC"
        else if [ConstructorId] = "williams" then "#64C4FF"
        else if [ConstructorId] = "rb" then "#6692FF"
        else if [ConstructorId] = "sauber" then "#52E252"
        else if [ConstructorId] = "audi" then "#52E252"            // 2026: Audi rebrand TBC
        else if [ConstructorId] = "haas" then "#B6BABD"
        else if [ConstructorId] = "cadillac" then "#FFCC00"        // 2026: new entry, color TBC
        else "#777777", type text),
    AddSecondary = Table.AddColumn(AddColors, "TeamColorSecondary", each
        if [ConstructorId] = "ferrari" then "#FFFFFF"
        else if [ConstructorId] = "mercedes" then "#000000"
        else "#FFFFFF", type text)
in
    AddSecondary
