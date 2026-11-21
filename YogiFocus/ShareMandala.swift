import AVKit
import Photos
import StoreKit
import SwiftUI
import YogiKit

// v2 items 6, 29 and 32: share a completed mandala, share and rate Yogi Focus, and Apple's rating prompt on day 30.

enum AppLinks {
    static let store = URL(string: "https://apps.apple.com/app/id6835473975")!
    static let review = URL(string: "https://apps.apple.com/app/id6835473975?action=write-review")!
    static let shareMessage = "I've been keeping a small daily routine with Yogi Focus. It's free."
    /// Instagram Stories needs a Facebook App ID (free, from developers.facebook.com). Until one is set here,
    /// the Instagram Stories button stays hidden and Instagram is reached through More.
    static let facebookAppID: String? = nil
}

/// "Share Yogi Focus" and "Rate Yogi Focus": links the person may choose to tap, never a prompt (item 32).
struct ShareAndRate: View {
    var body: some View {
        HStack(spacing: 22) {
            ShareLink(item: AppLinks.store, message: Text(AppLinks.shareMessage)) {
                Label { Text("Share Yogi Focus") } icon: { YFIcon("heart", size: 18) }
            }
            Link(destination: AppLinks.review) {
                Label { Text("Rate Yogi Focus") } icon: { YFIcon("lotus", size: 18) }
            }
        }
        .font(YFFont.body(15, .medium))
        .foregroundStyle(YF.ink)
        .tint(YF.ink)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

/// Apple's own rating prompt, once, as the person first sees their mandala on day 30 (item 29). Never after a miss
/// is mentioned, never on any other day. Apple decides whether it actually appears.
enum RatingMoment {
    @MainActor static var pending = false
    private static let key = "yf.rating.asked"

    @MainActor static func askIfDue(_ request: RequestReviewAction) {
        guard pending else { return }
        pending = false
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            request()
        }
    }
}

/// "Share your mandala" (`V2-Share-Making`, `V2-Share-Video`).
struct ShareMandalaScreen: View {
    let routineID: UUID
    let routineName: String
    let mandalaNumber: Int
    let onBack: () -> Void

    @StateObject private var maker: MandalaClipMaker
    @State private var mode = 0
    @State private var player: AVPlayer?
    @State private var saved: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(routineID: UUID, routineName: String, mandalaNumber: Int, onBack: @escaping () -> Void) {
        self.routineID = routineID; self.routineName = routineName; self.mandalaNumber = mandalaNumber; self.onBack = onBack
        _maker = StateObject(wrappedValue: MandalaClipMaker(routineID: routineID, routineName: routineName, mandalaNumber: mandalaNumber))
    }

    private var ready: Bool { mode == 1 ? maker.image != nil : maker.videoURL != nil }
    private var instagramAvailable: Bool {
        AppLinks.facebookAppID != nil && UIApplication.shared.canOpenURL(URL(string: "instagram-stories://share")!)
    }

    var body: some View {
        Screen {
            TopBar(back: onBack)
            H1("Share your mandala", size: 32).padding(.top, 6)
            Segmented(options: ["Video", "Image"], selection: $mode).padding(.top, 14)
            preview
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
            Para(ready ? "Made on your phone. Nothing is sent anywhere until you choose where it goes."
                       : "A few seconds. It's made here on your phone, from your own mandala.",
                 size: 14.5, color: YF.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            if let saved {
                Para(saved, size: 14, color: YF.textGreen).frame(maxWidth: .infinity).padding(.top, 4)
            }
        } bottom: {
            if instagramAvailable {
                PrimaryButton("Instagram Stories", enabled: ready, action: shareToStories)
            }
            HStack(spacing: 10) {
                GhostButton(mode == 1 ? "Save image" : "Save video", action: save).disabled(!ready).opacity(ready ? 1 : 0.5)
                moreButton
            }
        }
        .task { await maker.make() }
        .onChange(of: maker.videoURL) { _, url in startPlayer(url) }
        .onDisappear { player?.pause() }
    }

    @ViewBuilder private var preview: some View {
        let card = RoundedRectangle(cornerRadius: 26, style: .continuous)
        ZStack {
            if mode == 0, let player, !reduceMotion {
                VideoPlayer(player: player)
                    .disabled(true)
            } else if let image = maker.image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Clip.bgOut
            }
            if mode == 0 && maker.videoURL == nil {
                Color.black.opacity(0.28)
                VStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(.white.opacity(0.3), lineWidth: 5)
                        Circle().trim(from: 0, to: maker.progress)
                            .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                    .frame(width: 54, height: 54)
                    Text(maker.failed ? "The video couldn't be made. The image is ready." : "Making your video")
                        .font(YFFont.body(15, .semibold)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
            }
        }
        .aspectRatio(9 / 16, contentMode: .fit)
        .frame(maxWidth: 240)
        .clipShape(card)
        .overlay(card.strokeBorder(YF.line, lineWidth: 1))
        .accessibilityElement()
        .accessibilityLabel("Your mandala: \(routineName), \(Clip.kicker(mandalaNumber)), \(Mandala.days) days")
    }

    @ViewBuilder private var moreButton: some View {
        if mode == 1, let image = maker.image {
            ShareLink(item: Image(uiImage: image), preview: SharePreview("My mandala", image: Image(uiImage: image))) { moreLabel }
        } else if let url = maker.videoURL {
            ShareLink(item: url) { moreLabel }
        } else {
            moreLabel.opacity(0.5)
        }
    }

    private var moreLabel: some View {
        Text("More").font(YFFont.body(16, .semibold)).foregroundStyle(YF.textGreen)
            .frame(maxWidth: .infinity, minHeight: 48)
            .overlay(Capsule().strokeBorder(YF.textGreen, lineWidth: 1.5))
    }

    private func startPlayer(_ url: URL?) {
        guard let url else { return }
        let p = AVPlayer(url: url)
        p.isMuted = true
        p.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p.currentItem, queue: .main) { _ in
            p.seek(to: .zero); p.play()
        }
        player = p
        p.play()
    }

    private func shareToStories() {
        guard let appID = AppLinks.facebookAppID else { return }
        var item: [String: Any] = [:]
        if mode == 0, let url = maker.videoURL, let data = try? Data(contentsOf: url) {
            item["com.instagram.sharedSticker.backgroundVideo"] = data
        } else if let png = maker.image?.pngData() {
            item["com.instagram.sharedSticker.backgroundImage"] = png
        }
        guard !item.isEmpty, let url = URL(string: "instagram-stories://share?source_application=\(appID)") else { return }
        UIPasteboard.general.setItems([item], options: [.expirationDate: Date().addingTimeInterval(300)])
        UIApplication.shared.open(url)
    }

    /// Add-only access to Photos, asked only now.
    private func save() {
        Task { @MainActor in
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                saved = "Photos access is off. You can allow it in Settings."
                return
            }
            let isImage = mode == 1
            let url = maker.videoURL, image = maker.image
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    if isImage, let image { PHAssetChangeRequest.creationRequestForAsset(from: image) }
                    else if let url { PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) }
                }
                saved = "Saved to Photos."
            } catch {
                saved = "That didn't save. Try again."
            }
        }
    }
}
