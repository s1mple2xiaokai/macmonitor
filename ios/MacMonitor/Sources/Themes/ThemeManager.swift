import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: any Theme = DefaultTheme()
    @Published var themeId: String = "default"

    private let themeStorageKey = "selectedThemeId"

    let availableThemes: [any Theme] = [
        DefaultTheme(),
    ]

    private init() {
        loadTheme()
    }

    func setTheme(_ theme: any Theme) {
        currentTheme = theme
        themeId = theme.id
        saveTheme()
    }

    func setThemeById(_ id: String) {
        if let theme = availableThemes.first(where: { $0.id == id }) {
            setTheme(theme)
        }
    }

    private func saveTheme() {
        UserDefaults.standard.set(themeId, forKey: themeStorageKey)
    }

    private func loadTheme() {
        if let savedId = UserDefaults.standard.string(forKey: themeStorageKey) {
            setThemeById(savedId)
        }
    }
}
