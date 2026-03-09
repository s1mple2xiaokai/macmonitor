import SwiftUI

struct CyberpunkTheme: Theme {
    let id = "cyberpunk"
    let name = "赛博朋克"

    let primaryColor = Color(hex: "FF00FF")
    let secondaryColor = Color(hex: "00FFFF")
    let accentColor = Color(hex: "FF00FF")

    let backgroundColor = Color(hex: "1A0A2E")
    let cardBackgroundColor = Color(hex: "2D1B4E")

    let primaryTextColor = Color.white
    let secondaryTextColor = Color(hex: "00FFFF")

    let cardCornerRadius: CGFloat = 12
    let cardShadowRadius: CGFloat = 8

    let chartColors: [Color] = [
        Color(hex: "FF00FF"),
        Color(hex: "00FFFF"),
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "FFE66D")
    ]

    let hasGlowEffect = true
    let hasGradient = true
}
