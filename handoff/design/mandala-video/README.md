# The mandala video

When someone taps **Share my mandala** on the mandala complete screen, the app makes a 12-second video of their own mandala, on the phone, and offers it to share. Nothing is uploaded; there is no server. The person chooses where it goes.

`yogi-focus-mandala.mp4` is the reference: what the app's video should look like, frame for frame. `clip.html` draws any moment of it from a time `t` (see `render(t)`), so it is the exact timeline to copy. `build.py` writes `clip.html`; `shoot.js` films it (only used to make the reference).

Designs: canvas row 20, boards "Share · making the video on the phone" and "Share · the video, ready" (light and dark).

## What goes in it

| From the person's data | Shown as |
|---|---|
| Routine name | Title, e.g. "Meditate" (shrink the font for long custom names; one line) |
| Mandala number (`mandalaNumber` of the one just completed) | "My first mandala", "My 2nd mandala", "My 3rd mandala"… |
| Mandala length (`Mandala.days`, 48 today) | "Day 1" … "Day 48", then "48 days" |

Never in it: place, things, times, feelings, notes, missed days. Every petal is shown open: the video celebrates finishing the mandala.

## Timeline (12 s, 30 fps, 1080 × 1920)

| Time | What happens |
|---|---|
| 0.0–1.3 s | Green background; white sun rays fade in and turn slowly (3°/s, whole clip). "Meditate" rises in (0.2 s), "My 3rd mandala" above it (0.5 s). Pale outlines of all 48 petals; the saffron centre appears at 0.9 s. |
| 1.1–6.3 s | One petal opens every 0.1 s, day 1 to 48, inner ring first (white, then cream, then yellow outer ring). Each petal grows from its base with a slight overshoot over 0.5 s. The counter below shows "Day n" in step. |
| ~6.1 s | The yogi rises 160 px into the centre over 0.9 s and starts floating (14 px, 4.5 s period). A soft glow fills behind the lotus. |
| 6.4 s | A white ring bursts outward; 18 petals fly out; confetti starts falling. Soft two-note chime (784 Hz then 1046.5 Hz, about 0.3 s apart, gentle decay). |
| 6.6 s | The counter becomes "48 days", popping in. The lotus begins turning slowly (2.2°/s). |
| 7.3 s | "One day at a time." fades in. |
| 8.1 s | The Yogi Focus mark (icon and name) fades in at the bottom. |
| 8–12 s | Hold: yogi floating, lotus turning, confetti falling. |

## How the app makes it (no server)

- **Draw:** a SwiftUI view, `MandalaClipView(t:routineName:mandalaNumber:days:)`, whose look is a pure function of `t`, the same way `render(t)` is in `clip.html`. Reuse the app's existing vector lotus and yogi (`Lotus.swift`, `Art.swift`); no images to download.
- **Encode:** for each frame `i` in 0..<360, render the view at `t = i / 30` with `ImageRenderer` (size 1080 × 1920, scale 1) to a `CVPixelBuffer`, and append it through `AVAssetWriterInputPixelBufferAdaptor` (H.264, about 8 Mbit/s, `.mp4`). Show progress on the "Making your video" screen. On recent iPhones this should take a few seconds; if it is slow, render in batches and yield between them so the screen stays responsive.
- **Sound:** a short bundled chime file (`mandala-chime.caf`, made from the notes above), added at 6.4 s with an audio input on the same writer or an `AVMutableComposition` pass-through export.
- **Cache:** save to the app's caches folder, named by routine and mandala number; reuse it if they share again. Delete it when the routine is removed.
- **Reduce Motion:** still make the video (it's for other people), but the in-app preview shows a still frame with a play button instead of autoplaying.
- **Image instead:** the "Image" choice uses the final frame (t = 12 s) as a PNG; same layout as the still image board.

## Sharing it

- **Instagram Stories:** put the video data on the pasteboard as `com.instagram.sharedSticker.backgroundVideo` with `source_application` set to the free Facebook App ID, then open `instagram-stories://share?source_application=…`. Add `instagram-stories` to `LSApplicationQueriesSchemes`. Hide the button if Instagram isn't installed.
- **More:** `ShareLink` or `UIActivityViewController` with the file URL: Instagram feed and Reels, TikTok, WhatsApp, Messages, Mail and Save Video all appear there. No TikTok SDK needed.
- **Save video:** `PHPhotoLibrary` with add-only access (`NSPhotoLibraryAddUsageDescription`: "Save your mandala video to Photos."). Ask only when they tap it.
- **Privacy page:** add one line: the mandala video and image are made on your phone and go only where you choose to share them.
