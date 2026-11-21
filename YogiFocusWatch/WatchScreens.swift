import SwiftUI
import Combine
import YogiKit

// Drawn at 208 × 248 pt (the 46 mm size). `u` is one design point at this watch's width.
//
// Layout: everything sits inside the watch's safe area, so it starts below the system clock and keeps clear of
// the rounded corners, with a further inner margin. The words are centred in the space above the button; a screen
// without a button is centred as a whole. Only the background lotus runs to the edges.

struct WatchRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var model: WatchModel
    private let tick = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            // The lower part of the bottom inset is the rounded corner; the upper part is usable for the button.
            let extra = geo.safeAreaInsets.bottom * WatchMetrics.bottomUse
            let height = geo.size.height + extra
            // One design point: by the full width (the design is drawn edge to edge), but never so large that the
            // tallest screen (about 170 points of content) would not fit the height.
            let u = min((geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing) / 208, height / 172)
            screen(u: u)
                .frame(width: geo.size.width, height: height)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .id(model.screen.key)
                .transition(.opacity)
        }
        .background(Color.black.ignoresSafeArea())
        .animation(.easeOut(duration: 0.3), value: model.screen.key)
        .onReceive(tick) { _ in model.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: .yogiStoreDidChange).receive(on: RunLoop.main)) { _ in model.refresh() }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { model.becameActive() } else if phase == .background { model.becameInactive() }
        }
    }

    @ViewBuilder private func screen(u: CGFloat) -> some View {
        switch model.screen {
        case .empty:
            WatchFrame(u: u) {
                WLabel("One day at a time", u: u, color: YF.leaf)
                WTitle("Yogi Focus", u: u)
                WLine("Choose your routine on your iPhone.", u: u).padding(.top, 8 * u)
            }
        case .paused(let r):
            WatchFrame(u: u) {
                WLabel("Paused", u: u, color: YF.watchSecondary)
                WTitle(r.name, u: u)
                WLine("Nothing is lost.", u: u).padding(.top, 8 * u)
            }
        case .newDay(let r):
            WatchFrame(u: u) {
                WHeader(label: WLabel("A new day", u: u, color: YF.leaf), title: r.name, u: u, yogi: true)
                VStack(alignment: .leading, spacing: 2 * u) {
                    WRow("clock", r.timeText, u: u)
                    WRow("pin", r.placeTitle, u: u)
                }
                .padding(.top, 6 * u)
            } footer: {
                WButton("I've practised", u: u) { model.done(r) }
            }
        case .soon(let r, let minutes):
            WatchFrame(u: u) {
                WLabel("In \(minutes) minute\(minutes == 1 ? "" : "s")", u: u)
                WTitle(r.name, u: u)
                VStack(alignment: .leading, spacing: 2 * u) {
                    WRow("clock", r.whenCompact, u: u)
                    WRow("pin", r.placeTitle, u: u)
                    if !r.things.isEmpty { WRow("bag", r.thingsList, u: u) }
                }
                .padding(.top, 6 * u)
                Text("Same place, same time, same things.")
                    .font(YFFont.fixedBody(13 * u))
                    .foregroundStyle(YF.watchSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10 * u)
            }
        case .itsTime(let r):
            WatchFrame(u: u) {
                WHeader(label: WLabel("It's time", u: u, dot: true), title: r.name, u: u, yogi: true)
                WLine(Self.hourLine(r, model.now), u: u).padding(.top, 8 * u)
            } footer: {
                answers(r, u: u)
            }
        case .passed(let r):
            WatchFrame(u: u) {
                WLabel("Still today", u: u)
                WTitle(r.name, u: u)
                WLine("Just start when you can.", u: u).padding(.top, 8 * u)
            } footer: {
                VStack(spacing: 6 * u) {
                    if r.twoMinute != nil { WButton("Just two minutes", u: u, quiet: true) { model.twoMinutes(r) } }
                    answers(r, u: u)
                }
            }
        case .notToday(let r):
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                YogiView(.calm).frame(width: 64 * u, height: 64 * u)
                Text("That's all right.")
                    .font(YFFont.fixedHeading(19 * u)).foregroundStyle(YF.sunny)
                    .lineLimit(1).minimumScaleFactor(0.8)
                    .padding(.top, 8 * u)
                Text("Tomorrow is a new day.").font(YFFont.fixedBody(14.5 * u, .semibold))
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2 * u)
                Text("\(r.timeText), \(r.placeInSentence)").font(YFFont.fixedBody(13 * u))
                    .foregroundStyle(YF.watchSecondary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
        case .ask(let r):
            WatchFrame(u: u, lotus: true) {
                Text("How did it feel?")
                    .font(YFFont.fixedHeading(20 * u))
                    .lineLimit(1).minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: 5 * u) {
                    ForEach(Feeling.allCases) { f in
                        Button { model.feel(r, f) } label: {
                            HStack(spacing: 10 * u) {
                                YFIcon(f.icon, size: 17 * u)
                                    .foregroundStyle(YF.onAccent)
                                    .frame(width: 28 * u, height: 28 * u)
                                    .background(YF.sunny, in: Circle())
                                Text(f.title).font(YFFont.fixedBody(15.5 * u, .semibold))
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 10 * u)
                            .frame(minHeight: 40 * u)
                            .background(YF.watchRaised, in: Capsule())
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8 * u)
            }
        case .kept(let r):
            WatchKeptView(routine: r, u: u)
                .contentShape(Rectangle())
                .onTapGesture { model.dismissKept() }
        }
    }

    /// Done and Not today, side by side.
    private func answers(_ r: RoutineSnapshot, u: CGFloat) -> some View {
        HStack(spacing: 6 * u) {
            WButton("Done", u: u) { model.done(r) }
            WButton("Not today", u: u, quiet: true) { model.notToday(r) }
        }
    }

    /// The one line at the hour, by phase.
    static func hourLine(_ r: RoutineSnapshot, _ now: Date) -> String {
        switch r.phase(on: now) {
        case .cappedStart: return "Your mat is waiting."
        case .boringMiddle: return "Don't decide. Just start."
        case .becomingYours, .afterMandala: return "You know the way."
        }
    }
}

/// Black ground with the dark green lotus half off the right edge turning once a minute, the words centred in the
/// safe area above an optional button.
struct WatchFrame<Content: View, Footer: View>: View {
    let u: CGFloat
    var lotus = true
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 0) { content() }
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 8 * u)
            footer()
        }
        .padding(.horizontal, WatchMetrics.side * u)
        .padding(.bottom, 2 * u)
        .foregroundStyle(.white)
        .background {
            GeometryReader { g in
                ZStack(alignment: .topLeading) {
                    Color.black
                    if lotus {
                        LotusView(style: .decoration(YF.watchLotus, on: .black, centre: YF.watchLotus[0]))
                            .frame(width: 236 * u, height: 236 * u)
                            .spin(period: 60)
                            .offset(x: g.size.width - 118 * u, y: 34 * u)
                    }
                }
                .frame(width: g.size.width, height: g.size.height, alignment: .topLeading)
                .clipped()
            }
            .ignoresSafeArea()
        }
    }
}

extension WatchFrame where Footer == EmptyView {
    init(u: CGFloat, lotus: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.init(u: u, lotus: lotus, content: content, footer: { EmptyView() })
    }
}

enum WatchMetrics {
    /// Inner margin, on top of the safe area, so nothing meets the rounded edge of the display.
    static let side: CGFloat = 10
    /// How much of the bottom safe-area inset the content may use.
    static let bottomUse: CGFloat = 0.6
}

/// The label and routine name, with the calm yogi floating beside them.
struct WHeader: View {
    let label: WLabel
    let title: String
    let u: CGFloat
    var yogi = false
    var body: some View {
        HStack(alignment: .center, spacing: 6 * u) {
            VStack(alignment: .leading, spacing: 0) {
                label
                WTitle(title, u: u)
            }
            Spacer(minLength: 0)
            if yogi {
                YogiView(.calm)
                    .frame(width: 56 * u, height: 56 * u)
                    .levitate(low: 3 * u, high: -6 * u)
            }
        }
    }
}

/// After an answer: a smiling yogi in front of a turning lotus, and only tomorrow. Centred on the screen.
struct WatchKeptView: View {
    let routine: RoutineSnapshot
    let u: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ZStack {
                LotusView(style: LotusStyle(separator: .black, centre: nil))
                    .frame(width: 104 * u, height: 104 * u)
                    .spin(period: 30)
                WatchHalo(color: YF.sunny, lineWidth: 4 * u)
                    .frame(width: 74 * u, height: 74 * u)
                YogiView(.joyful)
                    .frame(width: 86 * u, height: 86 * u)
                    .levitate(low: 4 * u, high: -8 * u)
            }
            .frame(width: 104 * u, height: 96 * u)
            .accessibilityElement()
            .accessibilityLabel("A smiling yogi floats in front of an open lotus")
            Text("That's today, kept.")
                .font(YFFont.fixedHeading(21 * u))
                .foregroundStyle(YF.sunny)
                .lineLimit(1).minimumScaleFactor(0.7)
                .padding(.top, 10 * u)
            Text("Only tomorrow is next.")
                .font(YFFont.fixedBody(14 * u, .medium))
                .padding(.top, 4 * u)
            Text("\(routine.timeText), \(routine.placeInSentence)")
                .font(YFFont.fixedBody(13 * u))
                .foregroundStyle(YF.watchSecondary)
                .lineLimit(1).minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, WatchMetrics.side * u)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .background(Color.black.ignoresSafeArea())
    }
}

/// A ring that ripples outward and fades: scale 0.6 → 1.9 over the first 62% of 4.5 s.
struct WatchHalo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let color: Color
    let lineWidth: CGFloat
    var period: Double = 4.5
    @State private var start = Date()

    var body: some View {
        if reduceMotion {
            Color.clear
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { ctx in
                let f = ctx.date.timeIntervalSince(start).truncatingRemainder(dividingBy: period) / period
                let p = min(1, f / 0.62)
                let eased = 1 - pow(1 - p, 2)
                let alpha = f < 0.12 ? 0.9 * f / 0.12 : max(0, 0.9 * (1 - (f - 0.12) / 0.5))
                Circle().strokeBorder(color, lineWidth: lineWidth)
                    .scaleEffect(0.6 + 1.3 * eased)
                    .opacity(alpha)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Pieces

struct WLabel: View {
    let text: String
    let u: CGFloat
    var color: Color = YF.sunny
    var dot = false
    init(_ text: String, u: CGFloat, color: Color = YF.sunny, dot: Bool = false) {
        self.text = text; self.u = u; self.color = color; self.dot = dot
    }
    var body: some View {
        HStack(spacing: 6 * u) {
            if dot { Circle().fill(YF.saffron).frame(width: 8 * u, height: 8 * u) }
            Text(text).font(YFFont.fixedBody(13 * u, .semibold)).foregroundStyle(color).lineLimit(1)
        }
    }
}

struct WTitle: View {
    let text: String
    let u: CGFloat
    init(_ text: String, u: CGFloat) { self.text = text; self.u = u }
    var body: some View {
        Text(text)
            .font(YFFont.fixedHeading(27 * u))
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .padding(.top, 2 * u)
            .accessibilityAddTraits(.isHeader)
    }
}

struct WLine: View {
    let text: String
    let u: CGFloat
    init(_ text: String, u: CGFloat) { self.text = text; self.u = u }
    var body: some View {
        Text(text)
            .font(YFFont.fixedHeading(18 * u, .semibold))
            .designLineHeight(18 * u, 1.2, scales: false)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct WRow: View {
    let icon: String
    let text: String
    let u: CGFloat
    init(_ icon: String, _ text: String, u: CGFloat) { self.icon = icon; self.text = text; self.u = u }
    var body: some View {
        HStack(spacing: 7 * u) {
            YFIcon(icon, size: 16 * u).foregroundStyle(YF.leaf)
            Text(text).font(YFFont.fixedBody(14 * u, .medium)).lineLimit(1).minimumScaleFactor(0.75)
        }
        .frame(minHeight: 22 * u)
    }
}

struct WButton: View {
    let title: String
    let u: CGFloat
    var quiet = false
    let action: () -> Void
    init(_ title: String, u: CGFloat, quiet: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.u = u; self.quiet = quiet; self.action = action
    }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(YFFont.fixedBody((quiet ? 14.5 : 16) * u, .semibold))
                .foregroundStyle(quiet ? Color.white : YF.onAccent)
                .multilineTextAlignment(.center)
                .lineLimit(2).minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 44 * u)
                .background(quiet ? YF.watchRaised : YF.leaf, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
