import SwiftUI
import YogiKit

// MARK: - Today, and its variants

/// What Today says. Nothing is counted on screen before day 30, and no variant mentions what was missed.
struct TodayWords {
    var heading = "A new day."
    var sub = "How will you keep your practice today?"
    var chip = ""
    var chipKept = false
    var under: String?
    var tryAnotherHour = false
    var showsButton = true

    init(_ r: RoutineSnapshot, now: Date) {
        let phase = r.phase(on: now)
        switch r.moment(at: now) {
        case .paused:
            heading = "Paused."
            sub = "The widget is quiet. Nothing is lost. Begin again whenever you like."
            chip = "Paused"
            showsButton = false
        case .kept:
            heading = "That's today, kept."
            sub = "Forever was never the job. Today was, and you did it."
            chip = "Kept today"
            chipKept = true
            under = "Only tomorrow is next: \(r.timeText), \(r.placeInSentence)."
            showsButton = false
        case .passed:
            heading = "Still today."
            sub = "\(r.bareTimeText) has gone by, and that is all right. The day isn't over. Just start when you can."
            chip = "Whenever you're ready"
        case .earlier, .soon, .itsTime:
            if case .soon(let m) = r.moment(at: now) { chip = "In \(m) minute\(m == 1 ? "" : "s")" }
            else if r.moment(at: now) == .itsTime { chip = "It's time" }
            else { chip = "Today at \(r.timeText)" }
            if r.isMorningAfterMiss(now) {
                sub = "Yesterday is finished. Nothing to catch up, nothing to make good. Just start today."
                tryAnotherHour = true
            } else {
                switch phase {
                case .cappedStart:
                    under = r.durationMinutes == Mandala.minimumMinutes
                        ? "This first week, stop at ten minutes, even if you would like more."
                        : "This first week, stop at \(r.lengthText), even if you would like more."
                case .boringMiddle:
                    heading = "Just start."
                    sub = "If today feels flat, that is the practice settling in, not failing. You don't need to feel like it. Go to \(r.placeInSentence)\(r.things.contains { $0.lowercased().contains("mat") } ? ", sit on the mat" : "") and begin."
                    under = "The middle weeks are often the dullest. They pass."
                case .becomingYours, .afterMandala:
                    under = "You know the way."
                }
            }
        }
    }
}

struct TodayScreen: View {
    @Environment(AppModel.self) private var model
    @Binding var path: [Route]
    @State private var reveal: UUID?
    @State private var complete: UUID?
    @Environment(\.duoPose) private var pose
    /// The routine shown on the trailing side of the wide Duo display.
    @State private var selected: UUID?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 20)) { ctx in
            content(now: ctx.date)
        }
        .fullScreenCover(item: Binding(get: { reveal.map(IDBox.init) }, set: { reveal = $0?.id })) { box in
            debugFramed(Day30Screen(routineID: box.id) {
                YogiStore.shared.markDay30Seen(box.id)
                reveal = nil
                path.append(.mandala(box.id))
            })
        }
        .fullScreenCover(item: Binding(get: { complete.map(IDBox.init) }, set: { complete = $0?.id })) { box in
            debugFramed(MandalaCompleteScreen(routineID: box.id, onNewMandala: {
                YogiStore.shared.beginNewMandala(box.id)
                complete = nil
            }, onAddRoutine: {
                YogiStore.shared.beginNewMandala(box.id)
                complete = nil
                path.append(.choose)
            }))
        }
        .onAppear(perform: checkMilestones)
        .onChange(of: model.routines) { _, _ in checkMilestones() }
        .onChange(of: path) { _, p in if p.isEmpty { checkMilestones() } }
    }

    /// Day 30 reveals the lotus once. Day 48 completes the mandala whatever the count.
    private func checkMilestones() {
        guard path.isEmpty, reveal == nil, complete == nil else { return }
        let now = Date()
        if let r = model.routines.first(where: { $0.needsCompleteScreen(on: now) }) { complete = r.id }
        else if let r = model.routines.first(where: { $0.needsDay30Reveal(on: now) }) { reveal = r.id }
    }

    @ViewBuilder private func content(now: Date) -> some View {
        if pose == .phone { phoneContent(now: now) } else { duoContent(now: now) }
    }

    @ViewBuilder private func phoneContent(now: Date) -> some View {
        if let r = Routines.current(model.routines, at: now) {
            let w = TodayWords(r, now: now)
            Screen {
                HStack {
                    Text("Yogi Focus").font(YFFont.heading(26)).foregroundStyle(YF.textGreen)
                    Spacer()
                    Button { path.append(.routines) } label: {
                        YFIcon("plan").foregroundStyle(YF.ink).frame(width: 44, height: 44).contentShape(Rectangle())
                    }
                    .accessibilityLabel("Your routines")
                    .padding(.trailing, -10)
                }
                .frame(height: 44)
                Text(Words.fullDate(now)).font(YFFont.body(14, .medium)).foregroundStyle(YF.muted).padding(.top, 22)
                H1(w.heading, size: 42).padding(.top, 2)
                Para(w.sub).padding(.top, 6)
                CardBox(radius: 26) {
                    VStack(alignment: .leading, spacing: 0) {
                        Chip(text: w.chip, background: w.chipKept ? YF.softGreen : YF.sunny,
                             foreground: w.chipKept ? YF.textGreen : YF.onAccent, check: w.chipKept)
                        Text(r.name).font(YFFont.heading(32)).padding(.top, 10)
                        VStack(alignment: .leading, spacing: 4) {
                            AnchorRow(icon: "clock", text: r.whenText)
                            AnchorRow(icon: "pin", text: r.placeTitle)
                            if !r.things.isEmpty { AnchorRow(icon: "bag", text: r.thingsList) }
                        }
                        .font(YFFont.body(16))
                        .padding(.top, 10)
                    }
                    .padding(22)
                }
                .padding(.top, 22)
                if let under = w.under {
                    Para(under, size: 14, color: YF.muted).padding(.top, 14)
                }
                if w.tryAnotherHour {
                    Button { path.append(.edit(r.id)) } label: {
                        Text("Is \(r.timeText) hard to keep? Try another hour")
                            .font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.textGreen)
                            .frame(minHeight: 44, alignment: .leading)
                    }
                    .padding(.top, 6)
                }
                if w.chipKept, r.feelings[DayKey.key(now)] == nil {
                    Button { path.append(.reflect(r.id)) } label: {
                        Text("How did it feel?").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.textGreen)
                            .frame(minHeight: 44, alignment: .leading)
                    }
                    .padding(.top, 2)
                }
                // From day 30 the lotus may be shown: the way in to the mandala.
                if r.showsProgress(on: now) {
                    Button { path.append(.mandala(r.id)) } label: {
                        HStack(spacing: 12) {
                            LotusView(petals: r.petals(on: now)).frame(width: 34, height: 34)
                            Text("Your mandala").font(YFFont.body(15.5, .medium)).foregroundStyle(YF.ink)
                            Spacer()
                            YFIcon("chev-right", size: 18).foregroundStyle(YF.textGreen)
                        }
                        .padding(.horizontal, 18)
                        .frame(minHeight: 60)
                        .background(YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
                    }
                    .buttonStyle(PressStyle())
                    .padding(.top, 14)
                }
            } bottom: {
                if w.showsButton {
                    PrimaryButton("I've practised today") { path.append(.reflect(r.id)) }
                }
            }
        } else {
            Color.clear
        }
    }
}

struct IDBox: Identifiable { let id: UUID }

/// Full-screen covers sit outside the root view, so the debug window size is applied to them separately.
@ViewBuilder func debugFramed<V: View>(_ v: V) -> some View {
    #if DEBUG
    v.modifier(DebugFrame())
    #else
    v
    #endif
}

// MARK: - How did it feel?

struct ReflectScreen: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onBack: () -> Void
    let onDone: () -> Void
    @State private var feeling: Feeling?
    @State private var note = ""

    @ViewBuilder var phoneBody: some View {
        Screen {
            TopBar(back: onBack)
            H1("You practised today.", size: 34).padding(.top, 6)
            Para("How did it feel? There is no wrong answer.").padding(.top, 8)
            VStack(spacing: 10) {
                // Feelings are never colour-coded good or bad: all three use the same colours, and abstract glyphs, never faces.
                ForEach(Feeling.allCases) { f in
                    let on = feeling == f
                    Button {
                        withAnimation(.easeOut(duration: 0.35)) { feeling = f }
                    } label: {
                        HStack(spacing: 14) {
                            YFIcon(f.icon).foregroundStyle(YF.onAccent)
                                .frame(width: 44, height: 44).background(YF.sunny, in: Circle())
                            VStack(alignment: .leading, spacing: 0) {
                                Text(f.title).font(YFFont.body(17, .semibold)).foregroundStyle(YF.ink)
                                Text(f.subtitle).font(YFFont.body(14)).foregroundStyle(YF.muted)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: 72)
                        .background(on ? YF.softGreen : YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(on ? YF.textGreen : YF.line, lineWidth: 2))
                        .contentShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
            .padding(.top, 18)
            if let feeling {
                StatementCard(text: feeling.reply, size: 20, padding: EdgeInsets(top: 18, leading: 22, bottom: 18, trailing: 22))
                    .padding(.top, 14)
                    .id(feeling)
                    .transition(.asymmetric(insertion: .offset(y: 14).combined(with: .opacity), removal: .identity))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("A note for yourself (optional)").font(YFFont.body(13, .medium)).foregroundStyle(YF.muted)
                TextField("", text: $note, prompt: Text("Anything you noticed").foregroundStyle(YF.muted.opacity(0.7)))
                    .font(YFFont.body(16)).foregroundStyle(YF.ink)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 48)
                    .background(YF.paper, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(YF.muted, lineWidth: 1))
                    .submitLabel(.done)
                    .accessibilityLabel("A note for yourself, optional")
            }
            .padding(.top, 14)
        } bottom: {
            PrimaryButton("Done") {
                YogiStore.shared.markKept(routineID, feeling: feeling, note: note)
                Nudges.cancelToday(routineID)
                model.refresh()
                onDone()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            if let r = model.routine(routineID), let raw = r.feelings[DayKey.key(Date())] { feeling = Feeling(rawValue: raw) }
            note = YogiStore.shared.note(routineID: routineID) ?? ""
        }
    }
}

// MARK: - Hero layout

/// A full-colour screen with a hero graphic. The hero takes the height left after the text and button,
/// so it fits the shorter, squarer iPhone Duo displays; when the screen is wide (the open Duo) the graphic
/// goes on one side and the text and button on the other.
struct HeroLayout<Hero: View, Top: View, Content: View, Bottom: View>: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    let background: Color
    let heroAspect: CGFloat
    let heroMaxWidth: CGFloat
    /// Tone-on-tone rays behind the hero, centred at this fraction of the screen height.
    var rays: Color? = nil
    var raysCentre: CGFloat = 0.25
    @ViewBuilder var top: () -> Top
    @ViewBuilder var hero: () -> Hero
    @ViewBuilder var content: () -> Content
    @ViewBuilder var bottom: () -> Bottom

    @ViewBuilder var phoneBody: some View {
        GeometryReader { geo in
            let wide = geo.size.width >= 600
            let topPad = max(8, ScreenMetrics.edge - geo.safeAreaInsets.top)
            let bottomPad = max(0, ScreenMetrics.edge - geo.safeAreaInsets.bottom)
            Group {
                if wide {
                    // The open iPhone Duo: the graphic on one side; the words and buttons centred on the other.
                    HStack(spacing: 32) {
                        hero().aspectRatio(heroAspect, contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                top()
                                content().fixedSize(horizontal: false, vertical: true)
                                VStack(spacing: 8) { bottom() }.padding(.top, 28)
                            }
                            .padding(.vertical, max(topPad, bottomPad))
                            .frame(minHeight: geo.size.height, alignment: .center)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .frame(width: min(YF.maxColumn - 2 * YF.margin, geo.size.width * 0.46))
                    }
                    .padding(.horizontal, YF.margin)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        top()
                        hero().aspectRatio(heroAspect, contentMode: .fit)
                            .frame(maxWidth: heroMaxWidth * geo.size.width / YF.referenceWidth)
                            .frame(maxWidth: .infinity, minHeight: 96, maxHeight: .infinity)
                            .layoutPriority(-1)
                        content().fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 12).frame(maxHeight: 24)
                        VStack(spacing: 8) { bottom() }
                    }
                    .padding(.horizontal, YF.margin)
                    .padding(.top, topPad)
                    .padding(.bottom, bottomPad)
                    .frame(maxWidth: YF.maxColumn)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background {
            GeometryReader { geo in
                ZStack {
                    background
                    if let rays {
                        RaysView(color: rays)
                            .frame(width: 1400, height: 1400)
                            .position(x: geo.size.width / 2, y: geo.size.height * raysCentre)
                    }
                }
                .clipped()
            }
            .ignoresSafeArea()
        }
        .foregroundStyle(YF.ink)
        .toolbar(.hidden, for: .navigationBar)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

// MARK: - Today is kept

struct KeptScreen: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onDone: () -> Void
    @State private var showToday = false
    @State private var showTomorrow = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder var phoneBody: some View {
        let r = model.routine(routineID)
        HeroLayout(background: YF.heroYellow, heroAspect: 300 / 262, heroMaxWidth: 300, rays: YF.raysOnYellow, raysCentre: 0.24) {
            EmptyView()
        } hero: {
            KeptHero()
                .accessibilityElement()
                .accessibilityLabel("A smiling yogi floats while petals burst out around him")
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                H1("That's today, kept.", size: 38).padding(.top, 10)
                Para("Forever was never the job. Today was, and you did it.").padding(.top, 6)
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Today").font(YFFont.body(13, .semibold))
                        Text("Kept").font(YFFont.heading(30)).padding(.top, 2)
                        Spacer(minLength: 4)
                        YFIcon("check", size: 18).foregroundStyle(YF.sunny)
                            .frame(width: 30, height: 30).background(YF.onAccent, in: Circle())
                    }
                    .foregroundStyle(YF.onAccent)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
                    .background(YF.leaf, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .scaleEffect(showToday ? 1 : 0.4)
                    .opacity(showToday ? 1 : 0)

                    YFIcon("chev-right", size: 20).foregroundStyle(YF.ink)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Only tomorrow").font(YFFont.body(13, .semibold)).foregroundStyle(YF.textGreen)
                        Text(r?.timeText ?? "").font(YFFont.heading(30)).padding(.top, 2).lineLimit(1).minimumScaleFactor(0.7)
                        Spacer(minLength: 4)
                        Text(r?.placeTitle ?? "").font(YFFont.body(14, .medium)).lineLimit(2)
                    }
                    .foregroundStyle(YF.ink)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
                    .background(YF.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .offset(y: showTomorrow ? 0 : 14)
                    .opacity(showTomorrow ? 1 : 0)
                }
                .padding(.top, 18)
                if pose != .outer {
                    Para("Don't think about the week. One day is all you ever have to keep, and the next one is tomorrow.", size: 15)
                        .padding(.top, 14)
                }
            }
        } bottom: {
            PrimaryButton("Done", kind: .hero, action: onDone)
        }
        .navigationBarBackButtonHidden()
        .sensoryFeedback(.success, trigger: showToday)
        .onAppear {
            if reduceMotion { showToday = true; showTomorrow = true; return }
            // "Today · Kept" pops in at 0.3 s; "Only tomorrow" slides up at 0.9 s. Once.
            withAnimation(.spring(duration: 0.5, bounce: 0.45).delay(0.3)) { showToday = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { showTomorrow = true }
        }
    }
}

/// The yogi floats; nine petals burst outward from behind him and a white ring ripples, every 4.5 s.
struct KeptHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let colors: [Color] = [.white, YF.deepLeaf, YF.saffron, .white, YF.mid, YF.pink, .white, YF.deepLeaf, YF.saffron]
    @State private var start = Date()

    var body: some View {
        DesignCanvas(width: 300, height: 262) {
            HaloRing(color: .white, lineWidth: 7, period: 4.5)
                .frame(width: 140, height: 140)
                .offset(x: 80, y: 48)
            if !reduceMotion {
                TimelineView(.animation) { ctx in
                    Canvas { g, _ in
                        let t = ctx.date.timeIntervalSince(start)
                        let shape = LotusGeometry.petal(length: 26, width: 10)
                        for k in 0..<9 {
                            let local = t - Double(k) * 0.07
                            guard local >= 0 else { continue }
                            let f = local.truncatingRemainder(dividingBy: 4.5) / 4.5
                            // yf-fly: 0 → 55%: out 92 pt, growing; → 78%: out 118 pt, fading; then rest.
                            let e = 1 - pow(1 - min(1, f / 0.55), 2)
                            let dy: Double = f < 0.55 ? -92 * e : -92 - 26 * min(1, (f - 0.55) / 0.23)
                            let scale = f < 0.55 ? 0.2 + 0.8 * e : 1
                            let alpha = f < 0.1 ? f / 0.1 : (f < 0.55 ? 1 : max(0, 1 - (f - 0.55) / 0.23))
                            var c = g
                            c.opacity = alpha
                            c.translateBy(x: 150, y: 118)
                            c.rotate(by: .degrees(-120 + Double(k) * 30))
                            c.translateBy(x: 0, y: -58 + dy)
                            c.scaleBy(x: scale, y: scale)
                            c.fill(shape, with: .color(colors[k]))
                        }
                    }
                }
                .frame(width: 300, height: 262)
            }
            FloatShadow(color: YF.heroShadow)
                .frame(width: 96, height: 16)
                .offset(x: 102, y: 232)
            YogiView(.joyful, whiteDhoti: true)
                .frame(width: 230, height: 230)
                .levitate(low: 4.6, high: -10.35)
                .offset(x: 35, y: 8)
        }
    }
}

// MARK: - iPhone Duo

extension KeptScreen {
    /// The hero layout adapts by itself; the screen is the same on every display.
    var duoBody: some View { phoneBody }
}

extension HeroLayout {
    /// Duo: the hero is what you look at; the words and button sit beside it (wide), below the fold (tall), or
    /// under a smaller hero (outer). The rays turn behind the hero, edge to edge.
    var duoBody: some View {
        let raysColor = rays
        return DuoPage(background: background, stripTint: Color.black.opacity(0.05), pinsBottom: pose != .wide,
                       underlay: raysColor.map { c in
                           { r in
                               let centre: CGPoint = {
                                   switch pose {
                                   case .wide: return CGPoint(x: r.leading.midX, y: r.size.height / 2)
                                   case .tall: return CGPoint(x: r.size.width / 2, y: r.top.midY)
                                   default: return CGPoint(x: r.contentRight / 2, y: 140)
                                   }
                               }()
                               return AnyView(RaysView(color: c).frame(width: 1640, height: 1640).position(centre).allowsHitTesting(false))
                           }
                       }) {
            hero().aspectRatio(heroAspect, contentMode: .fit)
                .frame(maxWidth: pose == .outer ? heroMaxWidth * 0.72 : heroMaxWidth * 1.1)
                .frame(maxWidth: .infinity)
        } trail: {
            top()
            content().fixedSize(horizontal: false, vertical: true)
        } bottom: {
            bottom()
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

extension TodayScreen {
    /// Duo Today.
    /// - outer: the phone screen, shortened; the routines list moves into the strip.
    /// - wide: today's routines on the leading side, the selected one on the trailing side (`Duo-Wide-Today`).
    /// - tall: the routine in the top region; the yogi, one line and the button in the bottom region (`Duo-Tall-Today`).
    @ViewBuilder func duoContent(now: Date) -> some View {
        if let current = Routines.current(model.routines, at: now) {
            let r = model.routines.first { $0.id == selected } ?? current
            let w = TodayWords(r, now: now)
            switch pose {
            case .wide:
                let todays = model.routines.filter { !$0.isPaused || $0.id == r.id }
                DuoPage(leadAlignment: .top, trailAlignment: .top, pinsBottom: true, strip: [.routines { path.append(.routines) }]) {
                    Text(Words.fullDate(now)).font(YFFont.body(14, .medium)).foregroundStyle(YF.muted)
                    H1(TodayWords(current, now: now).heading, size: 42)
                    Para(summary(todays, now: now, fallback: TodayWords(current, now: now).sub), size: 16).padding(.top, 4)
                    VStack(spacing: 10) {
                        ForEach(todays) { t in routineRow(t, now: now, on: t.id == r.id) }
                    }
                    .padding(.top, 18)
                    if todays.count > 1 {
                        Para("When one routine is kept, Yogi Focus moves on to the next.", size: 14, color: YF.muted).padding(.top, 14)
                    } else if let under = w.under {
                        Para(under, size: 14, color: YF.muted).padding(.top, 14)
                    }
                } trail: {
                    todayCard(r, w, nameSize: 30).padding(.top, 12)
                    if todays.count > 1 {
                        Para(w.sub, size: 17).padding(.top, 16)
                    } else if w.showsButton {
                        Para("How will you keep your practice today?", size: 17).padding(.top, 16)
                    }
                    todayExtras(r, w, now: now)
                } bottom: {
                    if w.showsButton { PrimaryButton("I've practised today") { path.append(.reflect(r.id)) } }
                }
            case .tall:
                DuoPage(leadAlignment: .top, pinsBottom: true, bar: { AnyView(todayHeader) }) {
                    Text(Words.fullDate(now)).font(YFFont.body(14, .medium)).foregroundStyle(YF.muted)
                    H1(w.heading, size: 40)
                    Para(w.sub, size: 16).padding(.top, 4)
                    todayCard(r, w, nameSize: 28, compact: true).padding(.top, 12)
                } trail: {
                    HStack(spacing: 28) {
                        YogiView(.calm, mat: true).frame(width: 170, height: 170).levitate()
                        if let line = w.under {
                            Text(line).font(YFFont.heading(22, .semibold)).designLineHeight(22, 1.3)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: 300, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    todayExtras(r, w, now: now)
                } bottom: {
                    if w.showsButton { PrimaryButton("I've practised today") { path.append(.reflect(r.id)) } }
                }
            default:
                DuoPage(strip: [.routines { path.append(.routines) }]) {
                    Text(Words.fullDate(now)).font(YFFont.body(14, .medium)).foregroundStyle(YF.muted)
                    H1(w.heading, size: 42)
                    Para(w.sub, size: 16).padding(.top, 4)
                    todayCard(r, w, nameSize: 30).padding(.top, 14)
                    if let under = w.under { Para(under, size: 14, color: YF.muted).padding(.top, 10) }
                    todayExtras(r, w, now: now)
                } trail: {
                    EmptyView()
                } bottom: {
                    if w.showsButton { PrimaryButton("I've practised today") { path.append(.reflect(r.id)) } }
                }
            }
        } else {
            Color.clear
        }
    }

    private var todayHeader: some View {
        HStack {
            Text("Yogi Focus").font(YFFont.heading(26)).foregroundStyle(YF.textGreen)
            Spacer()
            Button { path.append(.routines) } label: {
                YFIcon("plan").foregroundStyle(YF.ink).frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .accessibilityLabel("Your routines")
        }
        .frame(height: 44)
    }

    /// "Two routines today. One is kept." Never a count of anything missed.
    private func summary(_ todays: [RoutineSnapshot], now: Date, fallback: String) -> String {
        guard todays.count > 1 else { return fallback }
        let kept = todays.filter { $0.keptToday(now) }.count
        let n = Words.capitalisedFirst(Words.spelled(todays.count))
        switch kept {
        case 0: return "\(n) routines today."
        case todays.count: return "\(n) routines today. All kept."
        default: return "\(n) routines today. \(Words.capitalisedFirst(Words.spelled(kept))) \(kept == 1 ? "is" : "are") kept."
        }
    }

    private func routineRow(_ t: RoutineSnapshot, now: Date, on: Bool) -> some View {
        let kept = t.keptToday(now)
        let state: String = {
            switch t.moment(at: now) {
            case .kept: return "Kept today"
            case .paused: return "Paused"
            case .passed: return "Whenever you're ready"
            default: return "Next"
            }
        }()
        return Button { withAnimation(.easeOut(duration: 0.2)) { selected = t.id } } label: {
            HStack(spacing: 14) {
                YFIcon(kept ? "check" : t.routineKind.icon, size: 20)
                    .foregroundStyle(kept ? YF.textGreen : YF.onAccent)
                    .frame(width: 36, height: 36)
                    .background(kept ? YF.softGreen : YF.sunny, in: Circle())
                VStack(alignment: .leading, spacing: 0) {
                    Text(t.name).font(YFFont.body(17, .semibold)).foregroundStyle(YF.ink)
                    Text("\(t.timeText) · \(state)").font(YFFont.body(14)).foregroundStyle(YF.muted)
                }
                Spacer(minLength: 0)
                if on && !kept { YFIcon("chev-right", size: 20).foregroundStyle(YF.muted) }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(on ? YF.softGreen : YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(on ? YF.textGreen : YF.line, lineWidth: on ? 2 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    /// - compact: a little tighter, so the card fits above the fold in the tall pose.
    private func todayCard(_ r: RoutineSnapshot, _ w: TodayWords, nameSize: CGFloat, compact: Bool = false) -> some View {
        let row: CGFloat = compact ? 25 : 28
        return CardBox(radius: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Chip(text: w.chip, background: w.chipKept ? YF.softGreen : YF.sunny,
                     foreground: w.chipKept ? YF.textGreen : YF.onAccent, check: w.chipKept)
                Text(r.name).font(YFFont.heading(nameSize)).padding(.top, compact ? 4 : 8)
                VStack(alignment: .leading, spacing: 2) {
                    AnchorRow(icon: "clock", text: r.whenText, minHeight: row)
                    AnchorRow(icon: "pin", text: r.placeTitle, minHeight: row)
                    if !r.things.isEmpty { AnchorRow(icon: "bag", text: r.thingsList, minHeight: row) }
                }
                .font(YFFont.body(16))
                .padding(.top, compact ? 4 : 8)
            }
            .padding(compact ? 16 : 20)
        }
    }

    /// The quiet links that sometimes follow the card: another hour, how it felt, and the mandala from day 30.
    @ViewBuilder private func todayExtras(_ r: RoutineSnapshot, _ w: TodayWords, now: Date) -> some View {
        if w.tryAnotherHour {
            Button { path.append(.edit(r.id)) } label: {
                Text("Is \(r.timeText) hard to keep? Try another hour")
                    .font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.textGreen)
                    .frame(minHeight: 44, alignment: .leading)
            }
            .padding(.top, 6)
        }
        if w.chipKept, r.feelings[DayKey.key(now)] == nil {
            Button { path.append(.reflect(r.id)) } label: {
                Text("How did it feel?").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.textGreen)
                    .frame(minHeight: 44, alignment: .leading)
            }
            .padding(.top, 2)
        }
        if r.showsProgress(on: now) {
            Button { path.append(.mandala(r.id)) } label: {
                HStack(spacing: 12) {
                    LotusView(petals: r.petals(on: now)).frame(width: 34, height: 34)
                    Text("Your mandala").font(YFFont.body(15.5, .medium)).foregroundStyle(YF.ink)
                    Spacer()
                    YFIcon("chev-right", size: 18).foregroundStyle(YF.textGreen)
                }
                .padding(.horizontal, 18)
                .frame(minHeight: 60)
                .background(YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
            }
            .buttonStyle(PressStyle())
            .padding(.top, 14)
        }
    }
}

extension ReflectScreen {
    /// Duo "How did it feel?".
    /// - outer and wide: Done moves into the strip; the reply and note sit beside the choices on the wide display.
    /// - tall: the reply in the top region; the three choices as large buttons, the note and Done below the fold.
    @ViewBuilder var duoBody: some View {
        Group {
            switch pose {
            case .tall:
                DuoPage(leadAlignment: .top, pinsBottom: true, bar: { AnyView(TopBar(back: onBack)) }) {
                    H1("You practised today.", size: 40).padding(.top, 10)
                    Para("How did it feel? There is no wrong answer.").padding(.top, 6)
                    if let feeling { reply(feeling, size: 24).padding(.top, 40) }
                } trail: {
                    HStack(spacing: 10) {
                        ForEach(Feeling.allCases) { f in bigChoice(f) }
                    }
                    noteField.padding(.top, 16)
                } bottom: {
                    PrimaryButton("Done", action: save)
                }
            case .wide:
                DuoPage(leadAlignment: .top, trailAlignment: .top, strip: [.back(onBack), .done(save)]) {
                    H1("You practised today.", size: 36).padding(.top, 24)
                    Para("How did it feel? There is no wrong answer.").padding(.top, 6)
                    VStack(spacing: 10) { ForEach(Feeling.allCases) { f in rowChoice(f, height: 64) } }.padding(.top, 22)
                } trail: {
                    if let feeling { reply(feeling, size: 22).padding(.top, 92) } else { Color.clear.frame(height: 92) }
                    noteField.padding(.top, 22)
                }
            default:
                DuoPage(strip: [.back(onBack), .done(save)]) {
                    H1("You practised today.", size: 34)
                    Para("How did it feel? There is no wrong answer.", size: 15.5).padding(.top, 2)
                    VStack(spacing: 8) { ForEach(Feeling.allCases) { f in rowChoice(f, height: 58) } }.padding(.top, 12)
                    if let feeling { reply(feeling, size: 17).padding(.top, 10) }
                    noteField.padding(.top, 10)
                } trail: {
                    EmptyView()
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            if let r = model.routine(routineID), let raw = r.feelings[DayKey.key(Date())] { feeling = Feeling(rawValue: raw) }
            note = YogiStore.shared.note(routineID: routineID) ?? ""
        }
    }

    private func save() {
        YogiStore.shared.markKept(routineID, feeling: feeling, note: note)
        Nudges.cancelToday(routineID)
        model.refresh()
        onDone()
    }

    private func reply(_ f: Feeling, size: CGFloat) -> some View {
        StatementCard(text: f.reply, size: size, padding: EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            .id(f)
            .transition(.asymmetric(insertion: .offset(y: 14).combined(with: .opacity), removal: .identity))
    }

    /// Feelings are never colour-coded good or bad: all three look the same, with abstract glyphs.
    private func rowChoice(_ f: Feeling, height: CGFloat) -> some View {
        let on = feeling == f
        return Button { withAnimation(.easeOut(duration: 0.35)) { feeling = f } } label: {
            HStack(spacing: 12) {
                YFIcon(f.icon, size: 22).foregroundStyle(YF.onAccent).frame(width: 40, height: 40).background(YF.sunny, in: Circle())
                VStack(alignment: .leading, spacing: 0) {
                    Text(f.title).font(YFFont.body(16, .semibold)).foregroundStyle(YF.ink)
                    Text(f.subtitle).font(YFFont.body(13.5)).foregroundStyle(YF.muted)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: height)
            .background(on ? YF.softGreen : YF.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(on ? YF.textGreen : YF.line, lineWidth: 2))
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private func bigChoice(_ f: Feeling) -> some View {
        let on = feeling == f
        return Button { withAnimation(.easeOut(duration: 0.35)) { feeling = f } } label: {
            VStack(spacing: 8) {
                YFIcon(f.icon, size: 24).foregroundStyle(YF.onAccent).frame(width: 48, height: 48).background(YF.sunny, in: Circle())
                Text(f.title).font(YFFont.body(17, .semibold)).foregroundStyle(YF.ink)
            }
            .frame(maxWidth: .infinity, minHeight: 132)
            .background(on ? YF.softGreen : YF.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(on ? YF.textGreen : YF.line, lineWidth: 2))
            .contentShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(f.title): \(f.subtitle)")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("A note for yourself (optional)").font(YFFont.body(13, .medium)).foregroundStyle(YF.muted)
            TextField("", text: $note, prompt: Text("Anything you noticed").foregroundStyle(YF.muted.opacity(0.7)))
                .font(YFFont.body(16)).foregroundStyle(YF.ink)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(YF.paper, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(YF.muted, lineWidth: 1))
                .submitLabel(.done)
                .accessibilityLabel("A note for yourself, optional")
        }
    }
}
