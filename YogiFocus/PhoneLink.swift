import Foundation
import WatchConnectivity
import YogiKit

/// The iPhone side of the iPhone ⇄ Apple Watch link.
/// Sends every routine (with its days kept) to the watch whenever something changes, and records days kept on the wrist.
/// Call `PhoneLink.shared.start()` once at launch, after `YogiStore.cloudSyncEnabled` is set.
final class PhoneLink: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = PhoneLink()
    private var observer: NSObjectProtocol?
    private var pending: DispatchWorkItem?
    private let queue = DispatchQueue(label: "yogifocus.phonelink")

    func start() {
        guard WCSession.isSupported(), observer == nil else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        observer = NotificationCenter.default.addObserver(forName: .yogiStoreDidChange, object: nil, queue: nil) { [weak self] _ in
            self?.scheduleSend()
        }
        scheduleSend()
    }

    /// Debounced: a burst of changes becomes one update about a second later.
    private func scheduleSend() {
        queue.async { [weak self] in
            guard let self else { return }
            self.pending?.cancel()
            let work = DispatchWorkItem { [weak self] in self?.send() }
            self.pending = work
            self.queue.asyncAfter(deadline: .now() + 1, execute: work)
        }
    }

    private func send() {
        let session = WCSession.default
        guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else { return }
        guard let data = try? JSONEncoder().encode(YogiStore.shared.snapshots()) else { return }
        try? session.updateApplicationContext(["routines": data, "sentAt": Date()])
    }

    private func applyKept(_ info: [String: Any]) {
        guard let raw = info["kept"] as? String, let id = UUID(uuidString: raw) else { return }
        let day = (info["dayKey"] as? String).flatMap { DayKey.date($0) } ?? Date()
        let feeling = (info["feeling"] as? String).flatMap(Feeling.init(rawValue:))
        YogiStore.shared.markKept(id, on: day, feeling: feeling)
        Nudges.cancelToday(id, now: day)
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated { scheduleSend() }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // The person switched watches: connect to the new one.
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        scheduleSend()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        applyKept(userInfo)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        applyKept(message)
    }
}
