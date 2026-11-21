import SwiftUI
import AVFoundation
import UserNotifications
import YogiKit

// v2 item 24: open straight into the practice. A ring, the yogi and the time left; a chime at the end marks the
// day kept. Finishing early still counts. The timer keeps running if the phone is locked or the app is left.

/// The running timer, kept in the app group so it survives the app being closed.
struct RunningTimer: Codable, Equatable {
    var routineID: UUID
    var start: Date
    var minutes: Int
    var twoMinute: Bool
    var end: Date { start.addingTimeInterval(Double(minutes) * 60) }

    private static let key = "yf.timer.running"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: YogiStore.appGroup) }
    static let endNotificationID = "yf.timer.end"

    static var current: RunningTimer? {
        get { defaults?.data(forKey: key).flatMap { try? JSONDecoder().decode(RunningTimer.self, from: $0) } }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) { defaults?.set(data, forKey: key) }
            else { defaults?.removeObject(forKey: key) }
        }
    }

    /// A timer that ran out while the app was away counts the day when the app next opens.
    @MainActor static func settleIfFinished(now: Date = Date()) {
        guard let t = current, now >= t.end else { return }
        current = nil
        YogiStore.shared.markKept(t.routineID, on: t.start, twoMinute: t.twoMinute)
        Nudges.cancelToday(t.routineID, now: t.start)
    }
}

enum Chime {
    nonisolated(unsafe) private static var player: AVAudioPlayer?
    static let fileName = "chime.wav"

    static func play() {
        guard let url = Bundle.main.url(forResource: "chime", withExtension: "wav") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

/// The practice timer (`V2-Timer`, `V2-Timer-Two`).
struct PracticeTimerScreen: View {
    @Environment(AppModel.self) private var model
    @Environment(\.duoPose) private var pose
    @Environment(\.scenePhase) private var scenePhase
    let routineID: UUID
    let twoMinute: Bool
    /// Called once the day is kept, by the chime or by Finish now.
    let onKept: () -> Void

    @State private var timer: RunningTimer?
    @State private var finished = false

    private var routine: RoutineSnapshot? { model.routine(routineID) }
    private var minutes: Int { twoMinute ? 2 : (routine?.durationMinutes ?? Mandala.minimumMinutes) }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let left = max(0, (timer?.end ?? ctx.date.addingTimeInterval(Double(minutes) * 60)).timeIntervalSince(ctx.date))
            Group {
                if pose == .phone { phoneBody(left: left) } else { duoBody(left: left) }
            }
            .onChange(of: left <= 0) { _, done in if done { finish(early: false) } }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: begin)
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, let t = timer, Date() >= t.end { finish(early: false) }
        }
    }

    // MARK: Running

    private func begin() {
        UIApplication.shared.isIdleTimerDisabled = true
        if let t = RunningTimer.current, t.routineID == routineID, t.twoMinute == twoMinute, Date() < t.end {
            timer = t
            return
        }
        let t = RunningTimer(routineID: routineID, start: Date(), minutes: minutes, twoMinute: twoMinute)
        RunningTimer.current = t
        timer = t
        scheduleEnd(t)
    }

    /// If the app is not on screen when the time is up, a notification rings the chime instead.
    private func scheduleEnd(_ t: RunningTimer) {
        guard let r = routine else { return }
        let content = UNMutableNotificationContent()
        content.title = "That's today, kept."
        content.body = "\(r.name). Forever was never the job. Today was, and you did it."
        content.sound = r.chimeEnabled ? UNNotificationSound(named: UNNotificationSoundName(Chime.fileName)) : nil
        content.interruptionLevel = .timeSensitive
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, t.end.timeIntervalSinceNow), repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: RunningTimer.endNotificationID, content: content, trigger: trigger))
    }

    private func finish(early: Bool) {
        guard !finished, let t = timer else { return }
        finished = true
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [RunningTimer.endNotificationID])
        RunningTimer.current = nil
        if !early, routine?.chimeEnabled ?? true { Chime.play() }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        YogiStore.shared.markKept(t.routineID, on: t.start, twoMinute: t.twoMinute)
        Nudges.cancelToday(t.routineID, now: t.start)
        model.refresh()
        onKept()
    }

    // MARK: Layout

    private func clock(_ left: TimeInterval) -> String {
        let s = Int(left.rounded(.up))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private var header: some View {
        HStack {
            Text(twoMinute ? "\(routine?.name ?? "") · two minutes" : "\(routine?.name ?? "") · \(routine?.placeInSentence ?? "")")
                .font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen)
                .lineLimit(1).minimumScaleFactor(0.8)
            Spacer(minLength: 8)
            if routine?.chimeEnabled ?? true {
                Label("Chime at the end", systemImage: "music.note")
                    .font(YFFont.body(13.5, .medium)).foregroundStyle(YF.muted)
                    .labelStyle(.titleAndIcon)
            }
        }
        .frame(minHeight: 44)
    }

    private func ring(_ left: TimeInterval, size: CGFloat) -> some View {
        let fraction = left / max(1, Double(minutes) * 60)
        return ZStack {
            Circle().fill(YF.softGreen.opacity(0.45))
            Circle().stroke(YF.petalClosed, lineWidth: 12)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(YF.mid, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: fraction)
            YogiView(.calm).padding(size * 0.2)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private func time(_ left: TimeInterval) -> some View {
        VStack(spacing: 2) {
            Text(clock(left)).font(YFFont.heading(64)).monospacedDigit().foregroundStyle(YF.ink)
                .contentTransition(.numericText(countsDown: true))
                .padding(.bottom, -14)
            Text("of \(Words.length(minutes))").font(YFFont.body(15)).foregroundStyle(YF.muted)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(left.rounded(.up)) / 60) minutes and \(Int(left.rounded(.up)) % 60) seconds left of \(Words.length(minutes))")
    }

    private var line: some View {
        Text("Sit, breathe and let the timer keep the time.")
            .font(YFFont.body(17)).foregroundStyle(YF.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var finishNow: some View {
        VStack(spacing: 10) {
            Button { finish(early: true) } label: {
                Text("Finish now").font(YFFont.body(16, .semibold)).foregroundStyle(YF.ink)
                    .padding(.horizontal, 26).frame(minHeight: 50)
                    .background(YF.paper, in: Capsule())
                    .overlay(Capsule().strokeBorder(YF.line, lineWidth: 1))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressStyle())
            Text("Finishing early still counts as kept.").font(YFFont.body(13.5)).foregroundStyle(YF.muted)
        }
        .frame(maxWidth: .infinity)
    }

    private func phoneBody(left: TimeInterval) -> some View {
        Screen(scrolls: false) {
            header
            Spacer(minLength: 20)
            ring(left, size: 276).frame(maxWidth: .infinity)
            time(left).frame(maxWidth: .infinity).padding(.top, 26)
            line.frame(maxWidth: .infinity).padding(.top, 16)
            Spacer(minLength: 20)
        } bottom: {
            finishNow
        }
    }

    private func duoBody(left: TimeInterval) -> some View {
        DuoPage {
            ring(left, size: 260).frame(maxWidth: .infinity)
        } trail: {
            header
            time(left).padding(.top, 20)
            line.padding(.top, 14)
        } bottom: {
            finishNow
        }
    }
}

/// Where a tapped notification asks the app to go, held until the screens are ready to read it.
@MainActor enum PendingOpen {
    static var timer: UUID?
    static let notice = Notification.Name("yf.openTimer")
}
