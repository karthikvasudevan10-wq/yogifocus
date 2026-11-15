import SwiftUI
import YogiKit

// MARK: - Your routines

struct RoutinesScreen: View {
    @Environment(AppModel.self) private var model
    let onBack: () -> Void
    let onEdit: (UUID) -> Void
    let onAdd: () -> Void

    var body: some View {
        let now = Date()
        Screen {
            TopBar(back: onBack)
            H1("Your routines", size: 34).padding(.top, 6)
            Para("Each one has its own hour, its own place and its own things.", size: 15, color: YF.muted).padding(.top, 6)
            VStack(spacing: 12) {
                ForEach(model.routines) { r in card(r, now: now) }
                // Adding a second routine is offered only after the first mandala is complete.
                if model.mayAddRoutine {
                    Button(action: onAdd) {
                        HStack(spacing: 8) {
                            YFIcon("plus", size: 20)
                            Text("Add a routine").font(YFFont.body(16, .semibold))
                        }
                        .foregroundStyle(YF.ink)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(YF.muted, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
                        .contentShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(PressStyle())
                }
            }
            .padding(.top, 16)
            Para("Add slowly. Give each routine a full mandala before you start the next.", size: 14, color: YF.muted)
                .padding(.top, 12)
        }
    }

    private func card(_ r: RoutineSnapshot, now: Date) -> some View {
        CardBox(radius: 24) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Text(r.name).font(YFFont.heading(26)).lineLimit(1).minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                    chip(r, now: now)
                }
                .padding(.trailing, 6)
                VStack(alignment: .leading, spacing: 0) {
                    AnchorRow(icon: "clock", text: r.whenShort, iconSize: 18, gap: 10, minHeight: 26)
                    AnchorRow(icon: "pin", text: r.placeTitle, iconSize: 18, gap: 10, minHeight: 26)
                    if !r.things.isEmpty { AnchorRow(icon: "bag", text: r.thingsList, iconSize: 18, gap: 10, minHeight: 26) }
                }
                .font(YFFont.body(15))
                .padding(.top, 8)
                HStack(spacing: 10) {
                    footer(r, now: now)
                    Spacer(minLength: 0)
                    Button { onEdit(r.id) } label: {
                        HStack(spacing: 2) {
                            Text("Edit").font(YFFont.body(15, .semibold))
                            YFIcon("chev-right", size: 18)
                        }
                        .foregroundStyle(YF.textGreen)
                        .padding(.horizontal, 6)
                        .frame(minHeight: 44)
                    }
                    .accessibilityLabel("Edit \(r.name)")
                }
                .padding(.top, 4)
            }
            .padding(EdgeInsets(top: 18, leading: 18, bottom: 6, trailing: 12))
        }
    }

    @ViewBuilder private func chip(_ r: RoutineSnapshot, now: Date) -> some View {
        switch r.moment(at: now) {
        case .kept: Chip(text: "Kept today", background: YF.softGreen, foreground: YF.textGreen, check: true)
        case .paused: Chip(text: "Paused", background: YF.line, foreground: YF.ink)
        case .passed: Chip(text: "Whenever you're ready")
        default: Chip(text: "Next, \(r.timeText)")
        }
    }

    /// No petal counts here.
    @ViewBuilder private func footer(_ r: RoutineSnapshot, now: Date) -> some View {
        let done = r.completedMandalas + (r.isComplete(on: now) ? 1 : 0)
        if done >= 1 {
            HStack(spacing: 8) {
                LotusView().frame(width: 30, height: 30)
                Text(done == 1 ? "First mandala complete" : "\(Words.capitalisedFirst(Words.spelled(done))) mandalas complete")
                    .font(YFFont.body(13.5, .semibold)).foregroundStyle(YF.textGreen)
            }
        } else {
            Text(r.dayNumber(on: now) <= 6 ? "In its first days" : "In its first mandala")
                .font(YFFont.body(13.5, .medium)).foregroundStyle(YF.muted)
        }
    }
}

// MARK: - Routine settings

struct RoutineEditScreen: View {
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onBack: () -> Void

    @State private var loaded = false
    @State private var hour = 7
    @State private var minute = 0
    @State private var duration = 10
    @State private var place = ""
    @State private var things: [String] = []
    @State private var chime = true
    @State private var paused = false
    @State private var confirmRemove = false

    var body: some View {
        let r = model.routine(routineID)
        let time = Words.time(hour: hour, minute: minute)
        Screen {
            TopBar(back: onBack)
            Text("Routine").font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted).padding(.top, 6)
            H1(r?.name ?? "", size: 34)
            AnchorCard(hour: $hour, minute: $minute, duration: $duration, place: $place, things: $things)
                .padding(.top, 16)
            CardBox {
                HStack(spacing: 12) {
                    Text("A soft chime at \(time)").font(YFFont.body(15.5, .medium))
                    Spacer(minLength: 0)
                    YFSwitch(isOn: $chime, label: "A soft chime at \(time)")
                }
                .padding(.leading, 18)
                .frame(minHeight: 60)
                Divider1()
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Pause this routine").font(YFFont.body(15.5, .medium))
                        Text("The widget goes quiet. Nothing is lost.").font(YFFont.body(13)).foregroundStyle(YF.muted)
                    }
                    Spacer(minLength: 0)
                    YFSwitch(isOn: $paused, label: "Pause this routine")
                }
                .padding(.leading, 18)
                .frame(minHeight: 68)
            }
            .padding(.top, 14)
            Button { confirmRemove = true } label: {
                Text("Remove this routine").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.ink)
                    .padding(.horizontal, 12).frame(minHeight: 44)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        } bottom: {
            PrimaryButton("Save", enabled: !place.trimmingCharacters(in: .whitespaces).isEmpty) { save() }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear { load(r) }
        .confirmationDialog("Remove \(r?.name ?? "this routine")?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                YogiStore.shared.removeRoutine(routineID)
                model.refresh()
                onBack()
            }
            Button("Keep it", role: .cancel) {}
        } message: {
            Text("Its days and notes are removed from this phone and from iCloud.")
        }
    }

    private func load(_ r: RoutineSnapshot?) {
        guard !loaded, let r else { return }
        loaded = true
        hour = r.hour; minute = r.minute; duration = r.durationMinutes
        place = r.place; things = r.things; chime = r.chimeEnabled; paused = r.isPaused
    }

    private func save() {
        let store = YogiStore.shared
        store.updateRoutine(routineID) { r in
            r.hour = hour; r.minute = minute; r.durationMinutes = duration
            r.place = place.trimmingCharacters(in: .whitespaces)
            r.things = things
            r.chimeEnabled = chime
        }
        store.setPaused(routineID, paused)
        model.refresh()
        onBack()
    }
}
