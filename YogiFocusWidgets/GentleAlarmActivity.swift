import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI
import WidgetKit
import YogiKit

/// The gentle alarm on the Lock Screen and in the Dynamic Island (v2 item 22, `V2-Alarm`): the routine, its hour and
/// place, with Start and Later.
@available(iOS 26.0, *)
struct GentleAlarmActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<YogiAlarmMetadata>.self) { context in
            let m = context.attributes.metadata
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    YogiView(.calm, mat: true).frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yogi Focus · \(m?.time ?? "")").font(YFFont.fixedBody(13, .semibold)).foregroundStyle(YF.textGreen)
                        Text(m?.name ?? "Your practice").font(YFFont.fixedHeading(26)).foregroundStyle(YF.ink)
                        if let place = m?.place, !place.isEmpty {
                            Text(place).font(YFFont.fixedBody(14)).foregroundStyle(YF.muted)
                        }
                    }
                    Spacer(minLength: 0)
                }
                controls(context, dark: false)
            }
            .padding(16)
            .activityBackgroundTint(YF.ground)
        } dynamicIsland: { context in
            let m = context.attributes.metadata
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    YogiView(.calm).frame(width: 44, height: 44)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(m?.name ?? "Your practice").font(YFFont.fixedHeading(20)).foregroundStyle(.white)
                        Text([m?.time, m?.place].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · "))
                            .font(YFFont.fixedBody(13)).foregroundStyle(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    controls(context, dark: true)
                }
            } compactLeading: {
                Image(systemName: "leaf.fill").foregroundStyle(YF.leaf)
            } compactTrailing: {
                Text(m?.time ?? "").font(.caption2).foregroundStyle(YF.leaf)
            } minimal: {
                Image(systemName: "leaf.fill").foregroundStyle(YF.leaf)
            }
            .keylineTint(YF.leaf)
        }
    }

    /// Start and Later, while it rings.
    @ViewBuilder
    private func controls(_ context: ActivityViewContext<AlarmAttributes<YogiAlarmMetadata>>, dark: Bool) -> some View {
        if let routine = context.attributes.metadata?.routineID {
            let alarm = context.state.alarmID
            HStack(spacing: 10) {
                Button(intent: AlarmStartIntent(alarmID: alarm, routineID: routine)) {
                    Text("Start").font(YFFont.fixedBody(16, .semibold)).foregroundStyle(YF.onAccent)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(YF.leaf, in: Capsule())
                }
                .buttonStyle(.plain)
                if context.attributes.presentation.alert.secondaryButton != nil {
                    Button(intent: AlarmLaterIntent(alarmID: alarm, routineID: routine)) {
                        Text("Later").font(YFFont.fixedBody(16, .semibold)).foregroundStyle(dark ? .white : YF.ink)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(dark ? Color.white.opacity(0.16) : YF.line, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
