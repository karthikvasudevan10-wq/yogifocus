import AVFoundation
import SwiftUI
import YogiKit

// v2 item 6: the shareable mandala video, made on the phone (`handoff/design/mandala-video/`).
// 12 s, 30 fps, 1080 × 1920. Every frame is a pure function of `t`, like `render(t)` in the reference `clip.html`.
// It shows only the routine's name and the mandala's number: no place, things, times, feelings or misses.

enum Clip {
    static let width: CGFloat = 1080, height: CGFloat = 1920
    static let fps = 30, seconds = 12.0
    static var frames: Int { Int(seconds) * fps }
    static let centre = CGPoint(x: 540, y: 930)
    static let lotusScale: CGFloat = 3.0
    // Timeline (seconds).
    static let open0 = 1.1, step = 0.1, openDuration = 0.5
    static var full: Double { open0 + 47 * step + openDuration }

    static let bgIn = Color(hex: 0x8FE356), bgOut = Color(hex: 0x3DBB45)
    static let white = Color.white, creams = Color(hex: 0xFFF6D6), cream = Color(hex: 0xFFE680), saffron = Color(hex: 0xFF7A1A)
    static let ringColours = [white, creams, cream]

    static func clamp(_ x: Double) -> Double { max(0, min(1, x)) }
    static func ease(_ x: Double) -> Double { 1 - pow(1 - clamp(x), 3) }
    /// Ease out with a slight overshoot.
    static func back(_ x: Double) -> Double { let x = clamp(x), c = 1.9; return 1 + (c + 1) * pow(x - 1, 3) + c * pow(x - 1, 2) }

    /// "My first mandala", "My 2nd mandala", "My 3rd mandala"…
    static func kicker(_ n: Int) -> String {
        if n <= 1 { return "My first mandala" }
        let suffix: String
        switch (n % 10, n % 100) {
        case (_, 11...13): suffix = "th"
        case (1, _): suffix = "st"
        case (2, _): suffix = "nd"
        case (3, _): suffix = "rd"
        default: suffix = "th"
        }
        return "My \(n)\(suffix) mandala"
    }
}

/// One frame of the mandala video.
struct MandalaClipView: View {
    let t: Double
    let routineName: String
    let mandalaNumber: Int
    var days: Int = Mandala.days

    private var full: Double { Clip.full }

    var body: some View {
        ZStack(alignment: .topLeading) {
            backdrop
            texts
            yogi
            mark
        }
        .frame(width: Clip.width, height: Clip.height)
        .clipped()
        .environment(\.colorScheme, .light)
    }

    /// Background, rays, glow, the lotus, the burst and confetti, all in one canvas.
    private var backdrop: some View {
        Canvas { g, size in
            let c = Clip.centre
            g.fill(Path(CGRect(origin: .zero, size: size)), with: .radialGradient(
                Gradient(colors: [Clip.bgIn, Clip.bgOut]), center: c, startRadius: 0, endRadius: 1500))
            // Rays: 16 wedges of 10.4°, turning 3°/s.
            let rays = Clip.ease((t - 0.1) / 1.2)
            if rays > 0 {
                var r = g
                r.translateBy(x: c.x, y: c.y)
                r.rotate(by: .degrees(t * 3))
                for i in 0..<16 {
                    let a0 = (Double(i) * 22.5 - 5.2) * .pi / 180, a1 = a0 + 10.4 * .pi / 180
                    var p = Path()
                    p.move(to: .zero)
                    p.addArc(center: .zero, radius: 1500, startAngle: .radians(a0 - .pi / 2), endAngle: .radians(a1 - .pi / 2), clockwise: false)
                    p.closeSubpath()
                    r.fill(p, with: .color(.white.opacity(0.13 * rays)))
                }
            }
            // A soft glow once the lotus is full.
            let glow = Clip.ease((t - full + 0.3) / 0.6) * (0.85 + 0.15 * sin(t * 2))
            if glow > 0 {
                g.fill(Path(ellipseIn: CGRect(x: c.x - 520, y: c.y - 520, width: 1040, height: 1040)), with: .radialGradient(
                    Gradient(colors: [Color(red: 1, green: 0.965, blue: 0.745).opacity(0.75 * glow), .clear]),
                    center: c, startRadius: 0, endRadius: 520 * 0.65))
            }
            drawLotus(&g, c)
            drawHalo(&g, c)
            drawBurst(&g, c)
            drawConfetti(&g)
        }
    }

    private func drawLotus(_ g: inout GraphicsContext, _ c: CGPoint) {
        var l = g
        l.translateBy(x: c.x, y: c.y)
        l.scaleBy(x: Clip.lotusScale, y: Clip.lotusScale)
        l.rotate(by: .degrees(max(0, t - full) * 2.2))
        for k in [2, 1, 0] {
            let ring = LotusGeometry.rings[k]
            let shape = LotusGeometry.petal(length: ring.length, width: ring.width)
            for i in 0..<16 {
                // The pale outline of every petal, from the start.
                let ghost = shape.applying(LotusGeometry.placement(ring: ring, index: i))
                l.fill(ghost, with: .color(.white.opacity(0.16)))
                l.stroke(ghost, with: .color(.white.opacity(0.32)), lineWidth: 1.2 / Clip.lotusScale * 3)
                let day = k * 16 + i + 1
                let p = (t - (Clip.open0 + Double(day - 1) * Clip.step)) / Clip.openDuration
                guard p > 0 else { continue }
                let path = shape.applying(LotusGeometry.placement(ring: ring, index: i, scale: CGFloat(Clip.back(p))))
                var pl = l
                pl.opacity = Clip.clamp(p * 3)
                pl.fill(path, with: .color(Clip.ringColours[k]))
                pl.stroke(path, with: .color(Clip.bgOut), lineWidth: 1.6)
            }
        }
        let centre = Clip.ease((t - 0.9) / 0.5)
        if centre > 0 {
            var cc = l
            cc.opacity = centre
            let r = LotusGeometry.centreRadius
            cc.fill(Path(ellipseIn: CGRect(x: -r, y: -r, width: 2 * r, height: 2 * r)), with: .color(Clip.saffron))
        }
    }

    private func drawHalo(_ g: inout GraphicsContext, _ c: CGPoint) {
        let h = (t - full - 0.1) / 1.4
        guard h > 0, h < 1 else { return }
        let r = 200 + h * 420
        g.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)),
                 with: .color(.white.opacity(0.9 * (1 - h))), lineWidth: 16)
    }

    private func drawBurst(_ g: inout GraphicsContext, _ c: CGPoint) {
        let colours = [Clip.white, Clip.cream, Clip.saffron, Clip.white, Clip.creams, Color(hex: 0xFF8FB1)]
        let shape = LotusGeometry.petal(length: 40, width: 15)
        for j in 0..<18 {
            let q = (t - full - 0.05 - Double(j) * 0.012) / 1.6
            guard q > 0, q < 1 else { continue }
            var b = g
            b.opacity = q < 0.15 ? q / 0.15 : 1 - Clip.ease((q - 0.5) / 0.5)
            b.translateBy(x: c.x, y: c.y)
            b.rotate(by: .degrees(Double(j) * 20))
            b.translateBy(x: 0, y: -200 - Clip.ease(q) * 520)
            b.scaleBy(x: 0.5 + Clip.ease(q) * 0.9, y: 0.5 + Clip.ease(q) * 0.9)
            b.fill(shape, with: .color(colours[j % colours.count]))
        }
    }

    /// 46 petals of confetti, each with its own seeded drift.
    private func drawConfetti(_ g: inout GraphicsContext) {
        let colours = [Clip.white, Clip.cream, Clip.creams, Clip.saffron, Color(hex: 0xFFB3C7), Clip.white]
        var rng = SeededGenerator(seed: 48)
        for n in 0..<46 {
            let x = Double.random(in: 0...1080, using: &rng), v = Double.random(in: 260...520, using: &rng)
            let d = Double.random(in: 0...1, using: &rng), s = Double.random(in: 18...34, using: &rng)
            let sw = Double.random(in: 1.4...2.6, using: &rng), a = Double.random(in: 20...60, using: &rng)
            let r0 = Double.random(in: 0...360, using: &rng)
            let e = t - (full + 0.1) - d * 1.2
            guard e >= 0 else { continue }
            let yy = -60 + (e * v).truncatingRemainder(dividingBy: 2060), xx = x + sin(e * sw * 2) * a
            var p = g
            p.translateBy(x: xx, y: yy)
            p.rotate(by: .degrees(r0 + e * 140))
            var leaf = Path()
            leaf.move(to: CGPoint(x: 0, y: s))
            leaf.addQuadCurve(to: CGPoint(x: s, y: 0), control: CGPoint(x: 0, y: 0))
            leaf.addQuadCurve(to: CGPoint(x: 0, y: s), control: CGPoint(x: s, y: s))
            p.fill(leaf, with: .color(colours[n % colours.count]))
        }
    }

    private var texts: some View {
        let kick = Clip.ease((t - 0.5) / 0.6), title = Clip.ease((t - 0.2) / 0.7)
        let line = Clip.ease((t - full - 1.0) / 0.7)
        let day = (1...days).last { t - (Clip.open0 + Double($0 - 1) * Clip.step) > 0 } ?? 0
        return ZStack(alignment: .top) {
            Text(Clip.kicker(mandalaNumber))
                .font(YFFont.fixedBody(46, .semibold))
                .opacity(kick).offset(y: 178 + (1 - kick) * 24)
            Text(routineName)
                .font(YFFont.fixedHeading(168))
                .lineLimit(1).minimumScaleFactor(0.4)
                .padding(.horizontal, 60)
                .opacity(title).offset(y: 236 + (1 - title) * 40)
            counter(day: day).frame(height: 190).offset(y: 1400)
            Text("One day at a time.")
                .font(YFFont.fixedBody(50, .medium))
                .opacity(line).offset(y: 1630)
        }
        .foregroundStyle(YF.onAccent)
        .frame(width: Clip.width, height: Clip.height, alignment: .top)
    }

    @ViewBuilder private func counter(day: Int) -> some View {
        if t < full + 0.3 {
            Text(day > 0 ? "Day \(day)" : " ")
                .font(YFFont.fixedHeading(150))
                .opacity(t > full ? 1 - Clip.ease((t - full) / 0.3) : (day > 0 ? 1 : 0))
        } else {
            let q = (t - full - 0.3) / 0.6
            Text("\(days) days")
                .font(YFFont.fixedHeading(150))
                .opacity(Clip.ease(q))
                .scaleEffect(0.8 + 0.2 * Clip.back(q))
        }
    }

    /// The yogi rises into the centre once the lotus is full, then floats.
    private var yogi: some View {
        let y = (t - full + 0.2) / 0.9
        let lev = t > full ? sin((t - full) * 2 * .pi / 4.5) * -14 : 0
        return ZStack {
            Ellipse().fill(Color(hex: 0x0B3D1A))
                .frame(width: 300, height: 52)
                .opacity(0.22 * Clip.ease(y) * (1 + lev / 40))
                .offset(y: 190)
            YogiView(.joyful, whiteDhoti: true)
                .frame(width: 400, height: 400)
                .opacity(Clip.ease(y * 1.6))
                .offset(y: (1 - Clip.ease(y)) * 160 + lev - 40)
        }
        .position(Clip.centre)
    }

    private var mark: some View {
        HStack(spacing: 18) {
            LotusView(petals: .allOpen, style: .decoration([Clip.white, Clip.creams, Clip.cream], on: Clip.cream, centre: Clip.saffron))
                .padding(6)
                .frame(width: 70, height: 70)
                .background(Clip.cream, in: RoundedRectangle(cornerRadius: 16))
            Text("Yogi Focus").font(YFFont.fixedBody(42, .semibold)).foregroundStyle(YF.onAccent)
        }
        .opacity(Clip.ease((t - full - 1.8) / 0.7))
        .frame(width: Clip.width)
        .offset(y: 1760)
    }
}

/// Writes the video, frame by frame, on the phone. Nothing is uploaded.
@MainActor
final class MandalaClipMaker: ObservableObject {
    @Published var progress: Double = 0
    @Published var videoURL: URL?
    @Published var image: UIImage?
    @Published var failed = false

    let routineName: String
    let mandalaNumber: Int
    let routineID: UUID

    init(routineID: UUID, routineName: String, mandalaNumber: Int) {
        self.routineID = routineID; self.routineName = routineName; self.mandalaNumber = mandalaNumber
    }

    static func cacheFolder() -> URL {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("MandalaVideos")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Removes a routine's videos when the routine is removed.
    static func removeCache(for id: UUID) {
        let folder = cacheFolder()
        for f in (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? [] where f.hasPrefix(id.uuidString) {
            try? FileManager.default.removeItem(at: folder.appendingPathComponent(f))
        }
    }

    private var finalURL: URL { Self.cacheFolder().appendingPathComponent("\(routineID.uuidString)-\(mandalaNumber).mp4") }

    func render(t: Double) -> CGImage? {
        let renderer = ImageRenderer(content: MandalaClipView(t: t, routineName: routineName, mandalaNumber: mandalaNumber))
        renderer.scale = 1
        renderer.proposedSize = ProposedViewSize(width: Clip.width, height: Clip.height)
        return renderer.cgImage
    }

    func makeImage() {
        if image == nil, let cg = render(t: Clip.seconds) { image = UIImage(cgImage: cg) }
    }

    func make() async {
        makeImage()
        if FileManager.default.fileExists(atPath: finalURL.path) { progress = 1; videoURL = finalURL; return }
        let silent = Self.cacheFolder().appendingPathComponent("\(routineID.uuidString)-\(mandalaNumber)-silent.mp4")
        try? FileManager.default.removeItem(at: silent)
        do {
            try await writeFrames(to: silent)
            try await addChime(video: silent, to: finalURL)
            try? FileManager.default.removeItem(at: silent)
            progress = 1
            videoURL = finalURL
        } catch {
            failed = true
        }
    }

    private func writeFrames(to url: URL) async throws {
        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(Clip.width), AVVideoHeightKey: Int(Clip.height),
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 8_000_000],
        ])
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(Clip.width), kCVPixelBufferHeightKey as String: Int(Clip.height),
        ])
        writer.add(input)
        guard writer.startWriting() else { throw writer.error ?? CocoaError(.fileWriteUnknown) }
        writer.startSession(atSourceTime: .zero)
        for i in 0..<Clip.frames {
            while !input.isReadyForMoreMediaData { try await Task.sleep(for: .milliseconds(5)) }
            guard let cg = render(t: Double(i) / Double(Clip.fps)), let pool = adaptor.pixelBufferPool,
                  let buffer = Self.pixelBuffer(cg, pool: pool) else { continue }
            adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(i), timescale: CMTimeScale(Clip.fps)))
            progress = Double(i + 1) / Double(Clip.frames) * 0.95
            if i % 4 == 0 { await Task.yield() }
        }
        input.markAsFinished()
        await writer.finishWriting()
        if writer.status != .completed { throw writer.error ?? CocoaError(.fileWriteUnknown) }
    }

    private static func pixelBuffer(_ image: CGImage, pool: CVPixelBufferPool) -> CVPixelBuffer? {
        var out: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &out)
        guard let buffer = out else { return nil }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let ctx = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: image.width, height: image.height,
                                  bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        else { return nil }
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return buffer
    }

    /// The soft two-note chime as the lotus fills (6.4 s).
    private func addChime(video: URL, to output: URL) async throws {
        try? FileManager.default.removeItem(at: output)
        let composition = AVMutableComposition()
        let videoAsset = AVURLAsset(url: video)
        guard let vTrack = try await videoAsset.loadTracks(withMediaType: .video).first,
              let cv = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        else { throw CocoaError(.fileReadUnknown) }
        let duration = try await videoAsset.load(.duration)
        try cv.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: vTrack, at: .zero)
        if let chimeURL = Bundle.main.url(forResource: "mandala-chime", withExtension: "wav") {
            let chime = AVURLAsset(url: chimeURL)
            if let aTrack = try await chime.loadTracks(withMediaType: .audio).first,
               let ca = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                let chimeDuration = try await chime.load(.duration)
                let at = CMTime(seconds: Clip.full + 0.1, preferredTimescale: 600)
                let length = CMTimeMinimum(chimeDuration, CMTimeSubtract(duration, at))
                try ca.insertTimeRange(CMTimeRange(start: .zero, duration: length), of: aTrack, at: at)
            }
        }
        guard let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try await export.export(to: output, as: .mp4)
    }
}
