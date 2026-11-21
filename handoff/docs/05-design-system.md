# Design system

Machine-readable values are in `design/tokens.json`. The owner asked for a look that is bright, fresh and vibrant, with few distractions. An earlier muted teal version was rejected as looking like "a hospital visit".

## Colour

| Name | Value | Use |
| --- | --- | --- |
| Leaf green | `#6FD43A` | Primary buttons, full-colour screens, the mat, outer lotus petals |
| Mid green | `#3DBB45` | Middle lotus ring, bars, front hill |
| Deep leaf | `#17933F` | Inner lotus ring, trees |
| Text green | `#127A35` | Links, icons, small labels on light grounds, the wordmark |
| Soft green | `#E6F8D2` | Panels, selected fills, "kept" widgets |
| Sunny yellow | `#FFD21F` | Welcome and kept screens, quote cards, chips, lotus centre, "It's time" widgets |
| Soft yellow | `#FFF3B0` | "In 20 minutes" widgets, the day sky |
| Saffron | `#FF7A1A` | The yogi's robe, the sun, today's petal, the "It's time" dot |
| Ink | `#14301F` | All main text; buttons on yellow and green screens |
| Muted | `#4F6355` | Secondary text on light grounds only |
| Ground | `#FFFEF8` | Default screen background |
| Line | `#E2EBD6` | Card borders and dividers |
| White | `#FFFFFF` | Cards, widgets |

Rules:

- Bright green is too light for white text. Buttons in leaf green carry Ink text. On yellow or green screens the primary button is Ink with white text.
- On yellow or green grounds use Ink for all text; Muted does not have enough contrast there.
- Small text and icons on white use Text green, not Leaf green.
- Feelings are never colour-coded good or bad. All three use the same colours.
- The muted orange-red `#F2AE8B` is used once: the boring-middle zone on the 48-day graph. The willpower path is `#E8792B`, its label `#A84A12`.
- Night scene: sky `#14284F`, moon `#FFF6CF`, moon glow `#2C4C8C`.

## Dark appearance

The app follows the system appearance. Eleven screens are drawn in the dark (`design/screens/*-Dark.html`): Welcome, Only today, How Yogi Focus helps, Choose one routine, Time place things, Today, How did it feel, Today is kept, Mandala progress, Mandala complete, and the small widget board. The rest follow the same rules. Values are in `design/tokens.json` under `dark`.

| Role | Light | Dark |
| --- | --- | --- |
| Ground | `#FFFEF8` | `#0E1A11` |
| Card and widget surface | `#FFFFFF` | `#18271B` |
| Main text | `#14301F` | `#EEF5E8` |
| Secondary text | `#4F6355` | `#A9B8A5` |
| Links, icons, small labels | `#127A35` | `#8AE264` |
| Soft green surface | `#E6F8D2` | `#1C3A21` |
| Soft yellow surface | `#FFF3B0` | `#3A3512` |
| Borders | `#E2EBD6` | `#2C3D2E` |
| Lotus petal still to come | `#EEF4E6`, edge `#D9E4CC` | `#233327`, edge `#34483A` |

Rules for the dark:

- The vibrant colours do not change: leaf green, sunny yellow, saffron, the lotus greens, the red for missed days, and the whole yogi.
- Bright surfaces stay bright and keep dark text `#14301F`: the green primary button, yellow statement cards and chips, the "It's time" widget, the lotus centre.
- The full-colour screens go dark instead of yellow or green. Welcome and Today is kept use `#111F10`; Mandala complete uses `#0F2212`. Their main button becomes the bright green one. Rays and the welcome mandala become dark tone-on-tone.
- Illustration panels (the day and night scene, the clock scene, the graph) keep their own colours.
- Apple Watch is already dark and has one appearance.

## Type

- Headings and the name: **Baloo 2**, weights 600 and 700. It also sets the Sanskrit verse (it includes Devanagari). It is under the SIL Open Font License and must be bundled.
- Body: **Inter**, weights 400, 500 and 600, in the reference. Whether to bundle Inter or use the system font on Apple platforms is an open question.

| Role | Size | Weight |
| --- | --- | --- |
| Screen heading | 34 to 42 pt, line height 1.1 | Baloo 2, 700 |
| Welcome sub-heading | 30 pt | Baloo 2, 600 |
| Card statement | 20 to 22 pt | Baloo 2, 600 |
| Body | 16 to 17 pt, line height 1.55 | Inter, 400 |
| Secondary | 14 to 15 pt | Inter, 400 or 500 |
| Label | 12.5 to 13.5 pt | Inter, 600 |
| Button | 17 pt | Inter, 600 |

Support Dynamic Type. Sizes above are the default size.

## Layout and shape

- Screen margins 28 pt. Top inset 56 pt, bottom 34 pt (plus safe areas).
- Primary button: full width, 56 pt tall, fully rounded. Secondary: 48 pt, outline.
- Cards: 22 to 26 pt radius, 1 pt Line border, white. Statement cards: 22 pt radius, Sunny yellow.
- Chips: fully rounded, 13 pt label.
- Touch targets at least 44 pt.
- No tab bar, no fake status bar, no shadows, no gradients.

## The yogi

An original character. Files in `assets/svg/yogi/`, drawn in a 200 × 200 box.

- Slim and upright, hair in a bun tied with a saffron band, prayer beads, a saffron robe draped over one shoulder with one arm bare, crossed legs with feet showing.
- Three expressions and poses:
  - **Calm**: eyes closed, small smile, hands resting on the knees. Used on Today-type screens, the idle widgets and the small scene.
  - **Joyful**: eyes open, broad smile. Used after Done, on the kept screen, on day 48, on the kept watch screen.
  - **Namaste, joyful**: palms together at the chest. Used only on Welcome.
- Lower robe: yellow by default; white on yellow grounds, where yellow would vanish.
- He floats: a slow rise and fall with a soft shadow that shrinks as he lifts. With a mat he sits still (widgets).
- Never put him on a white disc. The owner disliked that.

## The lotus

48 petals in three rings of 16, one petal per day of the mandala. Geometry is in `assets/lotus-geometry.json`; build it in code.

- Day 1 is the top petal of the inner ring; days run clockwise, then the middle ring, then the outer.
- Each petal is one day of the 48. Practised: Deep leaf, Mid green, Leaf green from inside out. Missed: red `#E0453F`. Still to come: `#EEF4E6` with a `#D9E4CC` edge. Today's petal once kept: Saffron. Centre disc: Sunny yellow, carrying the number of days practised.
- Red and green must not be the only signal: always pair the lotus with the count in words.
- As progress it may be shown only after day 30.
- As decoration (all petals one tone) it may be used any time: behind widgets, as the welcome halo in gold, under the floating yogi seen at an angle, on the watch in dark green.

## Icons

25 line icons, 24 × 24, 1.8 pt round strokes, in `assets/svg/icons/`. Feelings use abstract glyphs (scattered dots, two waves, concentric rings), never faces. No emoji anywhere.

## App icon

Version 2. The yogi's head and shoulders, large, in front of a bold eight-petal lotus in two greens, on Sunny yellow. Eyes closed in a happy upward curve, like ^ ^ (calm but awake, never sleepy), gentle smile, hair bun with a saffron band, saffron robe over one shoulder, prayer beads. Chosen because it stays readable at the smallest sizes, down to the 32 pt watch icon. The options considered are in `design/app-icon-v2-options/` (the chosen one is `G-smile`). Files in `assets/svg/app-icon/`, all 1024 × 1024 with square corners; the system applies the mask.

- `ios-icon-light.svg`: the default.
- `ios-icon-dark.svg`: the same on a dark green ground `#10281A`.
- `ios-icon-tinted.svg`: a greyscale version for the system tint.
- `watch-icon.svg`: the same design; the lotus and face already sit clear of the circular mask.

The dark and tinted versions were derived from the light one and have not been tuned by hand. Version 1 (a small seated yogi on a rosette) was replaced because the yogi was too small to see on the watch. The shipped app (1.0) still uses version 1; swapping the app's AppIcon set is part of v2.
