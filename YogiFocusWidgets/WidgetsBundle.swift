import SwiftUI
import WidgetKit
import AppIntents
import YogiKit

/// The Home Screen widget: the main reminder. Small, medium and large.
///
/// What WidgetKit allows, and so what this does:
/// - Nothing loops. The only motion is the change of content when Done is tapped (about one second).
/// - Done runs an App Intent; the widget then reloads.
/// - Each change through the day (twenty minutes before, the hour, the hour passing, the reminder line)
///   is a timeline entry. The system may show an entry a little late; the notification makes the hour exact.
struct YogiEntry: TimelineEntry {
    let date: Date
    let model: WidgetModel
    var relevance: TimelineEntryRelevance? {
        switch model.state {
        case .itsTime: return TimelineEntryRelevance(score: 100, duration: 30 * 60)
        case .soon: return TimelineEntryRelevance(score: 80, duration: 20 * 60)
        case .passed: return TimelineEntryRelevance(score: 40)
        default: return TimelineEntryRelevance(score: 10)
        }
    }
}

struct YogiProvider: TimelineProvider {
    func placeholder(in context: Context) -> YogiEntry { YogiEntry(date: .now, model: .sample) }

    func getSnapshot(in context: Context, completion: @escaping (YogiEntry) -> Void) {
        if context.isPreview { completion(YogiEntry(date: .now, model: .sample)); return }
        completion(YogiEntry(date: .now, model: WidgetModel.make(for: YogiStore.shared.snapshots(), at: .now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<YogiEntry>) -> Void) {
        let now = Date()
        let routines = YogiStore.shared.snapshots(now: now)
        let entries = WidgetModel.timelineDates(for: routines, from: now).prefix(60).map {
            YogiEntry(date: $0, model: WidgetModel.make(for: routines, at: $0))
        }
        // The widget refreshes every day even if the app is never opened, so it keeps the week of nudges topped up.
        Nudges.reschedule(routines, now: now)
        completion(Timeline(entries: entries.isEmpty ? [YogiEntry(date: now, model: .empty)] : entries, policy: .atEnd))
    }
}

/// Done, tapped on the widget. A day counts once, however many times it is tapped.
struct DoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Done"
    static var description = IntentDescription("Marks today's routine as kept.")
    static var isDiscoverable = false

    @Parameter(title: "Routine") var routineID: String

    init() {}
    init(routineID: UUID) { self.routineID = routineID.uuidString }

    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: routineID) {
            YogiStore.shared.markKept(id)
            Nudges.cancelToday(id)
        }
        return .result()
    }
}

/// "Not today", tapped on the widget: closes the day and stops its nudges.
struct NotTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Not today"
    static var description = IntentDescription("Closes today for this routine, with no more reminders today.")
    static var isDiscoverable = false

    @Parameter(title: "Routine") var routineID: String

    init() {}
    init(routineID: UUID) { self.routineID = routineID.uuidString }

    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: routineID) {
            YogiStore.shared.markNotToday(id)
            Nudges.cancelToday(id)
        }
        return .result()
    }
}

/// "Two minutes", tapped on the large widget: the day counts as kept with the two-minute version.
struct TwoMinutesIntent: AppIntent {
    static var title: LocalizedStringResource = "Two minutes"
    static var description = IntentDescription("Marks today's routine as kept with its two-minute version.")
    static var isDiscoverable = false

    @Parameter(title: "Routine") var routineID: String

    init() {}
    init(routineID: UUID) { self.routineID = routineID.uuidString }

    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: routineID) {
            YogiStore.shared.markKept(id, twoMinute: true)
            Nudges.cancelToday(id)
        }
        return .result()
    }
}

struct YogiWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: YogiEntry

    private var size: YogiWidgetSize {
        switch family {
        case .systemMedium: return .medium
        case .systemLarge: return .large
        default: return .small
        }
    }

    var body: some View {
        YogiWidgetContent(model: entry.model, size: size) { answer, label in
            if let id = entry.model.routineID {
                switch answer {
                case .done: Button(intent: DoneIntent(routineID: id)) { label }.buttonStyle(.plain)
                case .notToday: Button(intent: NotTodayIntent(routineID: id)) { label }.buttonStyle(.plain)
                case .twoMinutes: Button(intent: TwoMinutesIntent(routineID: id)) { label }.buttonStyle(.plain)
                }
            } else {
                label
            }
        }
        .containerBackground(for: .widget) {
            YogiWidgetBackground(model: entry.model, size: size)
        }
    }
}

struct YogiFocusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "YogiFocusWidget", provider: YogiProvider()) { entry in
            YogiWidgetView(entry: entry)
        }
        .configurationDisplayName("Yogi Focus")
        .description("Today's routine: the hour, the place and what to bring. Done at the hour.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

@main
struct YogiWidgetsBundle: WidgetBundle {
    var body: some Widget { YogiFocusWidget() }
}
