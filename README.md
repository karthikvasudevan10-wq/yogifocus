# Yogi Focus

A free app that helps people keep one small routine, one day at a time, using a method yogis have used for centuries. Built for people who find it hard to focus, keep a routine or form a habit.

Website: https://karthikvasudevan10-wq.github.io/yogifocus/

## What is here

| Path | What it is |
| --- | --- |
| `YogiFocus/` | The iPhone app (SwiftUI): introduction, setup, Today, how it felt, the lotus mandala, routines |
| `YogiFocusWidgets/` | The Home Screen widget, small, medium and large, with Done at the hour |
| `YogiFocusWatch/` | The Apple Watch app: haptic nudges, Done, and how it felt on the wrist |
| `YogiFocusWatchWidgets/` | Watch-face complications and the Smart Stack card |
| `YogiKit/` | Shared Swift package: data model, iCloud-backed store, words and phases, the lotus, the yogi, the widget views, notifications |
| `Config/` | Entitlements and Info.plist files |
| `docs/` | The website, served by GitHub Pages |
| `handoff/` | The design handoff the app was built from: product rules, screens, motion, tokens and vector artwork |

## Building

Open `YogiFocus.xcodeproj` in Xcode 27 and run the `YogiFocus` scheme. The watch app and both widget extensions are embedded in it.

Debug builds accept a `YF_SEED` environment variable to jump to any day of the mandala, for example `day=37;missed=9,17,33;kept=1`, or `reset=1` to see the introduction again. See `YogiFocus/DebugSeed.swift`.

## iPhone Duo

The Duo has its own layouts, from the design pack in `handoff/design/screens/Duo-*.html` and `handoff/docs/07-platforms.md`. Other iPhones are not affected.

- **Closed (outer display):** the phone screens, shortened. Back, Done and the routines list sit in a strip on the trailing edge.
- **Open wide:** two regions either side of the fold, with the same strip. Today lists the day's routines beside the selected one; Your routines shows the list beside the detail.
- **Open tall (tabletop):** a standard top bar, what to look at above the fold and what to tap below it.

The layouts live in `YogiFocus/Duo.swift` (pose, strip, fold regions) and in each screen's `duoBody`. In a debug build, `YF_FRAME=466x678` lays the app out at the outer display's size on any simulator.

## Data

Routines, days kept, feelings, notes and mandala progress are stored with SwiftData in the App Group container and mirrored to the person's private iCloud database (`iCloud.karthikvasudevan.yogifocus`), so they follow the person to a new phone. Nothing is sent to any server.

## Fonts

Baloo 2 and Inter are bundled under the SIL Open Font License; see `YogiKit/Sources/YogiKit/Resources/Fonts/`.
