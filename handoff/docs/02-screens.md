# Screens

Every screen was drawn at 390 × 844 points. Each has a live reference in `design/screens/` and a still in `design/previews/`. Copy below is the final wording. The example routine throughout is Meditate, 7:00 am, the balcony, with a yoga mat and grey shawl.

Common layout: 28 pt side margins, 56 pt top inset, 34 pt bottom inset, one primary button pinned to the bottom, no tab bar.

## 1. Understand the idea

### Welcome (`Main.html`)
Full bright yellow. Top half is the hero scene: a smiling yogi with palms together floats above a large green lotus, with a golden 48-petal mandala turning behind him and petals rising.

- Greeting: Namaste, and welcome.
- Name: Yogi Focus
- Heading: One small routine. One day at a time.
- Body: Come as you are. Scattered days and missed days are welcome here too. We'll go gently.
- Button: Begin → Only today

### Idea 1: Only today (`Idea-Today.html`)
Step label "1 of 3". Scene: a full day and night loop over a hill where a small yogi sits.

- Heading: Only today.
- Body: “Do this every day for the rest of your life” is too heavy to carry. So a yogi doesn't carry it. Each morning they ask a single question.
- Yellow card: This is a new day. How will I keep my practice today?
- Small line: It is the only thing Yogi Focus will ever ask of you.
- Button: Next

### Idea 2: Same time, place, things (`Idea-Same.html`)
Step label "2 of 3". Scene: a clock settling on 7:00, a pin dropping, a mat unrolling.

- Heading: Same time. Same place. Same things.
- Body: A yogi practises at the exact hour, in the exact spot, with the same mat and the same clothes.
- Body: When nothing around the routine changes, there is nothing to decide and nothing to remember. The moment itself reminds you.
- Button: Next

### Idea 3: One mandala (`Idea-Mandala.html`)
Step label "3 of 3". Graph of the 48 days with two paths. It animates once, then rests.

- Graph labels: Days 1–6, Days 7–27, Days 28–48; "Interest fades" beside the orange path; "Boring middle" while the green path crosses days 7 to 27; "It becomes yours" in the last zone.
- Heading: One mandala is 48 days.
- Body: Yogis hold that a practice kept for one mandala is likely to stay for life. This is how those 48 days tend to go.
- Willpower alone (orange dotted): A burst of effort, a crash in the boring middle, and then interest quietly dies.
- With Yogi Focus (green solid): A gentle ten-minute start, a shallow dip, a nudge to just start, and by the end it runs on its own.
- Button: Next

The graph has no axis and no percentages on purpose.

### How Yogi Focus helps you build a routine (`How-Yogi-Helps.html`)
An invitation to set the first routine. Illustration at the top: a smiling yogi with palms together floats above a turning lotus, beside a small tilted "It's time · Meditate · Done" widget, with little hearts rising.

- Heading: How Yogi Focus helps you build a routine
- A gentle nudge, right on time: A widget on your Home Screen shows the hour, the place and what to bring.
- A kind word every day: Tell Yogi Focus how your practice felt. Every answer is a good one.
- A lotus that blooms with you: Each day you practise opens a petal. After 30 days, you get to see it.
- Yellow card: Ten minutes a day is all it takes to begin. Let's choose your first routine.
- Button: Choose my first routine

This screen must stay positive. It must not say that the app "stays out of your way" or that opening the app is not the goal. That is true of the design, but the owner does not want it said to users.

## 2. Set up and manage routines

### Choose one routine (`Choose-Routine.html`)
- Heading: What would you like to practise?
- Sub: Choose one, and only one. Ten minutes a day to begin.
- Twelve tiles, single choice: Meditate, Stretch, Exercise or sport, Walk, Eating habits, Read, Journal, Play music, Study, Tidy up, Plan my day, My own.
- Footnote: When your first mandala is complete, Yogi Focus will invite you to add another.
- Button: Continue

"Eating habits" needs its own setup and is not designed yet. See open questions.

### Time, place, things (`Anchor.html`)
- Heading: Give Meditate a home.
- Sub: The more exact you are, the easier it is to begin.
- When: 7:00 am, for 10 minutes. Where: a text field. With: chips, plus an add button.
- Note: A first routine is ten minutes. No less, and for the first week, no more.
- Yellow card, "Your routine": Each day at 7:00 am, I go to the balcony with my yoga mat and grey shawl, and meditate for ten minutes. The sentence updates as the fields change.
- Button: This is my routine

### Add the widget (`Widget-Setup.html`)
- Top right: Not now
- Heading: Let your Home Screen do the remembering.
- A medium widget preview.
- Steps: 1. Touch and hold an empty spot on your Home Screen. 2. Tap Edit, then Add Widget. 3. Search for Yogi Focus and choose a size.
- Switch, on by default: A soft chime at 7:00 am
- Small line: No badges, no streak alerts, no nagging.
- Button: I've added it

### Your routines (`Routines.html`)
Reached from the list icon at the top right of every Today screen.

- Heading: Your routines
- Sub: Each one has its own hour, its own place and its own things.
- One card per routine in time order: name, hour and length, place, things, a chip for today's state ("Kept today" or "Next, 9:30 pm"), and an Edit link. No petal counts here. A routine with a finished mandala shows "First mandala complete"; a new one shows "In its first days".
- Dashed button: Add a routine
- Footnote: Add slowly. Give each routine a full mandala before you start the next.

For a beginner this list has one routine. Adding a second is offered only after the first mandala is complete.

### Routine settings (`Routine-Edit.html`)
- When, Where, With: as on the setup screen.
- Switch: A soft chime at 7:00 am
- Switch: Pause this routine. The widget goes quiet. Nothing is lost.
- Text button: Remove this routine
- Button: Save

## 3. The Home Screen widget

See `docs/03-widgets.md`.

## 4. Each day, days 1 to 6

### Today (`Today.html`)
- Header: Yogi Focus, and the routines list icon.
- Date, then heading: A new day.
- Sub: How will you keep your practice today?
- Routine card: a chip with the state ("In 20 minutes"), the name, the hour and length, the place, the things.
- First-week line: This first week, stop at ten minutes, even if you would like more.
- Button: I've practised today → How did it feel?

No count, no day number, no lotus.

### How did it feel? (`Reflect.html`)
- Heading: You practised today.
- Sub: How did it feel? There is no wrong answer.
- Three choices, each with an abstract glyph, never a face:
  - Scattered: My mind was everywhere
  - Steady: I stayed with it, mostly
  - Absorbed: I lost track of time
- A yellow reply appears for the choice:
  - Scattered: Scattered days build the habit more than easy ones. You came anyway.
  - Steady: Steady is exactly how a practice grows.
  - Absorbed: Hold on to this feeling. It is what the practice gives back.
- Optional field: A note for yourself (optional). Placeholder: Anything you noticed
- Button: Done → Today is kept

### Today is kept (`Kept.html`)
Full bright yellow with slowly turning rays. A smiling yogi floats; petals burst out around him and a ring ripples.

- Heading: That's today, kept.
- Body: Forever was never the job. Today was, and you did it.
- Two cards with an arrow between: "Today · Kept" with a tick, then "Only tomorrow · 7:00 am · The balcony".
- Line: Don't think about the week. One day is all you ever have to keep, and the next one is tomorrow.
- Button: Done

## 5. The boring middle, days 7 to 27

All three are the Today screen with different words. None mentions what was missed.

### Just start (`Just-Start.html`)
- Heading: Just start.
- Sub: If today feels flat, that is the practice settling in, not failing. You don't need to feel like it. Go to the balcony, sit on the mat and begin.
- Line under the card: The middle weeks are often the dullest. They pass.

### The hour has passed (`Still-Today.html`)
- Heading: Still today.
- Sub: 7:00 has gone by, and that is all right. The day isn't over. Just start when you can.
- Chip: Whenever you're ready

### After a missed day (`New-Day.html`)
- Heading: A new day.
- Sub: Yesterday is finished. Nothing to catch up, nothing to make good. Just start today.
- Chip: Today at 7:00 am
- Link: Is 7:00 am hard to keep? Try another hour → Routine settings

## 6. From day 30

### Day 30 (`Day-30.html`)
The first time any progress is shown, on day 30 of the mandala. The petals for the days so far unfold one by one: green for days practised, red for days missed. The example has 28 practised and 2 missed; the centre shows 28.

- Heading: Thirty days. Meet your lotus.
- Body: Each day you practised opened a petal: 28 so far. Yogi Focus kept it out of sight so that every day could simply be today.
- Body: The two red petals are days you missed. Nothing resets, and the lotus keeps opening.
- Button: See my mandala

### Mandala progress (`Mandala.html`)
Available only after day 30.

- Label: Meditate. Heading: Your mandala
- The lotus, with green petals for days practised, red for days missed and pale for days to come. The centre shows the number practised. The example is day 37: 34 practised, 3 missed.
- Under it: "34 of 48 days practised", then "Day 37. 3 days missed. Nothing resets.", then a small key: Practised, Missed, To come.
- "How it has felt": three rows with a bar and a count: Absorbed, Steady, Scattered. All bars are the same green; no row is marked as bad.
- Summary row: Every day, 7:00 am, the balcony, with Edit.

### Mandala complete (`Mandala-Complete.html`)
The grand finish. Full bright green with turning rays, falling petals, and an open-eyed, smiling yogi floating above a turning lotus.

- At the top, the verse: स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः
- Pronunciation: sa tu dīrgha-kāla-nairantarya-satkārāsevito dṛḍha-bhūmiḥ
- Meaning: Practice finds firm ground when it is tended for a long time, steadily and with care.
- Source: Yoga Sūtra 1.14
- Heading: One mandala.
- Body: Out of 48 days, you practised 45 and missed 3. Yogis say a practice held this long is yours for life. (The numbers are the person's own. With no days missed: "Out of 48 days, you practised all 48.")
- Button: Begin a new mandala
- Second button: Add another routine

This is the only place a second routine is offered to a beginner.

## Navigation

Welcome → Only today → Same time, place, things → One mandala → How Yogi Focus helps → Choose one routine → Time, place, things → Add the widget → Today → How did it feel? → Today is kept → Today.

Today's list icon → Your routines → Routine settings. Mandala progress is reached after day 30 (entry point from Today is not drawn yet; see open questions).

## Not drawn yet

- Today with two routines on the same day.
- The widget moving to the next routine after one is kept.
- The setup for an eating-habit routine.
- Layouts for the open iPhone Duo.
