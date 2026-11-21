#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import AppIntents
import Foundation
import SwiftUI

// v2 item 22: a gentle alarm at the hour, with AlarmKit (iOS 26). Off unless chosen, per routine.
// It breaks through silent mode as an alarm should, shows Start and Later, and rings with the app's own soft chime.
// Start opens the practice timer; Later rings once more in ten minutes, then never again that day.
// While it is on, it takes the place of that routine's "It's time" notification, so nothing rings twice.
// It lives here so the app (which schedules it) and the widget extension (which draws it) share one definition.

/// What the gentle alarm carries.
@available(iOS 26.0, *)
public struct YogiAlarmMetadata: AlarmMetadata {
    public var routineID: UUID?
    public var name: String
    public var place: String
    public var time: String
    public init(routineID: UUID?, name: String, place: String, time: String) {
        self.routineID = routineID; self.name = name; self.place = place; self.time = time
    }
}


/// Start, on the alarm: stops it and opens the practice timer, already running.
@available(iOS 26.0, *)
public struct AlarmStartIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Start"
    public static let isDiscoverable = false
    public static let openAppWhenRun = true

    @Parameter(title: "Alarm") public var alarmID: String
    @Parameter(title: "Routine") public var routineID: String

    public init() {}
    public init(alarmID: UUID, routineID: UUID) { self.alarmID = alarmID.uuidString; self.routineID = routineID.uuidString }

    public func perform() async throws -> some IntentResult {
        if let a = UUID(uuidString: alarmID) { try? AlarmManager.shared.stop(id: a) }
        if let id = UUID(uuidString: routineID) { PendingTimer.set(id) }
        return .result()
    }
}

/// Later, on the alarm: stops it and rings once more in ten minutes.
@available(iOS 26.0, *)
public struct AlarmLaterIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Later"
    public static let isDiscoverable = false

    @Parameter(title: "Alarm") public var alarmID: String
    @Parameter(title: "Routine") public var routineID: String

    public init() {}
    public init(alarmID: UUID, routineID: UUID) { self.alarmID = alarmID.uuidString; self.routineID = routineID.uuidString }

    public func perform() async throws -> some IntentResult {
        if let a = UUID(uuidString: alarmID) { try? AlarmManager.shared.stop(id: a) }
        if let id = UUID(uuidString: routineID), let r = YogiStore.shared.snapshots().first(where: { $0.id == id }) {
            await GentleAlarm.schedule(r, at: Date().addingTimeInterval(GentleAlarm.laterMinutes * 60), offersLater: false)
        }
        return .result()
    }
}

@available(iOS 26.0, *)
public enum GentleAlarm {
    public static let laterMinutes: Double = 10
    /// Days scheduled ahead; topped up whenever the app opens.
    static let daysAhead = 3
    public static let soundName = "chime.wav"

    /// Asks once, when the person turns the alarm on. True if alarms are allowed.
    public static func authorize() async -> Bool {
        let manager = AlarmManager.shared
        switch manager.authorizationState {
        case .authorized: return true
        case .notDetermined: return (try? await manager.requestAuthorization()) == .authorized
        default: return false
        }
    }

    /// Replaces every scheduled alarm with the next few days, skipping a day already kept or answered Not today.
    public static func reschedule(_ routines: [RoutineSnapshot], now: Date = Date()) async {
        let manager = AlarmManager.shared
        guard manager.authorizationState == .authorized else { return }
        for alarm in (try? manager.alarms) ?? [] where alarm.state == .scheduled { try? manager.cancel(id: alarm.id) }
        let cal = Calendar.current
        for r in routines where r.alarmEnabled == true && !r.isPaused {
            for offset in 0..<daysAhead {
                guard let day = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: now)) else { continue }
                if offset == 0 && (r.keptToday(now) || r.saidNotToday(now)) { continue }
                guard r.dayNumber(on: day) >= 1 else { continue }
                let at = r.reminderDate(on: day)
                guard at > now else { continue }
                await schedule(r, at: at, offersLater: true)
            }
        }
    }

    public static func schedule(_ r: RoutineSnapshot, at date: Date, offersLater: Bool) async {
        let id = UUID()
        let start = AlarmButton(text: "Start", textColor: YF.onAccent, systemImageName: "play.fill")
        let later = AlarmButton(text: "Later", textColor: .white, systemImageName: "clock")
        let alert = AlarmPresentation.Alert(title: LocalizedStringResource(stringLiteral: r.name), stopButton: start,
                                            secondaryButton: offersLater ? later : nil,
                                            secondaryButtonBehavior: offersLater ? .custom : nil)
        let attributes = AlarmAttributes<YogiAlarmMetadata>(
            presentation: AlarmPresentation(alert: alert),
            metadata: YogiAlarmMetadata(routineID: r.id, name: r.name, place: r.placeTitle, time: r.timeText),
            tintColor: YF.leaf)
        let configuration = AlarmManager.AlarmConfiguration<YogiAlarmMetadata>.alarm(
            schedule: .fixed(date), attributes: attributes,
            stopIntent: AlarmStartIntent(alarmID: id, routineID: r.id),
            secondaryIntent: offersLater ? AlarmLaterIntent(alarmID: id, routineID: r.id) : nil,
            sound: .named(soundName))
        _ = try? await AlarmManager.shared.schedule(id: id, configuration: configuration)
    }
}
#endif
