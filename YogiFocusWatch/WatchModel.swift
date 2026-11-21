import SwiftUI
import WatchKit
import YogiKit

/// What the watch shows. A nudge and a quick answer: not a second copy of the app.
enum WatchScreen {
    case empty
    case paused(RoutineSnapshot)
    case newDay(RoutineSnapshot)
    case soon(RoutineSnapshot, minutes: Int)
    case itsTime(RoutineSnapshot)
    case passed(RoutineSnapshot)
    case ask(RoutineSnapshot)
    case kept(RoutineSnapshot)
    case notToday(RoutineSnapshot)

    /// Identity for transitions.
    var key: String {
        switch self {
        case .empty: return "empty"
        case .paused(let r): return "paused-\(r.id)"
        case .newDay(let r): return "new-\(r.id)"
        case .soon(let r, _): return "soon-\(r.id)"
        case .itsTime(let r): return "time-\(r.id)"
        case .passed(let r): return "passed-\(r.id)"
        case .ask(let r): return "ask-\(r.id)"
        case .kept(let r): return "kept-\(r.id)"
        case .notToday(let r): return "not-\(r.id)"
        }
    }
}

@MainActor
@Observable
final class WatchModel {
    var snapshots: [RoutineSnapshot] = []
    var now = Date()
    /// The routine whose "How did it feel?" is on screen.
    var asking: UUID?
    /// The routine whose kept screen is on screen after an answer.
    var showingKept: UUID?
    var isActive = false

    init() { refresh() }

    func refresh() {
        now = Date()
        snapshots = YogiStore.shared.snapshots(now: now)
        playEntryHaptic()
    }

    var screen: WatchScreen {
        #if DEBUG
        if let s = ProcessInfo.processInfo.environment["YF_WATCH_SCREEN"] {
            let r = RoutineSnapshot(name: "Meditate")
            switch s {
            case "empty": return .empty
            case "paused": return .paused(r)
            case "soon": return .soon(r, minutes: 20)
            case "itsTime": return .itsTime(r)
            case "passed": return .passed(r)
            case "ask": return .ask(r)
            case "kept": return .kept(r)
            case "notToday": return .notToday(r)
            default: return .newDay(r)
            }
        }
        #endif
        if let id = asking, let r = snapshots.first(where: { $0.id == id }) { return .ask(r) }
        if let id = showingKept, let r = snapshots.first(where: { $0.id == id }) { return .kept(r) }
        guard let r = Routines.current(snapshots, at: now) else { return .empty }
        switch r.moment(at: now) {
        case .paused: return .paused(r)
        case .earlier: return .newDay(r)
        case .soon(let m): return .soon(r, minutes: m)
        case .itsTime: return .itsTime(r)
        case .passed: return .passed(r)
        case .notToday: return .notToday(r)
        case .kept:
            // Done was tapped (widget, phone or here) and the question has not been answered yet.
            if r.dayNumber(on: now) >= 1, r.feelings[DayKey.key(now)] == nil, r.asksFeeling(on: now), !askDeclined(r) { return .ask(r) }
            return .kept(r)
        }
    }

    // MARK: Actions

    /// Done, or "I've practised": the day counts at once, even if the question is never answered.
    func done(_ r: RoutineSnapshot) {
        YogiStore.shared.markKept(r.id, on: now)
        WatchLink.shared.sendKept(r.id, dayKey: DayKey.key(now), feeling: nil)
        // The question comes about once a week (v2 item 25); other days go straight to kept.
        if r.asksFeeling(on: now) { asking = r.id } else { showingKept = r.id }
        refresh()
    }

    /// "Just two minutes": counts as kept with the two-minute version.
    func twoMinutes(_ r: RoutineSnapshot) {
        YogiStore.shared.markKept(r.id, on: now, twoMinute: true)
        Nudges.cancelToday(r.id, now: now)
        WatchLink.shared.sendKept(r.id, dayKey: DayKey.key(now), feeling: nil, twoMinute: true)
        showingKept = r.id
        WKInterfaceDevice.current().play(.success)
        refresh()
    }

    /// "Not today": closes the day here and on the phone. No haptic.
    func notToday(_ r: RoutineSnapshot) {
        YogiStore.shared.markNotToday(r.id, on: now)
        Nudges.cancelToday(r.id, now: now)
        WatchLink.shared.sendNotToday(r.id, dayKey: DayKey.key(now))
        refresh()
    }

    func feel(_ r: RoutineSnapshot, _ feeling: Feeling) {
        YogiStore.shared.markKept(r.id, on: now, feeling: feeling)
        WatchLink.shared.sendKept(r.id, dayKey: DayKey.key(now), feeling: feeling)
        WKInterfaceDevice.current().play(.success)
        asking = nil
        showingKept = r.id
        refresh()
    }

    func dismissKept() {
        showingKept = nil
        refresh()
    }

    func becameActive() {
        isActive = true
        YogiStore.shared.removeDuplicates()
        refresh()
        // A day kept from the complication's Done button reaches the phone here.
        let key = DayKey.key(now)
        for r in snapshots where r.keptDayKeys.contains(key) {
            WatchLink.shared.sendKept(r.id, dayKey: key, feeling: r.feelings[key].flatMap(Feeling.init(rawValue:)))
        }
    }

    func becameInactive() {
        isActive = false
        if let id = asking, let r = snapshots.first(where: { $0.id == id }) { declineAsk(r) }
        asking = nil
        showingKept = nil
    }

    // MARK: Asking once

    private func askKey(_ r: RoutineSnapshot) -> String { "yf.ask.declined.\(r.id.uuidString)" }
    private func askDeclined(_ r: RoutineSnapshot) -> Bool {
        UserDefaults.standard.string(forKey: askKey(r)) == DayKey.key(now)
    }
    private func declineAsk(_ r: RoutineSnapshot) {
        UserDefaults.standard.set(DayKey.key(now), forKey: askKey(r))
    }

    // MARK: Haptics
    // Only for the moments in the design, and each at most once per routine per day.

    private func playEntryHaptic() {
        guard isActive, asking == nil, showingKept == nil else { return }
        let kind: String, haptic: WKHapticType, r: RoutineSnapshot
        switch screen {
        case .soon(let s, _): kind = "soon"; haptic = .notification; r = s
        case .itsTime(let s): kind = "time"; haptic = .start; r = s
        case .passed(let s): kind = "passed"; haptic = .notification; r = s
        default: return
        }
        let defaultsKey = "yf.haptic.\(kind).\(r.id.uuidString)"
        let today = DayKey.key(now)
        guard UserDefaults.standard.string(forKey: defaultsKey) != today else { return }
        UserDefaults.standard.set(today, forKey: defaultsKey)
        WKInterfaceDevice.current().play(haptic)
    }
}
