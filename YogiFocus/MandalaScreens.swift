import SwiftUI
import YogiKit

// MARK: - Day 30: the lotus is shown for the first time

struct Day30Screen: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onSee: () -> Void

    @ViewBuilder var phoneBody: some View {
        let now = Date()
        let r = model.routine(routineID)
        let practised = r?.practisedCount(on: now) ?? 0
        let missed = r?.missedCount(on: now) ?? 0
        Screen {
            Spacer().frame(height: 8)
            // The petals for the days so far unfold one by one: green for days practised, red for days missed.
            LotusProgressView(petals: r?.petals(on: now) ?? .noneOpen, count: practised, bloom: true)
                .frame(maxWidth: 270)
                .frame(maxWidth: .infinity)
            H1("Thirty days. Meet your lotus.").padding(.top, 16)
            Para("Each day you practised opened a petal: \(practised) so far. Yogi Focus kept it out of sight so that every day could simply be today.")
                .padding(.top, 8)
            Para(missedLine(missed)).padding(.top, 10)
        } bottom: {
            PrimaryButton("See my mandala", action: onSee)
        }
    }

    /// Plain fact, no blame.
    private func missedLine(_ n: Int) -> String {
        switch n {
        case 0: return "Nothing resets, and the lotus keeps opening."
        case 1: return "The red petal is a day you missed. Nothing resets, and the lotus keeps opening."
        default: return "The \(Words.spelled(n)) red petals are days you missed. Nothing resets, and the lotus keeps opening."
        }
    }
}

// MARK: - Mandala progress (only after day 30)

struct MandalaScreen: View {
    @Environment(\.duoPose) private var pose
    var body: some View {
        if pose == .phone { phoneBody } else { duoBody }
    }
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onBack: () -> Void
    let onEdit: () -> Void
    @State private var askRestart = false

    @ViewBuilder var phoneBody: some View {
        let now = Date()
        if let r = model.routine(routineID), r.showsProgress(on: now) {
            let practised = r.practisedCount(on: now)
            let missed = r.missedCount(on: now)
            let day = min(r.dayNumber(on: now), Mandala.days)
            let counts = YogiStore.shared.feelingCounts(for: r)
            let total = max(1, counts.values.reduce(0, +))
            Screen {
                TopBar(back: onBack)
                Text(r.name).font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
                H1("Your mandala", size: 34)
                LotusProgressView(petals: r.petals(on: now), count: practised)
                    .frame(maxWidth: 232)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                // Red and green are never the only signal: the count is always given in words.
                Text("\(practised) of 48 days practised").font(YFFont.body(17, .semibold))
                    .frame(maxWidth: .infinity).padding(.top, 10)
                Text(statusLine(day: day, missed: missed)).font(YFFont.body(14)).foregroundStyle(YF.muted)
                    .frame(maxWidth: .infinity)
                HStack(spacing: 16) {
                    key(YF.mid, "Practised")
                    key(YF.missed, "Missed")
                    key(YF.petalClosed, "To come", ring: true)
                }
                .font(YFFont.body(13, .medium))
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                Text("How it has felt").font(YFFont.body(14, .semibold)).padding(.top, 14)
                VStack(spacing: 0) {
                    // All bars are the same green; no row is marked as bad.
                    felt(.absorbed, counts[.absorbed] ?? 0, total)
                    felt(.steady, counts[.steady] ?? 0, total)
                    felt(.scattered, counts[.scattered] ?? 0, total)
                }
                .padding(.top, 4)
                HStack(spacing: 10) {
                    Text("Every day, \(r.timeText), \(r.placeInSentence)").font(YFFont.body(15, .medium))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Button(action: onEdit) {
                        Text("Edit").font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen)
                            .frame(minWidth: 52, minHeight: 44)
                    }
                }
                .padding(.leading, 20).padding(.trailing, 6)
                .frame(minHeight: 60)
                .background(YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
                .padding(.top, 18)
                freshMandalaLink(r)
            }
        } else {
            // Before day 30 there is nothing to show, by design.
            Screen { TopBar(back: onBack) }
        }
    }

    /// After day 30 only (this screen shows nothing before then). The person's choice; never suggested.
    func freshMandalaLink(_ r: RoutineSnapshot) -> some View {
        Button { askRestart = true } label: {
            Text("Begin a fresh mandala").font(YFFont.body(15, .medium)).underline().foregroundStyle(YF.ink)
                .padding(.horizontal, 12).frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
        .sheet(isPresented: $askRestart) {
            RestartSheet(routineName: r.name) {
                YogiStore.shared.restartMandala(r.id)
                model.refresh()
                onBack()
            }
        }
    }

    private func statusLine(day: Int, missed: Int) -> String {
        switch missed {
        case 0: return "Day \(day). Nothing resets."
        case 1: return "Day \(day). 1 day missed. Nothing resets."
        default: return "Day \(day). \(missed) days missed. Nothing resets."
        }
    }

    private func key(_ color: Color, _ text: String, ring: Bool = false) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
                .overlay { if ring { Circle().strokeBorder(YF.muted, lineWidth: 1) } }
            Text(text)
        }
    }

    private func felt(_ f: Feeling, _ n: Int, _ total: Int) -> some View {
        HStack(spacing: 12) {
            YFIcon(f.icon, size: 20).foregroundStyle(YF.textGreen)
            Text(f.title).font(YFFont.body(15, .medium)).frame(width: 84, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(YF.softGreen)
                    Capsule().fill(YF.mid).frame(width: geo.size.width * CGFloat(n) / CGFloat(total))
                }
            }
            .frame(height: 8)
            Text("\(n) day\(n == 1 ? "" : "s")").font(YFFont.body(14)).foregroundStyle(YF.muted)
                .frame(width: 58, alignment: .trailing)
        }
        .frame(minHeight: 36)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Mandala complete: the grand finish

struct MandalaCompleteScreen: View {
    @Environment(AppModel.self) private var model
    let routineID: UUID
    let onNewMandala: () -> Void
    let onAddRoutine: () -> Void

    var body: some View {
        let now = Date()
        let r = model.routine(routineID)
        let practised = r?.practisedCount(on: now) ?? Mandala.days
        let missed = Mandala.days - practised
        ZStack {
            HeroLayout(background: YF.heroGreen, heroAspect: 300 / 344, heroMaxWidth: 266, rays: YF.raysOnGreen, raysCentre: 0.42) {
                // Yoga Sūtra 1.14
                VStack(spacing: 3) {
                    Text("स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः")
                        .font(YFFont.heading(18, .semibold))
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .environment(\.locale, Locale(identifier: "sa"))
                    Text("sa tu dīrgha-kāla-nairantarya-satkārāsevito dṛḍha-bhūmiḥ")
                        .font(YFFont.body(14, .medium)).italic()
                    Text("Practice finds firm ground when it is tended for a long time, steadily and with care.")
                        .font(YFFont.body(14)).padding(.top, 4)
                    Text("Yoga Sūtra 1.14").font(YFFont.body(12.5, .semibold))
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
            } hero: {
                CompleteHero()
                    .padding(.top, 10)
                    .accessibilityElement()
                    .accessibilityLabel("A yogi floating above a slowly turning lotus")
            } content: {
                VStack(alignment: .leading, spacing: 0) {
                    H1("One mandala.", size: 46).padding(.top, 6)
                    Para(missed <= 0
                         ? "Out of 48 days, you practised all 48. Yogis say a practice held this long is yours for life."
                         : "Out of 48 days, you practised \(practised) and missed \(missed). Yogis say a practice held this long is yours for life.")
                        .padding(.top, 4)
                }
            } bottom: {
                PrimaryButton("Begin a new mandala", kind: .hero, action: onNewMandala)
                // The only place a second routine is offered to a beginner.
                GhostButton("Add another routine", color: YF.ink, action: onAddRoutine)
            }
            // In the reference the petals fall for ever so they can be seen; in the app they fall for a few seconds and stop.
            PetalDrift(count: 28, colors: [.white, YF.sunny, YF.daySky, YF.saffron, Color(hex: 0xFFB3C7), YF.sunny, .white],
                       seed: 48, period: 5...8, loops: false, stagger: 3.5)
                .ignoresSafeArea()
        }
        .sensoryFeedback(.success, trigger: routineID)
    }
}

/// The yogi levitating above a large open lotus seen at an angle; the lotus turns slowly and its rings breathe.
struct CompleteHero: View {
    var body: some View {
        DesignCanvas(width: 300, height: 344) {
            LotusView(style: LotusStyle(open: [.white, YF.daySky, YF.sunny], separator: YF.heroGreen, centre: nil), breathe: true)
                .frame(width: 300, height: 300)
                .spin(period: 48)
                .scaleEffect(x: 1.28, y: 0.54)
                .offset(x: 0, y: 112)
            FloatShadow(color: Color(hex: 0x0B3D1A), base: 0.24)
                .frame(width: 112, height: 24)
                .offset(x: 94, y: 250)
            YogiView(.joyful)
                .frame(width: 230, height: 230)
                .levitate(low: 4.6, high: -10.35)
                .offset(x: 35, y: -4)
        }
    }
}

// MARK: - iPhone Duo

extension Day30Screen {
    /// The lotus is what you look at; the words and button sit beside it, or below the fold.
    var duoBody: some View {
        let now = Date()
        let r = model.routine(routineID)
        let practised = r?.practisedCount(on: now) ?? 0
        let missed = r?.missedCount(on: now) ?? 0
        return DuoPage {
            LotusProgressView(petals: r?.petals(on: now) ?? .noneOpen, count: practised, bloom: true)
                .frame(maxWidth: pose == .outer ? 200 : 330)
                .frame(maxWidth: .infinity)
        } trail: {
            H1("Thirty days. Meet your lotus.").padding(.top, pose == .outer ? 12 : 0)
            Para("Each day you practised opened a petal: \(practised) so far. Yogi Focus kept it out of sight so that every day could simply be today.")
                .padding(.top, 8)
            Para(missedLine(missed)).padding(.top, 10)
        } bottom: {
            PrimaryButton("See my mandala", action: onSee)
        }
    }
}

extension MandalaScreen {
    /// Duo mandala (`Duo-Outer-Mandala`, `Duo-Wide-Mandala`).
    /// - outer: the lotus beside the count; Edit moves into the strip.
    /// - wide: the lotus on the leading side; the count, how it has felt and Edit on the trailing side.
    /// - tall: the lotus in the top region; the rest below the fold.
    @ViewBuilder var duoBody: some View {
        let now = Date()
        if let r = model.routine(routineID), r.showsProgress(on: now) {
            let practised = r.practisedCount(on: now)
            let missed = r.missedCount(on: now)
            let day = min(r.dayNumber(on: now), Mandala.days)
            let counts = YogiStore.shared.feelingCounts(for: r)
            let total = max(1, counts.values.reduce(0, +))
            let lotus = LotusProgressView(petals: r.petals(on: now), count: practised)
            let keys = HStack(spacing: 14) {
                key(YF.mid, "Practised")
                key(YF.missed, "Missed")
                key(YF.petalClosed, "To come", ring: true)
            }
            .font(YFFont.body(13, .medium))
            let felt = VStack(alignment: .leading, spacing: 0) {
                Text("How it has felt").font(YFFont.body(14, .semibold)).padding(.top, 16)
                VStack(spacing: 0) {
                    self.felt(.absorbed, counts[.absorbed] ?? 0, total)
                    self.felt(.steady, counts[.steady] ?? 0, total)
                    self.felt(.scattered, counts[.scattered] ?? 0, total)
                }
                .padding(.top, 4)
            }
            switch pose {
            case .wide:
                DuoPage(leadAlignment: .top, trailAlignment: .top, pinsBottom: true, strip: [.back(onBack)]) {
                    Text(r.name).font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
                    H1("Your mandala", size: 36)
                    lotus.frame(maxWidth: 330).frame(maxWidth: .infinity).padding(.top, 14)
                    keys.frame(maxWidth: .infinity).padding(.top, 14)
                } trail: {
                    Text("\(practised) of 48 days practised").font(YFFont.heading(30)).designLineHeight(30, 1.15).padding(.top, 56)
                    Text(statusLine(day: day, missed: missed)).font(YFFont.body(15)).foregroundStyle(YF.muted).padding(.top, 4)
                    felt.padding(.top, 10)
                    freshMandalaLink(r)
                } bottom: {
                    editRow(r)
                }
            case .tall:
                DuoPage(pinsBottom: true, bar: { AnyView(TopBar(back: onBack)) }) {
                    Text(r.name).font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
                    H1("Your mandala", size: 36)
                    lotus.frame(maxWidth: 300).frame(maxWidth: .infinity).padding(.top, 10)
                    keys.frame(maxWidth: .infinity).padding(.top, 10)
                } trail: {
                    Text("\(practised) of 48 days practised").font(YFFont.heading(28))
                    Text(statusLine(day: day, missed: missed)).font(YFFont.body(15)).foregroundStyle(YF.muted).padding(.top, 4)
                    felt
                    freshMandalaLink(r)
                } bottom: {
                    editRow(r)
                }
            default:
                DuoPage(strip: [.back(onBack), .edit(onEdit)]) {
                    Text(r.name).font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
                    H1("Your mandala", size: 34)
                    HStack(alignment: .center, spacing: 18) {
                        lotus.frame(width: 176, height: 176)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(practised) of 48 days practised").font(YFFont.heading(22)).designLineHeight(22, 1.15).fixedSize(horizontal: false, vertical: true)
                            Text(statusLine(day: day, missed: missed)).font(YFFont.body(14)).foregroundStyle(YF.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            VStack(alignment: .leading, spacing: 4) {
                                key(YF.mid, "Practised")
                                key(YF.missed, "Missed")
                                key(YF.petalClosed, "To come", ring: true)
                            }
                            .font(YFFont.body(13, .medium))
                        }
                    }
                    .padding(.top, 12)
                    felt
                    freshMandalaLink(r)
                } trail: {
                    EmptyView()
                } bottom: {
                    Text("Every day, \(r.timeText), \(r.placeInSentence)").font(YFFont.body(14.5, .medium)).foregroundStyle(YF.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } else {
            DuoPage(bar: { AnyView(TopBar(back: onBack)) }) { EmptyView() } trail: { EmptyView() }
        }
    }

    private func editRow(_ r: RoutineSnapshot) -> some View {
        HStack(spacing: 10) {
            Text("Every day, \(r.timeText), \(r.placeInSentence)").font(YFFont.body(15, .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(action: onEdit) {
                Text("Edit").font(YFFont.body(15, .semibold)).foregroundStyle(YF.textGreen).frame(minWidth: 52, minHeight: 44)
            }
        }
        .padding(.leading, 18).padding(.trailing, 6)
        .frame(minHeight: 60)
        .background(YF.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(YF.line, lineWidth: 1))
    }
}
