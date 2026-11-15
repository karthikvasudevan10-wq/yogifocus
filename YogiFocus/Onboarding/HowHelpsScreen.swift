import SwiftUI
import YogiKit

/// How Yogi Focus helps you build a routine (`How-Yogi-Helps.html`): an invitation to set the first routine.
struct HowHelpsScreen: View {
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        IllustratedScreen(artTop: 6) {
            TopBar(back: onBack)
        } art: {
            HelpArt()
        } content: {
            H1("How Yogi Focus helps you build a routine", size: 31).padding(.top, 14)
            VStack(alignment: .leading, spacing: 13) {
                row(YF.sunny, "widget", "A gentle nudge, right on time",
                    "A widget on your Home Screen shows the hour, the place and what to bring.")
                row(YF.leaf, "heart", "A kind word every day",
                    "Tell Yogi Focus how your practice felt. Every answer is a good one.")
                row(Color(hex: 0xFFB07A), "lotus", "A lotus that blooms with you",
                    "Each day you practise opens a petal. After 30 days, you get to see it.")
            }
            .padding(.top, 16)
            StatementCard(text: "Ten minutes a day is all it takes to begin. Let's choose your first routine.", size: 19,
                          padding: EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                .padding(.top, 16)
        } bottom: {
            PrimaryButton("Choose my first routine", action: onNext)
        }
    }

    private func row(_ color: Color, _ icon: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle().fill(color).frame(width: 46, height: 46)
                .overlay { YFIcon(icon).foregroundStyle(YF.onAccent) }
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(YFFont.body(16.5, .semibold))
                Text(text).font(YFFont.body(14.5)).foregroundStyle(YF.muted).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// A smiling yogi floats above a turning lotus beside a small tilted "It's time" widget, with little hearts rising.
struct HelpArt: View {
    var body: some View {
        DesignCanvas(width: 334, height: 164) {
            ZStack(alignment: .topLeading) {
                YF.softGreen
                LotusView(style: .decoration([YF.deepLeaf, YF.mid, YF.leaf], on: YF.softGreen))
                    .spin(period: 40)
                    .frame(width: 300, height: 300)
                    .scaleEffect(x: 0.78, y: 0.34)
                    .offset(x: 222 - 150, y: 150 - 150)
                FloatShadow(color: Color(hex: 0x0B3D1A), base: 0.22).place(x: 188, y: 144, w: 68, h: 12)
                RisingHearts().frame(width: 334, height: 164)
                YogiView(.namaste)
                    .levitate()
                    .place(x: 159, y: 6, w: 126, h: 126)
                MiniWidget()
                    .rotationEffect(.degrees(-6), anchor: UnitPoint(x: 56.0 / 112, y: 52.0 / 104))
                    .levitate(low: 0, high: -3, period: 5)
                    .offset(x: 24, y: 30)
            }
            .frame(width: 334, height: 164, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .accessibilityElement()
        .accessibilityLabel("A smiling yogi floats above a turning lotus beside a small widget that says It is time, Meditate")
    }
}

/// The small sunny widget in the illustration: "It's time · Meditate · Done".
private struct MiniWidget: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(YF.sunny)
            HStack(spacing: 5) {
                Circle().fill(YF.saffron).frame(width: 8, height: 8)
                Text("It's time").font(YFFont.fixedBody(11, .bold))
            }
            .offset(x: 13, y: 13)
            Text("Meditate").font(YFFont.fixedHeading(20))
                .offset(x: 13, y: 30)
            Text("Done").font(YFFont.fixedBody(12, .bold))
                .frame(width: 86, height: 27)
                .background(YF.leaf, in: Capsule())
                .offset(x: 13, y: 64)
        }
        .foregroundStyle(YF.onAccent)
        .frame(width: 112, height: 104, alignment: .topLeading)
    }
}

/// Three little hearts, each rising 64 pt and fading over 4 s.
private struct RisingHearts: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    private static let hearts: [(x: CGFloat, y: CGFloat, delay: Double, scale: CGFloat)] = [
        (176, 60, 0, 1), (268, 48, 1.7, 0.8), (250, 86, 2.9, 0.65),
    ]
    private static let heart: Path = {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 6))
        p.addCurve(to: CGPoint(x: -5, y: -9), control1: CGPoint(x: -9, y: 0), control2: CGPoint(x: -10, y: -7))
        p.addCurve(to: CGPoint(x: 0, y: -6), control1: CGPoint(x: -2, y: -10), control2: CGPoint(x: 0, y: -8))
        p.addCurve(to: CGPoint(x: 5, y: -9), control1: CGPoint(x: 0, y: -8), control2: CGPoint(x: 2, y: -10))
        p.addCurve(to: CGPoint(x: 0, y: 6), control1: CGPoint(x: 10, y: -7), control2: CGPoint(x: 9, y: 0))
        p.closeSubpath()
        return p
    }()

    var body: some View {
        if reduceMotion {
            Color.clear
        } else {
            TimelineView(.animation) { ctx in
                Canvas { g, _ in
                    let t = ctx.date.timeIntervalSince(start)
                    for h in Self.hearts {
                        let local = t - h.delay
                        guard local >= 0 else { continue }
                        let f = KF.easeOut(KF.fraction(local, period: 4))
                        var c = g
                        c.opacity = KF.lerp(f, [(0, 0), (0.15, 1), (1, 0)])
                        c.translateBy(x: h.x, y: h.y)
                        c.scaleBy(x: h.scale, y: h.scale)
                        c.translateBy(x: 0, y: -64 * f)
                        // The heart grows from half size about its own centre.
                        c.translateBy(x: 0, y: -1.75)
                        c.scaleBy(x: 0.5 + 0.5 * f, y: 0.5 + 0.5 * f)
                        c.translateBy(x: 0, y: 1.75)
                        c.fill(Self.heart, with: .color(YF.pink))
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
