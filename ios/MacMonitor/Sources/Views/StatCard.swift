import SwiftUI

struct StatCard<Content: View>: View {
    let title: String
    let value: String
    let icon: String
    let theme: any Theme
    let content: Content

    init(title: String, value: String, icon: String, theme: any Theme, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.icon = icon
        self.theme = theme
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(theme.primaryColor)
                Text(title)
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundColor(theme.primaryTextColor)
            content
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(theme.cardCornerRadius)
    }
}
