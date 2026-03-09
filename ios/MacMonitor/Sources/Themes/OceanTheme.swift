import SwiftUI

struct OceanTheme: Theme {
    let id = "ocean"
    let name = "大海"

    let primaryColor = Color(hex: "4169E1")
    let secondaryColor = Color(hex: "87CEEB")
    let accentColor = Color(hex: "00CED1")

    let backgroundColor = Color(hex: "0A1929")
    let cardBackgroundColor = Color(hex: "132F4C")

    let primaryTextColor = Color.white
    let secondaryTextColor = Color(hex: "87CEEB")

    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 4

    let chartColors: [Color] = [
        Color(hex: "4169E1"),
        Color(hex: "00CED1"),
        Color(hex: "87CEEB"),
        Color(hex: "48D1CC"),
        Color(hex: "20B2AA")
    ]

    let hasGlowEffect = true
    let hasGradient = true
}
