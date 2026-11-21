import SwiftUI

public enum YogiWidgetSize: Sendable {
    case small, medium, large
    /// The size each was drawn at.
    public var reference: CGSize {
        switch self {
        case .small: return CGSize(width: 170, height: 170)
        case .medium: return CGSize(width: 364, height: 170)
        case .large: return CGSize(width: 364, height: 382)
        }
    }
    public var cornerRadius: CGFloat { self == .large ? 28 : 24 }
}

public extension WidgetModel.Tone {
    var background: Color {
        switch self {
        case .paper: return YF.paper
        case .softYellow: return YF.softYellow
        case .sunny: return YF.sunny
        case .softGreen: return YF.softGreen
        }
    }
    /// The decorative lotus: every petal one tone, a shade off the widget's own background.
    var lotusTones: [Color] {
        switch self {
        case .paper: return [dyn(0xDDF3C3, 0x24402A), dyn(0xE7F7D3, 0x203825), dyn(0xEFFAE2, 0x1C3020)]
        case .softYellow: return [dyn(0xFFE266, 0x4D461A), dyn(0xFFE87C, 0x454017), dyn(0xFFED94, 0x3F3A14)]
        case .sunny: return [Color(hex: 0xFFE780), Color(hex: 0xFFE066), Color(hex: 0xFFDA47)]
        case .softGreen: return [dyn(0xC6ECA2, 0x2A5231), dyn(0xD0F0B1, 0x25492C), dyn(0xDAF3C1, 0x204126)]
        }
    }
    var text: Color { self == .sunny ? YF.onAccent : YF.ink }
    var label: Color { self == .sunny ? YF.onAccent : YF.textGreen }
    var secondary: Color { self == .sunny ? YF.onAccent : YF.muted }
}

/// The lotus opening once when Done is tapped: scale up from about half size with a short turn.
struct LotusOpen: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.5 : 1)
            .rotationEffect(.degrees(active ? -40 : 0))
            .opacity(active ? 0 : 1)
    }
}

/// The widget's ground: the state colour with the decorative lotus half-shown, cut off by the right edge.
public struct YogiWidgetBackground: View {
    let model: WidgetModel
    let size: YogiWidgetSize
    public init(model: WidgetModel, size: YogiWidgetSize) { self.model = model; self.size = size }

    public var body: some View {
        GeometryReader { geo in
            let u = geo.size.width / size.reference.width
            ZStack(alignment: .topLeading) {
                model.tone.background
                if model.progress == nil || size == .small {
                    let (d, top): (CGFloat, CGFloat) = {
                        switch size {
                        case .small: return (172, 30)
                        case .medium: return (236, -33)
                        case .large: return (372, 26)
                        }
                    }()
                    LotusView(style: .decoration(model.tone.lotusTones, on: model.tone.background, centre: model.tone.lotusTones[0]))
                        .frame(width: d * u, height: d * u)
                        .offset(x: geo.size.width - d * u / 2, y: top * u)
                        .id(model.tone)
                        .transition(.modifier(active: LotusOpen(active: true), identity: LotusOpen(active: false)))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .animation(.spring(duration: 0.9, bounce: 0.25), value: model.tone)
        }
        .accessibilityHidden(true)
    }
}

/// The two answers a widget can give at the hour.
public enum WidgetAnswer: Sendable { case done, notToday, twoMinutes }

/// The widget's content. `answer` makes the Done and Not today buttons tappable, supplied by the widget so it can run App Intents.
public struct YogiWidgetContent<Done: View>: View {
    let model: WidgetModel
    let size: YogiWidgetSize
    let answer: (WidgetAnswer, AnyView) -> Done

    /// - answer: wraps a button label in whatever makes it tappable (a `Button(intent:)` on a widget).
    public init(model: WidgetModel, size: YogiWidgetSize, @ViewBuilder answer: @escaping (WidgetAnswer, AnyView) -> Done) {
        self.model = model; self.size = size; self.answer = answer
    }

    public var body: some View {
        GeometryReader { geo in
            let u = geo.size.width / size.reference.width
            ZStack(alignment: .topLeading) {
                art(u: u, width: geo.size.width)
                text(u: u)
                    .frame(width: (size == .medium ? 236 : size.reference.width) * u, height: geo.size.height, alignment: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .foregroundStyle(model.tone.text)
        .animation(.spring(duration: 0.9, bounce: 0.25), value: model.state)
    }

    // The yogi in front of the lotus, or, after day 30 once kept, the real lotus with its count.
    @ViewBuilder private func art(u: CGFloat, width: CGFloat) -> some View {
        if size != .small {
            if let n = model.progress, let petals = model.petals {
                let (d, right, top): (CGFloat, CGFloat, CGFloat) = size == .medium ? (126, 16, 22) : (150, 18, 20)
                LotusProgressView(petals: petals, count: n, style: LotusStyle(separator: model.tone.background))
                    .frame(width: d * u, height: d * u)
                    .offset(x: width - (d + right) * u, y: top * u)
            } else if model.state != .empty {
                let (d, right, top): (CGFloat, CGFloat, CGFloat) = size == .medium ? (112, 10, 32) : (124, 12, 58)
                YogiView(model.joyful ? .joyful : .calm, whiteDhoti: model.tone == .sunny, mat: true)
                    .frame(width: d * u, height: d * u)
                    .offset(x: width - (d + right) * u, y: top * u)
                    .id(model.joyful)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder private func text(u: CGFloat) -> some View {
        switch size {
        case .small: small(u)
        case .medium: medium(u)
        case .large: large(u)
        }
    }

    private func labelRow(_ u: CGFloat, font: CGFloat, dot: CGFloat, check: CGFloat, gap: CGFloat) -> some View {
        HStack(spacing: gap * u) {
            if model.dot {
                Circle().fill(YF.saffron).frame(width: dot * u, height: dot * u)
            }
            if model.check {
                YFIcon("check", size: check * u)
                    .transition(.scale(scale: 0.01).animation(.spring(duration: 0.45, bounce: 0.5)))
            }
            Text(model.label).font(YFFont.fixedBody(font * u, .semibold))
        }
        .foregroundStyle(model.tone.label)
    }

    private func doneButton(_ u: CGFloat, height: CGFloat, font: CGFloat) -> some View {
        answer(.done, AnyView(
            Text("Done")
                .font(YFFont.fixedBody(font * u, .semibold))
                .foregroundStyle(YF.onAccent)
                .frame(maxWidth: .infinity, minHeight: height * u)
                .background(YF.leaf, in: Capsule())
        ))
    }

    /// Outlined, in the card's own text colour: a quiet second answer, never red.
    private func notTodayButton(_ u: CGFloat, height: CGFloat, font: CGFloat) -> some View {
        answer(.notToday, AnyView(
            Text("Not today")
                .font(YFFont.fixedBody(font * u, .semibold))
                .foregroundStyle(model.tone.text)
                .frame(maxWidth: .infinity, minHeight: height * u)
                .overlay(Capsule().strokeBorder(model.tone.text.opacity(0.45), lineWidth: 1.2 * u))
        ))
    }

    private func twoMinutesButton(_ u: CGFloat, height: CGFloat, font: CGFloat) -> some View {
        answer(.twoMinutes, AnyView(
            Text("Two minutes")
                .font(YFFont.fixedBody(font * u, .semibold))
                .foregroundStyle(model.tone.text)
                .frame(maxWidth: .infinity, minHeight: height * u)
                .overlay(Capsule().strokeBorder(model.tone.text.opacity(0.45), lineWidth: 1.2 * u))
        ))
    }

    private func notTodayLink(_ u: CGFloat) -> some View {
        answer(.notToday, AnyView(
            Text("Not today")
                .font(YFFont.fixedBody(14 * u, .semibold)).underline()
                .foregroundStyle(model.tone.text)
                .frame(maxWidth: .infinity, minHeight: 30 * u)
        ))
    }

    private func small(_ u: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            labelRow(u, font: 12.5, dot: 8, check: 15, gap: 6)
            Text(model.name).font(YFFont.fixedHeading(25 * u)).lineLimit(1).minimumScaleFactor(0.6).padding(.top, 2 * u)
            Text(model.small1).font(YFFont.fixedBody(14 * u, .medium)).fixedSize(horizontal: false, vertical: true)
                .id(model.small1).transition(.opacity)
            if !model.small2.isEmpty {
                Text(model.small2).font(YFFont.fixedBody(13 * u)).foregroundStyle(model.tone.secondary)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 1 * u)
            }
            Spacer(minLength: 0)
            if model.showsDone { doneButton(u, height: 44, font: 14) }
        }
        .padding(16 * u)
    }

    private func medium(_ u: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            labelRow(u, font: 12.5, dot: 8, check: 15, gap: 6)
            Text(model.name).font(YFFont.fixedHeading(28 * u)).lineLimit(1).minimumScaleFactor(0.6)
            Text(model.mediumLine).font(YFFont.fixedHeading(16 * u, .semibold)).designLineHeight(16 * u, 1.25, scales: false).fixedSize(horizontal: false, vertical: true)
                .id(model.mediumLine).transition(.opacity)
            Spacer(minLength: 0)
            if model.showsDone {
                HStack(spacing: 8 * u) {
                    doneButton(u, height: 44, font: 14)
                    if model.showsNotToday { notTodayButton(u, height: 44, font: 14) }
                }
            } else {
                VStack(alignment: .leading, spacing: 1 * u) {
                    ForEach(model.mediumFoot, id: \.self) { Text($0).lineLimit(1).minimumScaleFactor(0.8) }
                }
                .font(YFFont.fixedBody(13 * u))
                .foregroundStyle(model.tone.secondary)
            }
        }
        .padding(.vertical, 16 * u)
        .padding(.leading, 18 * u)
    }

    private func large(_ u: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            labelRow(u, font: 13.5, dot: 9, check: 17, gap: 7)
            Text(model.name).font(YFFont.fixedHeading(36 * u)).lineLimit(1).minimumScaleFactor(0.6).padding(.top, 2 * u)
            if model.routineID != nil {
                VStack(alignment: .leading, spacing: 0) {
                    row("clock", model.whenRow, u)
                    row("pin", model.whereRow, u)
                    if !model.thingsRow.isEmpty { row("bag", model.thingsRow, u) }
                }
                .padding(.top, 8 * u)
                .padding(.trailing, 130 * u)
            }
            Text(model.largeLine).font(YFFont.fixedHeading(21 * u, .semibold)).designLineHeight(21 * u, 1.25, scales: false).fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20 * u)
                .id(model.largeLine).transition(.opacity)
            Spacer(minLength: 0)
            if model.showsDone {
                HStack(spacing: 10 * u) {
                    doneButton(u, height: 48, font: 15)
                    if model.showsTwoMinutes { twoMinutesButton(u, height: 48, font: 15) }
                }
                if model.showsNotToday { notTodayLink(u).padding(.top, 6 * u) }
            } else if !model.largeFoot.isEmpty {
                Text(model.largeFoot).font(YFFont.fixedBody(14 * u, .medium)).foregroundStyle(model.tone.secondary)
            }
        }
        .padding(20 * u)
    }

    private func row(_ icon: String, _ text: String, _ u: CGFloat) -> some View {
        HStack(spacing: 10 * u) {
            YFIcon(icon, size: 18 * u).foregroundStyle(model.tone.label)
            Text(text).font(YFFont.fixedBody(15 * u, .medium)).lineLimit(1).minimumScaleFactor(0.75)
        }
        .frame(minHeight: 26 * u)
    }
}

/// The whole widget as a card, for showing inside the app (the "Add the widget" screen).
public struct YogiWidgetCard: View {
    let model: WidgetModel
    let size: YogiWidgetSize
    public init(model: WidgetModel, size: YogiWidgetSize) { self.model = model; self.size = size }
    public var body: some View {
        ZStack {
            YogiWidgetBackground(model: model, size: size)
            YogiWidgetContent(model: model, size: size) { _, label in label }
        }
        .aspectRatio(size.reference.width / size.reference.height, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
