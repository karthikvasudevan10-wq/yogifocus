import SwiftUI

/// The 48-petal lotus, from `assets/lotus-geometry.json`: three rings of 16 in a −150…150 box.
/// Day 1 is the top petal of the inner ring; days run clockwise, then the middle ring, then the outer.
public enum LotusGeometry {
    public struct Ring: Sendable { public let base: CGFloat, length: CGFloat, width: CGFloat, offset: CGFloat }
    public static let rings: [Ring] = [
        Ring(base: 30, length: 44, width: 13, offset: 0),
        Ring(base: 62, length: 44, width: 19, offset: 11.25),
        Ring(base: 96, length: 48, width: 25, offset: 0),
    ]
    public static let box: CGFloat = 300
    public static let centreRadius: CGFloat = 27

    /// A petal pointing up from its base at the origin.
    public static func petal(length l: CGFloat, width w: CGFloat) -> Path {
        var p = Path()
        p.move(to: .zero)
        p.addCurve(to: CGPoint(x: 0, y: -l), control1: CGPoint(x: w, y: -0.35 * l), control2: CGPoint(x: w, y: -0.75 * l))
        p.addCurve(to: .zero, control1: CGPoint(x: -w, y: -0.75 * l), control2: CGPoint(x: -w, y: -0.35 * l))
        p.closeSubpath()
        return p
    }

    /// The transform that places petal `index` (0…15) of a ring, with an optional scale about the petal's base.
    public static func placement(ring: Ring, index: Int, scale: CGFloat = 1) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: (CGFloat(index) * 22.5 + ring.offset) * .pi / 180)
            .translatedBy(x: 0, y: -ring.base)
            .scaledBy(x: scale, y: scale)
    }
}

public struct LotusStyle {
    /// Open petals, from the inner ring out.
    public var open: [Color]
    public var missed: Color
    public var today: Color
    public var closed: Color
    public var closedEdge: Color
    /// The line between petals: the colour of whatever the lotus sits on.
    public var separator: Color
    public var centre: Color?
    public var strokeWidth: CGFloat

    public init(open: [Color] = [YF.deepLeaf, YF.mid, YF.leaf], missed: Color = YF.missed, today: Color = YF.saffron,
                closed: Color = YF.petalClosed, closedEdge: Color = YF.petalEdge, separator: Color = YF.petalSep,
                centre: Color? = YF.sunny, strokeWidth: CGFloat = 1.5) {
        self.open = open; self.missed = missed; self.today = today; self.closed = closed
        self.closedEdge = closedEdge; self.separator = separator; self.centre = centre; self.strokeWidth = strokeWidth
    }

    /// Progress colours: green for practised, red for missed, pale for days to come.
    public static let progress = LotusStyle()

    /// Decoration: every petal one family of tones, so it never reads as progress.
    public static func decoration(_ tones: [Color], on background: Color, centre: Color? = nil) -> LotusStyle {
        LotusStyle(open: tones, separator: background, centre: centre)
    }
}

public extension Array where Element == PetalState {
    static var allOpen: [PetalState] { Array(repeating: .practised, count: Mandala.days) }
    static var noneOpen: [PetalState] { Array(repeating: .toCome, count: Mandala.days) }
    /// The first `opened` days open, with the given days missed (as in the reference drawings).
    static func sample(opened: Int, missed: Set<Int> = [], today: Int? = nil) -> [PetalState] {
        (1...Mandala.days).map { d in
            if d == today { return .today }
            if d > opened { return .toCome }
            return missed.contains(d) ? .missed : .practised
        }
    }
}

/// Draws the lotus. Static unless `bloom` or `breathe` is asked for; both are still under Reduce Motion.
public struct LotusView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let petals: [PetalState]
    let style: LotusStyle
    let bloom: Bool
    let breathe: Bool
    @State private var bloomStart = Date()
    @State private var breathing = false
    @State private var bloomDone = false

    public init(petals: [PetalState] = .allOpen, style: LotusStyle = .progress, bloom: Bool = false, breathe: Bool = false) {
        self.petals = petals; self.style = style; self.bloom = bloom; self.breathe = breathe
    }

    public var body: some View {
        Group {
            if bloom && !reduceMotion && !bloomDone {
                // Day 30: the open petals unfold one by one, 0.06 s apart, each scaling up from its base.
                TimelineView(.animation) { ctx in
                    let elapsed = ctx.date.timeIntervalSince(bloomStart)
                    Canvas { g, size in
                        draw(&g, size: size, rings: [2, 1, 0], elapsed: elapsed)
                    }
                }
                .onAppear { bloomStart = Date() }
                .task {
                    try? await Task.sleep(for: .seconds(0.3 + Double(Mandala.days) * 0.06 + 1))
                    bloomDone = true
                }
            } else if breathe && !reduceMotion {
                // Each ring swells to 105% in turn, half a second apart, over 7 s.
                ZStack {
                    ForEach([2, 1, 0], id: \.self) { k in
                        Canvas { g, size in draw(&g, size: size, rings: [k], elapsed: nil, centre: false) }
                            .scaleEffect(breathing ? 1.05 : 1)
                            .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(Double(k) * 0.5), value: breathing)
                    }
                    Canvas { g, size in drawCentre(&g, size: size) }
                }
                .onAppear { breathing = true }
            } else {
                Canvas { g, size in draw(&g, size: size, rings: [2, 1, 0], elapsed: nil) }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private func draw(_ g: inout GraphicsContext, size: CGSize, rings: [Int], elapsed: Double?, centre: Bool = true) {
        let s = min(size.width, size.height) / LotusGeometry.box
        g.translateBy(x: size.width / 2, y: size.height / 2)
        g.scaleBy(x: s, y: s)
        for k in rings {
            let ring = LotusGeometry.rings[k]
            let shape = LotusGeometry.petal(length: ring.length, width: ring.width)
            for i in 0..<16 {
                let day = k * 16 + i + 1
                let state = day <= petals.count ? petals[day - 1] : .toCome
                var scale: CGFloat = 1
                var alpha: Double = 1
                if let elapsed, state != .toCome {
                    let t = (elapsed - (0.3 + Double(day) * 0.06)) / 0.6
                    if t <= 0 { continue }
                    if t < 1 {
                        scale = 0.15 + 0.85 * Self.overshoot(t)
                        alpha = min(1, t * 2.5)
                    }
                }
                let fill: Color, stroke: Color
                switch state {
                case .today: fill = style.today; stroke = style.separator
                case .missed: fill = style.missed; stroke = style.separator
                case .practised: fill = style.open[min(k, style.open.count - 1)]; stroke = style.separator
                case .toCome: fill = style.closed; stroke = style.closedEdge
                }
                let path = shape.applying(LotusGeometry.placement(ring: ring, index: i, scale: scale))
                g.opacity = alpha
                g.fill(path, with: .color(fill))
                g.stroke(path, with: .color(stroke), lineWidth: style.strokeWidth)
                g.opacity = 1
            }
        }
        if centre, let c = style.centre {
            let r = LotusGeometry.centreRadius
            g.fill(Path(ellipseIn: CGRect(x: -r, y: -r, width: 2 * r, height: 2 * r)), with: .color(c))
        }
    }

    private func drawCentre(_ g: inout GraphicsContext, size: CGSize) {
        guard let c = style.centre else { return }
        let s = min(size.width, size.height) / LotusGeometry.box
        let r = LotusGeometry.centreRadius * s
        g.fill(Path(ellipseIn: CGRect(x: size.width / 2 - r, y: size.height / 2 - r, width: 2 * r, height: 2 * r)), with: .color(c))
    }

    /// cubic-bezier(0.3, 1.3, 0.5, 1): a slight overshoot.
    static func overshoot(_ t: Double) -> CGFloat {
        let c1 = 1.70158 * 0.6, c3 = c1 + 1
        let u = t - 1
        return CGFloat(1 + c3 * u * u * u + c1 * u * u)
    }
}

/// The lotus with the number of days practised in its centre. Progress: only ever shown from day 30.
public struct LotusProgressView: View {
    let petals: [PetalState]
    let count: Int
    let bloom: Bool
    let style: LotusStyle
    public init(petals: [PetalState], count: Int, bloom: Bool = false, style: LotusStyle = .progress) {
        self.petals = petals; self.count = count; self.bloom = bloom; self.style = style
    }
    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                LotusView(petals: petals, style: style, bloom: bloom)
                Text("\(count)")
                    .font(YFFont.fixedHeading(max(11, size * 0.095)))
                    .foregroundStyle(YF.onAccent)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel(label)
    }
    private var label: String {
        let missed = petals.filter { $0 == .missed }.count
        return "Lotus with \(count) of 48 petals open" + (missed > 0 ? " and \(missed) red for missed days" : "")
    }
}

/// A single loose petal: confetti, the kept burst, petals rising on Welcome.
public struct LoosePetal: Shape {
    public init() {}
    /// CSS `border-radius: 0 100% 0 100%` on a square: a leaf with two sharp corners.
    public func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.maxY), control: CGPoint(x: r.maxX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.minY), control: CGPoint(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}
