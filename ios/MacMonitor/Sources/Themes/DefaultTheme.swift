import SwiftUI

struct DefaultTheme: Theme {
    let id = "default"
    let name = "Default"

    let primaryColor = Color.blue
    let secondaryColor = Color.gray
    let accentColor = Color.orange

    let backgroundColor = Color(uiColor: .systemBackground)
    let cardBackgroundColor = Color(uiColor: .secondarySystemBackground)

    let primaryTextColor = Color.primary
    let secondaryTextColor = Color.secondary

    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 4

    let chartColors: [Color] = [.blue, .green, .orange, .red, .purple]

    let hasGlowEffect = false
    let hasGradient = false
}
