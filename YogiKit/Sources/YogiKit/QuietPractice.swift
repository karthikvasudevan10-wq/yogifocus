#if canImport(FamilyControls) && os(iOS)
import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

// v2 item 3: keep practice time clear. iOS doesn't let an app switch on Do Not Disturb, so instead the apps the
// person chooses are quieted, with Screen Time, from five minutes before the routine until its length is up.
// Shared by the app (which chooses and schedules), the monitor extension (which turns the quiet on and off) and
// the shield extension (which draws "It's practice time.").

public enum QuietPractice {
    static let selectionKey = "yf.quiet.selection."
    static let enabledKey = "yf.quiet.enabled."
    static let nowKey = "yf.quiet.now"
    public static let minutesBefore = 5
    static var defaults: UserDefaults? { UserDefaults(suiteName: YogiStore.appGroup) }

    public static func activityName(_ id: UUID) -> DeviceActivityName { DeviceActivityName("yf.quiet." + id.uuidString) }
    public static func routineID(from name: DeviceActivityName) -> UUID? {
        UUID(uuidString: String(name.rawValue.dropFirst("yf.quiet.".count)))
    }
    static func store(_ id: UUID) -> ManagedSettingsStore { ManagedSettingsStore(named: .init("yf.quiet." + id.uuidString)) }

    // MARK: The person's choice

    public static func selection(_ id: UUID) -> FamilyActivitySelection {
        guard let data = defaults?.data(forKey: selectionKey + id.uuidString),
              let s = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return FamilyActivitySelection() }
        return s
    }

    public static func setSelection(_ s: FamilyActivitySelection, for id: UUID) {
        if let data = try? JSONEncoder().encode(s) { defaults?.set(data, forKey: selectionKey + id.uuidString) }
    }

    public static func isEnabled(_ id: UUID) -> Bool { defaults?.bool(forKey: enabledKey + id.uuidString) ?? false }
    public static func setEnabled(_ on: Bool, for id: UUID) { defaults?.set(on, forKey: enabledKey + id.uuidString) }

    public static func hasApps(_ s: FamilyActivitySelection) -> Bool {
        !s.applicationTokens.isEmpty || !s.categoryTokens.isEmpty || !s.webDomainTokens.isEmpty
    }

    /// The window: five minutes before the hour (as the reminders have moved it) until the routine's length is up.
    public static func window(_ r: RoutineSnapshot, on date: Date = Date()) -> (start: Date, end: Date) {
        let hour = r.reminderDate(on: date)
        let length = r.routineKind.isTimed ? r.durationMinutes : 10
        return (hour.addingTimeInterval(-Double(minutesBefore) * 60), hour.addingTimeInterval(Double(length) * 60))
    }

    // MARK: Scheduling (the app)

    /// Matches the daily schedules to the routines: one repeating window per routine that has the quiet on.
    public static func reschedule(_ routines: [RoutineSnapshot]) {
        let center = DeviceActivityCenter()
        let wanted = routines.filter { isEnabled($0.id) && hasApps(selection($0.id)) && !$0.isPaused }
        for name in center.activities where !wanted.contains(where: { activityName($0.id) == name }) {
            center.stopMonitoring([name])
            if let id = routineID(from: name) { clear(id) }
        }
        let cal = Calendar.current
        for r in wanted {
            let w = window(r)
            let schedule = DeviceActivitySchedule(
                intervalStart: cal.dateComponents([.hour, .minute], from: w.start),
                intervalEnd: cal.dateComponents([.hour, .minute], from: w.end),
                repeats: true)
            try? center.startMonitoring(activityName(r.id), during: schedule)
        }
    }

    // MARK: Quiet on and off (the monitor extension, and the app when the practice ends early)

    /// Turns the quiet on, unless today is already kept, answered Not today, or paused.
    public static func begin(_ id: UUID, now: Date = Date()) {
        guard let r = YogiStore.shared.snapshots(now: now).first(where: { $0.id == id }),
              !r.isPaused, !r.keptToday(now), !r.saidNotToday(now) else { return }
        let s = selection(id)
        let store = store(id)
        store.shield.applications = s.applicationTokens.isEmpty ? nil : s.applicationTokens
        store.shield.applicationCategories = s.categoryTokens.isEmpty ? nil : .specific(s.categoryTokens)
        store.shield.webDomains = s.webDomainTokens.isEmpty ? nil : s.webDomainTokens
        let w = window(r, on: now)
        let info = QuietNow(name: r.name, place: r.placeInSentence, endsAt: w.end)
        if let data = try? JSONEncoder().encode(info) { defaults?.set(data, forKey: nowKey) }
    }

    /// Turns the quiet off: at the end of the window, or as soon as the day is kept.
    public static func clear(_ id: UUID) {
        store(id).clearAllSettings()
        defaults?.removeObject(forKey: nowKey)
    }

    /// What the shield says.
    public struct QuietNow: Codable, Sendable {
        public var name: String
        public var place: String
        public var endsAt: Date
    }

    public static var now: QuietNow? {
        defaults?.data(forKey: nowKey).flatMap { try? JSONDecoder().decode(QuietNow.self, from: $0) }
    }
}
#endif
