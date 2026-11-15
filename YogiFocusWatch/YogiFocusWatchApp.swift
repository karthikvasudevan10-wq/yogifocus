import SwiftUI
import YogiKit

@main
struct YogiFocusWatchApp: App {
    @State private var model: WatchModel

    init() {
        // The watch keeps its own store, mirrored to the same private iCloud database as the phone.
        YogiStore.cloudSyncEnabled = true
        YFFont.register()
        _ = YogiStore.shared
        WatchLink.shared.start()
        _model = State(initialValue: WatchModel())
    }

    var body: some Scene {
        WindowGroup { WatchRootView(model: model) }
    }
}
