# Promoting Yogi Focus for free

Ideas that cost nothing but time. Ordered roughly by value for effort. The app is free with no ads, which opens doors paid apps don't have: communities that ban promotion often welcome a genuinely free tool.

App Store: https://apps.apple.com/app/id6835473975
Website: https://karthikvasudevan10-wq.github.io/yogifocus/

## This week

- [ ] **Nominate for App Store featuring.** App Store Connect → Featuring → Nominations. Pitch: the no-guilt approach, the yogi and lotus design, Apple Watch, widgets with buttons, iPhone Duo layouts. Free, and Apple's editors read them. (v2 item 30.)
- [ ] **Post a launch story on Reddit.** A personal "I built a free habit app with no streaks and no guilt" post, with the lotus animation as a video. Good places: r/SideProject, r/iOSapps, r/apple (Saturday self-promotion threads only), r/getdisciplined, r/habits, r/Meditation, r/selfimprovement. Read each community's rules first; many allow it only in weekly threads. Reply to every comment.
- [ ] **Launch on Product Hunt.** Free. Launch on a Tuesday to Thursday, 12:01 am Pacific. Prepare the gallery from the App Store screenshots and the preview image in `docs/og-image.jpg`.
- [ ] **Share with friends and family on WhatsApp.** The website link now shows a card with the yogi. Ask the first 20 people who like it to leave a rating; early ratings matter most for search.

## Short videos (biggest free reach)

- [ ] **TikTok, Instagram Reels and YouTube Shorts, the same clip on all three.** 10–20 seconds, vertical, with captions. Record in the simulator with `xcrun simctl io booted recordVideo` and the debug seed (`YF_SEED`, `YF_DEMO`) to show any day.
- Ideas that tend to travel:
  - "What 49 days of meditation looks like": the lotus filling petal by petal.
  - "An app that never makes you feel guilty": a missed day, and the kind message instead of a broken streak.
  - "Same time. Same place. Same things.": the setup in 15 seconds.
  - The yogi levitating, with calm music.
  - "I built this app myself", the maker's story.
- Post three times a week for a month before judging what works. Reply to comments with short videos.

## Communities and press

- [ ] **Hacker News "Show HN".** A plain post about why it has no streaks, with the website link. Best early on weekday mornings, US time.
- [ ] **Indie Hackers.** A build-in-public post, then monthly updates with real download numbers.
- [ ] **Apple and indie-app newsletters and blogs.** Short, personal emails to people who cover new indie iPhone apps (for example MacStories, 9to5Mac's app roundups, AppAdvice, iMore). Include the preview image, two screenshots and one line on what's different. Many won't reply; a few will.
- [ ] **iPhone Duo coverage.** Few apps have Duo layouts yet. Sites covering the Duo are looking for apps to show; this is the easiest press angle.
- [ ] **Yoga and meditation teachers.** Offer it free to studios and teachers on Instagram for their students. The yogi and mandala theme fits; they need nothing from you.
- [ ] **International Yoga Day, 21 June.** Plan a post and a featuring nomination a few weeks ahead. Also New Year (habit season) and the start of September.

## Built into the app (no cost, keeps working)

- **Share a completed mandala** (v2 item 6): every person who finishes becomes a post.
- **Share Yogi Focus** (v2 item 32) and **the rating prompt at a happy moment** (v2 item 29).
- **Store text in more languages** (v2 items 27 and 28): more search terms in more countries, including US English and Chinese.

## Search on the App Store

- Check which keywords bring people in: App Store Connect → Analytics → Sources, after a few weeks.
- Swap low-value keywords in `fastlane/metadata/en-GB/keywords.txt` each update; keyword changes go live only with a new version.
- Use Promotional Text (changes any time, no review) for seasonal lines, such as "Start the new year with one small routine."

## Your own channels

- [ ] A short post on LinkedIn about building it; people share personal launch stories more than adverts.
- [ ] Add the App Store link to your email signature and social profiles.
- [ ] A link in the GitHub README (done) and a pinned GitHub repo on your profile.
