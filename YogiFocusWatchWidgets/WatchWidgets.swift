import SwiftUI
import WidgetKit
import AppIntents
import YogiKit

// The watch face carries the same thing as the iPhone Home Screen widget: today's routine, state for state,
// and Done at the hour. Complications are always still. Nothing shows a count before day 30 or a missed day.

struct WatchDoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Done"
    static var description = IntentDescription("Marks today's routine as kept.")

    @Parameter(title: "Routine") var routineID: String

    init() {}
    init(routineID: UUID) { self.routineID = routineID.uuidString }

    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: routineID) {
            YogiStore.shared.markKept(id)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct YogiEntry: TimelineEntry {
    let date: Date
    let model: WidgetModel
    var relevance: TimelineEntryRelevance? {
        let score: Float
        switch model.state {
        case .itsTime: score = 100
        case .soon: score = 80
        case .passed: score = 50
        case .earlier:
            let near = model.hourDate.map { $0.timeIntervalSince(date) < 3600 } ?? false
            score = near ? 30 : 10
        case .kept: score = 5
        case .paused, .empty: score = 0
        }
        return TimelineEntryRelevance(score: score)
    }
}

struct YogiProvider: TimelineProvider {
    func placeholder(in context: Context) -> YogiEntry { YogiEntry(date: .now, model: .sample) }

    func getSnapshot(in context: Context, completion: @escaping (YogiEntry) -> Void) {
        if context.isPreview { completion(YogiEntry(date: .now, model: .sample)); return }
        let now = Date()
        completion(YogiEntry(date: now, model: WidgetModel.make(for: YogiStore.shared.snapshots(now: now), at: now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<YogiEntry>) -> Void) {
        let now = Date()
        let all = YogiStore.shared.snapshots(now: now)
        let dates = WidgetModel.timelineDates(for: all, from: now).prefix(40)
        var entries = dates.map { YogiEntry(date: $0, model: WidgetModel.make(for: all, at: $0)) }
        if entries.isEmpty { entries = [YogiEntry(date: now, model: WidgetModel.make(for: all, at: now))] }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

/// The small lotus glyph. All petals open as decoration; the person's real petals only after day 30, once kept.
struct LotusGlyph: View {
    let model: WidgetModel
    var separator: Color = YF.watchRaised
    var body: some View {
        LotusView(petals: model.petals ?? .allOpen, style: LotusStyle(closed: Color(hex: 0x233327), closedEdge: Color(hex: 0x34483A), separator: separator))
            .widgetAccentable()
    }
}

struct YogiAccessoryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: YogiEntry
    private var model: WidgetModel { entry.model }
    private var inlineText: String {
        model.routineID == nil ? "Yogi Focus" : "\(model.timeText) \(model.name)"
    }

    var body: some View {
        switch family {
        case .accessoryRectangular: rectangular
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                LotusGlyph(model: model).padding(5)
            }
            .accessibilityLabel(inlineText)
        case .accessoryCorner:
            LotusGlyph(model: model, separator: .black)
                .widgetLabel(inlineText)
                .accessibilityLabel(inlineText)
        default:
            Text(inlineText)
        }
    }

    private var rectangular: some View {
        HStack(spacing: 10) {
            if !model.showsDone {
                LotusGlyph(model: model).frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    if model.dot { Circle().fill(YF.saffron).frame(width: 7, height: 7) }
                    Text(model.label).font(YFFont.fixedBody(12, .semibold)).foregroundStyle(YF.sunny).widgetAccentable()
                }
                Text(model.name).font(YFFont.fixedHeading(19)).foregroundStyle(.white)
                Text(model.small1).font(YFFont.fixedBody(12.5)).foregroundStyle(YF.watchSecondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            if model.showsDone, let id = model.routineID {
                Button(intent: WatchDoneIntent(routineID: id)) {
                    Text("Done")
                        .font(YFFont.fixedBody(14, .semibold))
                        .foregroundStyle(YF.onAccent)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 36)
                        .background(YF.leaf, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct YogiFocusComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "YogiFocusWatchWidget", provider: YogiProvider()) { entry in
            YogiAccessoryView(entry: entry)
                .containerBackground(YF.watchRaised, for: .widget)
        }
        .configurationDisplayName("Yogi Focus")
        .description("Today's routine, and Done at the hour.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline, .accessoryCorner])
    }
}

@main
struct YogiWatchWidgetsBundle: WidgetBundle {
    init() { YFFont.register() }
    var body: some Widget { YogiFocusComplication() }
}
