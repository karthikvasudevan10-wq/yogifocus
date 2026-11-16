# Product

## The goal

Help a person keep one small routine for 48 days, and so make it theirs for life. The measure of success is that the person keeps their routine. It is not how often they open the app. If the widget and the watch are enough and the app is rarely opened, that is the product working. This is for the builder to know; the app never says it to users.

## Who it is for

People who find it hard to focus, to follow a set routine, or to form a habit. For them, "do this every day for the rest of your life" is daunting, and streak counters and guilt make things worse.

## The method

The app is built on a technique yogis in India use to master any practice: meditation, yoga or any other skill.

1. **One day at a time.** Being told to keep a routine for life is too heavy. A yogi works with one day. Each morning they ask: this is a new day, how can I follow my routine today?
2. **Same time, same place, same things.** A routine is performed at the same exact time, in the same exact place, in the same clothing and with the same accessories, such as a yoga mat. When nothing around the routine changes, there is nothing to decide and nothing to remember.
3. **One mandala.** It is believed that someone who completes one mandala, 48 days, starts to see real benefits and is far more likely to keep the practice for the rest of their life.

## How the 48 days tend to go

This is the owner's model of the journey. It shapes what the app says and when.

| Phase | Days | What happens | What the app does |
| --- | --- | --- | --- |
| The capped start | 1 to 6 | Momentum builds. The risk is doing too much and burning out. | Keeps the routine to ten minutes. Says: stop at ten minutes, even if you would like more. |
| The boring middle | 7 to 27 | The novelty fades. Willpower alone crashes here and interest dies. | Says one thing, in many ways: just start. Dull is normal and it passes. Never blames a missed hour or day. |
| It becomes yours | 28 to 48 | The routine starts to run on its own. | From day 30, reveals the lotus the person has been opening. At day 48, celebrates. |

The owner's chart of this (a blue "redesigned system" line against an orange dotted "traditional willpower" line) is the basis for the graph on the third idea screen. The percentages on that chart are illustrative and must not appear in the app.

## What the app is

- A short introduction that explains the three ideas and the 48-day journey.
- A setup that takes one routine and gives it an hour, a place and its things.
- A Home Screen widget that quietly shows today's routine and, at the hour, a Done button.
- One kind question after practising: how did it feel? Every answer gets encouragement.
- A lotus mandala of 48 petals, one for each day of the mandala: green for a day practised, red for a day missed. Hidden until day 30.
- Apple Watch nudges with haptics, and the same question answerable on the wrist.

## What the app is not

- Not a streak tracker. There is no streak counter in this design, and a missed day never resets anything.
- Not a to-do list or a calendar.
- Not something that rewards opening it. No badges for visits, no daily-open bonus.
- Not paid, in any form.

## Tone

Calm, warm and short. Plain sentences. It speaks to the person as an equal. It never scolds, and it never uses pressure words such as "don't break", "you missed" or "only X left".

Good: "Yesterday is finished. Nothing to catch up, nothing to make good. Just start today."

Never: "You missed yesterday. Don't lose your progress."

Missed days are stated as plain fact, only after day 30 and only where the lotus is shown: "3 days missed. Nothing resets." No day-to-day message ever mentions a miss.

## History

The owner built a first version in 2023 as "Yogi Focus" (SwiftUI, SwiftData, EventKit). It used a 30-day target, a streak calendar and a three-step rating that began with a sad face. In April 2025 the owner tried another approach. This design replaces both: 48 days, no streaks, and positive reinforcement only. The 2023 source is in `legacy/`.
