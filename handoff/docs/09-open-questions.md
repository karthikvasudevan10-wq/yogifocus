# Open questions

Decisions the owner has not made. Ask before building anything that depends on them. Each has the assumption the design currently makes.

## Decided since the first draft

- **iPhone Duo layouts** are now drawn for the outer display, the inner display wide and the inner display tall (tabletop pose). See `docs/07-platforms.md`. Not every screen has a Duo version; the rest follow the same rules.
- **Two routines in one day** is drawn on the wide inner display (`Duo-Wide-Today.html`).
- **A missed day does not reset the mandala.** It turns that day's petal red, and the app states how many days were missed. A mandala is therefore 48 calendar days.

## Product rules

1. **When does a day count as missed?** Assumed: no Done by the end of that calendar day. Paused days are not covered.
2. **What does "cross 30 days" mean?** Now assumed to be the thirtieth calendar day, since each petal is a calendar day. Not confirmed separately.
3. **Missed-day wording.** The owner's wording is "out of 48 days, you missed 3 days". The design says "Out of 48 days, you practised 45 and missed 3" and, mid-mandala, "3 days missed. Nothing resets." Confirm the softer phrasing is acceptable.
4. **Streaks after day 30?** The owner said streaks or mandala tracking may be shown after 30 days. The design shows the mandala only, with no streak counter.
5. **May the hour be changed?** The missed-day screen has a quiet "Try another hour" link, and routine settings allow it. That bends "same exact time". Keep, or remove?
6. **Ads.** "Completely free for everyone" was stated. No purchases or subscriptions is clear. Ads were not discussed; assume none.
7. **Red and colour blindness.** Red and green petals are hard to tell apart for some people. The count is always given in words; a second cue on the petal itself has not been designed.

## Not designed yet

8. **Eating habits.** It is on the routine picker but does not fit "ten minutes at 7:00 am". Proposed: one small action tied to one meal, such as "no sugar in my morning tea". Needs its own setup screen.
9. **Entry to the mandala screen.** After day 30 the person needs a way from Today to their mandala. Not drawn.
10. **Watch notifications.** The watch screens show the content. The actual short-look and long-look notification layouts are not drawn.
11. **Routine setup on the watch.** Assumed phone only.
12. **A mandala screen on the watch after day 30.** Not drawn.
13. **Settings.** There is no general settings screen (notifications, sound, data). Per-routine settings exist.
14. **Accessibility passes.** VoiceOver labels are in the references for graphics, but Dynamic Type at large sizes and VoiceOver order have not been checked.

## Dark appearance

- **Not every screen is drawn in the dark.** Eleven are. The idea screens 2 and 3, widget setup, routines list and settings, the boring-middle Today screens, Day 30, the medium and large widgets and the Done demo follow the rules in `docs/05-design-system.md` but have not been drawn or checked.
- **The 48-day graph in the dark** needs its own colours for the zones and labels; not designed.
- **Dark app icon** exists; it was derived, not hand-tuned.

## From the website FAQ

- **Travel and time zones.** The FAQ tells travellers to carry their "same things", choose the closest spot, just start if the hour moves, and change the hour or place in settings. What the app should do when the person changes time zone (keep 7:00 local time, or keep the home time) is not designed.

## Design details to confirm

15. **Body font.** Inter in the reference. Bundle it, or use the system font?
16. **Welcome ripple rings.** Thin white rings ripple from behind the yogi. The owner disliked an earlier white circle behind him; these were flagged and not yet confirmed.
17. **Dusk colour.** Between day and night the sky passes through grey. A warmer dusk was offered.
18. **Finishing-screen rays.** Added without being asked for; the owner has not objected.
19. **Dark and tinted app icons.** Generated from the light icon, not tuned by hand.
20. **Reference artwork.** The owner shared two reference images (a yogi on a floating island, and a "Yogi" wordmark with birds). Their palette and flat style were followed, but the yogi, lotus and all artwork here are original and do not copy them. If the owner holds rights to those images and wants them used, that is a change.

## Technical

21. **Minimum OS versions.** Not set. iPhone Duo ships with iOS 27.1.
22. **Calendar event.** The 2023 app created a repeating calendar event. Keep alongside notifications, or drop?
23. **Haptic mapping.** The watch haptics are described by intent; the mapping to system haptics is a suggestion and untested.
24. **Petal fall duration on day 48.** Loops in the reference; proposed a few seconds in the app.
25. **Bundle identifier, team, App Store details.** Not provided.
