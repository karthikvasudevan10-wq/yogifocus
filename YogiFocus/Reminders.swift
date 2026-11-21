import SwiftUI
import YogiKit

// v2 items 9 and 18: reminders that follow when the person usually begins, and grow lighter once the routine is theirs.

/// "You don't need my reminder any more." Shown once, the first time the reminders grow lighter (`V2-Nudges-Fade`).
struct FadeMomentScreen: View {
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onDone: () -> Void

    var body: some View {
        HeroLayout(background: YF.heroYellow, heroAspect: 300 / 262, heroMaxWidth: 280, rays: YF.raysOnYellow, raysCentre: 0.24) {
            EmptyView()
        } hero: {
            YogiView(.joyful, whiteDhoti: true)
                .levitate()
                .accessibilityHidden(true)
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                H1("You don't need my reminder any more.", size: 34).padding(.top, 10)
                Para("Most days lately, you began before I even asked. That is what a habit looks like. From now on I'll stay quieter, and the hour is yours.")
                    .padding(.top, 8)
            }
        } bottom: {
            PrimaryButton("Thank you", kind: .hero) {
                YogiStore.shared.updateRoutine(routineID) { $0.fadeAnnounced = true }
                model.refresh()
                onDone()
            }
            Button {
                YogiStore.shared.updateRoutine(routineID) { $0.fadeAnnounced = true; $0.keepEveryReminder = true }
                model.refresh()
                onDone()
            } label: {
                Text("Keep every reminder").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.onAccent)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
    }
}

/// "They follow you": shown in routine settings when the reminders have moved (`V2-Reminders`).
struct FollowCard: View {
    let routine: RoutineSnapshot
    let offset: Int

    var body: some View {
        let set = routine.hour * 60 + routine.minute
        let now = set + offset
        HStack(alignment: .top, spacing: 14) {
            YFIcon("clock", size: 26).foregroundStyle(YF.textGreen)
            VStack(alignment: .leading, spacing: 4) {
                Text("They follow you.").font(YFFont.heading(19, .semibold)).foregroundStyle(YF.ink)
                Text("You set \(routine.timeText) and tend to begin nearer \(Words.time(hour: now / 60, minute: now % 60, suffix: false)), so the reminders come then.")
                    .font(YFFont.body(14.5)).foregroundStyle(YF.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(YF.softGreen, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// A switch row with a title and a quiet line under it.
struct SettingSwitch: View {
    let title: String
    let detail: String?
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(YFFont.body(15.5, .medium))
                if let detail {
                    Text(detail).font(YFFont.body(13)).foregroundStyle(YF.muted).fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            YFSwitch(isOn: $isOn, label: title)
        }
        .padding(.leading, 18)
        .padding(.vertical, 10)
        .frame(minHeight: detail == nil ? 60 : 68)
    }
}
