# Platforms

The app targets three things and nothing else:

1. iPhone
2. iPhone Duo
3. Apple Watch

Do not add iPad, Mac, Vision Pro, CarPlay, tvOS or web, and do not ship layouts tuned for them.

## Vector everywhere

All artwork must scale cleanly across these screens, so nothing in the app may be a bitmap.

- Draw in code where the graphic animates or changes: the lotus, rays, petals, the sun and moon scene, the graph.
- Use the SVG files in `assets/svg/` as vector assets (Preserve Vector Data) where the graphic is static, such as icons and the yogi.
- Size graphics as a fraction of the available width, never in fixed pixels. The references use 390 pt as the width; treat every measurement there as a proportion of 390.

## iPhone

Designed at 390 × 844 pt. Scale the hero graphics with the width; keep text sizes fixed (they follow Dynamic Type). Keep the 28 pt margins. The primary button stays pinned to the bottom safe area.

## iPhone Duo

Apple's first foldable iPhone, announced on 9 September 2026 and on sale from 23 October 2026. It has two displays, and the app must look right on both.

| | Outer display (closed) | Inner display (open) |
| --- | --- | --- |
| Size | 5.4 inch | 7.6 inch |
| Pixels | 1398 × 2034 | 1878 × 2670 |
| Points, as reported | 466 × 678 | 626 × 890 by simple division at 3×; 669 × 951 according to App Store Connect and Xcode readings |
| Shape (height ÷ width) | about 1.45 | about 1.42 |
| Size class, as reported | Compact width, regular height | Regular width, regular height |

The point sizes come from third-party write-ups and disagree for the inner display. Do not hard-code any of them. Read the size at run time and check in the current Xcode simulator.

Sources: https://www.macrumors.com/roundup/iphone-duo/ , https://blakecrosley.com/blog/iphone-duo-for-developers , https://foldhunt.com/guides/iphone-duo-screen-sizes/

What this means for the design, which was drawn for a tall 390 × 844 screen:

- **Both Duo displays are much squarer than a normal iPhone.** The outer display is wider and about 170 pt shorter than the reference. Screens with a tall hero (Welcome, Today is kept, Mandala complete) will not fit as drawn. Scale the hero to the height that is left after the text and button, not to the width.
- **Open, the inner display is wide.** Do not stretch the phone layout across it. Keep text in a column no wider than about 430 pt. Suggested arrangement for hero screens: graphic on one side, text and button on the other. This has not been drawn or approved; see open questions.
- The fold runs across the inner display. Keep buttons and text off the fold line; use the system's layout guides for it.
- The layout must adapt live when the phone is opened or closed.
- Widgets are the system's sizes and need no change.

## Apple Watch

See `docs/04-apple-watch.md`. Drawn at 208 × 248 pt (46 mm). Scale by width for every case size; test at the smallest.

## System features used

- WidgetKit for the Home Screen widget, Smart Stack card and complications, with App Intents for the Done button.
- Local notifications for the 20-minute nudge, the hour, and the feedback question. The soft chime is the notification sound and can be switched off per routine.
- Haptics on the watch for the nudges.
- The 2023 version added a repeating calendar event through EventKit as its reminder. Whether to keep that is an open question; notifications and the widget now do that job.
