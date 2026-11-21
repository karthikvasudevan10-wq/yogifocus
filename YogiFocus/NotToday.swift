import SwiftUI
import YogiKit

// v2 item 2: "Not today" as an answer. It closes the day early and stops the rest of today's nudges.
// No blame (design rule 5), and nothing about it is shown before day 30 (design rule 4).

/// A quiet second answer beside the main button: paper, a thin line, never red.
struct QuietButton: View {
    let title: String
    let action: () -> Void
    init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(YFFont.body(16, .semibold))
                .foregroundStyle(YF.ink)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(YF.paper, in: Capsule())
                .overlay(Capsule().strokeBorder(YF.line, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
    }
}

enum NotToday {
    /// Records the answer and withdraws today's remaining nudges.
    @MainActor static func answer(_ id: UUID, model: AppModel) {
        YogiStore.shared.markNotToday(id)
        Nudges.cancelToday(id)
        model.refresh()
    }
}

/// The reply after "Not today" (`V2-Not-Today`).
struct NotTodayScreen: View {
    @Environment(AppModel.self) private var model
    @Environment(\.duoPose) private var pose
    let routineID: UUID
    let onDone: () -> Void

    var body: some View {
        if let r = model.routine(routineID) {
            if pose == .phone { phoneBody(r) } else { duoBody(r) }
        } else {
            Color.clear
        }
    }

    private var art: some View {
        ZStack {
            LotusView(petals: .allOpen, style: .decoration([YF.softGreen, YF.softGreen, YF.softGreen], on: YF.ground))
                .opacity(0.7)
            YogiView(.calm, mat: true)
                .padding(34)
        }
        .frame(width: 240, height: 240)
        .accessibilityHidden(true)
    }

    private func tomorrowCard(_ r: RoutineSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Tomorrow").font(YFFont.body(14, .semibold))
            Text("\(r.timeText), \(r.placeInSentence)").font(YFFont.heading(26)).fixedSize(horizontal: false, vertical: true)
            if !r.things.isEmpty { Text(r.thingsList).font(YFFont.body(15, .medium)) }
        }
        .foregroundStyle(YF.onAccent)
        .padding(.horizontal, 20).padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(YF.sunny, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func words(_ r: RoutineSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            H1("That's all right.", size: 40)
            Text("Tomorrow is a new day.").font(YFFont.heading(20, .semibold)).foregroundStyle(YF.ink).padding(.top, 6)
            tomorrowCard(r).padding(.top, 22)
            Para("No more reminders today.", size: 15, color: YF.muted).padding(.top, 14)
        }
    }

    private func phoneBody(_ r: RoutineSnapshot) -> some View {
        Screen {
            Spacer().frame(height: 30)
            art.frame(maxWidth: .infinity)
            words(r).padding(.top, 18)
        } bottom: {
            PrimaryButton("Done", action: onDone)
        }
    }

    private func duoBody(_ r: RoutineSnapshot) -> some View {
        DuoPage(strip: [.done(onDone)]) {
            art.frame(maxWidth: .infinity)
        } trail: {
            words(r)
        } bottom: {
            PrimaryButton("Done", action: onDone)
        }
    }
}
