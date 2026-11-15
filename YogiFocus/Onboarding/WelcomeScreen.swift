import SwiftUI
import YogiKit

/// Welcome (`Main.html`): a greeting. Golden mandala turning behind, lotus turning below, petals rising.
struct WelcomeScreen: View {
    let onBegin: () -> Void

    var body: some View {
        GeometryReader { geo in
            if geo.size.width >= 600 {
                // The open iPhone Duo: graphic on one side, text and button on the other.
                HStack(spacing: 0) {
                    hero(extraTop: 0, anchor: .center, alignment: .center)
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 0)
                        words
                        PrimaryButton("Begin", kind: .hero, action: onBegin).padding(.top, 28)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, YF.margin)
                    .frame(width: min(YF.maxColumn, geo.size.width * 0.5))
                }
            } else {
                // The hero takes the height left after the text and button, never more than its drawn size.
                let top = geo.safeAreaInsets.top
                let drawn = 470 * geo.size.width / YF.referenceWidth - top
                let heroHeight = max(110, min(drawn, geo.size.height - 350))
                VStack(alignment: .leading, spacing: 0) {
                    hero(extraTop: top, anchor: .bottom, alignment: .bottom)
                        .frame(height: heroHeight)
                    words.padding(.horizontal, YF.margin)
                    Spacer(minLength: 12)
                    PrimaryButton("Begin", kind: .hero, action: onBegin)
                        .padding(.horizontal, YF.margin)
                        .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 0 : 16)
                }
            }
        }
        .background(YF.heroYellow.ignoresSafeArea())
        .foregroundStyle(YF.ink)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func hero(extraTop: CGFloat, anchor: UnitPoint, alignment: Alignment) -> some View {
        GeometryReader { g in
            let s = min(1.5, min(g.size.width / 390, (g.size.height + extraTop) / 470))
            WelcomeScene()
                .scaleEffect(s, anchor: anchor)
                .frame(width: g.size.width, height: g.size.height, alignment: alignment)
        }
    }

    private var words: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Namaste, and welcome.")
                .font(YFFont.heading(19, .semibold))
            Text("Yogi Focus")
                .font(YFFont.heading(50))
                .designLineHeight(50, 1.0)
                .foregroundStyle(YF.textGreen)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 2)
                .accessibilityAddTraits(.isHeader)
            Text("One small routine.\nOne day at a time.")
                .font(YFFont.heading(30, .semibold))
                .designLineHeight(30, 1.15)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
            Para("Come as you are. Scattered days and missed days are welcome here too. We'll go gently.", size: 16)
                .padding(.top, 8)
        }
    }
}

/// The hero, drawn in a 390 × 470 box at the top of the screen.
struct WelcomeScene: View {
    @Environment(\.colorScheme) private var scheme

    private var gold: [Color] {
        scheme == .dark
            ? [Color(hex: 0x3D3D13), Color(hex: 0x33350F), Color(hex: 0x2A2D0C)]
            : [Color(hex: 0xFFE680), Color(hex: 0xFFDF57), Color(hex: 0xFFDB45)]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // The golden mandala, turning slowly the other way.
            LotusView(style: .decoration(gold, on: YF.heroYellow))
                .spin(period: 120, reverse: true)
                .place(x: -25, y: -5, w: 440, h: 440)
            // Two soft rings ripple outward every 5 s.
            HaloRing(color: YF.welcomeRipple, lineWidth: 5, period: 5).place(x: 100, y: 120, w: 190, h: 190)
            HaloRing(color: YF.welcomeRipple, lineWidth: 5, period: 5, delay: 2.5).place(x: 100, y: 120, w: 190, h: 190)
            // The green lotus he floats above, seen at an angle.
            LotusView(style: .decoration([YF.deepLeaf, YF.mid, YF.leaf], on: YF.heroYellow))
                .spin(period: 48)
                .frame(width: 414, height: 414)
                .scaleEffect(x: 1, y: 0.4)
                .offset(x: -12, y: 177)
            FloatShadow(color: YF.heroShadow, base: 0.26).place(x: 131, y: 371, w: 128, h: 26)
            // Petals rise from the lotus and fade.
            PetalDrift(count: 14,
                       colors: [.white, YF.pink, YF.saffron, .white, YF.deepLeaf, YF.pink, .white],
                       seed: 7, direction: .rising, period: 7...11, sway: 1.8...3, sizes: [11, 13, 15],
                       travel: 470, startY: 500)
                .place(x: 0, y: -100, w: 390, h: 570)
            YogiView(.namaste, whiteDhoti: true)
                .levitate(low: 6, high: -13.5)
                .place(x: 45, y: 76, w: 300, h: 300)
        }
        .frame(width: 390, height: 470, alignment: .topLeading)
        .accessibilityElement()
        .accessibilityLabel("A smiling yogi greets you with palms together, floating above a turning lotus")
    }
}
