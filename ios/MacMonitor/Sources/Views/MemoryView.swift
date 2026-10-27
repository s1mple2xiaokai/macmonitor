import SwiftUI

struct MemoryView: View {
    @StateObject private var viewModel = MemoryViewModel()
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var monitorService = MonitorService.shared
    @State private var isCleaningUp = false

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

                // 清理内存按钮
                Button(action: {
                    Task {
                        isCleaningUp = true
                        await monitorService.cleanupMemory()
                        isCleaningUp = false
                    }
                }) {
                    HStack {
                        if isCleaningUp {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "trash")
                        }
                        Text(isCleaningUp ? "清理中..." : "清理内存")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.primaryColor)
                    .cornerRadius(12)
                }
                .disabled(isCleaningUp)

                // 显示错误消息
                if let error = monitorService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
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
