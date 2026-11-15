import SwiftUI
import Combine
import YogiKit

// Drawn at 208 × 248 pt (the 46 mm size). `u` is one design point at this watch's width.

struct WatchRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var model: WatchModel
    private let tick = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let u = geo.size.width / 208
            screen(u: u, size: geo.size)
                .frame(width: geo.size.width, height: geo.size.height)
                .id(model.screen.key)
                .transition(.opacity)
        }
        .ignoresSafeArea()
        .background(Color.black.ignoresSafeArea())
        .animation(.easeOut(duration: 0.3), value: model.screen.key)
        .onReceive(tick) { _ in model.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: .yogiStoreDidChange).receive(on: RunLoop.main)) { _ in model.refresh() }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { model.becameActive() } else if phase == .background { model.becameInactive() }
        }
    }

    @ViewBuilder private func screen(u: CGFloat, size: CGSize) -> some View {
        switch model.screen {
        case .empty:
            WatchFrame(u: u, size: size) {
                WLabel("One day at a time", u: u, color: YF.leaf)
                WTitle("Yogi Focus", u: u)
                WLine("Choose your routine on your iPhone.", u: u).padding(.top, 10 * u)
            }
        case .paused(let r):
            WatchFrame(u: u, size: size) {
                WLabel("Paused", u: u, color: YF.watchSecondary)
                WTitle(r.name, u: u)
                WLine("Paused. Nothing is lost.", u: u).padding(.top, 10 * u)
            }
        case .newDay(let r):
            WatchFrame(u: u, size: size, yogi: true) {
                WLabel("A new day", u: u, color: YF.leaf)
                WTitle(r.name, u: u).padding(.trailing, 70 * u)
                VStack(alignment: .leading, spacing: 2 * u) {
                    WRow("clock", r.timeText, u: u)
                    WRow("pin", r.placeTitle, u: u)
                }
                .padding(.top, 8 * u)
                Spacer(minLength: 0)
                WButton("I've practised", u: u) { model.done(r) }
            }
        case .soon(let r, let minutes):
            WatchFrame(u: u, size: size) {
                WLabel("In \(minutes) minute\(minutes == 1 ? "" : "s")", u: u)
                WTitle(r.name, u: u)
                VStack(alignment: .leading, spacing: 2 * u) {
                    WRow("clock", "\(r.timeText), \(r.lengthShort)", u: u)
                    WRow("pin", r.placeTitle, u: u)
                    if !r.things.isEmpty { WRow("bag", r.thingsList, u: u) }
                }
                .padding(.top, 8 * u)
                Spacer(minLength: 0)
                Text("Same place, same time, same things.")
                    .font(YFFont.fixedBody(13 * u))
                    .foregroundStyle(YF.watchSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .itsTime(let r):
            WatchFrame(u: u, size: size, yogi: true) {
                WLabel("It's time", u: u, dot: true)
                WTitle(r.name, u: u).padding(.trailing, 70 * u)
                WLine(Self.hourLine(r, model.now), u: u).padding(.top, 10 * u).frame(maxWidth: 150 * u, alignment: .leading)
                Spacer(minLength: 0)
                WButton("Done", u: u) { model.done(r) }
            }
        case .passed(let r):
            WatchFrame(u: u, size: size) {
                WLabel("Still today", u: u)
                WTitle(r.name, u: u)
                WLine("Just start when you can.", u: u).padding(.top, 10 * u)
                Spacer(minLength: 0)
                WButton("Done", u: u) { model.done(r) }
            }
        case .ask(let r):
            WatchFrame(u: u, size: size) {
                Text("How did it feel?")
                    .font(YFFont.fixedHeading(21 * u))
                    .frame(maxWidth: .infinity)
                    // Sits below the system clock, which the reference does not draw.
                    .padding(.top, 14 * u)
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
                            .padding(.horizontal, 12 * u)
                            .frame(minHeight: 44 * u)
                            .background(YF.watchRaised, in: Capsule())
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 9 * u)
            }
        case .kept(let r):
            WatchKeptView(routine: r, u: u, size: size)
                .contentShape(Rectangle())
                .onTapGesture { model.dismissKept() }
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

/// Black ground, the dark green lotus half off the right edge turning once a minute, and the content.
struct WatchFrame<Content: View>: View {
    let u: CGFloat
    let size: CGSize
    var lotus = true
    var yogi = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black
            if lotus {
                LotusView(style: .decoration(YF.watchLotus, on: .black, centre: YF.watchLotus[0]))
                    .frame(width: 236 * u, height: 236 * u)
                    .spin(period: 60)
                    .offset(x: size.width - 118 * u, y: 34 * u)
            }
            if yogi {
                // The reference puts him at the very top right; he sits a little lower here to clear the system clock.
                YogiView(.calm)
                    .frame(width: 74 * u, height: 74 * u)
                    .levitate(low: 4 * u, high: -9 * u)
                    .offset(x: size.width - 78 * u, y: 26 * u)
            }
            VStack(alignment: .leading, spacing: 0) { content() }
                .padding(EdgeInsets(top: 18 * u, leading: 13 * u, bottom: 13 * u, trailing: 13 * u))
                .frame(width: size.width, height: size.height, alignment: .topLeading)
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .clipped()
        .foregroundStyle(.white)
    }
}

/// After an answer: a smiling yogi in front of a turning lotus, and only tomorrow.
struct WatchKeptView: View {
    let routine: RoutineSnapshot
    let u: CGFloat
    let size: CGSize

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LotusView(style: LotusStyle(separator: .black, centre: nil))
                    .frame(width: 116 * u, height: 116 * u)
                    .spin(period: 30)
                WatchHalo(color: YF.sunny, lineWidth: 4 * u)
                    .frame(width: 80 * u, height: 80 * u)
                YogiView(.joyful)
                    .frame(width: 96 * u, height: 96 * u)
                    .levitate(low: 4 * u, high: -9 * u)
            }
            .frame(width: 96 * u, height: 96 * u)
            .padding(.top, -4 * u)
            .accessibilityElement()
            .accessibilityLabel("A smiling yogi floats in front of an open lotus")
            Text("That's today, kept.")
                .font(YFFont.fixedHeading(21 * u))
                .foregroundStyle(YF.sunny)
                .lineLimit(1).minimumScaleFactor(0.7)
                .padding(.top, 12 * u)
            Text("Only tomorrow is next.")
                .font(YFFont.fixedBody(14 * u, .medium))
                .padding(.top, 5 * u)
            Text("\(routine.timeText), \(routine.placeInSentence)")
                .font(YFFont.fixedBody(13 * u))
                .foregroundStyle(YF.watchSecondary)
                .lineLimit(1).minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 18 * u, leading: 13 * u, bottom: 13 * u, trailing: 13 * u))
        .frame(width: size.width, height: size.height, alignment: .top)
        .background(Color.black)
        .foregroundStyle(.white)
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
    let action: () -> Void
    init(_ title: String, u: CGFloat, action: @escaping () -> Void) { self.title = title; self.u = u; self.action = action }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(YFFont.fixedBody(16 * u, .semibold))
                .foregroundStyle(YF.onAccent)
                .frame(maxWidth: .infinity, minHeight: 44 * u)
                .background(YF.leaf, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
