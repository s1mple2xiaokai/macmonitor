import SwiftUI

struct DiskView: View {
    @StateObject private var viewModel = DiskViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.disks) { disk in
                    DiskCard(disk: disk, theme: theme)
                }
            }
            .padding()
        }
        .background(theme.backgroundColor)
        .navigationTitle("磁盘")
    }
}

struct DiskCard: View {
    let disk: DiskStats
    let theme: any Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundColor(theme.primaryColor)
                Text(disk.path)
                    .font(.headline)
                    .foregroundColor(theme.primaryTextColor)
                Spacer()
                Text(String(format: "%.1f%%", disk.usedPercent))
                    .font(.title3.bold())
                    .foregroundColor(theme.accentColor)
            }

            ProgressView(value: disk.usedPercent / 100)
                .tint(theme.primaryColor)

            HStack {
                VStack(alignment: .leading) {
                    Text("已用")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    Text(formatBytes(disk.used))
                        .font(.subheadline)
                        .foregroundColor(theme.primaryTextColor)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("可用")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    Text(formatBytes(disk.free))
                        .font(.subheadline)
                        .foregroundColor(theme.primaryTextColor)
                }
            }
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(theme.cardCornerRadius)
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
