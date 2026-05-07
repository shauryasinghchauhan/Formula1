// Query: CurrentRound
// Purpose: Helper that returns the round number of the most recently completed race.
// Use this to set the MaxRound parameter dynamically instead of bumping it manually.
// Returns: Int64. Returns 0 if no rounds completed yet.

let
    Source = Json.Document(Web.Contents("https://api.jolpi.ca/ergast/f1/2026/results.json?limit=1000")),
    Races = Source[MRData][RaceTable][Races],
    RoundNumbers = List.Transform(Races, each Number.FromText(_[round])),
    MaxCompleted = if List.Count(RoundNumbers) = 0 then 0 else List.Max(RoundNumbers)
in
    MaxCompleted
