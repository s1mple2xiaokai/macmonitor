import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        let theme = themeManager.currentTheme

        TabView {
            NavigationStack {
                DashboardView(themeManager: themeManager)
            }
            .tabItem {
                Label("仪表盘", systemImage: "gauge.with.dots.needle.bottom.50percent")
            }

            NavigationStack {
                CPUView(themeManager: themeManager)
            }
            .tabItem {
                Label("CPU", systemImage: "cpu")
            }

            NavigationStack {
                MemoryView(themeManager: themeManager)
            }
            .tabItem {
                Label("内存", systemImage: "memorychip")
            }

            NavigationStack {
                DiskView(themeManager: themeManager)
            }
            .tabItem {
                Label("磁盘", systemImage: "internaldrive")
            }

            NavigationStack {
                NetworkView(themeManager: themeManager)
            }
            .tabItem {
                Label("网络", systemImage: "network")
            }

            NavigationStack {
                ProcessListView(themeManager: themeManager)
            }
            .tabItem {
                Label("进程", systemImage: "list.bullet")
            }

            NavigationStack {
                AppListView(themeManager: themeManager)
            }
            .tabItem {
                Label("应用", systemImage: "app.badge")
            }

            NavigationStack {
                SettingsView(themeManager: themeManager)
            }
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
        }
        .tint(theme.primaryColor)
        .onAppear {
            MonitorService.shared.startMonitoring()
        }
    }
}
