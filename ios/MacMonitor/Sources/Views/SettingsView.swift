import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var monitorService = MonitorService.shared
    @ObservedObject var terminalConfig = TerminalConfig.shared

    @State private var serverAddress: String = ""
    @State private var refreshInterval: Double = 2.0
    @State private var terminalToken: String = ""

    var body: some View {
        let theme = themeManager.currentTheme

        List {
            Section {
                ForEach(Array(themeManager.availableThemes.enumerated()), id: \.offset) { index, themeItem in
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
                        .onChange(of: serverAddress) { newValue in
                            monitorService.updateServerAddress(newValue)
                        }
                }

                VStack(alignment: .leading) {
                    Text("刷新间隔: \(Int(refreshInterval))秒")
                        .foregroundColor(theme.primaryTextColor)
                    Slider(value: $refreshInterval, in: 1...10, step: 1)
                        .onChange(of: refreshInterval) { newValue in
                            monitorService.updateRefreshInterval(newValue)
                        }
                }
            } header: {
                Text("连接")
                    .foregroundColor(theme.secondaryTextColor)
            }

            Section {
                HStack {
                    Text("局域网模式")
                        .foregroundColor(theme.primaryTextColor)
                    Spacer()
                    Toggle("", isOn: $terminalConfig.useLocalNetwork)
                        .labelsHidden()
                }

                HStack {
                    Text("终端 Token")
                        .foregroundColor(theme.primaryTextColor)
                    Spacer()
                    SecureField("token", text: $terminalToken)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: terminalToken) { newValue in
                            terminalConfig.token = newValue
                        }
                }

                HStack {
                    Text("终端地址")
                        .foregroundColor(theme.primaryTextColor)
                    Spacer()
                    TextField("192.168.1.x:8080", text: $terminalConfig.host)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .disabled(terminalConfig.useLocalNetwork)
                }
            } header: {
                Text("终端")
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
            terminalToken = terminalConfig.token
        }
    }
}
