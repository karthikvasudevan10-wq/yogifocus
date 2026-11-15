import SwiftUI
import YogiKit

/// Idea 2: Same time, same place, same things (`Idea-Same.html`).
struct IdeaSameScreen: View {
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        IllustratedScreen(artTop: 8) {
            TopBar(back: onBack) { StepLabel("2 of 3") }
        } art: {
            SameScene()
        } content: {
            H1("Same time.\nSame place.\nSame things.").padding(.top, 18)
            Para("A yogi practises at the exact hour, in the exact spot, with the same mat and the same clothes.")
                .padding(.top, 12)
            Para("When nothing around the routine changes, there is nothing to decide and nothing to remember. The moment itself reminds you.")
                .padding(.top, 12)
        } bottom: {
            PrimaryButton("Next", action: onNext)
        }
    }
}

/// A 6.5 s loop: the clock settles on 7:00, the pin drops and bounces, the mat unrolls; a chime; a hold;
/// then a day whirls by and it all happens again.
struct SameScene: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    var body: some View {
        DesignCanvas(width: 334, height: 170) {
            TimelineView(.animation(paused: reduceMotion)) { ctx in
                // "6.5s ease-in-out -4.3s". Reduce Motion rests in the hold.
                let p = reduceMotion ? 0.7 : KF.fraction(ctx.date.timeIntervalSince(start) + 4.3, period: 6.5)
                Canvas { g, _ in draw(g, p: p) }
                    .frame(width: 334, height: 170)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("A clock settles at seven, a pin drops on the same spot and a mat unrolls, again and again")
    }

    private func draw(_ g: GraphicsContext, p: Double) {
        let e = KF.easeInOut
        g.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: 334, height: 170), cornerRadius: 26, style: .continuous), with: .color(YF.softGreen))

        // The chime: a ring out from the clock and under the pin at about 55%.
        let chimeScale = KF.lerp(p, [(0, 0.9), (0.53, 0.9), (0.82, 1.55), (1, 1.55)], ease: e)
        let chimeOpacity = KF.lerp(p, [(0, 0), (0.53, 0), (0.58, 0.9), (0.82, 0), (1, 0)], ease: e)
        if chimeOpacity > 0 {
            var c = g
            c.opacity = chimeOpacity
            let r = 40 * chimeScale
            c.stroke(Path(ellipseIn: CGRect(x: 104 - r, y: 66 - r, width: 2 * r, height: 2 * r)), with: .color(YF.saffron), lineWidth: 4 * chimeScale)
        }

        // The clock.
        g.circle(104, 66, 40, YF.sunny)
        for k in 0..<4 {
            var c = g
            c.translateBy(x: 104, y: 66)
            c.rotate(by: .degrees(Double(k) * 90))
            c.line(0, -33, 0, -29, YF.onAccent, width: 2.5)
        }
        let hour = KF.lerp(p, [(0, -30), (0.55, 0), (0.88, 0), (1, 330)], ease: e)
        var h = g
        h.translateBy(x: 104, y: 66)
        h.rotate(by: .degrees(hour))
        h.line(0, 0, -10, 17, YF.onAccent, width: 4.5)
        let minute = KF.lerp(p, [(0, -360), (0.55, 0), (0.88, 0), (1, 720)], ease: e)
        var m = g
        m.translateBy(x: 104, y: 66)
        m.rotate(by: .degrees(minute))
        m.line(0, 0, 0, -27, YF.onAccent, width: 3.5)
        g.circle(104, 66, 3.5, YF.onAccent)

        // The pin drops and bounces once.
        if chimeOpacity > 0 {
            var c = g
            c.opacity = chimeOpacity
            c.stroke(Path(ellipseIn: CGRect(x: 226 - 18 * chimeScale, y: 106 - 5 * chimeScale, width: 36 * chimeScale, height: 10 * chimeScale)),
                     with: .color(YF.saffron), lineWidth: 3 * chimeScale)
        }
        let dropY = KF.lerp(p, [(0, -52), (0.52, 0), (0.58, -8), (0.64, 0), (0.90, 0), (1, -52)], ease: e)
        let dropOpacity = KF.lerp(p, [(0, 0), (0.14, 1), (0.90, 1), (1, 0)], ease: e)
        var pin = g
        pin.opacity = dropOpacity
        pin.translateBy(x: 0, y: dropY)
        var shape = Path()
        shape.move(to: CGPoint(x: 226, y: 104))
        shape.addCurve(to: CGPoint(x: 202, y: 58), control1: CGPoint(x: 206, y: 78), control2: CGPoint(x: 202, y: 68))
        shape.addArc(center: CGPoint(x: 226, y: 58), radius: 24, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        shape.addCurve(to: CGPoint(x: 226, y: 104), control1: CGPoint(x: 250, y: 68), control2: CGPoint(x: 246, y: 78))
        shape.closeSubpath()
        pin.fill(shape, with: .color(YF.saffron))
        pin.circle(226, 58, 9, .white)

        // The mat grows in length from under its rolled end, so its rounded end stays round.
        let offset = KF.lerp(p, [(0, 196), (0.55, 0), (0.88, 0), (1, 196)], ease: e)
        g.line(65, 135, 65 + (204 - offset), 135, YF.leaf, width: 26)
        g.fill(Path(roundedRect: CGRect(x: 248 - offset, y: 122, width: 34, height: 26), cornerRadius: 13),
               with: .color(YF.textGreen))
    }
}
