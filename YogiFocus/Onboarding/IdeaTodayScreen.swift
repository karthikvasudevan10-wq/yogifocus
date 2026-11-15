import SwiftUI
import YogiKit

/// Idea 1: Only today (`Idea-Today.html`).
struct IdeaTodayScreen: View {
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        IllustratedScreen(artTop: 8) {
            TopBar(back: onBack) { StepLabel("1 of 3") }
        } art: {
            DayNightScene()
        } content: {
            H1("Only today.").padding(.top, 18)
            Para("“Do this every day for the rest of your life” is too heavy to carry. So a yogi doesn't carry it. Each morning they ask a single question.")
                .padding(.top, 12)
            StatementCard(text: "This is a new day. How will I keep my practice today?")
                .padding(.top, 18)
            Para("It is the only thing Yogi Focus will ever ask of you.", size: 15, color: YF.muted)
                .padding(.top, 14)
        } bottom: {
            PrimaryButton("Next", action: onNext)
        }
    }
}

/// One day and night in 18 s, looping, starting at noon. Illustration colours are the same in both appearances.
struct DayNightScene: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    private struct Star { let x: CGFloat, y: CGFloat, r: CGFloat, period: Double, delay: Double }
    private let stars: [Star]

    private static let arcEase = KF.bezier(0.3, 0.1, 0.7, 0.9)
    private static let nightSky = Color(hex: 0x14284F)
    private static let moonColor = Color(hex: 0xFFF6CF)

    init() {
        var rng = SeededGenerator(seed: 11)
        stars = (0..<22).map { _ in
            Star(x: CGFloat(Int.random(in: 14...320, using: &rng)), y: CGFloat(Int.random(in: 10...112, using: &rng)),
                 r: [1.2, 1.6, 2.1].randomElement(using: &rng) ?? 1.6,
                 period: [1.7, 2.3, 2.9, 3.4].randomElement(using: &rng) ?? 2.3,
                 delay: Double.random(in: 0...3, using: &rng))
        }
    }

    var body: some View {
        DesignCanvas(width: 334, height: 190) {
            TimelineView(.animation(paused: reduceMotion)) { ctx in
                let t = reduceMotion ? 0 : ctx.date.timeIntervalSince(start)
                // "18s linear -4.5s": the loop starts a quarter of the way in, at noon.
                let p = KF.fraction(t + 4.5, period: 18)
                let dim = KF.lerp(p, [(0, 0.85), (0.05, 1), (0.40, 1), (0.52, 0.42), (0.88, 0.42), (1, 0.85)])
                let sat = KF.lerp(p, [(0, 1), (0.05, 1), (0.40, 1), (0.52, 0.8), (0.88, 0.8), (1, 1)])
                ZStack(alignment: .topLeading) {
                    Canvas { g, _ in drawSky(g, t: t, p: p) }
                    // Hills, trees and the small yogi darken at night.
                    ZStack(alignment: .topLeading) {
                        Canvas { g, _ in drawGround(g) }
                        YogiView(.calm).place(x: 217, y: 88 - 3 * KF.wave(t, period: 5), w: 60, h: 60)
                    }
                    .frame(width: 334, height: 190, alignment: .topLeading)
                    .colorMultiply(Color(white: dim))
                    .saturation(sat)
                }
                .frame(width: 334, height: 190, alignment: .topLeading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .accessibilityElement()
        .accessibilityLabel("The sun crosses the sky over a hill where a yogi sits, night falls with a moon and stars, and a new day rises")
    }

    private func drawSky(_ g: GraphicsContext, t: Double, p: Double) {
        let box = CGRect(x: 0, y: 0, width: 334, height: 190)
        g.fill(Path(box), with: .color(YF.daySky))

        // The sky fades to dark blue between 40% and 50% and back between 90% and 6%.
        let night = KF.lerp(p, [(0, 0.25), (0.06, 0), (0.40, 0), (0.50, 1), (0.90, 1), (1, 0.25)])
        if night > 0 {
            var c = g
            c.opacity = night
            c.fill(Path(box), with: .color(Self.nightSky))
        }

        let starOpacity = KF.lerp(p, [(0, 0), (0.46, 0), (0.54, 1), (0.88, 1), (0.96, 0), (1, 0)])
        if starOpacity > 0 {
            for s in stars {
                var c = g
                c.opacity = starOpacity * (1 - 0.75 * KF.wave(t + s.delay, period: s.period))
                c.circle(s.x, s.y, s.r, Self.moonColor)
            }
        }

        // The sun arcs from behind the left of the hill to behind the right over the first half.
        let sunAngle = p < 0.5 ? -98 + 196 * Self.arcEase(p / 0.5) : -98
        var sun = g
        sun.translateBy(x: 167, y: 230)
        sun.rotate(by: .degrees(sunAngle))
        sun.translateBy(x: -167, y: -230)
        sun.circle(167, 72, 64 * (1 + 0.05 * KF.wave(t, period: 4)), Color(hex: 0xFFE566))
        sun.circle(167, 72, 50 * (1 + 0.05 * KF.wave(t - 0.4, period: 4)), YF.sunny)
        for k in 0..<12 {
            var r = sun
            r.translateBy(x: 167, y: 72)
            r.rotate(by: .degrees(Double(k) * 30 + 360 * t / 18))
            r.line(0, -46, 0, -56, YF.saffron, width: 4)
        }
        sun.circle(167, 72, 36, YF.saffron)

        // A slim crescent moon follows the same arc between 47% and 94%.
        let moonAngle = (p >= 0.47 && p < 0.94) ? -98 + 196 * Self.arcEase((p - 0.47) / 0.47) : -98
        var moon = g
        moon.translateBy(x: 167, y: 230)
        moon.rotate(by: .degrees(moonAngle))
        moon.translateBy(x: -167, y: -230)
        var glow = moon
        glow.opacity = 0.55
        glow.circle(167, 72, 44 * (1 + 0.05 * KF.wave(t, period: 4)), Color(hex: 0x2C4C8C))
        let crescent = Path(ellipseIn: CGRect(x: 143, y: 48, width: 48, height: 48))
            .subtracting(Path(ellipseIn: CGRect(x: 150, y: 45, width: 44, height: 44)))
        moon.fill(crescent, with: .color(Self.moonColor))

        // Clouds drift throughout and dim at night.
        var clouds = g
        clouds.opacity = KF.lerp(p, [(0, 0.8), (0.06, 1), (0.40, 1), (0.50, 0.2), (0.90, 0.2), (1, 0.8)])
        for (y, period, delay, scale) in [(18.0, 30.0, 8.0, 1.0), (50.0, 42.0, 27.0, 0.7)] {
            var c = clouds
            c.translateBy(x: 0, y: y)
            c.scaleBy(x: scale, y: scale)
            c.translateBy(x: -80 + 430 * KF.fraction(t + delay, period: period), y: 0)
            c.fill(Path(ellipseIn: CGRect(x: 0, y: 11, width: 56, height: 18)), with: .color(.white))
            c.circle(19, 14, 10, .white)
            c.circle(35, 11, 12, .white)
        }
    }

    private func drawGround(_ g: GraphicsContext) {
        var back = Path()
        back.move(to: CGPoint(x: 0, y: 190))
        back.addLine(to: CGPoint(x: 0, y: 158))
        back.addQuadCurve(to: CGPoint(x: 334, y: 158), control: CGPoint(x: 167, y: 98))
        back.addLine(to: CGPoint(x: 334, y: 190))
        back.closeSubpath()
        g.fill(back, with: .color(YF.leaf))

        for (x, y, r) in [(58.0, 132.0, 11.0), (84.0, 124.0, 8.0)] {
            g.fill(Path(roundedRect: CGRect(x: x - 2, y: y, width: 4, height: 16), cornerRadius: 2), with: .color(YF.hair))
            g.circle(x, y - 4, r, YF.deepLeaf)
        }

        var front = Path()
        front.move(to: CGPoint(x: 0, y: 190))
        front.addLine(to: CGPoint(x: 0, y: 178))
        front.addQuadCurve(to: CGPoint(x: 220, y: 172), control: CGPoint(x: 110, y: 146))
        front.addQuadCurve(to: CGPoint(x: 334, y: 170), control: CGPoint(x: 280, y: 186))
        front.addLine(to: CGPoint(x: 334, y: 190))
        front.closeSubpath()
        g.fill(front, with: .color(YF.mid))
    }
}
