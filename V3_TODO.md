# Yogi Focus v3: to do

Features planned for after v2. Each item has the idea as asked, then notes on what iOS allows and how it sits with the design rules in `handoff/CLAUDE.md`. Nothing here is built yet.

## 1. Game Center achievements for mandalas

- [ ] Award a Game Center achievement each time a mandala is completed.

Notes:
- **What earns one:** completing a mandala, and only that. For example "First mandala", "Three mandalas", "Seven mandalas", "A year of mandalas" (about 7 or 8 in a year) and "Three routines, each with a mandala". A mandala completes on day 48 whatever the count, so every achievement is reachable without a perfect run.
- **Design rules 4, 5 and 10:** no achievements for streaks, perfect attendance or days in a row, and nothing that can be lost. A restart (v2 item 1) never takes one away and never counts as a completion. Nothing before day 30 hints at progress towards one.
- **When:** report it on the mandala complete screen, alongside sharing (v2 item 6). Game Center's own banner appears; keep it to that one moment.
- **Where people see them:** Apple's Games app and the Game Center dashboard. A small "Achievements" link on the mandala complete screen or in Your routines could open the dashboard (`GKAccessPoint` or `GKGameCenterViewController`).
- **Sign-in:** Game Center asks the person to sign in the first time. If they're not signed in, or decline, nothing changes and nothing is shown again.
- **Set-up:** add the Game Center capability, define the achievements in App Store Connect (each needs a title, description and 512 × 512 or 1024 × 1024 artwork, which could use the lotus at different stages), then report with `GKAchievement`.
- **Check first:** Game Center is meant for games. Confirm with Apple's current guidelines that a lifestyle app can use achievements, or whether the app would need a games category, before building.
- **Privacy:** achievements are visible to Game Center friends depending on the person's own Game Center settings. Update the privacy page to say the app reports completed mandalas to Game Center only if the person is signed in to it. Routine names, places and feelings are never sent.
- **Already earned:** when v3 first runs, award achievements for mandalas completed before it, quietly, without a stack of banners.

---

Add new v3 requests below this line, numbered on from 2.
