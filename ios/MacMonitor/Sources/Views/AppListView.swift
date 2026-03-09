import SwiftUI

struct AppListView: View {
    @StateObject private var viewModel = AppListViewModel()
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.currentTheme

        List {
            ForEach(viewModel.apps) { app in
                AppRow(app: app, theme: theme)
            }
        }
        .listStyle(.plain)
        .background(theme.backgroundColor)
        .navigationTitle("应用")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppRow: View {
    let app: AppInfo
    let theme: any Theme

    var body: some View {
        HStack {
            Image(systemName: "app.fill")
                .font(.title)
                .foregroundColor(theme.primaryColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(theme.primaryTextColor)
                Text("PID: \(app.pid)")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "CPU: %.1f%%", app.cpuPercent))
                    .font(.subheadline)
                    .foregroundColor(theme.primaryColor)
                Text(String(format: "MEM: %.0f MB", app.memoryMB))
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.vertical, 4)
    }
}
