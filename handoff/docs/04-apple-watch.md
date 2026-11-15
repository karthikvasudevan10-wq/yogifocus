# Apple Watch

Reference: `design/screens/Watch.html`. Drawn at 208 × 248 points (the 46 mm size) on a black ground, as watchOS apps are. Scale by the screen width for other case sizes; nothing may be fixed in pixels.

## What the watch is for

The owner asked for three things:

1. A haptic nudge when the routine is close.
2. A haptic nudge when feedback is wanted.
3. Being able to give that feedback on the watch.

So the watch is a nudge and a quick answer. It is not a second copy of the app.

## Screens

| Moment | Haptic | What it shows |
| --- | --- | --- |
| 20 minutes before | One gentle tap | "In 20 minutes", Meditate, the hour and length, the place, the things, and "Same place, same time, same things." |
| At the hour | A firmer double tap | "It's time", Meditate, "Your mat is waiting.", a Done button |
| Boring middle, at the hour | A firmer double tap | Same, with "Don't decide. Just start." |
| If the hour slips by | One gentle tap, once only | "Still today", Meditate, "Just start when you can.", Done |
| Ten minutes later, asking how it felt | One gentle tap | "How did it feel?" and three buttons: Scattered, Steady, Absorbed |
| After an answer | The success pattern | A smiling yogi in front of a turning lotus, "That's today, kept.", "Only tomorrow is next.", "7:00 am, the balcony" |
| Opening the watch app | None | "A new day", Meditate, the hour and place, an "I've practised" button |
| On the watch face | None | A Smart Stack card ("In 20 minutes, Meditate, The balcony") and two complications: a lotus glyph, and "7:00 am Meditate" |

Tapping Done or "I've practised" leads to "How did it feel?". Choosing a feeling records the same reflection as the phone and leads to the kept screen.

## Haptics

The haptic descriptions above are the intent. Map them to the nearest system haptics; a reasonable starting point with `WKInterfaceDevice.current().play(_:)` is:

- Gentle tap: `.notification`, or simply let the local notification play its default.
- Firmer double tap at the hour: `.start`.
- After an answer: `.success`.

These mappings are a suggestion and have not been tested on a device. Rules that are fixed:

- Never more than one nudge for a missed hour. No repeated buzzing.
- No haptic for anything that is not one of the moments above.
- The nudge before the hour and the one asking for feedback are both required.

## Graphics and motion

- A dark green lotus sits half off the right edge behind the text on the nudge and app screens, turning very slowly (one turn a minute). See `assets/svg/lotus/watch-lotus-on-black.svg`.
- The yogi floats gently at the top right of the "It's time" and app screens.
- On the kept screen a bright green lotus turns behind a smiling, floating yogi and a yellow ring ripples outward.
- The Smart Stack card and complications are always still; watch-face widgets cannot animate.
- Honour Reduce Motion: show the lotus and yogi still.

## Colours on the watch

Black ground, white text, soft grey-green `#C2CDBE` for secondary text, bright green `#6FD43A` for buttons with dark text `#14301F`, bright yellow `#FFD21F` for labels and the kept heading, dark greens `#1F5129`, `#184220`, `#12331A` for the background lotus, `#1F2A1F` for raised surfaces.

## The same rules apply

No streaks, no counts before day 30, no blame. During days 7 to 27 the wording is "just start". After day 30 the Smart Stack card may show the petal count.

## Not designed yet

- The 20-minute nudge and "It's time" as actual notification layouts (short look and long look). The screens here show the content they should carry.
- Setting up or editing a routine on the watch. The assumption is that this stays on the phone.
- A mandala screen on the watch after day 30.
- Layouts checked at the smallest case size.
