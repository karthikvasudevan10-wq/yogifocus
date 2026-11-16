# Yogi Focus

A free app that helps people keep one small routine, one day at a time, using a method yogis have used for centuries. Built for people who find it hard to focus, keep a routine or form a habit.

This folder is a design handoff. It holds the product brief, every screen and widget as a live HTML reference, every graphic as a vector file, and the 2023 SwiftUI source of an earlier attempt. Nothing here is production code yet. Your job is to build the app from it.

## Read these first, in order

1. `docs/01-product.md`: the goal, who it is for, and the rules that must not be broken.
2. `docs/02-screens.md`: every screen, its copy, its states and where it leads.
3. `docs/03-widgets.md`: the Home Screen widget in three sizes, and what Apple allows.
4. `docs/04-apple-watch.md`: the watch screens, the haptic nudges and feedback on the wrist.
5. `docs/05-design-system.md`: colours, type, spacing, shapes, the yogi and the lotus.
6. `docs/06-motion.md`: every animation, with timings.
7. `docs/07-platforms.md`: iPhone, iPhone Duo and Apple Watch, and how layouts must scale.
8. `docs/08-logic-and-data.md`: phases, the day-30 rule, routines, reflections, notifications.
9. `docs/09-open-questions.md`: decisions the owner has not made yet. Ask before building these.

Open `design/index.html` in a browser to see every screen with its animations running. `design/previews/` has a still image of each screen for quick reference.

## The rules that must not be broken

These come straight from the owner. If a build decision conflicts with one of them, the rule wins.

1. **One day at a time.** The app never asks the person to commit to forever. Every message is about today, or at most tomorrow.
2. **Same time, same place, same things.** A routine is defined by its hour, its place and the things used (mat, clothes). The app reminds people of all three.
3. **One mandala is 48 days.** That is the journey the app supports.
4. **No tracking shown before day 30.** No streak, no petal count, no day number and no lotus progress may appear anywhere (app, widget, watch) until the person has crossed 30 days. From then on the lotus mandala may be shown.
5. **Only positive reinforcement.** No blame, no guilt, no sad mascot, no red badges, no "you broke your streak". A missed hour or a missed day is met with "just start".
6. **The boring middle is days 7 to 27.** In that window the app's one message is: just start. Dull is normal and it passes.
7. **Beginners start with exactly one routine, of at least ten minutes.** In the first week the app also tells them to stop at ten minutes. A second routine is offered only when the first mandala is complete.
8. **Success is the habit, not app usage.** Do not add anything designed to bring people back to the app: no engagement loops, no daily-open rewards. This is a design principle, not a message: never tell users that the app wants to be opened less.
9. **Free for everyone, always.** No price, no subscription, no in-app purchase, no paid tier.
10. **A missed day never resets the mandala.** A mandala is 48 days on the calendar. A day practised opens a green petal; a missed day leaves a red petal. Once the lotus is visible (from day 30), the app states the number plainly and without blame, for example "Out of 48 days, you practised 45 and missed 3."

## What to build for

- iPhone.
- iPhone Duo (the foldable): both the outer display and the open inner display.
- Apple Watch.

Nothing else. Do not add iPad, Mac, Vision Pro, CarPlay or a web version, and do not add layouts tuned for them.

## The website

`website/index.html` is a finished single-page site for the app, built from the same graphics and copy. It is plain HTML, CSS and inline SVG with no build step; it loads Baloo 2 and Inter from Google Fonts. Before it goes live:

- Replace the two visible placeholders: `[APP STORE LINK TO ADD]` (and point the "Get it free" and "Download on the App Store" buttons at that link), and `[CONTACT AND PRIVACY LINKS TO ADD]` in the footer.
- If it launches before the app is on the App Store, change the buttons to "Coming soon".
- It has one bright appearance on purpose; it does not switch to dark.
- Keep its wording in step with `docs/02-screens.md` if the app's copy changes.
- Its FAQ answers describe app behaviour (missed days, travel, progress after day 30, free). If the app's behaviour changes, update the FAQ to match.

The website is not one of the app's targets; the "nothing else" rule above is about the app.

## Light and dark

The app follows the system appearance. Light is the main design; dark is drawn for eleven screens and specified as rules and colours for the rest. See "Dark appearance" in `docs/05-design-system.md`.

## Graphics must be vector

Every graphic in the app must be resolution independent, so it stays sharp from a watch to the open iPhone Duo. No PNG or JPEG artwork in the app bundle.

- Prefer drawing in code: SwiftUI `Shape`, `Path` and `Canvas`. The lotus in particular should be generated from `assets/lotus-geometry.json`, because its petals open one by one and must animate.
- Where a graphic is static, import the SVG from `assets/svg/` as a vector asset with "Preserve Vector Data" on.
- The images in `design/previews/` are reference pictures only. Never ship them.

## How to work

- The legacy code in `legacy/` shows the owner's earlier SwiftUI, SwiftData and EventKit approach. Reuse what is sound; drop the streak calendar and the sad-face rating, which the owner has rejected. See `docs/08-logic-and-data.md`.
- Copy in `docs/02-screens.md` is final wording unless marked otherwise. Keep British spelling ("practise" as the verb).
- Do not invent statistics, research claims or health claims. The 48-day graph is the owner's illustration of how things tend to go, not measured data; it has no numbers on purpose.
- Honour Reduce Motion: every animation needs a still fallback.
- When something is not covered, check `docs/09-open-questions.md`, then ask the owner. Do not guess on anything that touches the ten rules.
