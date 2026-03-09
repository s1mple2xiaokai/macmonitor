import SwiftUI

struct CyberGirlTheme: Theme {
    let id = "cybergirl"
    let name = "赛博少女"

    let primaryColor = Color(hex: "FF69B4")
    let secondaryColor = Color(hex: "9B59B6")
    let accentColor = Color(hex: "FF1493")

    let backgroundColor = Color(hex: "1E1E2E")
    let cardBackgroundColor = Color(hex: "2D2D44")

    let primaryTextColor = Color.white
    let secondaryTextColor = Color(hex: "FF69B4")

    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 6

    let chartColors: [Color] = [
        Color(hex: "FF69B4"),
        Color(hex: "9B59B6"),
        Color(hex: "FF1493"),
        Color(hex: "DA70D6"),
        Color(hex: "EE82EE")
    ]

    let hasGlowEffect = true
    let hasGradient = true
}
