import Foundation
import WatchConnectivity
import YogiKit

/// The watch side of the iPhone ⇄ Apple Watch link.
/// Routines arrive from the phone (setup stays on the phone); days kept on the wrist go back.
/// This works without iCloud. With iCloud on, both devices also sync through the private database.
final class WatchLink: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = WatchLink()
    private var lastApplied: Date?

    func start() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Sent at once when the phone is reachable; otherwise queued and delivered later.
    func sendKept(_ routineID: UUID, dayKey: String, feeling: Feeling?, twoMinute: Bool = false) {
        var info: [String: Any] = ["kept": routineID.uuidString, "dayKey": dayKey]
        if twoMinute { info["twoMinute"] = true }
        if let feeling { info["feeling"] = feeling.rawValue }
        send(info)
    }

    func sendNotToday(_ routineID: UUID, dayKey: String) {
        send(["notToday": routineID.uuidString, "dayKey": dayKey])
    }

    private func send(_ info: [String: Any]) {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(info, replyHandler: nil) { _ in session.transferUserInfo(info) }
        } else {
            session.transferUserInfo(info)
        }
    }

    private func apply(_ context: [String: Any]) {
        guard let data = context["routines"] as? Data,
              let routines = try? JSONDecoder().decode([RoutineSnapshot].self, from: data) else { return }
        let sentAt = context["sentAt"] as? Date
        if let sentAt, let lastApplied, sentAt <= lastApplied { return }
        lastApplied = sentAt ?? Date()
        // Removing a routine that the phone no longer lists is only safe when iCloud is not also syncing this
        // store: a phone that has not finished restoring from iCloud must never cause a deletion that then
        // travels back up to iCloud.
        let iCloudActive = YogiStore.shared.isCloudBacked && FileManager.default.ubiquityIdentityToken != nil
        YogiStore.shared.merge(routines, removingMissing: !routines.isEmpty && !iCloudActive)
        // The merge posts .yogiStoreDidChange, which refreshes the screen. Nothing is sent back: no echo.
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        let context = session.receivedApplicationContext
        if !context.isEmpty { apply(context) }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        apply(applicationContext)
    }
}
