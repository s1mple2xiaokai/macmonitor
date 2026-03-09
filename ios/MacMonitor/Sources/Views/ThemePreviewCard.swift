import SwiftUI

struct ThemePreviewCard: View {
    let theme: any Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.cardBackgroundColor)
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 4) {
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(theme.secondaryColor)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 12, height: 12)
                        }
                    )

                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(theme.primaryTextColor)
            }
            .padding(8)
            .background(theme.backgroundColor)
            .cornerRadius(theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cardCornerRadius)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
