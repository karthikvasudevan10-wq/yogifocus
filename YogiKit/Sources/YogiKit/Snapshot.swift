import Foundation

public enum PetalState: String, Codable, Sendable {
    case practised, missed, today, toCome
}

public enum DayMoment: Equatable, Sendable {
    case paused
    case kept
    /// The person said "Not today": the day is closed and no more nudges come.
    case notToday
    case earlier
    case soon(minutes: Int)
    case itsTime
    case passed
}

/// A routine and its current mandala as plain values. Everything the app, widget and watch show is derived from this.
public struct RoutineSnapshot: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var kind: String
    public var hour: Int
    public var minute: Int
    public var durationMinutes: Int
    public var place: String
    public var things: [String]
    public var chimeEnabled: Bool
    public var isPaused: Bool
    public var pausedSince: Date?
    public var skippedDayKeys: [String]
    public var startedOn: Date
    public var mandalaNumber: Int
    public var day30SeenMandala: Int
    public var completeSeenMandala: Int
    /// Mandalas begun again before finishing. Optional so snapshots from 1.0 (watch, widget cache) still decode.
    public var restartedMandalas: Int?
    /// The day key of the last "Not today" answer. Optional so 1.0 snapshots still decode.
    public var notTodayKey: String?
    /// Ask how it felt every day. Optional so 1.0 snapshots still decode; nil means about once a week.
    public var feelingEveryDay: Bool?
    public var createdAt: Date
    public var updatedAt: Date
    /// Days kept in the current mandala.
    public var keptDayKeys: [String]
    /// Days kept in the last few days of any mandala (so "kept today" survives starting a new mandala).
    public var recentKeptDayKeys: [String]
    /// dayKey → feeling, for the current mandala.
    public var feelings: [String: String]

    public init(id: UUID = UUID(), name: String, kind: String = RoutineKind.meditate.rawValue, hour: Int = 7, minute: Int = 0,
                durationMinutes: Int = 10, place: String = "the balcony", things: [String] = ["Yoga mat", "Grey shawl"],
                chimeEnabled: Bool = true, isPaused: Bool = false, pausedSince: Date? = nil, skippedDayKeys: [String] = [],
                startedOn: Date = Date(), mandalaNumber: Int = 1, day30SeenMandala: Int = 0, completeSeenMandala: Int = 0,
                createdAt: Date = Date(), updatedAt: Date = Date(), keptDayKeys: [String] = [], recentKeptDayKeys: [String] = [],
                feelings: [String: String] = [:], restartedMandalas: Int = 0, notTodayKey: String? = nil,
                feelingEveryDay: Bool? = nil) {
        self.id = id; self.name = name; self.kind = kind; self.hour = hour; self.minute = minute
        self.durationMinutes = durationMinutes; self.place = place; self.things = things
        self.chimeEnabled = chimeEnabled; self.isPaused = isPaused; self.pausedSince = pausedSince
        self.skippedDayKeys = skippedDayKeys; self.startedOn = startedOn; self.mandalaNumber = mandalaNumber
        self.day30SeenMandala = day30SeenMandala; self.completeSeenMandala = completeSeenMandala
        self.createdAt = createdAt; self.updatedAt = updatedAt
        self.keptDayKeys = keptDayKeys; self.recentKeptDayKeys = recentKeptDayKeys; self.feelings = feelings
        self.restartedMandalas = restartedMandalas
        self.notTodayKey = notTodayKey
        self.feelingEveryDay = feelingEveryDay
    }

    public var routineKind: RoutineKind { RoutineKind(rawValue: kind) ?? .own }
    private var cal: Calendar { .current }

    // MARK: Days

    /// The day of the mandala on a date: 1 on the day it began. Paused days are not counted. 0 before it begins.
    public func dayNumber(on date: Date) -> Int {
        let start = cal.startOfDay(for: startedOn)
        var end = cal.startOfDay(for: date)
        if isPaused, let since = pausedSince { end = min(end, cal.startOfDay(for: since)) }
        guard end >= start else { return 0 }
        let span = (cal.dateComponents([.day], from: start, to: end).day ?? 0) + 1
        let startKey = DayKey.key(start), endKey = DayKey.key(end)
        let skipped = Set(skippedDayKeys).filter { $0 >= startKey && $0 <= endKey }.count
        return max(0, span - skipped)
    }

    /// The calendar-day keys of mandala days 1…count, in order.
    public func dayKeys(count: Int) -> [String] {
        guard count > 0 else { return [] }
        let skipped = Set(skippedDayKeys)
        var out: [String] = []
        var d = cal.startOfDay(for: startedOn)
        var guardCount = 0
        while out.count < count && guardCount < 2000 {
            let k = DayKey.key(d)
            if !skipped.contains(k) { out.append(k) }
            d = cal.date(byAdding: .day, value: 1, to: d) ?? d.addingTimeInterval(86400)
            guardCount += 1
        }
        return out
    }

    public func phase(on date: Date) -> Phase { Phase.forDay(max(1, dayNumber(on: date))) }

    public func keptToday(_ date: Date) -> Bool {
        let k = DayKey.key(date)
        return keptDayKeys.contains(k) || recentKeptDayKeys.contains(k)
    }

    /// The 48 petals on a date. Today's petal is not counted as missed until the day is over.
    public func petals(on date: Date) -> [PetalState] {
        let n = min(dayNumber(on: date), Mandala.days)
        let keys = dayKeys(count: n)
        let kept = Set(keptDayKeys)
        let todayKey = DayKey.key(date)
        return (1...Mandala.days).map { i in
            guard i <= keys.count else { return .toCome }
            let k = keys[i - 1]
            if kept.contains(k) { return k == todayKey ? .today : .practised }
            return k == todayKey ? .toCome : .missed
        }
    }

    public func practisedCount(on date: Date) -> Int {
        petals(on: date).filter { $0 == .practised || $0 == .today }.count
    }

    public func missedCount(on date: Date) -> Int {
        petals(on: date).filter { $0 == .missed }.count
    }

    /// Rule 4: nothing that shows progress may appear before day 30.
    public func showsProgress(on date: Date) -> Bool {
        dayNumber(on: date) >= Mandala.progressHiddenUntilDay
    }

    /// The mandala completes on day 48 whatever the count.
    public func isComplete(on date: Date) -> Bool {
        let n = dayNumber(on: date)
        return n > Mandala.days || (n == Mandala.days && keptToday(date))
    }

    public func needsDay30Reveal(on date: Date) -> Bool {
        showsProgress(on: date) && day30SeenMandala < mandalaNumber && !isComplete(on: date)
    }

    public func needsCompleteScreen(on date: Date) -> Bool {
        isComplete(on: date) && completeSeenMandala < mandalaNumber
    }

    public var completedMandalas: Int { max(0, mandalaNumber - 1 - (restartedMandalas ?? 0)) }

    // MARK: The hour

    public func hourDate(on date: Date) -> Date {
        cal.date(bySettingHour: hour, minute: minute, second: 0, of: cal.startOfDay(for: date)) ?? date
    }

    public func moment(at now: Date) -> DayMoment {
        if isPaused { return .paused }
        if keptToday(now) || dayNumber(on: now) < 1 { return .kept }
        if saidNotToday(now) { return .notToday }
        let h = hourDate(on: now)
        let before = h.addingTimeInterval(-Double(Mandala.nudgeBeforeMinutes) * 60)
        if now < before { return .earlier }
        if now < h { return .soon(minutes: max(1, Int((h.timeIntervalSince(now) / 60).rounded(.up)))) }
        if now < h.addingTimeInterval(Double(Mandala.hourWindowMinutes) * 60) { return .itsTime }
        return .passed
    }

    /// v2 item 25: "How did it feel?" is asked about once a week, unless the person chose every day.
    /// It is asked on a kept day when no answer has been given in the six days before it.
    public func asksFeeling(on date: Date) -> Bool {
        if feelingEveryDay == true { return true }
        guard let last = lastFeelingDay(before: date) else { return true }
        return Self.daysBetween(last, date) >= 7
    }

    /// The latest day in this mandala with an answer, before the given day.
    public func lastFeelingDay(before date: Date) -> Date? {
        let key = DayKey.key(date)
        return feelings.keys.filter { $0 < key }.max().flatMap { DayKey.date($0) }
    }

    public static func daysBetween(_ a: Date, _ b: Date) -> Int {
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: a), to: cal.startOfDay(for: b)).day ?? 0
    }

    /// "Not today" was the answer for this day, and it hasn't been kept since. A kept day always wins.
    public func saidNotToday(_ now: Date) -> Bool {
        notTodayKey == DayKey.key(now) && !keptToday(now)
    }

    // MARK: Words

    public var timeText: String { Words.time(hour: hour, minute: minute) }
    public var bareTimeText: String { Words.time(hour: hour, minute: minute, suffix: false) }
    public var placeTitle: String { Words.capitalisedFirst(place) }
    public var placeInSentence: String { Words.lowercasedFirst(place) }
    public var thingsList: String { Words.list(things) }
    public var whenText: String { routineKind.isTimed ? "\(timeText), for \(Words.length(durationMinutes))" : timeText }
    public var whenShort: String { routineKind.isTimed ? "\(timeText), \(Words.length(durationMinutes))" : timeText }
    /// For the watch: "7:00 am, 10 min".
    public var whenCompact: String { routineKind.isTimed ? "\(timeText), \(lengthShort)" : timeText }
    public var lengthText: String { Words.length(durationMinutes) }
    public var lengthShort: String { Words.length(durationMinutes, short: true) }

    /// "Each day at 7:00 am, I go to the balcony with my yoga mat and grey shawl, and meditate for ten minutes."
    public var sentence: String {
        Words.routineSentence(name: name, kind: routineKind, time: timeText, place: place, things: things, minutes: durationMinutes)
    }
}

public enum Words {
    public static func time(hour: Int, minute: Int, suffix: Bool = true) -> String {
        let h12 = hour % 12 == 0 ? 12 : hour % 12
        let base = String(format: "%d:%02d", h12, minute)
        return suffix ? base + (hour < 12 ? " am" : " pm") : base
    }

    public static func capitalisedFirst(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespaces)
        return t.prefix(1).uppercased() + t.dropFirst()
    }

    public static func lowercasedFirst(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespaces)
        // Leave acronyms and proper-looking words alone ("TV room").
        if t.count > 1, t.dropFirst().prefix(1).uppercased() == String(t.dropFirst().prefix(1)), t.dropFirst().prefix(1) != " " { return t }
        return t.prefix(1).lowercased() + t.dropFirst()
    }

    /// "Yoga mat, grey shawl"
    public static func list(_ things: [String]) -> String {
        let t = things.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard let first = t.first else { return "" }
        return ([capitalisedFirst(first)] + t.dropFirst().map(lowercasedFirst)).joined(separator: ", ")
    }

    /// "my yoga mat and grey shawl"
    public static func withThings(_ things: [String]) -> String {
        let t = things.map { lowercasedFirst($0) }.filter { !$0.isEmpty }
        switch t.count {
        case 0: return ""
        case 1: return "my \(t[0])"
        default: return "my " + t.dropLast().joined(separator: ", ") + " and " + t[t.count - 1]
        }
    }

    public static func spelled(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .spellOut
        f.locale = Locale(identifier: "en_GB")
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    public static func routineSentence(name: String, kind: RoutineKind, time: String, place: String, things: [String], minutes: Int) -> String {
        let p = lowercasedFirst(place)
        if kind == .eat {
            // Cutting sugar is one small action at one moment, not a stretch of time:
            // "Each day at 7:00 am, at the kitchen table, I have my tea without sugar."
            var s = "Each day at \(time),"
            if !p.isEmpty { s += " at \(p)," }
            let w = withThings(things)
            s += w.isEmpty ? " I skip the sugar." : " I have \(w) without sugar."
            return s
        }
        let verb = kind.verb ?? lowercasedFirst(name.isEmpty ? "practise" : name)
        var s = "Each day at \(time), I go"
        s += p.isEmpty ? " to my place" : " to \(p)"
        let w = withThings(things)
        if !w.isEmpty { s += " with \(w)," }
        s += " and \(verb) for \(spokenLength(minutes))."
        return s
    }

    /// "10 minutes", "45 minutes", "1 hour", "1 hour 30 minutes". Short: "10 min", "1 hr".
    public static func length(_ minutes: Int, short: Bool = false) -> String {
        let h = minutes / 60, m = minutes % 60
        let hs = short ? "\(h) hr" : (h == 1 ? "1 hour" : "\(h) hours")
        let ms = short ? "\(m) min" : "\(m) minutes"
        if h == 0 { return ms }
        return m == 0 ? hs : "\(hs) \(ms)"
    }

    /// For sentences: "ten minutes", "forty-five minutes", "an hour".
    public static func spokenLength(_ minutes: Int) -> String {
        if minutes == 60 { return "an hour" }
        if minutes % 60 == 0 { return "\(spelled(minutes / 60)) hours" }
        return "\(spelled(minutes)) minutes"
    }

    public static func petalsOpen(_ n: Int) -> String { n == 1 ? "1 petal open" : "\(n) petals open" }

    public static func fullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "EEEE d MMMM"
        return f.string(from: date)
    }
}

// MARK: - Choosing which routine to show

public enum Routines {
    public static func sorted(_ all: [RoutineSnapshot]) -> [RoutineSnapshot] {
        all.sorted { ($0.hour, $0.minute, $0.createdAt) < ($1.hour, $1.minute, $1.createdAt) }
    }

    /// With more than one routine in a day, the widget and Today show the next one not yet kept.
    public static func current(_ all: [RoutineSnapshot], at now: Date) -> RoutineSnapshot? {
        let list = sorted(all)
        let active = list.filter { !$0.isPaused }
        // A routine answered today (kept, or "Not today") steps aside for one still waiting.
        if let next = active.first(where: { ![.kept, .notToday].contains($0.moment(at: now)) }) { return next }
        return active.last ?? list.first
    }
}
