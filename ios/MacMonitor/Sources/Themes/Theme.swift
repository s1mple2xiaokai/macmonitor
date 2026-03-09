import SwiftUI

protocol Theme {
    var id: String { get }
    var name: String { get }

    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }

    var backgroundColor: Color { get }
    var cardBackgroundColor: Color { get }

    var primaryTextColor: Color { get }
    var secondaryTextColor: Color { get }

    var cardCornerRadius: CGFloat { get }
    var cardShadowRadius: CGFloat { get }

    var chartColors: [Color] { get }

    var hasGlowEffect: Bool { get }
    var hasGradient: Bool { get }
}
