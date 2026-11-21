import SwiftUI
import YogiKit

// v2 item 10: the two-minute version. A tiny fallback for a harder day that still counts as kept.

/// "And on a harder day?" (`V2-Setup-Two`). A step after setup, and reachable from routine settings.
struct TwoMinuteScreen: View {
    @Environment(AppModel.self) private var model
    @Environment(\.duoPose) private var pose
    let routineID: UUID
    /// True when opened from routine settings rather than during setup.
    let editing: Bool
    let onBack: () -> Void
    let onDone: () -> Void

    @State private var choice = ""
    @State private var writingOwn = false
    @State private var own = ""
    @State private var loaded = false
    @FocusState private var ownFocused: Bool

    private var routine: RoutineSnapshot? { model.routine(routineID) }
    private var chosen: String { (writingOwn ? own : choice).trimmingCharacters(in: .whitespaces) }

    var body: some View {
        Group {
            if pose == .phone { phoneBody } else { duoBody }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard !loaded, let r = routine else { return }
        loaded = true
        let suggestions = r.routineKind.twoMinuteSuggestions
        if let current = r.twoMinute {
            if suggestions.contains(current) { choice = current } else { writingOwn = true; own = current }
        } else {
            choice = suggestions.first ?? ""
        }
    }

    private var intro: String {
        guard let r = routine else { return "" }
        let tooMuch = r.routineKind.isTimed ? "\(Words.spokenLength(r.durationMinutes)) feels too much" : "it feels too much"
        return "Choose the smallest version of \(r.name). On a day when \(tooMuch), two minutes still keeps the day."
    }

    @ViewBuilder private var choices: some View {
        if let r = routine {
            FlowLayout(spacing: 8) {
                ForEach(r.routineKind.twoMinuteSuggestions, id: \.self) { s in
                    pill(Words.capitalisedFirst(s), on: !writingOwn && choice == s) {
                        writingOwn = false; choice = s; ownFocused = false
                    }
                }
                pill("Write my own", on: writingOwn) {
                    writingOwn = true; ownFocused = true
                }
            }
            if writingOwn {
                TextField("", text: $own, prompt: Text("sit quietly for two minutes").foregroundStyle(YF.muted.opacity(0.7)))
                    .font(YFFont.body(17, .medium))
                    .focused($ownFocused)
                    .submitLabel(.done)
                    .padding(.horizontal, 18).frame(minHeight: 52)
                    .background(YF.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
                    .padding(.top, 10)
            }
        }
    }

    private func pill(_ text: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(YFFont.body(15, .medium))
                .foregroundStyle(YF.ink)
                .padding(.horizontal, 18).frame(minHeight: 44)
                .background(on ? YF.softGreen : YF.paper, in: Capsule())
                .overlay(Capsule().strokeBorder(on ? YF.textGreen : YF.line, lineWidth: on ? 1.5 : 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    @ViewBuilder private var statement: some View {
        if let r = routine, !chosen.isEmpty {
            StatementCard(text: "I go to \(r.placeInSentence) and \(Words.lowercasedFirst(chosen)).", size: 19,
                          caption: "On a harder day")
            Para("It counts as kept. Showing up is the habit.", size: 14, color: YF.muted).padding(.top, 10)
        }
    }

    private func save() {
        YogiStore.shared.updateRoutine(routineID) { $0.twoMinuteVersion = Words.lowercasedFirst(chosen) }
        model.refresh()
        onDone()
    }

    private func skip() {
        if editing {
            YogiStore.shared.updateRoutine(routineID) { $0.twoMinuteVersion = "" }
            model.refresh()
        }
        onDone()
    }

    private var skipLabel: String { editing ? "None" : "Skip" }

    var phoneBody: some View {
        Screen {
            TopBar(back: onBack) {
                Button(action: skip) {
                    Text(skipLabel).font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen)
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            H1("And on a harder day?", size: 32).padding(.top, 6)
            Para(intro).padding(.top, 8)
            choices.padding(.top, 18)
            statement.padding(.top, 22)
        } bottom: {
            PrimaryButton("Keep this", enabled: !chosen.isEmpty, action: save)
        }
    }

    var duoBody: some View {
        DuoPage(leadAlignment: .top, trailAlignment: .top, pinsBottom: true,
                bar: { AnyView(TopBar(back: onBack, keepsTrailingOnDuo: true) {
                    Button(action: skip) {
                        Text(skipLabel).font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }) }) {
            H1("And on a harder day?", size: 32)
            Para(intro).padding(.top, 8)
            choices.padding(.top, 18)
        } trail: {
            statement
        } bottom: {
            PrimaryButton("Keep this", enabled: !chosen.isEmpty, action: save)
        }
    }
}

/// "The two-minute version", as a row in routine settings.
struct TwoMinuteRow: View {
    let routine: RoutineSnapshot
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                YFIcon("lotus", size: 22).foregroundStyle(YF.textGreen)
                VStack(alignment: .leading, spacing: 0) {
                    Text("The two-minute version").font(YFFont.body(15.5, .medium)).foregroundStyle(YF.ink)
                    Text(routine.twoMinute.map { "\(Words.capitalisedFirst($0)). It counts as kept." }
                         ?? "Choose a tiny version for a harder day.")
                        .font(YFFont.body(13)).foregroundStyle(YF.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                YFIcon("chev-right", size: 20).foregroundStyle(YF.muted)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .frame(minHeight: 68)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

enum TwoMinute {
    /// "Just two minutes": the day counts as kept, marked as the two-minute version.
    @MainActor static func keep(_ id: UUID, model: AppModel) {
        let now = Date()
        YogiStore.shared.markKept(id, on: now, twoMinute: true)
        Nudges.cancelToday(id, now: now)
        model.refresh()
    }
}
