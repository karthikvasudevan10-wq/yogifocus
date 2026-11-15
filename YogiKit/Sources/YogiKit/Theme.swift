import SwiftUI
import CoreText
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Colour

public extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}
#endif

/// A colour that follows the system appearance. Apple Watch has one appearance (dark).
func dyn(_ light: UInt32, _ dark: UInt32) -> Color {
    #if os(watchOS)
    return Color(hex: dark)
    #else
    return Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
    #endif
}

/// Design tokens. See `design/tokens.json` and `docs/05-design-system.md` in the handoff.
public enum YF {
    // Vibrant colours: the same in both appearances.
    public static let leaf = Color(hex: 0x6FD43A)
    public static let mid = Color(hex: 0x3DBB45)
    public static let deepLeaf = Color(hex: 0x17933F)
    public static let sunny = Color(hex: 0xFFD21F)
    public static let daySky = Color(hex: 0xFFF3B0)
    public static let saffron = Color(hex: 0xFF7A1A)
    /// Text on bright green or bright yellow.
    public static let onAccent = Color(hex: 0x14301F)
    public static let missed = Color(hex: 0xE0453F)
    public static let white = Color.white
    public static let pink = Color(hex: 0xFF8FB1)
    public static let hair = Color(hex: 0x4A3229)
    public static let switchOff = Color(hex: 0xB8C4B4)

    // Roles: these change with the appearance.
    public static let ink = dyn(0x14301F, 0xEEF5E8)
    public static let muted = dyn(0x4F6355, 0xA9B8A5)
    public static let textGreen = dyn(0x127A35, 0x8AE264)
    public static let softGreen = dyn(0xE6F8D2, 0x1C3A21)
    public static let softYellow = dyn(0xFFF3B0, 0x3A3512)
    public static let ground = dyn(0xFFFEF8, 0x0E1A11)
    public static let line = dyn(0xE2EBD6, 0x2C3D2E)
    public static let paper = dyn(0xFFFFFF, 0x18271B)
    public static let heroYellow = dyn(0xFFD21F, 0x111F10)
    public static let heroGreen = dyn(0x6FD43A, 0x0F2212)
    public static let petalClosed = dyn(0xEEF4E6, 0x233327)
    public static let petalEdge = dyn(0xD9E4CC, 0x34483A)
    public static let petalSep = dyn(0xFFFFFF, 0x0E1A11)
    /// Text on a full-colour (hero) screen: Ink in the light, light ink in the dark.
    public static let heroButtonFill = dyn(0x14301F, 0x6FD43A)
    public static let heroButtonText = dyn(0xFFFFFF, 0x14301F)
    public static let raysOnYellow = dyn(0xFFDF52, 0x182B17)
    public static let raysOnGreen = dyn(0x7EDC49, 0x173019)
    public static let welcomeRipple = dyn(0xFFFFFF, 0x5B6B2A)
    public static let heroShadow = dyn(0x7A5B00, 0x000000)
    public static let graphMiddle = dyn(0xD6F2BC, 0x24402A)

    // Apple Watch.
    public static let watchSecondary = Color(hex: 0xC2CDBE)
    public static let watchRaised = Color(hex: 0x1F2A1F)
    public static let watchLotus = [Color(hex: 0x1F5129), Color(hex: 0x184220), Color(hex: 0x12331A)]

    // Layout.
    public static let margin: CGFloat = 28
    public static let referenceWidth: CGFloat = 390
    public static let maxColumn: CGFloat = 430
}

// MARK: - Type

public enum YFFont {
    private static var registered = false
    private static var balooName: String?
    private static var interName: String?

    /// Registers any font files bundled in YogiKit (Baloo 2 is required by the design; Inter is optional).
    public static func register() {
        guard !registered else { return }
        registered = true
        let urls = (Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [])
            + (Bundle.module.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? [])
        for url in urls { CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) }
        #if canImport(UIKit)
        if UIFont.familyNames.contains("Baloo 2") { balooName = "Baloo 2" }
        if UIFont.familyNames.contains("Inter") { interName = "Inter" }
        #endif
    }

    /// Headings and the name: Baloo 2, weights 600 and 700. Falls back to the rounded system face.
    public static func heading(_ size: CGFloat, _ weight: Font.Weight = .bold, relativeTo style: Font.TextStyle = .title) -> Font {
        register()
        if let balooName {
            return Font.custom(balooName, size: size, relativeTo: style).weight(weight)
        }
        return .system(size: scaled(size, style), weight: weight, design: .rounded)
    }

    /// Body: Inter when bundled, otherwise the system font.
    public static func body(_ size: CGFloat = 17, _ weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        register()
        if let interName {
            return Font.custom(interName, size: size, relativeTo: style).weight(weight)
        }
        return .system(size: scaled(size, style), weight: weight)
    }

    /// A fixed size that ignores Dynamic Type: for text drawn inside illustrations and widgets.
    public static func fixedHeading(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        register()
        if let balooName { return Font.custom(balooName, fixedSize: size).weight(weight) }
        return .system(size: size, weight: weight, design: .rounded)
    }

    public static func fixedBody(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        register()
        if let interName { return Font.custom(interName, fixedSize: size).weight(weight) }
        return .system(size: size, weight: weight)
    }

    private static func scaled(_ size: CGFloat, _ style: Font.TextStyle) -> CGFloat {
        #if canImport(UIKit)
        let ui: UIFont.TextStyle = style == .title ? .title1 : .body
        // Cap growth so fixed layouts stay usable at the largest accessibility sizes.
        return min(UIFontMetrics(forTextStyle: ui).scaledValue(for: size), size * 1.6)
        #else
        return size
        #endif
    }
}

// MARK: - Motion helpers

/// Continuous rotation as a layer transform. Still when Reduce Motion is on.
public struct Spin: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false
    let period: Double
    let reverse: Bool
    public init(period: Double, reverse: Bool = false) { self.period = period; self.reverse = reverse }
    public func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(on ? (reverse ? -360 : 360) : 0))
            .animation(reduceMotion ? nil : .linear(duration: period).repeatForever(autoreverses: false), value: on)
            .onAppear { if !reduceMotion { on = true } }
    }
}

/// The yogi's float: rises and sinks about 13 pt (at a 200 pt drawing), 4.5 s, ease in-out.
public struct Levitate: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false
    /// Travel as a fraction of the drawing: +4 to −9 units of a 200-unit box by default.
    let low: CGFloat, high: CGFloat, period: Double
    public init(low: CGFloat = 4, high: CGFloat = -9, period: Double = 4.5) { self.low = low; self.high = high; self.period = period }
    public func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (up ? high : low))
            .animation(reduceMotion ? nil : .easeInOut(duration: period / 2).repeatForever(autoreverses: true), value: up)
            .onAppear { if !reduceMotion { up = true } }
    }
}

/// The soft shadow under the floating yogi: shrinks to about three quarters and fades as he lifts.
public struct FloatShadow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false
    let color: Color
    let base: Double
    public init(color: Color = Color(hex: 0x0B3D1A), base: Double = 0.26) { self.color = color; self.base = base }
    public var body: some View {
        Ellipse().fill(color)
            .opacity(up ? base * 0.54 : base)
            .scaleEffect(up ? 0.74 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 2.25).repeatForever(autoreverses: true), value: up)
            .onAppear { if !reduceMotion { up = true } }
    }
}

public extension View {
    func spin(period: Double, reverse: Bool = false) -> some View { modifier(Spin(period: period, reverse: reverse)) }
    func levitate(low: CGFloat = 4, high: CGFloat = -9, period: Double = 4.5) -> some View { modifier(Levitate(low: low, high: high, period: period)) }
}

// MARK: - Line height

/// Baloo 2's own line height is about 1.6 × its size; the design sets headings at 1.1 (CSS `line-height`).
/// SwiftUI can set an exact line height from iOS 26 and watchOS 26. Earlier systems keep the font's own spacing.
public struct DesignLineHeight: ViewModifier {
    let size: CGFloat
    let factor: CGFloat
    let scales: Bool
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, watchOS 26.0, *) {
            content.lineHeight(.exact(points: points))
        } else {
            content
        }
    }
    private var points: CGFloat {
        #if canImport(UIKit) && !os(watchOS)
        if scales { return min(UIFontMetrics(forTextStyle: .title1).scaledValue(for: size), size * 1.6) * factor }
        #endif
        return size * factor
    }
}

public extension View {
    /// Sets lines `factor` × `size` apart. `scales`: the text follows Dynamic Type (YFFont.heading/body).
    func designLineHeight(_ size: CGFloat, _ factor: CGFloat = 1.1, scales: Bool = true) -> some View {
        modifier(DesignLineHeight(size: size, factor: factor, scales: scales))
    }
}
