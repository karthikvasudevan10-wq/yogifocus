# Yogi Focus: design handoff

Everything needed to build Yogi Focus with Claude Code. Start with `CLAUDE.md`.

## What is in here

| Path | What it is |
| --- | --- |
| `CLAUDE.md` | The brief for Claude Code: the goal, the ten rules, the targets, how to work |
| `docs/` | Nine documents: product, screens, widgets, Apple Watch, design system, motion, platforms, logic and data, open questions |
| `design/index.html` | Open in a browser: links to every screen as a live page with its animations |
| `design/screens/` | 54 live reference pages (HTML and CSS, all vector): 25 light, 11 dark, 18 for iPhone Duo |
| `design/previews/` | A still image of each screen. Reference only; never ship these |
| `design/tokens.json` | Colours, type, spacing and radii as data |
| `design/source/` | The Python that generated the drawings; the exact geometry of every graphic is in here |
| `assets/svg/` | Every graphic as a standalone vector file: the yogi, the lotus, illustrations, icons, the app icon |
| `assets/lotus-geometry.json` | The 48-petal lotus as numbers, for drawing it in code |
| `website/` | A finished single-page marketing website (`index.html`), self-contained apart from Google Fonts |
| `legacy/` | The owner's 2023 SwiftUI source, for context |

## Targets

iPhone, iPhone Duo and Apple Watch. Nothing else.

## Status

This is a design, not an app. The live pages are references for layout, copy and motion. They were checked in a desktop browser, not on devices. `docs/09-open-questions.md` lists what is still undecided or not yet drawn.

The reference pages load their fonts (Baloo 2 and Inter) from Google Fonts, so they need a connection to look right.

Yogi Focus is free for everyone, always.
