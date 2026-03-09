import SwiftUI

struct CPUView: View {
    @StateObject private var viewModel = CPUViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("总体使用率")
                        .font(.headline)
                        .foregroundColor(theme.primaryTextColor)

                    CircularProgressView(progress: viewModel.usage / 100, color: theme.primaryColor)
                        .frame(height: 150)

                    Text(String(format: "%.1f%%", viewModel.usage))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(theme.primaryColor)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(theme.cardBackgroundColor)
                .cornerRadius(theme.cardCornerRadius)

                VStack(alignment: .leading, spacing: 8) {
                    Text("CPU 信息")
                        .font(.headline)
                        .foregroundColor(theme.primaryTextColor)

                    HStack {
                        Text("核心数")
                            .foregroundColor(theme.secondaryTextColor)
                        Spacer()
                        Text("\(viewModel.cores)")
                            .foregroundColor(theme.primaryTextColor)
                    }

                    HStack {
                        Text("型号")
                            .foregroundColor(theme.secondaryTextColor)
                        Spacer()
                        Text(viewModel.modelName)
                            .foregroundColor(theme.primaryTextColor)
                            .lineLimit(1)
                    }
                }
                .padding()
                .background(theme.cardBackgroundColor)
                .cornerRadius(theme.cardCornerRadius)
            }
            .padding()
        }
        .background(theme.backgroundColor)
        .navigationTitle("CPU")
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}
