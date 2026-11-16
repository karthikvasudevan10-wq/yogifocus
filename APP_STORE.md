# App Store submission

Everything App Store Connect asks for to submit Yogi Focus 1.0, apart from screenshots and your own contact details.

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

## Screenshots (still to make)

App Store Connect needs at least one set per device family you ship. Plan:

| Device | Size (pixels) | Where to capture |
| --- | --- | --- |
| iPhone 6.9" | 1320 × 2868 | iPhone 18 Pro Max simulator |
| iPhone Duo, outer display | 1398 × 2034 | iPhone Duo simulator, display 1 (closed) |
| iPhone Duo, inner display | 2007 × 2853 | iPhone Duo simulator, display 3 |
| Apple Watch | the size App Store Connect lists for the watch you choose | Apple Watch Ultra 3 or Series 12 simulator |

The Duo sizes are the App Store Connect sizes given in `handoff/docs/07-platforms.md`. Check every size against App Store Connect when you upload.

Suggested order, so the story reads in sequence: Welcome; Only today; Give it a home (time, place, things); Today; How did it feel?; That's today, kept; the Home Screen widget; the lotus at day 30. Debug builds can open any of these directly with `YF_SEED` and `YF_SCREEN` (see `YogiFocus/DebugSeed.swift`). Use the light appearance, and set the status bar to 9:41 with `xcrun simctl status_bar booted override --time 9:41`.

## Before you submit

- Add the `ITSAppUsesNonExemptEncryption` key (see above), or answer the question on upload.
- Archive with the **Release** configuration. The debug helpers (`YF_SEED`, `YF_SCREEN`, `YF_FRAME`) are only compiled into Debug builds.
- In the Apple Developer portal, the iCloud container `iCloud.karthikvasudevan.yogifocus` and the App Group `group.karthikvasudevan.yogifocus` must exist and be enabled for the app, watch app and widget identifiers. Xcode's automatic signing usually creates them on the first device build.
- Update the website's "Coming soon to the App Store" buttons with the App Store link once the app is live.
