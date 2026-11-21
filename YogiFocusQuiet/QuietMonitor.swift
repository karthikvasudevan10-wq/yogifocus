import DeviceActivity
import Foundation
import YogiKit

/// Turns the quiet on five minutes before the routine and off when its length is up (v2 item 3).
/// Runs by itself at those times, even if Yogi Focus isn't open.
final class QuietMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        if let id = QuietPractice.routineID(from: activity) { QuietPractice.begin(id) }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        if let id = QuietPractice.routineID(from: activity) { QuietPractice.clear(id) }
    }
}
