import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        ScrollView {
            VStack(spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(title: "CPU", value: String(format: "%.1f%%", viewModel.cpuUsage), icon: "cpu", theme: theme) {
                        ProgressView(value: viewModel.cpuUsage / 100)
                            .tint(theme.primaryColor)
                    }

                    StatCard(title: "内存", value: String(format: "%.1f%%", viewModel.memoryPercent), icon: "memorychip", theme: theme) {
                        ProgressView(value: viewModel.memoryPercent / 100)
                            .tint(theme.secondaryColor)
                    }

                    StatCard(title: "磁盘", value: String(format: "%.1f%%", viewModel.diskPercent), icon: "internaldrive", theme: theme) {
                        ProgressView(value: viewModel.diskPercent / 100)
                            .tint(theme.accentColor)
                    }

                    StatCard(title: "网络", value: formatBytes(viewModel.networkRecv) + "/s", icon: "network", theme: theme) {
                        HStack {
                            Image(systemName: "arrow.down")
                            Text(formatBytes(viewModel.networkRecv))
                        }
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    }
                }
            }
            .padding()
        }
        .background(theme.backgroundColor)
        .navigationTitle("仪表盘")
        .themed(themeManager)
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
