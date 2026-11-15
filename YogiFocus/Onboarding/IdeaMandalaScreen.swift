import SwiftUI
import YogiKit

/// Idea 3: One mandala (`Idea-Mandala.html`). The graph animates once, then rests.
struct IdeaMandalaScreen: View {
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        IllustratedScreen(artTop: 8) {
            TopBar(back: onBack) { StepLabel("3 of 3") }
        } art: {
            JourneyGraph()
        } content: {
            H1("One mandala is 48 days.").padding(.top, 16)
            Para("Yogis hold that a practice kept for one mandala is likely to stay for life. This is how those 48 days tend to go.", size: 15.5)
                .padding(.top, 8)
            VStack(alignment: .leading, spacing: 12) {
                pathRow(dotted: true, title: "Willpower alone",
                        text: "A burst of effort, a crash in the boring middle, and then interest quietly dies.")
                pathRow(dotted: false, title: "With Yogi Focus",
                        text: "A gentle ten-minute start, a shallow dip, a nudge to just start, and by the end it runs on its own.")
            }
            .padding(.top, 16)
        } bottom: {
            PrimaryButton("Next", action: onNext)
        }
        .overlay {
            // About 26 petals shower down the whole screen once, as the lotus blooms at the end of the path.
            GeometryReader { geo in
                PetalDrift(count: 26, colors: [YF.pink, .white, YF.sunny, YF.saffron, YF.pink, YF.mid], seed: 4,
                           direction: .falling, period: 3.2...5.2, sway: 1.4...2.4, sizes: [11, 13, 15],
                           travel: Double(geo.size.height) + 100, startY: -40, loops: false,
                           startDelay: JourneyGraph.blueEnd, stagger: 1.6)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private func pathRow(dotted: Bool, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Canvas { g, _ in
                var p = Path()
                p.move(to: CGPoint(x: 2, y: 6))
                p.addLine(to: CGPoint(x: 24, y: 6))
                if dotted {
                    g.stroke(p, with: .color(JourneyGraph.orange), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [0.1, 7.3]))
                } else {
                    g.stroke(p, with: .color(YF.textGreen), style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
                }
            }
            .frame(width: 26, height: 12)
            .padding(.top, 6)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(YFFont.body(16, .semibold))
                Text(text).font(YFFont.body(15)).foregroundStyle(YF.muted).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Two paths across 48 days: willpower alone (orange, dotted) against the Yogi Focus journey (green).
/// The owner's illustration of how things tend to go: no axis and no numbers, on purpose.
struct JourneyGraph: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    @State private var done = false

    // Seconds: orange starts / lasts, green starts / lasts.
    static let orangeStart = 0.5, orangeLasts = 2.8, blueStart = 3.6, blueLasts = 4.2
    static let blueEnd = blueStart + blueLasts

    // The panel keeps its light colours in both appearances, so its text is fixed too.
    static let orange = Color(hex: 0xE8792B)
    private static let orangeLabel = Color(hex: 0xA84A12)
    private static let green = Color(hex: 0x127A35)
    private static let ink = Color(hex: 0x14301F)
    private static let muted = Color(hex: 0x4F6355)
    private static let panel = Color(hex: 0xE6F8D2)

    private static func dx(_ d: Double) -> Double { 18 + d * 5.85 }
    private static func ly(_ v: Double) -> Double { 150 - v * 1.3 }
    private static let journey: [CGPoint] = [(0, 35), (4, 60), (14, 48), (16, 55), (27, 72), (38, 84), (42, 86), (48, 88)]
        .map { CGPoint(x: dx($0.0), y: ly($0.1)) }
    private static let willpower: [CGPoint] = [(0, 20), (4, 95), (14, 30), (20, 42), (27, 22), (48, 5)]
        .map { CGPoint(x: dx($0.0), y: ly($0.1)) }
    private static let cum: [Double] = {
        var c = [0.0]
        for (a, b) in zip(journey, journey.dropFirst()) { c.append(c[c.count - 1] + Double(hypot(b.x - a.x, b.y - a.y))) }
        return c
    }()
    /// Where along the green path day 7 and day 27 fall, as fractions of its length.
    private static let p7 = (cum[1] + (cum[2] - cum[1]) * 0.3) / cum[cum.count - 1]
    private static let p27 = cum[4] / cum[cum.count - 1]

    private static func polyline(_ pts: [CGPoint]) -> Path {
        var p = Path()
        p.addLines(pts)
        return p
    }

    private static func point(at fraction: Double) -> CGPoint {
        let target = fraction * cum[cum.count - 1]
        for i in 1..<cum.count where target <= cum[i] {
            let f = (target - cum[i - 1]) / max(0.0001, cum[i] - cum[i - 1])
            let a = journey[i - 1], b = journey[i]
            return CGPoint(x: a.x + (b.x - a.x) * f, y: a.y + (b.y - a.y) * f)
        }
        return journey[journey.count - 1]
    }

    var body: some View {
        DesignCanvas(width: 334, height: 200) {
            TimelineView(.animation(paused: reduceMotion || done)) { ctx in
                // Reduce Motion, and the rest after playing: the final picture.
                let t = (reduceMotion || done) ? 60 : ctx.date.timeIntervalSince(start)
                Canvas { g, _ in draw(g, t: t) }
                    .frame(width: 334, height: 200)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(Self.blueEnd + 2.5))
            done = true
        }
        .accessibilityElement()
        .accessibilityLabel("Two paths across 48 days. Willpower alone, dotted orange, starts high, crashes in the boring middle and fades out. With Yogi Focus, solid green, the start is gentle, the dip is shallow, and the routine climbs and settles.")
    }

    private func label(_ g: GraphicsContext, _ text: String, x: Double, y: Double, size: CGFloat, weight: Font.Weight, color: Color, opacity: Double = 1) {
        guard opacity > 0 else { return }
        var c = g
        c.opacity = opacity
        // SVG text sits on its baseline; the resolved text is anchored a little below it.
        c.draw(Text(text).font(YFFont.fixedBody(size, weight)).foregroundColor(color), at: CGPoint(x: x, y: y + 3.5), anchor: .bottom)
    }

    private func draw(_ g: GraphicsContext, t: Double) {
        let dx = Self.dx, ly = Self.ly
        let p7 = Self.p7, p27 = Self.p27
        // Progress of the green path, 0…1, linear; holds at 0 before it starts and at 1 after.
        let q = min(1, max(0, (t - Self.blueStart) / Self.blueLasts))
        let w = min(1, max(0, (t - Self.orangeStart) / Self.orangeLasts))
        let end = Self.journey[Self.journey.count - 1]

        g.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: 334, height: 200), cornerRadius: 26, style: .continuous), with: .color(Self.panel))
        g.fill(Path(roundedRect: CGRect(x: dx(7), y: 14, width: dx(27) - dx(7), height: 146), cornerRadius: 12), with: .color(Color(hex: 0xD6F2BC)))

        // Each zone lights up as the dot passes: yellow, then muted orange (both fade once crossed), then green (stays).
        let band1 = KF.lerp(q, [(0, 0), (0.04, 1), (p7, 1), (p7 + 0.06, 0), (1, 0)])
        let band2 = KF.lerp(q, [(0, 0), (p7 - 0.01, 0), (p7 + 0.05, 1), (p27, 1), (p27 + 0.06, 0), (1, 0)])
        let band3 = KF.lerp(q, [(0, 0), (p27 - 0.01, 0), (p27 + 0.05, 1), (1, 1)])
        func band(_ x: Double, _ width: Double, _ color: Color, _ opacity: Double) {
            guard opacity > 0 else { return }
            var c = g
            c.opacity = opacity
            c.fill(Path(roundedRect: CGRect(x: x, y: 14, width: width, height: 146), cornerRadius: 12), with: .color(color))
        }
        band(dx(0) - 8, dx(7) - dx(0) + 6, YF.sunny, band1)
        band(dx(7) + 2, dx(27) - dx(7) - 4, Color(hex: 0xF2AE8B), band2)
        band(dx(27) + 2, dx(48) - dx(27) - 4 + 8, Color(hex: 0xB9F08F), band3)

        // Willpower alone: dotted, drawn over 2.8 s.
        if w > 0 {
            g.stroke(Self.polyline(Self.willpower).trimmedPath(from: 0, to: w), with: .color(Self.orange),
                     style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [0.1, 8]))
        }
        label(g, "Interest fades", x: dx(37.5), y: ly(13) - 12, size: 12.5, weight: .bold, color: Self.orangeLabel,
              opacity: KF.lerp((t - Self.orangeStart - Self.orangeLasts) / 0.5, [(0, 0), (1, 1)], ease: KF.easeOut))
        label(g, "Boring middle", x: (dx(7) + dx(27)) / 2, y: 150, size: 12.5, weight: .bold, color: Self.ink, opacity: band2)
        label(g, "It becomes yours", x: dx(37.5), y: ly(80) + 24, size: 12.5, weight: .bold, color: Self.green, opacity: band3)

        // With Yogi Focus: solid, drawn over 4.2 s, led by a dot.
        if q > 0 {
            g.stroke(Self.polyline(Self.journey).trimmedPath(from: 0, to: q), with: .color(Self.green),
                     style: StrokeStyle(lineWidth: 4.5, lineCap: .round, lineJoin: .round))
        }

        // At the end of the path a ring bursts and a pink and yellow lotus blooms.
        let burst = (t - Self.blueEnd) / 1.1
        if burst > 0, burst < 1 {
            let e = KF.easeOut(burst)
            var c = g
            c.opacity = KF.lerp(e, [(0, 0), (0.15, 0.9), (1, 0)])
            let r = 9 * (0.4 + 2.6 * e)
            c.stroke(Path(ellipseIn: CGRect(x: end.x - r, y: end.y - r, width: 2 * r, height: 2 * r)), with: .color(YF.pink), lineWidth: 3 * (0.4 + 2.6 * e))
        }
        func bloom(_ k: Int, base: CGFloat, length: CGFloat, width: CGFloat, color: Color, offset: Double) {
            let f = (t - Self.blueEnd - 0.05 * Double(k)) / 0.55
            guard f > 0 else { return }
            let scale = f >= 1 ? 1 : 0.15 + 0.85 * KF.overshoot(f)
            let transform = CGAffineTransform(translationX: end.x, y: end.y)
                .rotated(by: (offset + Double(k) * 45) * .pi / 180)
                .translatedBy(x: 0, y: -base)
                .scaledBy(x: scale, y: scale)
            let path = LotusGeometry.petal(length: length, width: width).applying(transform)
            var c = g
            c.opacity = min(1, f)
            c.fill(path, with: .color(color))
            c.stroke(path, with: .color(Self.panel), lineWidth: 0.8)
        }
        for k in 0..<8 { bloom(k, base: 7, length: 17, width: 6.5, color: YF.pink, offset: 0) }
        for k in 0..<8 { bloom(k, base: 5, length: 11, width: 4.5, color: YF.sunny, offset: 22.5) }

        // The dot fades in just before the path starts and rests at its end.
        let head = KF.lerp((t - (Self.blueStart - 0.2)) / 0.25, [(0, 0), (1, 1)])
        if head > 0 {
            let pt = Self.point(at: q)
            var c = g
            c.opacity = head
            let dot = Path(ellipseIn: CGRect(x: pt.x - 6.5, y: pt.y - 6.5, width: 13, height: 13))
            c.fill(dot, with: .color(Self.green))
            c.stroke(dot, with: .color(.white), lineWidth: 2.5)
        }

        label(g, "Days 1–6", x: (dx(0) + dx(7)) / 2 + 4, y: 182, size: 12, weight: .semibold, color: Self.muted)
        label(g, "Days 7–27", x: (dx(7) + dx(27)) / 2, y: 182, size: 12, weight: .semibold, color: Self.muted)
        label(g, "Days 28–48", x: (dx(27) + dx(48)) / 2, y: 182, size: 12, weight: .semibold, color: Self.muted)
    }
}
