import SwiftUI
import YogiKit

// MARK: - Your routines

struct RoutinesScreen: View {
    @Environment(AppModel.self) private var model
    let onBack: () -> Void
    let onEdit: (UUID) -> Void
    let onAdd: () -> Void
    @Environment(\.duoPose) private var pose
    /// The routine shown in detail on the wide Duo display.
    @State private var selected: UUID?

    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }

    var phoneBody: some View {
        let now = Date()
        return Screen {
            TopBar(back: onBack)
            H1("Your routines", size: 34).padding(.top, 6)
            Para("Each one has its own hour, its own place and its own things.", size: 15, color: YF.muted).padding(.top, 6)
            routineList(now: now)
            .padding(.top, 16)
            Para("Add slowly. Give each routine a full mandala before you start the next.", size: 14, color: YF.muted)
                .padding(.top, 12)
            Divider1().padding(.top, 22)
            ShareAndRate().padding(.top, 8)
        }
    }

    private func routineList(now: Date) -> some View {
        VStack(spacing: 12) {
            ForEach(model.routines) { r in card(r, now: now) }
            addButton
        }
    }

    /// Always offered. The picker suggests one routine at a time, but never blocks another.
    private var addButton: some View {
        Button(action: onAdd) {
            HStack(spacing: 8) {
                YFIcon("plus", size: 20)
                Text("Add a routine").font(YFFont.body(16, .semibold))
            }
            .foregroundStyle(YF.ink)
            .frame(maxWidth: .infinity, minHeight: pose == .wide ? 56 : 60)
            .overlay(RoundedRectangle(cornerRadius: pose == .wide ? 20 : 24, style: .continuous)
                .strokeBorder(YF.muted, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
            .contentShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(PressStyle())
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
        case .notToday: Chip(text: "Tomorrow, \(r.timeText)", background: YF.softGreen, foreground: YF.textGreen)
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
    var onTwoMinute: () -> Void = {}
    var onQuiet: () -> Void = {}

    @State private var loaded = false
    @State private var hour = 7
    @State private var minute = 0
    @State private var duration = 10
    @State private var place = ""
    @State private var things: [String] = []
    @State private var chime = true
    @State private var paused = false
    @State private var confirmRemove = false
    @State private var askRestart = false
    @State private var feelEveryDay = false
    @State private var followUsual = true
    @State private var keepEvery = false
    @State private var alarm = false
    @State private var alarmRefused = false
    @Environment(\.duoPose) private var pose

    var body: some View {
        Group {
            if pose == .phone { phoneBody } else { duoBody }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear { load(model.routine(routineID)) }
        .sheet(isPresented: $askRestart) {
            RestartSheet(routineName: model.routine(routineID)?.name ?? "this routine") { restart() }
        }
        .confirmationDialog("Remove \(model.routine(routineID)?.name ?? "this routine")?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                YogiStore.shared.removeRoutine(routineID)
                MandalaClipMaker.removeCache(for: routineID)
                model.refresh()
                onBack()
            }
            Button("Keep it", role: .cancel) {}
        } message: {
            Text("Its days and notes are removed from this phone and from iCloud.")
        }
    }

    var phoneBody: some View {
        let r = model.routine(routineID)
        let time = Words.time(hour: hour, minute: minute)
        return Screen {
            TopBar(back: onBack)
            Text("Routine").font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted).padding(.top, 6)
            H1(r?.name ?? "", size: 34)
            AnchorCard(hour: $hour, minute: $minute, duration: $duration, place: $place, things: $things,
                       timed: model.routine(routineID)?.routineKind.isTimed ?? true)
                .padding(.top, 16)
            harderDay.padding(.top, 22)
            SectionLabel("Reminders").padding(.top, 22)
            reminders(time).padding(.top, 8)
            SectionLabel("How did it feel?").padding(.top, 22)
            feelingCard.padding(.top, 8)
            if let r { 
                SectionLabel("Practice time").padding(.top, 22)
                PracticeTimeRows(routine: r) { save(leaving: false); onQuiet() }.padding(.top, 8)
            }
            SectionLabel("This routine").padding(.top, 22)
            thisRoutine.padding(.top, 8)
            Button { confirmRemove = true } label: {
                Text("Remove this routine").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.ink)
                    .padding(.horizontal, 12).frame(minHeight: 44)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        } bottom: {
            PrimaryButton("Save", enabled: !place.trimmingCharacters(in: .whitespaces).isEmpty) { save() }
        }
    }

    /// "On a harder day": the two-minute version (v2 item 10). Not for routines with no length.
    @ViewBuilder var harderDay: some View {
        if let r = model.routine(routineID), r.routineKind.isTimed {
            VStack(alignment: .leading, spacing: 0) {
                SectionLabel("On a harder day")
                CardBox { TwoMinuteRow(routine: r, action: onTwoMinute) }.padding(.top, 8)
            }
        }
    }

    /// The chime, following the usual time (v2 item 18) and keeping every reminder (v2 item 9).
    func reminders(_ time: String) -> some View {
        let r = model.routine(routineID)
        let offset = followUsual ? (r?.reminderOffsetMinutes(on: Date()) ?? 0) : 0
        return VStack(alignment: .leading, spacing: 0) {
            if let r, offset != 0 { FollowCard(routine: r, offset: offset).padding(.bottom, 10) }
            CardBox {
                SettingSwitch(title: "A soft chime at \(time)", detail: nil, isOn: $chime)
                Divider1()
                if #available(iOS 26.0, *) {
                    SettingSwitch(title: "Ring like a gentle alarm",
                                  detail: "With Start and Later, even when the phone is silent.", isOn: $alarm)
                        .onChange(of: alarm) { _, on in
                            guard on else { return }
                            Task {
                                if !(await GentleAlarm.authorize()) { alarm = false; alarmRefused = true }
                            }
                        }
                    Divider1()
                }
                SettingSwitch(title: "Follow when I usually practise",
                              detail: "Reminders move quietly towards the time you tend to begin.", isOn: $followUsual)
                Divider1()
                SettingSwitch(title: "Keep every reminder",
                              detail: "Otherwise they grow lighter as the routine becomes yours.", isOn: $keepEvery)
            }
            if alarmRefused {
                Para("Alarms are turned off for Yogi Focus. You can allow them in Settings, under Yogi Focus.",
                     size: 13.5, color: YF.muted)
                    .padding(.top, 8).padding(.horizontal, 4)
            }
            if followUsual {
                Para("Your routine still says \(time). Reminders never move more than \(RoutineSnapshot.followLimitMinutes) minutes from it.",
                     size: 13.5, color: YF.muted)
                    .padding(.top, 8).padding(.horizontal, 4)
            }
        }
    }

    /// How often "How did it feel?" is asked (v2 item 25). About once a week by default.
    var feelingCard: some View {
        CardBox {
            VStack(alignment: .leading, spacing: 0) {
                Text("How often to ask").font(YFFont.body(15.5, .medium))
                Text("Your answers still build up for later. There is no wrong answer.")
                    .font(YFFont.body(13)).foregroundStyle(YF.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Segmented(options: ["About once a week", "Every day"], selection: Binding(
                    get: { feelEveryDay ? 1 : 0 }, set: { feelEveryDay = $0 == 1 }))
                    .padding(.top, 12)
            }
            .padding(18)
        }
    }

    /// Pause, and begin again.
    var thisRoutine: some View {
        CardBox {
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
            Divider1()
            RestartRow { askRestart = true }
        }
    }

    /// Saves any edits first, so beginning again keeps the hour, place and things as shown.
    private func restart() {
        save(leaving: false)
        YogiStore.shared.restartMandala(routineID)
        paused = false
        model.refresh()
    }

    private func load(_ r: RoutineSnapshot?) {
        guard !loaded, let r else { return }
        loaded = true
        hour = r.hour; minute = r.minute; duration = r.durationMinutes
        place = r.place; things = r.things; chime = r.chimeEnabled; paused = r.isPaused
        feelEveryDay = r.feelingEveryDay ?? false
        followUsual = r.followUsualTime ?? true
        keepEvery = r.keepEveryReminder ?? false
        alarm = r.alarmEnabled ?? false
    }

    private func save(leaving: Bool = true) {
        let store = YogiStore.shared
        store.updateRoutine(routineID) { r in
            r.hour = hour; r.minute = minute; r.durationMinutes = duration
            r.place = place.trimmingCharacters(in: .whitespaces)
            r.things = things
            r.chimeEnabled = chime
            r.feelingEveryDay = feelEveryDay
            r.followUsualTime = followUsual
            r.keepEveryReminder = keepEvery
            r.alarmEnabled = alarm
        }
        store.setPaused(routineID, paused)
        model.refresh()
        if leaving { onBack() }
    }
}

// MARK: - iPhone Duo

extension RoutinesScreen {
    /// Wide (`Duo-Wide-Routines`): the list on the leading side, the selected routine on the trailing side.
    /// Outer and tall: the phone list, with Back in the strip or the bar.
    @ViewBuilder var duoBody: some View {
        let now = Date()
        if pose == .wide, let r = model.routines.first(where: { $0.id == selected }) ?? model.routines.first {
            DuoPage(leadAlignment: .top, trailAlignment: .top, pinsBottom: true, strip: [.back(onBack)]) {
                H1("Your routines", size: 34).padding(.top, 24)
                Para("Each one has its own hour, its own place and its own things.", size: 15, color: YF.muted).padding(.top, 6)
                VStack(spacing: 10) {
                    ForEach(model.routines) { t in listRow(t, now: now, on: t.id == r.id) }
                    addButton
                }
                .padding(.top, 16)
                Para("Add slowly. Give each routine a full mandala before you start the next.", size: 14, color: YF.muted).padding(.top, 24)
            } trail: {
                Text("Routine").font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted).padding(.top, 24)
                H1(r.name, size: 34)
                detailCard(r, now: now).padding(.top, 14)
                ChimeRow(routine: r).padding(.top, 12)
            } bottom: {
                PrimaryButton("Edit \(r.name)") { onEdit(r.id) }
            }
        } else {
            DuoPage(leadAlignment: .top, bar: { AnyView(TopBar(back: onBack)) }) {
                H1("Your routines", size: 34)
                Para("Each one has its own hour, its own place and its own things.", size: 15, color: YF.muted).padding(.top, 6)
                routineList(now: now).padding(.top, 16)
                Para("Add slowly. Give each routine a full mandala before you start the next.", size: 14, color: YF.muted).padding(.top, 12)
            } trail: {
                EmptyView()
            }
        }
    }

    private func listRow(_ t: RoutineSnapshot, now: Date, on: Bool) -> some View {
        Button { withAnimation(.easeOut(duration: 0.2)) { selected = t.id } } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(t.name).font(YFFont.body(17, .semibold)).foregroundStyle(YF.ink)
                    Text("\(t.timeText) · \(t.placeTitle)").font(YFFont.body(14)).foregroundStyle(YF.muted)
                }
                Spacer(minLength: 0)
                chip(t, now: now)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(on ? YF.softGreen : YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(on ? YF.textGreen : YF.line, lineWidth: on ? 2 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    /// No petal counts here: only whether a first mandala is complete.
    private func detailCard(_ r: RoutineSnapshot, now: Date) -> some View {
        let done = r.completedMandalas + (r.isComplete(on: now) ? 1 : 0)
        return CardBox(radius: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Chip(text: done >= 1 ? (done == 1 ? "First mandala complete" : "\(Words.capitalisedFirst(Words.spelled(done))) mandalas complete")
                                     : (r.dayNumber(on: now) <= 6 ? "In its first days" : "In its first mandala"),
                     background: done >= 1 ? YF.sunny : YF.softGreen, foreground: done >= 1 ? YF.onAccent : YF.textGreen)
                Text("Every day").font(YFFont.heading(30)).padding(.top, 8)
                VStack(alignment: .leading, spacing: 2) {
                    AnchorRow(icon: "clock", text: r.whenText, minHeight: 28)
                    AnchorRow(icon: "pin", text: r.placeTitle, minHeight: 28)
                    if !r.things.isEmpty { AnchorRow(icon: "bag", text: r.thingsList, minHeight: 28) }
                }
                .font(YFFont.body(16))
                .padding(.top, 8)
            }
            .padding(20)
        }
    }
}

/// The chime switch for one routine, saved as it is changed.
private struct ChimeRow: View {
    let routine: RoutineSnapshot
    @State private var on = true
    var body: some View {
        HStack(spacing: 12) {
            Text("A soft chime at \(routine.timeText)").font(YFFont.body(15.5, .medium))
            Spacer(minLength: 0)
            YFSwitch(isOn: $on, label: "A soft chime at \(routine.timeText)")
        }
        .padding(.leading, 18)
        .frame(minHeight: 58)
        .background(YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
        .onAppear { on = routine.chimeEnabled }
        .onChange(of: routine.id) { _, _ in on = routine.chimeEnabled }
        .onChange(of: on) { _, v in
            guard v != routine.chimeEnabled else { return }
            YogiStore.shared.updateRoutine(routine.id) { $0.chimeEnabled = v }
        }
    }
}

extension RoutineEditScreen {
    /// Wide: what the routine is on the leading side; its switches, Remove and Save on the trailing side.
    /// Tall: the same split above and below the fold. Outer: the phone screen with Back in the strip.
    var duoBody: some View {
        let r = model.routine(routineID)
        let time = Words.time(hour: hour, minute: minute)
        let anchor = AnchorCard(hour: $hour, minute: $minute, duration: $duration, place: $place, things: $things,
                       timed: model.routine(routineID)?.routineKind.isTimed ?? true)
        return Group {
            if pose == .outer {
                DuoPage(bar: { AnyView(TopBar(back: onBack)) }) {
                    Text("Routine").font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
                    H1(r?.name ?? "", size: 34)
                    anchor.padding(.top, 14)
                    switches(time).padding(.top, 12)
                    removeButton.padding(.top, 6)
                } trail: {
                    EmptyView()
                } bottom: {
                    saveButton
                }
            } else {
                DuoPage(leadAlignment: pose == .tall ? .top : .center, pinsBottom: pose == .tall, bar: { AnyView(TopBar(back: onBack)) }) {
                    Text("Routine").font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
                    H1(r?.name ?? "", size: 34)
                    anchor.padding(.top, 14)
                } trail: {
                    switches(time)
                    removeButton.padding(.top, 8)
                } bottom: {
                    saveButton
                }
            }
        }
    }

    private func switches(_ time: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            harderDay
            SectionLabel("Reminders").padding(.top, 18)
            reminders(time).padding(.top, 8)
            SectionLabel("How did it feel?").padding(.top, 18)
            feelingCard.padding(.top, 8)
            if let r = model.routine(routineID) {
                SectionLabel("Practice time").padding(.top, 18)
                PracticeTimeRows(routine: r) { save(leaving: false); onQuiet() }.padding(.top, 8)
            }
            SectionLabel("This routine").padding(.top, 18)
            thisRoutine.padding(.top, 8)
        }
    }

    private var removeButton: some View {
        Button { confirmRemove = true } label: {
            Text("Remove this routine").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.ink)
                .padding(.horizontal, 12).frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity)
    }

    private var saveButton: some View {
        PrimaryButton("Save", enabled: !place.trimmingCharacters(in: .whitespaces).isEmpty) { save() }
    }
}
