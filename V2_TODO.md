# Yogi Focus v2: to do

Features planned for after 1.0. Each item has the idea as asked, then notes on what iOS allows and how it sits with the design rules in `handoff/CLAUDE.md`. Nothing here is built yet.

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
- **What is shared:** a ready-made image (and perhaps a short clip of the lotus opening) in the app's style: the full lotus, the routine's name, "49 days" and "Mandala 3". Nothing private: no place, things, feelings or times.
- **Instagram:** Stories sharing through the `instagram-stories://share` URL scheme, with the image on the pasteboard. This needs a Facebook App ID and `instagram-stories` in `LSApplicationQueriesSchemes`. Feed posts go through the share sheet.
- **TikTok:** the TikTok Share Kit SDK (needs a TikTok developer app and review) for sharing to TikTok directly. Without it, the system share sheet can still send the image or video to TikTok.
- **Fallback:** a share sheet button (`ShareLink`) for everything else, and a plain "Save image" option.
- **"Not many people reach here":** keep it true and warm, for example "Very few people ever keep a practice for 49 days. This is a special place to be." Avoid a made-up statistic unless we have one we can stand behind. No comparing with others in a way that shames anyone who has not got there.
- **Mandalas completed:** the count comes from `mandalaNumber - 1` for the routine (and the iCloud summary's `mandalasCompleted` for all routines). Show both on the screen and in the shared image, for example "Your 3rd mandala".
- **Design rule 4:** this screen is after day 49, so showing counts is allowed here.
- **Privacy:** sharing only happens when the person taps it. Update the privacy page to say no data goes to Instagram or TikTok unless they choose to share.
