# Logic and data

This file states the behaviour the design relies on. Where something is a suggestion and not an owner decision, it says so.

## Phases

Everything the app says depends on which phase a routine is in.

| Phase | Days | Voice |
| --- | --- | --- |
| Capped start | 1 to 6 | Welcoming. "Stop at ten minutes, even if you would like more." |
| Boring middle | 7 to 27 | "Just start." Dull is normal and it passes. |
| Becoming yours | 28 to 48 | Quiet confidence. "You know the way." |
| After the mandala | 49 on | A new mandala begins; a second routine may be added. |

Days are calendar days counted from the day the routine began.

## The day-30 rule

Before day 30, nothing may show progress: no petal count, no day number, no streak, no lotus filled in, on any surface. The data is still recorded from day one, silently.

At day 30 the Day 30 screen appears once and the lotus is revealed. After that, the mandala screen, the widget and the Smart Stack card may show the petal count.

Day 30 is the thirtieth calendar day of the mandala. This follows from the missed-day rule below; the owner has not confirmed it separately.

## Petals and missed days

Decided by the owner:

- A mandala is 48 days on the calendar. Petal n belongs to day n.
- A day on which the routine was kept turns its petal green. A day counts once, however many times Done is tapped.
- A missed day does not reset the mandala. Its petal turns red.
- The app tells the person how many were missed, for example "Out of 48 days, you practised 45 and missed 3."
- There is no streak counter anywhere.

How the design applies this:

- Red petals and the missed count appear only where the lotus appears, so only from day 30: the Day 30 screen, the mandala screen, the large and medium widgets, and the finishing screen.
- Day-to-day messages never mention a miss. The morning after a missed day still says only "A new day."
- The wording is plain fact with no blame: "3 days missed. Nothing resets."
- The mandala completes on day 48 whatever the count.

Not yet decided: exactly when a day becomes "missed" (assumed: no Done by the end of that calendar day), and how paused days are treated.

## The daily loop

1. Earlier in the day: the widget shows the routine and, now and then, the reminder line.
2. Twenty minutes before: widget turns soft yellow; the watch gives a gentle tap.
3. At the hour: widget turns bright yellow with Done; soft chime if enabled; the watch gives a firmer tap.
4. The person practises, away from the phone.
5. They tap Done on the widget, watch or app.
6. The app, or the watch, asks how it felt: Scattered, Steady or Absorbed, with an optional note on the phone. If Done was not tapped, the watch asks ten minutes after the hour.
7. The kept screen. Then nothing until tomorrow.

If the hour passes without Done: "Still today. Just start when you can." One gentle watch tap at most. The next morning, whatever happened: "A new day." No mention of yesterday.

## Routines

- A beginner has exactly one routine, at least ten minutes long. In the first week the app tells them not to do more.
- A routine has: what it is, an hour, a length, a place, a list of things, a chime switch, a paused switch.
- A second routine is offered when the first mandala is complete. Each routine has its own phase and its own lotus.
- With more than one routine in a day, the widget and Today show the next one not yet kept.
- Pausing silences the widget and nudges and loses nothing.

## Suggested data model

A suggestion, based on the 2023 SwiftData models (`TaskModel`, `FeedbackModel`). Rename and reshape as needed.

```
Routine
  id
  name                 "Meditate"
  kind                 one of the twelve choices, or custom
  hour, minute         the fixed time each day
  durationMinutes      at least 10
  place                "the balcony"
  things               ["Yoga mat", "Grey shawl"]
  chimeEnabled
  isPaused
  startedOn            date the routine began
  mandalaNumber        1 for the first 48 days

Reflection             one per routine per day kept
  id
  routine
  day                  calendar day it belongs to
  feeling              scattered | steady | absorbed
  note                 optional
  recordedAt
```

Derived, never stored: the day of the mandala, days practised (days with a reflection), days missed (past days without one), the phase, whether progress may be shown.

The widget, watch and app all need the same data: use an App Group container.

## What to take from the legacy code

In `legacy/`:

- `Model/Task.swift`, `Model/Feedback.swift`: the SwiftData shape to evolve from. The old `feedbackScore` 0 to 2 maps to scattered, steady, absorbed; the old label for 0 was "No" with a sad face, which is dropped.
- `Model/EventStore.swift`: adds a repeating calendar event as the reminder. Optional now.
- `OnboardingView.swift`: the original five-page introduction, including the Yoga Sūtra 1.14 verse, which now appears on the finishing screen.
- `StreakCalView.swift`: the streak calendar and "Current Streak" line. Do not carry this over.
- `TaskForm.swift`: the old nine categories (Physical Health, Mental Health, and so on). Replaced by the twelve routine choices.
- Colours and the old yogi artwork in `Assets.xcassets`: replaced by this design.

## Privacy

Nothing in the design needs an account or a server. The assumption is that all data stays on the device, shared between the app, widget and watch. This has not been discussed with the owner.
