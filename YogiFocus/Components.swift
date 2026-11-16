import SwiftUI
import YogiKit

// MARK: - Screen scaffold

/// The common layout: 28 pt side margins, content that scrolls if it must, and one primary button.
///
/// - On a tall iPhone (as drawn, 390 × 844) the button is pinned to the bottom.
/// - On the iPhone Duo, whose displays are much squarer (outer about 466 × 678, inner about 951 × 669),
///   the content and its button sit together as one group in the middle of the screen, in a column no wider
///   than about 430 pt, and scroll if they do not fit.
/// - Content never sits closer than 24 pt to the top or bottom edge, even where there is no status bar above it.
struct Screen<Content: View, Bottom: View>: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    var background: Color = YF.ground
    var scrolls = true
    @ViewBuilder var content: () -> Content
    @ViewBuilder var bottom: () -> Bottom

    @ViewBuilder var phoneBody: some View {
        GeometryReader { geo in
            let column = min(geo.size.width, YF.maxColumn)
            let top = max(8, ScreenMetrics.edge - geo.safeAreaInsets.top)
            let bottomPad = max(0, ScreenMetrics.edge - geo.safeAreaInsets.bottom)
            Group {
                if ScreenMetrics.isTall(geo.size) {
                    VStack(spacing: 0) {
                        if scrolls {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) { content() }
                                    .padding(.horizontal, YF.margin)
                                    .padding(.top, top)
                                    .padding(.bottom, 16)
                                    .frame(width: column, alignment: .leading)
                                    .frame(maxWidth: .infinity)
                            }
                            .scrollBounceBehavior(.basedOnSize)
                        } else {
                            VStack(alignment: .leading, spacing: 0) { content() }
                                .padding(.horizontal, YF.margin)
                                .padding(.top, top)
                                .frame(width: column, alignment: .leading)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        VStack(spacing: 8) { bottom() }
                            .padding(.horizontal, YF.margin)
                            .padding(.top, 8)
                            .padding(.bottom, bottomPad)
                            .frame(width: column)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    // Short or wide displays: the words and button as one group in the middle. If that group is
                    // taller than the screen, the words scroll and the button stays pinned at the bottom instead.
                    ViewThatFits(in: .vertical) {
                        VStack(alignment: .leading, spacing: 0) {
                            content()
                            VStack(spacing: 8) { bottom() }
                                .padding(.top, 28)
                        }
                        .padding(.horizontal, YF.margin)
                        .padding(.top, top)
                        .padding(.bottom, max(8, bottomPad))
                        .frame(width: column, alignment: .leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                        VStack(spacing: 0) {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) { content() }
                                    .padding(.horizontal, YF.margin)
                                    .padding(.top, top)
                                    .padding(.bottom, 16)
                                    .frame(width: column, alignment: .leading)
                                    .frame(maxWidth: .infinity)
                            }
                            .scrollBounceBehavior(.basedOnSize)
                            VStack(spacing: 8) { bottom() }
                                .padding(.horizontal, YF.margin)
                                .padding(.top, 8)
                                .padding(.bottom, max(8, bottomPad))
                                .frame(width: column)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(background.ignoresSafeArea())
        .foregroundStyle(YF.ink)
        .toolbar(.hidden, for: .navigationBar)
    }
}

enum ScreenMetrics {
    /// The nearest any content may come to the top or bottom edge of the screen.
    static let edge: CGFloat = 24
    /// A normal iPhone in portrait (390 × 844 is 2.16). The Duo's displays are 1.45 (outer) and 0.70 (inner).
    static func isTall(_ size: CGSize) -> Bool { size.height / max(1, size.width) >= 1.75 }
}

extension Screen {
    /// A screen without its own Duo arrangement: everything sits in the trailing region, clear of the fold.
    var duoBody: some View {
        DuoPage(background: background, trailAlignment: .top, pinsBottom: true, lead: { EmptyView() }, trail: content, bottom: bottom)
    }
}

extension Screen where Bottom == EmptyView {
    init(background: Color = YF.ground, scrolls: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.init(background: background, scrolls: scrolls, content: content, bottom: { EmptyView() })
    }
}

/// A drawing made in fixed design coordinates (for example the 334 × 190 scene panels), scaled to the width it is given.
/// Every measurement in the references is a proportion of the 390 pt screen, so nothing is fixed in pixels.
struct DesignCanvas<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    var alignment: Alignment = .topLeading
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / width, geo.size.height / height)
            ZStack(alignment: alignment) { content() }
                .frame(width: width, height: height, alignment: alignment)
                .scaleEffect(s, anchor: .topLeading)
                .frame(width: width * s, height: height * s, alignment: .topLeading)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(width / height, contentMode: .fit)
    }
}

// MARK: - Buttons and bars

struct PrimaryButton: View {
    enum Kind { case leaf, hero }
    let title: String
    var kind: Kind = .leaf
    var enabled = true
    let action: () -> Void

    init(_ title: String, kind: Kind = .leaf, enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title; self.kind = kind; self.enabled = enabled; self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(YFFont.body(17, .semibold))
                .foregroundStyle(kind == .leaf ? YF.onAccent : YF.heroButtonText)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(kind == .leaf ? YF.leaf : YF.heroButtonFill, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.5)
    }
}

struct GhostButton: View {
    let title: String
    var color: Color = YF.textGreen
    let action: () -> Void
    init(_ title: String, color: Color = YF.textGreen, action: @escaping () -> Void) {
        self.title = title; self.color = color; self.action = action
    }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(YFFont.body(16, .semibold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, minHeight: 48)
                .overlay(Capsule().strokeBorder(color, lineWidth: 1.5))
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
    }
}

struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// 44 pt bar: a back chevron on the left (or nothing), anything on the right.
struct TopBar<Trailing: View>: View {
    @Environment(\.duoPose) private var pose
    var back: (() -> Void)?
    /// On the Duo's outer and wide displays the bar's back button moves into the trailing strip. Set this to keep the
    /// trailing item (for example "Not now") in the content there; otherwise the bar is not drawn at all.
    var keepsTrailingOnDuo = false
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        if pose.hasStrip {
            Group {
                if keepsTrailingOnDuo {
                    HStack { Spacer(); trailing() }.frame(height: 44)
                } else {
                    Color.clear.frame(height: 0)
                }
            }
            .modifier(BackInStrip(back: back))
        } else {
            phoneBar
        }
    }

    private var phoneBar: some View {
        HStack {
            if let back {
                Button(action: back) {
                    YFIcon("chev-left").foregroundStyle(YF.ink).frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .accessibilityLabel("Back")
                .padding(.leading, -12)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            Spacer()
            trailing()
        }
        .frame(height: 44)
    }
}

private struct BackInStrip: ViewModifier {
    let back: (() -> Void)?
    func body(content: Content) -> some View {
        if let back {
            content.duoStripItem("back", order: 0, icon: "chev-left", label: "Back", action: back)
        } else {
            content
        }
    }
}

extension TopBar where Trailing == EmptyView {
    init(back: (() -> Void)?) { self.init(back: back, trailing: { EmptyView() }) }
}

struct StepLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View { Text(text).font(YFFont.body(14, .medium)).foregroundStyle(YF.muted) }
}

// MARK: - Text

struct H1: View {
    @Environment(\.duoPose) private var pose
    let text: String
    var size: CGFloat = 36
    var color: Color = YF.ink
    init(_ text: String, size: CGFloat = 36, color: Color = YF.ink) { self.text = text; self.size = size; self.color = color }
    /// The Duo's outer display draws headings about 15% smaller than the phone.
    private var drawn: CGFloat { pose == .outer ? (size * 0.86).rounded() : size }
    var body: some View {
        Text(text)
            .font(YFFont.heading(drawn))
            .foregroundStyle(color)
            .designLineHeight(drawn, 1.1)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

struct Para: View {
    let text: String
    var size: CGFloat = 17
    var color: Color = YF.ink
    init(_ text: String, size: CGFloat = 17, color: Color = YF.ink) { self.text = text; self.size = size; self.color = color }
    var body: some View {
        Text(text)
            .font(YFFont.body(size))
            .foregroundStyle(color)
            .lineSpacing(size * 0.3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// The sunny yellow statement card: 22 pt radius, Baloo 2 600.
struct StatementCard: View {
    let text: String
    var size: CGFloat = 22
    var padding = EdgeInsets(top: 20, leading: 22, bottom: 20, trailing: 22)
    var caption: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let caption { Text(caption).font(YFFont.body(13, .semibold)) }
            Text(text).font(YFFont.heading(size, .semibold)).designLineHeight(size, 1.25).fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(YF.onAccent)
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(YF.sunny, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

/// A white card with a 1 pt line border.
struct CardBox<Content: View>: View {
    var radius: CGFloat = 22
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(YF.paper, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
    }
}

struct Divider1: View {
    var body: some View { Rectangle().fill(YF.line).frame(height: 1) }
}

struct Chip: View {
    let text: String
    var background: Color = YF.sunny
    var foreground: Color = YF.onAccent
    var check = false
    var body: some View {
        HStack(spacing: 5) {
            if check { YFIcon("check", size: 14) }
            Text(text).font(YFFont.body(13, .semibold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(background, in: Capsule())
    }
}

/// The design's switch: 52 × 32, leaf green when on, in a 44 pt touch target.
struct YFSwitch: View {
    @Binding var isOn: Bool
    let label: String
    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25)) { isOn.toggle() }
        } label: {
            Capsule().fill(isOn ? YF.leaf : YF.switchOff)
                .frame(width: 52, height: 32)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle().fill(.white).frame(width: 26, height: 26).padding(.horizontal, 3)
                }
                .frame(width: 76, height: 58)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
    }
}

/// Wraps chips onto as many lines as they need.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let r = arrange(proposal.width ?? .infinity, subviews).size
        // Take the full width offered, so the height is measured for the width the chips are placed in.
        return CGSize(width: proposal.width ?? r.width, height: r.height)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let r = arrange(bounds.width, subviews)
        for (i, p) in r.points.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y), proposal: .unspecified)
        }
    }
    private func arrange(_ width: CGFloat, _ subviews: Subviews) -> (size: CGSize, points: [CGPoint]) {
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0
        var pts: [CGPoint] = []
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x > 0, x + sz.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            pts.append(CGPoint(x: x, y: y))
            x += sz.width + spacing
            rowH = max(rowH, sz.height)
            maxX = max(maxX, x - spacing)
        }
        return (CGSize(width: maxX, height: y + rowH), pts)
    }
}

/// An icon and a line of text: the hour, the place, the things.
struct AnchorRow: View {
    let icon: String
    let text: String
    var iconSize: CGFloat = 20
    var gap: CGFloat = 12
    var minHeight: CGFloat = 30
    var body: some View {
        HStack(spacing: gap) {
            YFIcon(icon, size: iconSize).foregroundStyle(YF.textGreen)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
        .frame(minHeight: minHeight)
    }
}

// MARK: - Loose petals (confetti, rising petals)

/// Petals drifting down (or up) the screen with a gentle sway, drawn in one canvas.
/// - duration: stop after this many seconds (nil loops). Still under Reduce Motion: nothing is drawn.
struct PetalDrift: View {
    enum Direction { case falling, rising }
    struct Petal { let x: Double, size: Double, period: Double, delay: Double, sway: Double, swayPhase: Double, color: Color }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let petals: [Petal]
    let direction: Direction
    /// Distance travelled, in points, over one period.
    let travel: Double
    let startY: Double
    let loops: Bool
    @State private var start = Date()
    @State private var finished = false

    init(count: Int, colors: [Color], seed: UInt64, direction: Direction = .falling, period: ClosedRange<Double> = 6.5...11,
         sway: ClosedRange<Double> = 1.6...2.8, sizes: [Double] = [11, 13, 15, 17], travel: Double = 940, startY: Double = -40,
         loops: Bool = true, startDelay: Double = 0, stagger: Double? = nil) {
        var rng = SeededGenerator(seed: seed)
        self.petals = (0..<count).map { k in
            let p = Double.random(in: period, using: &rng)
            return Petal(x: (Double(k) + Double.random(in: 0...1, using: &rng)) / Double(count),
                         size: sizes.randomElement(using: &rng) ?? 13,
                         period: p,
                         delay: loops ? -Double.random(in: 0...p, using: &rng) : startDelay + Double.random(in: 0...(stagger ?? 1.6), using: &rng),
                         sway: Double.random(in: sway, using: &rng),
                         swayPhase: Double.random(in: 0...3, using: &rng),
                         color: colors[k % colors.count])
        }
        self.direction = direction; self.travel = travel; self.startY = startY; self.loops = loops
    }

    var body: some View {
        if reduceMotion || finished {
            Color.clear
        } else {
            TimelineView(.animation) { ctx in
                Canvas { g, size in
                    let t = ctx.date.timeIntervalSince(start)
                    for p in petals {
                        var local = t - p.delay
                        if local < 0 { continue }
                        if loops { local = local.truncatingRemainder(dividingBy: p.period) } else if local > p.period { continue }
                        let f = local / p.period
                        // Sway: ease in-out between −18 pt/−50° and +18 pt/+70°, alternating.
                        let phase = (t + p.swayPhase) / p.sway
                        let tri = abs(phase.truncatingRemainder(dividingBy: 2) - 1)
                        let e = tri * tri * (3 - 2 * tri)
                        let dx = -18 + 36 * e
                        let rot = -50 + 120 * e
                        var y = startY + travel * f
                        var alpha = 1.0
                        if direction == .rising {
                            y = startY - travel * f
                            alpha = f < 0.12 ? f / 0.12 : (f > 0.78 ? max(0, (1 - f) / 0.22) : 1)
                        }
                        var c = g
                        c.opacity = alpha
                        c.translateBy(x: p.x * size.width + dx, y: y)
                        c.rotate(by: .degrees(rot))
                        c.fill(LoosePetal().path(in: CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size)), with: .color(p.color))
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .task {
                guard !loops else { return }
                let longest = petals.map { $0.delay + $0.period }.max() ?? 6
                try? await Task.sleep(for: .seconds(longest + 0.2))
                finished = true
            }
        }
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed &* 0x9E3779B97F4A7C15 &+ 0xD1B54A32D192ED03 }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// A ring that ripples outward and fades: scale 0.6 → 1.9 over the first 62% of the period.
struct HaloRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let color: Color
    let lineWidth: CGFloat
    let period: Double
    var delay: Double = 0
    @State private var start = Date()

    var body: some View {
        if reduceMotion {
            Color.clear
        } else {
            TimelineView(.animation) { ctx in
                let t = ctx.date.timeIntervalSince(start) - delay
                let f = t < 0 ? 0 : t.truncatingRemainder(dividingBy: period) / period
                let p = min(1, f / 0.62)
                let eased = 1 - pow(1 - p, 2)
                let alpha = f < 0.12 ? 0.9 * f / 0.12 : max(0, 0.9 * (1 - (f - 0.12) / 0.5))
                Circle().strokeBorder(color, lineWidth: lineWidth)
                    .scaleEffect(0.6 + 1.3 * eased)
                    .opacity(t < 0 ? 0 : alpha)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

/// A screen led by an illustration (the idea screens). On a tall phone it is a normal `Screen` with the
/// illustration above the words. On a wide display, such as the open iPhone Duo, the illustration takes one
/// side and the words and button the other, both centred, so nothing has to scroll out of sight.
struct IllustratedScreen<Top: View, Art: View, Content: View, Bottom: View>: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    var artTop: CGFloat = 8
    @ViewBuilder var top: () -> Top
    @ViewBuilder var art: () -> Art
    @ViewBuilder var content: () -> Content
    @ViewBuilder var bottom: () -> Bottom

    @ViewBuilder var phoneBody: some View {
        GeometryReader { geo in
            if geo.size.width >= 600 && !ScreenMetrics.isTall(geo.size) {
                let topPad = max(8, ScreenMetrics.edge - geo.safeAreaInsets.top)
                let bottomPad = max(8, ScreenMetrics.edge - geo.safeAreaInsets.bottom)
                let column = min(YF.maxColumn - 2 * YF.margin, (geo.size.width - 3 * YF.margin) / 2)
                HStack(spacing: YF.margin) {
                    art()
                        .frame(maxWidth: column)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            top()
                            content()
                            VStack(spacing: 8) { bottom() }.padding(.top, 28)
                        }
                        .padding(.top, topPad)
                        .padding(.bottom, bottomPad)
                        .frame(minHeight: geo.size.height, alignment: .center)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .frame(width: column)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, YF.margin)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(YF.ground.ignoresSafeArea())
                .foregroundStyle(YF.ink)
                .toolbar(.hidden, for: .navigationBar)
            } else {
                Screen {
                    top()
                    art().padding(.top, artTop)
                    content()
                } bottom: {
                    bottom()
                }
            }
        }
    }
}

extension IllustratedScreen {
    /// Duo: the illustration is what you look at (leading region, or top region when tall); the words and button
    /// sit on the trailing side (or below the fold).
    var duoBody: some View {
        DuoPage(bar: { AnyView(top()) }) {
            art().frame(maxWidth: 520).frame(maxWidth: .infinity)
        } trail: {
            content()
        } bottom: {
            bottom()
        }
    }
}
