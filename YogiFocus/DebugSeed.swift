#if DEBUG
import Foundation
import YogiKit

/// Debug builds only: put the app at a given day of the mandala so every screen can be looked at.
///
/// Set the environment variable `YF_SEED`, for example in the scheme or with
/// `SIMCTL_CHILD_YF_SEED="day=37;missed=9,17,33;kept=1" xcrun simctl launch booted karthikvasudevan.yogifocus`.
/// - day: the day of the mandala today (1…49).
/// - missed: days that were not kept.
/// - kept: 1 if today is already kept.
/// - hour / minute: the routine's time (defaults to 7:00).
/// - reset: 1 removes everything and shows the introduction again.
enum DebugSeed {
    static func applyIfAsked() {
        guard let raw = ProcessInfo.processInfo.environment["YF_SEED"], !raw.isEmpty else { return }
        var opts: [String: String] = [:]
        for part in raw.split(separator: ";") {
            let kv = part.split(separator: "=", maxSplits: 1).map(String.init)
            if kv.count == 2 { opts[kv[0]] = kv[1] }
        }
        let store = YogiStore.shared
        store.snapshots().forEach { store.removeRoutine($0.id) }
        if opts["reset"] == "1" {
            store.hasOnboarded = false
            return
        }
        let day = max(1, Int(opts["day"] ?? "1") ?? 1)
        let missed = Set((opts["missed"] ?? "").split(separator: ",").compactMap { Int($0) })
        let keptToday = opts["kept"] == "1"
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -(day - 1), to: today) ?? today

        let id = store.addRoutine(name: "Meditate", kind: .meditate, hour: Int(opts["hour"] ?? "7") ?? 7,
                                  minute: Int(opts["minute"] ?? "0") ?? 0, place: "the balcony", things: ["Yoga mat", "Grey shawl"])
        store.updateRoutine(id) { $0.startedOn = start }
        let feelings: [Feeling] = [.steady, .absorbed, .steady, .scattered, .steady, .absorbed]
        for d in 1...min(day, Mandala.days) where !missed.contains(d) {
            if d == day && !keptToday { continue }
            let date = cal.date(byAdding: .day, value: d - 1, to: start) ?? start
            store.markKept(id, on: date, feeling: feelings[d % feelings.count])
        }
        store.hasOnboarded = true
    }
}
#endif
