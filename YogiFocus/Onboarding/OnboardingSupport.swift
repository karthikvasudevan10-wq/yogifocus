import SwiftUI
import YogiKit

/// Keyframe helpers for the illustration clocks. Each scene is driven by one clock and computes its own values.
enum KF {
    /// Piecewise interpolation between (position, value) stops, with an easing applied inside each interval.
    static func lerp(_ p: Double, _ stops: [(Double, Double)], ease: (Double) -> Double = { $0 }) -> Double {
        guard let first = stops.first, let last = stops.last else { return 0 }
        if p <= first.0 { return first.1 }
        if p >= last.0 { return last.1 }
        for (a, b) in zip(stops, stops.dropFirst()) where p >= a.0 && p <= b.0 {
            let span = b.0 - a.0
            if span <= 0 { return b.1 }
            return a.1 + (b.1 - a.1) * ease((p - a.0) / span)
        }
        return last.1
    }

    /// A CSS cubic-bezier timing function.
    static func bezier(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> (Double) -> Double {
        { u in
            if u <= 0 { return 0 }
            if u >= 1 { return 1 }
            func x(_ t: Double) -> Double { 3 * (1 - t) * (1 - t) * t * x1 + 3 * (1 - t) * t * t * x2 + t * t * t }
            func y(_ t: Double) -> Double { 3 * (1 - t) * (1 - t) * t * y1 + 3 * (1 - t) * t * t * y2 + t * t * t }
            var lo = 0.0, hi = 1.0
            for _ in 0..<24 {
                let mid = (lo + hi) / 2
                if x(mid) < u { lo = mid } else { hi = mid }
            }
            return y((lo + hi) / 2)
        }
    }

    static let easeInOut = bezier(0.42, 0, 0.58, 1)
    static let easeOut = bezier(0, 0, 0.58, 1)
    /// cubic-bezier(0.3, 1.3, 0.5, 1): a slight overshoot.
    static let overshoot = bezier(0.3, 1.3, 0.5, 1)

    /// 0 → 1 → 0 over a period, eased in and out (CSS `0%,100%{a} 50%{b}` with ease-in-out).
    static func wave(_ t: Double, period: Double) -> Double {
        var f = (t / period).truncatingRemainder(dividingBy: 1)
        if f < 0 { f += 1 }
        return easeInOut(f < 0.5 ? f * 2 : (1 - f) * 2)
    }

    static func fraction(_ t: Double, period: Double) -> Double {
        var f = (t / period).truncatingRemainder(dividingBy: 1)
        if f < 0 { f += 1 }
        return f
    }
}

extension View {
    /// Places a view in reference coordinates inside a top-leading ZStack.
    func place(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        frame(width: w, height: h).offset(x: x, y: y)
    }
}

extension GraphicsContext {
    func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ color: Color) {
        fill(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r)), with: .color(color))
    }
    func line(_ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat, _ color: Color, width: CGFloat) {
        var p = Path()
        p.move(to: CGPoint(x: x0, y: y0))
        p.addLine(to: CGPoint(x: x1, y: y1))
        stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }
}
