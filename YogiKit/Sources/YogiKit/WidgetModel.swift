import Foundation

/// Everything a widget (Home Screen, Smart Stack, complication) shows at one moment.
/// Copy is from `docs/03-widgets.md`. Nothing here shows progress before day 30, and nothing ever mentions a miss.
public struct WidgetModel: Hashable, Sendable {
    public enum Tone: String, Sendable { case paper, softYellow, sunny, softGreen }
    public enum State: String, Sendable { case empty, paused, earlier, soon, itsTime, passed, kept }

    public static let reminder = "Remember: same place, same time, same things."

    public var routineID: UUID?
    public var state: State = .empty
    public var tone: Tone = .paper
    public var name: String = "Yogi Focus"
    public var label: String = ""
    public var dot = false
    public var check = false
    public var showsDone = false
    /// Small: one or two short lines.
    public var small1 = ""
    public var small2 = ""
    /// Medium: one line and up to two footer lines.
    public var mediumLine = ""
    public var mediumFoot: [String] = []
    /// Large: the three anchor rows, one larger line and a footer.
    public var whenRow = ""
    public var whereRow = ""
    public var thingsRow = ""
    public var largeLine = ""
    public var largeFoot = ""
    /// The yogi smiles with eyes open after Done.
    public var joyful = false
    /// Days practised: only after day 30, once kept. Then the real lotus replaces the yogi.
    public var progress: Int?
    public var petals: [PetalState]?
    /// Complication text: "7:00 am" and the routine name.
    public var timeText = ""
    /// The next hour, for relevance in the Smart Stack.
    public var hourDate: Date?

    public init() {}

    public static var empty: WidgetModel {
        var m = WidgetModel()
        m.label = "One day at a time"
        m.small1 = "Open Yogi Focus to choose your routine."
        m.mediumLine = "One small routine."
        m.mediumFoot = ["Open Yogi Focus to choose yours."]
        m.largeLine = "One small routine. One day at a time."
        m.largeFoot = "Open Yogi Focus to choose yours."
        return m
    }

    /// The example from the design: Meditate, 7:00 am, the balcony. Used for previews and the gallery.
    public static var sample: WidgetModel {
        make(RoutineSnapshot(name: "Meditate"), at: Calendar.current.date(bySettingHour: 4, minute: 30, second: 0, of: Date()) ?? Date())
    }

    public static func make(for all: [RoutineSnapshot], at now: Date) -> WidgetModel {
        guard let r = Routines.current(all, at: now) else { return .empty }
        return make(r, at: now)
    }

    public static func make(_ r: RoutineSnapshot, at now: Date) -> WidgetModel {
        var m = WidgetModel()
        m.routineID = r.id
        m.name = r.name
        m.timeText = r.timeText
        m.whenRow = r.whenShort
        m.whereRow = r.placeTitle
        m.thingsRow = r.thingsList
        m.hourDate = r.hourDate(on: now)

        let time = r.timeText
        let place = r.placeTitle
        let phase = r.phase(on: now)
        let boring = phase == .boringMiddle
        let anchor = "\(time) · \(place)"

        switch r.moment(at: now) {
        case .paused:
            m.state = .paused
            m.label = "Paused"
            m.small1 = "Nothing is lost."
            m.mediumLine = "Nothing is lost."
            m.mediumFoot = [anchor]
            m.largeLine = "Paused. Nothing is lost."

        case .earlier:
            m.state = .earlier
            let afterMiss = r.isMorningAfterMiss(now)
            if afterMiss {
                m.label = "A new day"
                m.small1 = time
                m.small2 = "Nothing to catch up. Just start."
                m.mediumLine = "Nothing to catch up. Just start."
                m.largeLine = "A new day. Nothing to catch up. Just start."
            } else if boring {
                m.label = "Today, \(time)"
                m.small1 = "Dull is normal now."
                m.small2 = "It passes. Just show up."
                m.mediumLine = "Dull is normal now. It passes."
                m.largeLine = "Dull is normal now. It passes. Just show up."
            } else {
                m.label = "Today"
                m.small1 = time
                m.small2 = place
                m.mediumLine = "A new day."
                m.largeLine = "A new day. How will you keep your practice today?"
            }
            m.mediumFoot = [anchor, r.thingsList].filter { !$0.isEmpty }
            m.largeFoot = startsIn(r.hourDate(on: now), from: now)
            // Now and then, in this calm state only, the line is swapped for the reminder.
            if !afterMiss, isReminderWindow(now) {
                m.small1 = WidgetModel.reminder
                m.small2 = ""
                m.mediumLine = WidgetModel.reminder
                m.largeLine = WidgetModel.reminder
            }

        case .soon(let minutes):
            m.state = .soon
            m.tone = .softYellow
            m.label = "In \(minutes) minute\(minutes == 1 ? "" : "s")"
            if boring {
                m.small1 = "No need to feel like it."
                m.small2 = "Just go to \(r.placeInSentence)."
                m.mediumLine = "No need to feel like it."
                m.largeLine = "No need to feel like it. Just go to \(r.placeInSentence)."
            } else {
                m.small1 = place
                m.small2 = r.thingsList
                m.mediumLine = "A new day."
                m.largeLine = "A new day. How will you keep your practice today?"
            }
            m.mediumFoot = [anchor, r.thingsList].filter { !$0.isEmpty }
            m.largeFoot = "Starts in \(minutes) minute\(minutes == 1 ? "" : "s")"

        case .itsTime:
            m.state = .itsTime
            m.tone = .sunny
            m.label = "It's time"
            m.dot = true
            m.showsDone = true
            switch phase {
            case .boringMiddle:
                m.small1 = "Don't decide. Just start."
                m.mediumLine = "Don't decide. Just start."
                m.largeLine = "Dull is normal now. Don't decide. Just start."
            case .becomingYours, .afterMandala:
                m.small1 = "You know the way."
                m.mediumLine = "You know the way."
                m.largeLine = "You know the way."
            case .cappedStart:
                m.small1 = "Your mat is waiting."
                m.mediumLine = "Your mat is waiting."
                m.largeLine = "Your mat is waiting."
            }

        case .passed:
            m.state = .passed
            m.label = "Still today"
            m.showsDone = true
            m.small1 = "Just start when you can."
            m.mediumLine = "Just start when you can."
            m.largeLine = "Still today. Just start when you can."

        case .kept:
            m.state = .kept
            m.tone = .softGreen
            m.label = "Kept today"
            m.check = true
            m.joyful = true
            if r.showsProgress(on: now) {
                // A petal count may appear only after day 30. It counts days practised, never days missed.
                let n = r.practisedCount(on: now)
                m.progress = n
                m.petals = r.petals(on: now)
                m.small1 = Words.petalsOpen(n)
                m.small2 = "Tomorrow, \(time)"
                m.mediumLine = Words.petalsOpen(n) + "."
                m.mediumFoot = ["Tomorrow, one more", anchor]
                m.largeLine = Words.petalsOpen(n) + ". Tomorrow, one more."
            } else if boring {
                m.small1 = "You started anyway."
                m.small2 = "That is the whole practice."
                m.mediumLine = "Only tomorrow is next."
                m.mediumFoot = ["Tomorrow, \(anchor)"]
                m.largeLine = "That's today, kept. Only tomorrow is next."
            } else {
                m.small1 = "See you tomorrow"
                m.small2 = time
                m.mediumLine = "Only tomorrow is next."
                m.mediumFoot = ["Tomorrow, \(anchor)"]
                m.largeLine = "That's today, kept. Only tomorrow is next."
            }
            m.largeFoot = "Tomorrow, \(time)"
        }
        return m
    }

    static func startsIn(_ hour: Date, from now: Date) -> String {
        let minutes = Int((hour.timeIntervalSince(now) / 60).rounded())
        if minutes >= 90 {
            let h = Int((Double(minutes) / 60).rounded())
            return "Starts in \(h) hours"
        }
        if minutes >= 45 { return "Starts in 1 hour" }
        return "Starts in \(max(1, minutes)) minutes"
    }

    /// The reminder shows for twenty minutes at the top of every third hour: a few times a day.
    static func isReminderWindow(_ date: Date) -> Bool {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) % 3 == 0 && (c.minute ?? 0) < 20
    }

    /// The moments at which what the widget shows can change, from `now` to the end of tomorrow.
    public static func timelineDates(for all: [RoutineSnapshot], from now: Date) -> [Date] {
        let cal = Calendar.current
        var dates: Set<Date> = [now]
        let today = cal.startOfDay(for: now)
        for dayOffset in 0...1 {
            guard let day = cal.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            if dayOffset == 1 { dates.insert(day) }
            for h in stride(from: 0, to: 24, by: 3) {
                if let d = cal.date(bySettingHour: h, minute: 0, second: 0, of: day) { dates.insert(d); dates.insert(d.addingTimeInterval(20 * 60)) }
            }
            for r in all where !r.isPaused {
                let hour = r.hourDate(on: day)
                for m in [20, 15, 10, 5, 3, 1] { dates.insert(hour.addingTimeInterval(-Double(m) * 60)) }
                dates.insert(hour)
                dates.insert(hour.addingTimeInterval(Double(Mandala.hourWindowMinutes) * 60))
                for h in 1...12 { dates.insert(hour.addingTimeInterval(-Double(h) * 3600)) }
            }
        }
        let end = cal.date(byAdding: .day, value: 2, to: today) ?? now.addingTimeInterval(2 * 86400)
        return dates.filter { $0 >= now && $0 < end }.sorted()
    }
}
