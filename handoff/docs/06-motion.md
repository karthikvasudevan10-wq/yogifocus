# Motion

Motion is calm and slow, with a few big moments. Every animation below runs in the live references in `design/screens/`; open them to see the exact feel. The keyframes are in each page's `<style>` block and can be read directly.

Honour Reduce Motion everywhere: show the settled final frame, with no movement.

## Shared pieces

| Name | What it does | Timing |
| --- | --- | --- |
| Float (levitate) | The yogi rises about 13 pt and sinks, with a shadow that shrinks to about three quarters and fades as he lifts | 4.5 s, ease in-out, loops |
| Lotus turn | The lotus rotates about its centre | 48 s per turn under the yogi; 120 s for the welcome halo, turning the other way; 60 s on the watch; 30 s on the watch kept screen |
| Ring breathe | Each lotus ring swells to 105% in turn, half a second apart | 7 s, loops |
| Rays | Tone-on-tone rays turn behind the hero | 140 s per turn |
| Slide up | An element rises 14 pt while fading in | 0.35 to 0.5 s, ease out |
| Pop | Scale from 40% with a slight overshoot | 0.5 to 0.6 s |

## Screen by screen

**Welcome.** The golden mandala turns slowly behind the yogi; the green lotus below turns the other way; the yogi floats; petals rise from the lotus and fade (7 to 11 s each, swaying); two soft rings ripple outward every 5 s. All loop.

**Only today.** One day and night in 18 s, looping, starting at noon.
- The sun arcs from behind the left of the hill to behind the right over the first half. Its rays turn and its glow breathes. It must be fully hidden below the hill at both ends.
- The sky fades from soft yellow to dark blue between 40% and 50% of the loop and back between 90% and 6%.
- A slim crescent moon follows the same arc between 47% and 94%.
- About 22 stars fade in for the night and twinkle at their own pace.
- The hills, trees and small yogi darken at night; clouds drift throughout and dim at night.

**Same time, place, things.** A 6.5 s loop.
- 0 to 55%: the clock hands sweep round and settle on 7:00; the pin drops and bounces once; the mat unrolls from under its rolled end.
- At about 55%: a ring chimes out from the clock and under the pin.
- 55 to 88%: everything holds.
- 88 to 100%: a day whirls by: the hands spin, the pin lifts, the mat rolls up.
- The mat must grow in length, not stretch, so its rounded end stays round.

**One mandala (the graph).** Plays once, then rests on the final picture.
1. 0.5 s: the orange dotted willpower path draws over 2.8 s. "Interest fades" appears at its tail.
2. 3.6 s: the green path draws over 4.2 s, led by a dot. As the dot passes, each zone lights up: yellow for days 1 to 6, muted orange with "Boring middle" for days 7 to 27 (both fade once it has crossed), green with "It becomes yours" for days 28 to 48 (stays).
3. 7.8 s: a pink and yellow lotus blooms at the end of the green path, a ring bursts, and about 26 petals shower down the whole screen once.

**How did it feel?** The yellow reply slides up when a choice is made.

**Today is kept.** The yogi floats; nine petals burst outward from behind him and a white ring ripples, every 4.5 s; the rays turn. The "Today · Kept" card pops in at 0.3 s and the "Only tomorrow" card slides up at 0.9 s, once.

**Day 30.** The thirty open petals unfold one by one, 0.06 s apart, each scaling up from its base with a slight overshoot. Once.

**Mandala complete.** The yogi floats above the turning lotus; rays turn; about 28 petals fall continuously in the reference so they can be seen. In the app the petal fall should run for a few seconds and stop.

## Widget

Nothing loops. One animation: tapping Done. See `docs/03-widgets.md` and `design/screens/Widget-Done.html`. The rotating reminder line is a content change, not an animation.

## Apple Watch

The background lotus turns once a minute, the yogi floats, and on the kept screen a bright lotus turns behind him while a ring ripples. Watch-face widgets are still.

## Building it

- Lotus, rays, petals and the yogi's float are best drawn and animated in SwiftUI (`Canvas`, `TimelineView`, `Shape` with animatable data). Rotations and floats should be transforms on whole layers, which is cheap.
- Avoid redrawing a large vector every frame. In the reference, the finishing screen was first built with a very large rotating vector, and the owner reported its animation stopping. The cause was never confirmed, but the screen was rebuilt as flat layers that only rotate and move.
- Timings in the reference are the target. Small adjustments for feel are fine; the order of events is not negotiable.
