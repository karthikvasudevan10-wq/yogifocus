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

## 5. Start from Control Centre and the Lock Screen

- [ ] An iOS control that starts the practice timer in one press, from Control Centre, the Lock Screen or the Action button.

Notes:
- **How:** a `ControlWidget` (iOS 18) running the Start App Intent from v2 item 14, which opens the timer already running.
- **Label:** the routine's name and hour; with several routines, the next one not yet kept.
- **Lock Screen:** placeable in the bottom corners in place of the torch or camera.

## 6. StandBy

- [ ] A calm bedside view while the phone charges on its side: tomorrow's routine overnight, then a sunrise "It's time".

Notes:
- **How:** the existing widgets with StandBy-specific layouts (`.widgetRenderingMode`, full-colour and the red night mode).
- **Night:** dim, no counts, nothing that wakes anyone. The morning nudge still comes from the alarm or notification.

## 7. A gentle voice for the first week

- [ ] Short spoken guidance inside the timer during days 1 to 6, when starting is hardest.

Notes:
- **What:** a few calm sentences at the start ("Settle in. Nothing to get right.") and one near the end. Silence otherwise.
- **How:** recorded audio clips, or on-device speech (`AVSpeechSynthesizer` with a premium voice). No streaming.
- **Choice:** off after day 6 unless the person keeps it; a switch in routine settings.
- **Routines:** wording per kind (meditate, stretch, read…), never instructions that assume ability.

## 8. Ambient sound in the timer

- [ ] Rain, birds or a soft drone, chosen once, playing only while the practice timer runs.

Notes:
- **How:** a few short, original, seamlessly looping files in the app; `AVAudioSession` set so other audio pauses politely.
- **Ends:** fades out a few seconds before the chime.
- **Choice:** per routine, with "Silence" as the default.

## 9. Your mandala garden

- [ ] A gallery of every completed mandala: the lotus, its routine, its dates, and the day-1 letter (v2 item 8).

Notes:
- **Where:** from Your routines, and the mandala complete screen.
- **Builds on:** v2 item 16 (the yogi's year) and the mandala video (v2 item 6): each lotus can be shared again.
- **Restarts:** a mandala begun again shows its days kept in the history but is never shown as unfinished or failed.

## 10. Lotus colours you grow into

- [ ] Each completed mandala unlocks a new lotus palette for the widget and the app.

Notes:
- **Only adds:** nothing is ever taken away; there is no way to lose a colour.
- **Examples:** sunrise, monsoon, dusk, snow. The person chooses which to use; the default stays green.
- **Design rule 4:** nothing before day 30 hints at what's coming.

## 11. Practice circles

- [ ] A small private group of family or friends doing the same routine, each seeing only "kept today".

Notes:
- **Widens v2 item 17** from one partner to a few (up to about 6).
- **How:** iCloud sharing (`CKShare`) of one small record per person; no server of ours.
- **Shown:** names and a kept-today tick. Never misses, streaks or rankings; never place, things or feelings.
- **Leaving:** anyone can leave or remove the circle at any time.

## 12. On-device insights with Apple Intelligence

- [ ] Warmer, more personal "What we've noticed" lines (v2 item 15), written on the phone.

Notes:
- **How:** Apple's on-device Foundation Models framework, where available; the existing simple insights as the fallback.
- **Guardrails:** generated lines pass the same tone rules as the rest of the app: kind, no blame, no counts before day 30, never mention misses. Prefer a short fixed template the model only fills.
- **Privacy:** nothing leaves the device.

## 13. iPad, Mac and Vision Pro

- [ ] Yogi Focus on iPad, Mac and Vision Pro, with the same routines through iCloud.

Notes:
- **iPad and Mac:** the iPhone Duo layouts (wide and tall) are a strong starting point; Mac via Mac Catalyst or "Designed for iPad".
- **Vision Pro:** a quiet space for the practice timer: the lotus and yogi in a calm surrounding.
- **Sync:** already handled by CloudKit; widgets on iPad and Mac follow.

## 14. The whole app in more languages

- [ ] Translate the app itself, not only the App Store text (v2 items 27 and 28): Spanish, German, French, Japanese, Hindi and Chinese.

Notes:
- **How:** move all text to a String Catalog; plural rules for counts after day 30.
- **Tone:** native speakers review every line; the no-blame wording is easy to lose in translation.
- **Fonts:** check Baloo 2 and Inter cover Devanagari and Chinese, or fall back to system fonts for those scripts.

---

Add new v3 requests below this line, numbered on from 15.
