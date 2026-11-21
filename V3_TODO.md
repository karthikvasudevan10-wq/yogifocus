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

## 2. Global leaderboard

- [ ] A Game Center leaderboard of mandalas completed, worldwide and among friends.

Notes:
- **How:** a Game Center leaderboard (Apple's service, no server of our own), with its built-in global, friends and recent views.
- **Score:** mandalas completed, a number that only goes up. Never days in a row or anything a missed day can lower (design rules 5 and 10).
- **Opt-in:** off until the person chooses to join. Lead with friends rather than the whole world; never show a rank in a nudge or on Today.
- **Wording:** "You and 3 friends have completed 11 mandalas" rather than "You're 48,213th".
- **Shares set-up with item 1:** same Game Center capability and sign-in; same "check Apple allows this for a lifestyle app" question.

## 3. Global mandala challenge

- [ ] Everyone starts a mandala on the same day and follows it together.

Notes:
- **Dates:** fixed starts such as 1 January and 21 June (International Yoga Day), announced in the app a week or two before.
- **How:** a Game Center recurring leaderboard, 48 days long, from each start date. Game Center reports how many players are on it, so the app can say "You're one of 12,400 people starting today".
- **Together, not a race:** show presence only, for example "8,900 people practised today" and, on day 48, "Together, 9,000 mandalas". No ranks, no misses (design rules 4 and 5).
- **Daily count:** test first whether a daily leaderboard's player count is enough, or whether iCloud's public database (still Apple's, not a server of ours) is needed for "practised today".
- **Joining:** joining starts (or restarts, as the person's own choice) a mandala on the start date. Joining late is fine; the count still welcomes them.
- **Sharing:** the day-48 moment pairs with the mandala video (v2 item 6): "I finished the June mandala with 9,000 people."
- **Promotion:** a natural featuring nomination and short-video moment (v2 items 30 and 31).

## 4. Quick motivational quotes on the Home Screen

- [ ] Short, calm quotes that appear now and then on the Home Screen widget.

Notes:
- **Where:** in the widget's calm state between reminders (it already rotates a reminder line a few times a day), and perhaps a Lock Screen widget. Never at the hour, when the widget's job is Done.
- **How often:** a new one every few hours through the widget timeline; random but never the same twice in a row.
- **Tone:** encouragement only, never pressure or guilt ("Small and steady is how it grows", not "No excuses"). Fits the stage the person is in (first week, the boring middle, becoming yours), as the widget lines already do.
- **Source:** write our own short lines, plus public-domain sources such as the Yoga Sūtras (as the app already quotes 1.14). Check every translation's copyright; don't use modern quotes without permission.
- **Choice:** a switch in routine settings to turn quotes off for people who prefer the plain widget.
- **Length:** short enough for the small widget, about 6 to 10 words; longer ones for medium and large.

---

Add new v3 requests below this line, numbered on from 5.
