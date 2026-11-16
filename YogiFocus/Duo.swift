import SwiftUI
import YogiKit

// iPhone Duo layouts, from `handoff/docs/07-platforms.md` and `handoff/design/screens/Duo-*.html`.
//
// - Outer display (closed, compact width): the phone layouts, shortened. Back, Done and the routines list move into
//   a strip on the trailing edge, under the camera and status bar. The big content button stays at the bottom.
// - Inner display wide: two regions either side of the fold. Illustration or list on the leading side, words and
//   actions on the trailing side. Controls stay in the trailing strip.
// - Inner display tall (tabletop pose): standard horizontal bars. What to look at in the top region, what to tap
//   in the bottom region.
//
// Nothing here changes a regular iPhone: every screen keeps its phone layout when the pose is `.phone`.
// Apple does not publish the strip or fold widths; the design assumes 60 pt and 40 pt. The strip is never narrower
// than the system's own trailing inset (84 pt on the inner display in the Xcode 27.1 simulator).

enum DuoPose: Equatable, Sendable {
    case phone, outer, wide, tall
    var hasStrip: Bool { self == .outer || self == .wide }
}

extension EnvironmentValues {
    @Entry var duoPose: DuoPose = .phone
}

enum DuoDevice {
    /// True on an iPhone Duo (iPhone19,4), and in debug builds laid out with `YF_FRAME`.
    static let isDuo: Bool = {
        #if DEBUG
        if let f = ProcessInfo.processInfo.environment["YF_FRAME"], !f.isEmpty { return true }
        #endif
        let env = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
        return (env ?? machine()).hasPrefix("iPhone19,4")
    }()

    /// The pose for a window of this full size (including safe areas). Never anything but `.phone` off a Duo.
    static func pose(for size: CGSize) -> DuoPose {
        guard isDuo else { return .phone }
        if size.width >= 600 { return size.height > size.width ? .tall : .wide }
        return .outer
    }

    private static func machine() -> String {
        var u = utsname()
        uname(&u)
        return withUnsafeBytes(of: &u.machine) { raw in
            String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
        }
    }
}

enum DuoMetrics {
    static let strip: CGFloat = 60
    static let fold: CGFloat = 40
    /// Where the strip's buttons begin, measured from the top of the display: below the camera and status bar.
    static let stripItemsTop: CGFloat = 140
}

// MARK: - The trailing strip

struct DuoStripItem: Identifiable, Equatable {
    let id: String
    let order: Int
    let icon: String
    let label: String
    var tint: Color? = nil
    let action: () -> Void
    static func == (a: Self, b: Self) -> Bool { a.id == b.id && a.icon == b.icon && a.label == b.label && a.order == b.order }
}

extension DuoStripItem {
    static func back(_ action: @escaping () -> Void) -> Self { .init(id: "back", order: 0, icon: "chev-left", label: "Back", action: action) }
    static func done(_ action: @escaping () -> Void) -> Self { .init(id: "done", order: 1, icon: "check", label: "Done", tint: YF.textGreen, action: action) }
    static func routines(_ action: @escaping () -> Void) -> Self { .init(id: "routines", order: 1, icon: "plan", label: "Your routines", action: action) }
    static func edit(_ action: @escaping () -> Void) -> Self { .init(id: "edit", order: 1, icon: "settings", label: "Edit routine", action: action) }
}

struct DuoStripKey: PreferenceKey {
    static let defaultValue: [DuoStripItem] = []
    static func reduce(value: inout [DuoStripItem], nextValue: () -> [DuoStripItem]) { value += nextValue() }
}

extension View {
    /// Puts a button in the trailing strip on the Duo's outer display and wide inner display. Elsewhere it does nothing.
    /// Back is order 0; prominent actions such as Done come after it.
    func duoStripItem(_ id: String, order: Int, icon: String, label: String, tint: Color? = nil,
                      action: @escaping () -> Void) -> some View {
        transformPreference(DuoStripKey.self) {
            $0.append(DuoStripItem(id: id, order: order, icon: icon, label: label, tint: tint, action: action))
        }
    }
}

/// The strip: a faint band on the trailing edge, with the app's buttons below the system's camera and status bar.
struct DuoStrip: View {
    let items: [DuoStripItem]
    let geo: GeometryProxy
    var tint: Color = Color(hex: 0x14301F, opacity: 0.045)

    var body: some View {
        let width = max(geo.safeAreaInsets.trailing, DuoMetrics.strip)
        let x = geo.size.width + geo.safeAreaInsets.trailing - width
        ZStack(alignment: .top) {
            Rectangle().fill(tint)
            VStack(spacing: 8) {
                ForEach(items.sorted { $0.order < $1.order }) { item in
                    Button(action: item.action) {
                        YFIcon(item.icon, size: 22)
                            .foregroundStyle(item.tint ?? YF.ink)
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel(item.label)
                }
            }
            .padding(.top, max(8, DuoMetrics.stripItemsTop))
        }
        .frame(width: width, height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom)
        .offset(x: x, y: -geo.safeAreaInsets.top)
    }
}

// MARK: - Regions

/// The Duo's regions, in the local space of a GeometryReader that respects the safe area.
struct DuoRegions {
    let pose: DuoPose
    let size: CGSize
    let insets: EdgeInsets

    /// Content stops here on the trailing side, leaving room for the strip.
    var contentRight: CGFloat {
        guard pose.hasStrip else { return size.width }
        return min(size.width, size.width + insets.trailing - DuoMetrics.strip)
    }
    /// The centre of the fold, measured across the whole display.
    var foldX: CGFloat { (size.width + insets.leading + insets.trailing) / 2 - insets.leading }
    var foldY: CGFloat { (size.height + insets.top + insets.bottom) / 2 - insets.top }

    var leading: CGRect { CGRect(x: 0, y: 0, width: max(0, foldX - DuoMetrics.fold / 2), height: size.height) }
    var trailing: CGRect {
        let x = foldX + DuoMetrics.fold / 2
        return CGRect(x: x, y: 0, width: max(0, contentRight - x), height: size.height)
    }
    var top: CGRect { CGRect(x: 0, y: 0, width: size.width, height: max(0, foldY - DuoMetrics.fold / 2)) }
    var bottom: CGRect {
        let y = foldY + DuoMetrics.fold / 2
        return CGRect(x: 0, y: y, width: size.width, height: max(0, size.height - y))
    }
}

/// One region's content: centred (or top-aligned) when it fits, scrolling when it does not.
struct DuoRegion<Content: View>: View {
    var alignment: Alignment = .center
    var padding: EdgeInsets
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { g in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) { content() }
                    .padding(padding)
                    .frame(width: g.size.width, alignment: .leading)
                    .frame(minHeight: g.size.height, alignment: alignment)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

/// A region whose words scroll and whose button stays at the bottom.
struct DuoPinnedRegion<Content: View, Bottom: View>: View {
    var alignment: Alignment = .top
    var padding: EdgeInsets
    @ViewBuilder var content: () -> Content
    @ViewBuilder var bottom: () -> Bottom

    var body: some View {
        VStack(spacing: 0) {
            DuoRegion(alignment: alignment, padding: EdgeInsets(top: padding.top, leading: padding.leading, bottom: 12, trailing: padding.trailing),
                      content: content)
            VStack(spacing: 8) { bottom() }
                .padding(.leading, padding.leading)
                .padding(.trailing, padding.trailing)
                .padding(.bottom, padding.bottom)
        }
    }
}

// MARK: - Page

/// A whole Duo screen. `lead` is what to look at (illustration, list, lotus); `trail` is the words and actions;
/// `bottom` is the main button.
///
/// - outer: lead then trail, top-aligned, with the button pinned to the bottom of the content area.
/// - wide: lead in the leading region, trail and button in the trailing region.
/// - tall: lead in the top region (under the standard bar), trail and button in the bottom region.
struct DuoPage<Lead: View, Trail: View, Bottom: View>: View {
    @Environment(\.duoPose) private var pose
    var background: Color = YF.ground
    var stripTint: Color = Color(hex: 0x14301F, opacity: 0.045)
    /// Wide: how the lead and trail sit in their regions.
    var leadAlignment: Alignment = .center
    var trailAlignment: Alignment = .center
    /// Wide and tall: keep the button at the bottom of its region rather than with the words.
    var pinsBottom = false
    /// Buttons for the trailing strip that belong to the page itself (Back, Done, the routines list). Buttons can also
    /// come from inside the page with `duoStripItem`, as a TopBar's Back does.
    var strip: [DuoStripItem] = []
    /// Drawn behind everything, edge to edge (rays, confetti). Receives the regions.
    var underlay: ((DuoRegions) -> AnyView)? = nil
    /// The screen's bar (a TopBar or a title row). Tall: drawn across the top, above the top region. Outer and wide:
    /// not drawn, but its back button still goes to the strip.
    var bar: (() -> AnyView)? = nil
    @ViewBuilder var lead: () -> Lead
    @ViewBuilder var trail: () -> Trail
    @ViewBuilder var bottom: () -> Bottom

    @State private var items: [DuoStripItem] = []

    var body: some View {
        GeometryReader { geo in
            let r = DuoRegions(pose: pose, size: geo.size, insets: geo.safeAreaInsets)
            ZStack(alignment: .topLeading) {
                if let underlay { underlay(r) }
                if pose != .tall, let bar { bar().frame(height: 0).clipped() }
                switch pose {
                case .wide: wide(r)
                case .tall: tall(r, geo)
                default: outer(r, geo)
                }
                if pose.hasStrip { DuoStrip(items: merged, geo: geo, tint: stripTint) }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .background(background.ignoresSafeArea())
        .foregroundStyle(YF.ink)
        .toolbar(.hidden, for: .navigationBar)
        .onPreferenceChange(DuoStripKey.self) { items = $0 }
    }

    /// The page's own buttons, then any from inside it that are not already there.
    private var merged: [DuoStripItem] {
        var out = strip
        for i in items where !out.contains(where: { $0.id == i.id }) { out.append(i) }
        return out
    }

    private func outer(_ r: DuoRegions, _ geo: GeometryProxy) -> some View {
        let top = max(18, 24 - geo.safeAreaInsets.top)
        let bottomPad = max(8, 22 - geo.safeAreaInsets.bottom)
        return DuoPinnedRegion(alignment: .top, padding: EdgeInsets(top: top, leading: 24, bottom: bottomPad, trailing: 22)) {
            lead()
            trail()
        } bottom: {
            bottom()
        }
        .frame(width: r.contentRight, height: geo.size.height)
    }

    private func wide(_ r: DuoRegions) -> some View {
        let leadPad = EdgeInsets(top: 28, leading: 32, bottom: 28, trailing: 32)
        let trailPad = EdgeInsets(top: 28, leading: 32, bottom: 28, trailing: 28)
        return ZStack(alignment: .topLeading) {
            DuoRegion(alignment: leadAlignment, padding: leadPad, content: lead)
                .frame(width: r.leading.width, height: r.leading.height)
            Group {
                if pinsBottom {
                    DuoPinnedRegion(alignment: trailAlignment, padding: trailPad, content: trail, bottom: bottom)
                } else {
                    DuoRegion(alignment: trailAlignment, padding: trailPad) {
                        trail()
                        VStack(spacing: 8) { bottom() }.padding(.top, 28)
                    }
                }
            }
            .frame(width: r.trailing.width, height: r.trailing.height)
            .offset(x: r.trailing.minX)
        }
    }

    private func tall(_ r: DuoRegions, _ geo: GeometryProxy) -> some View {
        let barH: CGFloat = bar == nil ? max(0, 24 - geo.safeAreaInsets.top) : 44
        return ZStack(alignment: .topLeading) {
            if let bar {
                bar().padding(.horizontal, 28).frame(width: r.top.width, height: 44, alignment: .bottom)
            }
            DuoRegion(alignment: leadAlignment, padding: EdgeInsets(top: 2, leading: 40, bottom: 6, trailing: 40), content: lead)
                .frame(width: r.top.width, height: max(0, r.top.height - barH))
                .offset(y: barH)
            DuoPinnedRegion(alignment: .top, padding: EdgeInsets(top: 24, leading: 40, bottom: max(16, 40 - geo.safeAreaInsets.bottom), trailing: 40),
                            content: trail, bottom: bottom)
                .frame(width: r.bottom.width, height: r.bottom.height)
                .offset(y: r.bottom.minY)
        }
    }
}

extension DuoPage where Bottom == EmptyView {
    init(background: Color = YF.ground, stripTint: Color = Color(hex: 0x14301F, opacity: 0.045),
         leadAlignment: Alignment = .center, trailAlignment: Alignment = .center, pinsBottom: Bool = false,
         strip: [DuoStripItem] = [], underlay: ((DuoRegions) -> AnyView)? = nil, bar: (() -> AnyView)? = nil,
         @ViewBuilder lead: @escaping () -> Lead, @ViewBuilder trail: @escaping () -> Trail) {
        self.init(background: background, stripTint: stripTint, leadAlignment: leadAlignment, trailAlignment: trailAlignment,
                  pinsBottom: pinsBottom, strip: strip, underlay: underlay, bar: bar, lead: lead, trail: trail, bottom: { EmptyView() })
    }
}

/// Reads the window's full size once, at the root, and tells every screen which Duo pose it is in.
struct DuoPoseReader<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        GeometryReader { geo in
            let full = CGSize(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                              height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom)
            content().environment(\.duoPose, DuoDevice.pose(for: full))
        }
    }
}

/// On the Duo the app follows the device into every orientation (the inner display can be held wide or tall).
/// Every other iPhone stays in portrait, as designed.
enum DuoOrientation {
    static var supported: UIInterfaceOrientationMask { DuoDevice.isDuo ? .all : .portrait }
}
