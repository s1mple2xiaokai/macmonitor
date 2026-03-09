import SwiftUI

struct ThemedViewModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.3), value: themeManager.themeId)
    }
}

extension View {
    func themed(_ themeManager: ThemeManager) -> some View {
        modifier(ThemedViewModifier(themeManager: themeManager))
    }
}
