import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit
import YogiKit

/// The practice on the Lock Screen and in the Dynamic Island (v2 item 4, `V2-Live-Activity`).
/// Before: "In 12 minutes", I'm starting and Two minutes. During: the ring, time left, Done. After: kept, for a moment.
/// The countdowns are drawn by the system from dates, so nothing needs to update them.
struct PracticeActivity: Widget {
    /// The deep green of the Lock Screen card in the design.
    static let card = Color(hex: 0x15381F)
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PracticeActivityAttributes.self) { context in
            LockScreenPractice(context: context)
                .padding(16)
                .activityBackgroundTint(Self.card)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let s = context.state
            let a = context.attributes
            let after = s.phase == .after || context.isStale
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    if after {
                        YogiView(.joyful).frame(width: 44, height: 44)
                    } else if s.phase == .during {
                        Ring(state: s, size: 46, line: 6)
                    } else {
                        LotusView(petals: .allOpen, style: .decoration([YF.deepLeaf, YF.mid, YF.leaf], on: .black, centre: YF.sunny))
                            .frame(width: 40, height: 40)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 0) {
                        if after {
                            Text("That's today, kept.").font(YFFont.fixedHeading(20)).foregroundStyle(YF.sunny)
                            Text(s.petals.map { "\(Words.petalsOpen($0)). Tomorrow, one more." } ?? "Only tomorrow is next.")
                                .font(YFFont.fixedBody(13)).foregroundStyle(.white)
                        } else if s.phase == .during {
                            Text("\(a.name) · \(a.place)").font(YFFont.fixedBody(12.5, .semibold)).foregroundStyle(YF.sunny)
                            (Text(timerInterval: s.start...s.end, countsDown: true) + Text(" left"))
                                .font(YFFont.fixedHeading(24)).foregroundStyle(.white).monospacedDigit()
                        } else {
                            (Text("In ") + Text(timerInterval: s.start...s.end, countsDown: true))
                                .font(YFFont.fixedBody(12.5, .semibold)).foregroundStyle(YF.sunny)
                            Text(a.name).font(YFFont.fixedHeading(22)).foregroundStyle(.white)
                            Text([a.place, a.things].filter { !$0.isEmpty }.joined(separator: " · "))
                                .font(YFFont.fixedBody(12.5)).foregroundStyle(.white.opacity(0.8)).lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !after && s.phase == .during {
                        Button(intent: PracticeDoneIntent(routineID: a.routineID)) {
                            Text("Done").font(YFFont.fixedBody(15, .semibold)).foregroundStyle(YF.onAccent)
                                .padding(.horizontal, 16).frame(height: 36)
                                .background(YF.leaf, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .fixedSize()
                        .frame(maxHeight: .infinity)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if !after && s.phase == .before {
                        Buttons(context: context, dark: true).padding(.horizontal, 6)
                    }
                }
            } compactLeading: {
                if after {
                    Image(systemName: "checkmark").foregroundStyle(YF.leaf)
                } else if s.phase == .during {
                    Ring(state: s, size: 18, line: 3)
                } else {
                    LotusView(petals: .allOpen, style: .decoration([YF.deepLeaf, YF.mid, YF.leaf], on: .black, centre: YF.sunny))
                        .frame(width: 20, height: 20)
                }
            } compactTrailing: {
                if after {
                    Text("Kept").font(.caption.weight(.semibold)).foregroundStyle(YF.leaf)
                } else {
                    Text(timerInterval: s.start...s.end, countsDown: true)
                        .font(.caption.weight(.semibold)).monospacedDigit().foregroundStyle(YF.leaf)
                        .frame(maxWidth: 52)
                }
            } minimal: {
                if after { Image(systemName: "checkmark").foregroundStyle(YF.leaf) } else { Ring(state: s, size: 18, line: 3) }
            }
            .keylineTint(YF.leaf)
        }
    }
}

/// The ring, filling over the routine's length.
private struct Ring: View {
    let state: PracticeActivityAttributes.ContentState
    let size: CGFloat
    let line: CGFloat
    var body: some View {
        ProgressView(timerInterval: state.start...state.end, countsDown: false) { EmptyView() } currentValueLabel: { EmptyView() }
            .progressViewStyle(.circular)
            .tint(YF.leaf)
            .frame(width: size, height: size)
    }
}

/// I'm starting and Two minutes before the hour; Done during.
private struct Buttons: View {
    let context: ActivityViewContext<PracticeActivityAttributes>
    let dark: Bool
    var body: some View {
        let id = context.attributes.routineID
        HStack(spacing: 10) {
            if context.state.phase == .before {
                Button(intent: PracticeStartIntent(routineID: id, twoMinute: false)) { pill("I'm starting", main: true) }
                    .buttonStyle(.plain)
                if context.attributes.hasTwoMinute {
                    Button(intent: PracticeStartIntent(routineID: id, twoMinute: true)) { pill("Two minutes", main: false) }
                        .buttonStyle(.plain)
                }
            } else {
                Button(intent: PracticeDoneIntent(routineID: id)) { pill("Done", main: true) }
                    .buttonStyle(.plain)
                Spacer(minLength: 0)
            }
        }
    }
    private func pill(_ text: String, main: Bool) -> some View {
        Text(text).font(YFFont.fixedBody(15, .semibold))
            .foregroundStyle(main ? YF.onAccent : .white)
            .padding(.horizontal, 18).frame(height: 36)
            .background(main ? YF.leaf : Color.white.opacity(0.16), in: Capsule())
    }
}

/// The Lock Screen banner.
private struct LockScreenPractice: View {
    let context: ActivityViewContext<PracticeActivityAttributes>
    var body: some View {
        let s = context.state
        let a = context.attributes
        if s.phase == .after || context.isStale {
            HStack(spacing: 14) {
                if let n = s.petals {
                    LotusView(petals: .sample(opened: n), style: LotusStyle(separator: PracticeActivity.card)).frame(width: 56, height: 56)
                } else {
                    YogiView(.joyful).frame(width: 56, height: 56)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.petals == nil ? "That's today, kept." : "After day 30").font(YFFont.fixedBody(13, .semibold)).foregroundStyle(YF.sunny)
                    Text(s.petals.map { Words.petalsOpen($0) } ?? "Only tomorrow is next.")
                        .font(YFFont.fixedHeading(22)).foregroundStyle(.white)
                    if s.petals != nil { Text("Tomorrow, one more").font(YFFont.fixedBody(13)).foregroundStyle(.white.opacity(0.8)) }
                }
                Spacer(minLength: 0)
            }
        } else {
            HStack(spacing: 14) {
                if s.phase == .during {
                    Ring(state: s, size: 56, line: 7)
                } else {
                    LotusView(petals: .allOpen, style: .decoration([YF.deepLeaf, YF.mid, YF.leaf], on: PracticeActivity.card, centre: YF.sunny))
                        .frame(width: 52, height: 52)
                }
                VStack(alignment: .leading, spacing: 2) {
                    if s.phase == .during {
                        Text("\(a.name) · \(a.place)").font(YFFont.fixedBody(13, .semibold)).foregroundStyle(YF.sunny)
                        (Text(timerInterval: s.start...s.end, countsDown: true) + Text(" left"))
                            .font(YFFont.fixedHeading(26)).foregroundStyle(.white).monospacedDigit()
                        Text("Chime at \(s.end.formatted(date: .omitted, time: .shortened))")
                            .font(YFFont.fixedBody(13)).foregroundStyle(.white.opacity(0.8))
                    } else {
                        (Text("In ") + Text(timerInterval: s.start...s.end, countsDown: true))
                            .font(YFFont.fixedBody(13, .semibold)).foregroundStyle(YF.sunny)
                        Text(a.name).font(YFFont.fixedHeading(24)).foregroundStyle(.white)
                        Text([a.place, a.things].filter { !$0.isEmpty }.joined(separator: " · "))
                            .font(YFFont.fixedBody(13)).foregroundStyle(.white.opacity(0.8)).lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                if s.phase == .during {
                    Button(intent: PracticeDoneIntent(routineID: a.routineID)) {
                        Text("Done").font(YFFont.fixedBody(15, .semibold)).foregroundStyle(YF.onAccent)
                            .padding(.horizontal, 18).frame(minHeight: 40)
                            .background(YF.leaf, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
