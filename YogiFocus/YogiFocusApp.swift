import SwiftUI
import UserNotifications
import YogiKit

@main
struct YogiFocusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var model: AppModel

    init() {
        // The app owns iCloud syncing. Routines, days kept, feelings and mandala numbers follow the person to a new phone.
        YogiStore.cloudSyncEnabled = true
        #if DEBUG
        // YF_NO_CLOUD=1 runs as a brand-new install that has never seen iCloud, for recording the introduction.
        // Nothing in iCloud is read, written or deleted.
        if ProcessInfo.processInfo.environment["YF_NO_CLOUD"] != nil { YogiStore.cloudSyncEnabled = false }
        #endif
        YFFont.register()
        #if DEBUG
        DebugSeed.applyIfAsked()
        #endif
        _model = State(initialValue: AppModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Nudges.registerCategories()
        // Silent pushes tell the app that iCloud has changes from another device.
        application.registerForRemoteNotifications()
        PhoneLink.shared.start()
        return true
    }

    /// The Duo follows the device into every orientation; other iPhones stay in portrait.
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        DuoOrientation.supported
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        NotificationCenter.default.post(name: .yogiStoreDidChange, object: nil)
        return .newData
    }

    /// Done, or a feeling, tapped on a notification (on the phone or mirrored to the watch).
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let content = response.notification.request.content
        // Tapping "It's time" (or its Start button) opens the practice timer, already running (v2 item 24).
        let opensTimer = response.actionIdentifier == Nudges.startAction
            || (response.actionIdentifier == UNNotificationDefaultActionIdentifier
                && [Nudges.hourCategory, Nudges.hourTwoCategory].contains(content.categoryIdentifier))
        if opensTimer, let raw = content.userInfo[Nudges.routineKey] as? String, let id = UUID(uuidString: raw) {
            await MainActor.run { PendingOpen.open(id, twoMinute: false) }
            return
        }
        Nudges.handle(action: response.actionIdentifier, userInfo: content.userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

/// What the screens read. Everything shown is derived from the routine snapshots and the current time.
@Observable @MainActor
final class AppModel {
    var routines: [RoutineSnapshot] = []
    var hasOnboarded = false
    var cloudHasRoutines = false
    private var observer: NSObjectProtocol?
    private var pending: Task<Void, Never>?

    init() {
        refresh()
        observer = NotificationCenter.default.addObserver(forName: .yogiStoreDidChange, object: nil, queue: nil) { [weak self] _ in
            Task { @MainActor in self?.scheduleRefresh() }
        }
    }

    private func scheduleRefresh() {
        pending?.cancel()
        pending = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            self?.refresh()
        }
    }

    func refresh() {
        let store = YogiStore.shared
        RunningTimer.settleIfFinished()
        store.removeDuplicates()
        let fresh = store.snapshots()
        if fresh != routines { routines = fresh }
        hasOnboarded = store.hasOnboarded
        cloudHasRoutines = store.cloudHasRoutines
        Nudges.reschedule(fresh)
        YogiShortcuts.updateAppShortcutParameters()
        if #available(iOS 26.0, *) { Task { await GentleAlarm.reschedule(fresh) } }
    }

    func routine(_ id: UUID) -> RoutineSnapshot? { routines.first { $0.id == id } }

    /// Adding a routine is always allowed. Until a first mandala is complete, Yogi Focus gently suggests waiting.
    var suggestsWaitingToAdd: Bool {
        !routines.isEmpty && !routines.contains { $0.completedMandalas >= 1 || $0.isComplete(on: Date()) }
    }
}

enum Route: Hashable {
    case ideaToday, ideaSame, ideaMandala, howHelps
    case choose
    case anchor(RoutineKind)
    case widgetSetup(UUID)
    case reflect(UUID)
    case kept(UUID)
    case notToday(UUID)
    case twoMinute(UUID, editing: Bool)
    case timer(UUID, twoMinute: Bool)
    case routines
    case edit(UUID)
    case mandala(UUID)
}

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase
    @State private var path: [Route] = []
    @State private var startFresh = false

    var body: some View {
        DuoPoseReader {
            NavigationStack(path: $path) {
                root
                    .navigationDestination(for: Route.self) { destination($0) }
            }
        }
        .tint(YF.textGreen)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.refresh(); openPendingTimer() }
        }
        .onReceive(NotificationCenter.default.publisher(for: PendingOpen.notice)) { _ in openPendingTimer() }
        .onAppear(perform: resumeOrOpenTimer)
        #if DEBUG
        .onAppear { if let r = DebugSeed.route(model.routines.first?.id) { path = r } }
        .modifier(DebugFrame())
        #endif
    }

    @ViewBuilder private var root: some View {
        if !model.routines.isEmpty {
            TodayScreen(path: $path)
        } else if model.cloudHasRoutines && !startFresh {
            RestoringScreen { startFresh = true }
        } else if model.hasOnboarded {
            ChooseRoutineScreen(onBack: nil) { path.append(.anchor($0)) }
        } else {
            WelcomeScreen { path.append(.ideaToday) }
        }
    }

    /// A tapped "It's time" notification opens the timer, already running (v2 item 24).
    private func openPendingTimer() {
        // Start on the gentle alarm leaves its routine in the app group.
        if PendingOpen.timer == nil, let id = PendingTimer.take() { PendingOpen.timer = id; PendingOpen.twoMinute = false }
        guard let id = PendingOpen.timer, model.routine(id) != nil else { return }
        PendingOpen.timer = nil
        guard model.routine(id)?.routineKind.isTimed == true, model.routine(id)?.keptToday(Date()) == false else { return }
        path = [.timer(id, twoMinute: PendingOpen.twoMinute)]
    }

    /// A timer still running when the app was closed is picked up where it is.
    private func resumeOrOpenTimer() {
        if let t = RunningTimer.current, Date() < t.end, model.routine(t.routineID) != nil {
            path = [.timer(t.routineID, twoMinute: t.twoMinute)]
        } else {
            openPendingTimer()
        }
    }

    /// The widget is set up once, with the first routine. Later routines go straight back to Today.
    private func afterSetup(_ id: UUID) {
        if model.routines.count > 1 { path.removeAll() } else { path.append(.widgetSetup(id)) }
    }

    @ViewBuilder private func destination(_ route: Route) -> some View {
        let back = { if !path.isEmpty { path.removeLast() } }
        switch route {
        case .ideaToday: IdeaTodayScreen(onBack: back) { path.append(.ideaSame) }
        case .ideaSame: IdeaSameScreen(onBack: back) { path.append(.ideaMandala) }
        case .ideaMandala: IdeaMandalaScreen(onBack: back) { path.append(.howHelps) }
        case .howHelps: HowHelpsScreen(onBack: back) { path.append(.choose) }
        case .choose: ChooseRoutineScreen(onBack: back) { path.append(.anchor($0)) }
        case .anchor(let kind):
            AnchorScreen(kind: kind, onBack: back) { id in
                YogiStore.shared.hasOnboarded = true
                model.refresh()
                // v2 item 10: then the two-minute version for a harder day (not for Cut Sugar, which has no length).
                if kind.isTimed { path.append(.twoMinute(id, editing: false)) } else { afterSetup(id) }
            }
        case .twoMinute(let id, let editing):
            TwoMinuteScreen(routineID: id, editing: editing, onBack: back) {
                if editing { back() } else { afterSetup(id) }
            }
        case .widgetSetup(let id): WidgetSetupScreen(routineID: id, onBack: back) { path.removeAll() }
        case .reflect(let id): ReflectScreen(routineID: id, onBack: back) { path.append(.kept(id)) }
        case .kept(let id): KeptScreen(routineID: id) { path.removeAll() }
        case .notToday(let id): NotTodayScreen(routineID: id) { path.removeAll() }
        case .timer(let id, let twoMinute):
            PracticeTimerScreen(routineID: id, twoMinute: twoMinute) {
                // Most days straight to kept; about once a week, "How did it feel?" first (v2 item 25).
                let asks = !twoMinute && (model.routine(id)?.asksFeeling(on: Date()) ?? false)
                if !path.isEmpty { path.removeLast() }
                path.append(asks ? .reflect(id) : .kept(id))
            }
        case .routines:
            RoutinesScreen(onBack: back, onEdit: { path.append(.edit($0)) }, onAdd: { path.append(.choose) })
        case .edit(let id): RoutineEditScreen(routineID: id, onBack: back, onTwoMinute: { path.append(.twoMinute(id, editing: true)) })
        case .mandala(let id): MandalaScreen(routineID: id, onBack: back) { path.append(.edit(id)) }
        }
    }
}

/// A new phone: iCloud says there are routines, and the database is still arriving.
struct RestoringScreen: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    let onStartFresh: () -> Void
    @ViewBuilder var phoneBody: some View {
        Screen {
            Spacer().frame(height: 60)
            YogiView(.calm).frame(width: 180, height: 180).levitate().frame(maxWidth: .infinity)
            H1("Welcome back.", size: 38).padding(.top, 24)
            Para("Your routine is on its way from iCloud. It can take a minute or two on a new phone.").padding(.top, 8)
            Para("Nothing is lost.", size: 15, color: YF.muted).padding(.top, 14)
        } bottom: {
            GhostButton("Start fresh instead", action: onStartFresh)
        }
    }
}

extension RestoringScreen {
    var duoBody: some View {
        DuoPage {
            YogiView(.calm).frame(width: 180, height: 180).levitate().frame(maxWidth: .infinity)
        } trail: {
            H1("Welcome back.", size: 38)
            Para("Your routine is on its way from iCloud. It can take a minute or two on a new phone.").padding(.top, 8)
            Para("Nothing is lost.", size: 15, color: YF.muted).padding(.top, 14)
        } bottom: {
            GhostButton("Start fresh instead", action: onStartFresh)
        }
    }
}
