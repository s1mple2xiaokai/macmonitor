# iOS 基础架构实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 为 MacMonitor iOS App 创建基础项目结构、数据模型、网络层和主题系统

**Architecture:** 采用 SwiftUI + MVVM 架构，网络层使用 Combine，数据持久化使用 UserDefaults

**Tech Stack:** SwiftUI, Combine, Charts (iOS 16+), XcodeGen

---

## Task 6: XcodeGen 项目配置

**Goal:** 创建 XcodeGen 项目配置文件，生成 .xcodeproj

**Files:**
- Create: `ios/MacMonitor/project.yml`
- Create: `ios/MacMonitor/Sources/App/MacMonitorApp.swift`
- Create: `ios/MacMonitor/Sources/ContentView.swift`

**Step 1: 检查 XcodeGen 是否安装**

Run: `which xcodegen || brew install xcodegen`
Expected: 路径输出或安装成功

**Step 2: 创建目录结构**

```bash
mkdir -p ios/MacMonitor/Sources/{App,Models,Services,Views,ViewModels,Themes}
mkdir -p ios/MacMonitor/Resources
```

**Step 3: 创建 project.yml**

```yaml
name: MacMonitor
options:
  bundleIdPrefix: com.macmonitor
  deploymentTarget:
    iOS: "16.0"
  xcodeVersion: "15.0"

settings:
  base:
    SWIFT_VERSION: "5.9"
    GENERATE_INFOPLIST_FILE: YES
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"
    DEVELOPMENT_TEAM: ""

targets:
  MacMonitor:
    type: application
    platform: iOS
    sources:
      - path: Sources
    settings:
      base:
        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: YES
        INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: YES
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"
        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: "UIInterfaceOrientationPortrait"
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        CODE_SIGN_STYLE: Automatic
        TARGETED_DEVICE_FAMILY: "1,2"
```

**Step 4: 创建入口文件 Sources/App/MacMonitorApp.swift**

```swift
import SwiftUI

@main
struct MacMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Step 5: 创建 ContentView.swift**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("MacMonitor")
    }
}

#Preview {
    ContentView()
}
```

**Step 6: 生成 Xcode 项目**

Run: `cd ios/MacMonitor && xcodegen generate`
Expected: 项目生成成功

**Step 7: 提交**

```bash
git add ios/MacMonitor/
git commit -m "feat(ios): 添加 XcodeGen 项目配置"
```

---

## Task 7: 数据模型实现

**Goal:** 创建与 Go 后端对应的 Swift 数据模型

**Files:**
- Create: `ios/MacMonitor/Sources/Models/SystemStats.swift`
- Create: `ios/MacMonitor/Sources/Models/CPUStats.swift`
- Create: `ios/MacMonitor/Sources/Models/MemoryStats.swift`
- Create: `ios/MacMonitor/Sources/Models/DiskStats.swift`
- Create: `ios/MacMonitor/Sources/Models/NetworkStats.swift`
- Create: `ios/MacMonitor/Sources/Models/ProcessInfo.swift`
- Create: `ios/MacMonitor/Sources/Models/AppInfo.swift`

**Step 1: 创建 SystemStats.swift**

```swift
import Foundation

struct SystemStats: Codable, Identifiable {
    var id: Date { timestamp }
    let cpu: CPUStats
    let memory: MemoryStats
    let disks: [DiskStats]
    let network: NetworkStats
    let processes: [ProcessInfo]
    let apps: [AppInfo]
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case cpu, memory, disks, network, processes, apps, timestamp
    }
}
```

**Step 2: 创建 CPUStats.swift**

```swift
import Foundation

struct CPUStats: Codable {
    let usage: Double          // 0-100
    let cores: Int
    let perCoreUsage: [Double] // 每核心使用率
    let model: String?
    let frequency: Double?
}
```

**Step 3: 创建 MemoryStats.swift**

```swift
import Foundation

struct MemoryStats: Codable {
    let used: UInt64           // bytes
    let total: UInt64
    let available: UInt64
    let swap: UInt64
    let percent: Double
    let appMemory: UInt64?
    let wiredMemory: UInt64?
    let compressed: UInt64?
}
```

**Step 4: 创建 DiskStats.swift**

```swift
import Foundation

struct DiskStats: Codable, Identifiable {
    var id: String { device }
    let device: String
    let mountPoint: String
    let total: UInt64
    let used: UInt64
    let free: UInt64
    let percent: Double
}
```

**Step 5: 创建 NetworkStats.swift**

```swift
import Foundation

struct NetworkStats: Codable {
    let bytesSent: UInt64
    let bytesRecv: UInt64
    let packetsSent: UInt64
    let packetsRecv: UInt64
    let interfaces: [NetworkInterface]
}

struct NetworkInterface: Codable, Identifiable {
    var id: String { name }
    let name: String
    let bytesSent: UInt64
    let bytesRecv: UInt64
}
```

**Step 6: 创建 ProcessInfo.swift**

```swift
import Foundation

struct ProcessInfo: Codable, Identifiable {
    var id: Int32 { pid }
    let pid: Int32
    let name: String
    let cpuPercent: Double
    let memoryPercent: Double
    let memory: UInt64
    let status: String?
}
```

**Step 7: 创建 AppInfo.swift**

```swift
import Foundation

struct AppInfo: Codable, Identifiable {
    var id: Int32 { pid }
    let pid: Int32
    let name: String
    let bundleId: String?
    let isActive: Bool
}
```

**Step 8: 提交**

```bash
git add ios/MacMonitor/Sources/Models/
git commit -m "feat(ios): 添加数据模型"
```

---

## Task 8: 网络服务层实现

**Goal:** 实现 HTTP 客户端，定时轮询后端 API

**Files:**
- Create: `ios/MacMonitor/Sources/Services/MonitorService.swift`
- Create: `ios/MacMonitor/Sources/Services/APIClient.swift`

**Step 1: 创建 APIClient.swift**

```swift
import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .serverError(let code): return "Server error: \(code)"
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
```

**Step 2: 创建 MonitorService.swift**

```swift
import Foundation
import Combine

@MainActor
class MonitorService: ObservableObject {
    static let shared = MonitorService()

    @Published var stats: SystemStats?
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    @Published var serverAddress: String = "http://localhost:8080"

    private var timer: AnyCancellable?
    private var refreshInterval: TimeInterval = 2.0

    private init() {
        loadServerAddress()
    }

    func startMonitoring() {
        stopMonitoring()

        timer = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.fetchStats()
                }
            }

        Task {
            await fetchStats()
        }
    }

    func stopMonitoring() {
        timer?.cancel()
        timer = nil
    }

    func fetchStats() async {
        guard let url = URL(string: "\(serverAddress)/api/stats") else {
            errorMessage = "Invalid server address"
            isConnected = false
            return
        }

        do {
            let newStats = try await APIClient.shared.fetch(SystemStats.self, from: url)
            self.stats = newStats
            self.isConnected = true
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            self.isConnected = false
        }
    }

    func updateServerAddress(_ address: String) {
        serverAddress = address
        saveServerAddress()
    }

    func updateRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = interval
        if timer != nil {
            startMonitoring()
        }
    }

    private func saveServerAddress() {
        UserDefaults.standard.set(serverAddress, forKey: "serverAddress")
    }

    private func loadServerAddress() {
        if let saved = UserDefaults.standard.string(forKey: "serverAddress") {
            serverAddress = saved
        }
    }
}
```

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Services/
git commit -m "feat(ios): 添加网络服务层"
```

---

## Task 9: 主题系统基础架构

**Goal:** 创建主题协议和默认主题实现

**Files:**
- Create: `ios/MacMonitor/Sources/Themes/Theme.swift`
- Create: `ios/MacMonitor/Sources/Themes/ThemeManager.swift`
- Create: `ios/MacMonitor/Sources/Themes/DefaultTheme.swift`

**Step 1: 创建 Theme.swift (协议)**

```swift
import SwiftUI

protocol Theme: ObservableObject {
    var id: String { get }
    var name: String { get }

    // 主色调
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }

    // 背景
    var backgroundColor: Color { get }
    var cardBackgroundColor: Color { get }

    // 文字
    var primaryTextColor: Color { get }
    var secondaryTextColor: Color { get }

    // 组件样式
    var cardCornerRadius: CGFloat { get }
    var cardShadowRadius: CGFloat { get }

    // 图表颜色
    var chartColors: [Color] { get }

    // 特殊效果
    var hasGlowEffect: Bool { get }
    var hasGradient: Bool { get }
}
```

**Step 2: 创建 DefaultTheme.swift**

```swift
import SwiftUI

struct DefaultTheme: Theme {
    let id = "default"
    let name = "Default"

    let primaryColor = Color.blue
    let secondaryColor = Color.gray
    let accentColor = Color.orange

    let backgroundColor = Color(.systemBackground)
    let cardBackgroundColor = Color(.secondarySystemBackground)

    let primaryTextColor = Color.primary
    let secondaryTextColor = Color.secondary

    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 4

    let chartColors: [Color] = [.blue, .green, .orange, .red, .purple]

    let hasGlowEffect = false
    let hasGradient = false
}
```

**Step 3: 创建 ThemeManager.swift**

```swift
import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: any Theme = DefaultTheme()
    @Published var themeId: String = "default"

    private let themeStorageKey = "selectedThemeId"

    let availableThemes: [any Theme] = [
        DefaultTheme(),
    ]

    private init() {
        loadTheme()
    }

    func setTheme(_ theme: any Theme) {
        currentTheme = theme
        themeId = theme.id
        saveTheme()
    }

    func setThemeById(_ id: String) {
        if let theme = availableThemes.first(where: { $0.id == id }) {
            setTheme(theme)
        }
    }

    private func saveTheme() {
        UserDefaults.standard.set(themeId, forKey: themeStorageKey)
    }

    private func loadTheme() {
        if let savedId = UserDefaults.standard.string(forKey: themeStorageKey) {
            setThemeById(savedId)
        }
    }
}
```

**Step 4: 提交**

```bash
git add ios/MacMonitor/Sources/Themes/
git commit -m "feat(ios): 添加主题系统基础架构"
```

---

## 验收标准

- [ ] XcodeGen 生成项目成功
- [ ] 项目可在 iOS Simulator 中编译运行
- [ ] 数据模型与后端 JSON 对应
- [ ] 网络服务可获取系统数据
- [ ] 主题系统可切换主题
- [ ] 代码遵循 Swift 规范
