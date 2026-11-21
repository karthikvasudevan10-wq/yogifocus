import AppIntents
import SwiftUI
import YogiKit

// v2 item 14: Siri, Spotlight, Shortcuts and the Action button, with nothing to set up.
// Before day 30 nothing here gives a count (design rule 4); nothing ever mentions a miss.

/// A routine, as Siri and Shortcuts see it.
struct RoutineEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Routine"
    static let defaultQuery = RoutineQuery()
    let id: UUID
    let name: String
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }

    init(_ r: RoutineSnapshot) { id = r.id; name = r.name }
}

struct RoutineQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [RoutineEntity] {
        YogiStore.shared.snapshots().filter { identifiers.contains($0.id) }.map(RoutineEntity.init)
    }
    func suggestedEntities() async throws -> [RoutineEntity] {
        YogiStore.shared.snapshots().map(RoutineEntity.init)
    }
}

/// The routine asked about, or the one Today would show.
private func resolve(_ entity: RoutineEntity?) -> RoutineSnapshot? {
    let all = YogiStore.shared.snapshots()
    if let entity { return all.first { $0.id == entity.id } }
    return Routines.current(all, at: Date())
}

struct NoRoutine: Error, CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource { "Open Yogi Focus to choose your routine." }
}

/// "Start Meditate": opens the practice timer, already running.
struct StartRoutineIntent: AppIntent {
    static let title: LocalizedStringResource = "Start"
    static let description = IntentDescription("Opens the practice timer for a routine, already running.")
    static let openAppWhenRun = true

    @Parameter(title: "Routine") var routine: RoutineEntity?

    @MainActor func perform() async throws -> some IntentResult {
        guard let r = resolve(routine) else { throw NoRoutine() }
        PendingOpen.open(r.id, twoMinute: false)
        return .result()
    }
}

/// "Two minutes": opens the two-minute timer.
struct TwoMinutesRoutineIntent: AppIntent {
    static let title: LocalizedStringResource = "Two minutes"
    static let description = IntentDescription("Opens the two-minute version of a routine.")
    static let openAppWhenRun = true

    @Parameter(title: "Routine") var routine: RoutineEntity?

    @MainActor func perform() async throws -> some IntentResult {
        guard let r = resolve(routine) else { throw NoRoutine() }
        PendingOpen.open(r.id, twoMinute: r.twoMinute != nil)
        return .result()
    }
}

/// "I've done my meditation": today counts as kept, without opening the app.
struct MarkKeptIntent: AppIntent {
    static let title: LocalizedStringResource = "Done"
    static let description = IntentDescription("Marks today's routine as kept.")

    @Parameter(title: "Routine") var routine: RoutineEntity?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let r = resolve(routine) else { throw NoRoutine() }
        let now = Date()
        if r.keptToday(now) { return .result(dialog: "That's already kept today. Only tomorrow is next.") }
        YogiStore.shared.markKept(r.id, on: now)
        Nudges.cancelToday(r.id, now: now)
        return .result(dialog: "That's today, kept. Only tomorrow is next.")
    }
}

/// "How am I doing with Meditate?": kindness and time before day 30, petals from day 30. Never a miss.
struct HowAmIDoingIntent: AppIntent {
    static let title: LocalizedStringResource = "How am I doing?"
    static let description = IntentDescription("A word about today's routine.")

    @Parameter(title: "Routine") var routine: RoutineEntity?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let r = resolve(routine) else { throw NoRoutine() }
        return .result(dialog: IntentDialog(stringLiteral: Self.answer(r, now: Date())))
    }

    static func answer(_ r: RoutineSnapshot, now: Date) -> String {
        let anchor = "\(r.timeText), \(r.placeInSentence)."
        let petals = r.showsProgress(on: now) ? Words.petalsOpen(r.practisedCount(on: now)) + ". " : ""
        switch r.moment(at: now) {
        case .paused: return "\(r.name) is paused. Nothing is lost."
        case .kept: return petals + "That's today, kept. Only tomorrow is next."
        case .notToday: return "Tomorrow is a new day. " + anchor
        default: return (petals.isEmpty ? "One day at a time. " : petals) + "Today is still yours. " + anchor
        }
    }
}

struct YogiShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartRoutineIntent(), phrases: [
            "Start \(\.$routine) in \(.applicationName)",
            "Start my practice in \(.applicationName)",
        ], shortTitle: "Start", systemImageName: "play.circle")
        AppShortcut(intent: TwoMinutesRoutineIntent(), phrases: [
            "Just two minutes of \(\.$routine) in \(.applicationName)",
            "Just two minutes in \(.applicationName)",
        ], shortTitle: "Two minutes", systemImageName: "leaf")
        AppShortcut(intent: MarkKeptIntent(), phrases: [
            "I've done \(\.$routine) in \(.applicationName)",
            "I've done my practice in \(.applicationName)",
            "Mark today kept in \(.applicationName)",
        ], shortTitle: "Done", systemImageName: "checkmark.circle")
        AppShortcut(intent: HowAmIDoingIntent(), phrases: [
            "How am I doing with \(\.$routine) in \(.applicationName)",
            "How am I doing in \(.applicationName)",
        ], shortTitle: "How am I doing?", systemImageName: "sparkles")
    }
}
