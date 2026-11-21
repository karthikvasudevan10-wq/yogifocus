import SwiftUI
import YogiKit

// v2 item 1: begin a routine again. Always the person's choice; the app never suggests it (design rule 10),
// and nothing here mentions missed days (design rule 4).

/// A small heading above a group of settings, such as "This routine".
struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(YFFont.body(14, .semibold)).foregroundStyle(YF.muted)
            .padding(.leading, 4)
            .accessibilityAddTraits(.isHeader)
    }
}

/// "Begin this routine again", as a row in routine settings.
struct RestartRow: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                YFIcon("lotus", size: 22).foregroundStyle(YF.textGreen)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Begin this routine again").font(YFFont.body(15.5, .medium)).foregroundStyle(YF.ink)
                    Text("A new mandala from today. Earlier days stay in your history.")
                        .font(YFFont.body(13)).foregroundStyle(YF.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                YFIcon("chev-right", size: 20).foregroundStyle(YF.muted)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .frame(minHeight: 68)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// The sheet that asks once before beginning again (`V2-Restart`).
struct RestartSheet: View {
    let routineName: String
    let onBegin: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            LotusView(petals: .noneOpen)
                .frame(width: 148, height: 148)
                .accessibilityHidden(true)
            Text("Begin \(routineName) again?")
                .font(YFFont.heading(30))
                .foregroundStyle(YF.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
            Text("A new mandala starts today, at day one. Every day so far stays in your history.")
                .font(YFFont.body(17)).foregroundStyle(YF.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            Text("Same hour, same place, same things. Only the lotus starts fresh.")
                .font(YFFont.body(15)).foregroundStyle(YF.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            VStack(spacing: 10) {
                PrimaryButton("Begin again") { onBegin(); dismiss() }
                GhostButton("Not now") { dismiss() }
            }
            .padding(.top, 26)
        }
        .padding(.horizontal, 28)
        .padding(.top, 30)
        .padding(.bottom, 12)
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(560), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(36)
        .presentationBackground(YF.ground)
    }
}
