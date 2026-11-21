import Foundation
import SwiftData

// MARK: - Constants from the product rules

public enum Mandala {
    public static let days = 48
    public static let progressHiddenUntilDay = 30
    public static let minimumMinutes = 10
    /// How long a routine can be. Ten minutes is the gentlest start; some practices need longer.
    public static let durationChoices = [10, 20, 30, 45, 60]
    public static let nudgeBeforeMinutes = 20
    public static let feedbackAfterMinutes = 10
    /// How long "It's time" holds before it becomes "Still today".
    public static let hourWindowMinutes = 30
}

public enum Phase: String, Codable, Sendable {
    case cappedStart      // days 1 to 6
    case boringMiddle     // days 7 to 27
    case becomingYours    // days 28 to 48
    case afterMandala     // 49 on

    public static func forDay(_ day: Int) -> Phase {
        switch day {
        case ..<7: return .cappedStart
        case 7...27: return .boringMiddle
        case 28...48: return .becomingYours
        default: return .afterMandala
        }
    }
}

public enum Feeling: String, Codable, CaseIterable, Sendable, Identifiable {
    case scattered, steady, absorbed
    public var id: String { rawValue }
    public var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
    public var subtitle: String {
        switch self {
        case .scattered: return "My mind was everywhere"
        case .steady: return "I stayed with it, mostly"
        case .absorbed: return "I lost track of time"
        }
    }
    public var reply: String {
        switch self {
        case .scattered: return "Scattered days build the habit more than easy ones. You came anyway."
        case .steady: return "Steady is exactly how a practice grows."
        case .absorbed: return "Hold on to this feeling. It is what the practice gives back."
        }
    }
    public var icon: String { rawValue }
}

/// The twelve routine choices.
public enum RoutineKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case meditate, stretch, exercise, walk, eat, read, journal, music, study, tidy, plan, own
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .meditate: return "Meditate"
        case .stretch: return "Stretch"
        case .exercise: return "Gym"
        case .walk: return "Walk"
        case .eat: return "Cut Sugar"
        case .read: return "Read"
        case .journal: return "Journal"
        case .music: return "Play music"
        case .study: return "Study"
        case .tidy: return "Tidy up"
        case .plan: return "Plan my day"
        case .own: return "My own"
        }
    }
    public var icon: String { self == .own ? "plus" : rawValue }
    /// Cutting sugar is one small action at one moment, so it has an hour but no length.
    public var isTimed: Bool { self != .eat }
    /// The verb used in "…and meditate for ten minutes."
    public var verb: String? {
        switch self {
        case .meditate: return "meditate"
        case .stretch: return "stretch"
        case .exercise: return "work out"
        case .walk: return "walk"
        case .eat: return "skip the sugar"
        case .read: return "read"
        case .journal: return "journal"
        case .music: return "play music"
        case .study: return "study"
        case .tidy: return "tidy up"
        case .plan: return "plan my day"
        case .own: return nil
        }
    }
}

// MARK: - Stored models (SwiftData, mirrored to the person's private iCloud database)
// CloudKit rules: every property has a default or is optional, and nothing is marked unique.

@Model
public final class Routine {
    public var id: UUID = UUID()
    public var name: String = ""
    public var kindRaw: String = RoutineKind.meditate.rawValue
    public var hour: Int = 7
    public var minute: Int = 0
    public var durationMinutes: Int = 10
    public var place: String = ""
    /// The things used, one per line.
    public var thingsRaw: String = ""
    public var chimeEnabled: Bool = true
    public var isPaused: Bool = false
    public var pausedSince: Date?
    /// Calendar days that were paused through, comma separated. They take no petal.
    public var skippedDayKeysRaw: String = ""
    /// The day the current mandala began.
    public var startedOn: Date = Date()
    /// 1 for the first 48 days. Completed mandalas = mandalaNumber − 1 − restartedMandalas.
    public var mandalaNumber: Int = 1
    /// Mandalas the person chose to begin again before finishing. They don't count as completed.
    public var restartedMandalas: Int = 0
    /// The day the person answered "Not today" (a day key), so that day closes early. Empty when never.
    public var notTodayKey: String = ""
    /// "How did it feel?" every day (true) or about once a week (false, the v2 default).
    public var feelingEveryDay: Bool = false
    /// The mandala for which the Day 30 reveal has been shown.
    public var day30SeenMandala: Int = 0
    /// The mandala for which the finishing screen has been shown.
    public var completeSeenMandala: Int = 0
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    public init(id: UUID = UUID(), name: String, kind: RoutineKind, hour: Int, minute: Int, durationMinutes: Int = 10,
                place: String, things: [String], chimeEnabled: Bool = true, startedOn: Date = Date()) {
        self.id = id
        self.name = name
        self.kindRaw = kind.rawValue
        self.hour = hour
        self.minute = minute
        self.durationMinutes = max(Mandala.minimumMinutes, durationMinutes)
        self.place = place
        self.thingsRaw = things.joined(separator: "\n")
        self.chimeEnabled = chimeEnabled
        self.startedOn = startedOn
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    public var things: [String] {
        get { thingsRaw.split(separator: "\n").map(String.init) }
        set { thingsRaw = newValue.joined(separator: "\n") }
    }
    public var skippedDayKeys: [String] {
        get { skippedDayKeysRaw.split(separator: ",").map(String.init) }
        set { skippedDayKeysRaw = newValue.joined(separator: ",") }
    }
}

/// One per routine per day kept. A day counts once, however many times Done is tapped.
@Model
public final class Reflection {
    public var id: UUID = UUID()
    public var routineID: UUID = UUID()
    /// The calendar day it belongs to, as yyyy-MM-dd.
    public var dayKey: String = ""
    public var mandalaNumber: Int = 1
    /// scattered | steady | absorbed. Nil when Done was tapped and the question has not been answered yet.
    public var feelingRaw: String?
    public var note: String?
    public var recordedAt: Date = Date()

    public init(routineID: UUID, dayKey: String, mandalaNumber: Int, feeling: Feeling?, note: String?) {
        self.id = UUID()
        self.routineID = routineID
        self.dayKey = dayKey
        self.mandalaNumber = mandalaNumber
        self.feelingRaw = feeling?.rawValue
        self.note = note
        self.recordedAt = Date()
    }
}

// MARK: - Day keys

public enum DayKey {
    public static func key(_ date: Date, _ cal: Calendar = .current) -> String {
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
    public static func date(_ key: String, _ cal: Calendar = .current) -> Date? {
        let p = key.split(separator: "-").compactMap { Int($0) }
        guard p.count == 3 else { return nil }
        return cal.date(from: DateComponents(year: p[0], month: p[1], day: p[2]))
    }
}
