# Home Screen widget

The widget is the main reminder. The owner wants people to rely on it more than on the app. References: `design/screens/Widget-States.html` (small), `Widget-Medium.html`, `Widget-Large.html`, `Widget-Done.html` (the one animation) and `Widget-Setup.html`.

## What Apple allows

Checked in November 2026 against Apple's WidgetKit documentation and developer forum replies.

- A widget cannot run a looping animation. Nothing on it may move by itself.
- A widget can animate a change of content, for at most about two seconds. Use SwiftUI transitions and `contentTransition`.
- A button on a widget can run an App Intent, after which the widget reloads. Use this for Done.
- Text can count down live with the system timer styles, so "In 20 minutes" can tick without the app running.
- The system decides when a timeline entry is actually shown, so a scheduled change may land a little late. The notification is what makes the hour exact.
- Do not use private APIs to fake continuous motion. Apps have been rejected for it.

Sources: https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities and https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date

## Sizes

| Size | Drawn at | Holds |
| --- | --- | --- |
| Small | 170 × 170 pt | State label, routine name, one or two short lines, Done at the hour |
| Medium | 364 × 170 pt | Text on the left, the yogi in front of the lotus on the right |
| Large | 364 × 382 pt | Name, the three anchor rows (hour, place, things), one larger line, the yogi, Done at the hour |

Corner radius 24 pt (28 on large). Padding 16 pt (20 on large).

Every widget has a decorative lotus half-shown behind its content, cut off by the right edge. All its petals are one tone, a shade off the widget's own background, so it never reads as progress. See `assets/svg/lotus/widget-lotus-on-*.svg`.

## Backgrounds by state

| State | Background |
| --- | --- |
| Earlier in the day, hour passed, morning after a miss | White |
| Twenty minutes before | Soft yellow `#FFF3B0` |
| At the hour | Bright yellow `#FFD21F`, with an orange dot beside "It's time" |
| Kept | Soft green `#E6F8D2`, with a tick beside "Kept today" |

## States and copy, small widget

Each row is: label / line one / line two.

**Days 1 to 6**
- Earlier in the day: Today / 7:00 am / The balcony
- Twenty minutes before: In 20 minutes / The balcony / Yoga mat, grey shawl
- At the hour: It's time / Your mat is waiting. / [Done]
- After Done: Kept today / See you tomorrow / 7:00 am

**Boring middle, days 7 to 27**
- Earlier in the day: Today, 7:00 am / Dull is normal now. / It passes. Just show up.
- Twenty minutes before: In 20 minutes / No need to feel like it. / Just go to the balcony.
- At the hour: It's time / Don't decide. Just start. / [Done]
- After Done: Kept today / You started anyway. / That is the whole practice.

**Any day**
- If the hour slips by: Still today / Just start when you can. / [Done]
- The morning after a missed day: A new day / 7:00 am / Nothing to catch up. Just start.

**Later**
- Days 28 to 48, at the hour: It's time / You know the way. / [Done]
- After day 30, once kept: Kept today / 34 petals open / Tomorrow, 7:00 am

A petal count may appear on the widget only after day 30. It counts days practised. The widget never states the number missed.

## Medium and large

Same four moments, with more room:

| Moment | Medium line | Large line |
| --- | --- | --- |
| Days 1 to 6, earlier in the day | A new day. | A new day. How will you keep your practice today? |
| Boring middle, at the hour | Don't decide. Just start. | Dull is normal now. Don't decide. Just start. |
| After Done | Only tomorrow is next. | That's today, kept. Only tomorrow is next. |
| After day 30, once kept | 34 petals open. | 34 petals open. Tomorrow, one more. |

On medium and large the yogi is calm with eyes closed, and smiling with eyes open after Done. After day 30 the real lotus replaces the yogi, with its count in the centre and red petals for missed days.

## The rotating reminder

Now and then, in the calm "earlier in the day" state only, the widget swaps its line for:

> Remember: same place, same time, same things.

This is a plain change of text between timeline entries, which is allowed. On the reference pages the two lines swap every few seconds so both can be seen; in the real widget it should happen a few times a day. It must not appear at the hour or after Done.

## The one animated moment: tapping Done

Identical on all three sizes, about one second, played once per tap:

1. The yellow "It's time" card cross-fades to soft green.
2. The tick pops in beside "Kept today".
3. The lotus behind opens once (scale up from about half size with a short turn).
4. On medium and large, the yogi changes from eyes closed to eyes open and smiling, and the line changes.

Everything else on the widget stays still.

## More than one routine

If two routines fall on the same day, the widget shows the next one not yet kept. After the first is kept it moves to the second. This behaviour is agreed but not drawn.

## What the widget never shows

Streaks, missed days, red badges, counts before day 30, or any wording about failure.
