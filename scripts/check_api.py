"""
Quick API check — verify the Jolpica Ergast endpoints are responding
and that 2026 data is available for the queries we use.

Run before opening Power BI if a refresh fails, to isolate "is it the API
or is it Power BI" questions.

Usage:
    python scripts/check_api.py
    python scripts/check_api.py --season 2026
"""

import argparse
import json
import sys
from urllib.request import urlopen
from urllib.error import HTTPError, URLError

BASE = "https://api.jolpi.ca/ergast/f1"

ENDPOINTS = [
    ("Schedule",          "/{season}/races.json?limit=1000"),
    ("Race results",      "/{season}/results.json?limit=1000"),
    ("Qualifying",        "/{season}/qualifying.json?limit=1000"),
    ("Driver standings",  "/{season}/driverStandings.json"),
    ("Constructors",      "/{season}/constructorStandings.json"),
]


def check(season: int) -> int:
    """Returns 0 on success, 1 if any endpoint failed."""
    failures = 0
    print(f"Checking Jolpica Ergast API for season {season}\n")

    for name, path in ENDPOINTS:
        url = BASE + path.format(season=season)
        try:
            with urlopen(url, timeout=10) as resp:
                data = json.loads(resp.read())
                race_table = data.get("MRData", {}).get("RaceTable", {})
                standings = data.get("MRData", {}).get("StandingsTable", {})
                count = (
                    len(race_table.get("Races", []))
                    or len(standings.get("StandingsLists", []))
                )
                print(f"  ✓ {name:20s} ({count} items)")
        except HTTPError as e:
            print(f"  ✗ {name:20s} HTTP {e.code}: {url}")
            failures += 1
        except URLError as e:
            print(f"  ✗ {name:20s} URL error: {e.reason}")
            failures += 1
        except json.JSONDecodeError:
            print(f"  ✗ {name:20s} invalid JSON response")
            failures += 1

    print()
    if failures:
        print(f"{failures} endpoint(s) failed.")
        return 1
    print("All endpoints healthy.")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--season", type=int, default=2026)
    args = parser.parse_args()
    sys.exit(check(args.season))
