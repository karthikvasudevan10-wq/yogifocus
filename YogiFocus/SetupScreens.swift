import SwiftUI
import YogiKit

// MARK: - Choose one routine

struct ChooseRoutineScreen: View {
    let onBack: (() -> Void)?
    let onContinue: (RoutineKind) -> Void
    @State private var picked: RoutineKind = .meditate

    var body: some View {
        Screen {
            TopBar(back: onBack)
            H1("What would you like to practise?", size: 34).padding(.top, 6)
            Para("Choose one, and only one. Ten minutes a day to begin.").padding(.top, 8)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(RoutineKind.allCases) { kind in
                    let on = kind == picked
                    Button { picked = kind } label: {
                        HStack(spacing: 10) {
                            YFIcon(kind.icon, size: 22).foregroundStyle(YF.textGreen)
                            Text(kind.title).font(YFFont.body(15, .medium)).foregroundStyle(YF.ink)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(on ? YF.softGreen : YF.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(on ? YF.textGreen : YF.line, lineWidth: 2))
                        .contentShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
            .padding(.top, 18)
            Para("When your first mandala is complete, Yogi Focus will invite you to add another.", size: 14, color: YF.muted)
                .padding(.top, 14)
        } bottom: {
            PrimaryButton("Continue") { onContinue(picked) }
        }
    }
}

// MARK: - When, where, with

/// The three anchors of a routine, shared by setup and routine settings.
struct AnchorCard: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var duration: Int
    @Binding var place: String
    @Binding var things: [String]
    @State private var pickingTime = false
    @State private var addingThing = false
    @State private var newThing = ""

    private let label = YFFont.body(13, .medium)

    var body: some View {
        CardBox {
            Button { pickingTime = true } label: {
                HStack(spacing: 14) {
                    YFIcon("clock", size: 22).foregroundStyle(YF.textGreen)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When").font(label).foregroundStyle(YF.muted)
                        Text("\(Words.time(hour: hour, minute: minute)), for \(Words.length(duration))")
                            .font(YFFont.body(17, .semibold)).foregroundStyle(YF.ink)
                    }
                    Spacer(minLength: 0)
                    YFIcon("chev-right", size: 20).foregroundStyle(YF.muted)
                }
                .padding(.horizontal, 18)
                .frame(minHeight: 68)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $pickingTime) {
                TimeSheet(hour: $hour, minute: $minute)
                    .presentationDetents([.height(380)])
            }
            DurationPicker(duration: $duration)
                .padding(.leading, 54)
                .padding(.trailing, 18)
                .padding(.bottom, 14)
            Divider1()
            HStack(spacing: 14) {
                YFIcon("pin", size: 22).foregroundStyle(YF.textGreen)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Where").font(label).foregroundStyle(YF.muted)
                    TextField("", text: $place, prompt: Text("the balcony").foregroundStyle(YF.muted.opacity(0.7)))
                        .font(YFFont.body(17, .semibold))
                        .foregroundStyle(YF.ink)
                        .frame(minHeight: 30)
                        .submitLabel(.done)
                        .accessibilityLabel("Where")
                }
            }
            .padding(.horizontal, 18)
            .frame(minHeight: 72)
            Divider1()
            HStack(alignment: .top, spacing: 14) {
                YFIcon("bag", size: 22).foregroundStyle(YF.textGreen).padding(.top, 2)
                VStack(alignment: .leading, spacing: 8) {
                    Text("With").font(label).foregroundStyle(YF.muted)
                    FlowLayout(spacing: 8) {
                        ForEach(things, id: \.self) { thing in
                            Menu {
                                Button("Remove", role: .destructive) { things.removeAll { $0 == thing } }
                            } label: {
                                Text(thing)
                                    .font(YFFont.body(15, .medium)).foregroundStyle(YF.ink)
                                    .padding(.horizontal, 12)
                                    .frame(minHeight: 34)
                                    .background(YF.softGreen, in: Capsule())
                            }
                            .accessibilityHint("Opens a menu to remove it")
                        }
                        Button { newThing = ""; addingThing = true } label: {
                            YFIcon("plus", size: 20).foregroundStyle(YF.textGreen)
                                .frame(width: 44, height: 44)
                                .overlay(Circle().strokeBorder(YF.muted, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])))
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add something you use")
                        .alert("Something you use", isPresented: $addingThing) {
                            TextField("Yoga mat", text: $newThing)
                            Button("Add") {
                                let t = newThing.trimmingCharacters(in: .whitespaces)
                                if !t.isEmpty, !things.contains(t) { things.append(t) }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("The same things, every time: a mat, a shawl, a book.")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }
}

/// How long: 10, 20, 30, 45 minutes or an hour. One choice, the same every day.
struct DurationPicker: View {
    @Binding var duration: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How long").font(YFFont.body(13, .medium)).foregroundStyle(YF.muted)
            HStack(spacing: 6) {
                ForEach(Mandala.durationChoices, id: \.self) { m in
                    let on = m == duration
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) { duration = m }
                    } label: {
                        Text(Words.length(m, short: true))
                            .font(YFFont.body(14, .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(on ? YF.onAccent : YF.ink)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(on ? YF.leaf : YF.softGreen, in: Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Words.length(m))
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
    }
}

private struct TimeSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()

    var body: some View {
        VStack(spacing: 0) {
            Text("The same hour, every day").font(YFFont.heading(22, .semibold)).foregroundStyle(YF.ink).padding(.top, 24)
            DatePicker("Hour", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.bottom, 8)
            PrimaryButton("Set") {
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                hour = c.hour ?? hour
                minute = c.minute ?? minute
                dismiss()
            }
            .padding(.horizontal, YF.margin)
            .padding(.bottom, 16)
        }
        .background(YF.ground)
        .onAppear { date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date() }
    }
}

// MARK: - Setup

struct AnchorScreen: View {
    @Environment(AppModel.self) private var model
    let kind: RoutineKind
    let onBack: () -> Void
    let onDone: (UUID) -> Void

    @State private var name = ""
    @State private var hour = 7
    @State private var minute = 0
    @State private var duration = Mandala.minimumMinutes
    @State private var place = ""
    @State private var things: [String] = []

    private var routineName: String {
        kind == .own ? name.trimmingCharacters(in: .whitespaces) : kind.title
    }
    private var ready: Bool {
        !place.trimmingCharacters(in: .whitespaces).isEmpty && !routineName.isEmpty
    }

    var body: some View {
        Screen {
            TopBar(back: onBack)
            H1("Give \(routineName.isEmpty ? "your routine" : routineName) a home.", size: 34).padding(.top, 6)
            Para("The more exact you are, the easier it is to begin.").padding(.top, 8)
            if kind == .own {
                CardBox {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What").font(YFFont.body(13, .medium)).foregroundStyle(YF.muted)
                        TextField("", text: $name, prompt: Text("Name your routine").foregroundStyle(YF.muted.opacity(0.7)))
                            .font(YFFont.body(17, .semibold)).foregroundStyle(YF.ink).frame(minHeight: 30)
                            .submitLabel(.done)
                    }
                    .padding(.horizontal, 18)
                    .frame(minHeight: 68)
                }
                .padding(.top, 18)
            }
            AnchorCard(hour: $hour, minute: $minute, duration: $duration, place: $place, things: $things)
                .padding(.top, kind == .own ? 10 : 18)
            Para(duration == Mandala.minimumMinutes
                 ? "Ten minutes is the gentlest start. For the first week, no more."
                 : "Choose the time the practice needs. For the first week, stop when it is up.", size: 14, color: YF.muted)
                .padding(.top, 10)
            StatementCard(text: Words.routineSentence(name: routineName, kind: kind, time: Words.time(hour: hour, minute: minute),
                                                      place: place.isEmpty ? "the balcony" : place, things: things, minutes: duration),
                          size: 20, padding: EdgeInsets(top: 16, leading: 22, bottom: 16, trailing: 22), caption: "Your routine")
                .padding(.top, 12)
        } bottom: {
            PrimaryButton("This is my routine", enabled: ready) {
                let id = YogiStore.shared.addRoutine(name: routineName, kind: kind, hour: hour, minute: minute, durationMinutes: duration,
                                                    place: place.trimmingCharacters(in: .whitespaces), things: things)
                onDone(id)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Add the widget

struct WidgetSetupScreen: View {
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onBack: () -> Void
    let onDone: () -> Void
    @State private var chime = true

    private var routine: RoutineSnapshot? { model.routine(routineID) }
    /// The widget as it looks earlier in the day.
    private var preview: WidgetModel {
        guard let r = routine else { return .sample }
        let early = r.hourDate(on: Date()).addingTimeInterval(-150 * 60)
        var m = WidgetModel.make(r, at: early)
        if m.state != .earlier || m.label != "Today" {
            m = WidgetModel.make(RoutineSnapshot(id: r.id, name: r.name, kind: r.kind, hour: r.hour, minute: r.minute, place: r.place, things: r.things), at: early)
        }
        m.mediumLine = "A new day."
        return m
    }

    var body: some View {
        Screen {
            TopBar(back: onBack) {
                Button("Not now") { finish() }
                    .font(YFFont.body(15, .medium)).foregroundStyle(YF.textGreen).frame(minHeight: 44)
            }
            H1("Let your Home Screen do the remembering.", size: 32).padding(.top, 6)
            YogiWidgetCard(model: preview, size: .medium)
                .padding(16)
                .background(YF.leaf, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, 16)
            VStack(alignment: .leading, spacing: 12) {
                step(1, "Touch and hold an empty spot on your Home Screen.")
                step(2, "Tap Edit, then Add Widget.")
                step(3, "Search for Yogi Focus and choose a size.")
            }
            .padding(.top, 18)
            HStack(spacing: 12) {
                Text("A soft chime at \(routine?.timeText ?? "7:00 am")").font(YFFont.body(15.5, .medium))
                Spacer(minLength: 0)
                YFSwitch(isOn: $chime, label: "A soft chime at \(routine?.timeText ?? "7:00 am")")
            }
            .padding(.leading, 18)
            .frame(minHeight: 60)
            .background(YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
            .padding(.top, 16)
            Para("No badges, no streak alerts, no nagging.", size: 14, color: YF.muted).padding(.top, 10)
        } bottom: {
            PrimaryButton("I've added it") { finish() }
        }
        .onAppear { chime = routine?.chimeEnabled ?? true }
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(spacing: 14) {
            Text("\(n)").font(YFFont.body(14, .semibold)).foregroundStyle(YF.textGreen)
                .frame(width: 28, height: 28).background(YF.softGreen, in: Circle())
            Text(text).font(YFFont.body(15.5)).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func finish() {
        YogiStore.shared.updateRoutine(routineID) { $0.chimeEnabled = chime }
        Task {
            // The nudges are local notifications. Asking here, right after the person has chosen their hour.
            _ = await Nudges.requestPermission()
            model.refresh()
            onDone()
        }
    }
}
