import SwiftUI

struct ProcessListView: View {
    @StateObject private var viewModel = ProcessListViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        VStack(spacing: 0) {
            Picker("排序", selection: $viewModel.sortOrder) {
                Text("CPU").tag(ProcessListViewModel.SortOrder.cpu)
                Text("内存").tag(ProcessListViewModel.SortOrder.memory)
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                ForEach(viewModel.sortedProcesses) { process in
                    ProcessRow(process: process, theme: theme)
                }
            }
            .listStyle(.plain)
        }
        .background(theme.backgroundColor)
        .navigationTitle("进程")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProcessRow: View {
    let process: ProcessInfo
    let theme: any Theme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(process.name)
                    .font(.headline)
                    .foregroundColor(theme.primaryTextColor)
                Text("PID: \(process.pid)")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "CPU: %.1f%%", process.cpuPercent))
                    .font(.subheadline)
                    .foregroundColor(theme.primaryColor)
                Text("MEM: \(formatBytes(process.memoryBytes))")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
