import Foundation
import SwiftData
import CoreData
#if canImport(WidgetKit)
import WidgetKit
#endif

public extension Notification.Name {
    /// Posted (on any thread) whenever routines or reflections change, locally or from iCloud.
    static let yogiStoreDidChange = Notification.Name("YogiStoreDidChange")
}

/// The single source of truth, shared by the app, its widget and (through iCloud) the person's other devices.
///
/// - The SwiftData store lives in the App Group container so the widget can read it and record Done.
/// - In the app and the watch app it is mirrored to the person's private iCloud database (CloudKit), so
///   routines, days kept, feelings, notes and mandala numbers follow them to a new phone.
/// - A few small flags also go to iCloud key-value storage, which arrives sooner than the full database
///   on a fresh install.
public final class YogiStore: @unchecked Sendable {
    public static let appGroup = "group.karthikvasudevan.yogifocus"
    public static let cloudContainer = "iCloud.karthikvasudevan.yogifocus"

    /// Set to true by the app and the watch app before first use. Extensions leave it false:
    /// they read and write the same store and the app does the syncing.
    public static var cloudSyncEnabled = false

    public static let shared = YogiStore()

    public let container: ModelContainer
    public private(set) var isCloudBacked = false
    private var observers: [NSObjectProtocol] = []

    private init() {
        let schema = Schema([Routine.self, Reflection.self])
        let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroup)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        let url = base.appendingPathComponent("YogiFocus.store")

        var made: ModelContainer?
        if Self.cloudSyncEnabled, ProcessInfo.processInfo.environment["YF_NO_CLOUD"] == nil {
            let cloud = ModelConfiguration("YogiFocus", schema: schema, url: url, cloudKitDatabase: .private(Self.cloudContainer))
            made = try? ModelContainer(for: schema, configurations: cloud)
            isCloudBacked = made != nil
        }
        if made == nil {
            let local = ModelConfiguration("YogiFocus", schema: schema, url: url, cloudKitDatabase: .none)
            made = try? ModelContainer(for: schema, configurations: local)
        }
        if made == nil {
            let memory = ModelConfiguration("YogiFocus", schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            made = try? ModelContainer(for: schema, configurations: memory)
        }
        container = made!

        // Changes written by the widget, or imported from iCloud, arrive as remote-change notifications.
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { _ in
            NotificationCenter.default.post(name: .yogiStoreDidChange, object: nil)
        })
        observers.append(nc.addObserver(forName: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, queue: nil) { _ in
            NotificationCenter.default.post(name: .yogiStoreDidChange, object: nil)
        })
        observers.append(nc.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil, queue: nil) { _ in
            NotificationCenter.default.post(name: .yogiStoreDidChange, object: nil)
        })
        if Self.cloudSyncEnabled { NSUbiquitousKeyValueStore.default.synchronize() }
    }

    private func context() -> ModelContext {
        let c = ModelContext(container)
        c.autosaveEnabled = false
        return c
    }

    private func finish(_ c: ModelContext, notify: Bool = true) {
        try? c.save()
        guard notify else { return }
        publishSummary()
        NotificationCenter.default.post(name: .yogiStoreDidChange, object: nil)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    // MARK: Reading

    public func snapshots(now: Date = Date()) -> [RoutineSnapshot] {
        let c = context()
        let routines = (try? c.fetch(FetchDescriptor<Routine>())) ?? []
        let reflections = (try? c.fetch(FetchDescriptor<Reflection>())) ?? []
        let recentFloor = DayKey.key(now.addingTimeInterval(-3 * 86400))
        var seen = Set<UUID>()
        var out: [RoutineSnapshot] = []
        // CloudKit cannot enforce uniqueness, so the newest copy of a routine wins.
        for r in routines.sorted(by: { $0.updatedAt > $1.updatedAt }) where seen.insert(r.id).inserted {
            let mine = reflections.filter { $0.routineID == r.id }
            let current = mine.filter { $0.mandalaNumber == r.mandalaNumber }
            var feelings: [String: String] = [:]
            for f in current { if let raw = f.feelingRaw { feelings[f.dayKey] = raw } }
            out.append(RoutineSnapshot(
                id: r.id, name: r.name, kind: r.kindRaw, hour: r.hour, minute: r.minute, durationMinutes: r.durationMinutes,
                place: r.place, things: r.things, chimeEnabled: r.chimeEnabled, isPaused: r.isPaused, pausedSince: r.pausedSince,
                skippedDayKeys: r.skippedDayKeys, startedOn: r.startedOn, mandalaNumber: r.mandalaNumber,
                day30SeenMandala: r.day30SeenMandala, completeSeenMandala: r.completeSeenMandala,
                createdAt: r.createdAt, updatedAt: r.updatedAt,
                keptDayKeys: Array(Set(current.map(\.dayKey))).sorted(),
                recentKeptDayKeys: Array(Set(mine.map(\.dayKey).filter { $0 >= recentFloor })).sorted(),
                feelings: feelings, restartedMandalas: r.restartedMandalas))
        }
        return Routines.sorted(out)
    }

    public func note(routineID: UUID, on date: Date = Date()) -> String? {
        let key = DayKey.key(date)
        return reflections(context(), routineID: routineID).first { $0.dayKey == key }?.note
    }

    /// Days by feeling for the current mandala. No row is better or worse than another.
    public func feelingCounts(for snapshot: RoutineSnapshot) -> [Feeling: Int] {
        var out: [Feeling: Int] = [:]
        for (_, raw) in snapshot.feelings { if let f = Feeling(rawValue: raw) { out[f, default: 0] += 1 } }
        return out
    }

    private func routine(_ c: ModelContext, _ id: UUID) -> Routine? {
        let all = (try? c.fetch(FetchDescriptor<Routine>(predicate: #Predicate { $0.id == id }))) ?? []
        return all.max { $0.updatedAt < $1.updatedAt }
    }

    private func reflections(_ c: ModelContext, routineID: UUID) -> [Reflection] {
        (try? c.fetch(FetchDescriptor<Reflection>(predicate: #Predicate { $0.routineID == routineID }))) ?? []
    }

    // MARK: Routines

    @discardableResult
    public func addRoutine(name: String, kind: RoutineKind, hour: Int, minute: Int, durationMinutes: Int = Mandala.minimumMinutes,
                           place: String, things: [String], chimeEnabled: Bool = true, now: Date = Date()) -> UUID {
        let c = context()
        let r = Routine(name: name, kind: kind, hour: hour, minute: minute, durationMinutes: durationMinutes,
                        place: place, things: things, chimeEnabled: chimeEnabled, startedOn: Calendar.current.startOfDay(for: now))
        c.insert(r)
        finish(c)
        return r.id
    }

    public func updateRoutine(_ id: UUID, _ change: (Routine) -> Void) {
        let c = context()
        guard let r = routine(c, id) else { return }
        change(r)
        r.durationMinutes = max(Mandala.minimumMinutes, r.durationMinutes)
        r.updatedAt = Date()
        finish(c)
    }

    /// Pausing silences the widget and nudges and loses nothing: paused days take no petal.
    public func setPaused(_ id: UUID, _ paused: Bool, now: Date = Date()) {
        updateRoutine(id) { r in
            guard r.isPaused != paused else { return }
            let cal = Calendar.current
            if paused {
                r.isPaused = true
                r.pausedSince = now
            } else {
                var skipped = Set(r.skippedDayKeys)
                if let since = r.pausedSince {
                    var d = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: since)) ?? now
                    let today = cal.startOfDay(for: now)
                    while d < today {
                        skipped.insert(DayKey.key(d))
                        d = cal.date(byAdding: .day, value: 1, to: d) ?? today
                    }
                }
                r.skippedDayKeys = skipped.sorted()
                r.isPaused = false
                r.pausedSince = nil
            }
        }
    }

    public func removeRoutine(_ id: UUID) {
        let c = context()
        let all = (try? c.fetch(FetchDescriptor<Routine>(predicate: #Predicate { $0.id == id }))) ?? []
        all.forEach { c.delete($0) }
        reflections(c, routineID: id).forEach { c.delete($0) }
        finish(c)
    }

    public func markDay30Seen(_ id: UUID) {
        updateRoutine(id) { $0.day30SeenMandala = $0.mandalaNumber }
    }

    public func markCompleteSeen(_ id: UUID) {
        updateRoutine(id) { $0.completeSeenMandala = $0.mandalaNumber }
    }

    /// Begins the next 48 days. If today is already kept, the new mandala starts tomorrow.
    public func beginNewMandala(_ id: UUID, now: Date = Date()) {
        let keptToday = snapshots(now: now).first { $0.id == id }?.keptToday(now) ?? false
        updateRoutine(id) { r in
            let cal = Calendar.current
            let today = cal.startOfDay(for: now)
            r.completeSeenMandala = r.mandalaNumber
            r.mandalaNumber += 1
            r.startedOn = keptToday ? (cal.date(byAdding: .day, value: 1, to: today) ?? today) : today
            r.skippedDayKeys = []
            r.isPaused = false
            r.pausedSince = nil
        }
    }

    /// The person's own choice to begin a routine again: a new mandala from today, at day one.
    /// Earlier days stay in the history under their old mandala. Never called by the app on its own (design rule 10).
    /// If today is already kept, that day moves into the new mandala as its first petal.
    public func restartMandala(_ id: UUID, now: Date = Date()) {
        let c = context()
        guard let r = routine(c, id) else { return }
        let old = r.mandalaNumber
        let todayKey = DayKey.key(now)
        r.restartedMandalas += 1
        r.mandalaNumber = old + 1
        r.completeSeenMandala = old
        r.startedOn = Calendar.current.startOfDay(for: now)
        r.skippedDayKeys = []
        r.isPaused = false
        r.pausedSince = nil
        r.updatedAt = now
        reflections(c, routineID: id).filter { $0.dayKey == todayKey && $0.mandalaNumber == old }.forEach { $0.mandalaNumber = old + 1 }
        finish(c)
    }

    // MARK: Days kept

    /// Records that the routine was kept on a day. A day counts once; a later call only adds the feeling or note.
    public func markKept(_ routineID: UUID, on date: Date = Date(), feeling: Feeling? = nil, note: String? = nil) {
        let c = context()
        guard let r = routine(c, routineID) else { return }
        let key = DayKey.key(date)
        let existing = reflections(c, routineID: routineID).filter { $0.dayKey == key }.sorted { $0.recordedAt < $1.recordedAt }
        if let first = existing.first {
            if let feeling { first.feelingRaw = feeling.rawValue }
            if let note, !note.isEmpty { first.note = note }
            existing.dropFirst().forEach { c.delete($0) }
        } else {
            c.insert(Reflection(routineID: routineID, dayKey: key, mandalaNumber: r.mandalaNumber, feeling: feeling,
                                note: (note?.isEmpty ?? true) ? nil : note))
        }
        finish(c)
    }

    // MARK: Merging (Apple Watch ⇄ iPhone, and tidying after iCloud imports)

    /// Applies routines received from the paired device. The newer copy of each routine wins.
    public func merge(_ incoming: [RoutineSnapshot], removingMissing: Bool) {
        let c = context()
        let existing = (try? c.fetch(FetchDescriptor<Routine>())) ?? []
        let ids = Set(incoming.map(\.id))
        for s in incoming {
            let mine = existing.filter { $0.id == s.id }.max { $0.updatedAt < $1.updatedAt }
            let r: Routine
            if let mine {
                r = mine
                if mine.updatedAt > s.updatedAt { mergeKept(c, s); continue }
            } else {
                r = Routine(id: s.id, name: s.name, kind: s.routineKind, hour: s.hour, minute: s.minute, place: s.place, things: s.things)
                c.insert(r)
            }
            r.name = s.name; r.kindRaw = s.kind; r.hour = s.hour; r.minute = s.minute; r.durationMinutes = s.durationMinutes
            r.place = s.place; r.things = s.things; r.chimeEnabled = s.chimeEnabled; r.isPaused = s.isPaused
            r.pausedSince = s.pausedSince; r.skippedDayKeys = s.skippedDayKeys; r.startedOn = s.startedOn
            r.mandalaNumber = s.mandalaNumber; r.day30SeenMandala = s.day30SeenMandala
            r.completeSeenMandala = s.completeSeenMandala; r.restartedMandalas = s.restartedMandalas ?? r.restartedMandalas; r.createdAt = s.createdAt; r.updatedAt = s.updatedAt
            mergeKept(c, s)
        }
        if removingMissing {
            for r in existing where !ids.contains(r.id) {
                reflections(c, routineID: r.id).forEach { c.delete($0) }
                c.delete(r)
            }
        }
        finish(c)
    }

    private func mergeKept(_ c: ModelContext, _ s: RoutineSnapshot) {
        let have = reflections(c, routineID: s.id)
        for key in s.keptDayKeys {
            let feeling = s.feelings[key].flatMap(Feeling.init(rawValue:))
            if let r = have.first(where: { $0.dayKey == key }) {
                if r.feelingRaw == nil, let feeling { r.feelingRaw = feeling.rawValue }
            } else {
                c.insert(Reflection(routineID: s.id, dayKey: key, mandalaNumber: s.mandalaNumber, feeling: feeling, note: nil))
            }
        }
    }

    /// iCloud can deliver a second copy of the same record (for example a day kept on the watch and on the phone
    /// before either had synced). Keep one of each.
    public func removeDuplicates() {
        let c = context()
        var changed = false
        let routines = (try? c.fetch(FetchDescriptor<Routine>())) ?? []
        for (_, group) in Dictionary(grouping: routines, by: \.id) where group.count > 1 {
            group.sorted { $0.updatedAt > $1.updatedAt }.dropFirst().forEach { c.delete($0); changed = true }
        }
        let reflections = (try? c.fetch(FetchDescriptor<Reflection>())) ?? []
        for (_, group) in Dictionary(grouping: reflections, by: { "\($0.routineID.uuidString)|\($0.dayKey)" }) where group.count > 1 {
            let ordered = group.sorted { ($0.feelingRaw != nil ? 0 : 1, $0.recordedAt) < ($1.feelingRaw != nil ? 0 : 1, $1.recordedAt) }
            let keep = ordered[0]
            for extra in ordered.dropFirst() {
                if keep.note == nil { keep.note = extra.note }
                c.delete(extra); changed = true
            }
        }
        if changed { finish(c) }
    }

    // MARK: iCloud key-value summary

    private static let kvHasRoutines = "hasRoutines"
    private static let kvSummary = "summary"
    private static let kvOnboarded = "onboarded"

    /// What iCloud says this person already has, readable before the full database has arrived on a new phone.
    public struct CloudSummary: Codable, Sendable {
        public var routines: Int
        public var mandalasCompleted: Int
        public var daysKept: Int
        public var updatedAt: Date
    }

    private func publishSummary() {
        guard Self.cloudSyncEnabled else { return }
        let c = context()
        let routines = (try? c.fetch(FetchDescriptor<Routine>())) ?? []
        let kept = (try? c.fetchCount(FetchDescriptor<Reflection>())) ?? 0
        let unique = Dictionary(grouping: routines, by: \.id).compactMap { $0.value.max { $0.updatedAt < $1.updatedAt } }
        let summary = CloudSummary(routines: unique.count,
                                   mandalasCompleted: unique.reduce(0) { $0 + max(0, $1.mandalaNumber - 1 - $1.restartedMandalas) },
                                   daysKept: kept, updatedAt: Date())
        let kv = NSUbiquitousKeyValueStore.default
        kv.set(!unique.isEmpty, forKey: Self.kvHasRoutines)
        if let data = try? JSONEncoder().encode(summary) { kv.set(data, forKey: Self.kvSummary) }
        kv.synchronize()
    }

    public var cloudSummary: CloudSummary? {
        guard Self.cloudSyncEnabled, let data = NSUbiquitousKeyValueStore.default.data(forKey: Self.kvSummary) else { return nil }
        return try? JSONDecoder().decode(CloudSummary.self, from: data)
    }

    /// True when iCloud knows of routines that have not reached this device yet.
    public var cloudHasRoutines: Bool {
        Self.cloudSyncEnabled && NSUbiquitousKeyValueStore.default.bool(forKey: Self.kvHasRoutines)
    }

    /// Whether the introduction has been completed, on this device or another one signed in to the same iCloud.
    public var hasOnboarded: Bool {
        get {
            UserDefaults(suiteName: Self.appGroup)?.bool(forKey: Self.kvOnboarded) == true
                || (Self.cloudSyncEnabled && NSUbiquitousKeyValueStore.default.bool(forKey: Self.kvOnboarded))
        }
        set {
            UserDefaults(suiteName: Self.appGroup)?.set(newValue, forKey: Self.kvOnboarded)
            if Self.cloudSyncEnabled {
                NSUbiquitousKeyValueStore.default.set(newValue, forKey: Self.kvOnboarded)
                NSUbiquitousKeyValueStore.default.synchronize()
            }
        }
    }
}
