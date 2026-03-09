import SwiftUI

struct PastoralTheme: Theme {
    let id = "pastoral"
    let name = "田园"

    let primaryColor = Color(hex: "90EE90")
    let secondaryColor = Color(hex: "F5F5DC")
    let accentColor = Color(hex: "8FBC8F")

    let backgroundColor = Color(hex: "F5FFF5")
    let cardBackgroundColor = Color.white

    let primaryTextColor = Color(hex: "2E4A2E")
    let secondaryTextColor = Color(hex: "6B8E6B")

    let cardCornerRadius: CGFloat = 18
    let cardShadowRadius: CGFloat = 3

    let chartColors: [Color] = [
        Color(hex: "90EE90"),
        Color(hex: "8FBC8F"),
        Color(hex: "98FB98"),
        Color(hex: "9ACD32"),
        Color(hex: "32CD32")
    ]

    let hasGlowEffect = false
    let hasGradient = false
}
