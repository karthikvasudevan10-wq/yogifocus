#if canImport(ActivityKit) && os(iOS)
import ActivityKit
import AppIntents
import Foundation
import UserNotifications

// v2 item 4: the practice on the Lock Screen and in the Dynamic Island. Started by a tap (the 20-minute nudge,
// Start, the alarm), never by a server. Before: a countdown to the hour. During: a ring filling over the routine's
// length. After: "That's today, kept." for a moment, then it ends itself. Before day 30, only time: never days or petals.

public struct PracticeActivityAttributes: ActivityAttributes {
    public enum Phase: String, Codable, Hashable, Sendable { case before, during, after }

    public struct ContentState: Codable, Hashable, Sendable {
        public var phase: Phase
        /// Before: now → the hour. During: the timer's start → its end.
        public var start: Date
        public var end: Date
        public var twoMinute: Bool
        /// After, from day 30 only: petals open.
        public var petals: Int?
        public init(phase: Phase, start: Date, end: Date, twoMinute: Bool = false, petals: Int? = nil) {
            self.phase = phase; self.start = start; self.end = end; self.twoMinute = twoMinute; self.petals = petals
        }
    }

    public var routineID: UUID
    public var name: String
    public var place: String
    public var things: String
    public var hasTwoMinute: Bool
    public init(routineID: UUID, name: String, place: String, things: String, hasTwoMinute: Bool) {
        self.routineID = routineID; self.name = name; self.place = place; self.things = things; self.hasTwoMinute = hasTwoMinute
    }
}

/// A routine the app should open at the practice timer, left in the app group by Start (alarm or Live Activity).
public enum PendingTimer {
    static let key = "yf.pending.timer"
    public static func set(_ id: UUID, twoMinute: Bool = false) {
        UserDefaults(suiteName: YogiStore.appGroup)?.set(id.uuidString + (twoMinute ? "|2" : ""), forKey: key)
    }
    /// Reads and clears it.
    public static func take() -> (id: UUID, twoMinute: Bool)? {
        let d = UserDefaults(suiteName: YogiStore.appGroup)
        defer { d?.removeObject(forKey: key) }
        guard let raw = d?.string(forKey: key) else { return nil }
        let parts = raw.split(separator: "|")
        guard let id = parts.first.flatMap({ UUID(uuidString: String($0)) }) else { return nil }
        return (id, parts.count > 1)
    }
}

/// The practice timer that is running, shared by the app and the Live Activity's Done.
public enum RunningTimerStore {
    public static let key = "yf.timer.running"
    public static let endNotificationID = "yf.timer.end"
    public static var defaults: UserDefaults? { UserDefaults(suiteName: YogiStore.appGroup) }
    public static func clear() {
        defaults?.removeObject(forKey: key)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [endNotificationID])
    }
}

public enum PracticeLive {
    static func attributes(_ r: RoutineSnapshot) -> PracticeActivityAttributes {
        PracticeActivityAttributes(routineID: r.id, name: r.name, place: r.placeInSentence, things: r.thingsList,
                                   hasTwoMinute: r.twoMinute != nil)
    }

    static func activities(for id: UUID) -> [Activity<PracticeActivityAttributes>] {
        Activity<PracticeActivityAttributes>.activities.filter { $0.attributes.routineID == id && $0.activityState == .active }
    }

    /// Before: from a tap on the 20-minute nudge, a countdown to the hour.
    public static func startBefore(_ r: RoutineSnapshot, now: Date = Date()) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, activities(for: r.id).isEmpty else { return }
        let hour = r.reminderDate(on: now)
        guard hour > now else { return }
        let state = PracticeActivityAttributes.ContentState(phase: .before, start: now, end: hour)
        _ = try? Activity.request(attributes: attributes(r), content: ActivityContent(state: state, staleDate: hour.addingTimeInterval(30 * 60)))
    }

    /// During: when the practice timer starts. Turns a Before activity into a During one.
    public static func startDuring(_ r: RoutineSnapshot, start: Date, end: Date, twoMinute: Bool) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = PracticeActivityAttributes.ContentState(phase: .during, start: start, end: end, twoMinute: twoMinute)
        let content = ActivityContent(state: state, staleDate: end)
        if let existing = activities(for: r.id).first {
            await existing.update(content)
        } else {
            _ = try? Activity.request(attributes: attributes(r), content: content)
        }
    }

    /// After: "That's today, kept." for a moment, then it ends itself.
    public static func finish(_ id: UUID, now: Date = Date()) async {
        let r = YogiStore.shared.snapshots(now: now).first { $0.id == id }
        let petals = r.flatMap { $0.showsProgress(on: now) ? $0.practisedCount(on: now) : nil }
        let state = PracticeActivityAttributes.ContentState(phase: .after, start: now, end: now, petals: petals)
        for a in activities(for: id) {
            await a.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .after(now.addingTimeInterval(8)))
        }
    }

    /// Quietly, when the day was answered some other way (Not today, or kept elsewhere).
    public static func cancel(_ id: UUID) async {
        for a in activities(for: id) { await a.end(nil, dismissalPolicy: .immediate) }
    }
}

/// Done, on the Live Activity: the day counts as kept, without opening the app.
public struct PracticeDoneIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Done"
    public static let isDiscoverable = false

    @Parameter(title: "Routine") public var routineID: String

    public init() {}
    public init(routineID: UUID) { self.routineID = routineID.uuidString }

    public func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: routineID) else { return .result() }
        let now = Date()
        let began = PracticeLive.activities(for: id).first.map { $0.content.state.phase == .during ? $0.content.state.start : now }
        RunningTimerStore.clear()
        YogiStore.shared.markKept(id, on: now, beganAt: began)
        Nudges.cancelToday(id, now: now)
        await PracticeLive.finish(id, now: now)
        return .result()
    }
}

/// I'm starting, or Two minutes, on the Before activity: opens the practice timer, already running.
public struct PracticeStartIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "I'm starting"
    public static let isDiscoverable = false
    public static let openAppWhenRun = true

    @Parameter(title: "Routine") public var routineID: String
    @Parameter(title: "Two minutes") public var twoMinute: Bool

    public init() {}
    public init(routineID: UUID, twoMinute: Bool) { self.routineID = routineID.uuidString; self.twoMinute = twoMinute }

    public func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: routineID) { PendingTimer.set(id, twoMinute: twoMinute) }
        return .result()
    }
}
#endif
