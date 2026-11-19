# Yogi Focus v2: to do

Features planned for after 1.0. Each item has the idea as asked, then notes on what iOS allows and how it sits with the design rules in `handoff/CLAUDE.md`. Nothing here is built yet.

## Release plan

Agreed 18 November 2026. No server of our own: everything runs on the phone or through Apple services (iCloud/CloudKit, WeatherKit). Building starts 19 November 2026.

**v2.0: build first**
- 1 Restart a mandala
- 2 "Not today" as an answer
- 10 A two-minute version
- 24 Open straight into the practice
- 25 Ask "How did it feel?" less
- 26 A missed day leaves no trace in the moment
- 9 Fading nudges
- 18 Learn when they really do it
- 14 Siri, Shortcuts and the Action button
- 22 A gentle alarm (AlarmKit)
- 4 Dynamic Island and Live Activity (started from the alarm, a notification or the widget; no server push)
- 6 Share a completed mandala (share sheet first; Instagram Stories needs a free Facebook App ID)
- 32 "Share Yogi Focus" inside the app
- 29 Ask for a rating at a happy moment
- 3 Do Not Disturb alternatives: block distracting apps with Screen Time, plus the one-tap shortcut (needs Apple's Family Controls entitlement; request it early)

**v2.1: next (permissions or more care)**
- 5, 19, 20 Calendar: block the time, suggest a new time, hold nudges while busy
- 11 "After I…" anchor; 7 automatic-or-not check-in; 8 letter to yourself (review 7 and 8 against item 25 first, as they add questions)
- 13 Apple Health check-ins, and the Health item in Maybe
- 12 A nudge on arrival
- 15 What we've noticed; 16 The yogi's year
- 21 Weather-aware Walk (WeatherKit)

**Later or hard**
- 17 A practice partner (iCloud sharing; the most complex item)
- 23 Set the scene (Shortcuts or HomeKit, once Start is tapped)

**Not possible as written**
- 3: switching Do Not Disturb on automatically. iOS has no API for it; see the alternatives in item 3.
- 20: detecting driving. A Driving Focus already holds notifications, so nothing to build.
- 6: posting straight to TikTok needs TikTok's developer approval (free, no server). The share sheet reaches TikTok without it.

**Any time, no code:** 27, 28, 30, 31 and the ideas in [PROMOTION.md](PROMOTION.md).

## 1. Restart a mandala

- [ ] Let people restart the mandala for any routine, so they can make a fresh start if they missed too many days and get a chance to correct course.

Notes:
- **Design rule 10:** "A missed day never resets the mandala." That rule is about the app never resetting it automatically. A restart the person chooses is different, but it must stay their choice. The app should never suggest it because of missed days, and never word it as a failure ("start again" or "a fresh start", not "you missed too many").
- **Design rule 4:** misses stay hidden before day 30, so the option should not mention missed days before then. Before day 30 it is simply "Begin this routine again".
- **Where:** routine settings, beside Pause. After day 30, perhaps also on the mandala screen.
- **Data:** the model already supports it. `YogiStore.beginNewMandala` starts mandala n + 1 from today and keeps the earlier days as history.

## 2. "Not today" as an answer

- [ ] When the Apple Watch, the widgets (all sizes) or the notifications ask whether the practice was done, also offer a way to say it was missed that day.

Notes:
- **Today, a day counts as missed** only when the calendar day ends without Done. An explicit answer would let the day close sooner and stop the remaining nudges, including the "How did it feel?" one.
- **Tone (design rule 5):** no blame. Use something like "Not today", answered with "That's all right. Tomorrow is a new day."
- **Showing misses (design rules 4 and 10):** a miss is never mentioned day to day. The answer only changes what the lotus shows from day 30, where a missed day is already a red petal.
- **Where:** a second button beside Done on the watch "It's time" and "Still today" screens. A second widget button on medium and large; small has room for one only. A third notification action.

## 3. Do Not Disturb during the practice

- [ ] From 5 minutes before the routine until its length is up, put the phone into Do Not Disturb automatically, after asking the person's permission.

Notes:
- **iOS limit:** iOS does not let an app turn on Do Not Disturb or a Focus by itself. There is no public API for it.
- **What is possible:**
  - **A Shortcuts personal automation.** Shortcuts' own "Set Focus" action can turn Do Not Disturb on at a time of day and off after a set time. Yogi Focus can offer to set this up: explain it, then hand over a ready-made shortcut or step-by-step guidance. The person approves it in Shortcuts, which counts as the permission.
  - **A scheduled Focus.** In Settings → Focus, the person can schedule Do Not Disturb for the routine's hour. The app can open the right settings page and show the times to enter.
  - **A Focus filter** (`SetFocusFilterIntent`). Yogi Focus can react when a Focus is on, for example by showing only today's routine, but it cannot switch the Focus on.
  - **Block distracting apps (recommended, with the shortcut).** Apple's Screen Time API (FamilyControls, ManagedSettings, DeviceActivity) lets Yogi Focus shield the apps the person picks, such as Instagram or TikTok, from 5 minutes before the routine until its length is up, with a calm "It's practice time" screen. A `DeviceActivitySchedule` switches it on and off by itself, with no server. Needs the person's permission once (individual authorisation) and Apple's Family Controls (Distribution) entitlement, requested from Apple and reviewed; ask early. Limit: it blocks apps, not calls or notifications.
  - **The gentle alarm and Live Activity (items 22 and 4).** They don't silence anything, but they make the practice time hard to miss on the Lock Screen and Dynamic Island.
- **Plan:** offer app blocking plus the one-tap Do Not Disturb shortcut, side by side, in routine settings.
- **Keeping times in step:** if the routine's hour or length changes, the person has to update their automation or schedule. The app can remind them in routine settings.

## 4. Dynamic Island and Live Activity

- [ ] Find intelligent ways to use the Dynamic Island, and show progress there.

Ideas:
- **Before:** about 20 minutes ahead, a compact countdown ("Meditate in 12 min") with the place and things in the expanded view: same time, same place, same things.
- **During:** once started, a ring that fills over the routine's length (10 minutes to 1 hour), the time remaining, and Done in the expanded view. Live Activity buttons can run App Intents.
- **After:** a brief "That's today, kept." and then it ends itself.
- **Lock Screen:** the same Live Activity, with the same content as the widget.
- **Progress:** before day 30, time-based progress only, never counts (design rule 4). From day 30, the expanded view can show the lotus and "34 petals open", as the widget does.

Notes:
- **Starting it:** a Live Activity can be started while the app is open, or from an App Intent such as an "I'm starting" button on the widget or a notification. Starting one at a set time with no interaction needs a push from a server, and Yogi Focus has none. The likely design is to start it from the 20-minute notification or the widget.
- **Apple Watch:** watchOS shows iPhone Live Activities in the Smart Stack, so the watch gets this too.
- **iPhone Duo:** check how the Dynamic Island sits on the outer display's trailing strip.

## 5. Block the time in the person's calendars

- [ ] For each routine, add a recurring event that blocks its time in the calendars the person chooses, such as their work and family calendars.

Notes:
- **How:** use EventKit. Create one event per chosen calendar, repeating daily at the routine's hour for its length, titled with the routine's name (for example "Meditate · Yogi Focus") and shown as busy, so colleagues and family see the time as taken. Cut Sugar has no length, so it would get a short block or none.
- **Permission:** to list the person's calendars so they can pick work and family, the app needs full calendar access, with an `NSCalendarsFullAccessUsageDescription` that explains why. Write-only access can add events but cannot list calendars. Ask only when the person turns the option on, never during setup.
- **Which calendars:** any calendar the iPhone already syncs (iCloud, Google, Exchange or Outlook) can take events. Some work accounts limit what other apps may add, so a calendar may refuse an event; say so plainly if it does.
- **Keeping it in step:** store each event's identifier with the routine. When the hour or length changes, update the events. When the routine is paused or removed, end or delete them (the "Remove this routine" message already says data is removed). If the person deletes an event in their calendar, leave it deleted.
- **Where:** a "Block this time in my calendar" option in routine settings, with a calendar picker. Possibly also offered once after setup, on the widget screen.
- **History:** the 2023 version created a repeating calendar event (`handoff/legacy/.../Model/EventStore.swift`). The handoff left this as an open question ("Calendar event. Keep alongside notifications, or drop?"); this answers it.
- **Privacy:** events live in the person's own calendars, not on any server. The privacy page should add a line saying calendar access is used only to add and update these events.

---

Add new v2 requests below this line, numbered on from 6.

## 6. Share a completed mandala to Instagram and TikTok

- [ ] On the mandala complete screen, add sharing to Instagram and TikTok. Tell the person this is a very special screen that not many people in the world ever reach, and show how many mandalas they have completed.

Notes:
- **What is shared:** a 12-second video the app makes on the phone when Share my mandala is tapped, with a still image as the other choice. It uses the person's own routine name and mandala number: the lotus opening petal by petal, the yogi arriving, "48 days". Nothing private: no place, things, feelings or times. No server: drawn with SwiftUI and written with AVAssetWriter on the device.
- **Spec and reference:** `handoff/design/mandala-video/` has the reference video, the frame-by-frame timeline (`clip.html`, `render(t)`) and the build notes (README). Canvas row 20 has the "Making your video" and "Share your mandala" screens.
- **Instagram:** Stories sharing through the `instagram-stories://share` URL scheme, with the image on the pasteboard. This needs a Facebook App ID and `instagram-stories` in `LSApplicationQueriesSchemes`. Feed posts go through the share sheet.
- **TikTok:** the TikTok Share Kit SDK (needs a TikTok developer app and review) for sharing to TikTok directly. Without it, the system share sheet can still send the image or video to TikTok.
- **Fallback:** a share sheet button (`ShareLink`) for everything else, and a plain "Save image" option.
- **"Not many people reach here":** keep it true and warm, for example "Very few people ever keep a practice for 49 days. This is a special place to be." Avoid a made-up statistic unless we have one we can stand behind. No comparing with others in a way that shames anyone who has not got there.
- **Mandalas completed:** the count comes from `mandalaNumber - 1` for the routine (and the iCloud summary's `mandalasCompleted` for all routines). Show both on the screen and in the shared image, for example "Your 3rd mandala".
- **Design rule 4:** this screen is after day 49, so showing counts is allowed here.
- **Privacy:** sharing only happens when the person taps it. Update the privacy page to say no data goes to Instagram or TikTok unless they choose to share.

## 7. Automatic-or-not check-in

- [ ] On days 21 and 49, ask one gentle question: "Today, did it happen without much thinking?" From day 30, show how the answer has changed ("Day 7: it took effort. Day 49: it just happened.").

Notes:
- **Why:** a habit is formed when it feels automatic. This is the clearest sign for the person that the app helped, more than any count.
- **Design rule 4:** the day-21 answer is stored but not shown back until day 30.
- **Answers:** three choices, such as "It took effort", "A little" and "It just happened". No wrong answer, no blame.
- **Data:** a small field on `Reflection` or a new model, synced through CloudKit like the rest.

## 8. A letter to yourself

- [ ] On day 1, ask for one line on why this routine matters. On day 49, show it on the mandala complete screen.

Notes:
- **Setup:** optional, after the anchor screen. Easy to skip, and editable later in routine settings.
- **Day 49:** "On day 1 you wrote: …", above the sharing from item 6. The person chooses whether the line goes into the shared image (off by default).
- **Privacy:** stays in their private iCloud database.

## 9. Fading nudges

- [ ] As days are kept on time, make reminders gentler and less frequent. Near the end of the mandala, tell the person: "You don't need my reminder any more."

Notes:
- **How:** from day 30, if most recent days were kept before the reminder fired, drop the 20-minute nudge first, then the on-time one. Bring them back quietly after a few misses, without saying why (design rule 5).
- **Control:** a "Keep all reminders" switch in routine settings for people who want them.
- **Message:** said once, warmly, as a moment to be proud of.

## 10. A two-minute version

- [ ] During setup, let the person choose a tiny fallback (for example "sit on the mat for two minutes"). On a hard day, offer it, and count it as kept.

Notes:
- **Where:** an optional step in setup; a "Just the two-minute version" button on Today, the widget and the watch.
- **Counting:** it counts as kept, so the mandala petal opens. It can be marked in the data so the insights in item 15 can mention it kindly ("Twice you kept it with the two-minute version").
- **Tone:** never a lesser kept day. "Showing up is the habit."

## 11. Anchor to something already done

- [ ] Alongside the time, add an "After I…" anchor, such as "After my morning coffee, I meditate".

Notes:
- **Why:** linking a new routine to an existing habit makes it more likely to happen.
- **Sentence:** `routineSentence` gains the anchor: "Each day after my morning coffee, at about 7:00, on the balcony, I meditate."
- **Suggestions:** a short list (after waking, after coffee, after brushing my teeth, after work), plus free text.
- **Reminders:** still at the time, since iOS can't detect "after coffee".

## 12. A nudge on arrival

- [ ] Offer a reminder when the person arrives at the routine's place (the gym, the balcony), as well as at the time.

Notes:
- **How:** a location-triggered local notification (`UNLocationNotificationTrigger`) on a region set by picking the place on a map. Only once a day, and only around the routine's hour.
- **Permission:** "When in use" location is enough for location notifications. Ask only when the person turns it on.
- **Privacy:** the location stays on the device and in their private iCloud. The privacy page needs a line on it.

## 13. Mark it done automatically

- [ ] Use Apple Health to notice a kept day: a workout logged near the routine's time counts for Gym, and mindful minutes count for Meditate. Ask "Looks like you went. Count it?" and never mark it without asking.

Notes:
- **How:** HealthKit read access for workouts and mindful sessions, with background delivery to send the question as a notification.
- **Writing back:** optionally save a mindful session to Health when a Meditate day is kept.
- **Permission:** ask only when turned on in routine settings. Health data never leaves the device; the privacy page needs a line on it.

## 14. Siri, Shortcuts and the Action button

- [ ] "Hey Siri, I've done my meditation." App Shortcuts for Done, the two-minute version and "How am I doing?", available to Siri, Spotlight and the Action button.

Notes:
- **How:** the Done App Intent already exists for the widget; publish it with `AppShortcutsProvider` and phrases per routine.
- **"How am I doing?":** before day 30, answers with time and kindness only, never counts (design rule 4).

## 15. What we've noticed

- [ ] From day 30, show small insights drawn from the person's own answers, such as "You felt steadiest on days you went before 7" or "The balcony days felt more absorbed".

Notes:
- **How:** simple on-device comparisons of feelings against time of day, weekday and place. No server, no AI service needed.
- **Tone:** only kind, useful observations. Never "You miss Mondays".
- **Where:** the mandala screen, one insight at a time; perhaps one on the mandala complete screen.

## 16. The yogi's year

- [ ] Each completed mandala adds a lasting mark to a yearly lotus garden: a quiet record of a changed life, and a year-end share.

Notes:
- **Where:** a new screen from the routines list, and a year-end moment in late December with sharing (item 6).
- **Content:** one lotus per completed mandala, coloured by routine, with the month it was finished.
- **Data:** already there; `mandalaNumber` and kept days give everything needed.

## 17. A practice partner

- [ ] Invite one person to practise alongside. Each sees only whether the other has kept today, never their misses. A soft nudge such as "Priya has kept today".

Notes:
- **How:** CloudKit sharing (`CKShare`) of a small record per routine, holding only "kept today" and the mandala number.
- **Design rules 4 and 5:** no misses, no streaks, no comparison. Only presence.
- **Privacy:** the partner sees nothing else: no place, things, feelings or times. Either person can stop sharing at any time.

## 18. Learn when they really do it

- [ ] Move reminders quietly to match when Done is usually tapped. If the routine is set for 7:00 but is usually finished at 7:40, the nudge follows, with nothing to set up and no question.

Notes:
- **How:** keep the time of each Done; after a week or two, shift the nudge towards the typical time, within limits (say ±45 minutes). The routine's set time stays as written.
- **Visible:** a quiet line in routine settings ("Reminders follow when you usually practise"), with a switch to turn it off.

## 19. Clear the way around the calendar

- [ ] When a calendar event overlaps the routine, suggest a new time for today the evening before or that morning: "You've a call at 7. Meditate at 6:30 today?" One tap accepts; doing nothing keeps the usual time.

Notes:
- **Permission:** calendar read access, shared with item 5. Only when turned on.
- **Today only:** the change applies to one day, never the routine.
- **Tone:** an offer, never a warning.

## 20. Hold nudges until they're free

- [ ] Don't nudge while the person is driving or in a meeting; deliver the reminder once they're free.

Notes:
- **How:** calendar busy times (item 19) to delay the nudge; notification interruption levels so Focus modes such as Driving hold it. iOS doesn't let apps read whether someone is driving, so Focus does that part.
- **Limit:** if the delay pushes past the routine's window, send a softer "Still today" nudge instead.

## 21. Weather-aware Walk

- [ ] On a rainy morning, offer an indoor walk or a drier time: "Rain at 7. An indoor walk today, or 5:30 this evening when it clears?"

Notes:
- **How:** WeatherKit for the routine's place. Needs the place's rough location (item 12) or the phone's.
- **Other routines:** could extend to Gym (an outdoor run) or Stretch outdoors.

## 22. A gentle alarm

- [ ] For people who want it, ring the routine like a soft alarm at its time, with Start and Later buttons.

Notes:
- **How:** AlarmKit (iOS 26), which shows on the Lock Screen, Dynamic Island and watch, and breaks through silent mode.
- **Sound:** the app's chime, soft and short. Off by default; chosen in routine settings.

## 23. Set the scene

- [ ] At the routine's time, run a Shortcut or Home scene the person chose once: dim the lights, start a playlist, turn on Do Not Disturb (item 3).

Notes:
- **How:** iOS can't run a Shortcut from an app at a set time without the person; so either a Shortcuts automation the app helps set up (as in item 3), or running it when Start is tapped (item 22 or 24).
- **HomeKit:** with Home permission, the app could run a scene itself when Start is tapped.

## 24. Open straight into the practice

- [ ] Tapping the nudge goes straight to a timer with the chime, not a screen of choices. Done is marked when the timer ends.

Notes:
- **Untimed routines:** Cut Sugar has no timer; the nudge opens to Done.
- **Ties in with:** the Live Activity in item 4, which shows the timer on the Lock Screen and Dynamic Island.
- **Leaving early:** if the timer is stopped early, still count it as kept (item 10's spirit: showing up is the habit).

## 25. Ask "How did it feel?" less

- [ ] Ask about once a week, or only when the answer would teach the app something, instead of every day.

Notes:
- **Why:** fewer questions, less burden. Reflections still build up for the insights in item 15.
- **Choice:** people who like answering daily can turn it back on.
- **Design:** check how this sits with the reflect and kept screens; on days without the question, Done goes straight to "That's today, kept."

## 26. A missed day leaves no trace in the moment

- [ ] The day after a miss, the nudge is exactly as warm as always. No "welcome back", no "let's get back on track". The app simply carries on.

Notes:
- **Design rules 5 and 10:** this makes the existing rules explicit for every nudge, widget and watch message, and for anything added in v2.
- **Check:** review every message in `Nudges.swift` and the widgets to make sure none of them depends on the day before.

## 27. US English store text

- [ ] Add an en-US App Store localisation alongside en-GB.

Notes:
- **Why:** the US store indexes its own localisation's keywords, so a second set of 100 characters roughly doubles the search terms the app can rank for there.
- **How:** copy the en-GB name, subtitle and description into `fastlane/metadata/en-US/`, switch spellings (practise → practice, colour → color), and write a different keyword set so the two don't repeat each other.

## 28. Translate the store text

- [ ] Translate the App Store text for big markets: Spanish, German, French, Japanese, Hindi and Chinese (Simplified, and Traditional for Taiwan and Hong Kong).

Notes:
- **Store text first:** name, subtitle, description, keywords and screenshots' captions. Translating the app itself can come later; the store text alone helps search.
- **India:** the yoga and mandala theme is a natural fit. Hindi metadata is supported; many people there search in English too, so en-IN wording may matter as much.
- **Mainland China:** the China App Store needs an ICP filing number for the app, entered in App Store Connect, before it can be available there. Taiwan and Hong Kong don't. Check whether the app is currently live in China or was held back for this.
- **Native review:** have each translation checked by a native speaker; the no-blame tone is easy to lose.

## 29. Ask for a rating at a happy moment

- [ ] Use Apple's built-in rating prompt (`requestReview`) at a good moment, such as day 30 or mandala complete, never after a miss.

Notes:
- **Limit:** Apple shows it at most three times a year per person and may choose not to show it at all.
- **Feedback minimum:** this is the only rating ask; no custom "Do you like the app?" screen.
- **Ties in with:** "What changed?" in the Maybe list.

## 30. Nominate the app for App Store featuring

- [ ] Submit a featuring nomination in App Store Connect (Featuring → Nominations).

Notes:
- **Pitch:** the no-guilt approach, the lotus and yogi design, and full use of Apple platforms: iPhone, iPhone Duo layouts, Apple Watch app and complications, widgets with buttons. Later: Live Activity and Dynamic Island (item 4) and AlarmKit (item 22).
- **Timing:** nominate again for each meaningful update (v2), and a few weeks ahead of themed moments such as New Year and International Yoga Day (21 June).

## 31. Short videos on TikTok and Instagram

- [ ] Post the lotus-opening animation and the mandala-complete moment as short videos on TikTok and Instagram Reels.

Notes:
- **Material:** simulator recordings already work (`xcrun simctl io recordVideo`), and the debug seed (`YF_SEED`, `YF_DEMO`) can show any day of the mandala.
- **Ideas:** the 49-petal lotus filling in, "what 49 days of meditation looks like", the yogi levitating, the no-guilt message.
- **Ties in with:** item 6, where people share their own mandala.

## 32. "Share Yogi Focus" inside the app

- [ ] Add a quiet way to share the app's App Store link (https://apps.apple.com/app/id6835473975) with friends, and a "Rate Yogi Focus" link beside it.

Notes:
- **Where:** at the bottom of the routines screen, and on the mandala complete screen next to item 6's sharing. Never as a pop-up or nudge.
- **How:** `ShareLink` with the App Store URL and a short warm message ("I've been keeping a small daily routine with Yogi Focus. It's free."). The rate link opens `https://apps.apple.com/app/id6835473975?action=write-review`.
- **Feedback minimum:** these are links the person can choose to tap, not questions. The only rating prompt stays item 29.
- **Watch:** not needed there.

---

# Maybe

Ideas to keep in mind but not yet planned. Move one up into the numbered list when it's decided.

## Share kept days with Apple Health

- [ ] Write what a kept day does to Apple Health, as an option the person turns on per routine.

Notes:
- **What Health can hold:** Health has no type for habits, so the mandala (petals, days kept, mandalas completed) can't appear there. A kept day can.
- **By routine:**
  - Meditate: a mindful session for the routine's length.
  - Gym, Walk, Stretch: a workout of the right kind (strength training, walking, flexibility). These count towards the Activity rings.
  - Cut Sugar, Read, Journal, Music, Study, Tidy, Plan: nothing fits. Don't log zero sugar; it would mislead.
- **"How did it feel?":** a State of Mind entry (iOS 18) for Scattered, Steady or Absorbed, linked to the routine. Over 49 days Health shows their mood on practice days, the strongest part of this idea.
- **No doubles:** don't write a workout already logged by the watch. Ties in with item 13, which reads it.
- **Permission:** ask only when turned on, and only for the types that routine needs.
- **Privacy:** the privacy page needs a line saying Health data stays on the device and is used for nothing else.

## Before and after

- [ ] On day 1, ask one question about the area the routine is for ("How calm do your days feel?", 1 to 5). Ask again on day 49 and show both side by side.

## "What changed?"

- [ ] On day 49, ask "What's different now?" and keep the answer beside the day-1 letter (item 8). A good moment to ask for an App Store review.

## Who you're becoming

- [ ] Identity wording that grows: around day 30, "You're becoming someone who meditates"; at day 49, "You're someone who meditates."

## Know what this stage feels like

- [ ] A short note for each stage the app already tracks (days 1–6, the boring middle 7–27, becoming yours 28–48), such as "Week 2 often feels dull. That's normal, and it's where habits are made."

## Plan for the obstacle

- [ ] At setup, ask "What's most likely to get in the way?" and help write an if-then plan ("If it rains, I'll walk indoors"). Show the plan back on days it may matter.

## Get ready the night before

- [ ] For morning routines, an optional evening nudge to set out the routine's things: "Put your mat and shawl out for tomorrow."

## Travel and holidays

- [ ] When the time zone changes, gently ask whether to keep the routine at local time, change it, or pause for the trip. Pausing never counts as missed days.

## The next routine builds on this one

- [ ] At mandala complete, offer a second routine anchored to the first ("After I meditate, I journal"), using item 11.

## Keeping it going

- [ ] After the mandala, a lighter mode: fewer nudges, a weekly check-in, and a lotus that keeps growing, for people who don't want a new mandala.
