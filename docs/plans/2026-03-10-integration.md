# 整合与测试实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 集成所有页面到 TabView，添加动画效果，完成测试

**Tech Stack:** SwiftUI, NavigationStack, TabView

---

## Task 24: 集成所有页面到 TabView

**Goal:** 将所有页面集成到主导航结构，使用 TabView

**Files:**
- Modify: `ios/MacMonitor/Sources/ContentView.swift`

**Step 1: 更新 ContentView.swift**

```swift
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
```

**Step 2: 更新 MacMonitorApp.swift 启动监控**

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

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/ContentView.swift ios/MacMonitor/Sources/App/MacMonitorApp.swift
git commit -m "feat(integration): 集成所有页面到 TabView"
```

---

## Task 25: 添加动画效果

**Goal:** 为页面切换和数据更新添加动画

**Files:**
- Modify: `ios/MacMonitor/Sources/Views/DashboardView.swift`
- Modify: `ios/MacMonitor/Sources/Views/CPUView.swift`
- Modify: `ios/MacMonitor/Sources/Views/MemoryView.swift`

**Step 1: 添加主题切换动画**

创建 `ios/MacMonitor/Sources/Views/ThemedView.swift`:

```swift
import SwiftUI

struct ThemedViewModifier: ViewModifier {
    let theme: any Theme
    @ObservedObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.themeId == "default" ? .none : .dark)
            .animation(.easeInOut(duration: 0.3), value: themeManager.themeId)
    }
}

extension View {
    func themed(_ themeManager: ThemeManager) -> some View {
        modifier(ThemedViewModifier(theme: themeManager.currentTheme, themeManager: themeManager))
    }
}
```

**Step 2: 为数字变化添加动画**

更新 DashboardView 中的数值显示部分，添加 `.animation(.easeInOut, value: viewModel.cpuUsage)` 等

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Views/
git commit -m "feat(animation): 添加主题切换和数据更新动画"
```

---

## Task 26: 测试与调试

**Goal:** 确保应用可以编译运行，修复发现的问题

**Files:**
- 验证项目编译

**Step 1: 验证 XcodeGen 生成**

```bash
cd ios/MacMonitor
xcodegen generate
```

**Step 2: 提交**

```bash
git commit -m "test: 验证项目编译"
```

---

## 验收标准

- [ ] TabView 包含所有 8 个页面
- [ ] 页面切换流畅
- [ ] 主题切换有动画过渡
- [ ] 数据更新有动画效果
- [ ] 项目可编译
