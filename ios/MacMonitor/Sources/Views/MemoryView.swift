import SwiftUI

struct MemoryView: View {
    @StateObject private var viewModel = MemoryViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    CircularProgressView(progress: viewModel.percent / 100, color: theme.primaryColor)
                        .frame(height: 150)

                    Text(String(format: "%.1f%%", viewModel.percent))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(theme.primaryColor)
                }
                .padding()
                .background(theme.cardBackgroundColor)
                .cornerRadius(theme.cardCornerRadius)

                VStack(spacing: 12) {
                    MemoryRow(label: "已用", value: formatBytes(viewModel.used), theme: theme)
                    MemoryRow(label: "可用", value: formatBytes(viewModel.free), theme: theme)
                    MemoryRow(label: "总计", value: formatBytes(viewModel.total), theme: theme)
                }
                .padding()
                .background(theme.cardBackgroundColor)
                .cornerRadius(theme.cardCornerRadius)
            }
            .padding()
        }
        .background(theme.backgroundColor)
        .navigationTitle("内存")
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct MemoryRow: View {
    let label: String
    let value: String
    let theme: any Theme

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(theme.secondaryTextColor)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(theme.primaryTextColor)
        }
    }
}
