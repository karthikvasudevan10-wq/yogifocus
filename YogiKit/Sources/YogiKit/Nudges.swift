import Foundation
import UserNotifications

/// Local notifications: the 20-minute nudge, the hour, and the question ten minutes later.
/// On a paired Apple Watch these arrive on the wrist as haptic nudges, with their buttons.
///
/// Rules: never more than one nudge for a missed hour, no badges, no streak alerts, nothing after Done.
public enum Nudges {
    public static let hourCategory = "YF_HOUR"
    public static let askCategory = "YF_ASK"
    public static let doneAction = "YF_DONE"
    public static let notTodayAction = "YF_NOT_TODAY"
    public static let twoMinuteAction = "YF_TWO_MINUTES"
    /// Opens the app at the practice timer (v2 item 24).
    public static let startAction = "YF_START"
    /// The hour's category when the routine has a two-minute version.
    public static let hourTwoCategory = "YF_HOUR_TWO"
    public static let feelingPrefix = "YF_FEEL_"
    public static let routineKey = "routineID"
    public static let dayKey = "dayKey"
    /// Days scheduled ahead. Topped up whenever the app opens or the widget refreshes.
    static let daysAhead = 7

    public static func registerCategories() {
        let done = UNNotificationAction(identifier: doneAction, title: "Done", options: [])
        let notToday = UNNotificationAction(identifier: notTodayAction, title: "Not today", options: [])
        let two = UNNotificationAction(identifier: twoMinuteAction, title: "Just two minutes, done", options: [])
        let start = UNNotificationAction(identifier: startAction, title: "Start", options: [.foreground])
        let feelings = Feeling.allCases.map { UNNotificationAction(identifier: feelingPrefix + $0.rawValue, title: $0.title, options: []) }
        UNUserNotificationCenter.current().setNotificationCategories([
            UNNotificationCategory(identifier: hourCategory, actions: [start, done, notToday], intentIdentifiers: []),
            UNNotificationCategory(identifier: hourTwoCategory, actions: [start, two, done, notToday], intentIdentifiers: []),
            UNNotificationCategory(identifier: askCategory, actions: feelings, intentIdentifiers: []),
        ])
    }

    public static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Replaces every pending nudge with a fresh week, worded for the phase each day falls in.
    public static func reschedule(_ routines: [RoutineSnapshot], now: Date = Date()) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
            center.removeAllPendingNotificationRequests()
            let cal = Calendar.current
            let active = routines.filter { !$0.isPaused }
            guard !active.isEmpty else { return }
            // iOS keeps at most 64 pending requests.
            let days = max(1, min(daysAhead, 60 / (active.count * 3)))
            for r in active {
                // "How did it feel?" about once a week: assume each scheduled question is answered.
                var lastAsk = r.lastFeelingDay(before: now)
                for offset in 0..<days {
                    guard let day = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: now)) else { continue }
                    if offset == 0 && (r.keptToday(now) || r.saidNotToday(now)) { continue }
                    let n = r.dayNumber(on: day)
                    guard n >= 1 else { continue }
                    let phase = Phase.forDay(n)
                    let hour = r.hourDate(on: day)
                    let key = DayKey.key(day)

                    add(center, id: id(r, key, "pre"), at: hour.addingTimeInterval(-Double(Mandala.nudgeBeforeMinutes) * 60), now: now,
                        title: "In \(Mandala.nudgeBeforeMinutes) minutes",
                        body: phase == .boringMiddle
                            ? "\(r.name). No need to feel like it. Just go to \(r.placeInSentence)."
                            : [r.name, r.placeTitle, r.thingsList].filter { !$0.isEmpty }.joined(separator: ". ") + ".",
                        sound: true, category: nil, routine: r, key: key)

                    let line: String
                    switch phase {
                    case .cappedStart: line = "Your mat is waiting."
                    case .boringMiddle: line = "Don't decide. Just start."
                    case .becomingYours, .afterMandala: line = "You know the way."
                    }
                    add(center, id: id(r, key, "hour"), at: hour, now: now,
                        title: "It's time", body: "\(r.name). \(line)",
                        sound: r.chimeEnabled, category: r.twoMinute == nil ? hourCategory : hourTwoCategory, routine: r, key: key)

                    let asks = r.feelingEveryDay == true || lastAsk.map { RoutineSnapshot.daysBetween($0, day) >= 7 } ?? true
                    if asks {
                        lastAsk = day
                        add(center, id: id(r, key, "ask"), at: hour.addingTimeInterval(Double(Mandala.feedbackAfterMinutes) * 60), now: now,
                            title: "How did it feel?", body: "\(r.name). There is no wrong answer.",
                            sound: true, category: askCategory, routine: r, key: key)
                    }
                }
            }
        }
    }

    /// After Done, today's remaining nudges are withdrawn. Then nothing until tomorrow.
    public static func cancelToday(_ routineID: UUID, now: Date = Date()) {
        let key = DayKey.key(now)
        let ids = ["pre", "hour", "ask"].map { "yf.\(routineID.uuidString).\(key).\($0)" }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    private static func id(_ r: RoutineSnapshot, _ key: String, _ kind: String) -> String {
        "yf.\(r.id.uuidString).\(key).\(kind)"
    }

    private static func add(_ center: UNUserNotificationCenter, id: String, at date: Date, now: Date, title: String, body: String,
                            sound: Bool, category: String?, routine: RoutineSnapshot, key: String) {
        guard date > now else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound ? .default : nil
        content.threadIdentifier = routine.id.uuidString
        if let category { content.categoryIdentifier = category }
        content.userInfo = [routineKey: routine.id.uuidString, dayKey: key]
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        center.add(UNNotificationRequest(identifier: id, content: content,
                                         trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)))
    }

    /// Handles a tap on a notification button. Returns true if the day was answered.
    @discardableResult
    public static func handle(action: String, userInfo: [AnyHashable: Any]) -> Bool {
        guard let raw = userInfo[routineKey] as? String, let id = UUID(uuidString: raw) else { return false }
        let day = (userInfo[dayKey] as? String).flatMap { DayKey.date($0) } ?? Date()
        if action == doneAction {
            YogiStore.shared.markKept(id, on: day)
        } else if action == twoMinuteAction {
            YogiStore.shared.markKept(id, on: day, twoMinute: true)
        } else if action == notTodayAction {
            YogiStore.shared.markNotToday(id, on: day)
        } else if action.hasPrefix(feelingPrefix), let f = Feeling(rawValue: String(action.dropFirst(feelingPrefix.count))) {
            YogiStore.shared.markKept(id, on: day, feeling: f)
        } else {
            return false
        }
        cancelToday(id, now: day)
        return true
    }
}
