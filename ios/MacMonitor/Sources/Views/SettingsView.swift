import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var monitorService = MonitorService.shared

    @State private var serverAddress: String = ""
    @State private var refreshInterval: Double = 2.0

    var body: some View {
        let theme = themeManager.currentTheme

        List {
            Section {
                ForEach(themeManager.availableThemes, id: \.id) { themeItem in
                    Button(action: {
                        themeManager.setTheme(themeItem)
                    }) {
                        HStack {
                            Circle()
                                .fill(themeItem.primaryColor)
                                .frame(width: 24, height: 24)
                            Text(themeItem.name)
                                .foregroundColor(themeManager.themeId == themeItem.id ? theme.primaryColor : theme.primaryTextColor)
                            Spacer()
                            if themeManager.themeId == themeItem.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.primaryColor)
                            }
                        }
                    }
                }
            } header: {
                Text("主题")
                    .foregroundColor(theme.secondaryTextColor)
            }

            Section {
                HStack {
                    Text("服务器地址")
                        .foregroundColor(theme.primaryTextColor)
                    Spacer()
                    TextField("http://192.168.1.x:8080", text: $serverAddress)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .onChange(of: serverAddress) { _, newValue in
                            monitorService.updateServerAddress(newValue)
                        }
                }

                VStack(alignment: .leading) {
                    Text("刷新间隔: \(Int(refreshInterval))秒")
                        .foregroundColor(theme.primaryTextColor)
                    Slider(value: $refreshInterval, in: 1...10, step: 1)
                        .onChange(of: refreshInterval) { _, newValue in
                            monitorService.updateRefreshInterval(newValue)
                        }
                }
            } header: {
                Text("连接")
                    .foregroundColor(theme.secondaryTextColor)
            }

            Section {
                HStack {
                    Text("连接状态")
                        .foregroundColor(theme.primaryTextColor)
                    Spacer()
                    Circle()
                        .fill(monitorService.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(monitorService.isConnected ? "已连接" : "未连接")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                }

                if let error = monitorService.errorMessage {
                    Text("错误: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } header: {
                Text("状态")
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.backgroundColor)
        .navigationTitle("设置")
        .onAppear {
            serverAddress = monitorService.serverAddress
        }
    }
}
