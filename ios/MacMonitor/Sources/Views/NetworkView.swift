import SwiftUI

struct NetworkView: View {
    @StateObject private var viewModel = NetworkViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    NetworkStatBox(title: "下载", value: formatBytes(viewModel.totalRecv), icon: "arrow.down.circle.fill", color: theme.secondaryColor, theme: theme)
                    NetworkStatBox(title: "上传", value: formatBytes(viewModel.totalSent), icon: "arrow.up.circle.fill", color: theme.primaryColor, theme: theme)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("网络接口")
                        .font(.headline)
                        .foregroundColor(theme.primaryTextColor)

                    ForEach(viewModel.interfaces) { iface in
                        NetworkInterfaceRow(iface: iface, theme: theme)
                    }
                }
                .padding()
                .background(theme.cardBackgroundColor)
                .cornerRadius(theme.cardCornerRadius)
            }
            .padding()
        }
        .background(theme.backgroundColor)
        .navigationTitle("网络")
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct NetworkStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let theme: any Theme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(theme.secondaryTextColor)
            Text(value)
                .font(.headline)
                .foregroundColor(theme.primaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(theme.cardCornerRadius)
    }
}

struct NetworkInterfaceRow: View {
    let iface: NetworkStats
    let theme: any Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(iface.networkInterface)
                .font(.subheadline.bold())
                .foregroundColor(theme.primaryTextColor)

            HStack {
                Label(formatBytes(iface.bytesRecv), systemImage: "arrow.down")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
                Spacer()
                Label(formatBytes(iface.bytesSent), systemImage: "arrow.up")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.vertical, 8)
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
