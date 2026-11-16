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
        Nudges.handle(action: response.actionIdentifier, userInfo: response.notification.request.content.userInfo)
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
        store.removeDuplicates()
        let fresh = store.snapshots()
        if fresh != routines { routines = fresh }
        hasOnboarded = store.hasOnboarded
        cloudHasRoutines = store.cloudHasRoutines
        Nudges.reschedule(fresh)
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
            if phase == .active { model.refresh() }
        }
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
                // The widget is set up once, with the first routine. Later routines go straight back to Today.
                if model.routines.count > 1 { path.removeAll() } else { path.append(.widgetSetup(id)) }
            }
        case .widgetSetup(let id): WidgetSetupScreen(routineID: id, onBack: back) { path.removeAll() }
        case .reflect(let id): ReflectScreen(routineID: id, onBack: back) { path.append(.kept(id)) }
        case .kept(let id): KeptScreen(routineID: id) { path.removeAll() }
        case .routines:
            RoutinesScreen(onBack: back, onEdit: { path.append(.edit($0)) }, onAdd: { path.append(.choose) })
        case .edit(let id): RoutineEditScreen(routineID: id, onBack: back)
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
