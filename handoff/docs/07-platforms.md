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

Apple's first foldable iPhone, on sale since 23 October 2026, running iOS 27.1. Design references: `design/screens/Duo-*.html` (18 pages), starting with `Duo-Spec.html`.

Sources: Apple Human Interface Guidelines, "Designing for iPhone Duo" (https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo); "Preparing your app for iPhone Duo" (https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo); Apple tech talks 111461, 111463 and 111466; App Store Connect screenshot specifications.

### Sizes

| | Outer display (closed) | Inner display (open) |
| --- | --- | --- |
| Screenshot size in App Store Connect | 1398 × 2034 px | 2007 × 2853 px |
| Points at 3× (derived) | 466 × 678 | 669 × 951 tall, 951 × 669 wide |
| Size class | Compact width | Regular width |

Apple does not publish point sizes; the numbers above are derived from the screenshot sizes. Never hard-code them. Lay out from the scene's bounds, size classes, safe areas and layout margins, as Apple asks.

### Apple's rules that shape these designs

- **Two layouts, not one per pose.** A compact-width layout for the outer display and a regular-width layout for the inner display. Do not reinvent the app when it resizes.
- **Outer display: controls move to the trailing edge.** The Dynamic Island, status bar, toolbar and tab bar sit in a vertical strip, top to bottom. The outer camera is in the corner, in line with that strip. Back or Close goes at the top of the toolbar, then prominent actions such as Done.
- **Inner display wide: controls stay on the side. Inner display tall: standard horizontal bars.**
- **Show one more level of hierarchy on the inner display** where it makes sense, the way Mail shows the list and the message side by side.
- **The fold.** When partially folded like a book, the fold divides the display into leading and trailing regions. In the tabletop pose it divides it into top and bottom: viewing content on top, tappable controls on the bottom. Keep buttons and text out of the fold. Scrolling content does not need to avoid it.
- **Prefer system containers** (split views, arrangement views, tab views, navigation stacks). Use `ReservedRegion` for custom layouts, and an even number of columns in grids.
- **Full-width backgrounds are fine** for immersive screens, as long as nothing clashes with the Dynamic Island or status bar.
- **Toolbar items need both a symbol and a title.**

### How Yogi Focus uses them

- **Outer display (`Duo-Outer-*`).** The phone layouts, shortened. Back, Done and the routines list move into the trailing strip; the big content button stays at the bottom of the content area. Illustrations shrink to leave room for the text.
- **Inner display wide (`Duo-Wide-*`).** Two regions either side of the fold. Illustration or list on the leading side, words and actions on the trailing side. Today shows the day's routines on the leading side and the selected routine on the trailing side; this is also the drawn version of two routines in a day. The routine picker uses two columns of tiles on the trailing side.
- **Inner display tall (`Duo-Tall-*`).** Drawn for the tabletop pose: what to look at in the top region, what to tap in the bottom region. "How did it feel?" puts the three choices as large buttons in the bottom region.
- **Fold guides.** The owner's design canvas shows a pink band over the fold as a layout guide. It is not in the reference pages or previews in this package, and it must never be drawn in the app. In the app, keep content out of the fold using `ReservedRegion`, not a drawn band.

### Assumptions to check in the Xcode 27.1 iPhone Duo simulator

- The trailing strip is drawn 60 pt wide. Apple does not give a width.
- The fold band is drawn 40 pt wide. Apple does not give a width.
- The black circle drawn at the top of the strip only marks the camera's reserved region.
- The status bar area is left blank in the designs; the system draws it.

## Apple Watch

See `docs/04-apple-watch.md`. Drawn at 208 × 248 pt (46 mm). Scale by width for every case size; test at the smallest.

## System features used

- WidgetKit for the Home Screen widget, Smart Stack card and complications, with App Intents for the Done button.
- Local notifications for the 20-minute nudge, the hour, and the feedback question. The soft chime is the notification sound and can be switched off per routine.
- Haptics on the watch for the nudges.
- The 2023 version added a repeating calendar event through EventKit as its reminder. Whether to keep that is an open question; notifications and the widget now do that job.
