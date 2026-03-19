import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDarkTheme: Bool {
        didSet {
            UserDefaults.standard.set(isDarkTheme, forKey: Self.themeKey)
        }
    }

    @Published var showUserAgreement = false

    let apiDescription = "Приложение использует API «Яндекс.Расписания»"
    let versionDescription: String

    private static let themeKey = "is_dark_theme"

    init() {
        self.isDarkTheme = UserDefaults.standard.bool(forKey: Self.themeKey)

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.versionDescription = "Версия \(version) (beta)"
    }

    func openUserAgreement() {
        showUserAgreement = true
    }
}
