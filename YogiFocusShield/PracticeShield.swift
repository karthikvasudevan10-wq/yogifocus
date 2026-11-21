import ManagedSettings
import ManagedSettingsUI
import UIKit
import YogiKit

/// What a quieted app shows during practice time (v2 item 3, `V2-Shield`): calm, sunny, never a scold.
final class PracticeShield: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration { shield }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { shield }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { shield }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { shield }

    private var shield: ShieldConfiguration {
        let now = QuietPractice.now
        let ends = now.map { DateFormatter.localizedString(from: $0.endsAt, dateStyle: .none, timeStyle: .short) }
        let sub: String
        if let now, let ends {
            sub = "\(now.name) on \(now.place). This app opens again at \(ends)."
        } else {
            sub = "This app opens again when your practice is over."
        }
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialLight,
            backgroundColor: UIColor(red: 1, green: 0.82, blue: 0.12, alpha: 1),
            icon: UIImage(systemName: "leaf.circle.fill")?.withTintColor(UIColor(red: 0.07, green: 0.48, blue: 0.21, alpha: 1), renderingMode: .alwaysOriginal),
            title: ShieldConfiguration.Label(text: "It's practice time.", color: UIColor(red: 0.08, green: 0.19, blue: 0.12, alpha: 1)),
            subtitle: ShieldConfiguration.Label(text: sub, color: UIColor(red: 0.08, green: 0.19, blue: 0.12, alpha: 1)),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 0.08, green: 0.19, blue: 0.12, alpha: 1))
    }
}
