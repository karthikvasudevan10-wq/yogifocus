import SwiftUI

/// The yogi: an original character drawn in a 200 × 200 box. Vector assets from `assets/svg/yogi/`.
public struct YogiView: View {
    public enum Pose: Sendable { case calm, joyful, namaste }
    let pose: Pose
    let whiteDhoti: Bool
    let mat: Bool

    /// - whiteDhoti: use on yellow grounds, where the yellow lower robe would vanish.
    /// - mat: with a mat he sits still (widgets); without one he floats.
    public init(_ pose: Pose = .calm, whiteDhoti: Bool = false, mat: Bool = false) {
        self.pose = pose; self.whiteDhoti = whiteDhoti; self.mat = mat
    }

    private var asset: String {
        let base: String
        switch pose {
        case .calm: base = "yogi-calm"
        case .joyful: base = "yogi-joyful"
        case .namaste: base = "yogi-namaste-joyful"
        }
        return whiteDhoti ? base + "-white-dhoti" : base
    }

    public var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height) / 200
            ZStack(alignment: .topLeading) {
                if mat {
                    RoundedRectangle(cornerRadius: 4.5 * u)
                        .fill(YF.textGreen)
                        .frame(width: 132 * u, height: 9 * u)
                        .offset(x: 34 * u, y: 174 * u)
                }
                Image(asset, bundle: .module)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 200 * u, height: 200 * u)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

/// One of the 25 line icons (24 × 24, 1.8 pt round strokes). Tinted with the foreground style.
public struct YFIcon: View {
    let name: String
    let size: CGFloat
    public init(_ name: String, size: CGFloat = 24) { self.name = name; self.size = size }
    public var body: some View {
        Image("icon-" + name, bundle: .module)
            .renderingMode(.template)
            .resizable()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// Tone-on-tone rays behind a hero: sixteen wedges of 10.4° every 22.5°, turning once in 140 s.
public struct RaysShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = max(rect.width, rect.height) / 2
        for k in 0..<16 {
            // CSS conic gradients start at the top and run clockwise.
            let a0 = Angle.degrees(-90 - 5.2 + Double(k) * 22.5)
            let a1 = Angle.degrees(-90 - 5.2 + Double(k) * 22.5 + 10.4)
            p.move(to: c)
            p.addArc(center: c, radius: r, startAngle: a0, endAngle: a1, clockwise: false)
            p.closeSubpath()
        }
        return p
    }
}

public struct RaysView: View {
    let color: Color
    public init(color: Color) { self.color = color }
    public var body: some View {
        RaysShape().fill(color).spin(period: 140).accessibilityHidden(true)
    }
}
