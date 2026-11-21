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
/// - kind: which routine (meditate, eat, exercise, …); defaults to meditate.
/// - reset: 1 removes everything and shows the introduction again.
enum DebugSeed {
    /// `YF_DEMO=1` fills in example answers (a place, things, a feeling) so screens look finished in screenshots.
    static var demo: Bool { ProcessInfo.processInfo.environment["YF_DEMO"] == "1" }

    /// `YF_TIME=06:40` makes Today behave as if it were that time today, to show a given moment (here "In 20 minutes").
    static func clock(_ date: Date) -> Date {
        guard let raw = ProcessInfo.processInfo.environment["YF_TIME"] else { return date }
        let p = raw.split(separator: ":").compactMap { Int($0) }
        guard p.count == 2 else { return date }
        return Calendar.current.date(bySettingHour: p[0], minute: p[1], second: 0, of: date) ?? date
    }

    /// `YF_SCREEN` opens one screen directly: welcome, ideaToday, ideaSame, ideaMandala, howHelps, choose, anchor,
    /// widgetSetup, reflect, kept, routines, edit, mandala. (today, day30 and complete come from YF_SEED.)
    static func route(_ id: UUID?) -> [Route]? {
        guard let s = ProcessInfo.processInfo.environment["YF_SCREEN"], !s.isEmpty else { return nil }
        let rid = id ?? UUID()
        switch s {
        case "ideaToday": return [.ideaToday]
        case "ideaSame": return [.ideaSame]
        case "ideaMandala": return [.ideaMandala]
        case "howHelps": return [.howHelps]
        case "choose": return [.choose]
        case "anchor": return [.anchor(.meditate)]
        case "anchorEat": return [.anchor(.eat)]
        case "widgetSetup": return [.widgetSetup(rid)]
        case "reflect": return [.reflect(rid)]
        case "kept": return [.kept(rid)]
        case "routines": return [.routines]
        case "edit": return [.edit(rid)]
        case "mandala": return [.mandala(rid)]
        default: return nil
        }
    }

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

        let kind = RoutineKind(rawValue: opts["kind"] ?? "") ?? .meditate
        let id = store.addRoutine(name: kind == .meditate ? "Meditate" : kind.title, kind: kind, hour: Int(opts["hour"] ?? "7") ?? 7,
                                  minute: Int(opts["minute"] ?? "0") ?? 0, place: "the balcony", things: ["Yoga mat", "Grey shawl"])
        store.updateRoutine(id) { $0.startedOn = start }
        let feelings: [Feeling] = [.steady, .absorbed, .steady, .scattered, .steady, .absorbed]
        // began=HH:MM records each kept day as begun at that time (v2 reminders that follow and fade).
        let began = opts["began"].map { $0.split(separator: ":").compactMap { Int($0) } }
        for d in 1...min(day, Mandala.days) where !missed.contains(d) {
            if d == day && !keptToday { continue }
            let date = cal.date(byAdding: .day, value: d - 1, to: start) ?? start
            let start = began.flatMap { $0.count == 2 ? cal.date(bySettingHour: $0[0], minute: $0[1], second: 0, of: date) : nil }
            store.markKept(id, on: date, feeling: feelings[d % feelings.count], beganAt: start)
        }
        store.hasOnboarded = true
    }
}

import SwiftUI

/// `YF_FRAME=466x678` lays the app out in a window of that size, to check the iPhone Duo's outer display
/// (or any other size) on whatever simulator is running.
struct DebugFrame: ViewModifier {
    func body(content: Content) -> some View {
        let raw = ProcessInfo.processInfo.environment["YF_FRAME"] ?? ""
        let p = raw.split(separator: "x").compactMap { Double($0) }
        if p.count == 2 {
            // Laid out at the requested size, then scaled to fit the real screen so all of it can be seen.
            GeometryReader { geo in
                let k = min(1, geo.size.width / p[0], geo.size.height / p[1])
                content
                    .frame(width: p[0], height: p[1])
                    .clipped()
                    .scaleEffect(k)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
            .background(Color.black.ignoresSafeArea())
        } else {
            content
        }
    }
}
#endif
