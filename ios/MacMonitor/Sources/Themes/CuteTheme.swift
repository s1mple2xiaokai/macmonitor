import SwiftUI

struct CuteTheme: Theme {
    let id = "cute"
    let name = "可爱"

    let primaryColor = Color(hex: "FFB6C1")
    let secondaryColor = Color(hex: "FFF0F5")
    let accentColor = Color(hex: "FF69B4")

    let backgroundColor = Color(hex: "FFF5F8")
    let cardBackgroundColor = Color.white

    let primaryTextColor = Color(hex: "4A4A4A")
    let secondaryTextColor = Color(hex: "8E8E93")

    let cardCornerRadius: CGFloat = 20
    let cardShadowRadius: CGFloat = 2

    let chartColors: [Color] = [
        Color(hex: "FFB6C1"),
        Color(hex: "FF69B4"),
        Color(hex: "87CEEB"),
        Color(hex: "98FB98"),
        Color(hex: "DDA0DD")
    ]

    let hasGlowEffect = false
    let hasGradient = false
}
