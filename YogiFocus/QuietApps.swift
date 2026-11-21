import FamilyControls
import SwiftUI
import YogiKit

// v2 item 3: Do Not Disturb alternatives. iOS doesn't let an app turn on Do Not Disturb, so Yogi Focus quiets the
// apps the person picks with Screen Time, from five minutes before until the routine's length is up, and helps
// them set up Do Not Disturb themselves with a Shortcuts automation.

/// "Practice time" rows in routine settings.
struct PracticeTimeRows: View {
    let routine: RoutineSnapshot
    let action: () -> Void
    var body: some View {
        CardBox {
            if QuietPractice.isAvailable {
                row(icon: "settings", title: "Quiet distracting apps", detail: quietDetail)
                Divider1()
            }
            row(icon: "clock", title: "Do Not Disturb with one tap", detail: "Set up once in Shortcuts")
        }
    }

    private var quietDetail: String {
        guard QuietPractice.isEnabled(routine.id) else { return "Off. Choose apps to quiet while you practise." }
        let w = QuietPractice.window(routine)
        return "\(Words.timeOf(w.start)) to \(Words.timeOf(w.end))"
    }

    private func row(icon: String, title: String, detail: String) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                YFIcon(icon, size: 22).foregroundStyle(YF.textGreen)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(YFFont.body(15.5, .medium)).foregroundStyle(YF.ink)
                    Text(detail).font(YFFont.body(13)).foregroundStyle(YF.muted).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                YFIcon("chev-right", size: 20).foregroundStyle(YF.muted)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// "Keep practice time clear" (`V2-Quiet-Apps`).
struct QuietAppsScreen: View {
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onDone: () -> Void

    @State private var enabled = false
    @State private var selection = FamilyActivitySelection()
    @State private var picking = false
    @State private var refused = false
    @State private var loaded = false

    private var routine: RoutineSnapshot? { model.routine(routineID) }

    var body: some View {
        Screen {
            TopBar(back: save)
            if let r = routine {
                Text(r.name).font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted).padding(.top, 6)
                H1("Keep practice time clear", size: 32)
                Para("From five minutes before until your \(r.routineKind.isTimed ? Words.spokenLength(r.durationMinutes) : "practice") \(r.durationMinutes == 60 ? "is" : "are") up.",
                     size: 16, color: YF.muted).padding(.top, 6)
                if QuietPractice.isAvailable { quietCard(r).padding(.top, 18) }
                dndCard(r).padding(.top, QuietPractice.isAvailable ? 12 : 18)
                Para("If you change the hour or length, update the Shortcuts automation too.", size: 13.5, color: YF.muted)
                    .padding(.top, 12).padding(.horizontal, 4)
            }
        } bottom: {
            PrimaryButton("Done", action: save)
        }
        .familyActivityPicker(isPresented: $picking, selection: $selection)
        .onAppear(perform: load)
        .onChange(of: enabled) { _, on in if on { authorize() } }
    }

    private func load() {
        guard !loaded else { return }
        loaded = true
        enabled = QuietPractice.isEnabled(routineID)
        selection = QuietPractice.selection(routineID)
    }

    /// Screen Time asks once; nothing leaves the phone.
    private func authorize() {
        Task { @MainActor in
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                if !QuietPractice.hasApps(selection) { picking = true }
            } catch {
                enabled = false
                refused = true
            }
        }
    }

    private func save() {
        guard QuietPractice.isAvailable else { onDone(); return }
        QuietPractice.setSelection(selection, for: routineID)
        QuietPractice.setEnabled(enabled && QuietPractice.hasApps(selection), for: routineID)
        QuietPractice.reschedule(model.routines)
        onDone()
    }

    private func quietCard(_ r: RoutineSnapshot) -> some View {
        let w = QuietPractice.window(r)
        return CardBox {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Quiet distracting apps").font(YFFont.body(15.5, .medium))
                        Text("\(Words.timeOf(w.start)) to \(Words.timeOf(w.end)), every day").font(YFFont.body(13)).foregroundStyle(YF.muted)
                    }
                    Spacer(minLength: 0)
                    YFSwitch(isOn: $enabled, label: "Quiet distracting apps")
                }
                if QuietPractice.hasApps(selection) {
                    FlowLayout(spacing: 8) {
                        ForEach(Array(selection.applicationTokens), id: \.self) { token in
                            Label(token).labelStyle(.titleAndIcon)
                                .font(YFFont.body(14, .medium))
                                .padding(.horizontal, 12).frame(minHeight: 36)
                                .background(YF.softGreen, in: Capsule())
                        }
                        ForEach(Array(selection.categoryTokens), id: \.self) { token in
                            Label(token).labelStyle(.titleAndIcon)
                                .font(YFFont.body(14, .medium))
                                .padding(.horizontal, 12).frame(minHeight: 36)
                                .background(YF.softGreen, in: Capsule())
                        }
                    }
                    .padding(.top, 12)
                }
                Button { picking = true } label: {
                    Text(QuietPractice.hasApps(selection) ? "Choose apps" : "Choose apps to quiet")
                        .font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen)
                        .frame(minHeight: 44)
                }
                .padding(.top, 4)
                if refused {
                    Text("Screen Time access is off for Yogi Focus. You can allow it in Settings, under Screen Time.")
                        .font(YFFont.body(13)).foregroundStyle(YF.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
        }
    }

    /// Do Not Disturb, set up once by the person in Shortcuts (apps can't switch it on).
    private func dndCard(_ r: RoutineSnapshot) -> some View {
        let w = QuietPractice.window(r)
        return CardBox {
            VStack(alignment: .leading, spacing: 8) {
                Text("Do Not Disturb with one tap").font(YFFont.body(15.5, .medium))
                Text("iPhone doesn't let apps turn on Do Not Disturb, but Shortcuts can, every day by itself. Set it up once:")
                    .font(YFFont.body(13.5)).foregroundStyle(YF.muted).fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: 4) {
                    step(1, "In Shortcuts, tap Automation, then New Automation.")
                    step(2, "Choose Time of Day: \(Words.timeOf(w.start)), Daily, Run Immediately.")
                    step(3, "Add Set Focus: Do Not Disturb, On, Until Time \(Words.timeOf(w.end)).")
                }
                Link(destination: URL(string: "shortcuts://")!) {
                    Text("Open Shortcuts").font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen)
                        .padding(.horizontal, 18).frame(minHeight: 40)
                        .background(YF.softGreen, in: Capsule())
                }
                .padding(.top, 4)
            }
            .padding(18)
        }
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(n).").font(YFFont.body(13.5, .semibold)).foregroundStyle(YF.textGreen).frame(width: 16, alignment: .leading)
            Text(text).font(YFFont.body(13.5)).foregroundStyle(YF.ink).fixedSize(horizontal: false, vertical: true)
        }
    }
}
