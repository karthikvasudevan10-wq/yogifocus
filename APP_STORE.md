# App Store submission

Everything App Store Connect asks for to submit Yogi Focus 1.0, apart from your own contact details.

The text fields are in [`fastlane/metadata/`](fastlane/metadata/), one file per field, in the layout `fastlane deliver` reads. Paste them into App Store Connect, or upload them all with `fastlane deliver --skip_screenshots --skip_binary_upload`.

Primary language: **English (U.K.)**, to match the app's British spelling.

## App information

| Field | Value | File |
| --- | --- | --- |
| Name | Yogi Focus | `en-GB/name.txt` |
| Subtitle | One routine, one day at a time | `en-GB/subtitle.txt` |
| Bundle ID | karthikvasudevan.yogifocus | |
| SKU | yogifocus (any unique text; never shown) | |
| Primary category | Health & Fitness | `primary_category.txt` |
| Secondary category | Productivity | `secondary_category.txt` |
| Content rights | Does not contain, show or access third-party content | |
| Copyright | 2026 Karthik Vasudevan | `copyright.txt` |

## Version 1.0 page

| Field | File |
| --- | --- |
| Promotional text | `en-GB/promotional_text.txt` |
| Description | `en-GB/description.txt` |
| Keywords | `en-GB/keywords.txt` |
| Support URL | `en-GB/support_url.txt` (the GitHub issues page) |
| Marketing URL | `en-GB/marketing_url.txt` (the website) |
| Privacy policy URL | `en-GB/privacy_url.txt` (the website's privacy page) |
| What's New | Not needed for a first version |

The support URL points at the repository's Issues page, so people can reach you without an email address being published. Apple only asks that it lets people contact you; swap in a contact page or address if you prefer.

## Pricing and availability

- Price: **Free**. No in-app purchases, no subscriptions.
- Availability: all countries and regions, unless you want to limit it.

## App privacy (the "nutrition label")

Answer **"No, we do not collect data from this app."** The label then reads **Data Not Collected**.

Why this is accurate: the app has no server, account, analytics or advertising. Routines, days kept, feelings and notes stay on the device, and in the person's own private iCloud database when iCloud is on. Apple does not count data held only on the device or in the user's private iCloud, where the developer cannot see it, as collected. Notifications are scheduled locally.

## Age rating

Answer **None** or **No** to every content question: violence, sexual content, profanity, horror, drugs, alcohol, tobacco, gambling, contests and medical or treatment information. Also answer **No** to the capabilities: unrestricted web access, user-generated content, messaging or chat, advertising, and location sharing. The expected rating is **4+**.

## Export compliance

The app uses no encryption beyond what Apple's operating systems provide (HTTPS and CloudKit). Answer that it **uses no non-exempt encryption**. To skip the question on every upload, add `ITSAppUsesNonExemptEncryption = NO` to the app's Info.plist. That is not in the project yet.

## App Review information

- **Sign-in required:** No.
- **Notes:** [`fastlane/metadata/review_information/notes.txt`](fastlane/metadata/review_information/notes.txt). They explain how to get through setup, why progress stays hidden until day 30, and where the widget and watch app are.
- **Contact:** your first name, last name, phone and email. These are for Apple only and are not stored in this repository; enter them in App Store Connect.

## Screenshots

In [`fastlane/screenshots/en-GB/`](fastlane/screenshots/en-GB/): RGB PNGs (App Store Connect rejects images with transparency), light appearance, with the example routine (Meditate, 7:00 am, the balcony).

| Set | Size (pixels) | Files | Captured on |
| --- | --- | --- | --- |
| iPhone 6.9" | 1320 × 2868 | `iPhone69-01` to `08` | iPhone 18 Pro Max simulator, status bar at 9:41 |
| iPhone Duo, inner display | 2007 × 2853 | `DuoInner-01` to `08` | iPhone Duo simulator, inner display held tall, status bar at 9:41 |
| iPhone Duo, outer display | 1398 × 2034 | `DuoOuter-01` to `08` | the outer layout drawn at its 466 × 678 pt size and cropped (the simulator cannot be closed) |
| Apple Watch | 416 × 496 | `Watch-01` to `04` | Apple Watch Series 12 (46 mm) simulator |

The order tells the story:
1. Welcome
2. Only today
3. Give it a home
4. The widget
5. Today, in the 20 minutes before the hour
6. How did it feel?
7. That's today, kept
8. The mandala at day 37

The watch set is: It's time; How did it feel?; That's today, kept; In 20 minutes.

Notes:
- **Duo outer set:** it has no system status bar, because it was drawn at the outer display's size rather than on a closed device.
- **Watch set:** the watch simulator cannot fake the time, so its clock shows the time of capture.
- **Widget screenshot:** it shows the widget preview inside the app's "Add the widget" screen, not a real Home Screen.
- **Matching sizes:** check each size against the slots App Store Connect offers when you upload. `fastlane deliver` recognises the iPhone 6.9" and watch sizes by their pixel size; the Duo sizes may need uploading by hand until fastlane knows them.

To recapture, use a Debug build:
- `YF_SEED` sets the day of the mandala.
- `YF_SCREEN` opens a screen directly.
- `YF_DEMO=1` fills in example answers.
- `YF_TIME=06:40` sets Today's moment.
- `YF_FRAME=466x678` draws the outer display.
- `YF_WATCH_SCREEN` picks the watch screen.

`YogiFocus/DebugSeed.swift` describes each one.

## Before you submit

- Add the `ITSAppUsesNonExemptEncryption` key (see above), or answer the question on upload.
- Archive with the **Release** configuration. The debug helpers (`YF_SEED`, `YF_SCREEN`, `YF_FRAME`) are only compiled into Debug builds.
- In the Apple Developer portal, the iCloud container `iCloud.karthikvasudevan.yogifocus` and the App Group `group.karthikvasudevan.yogifocus` must exist and be enabled for the app, watch app and widget identifiers. Xcode's automatic signing usually creates them on the first device build.
- The website links to the App Store: https://apps.apple.com/app/id6835473975
