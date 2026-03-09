# 皮肤系统实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现5套主题皮肤和主题管理器，让用户可以在设置中切换主题

**Architecture:** 扩展 Theme 协议，为每套皮肤创建独立的主题 struct，实现主题管理器的主题切换功能

**Tech Stack:** SwiftUI, iOS 16+

---

## Task 10: 赛博朋克皮肤

**Goal:** 创建赛博朋克风格主题

**Files:**
- Create: `ios/MacMonitor/Sources/Themes/CyberpunkTheme.swift`

**Step 1: 创建 CyberpunkTheme.swift**

```swift
import SwiftUI

struct CyberpunkTheme: Theme {
    let id = "cyberpunk"
    let name = "赛博朋克"

    let primaryColor = Color(hex: "FF00FF")
    let secondaryColor = Color(hex: "00FFFF")
    let accentColor = Color(hex: "FF00FF")

    let backgroundColor = Color(hex: "1A0A2E")
    let cardBackgroundColor = Color(hex: "2D1B4E")

    let primaryTextColor = Color.white
    let secondaryTextColor = Color(hex: "00FFFF")

    let cardCornerRadius: CGFloat = 12
    let cardShadowRadius: CGFloat = 8

    let chartColors: [Color] = [
        Color(hex: "FF00FF"),
        Color(hex: "00FFFF"),
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "FFE66D")
    ]

    let hasGlowEffect = true
    let hasGradient = true
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

**Step 2: 更新 ThemeManager 添加主题**

修改 `ios/MacMonitor/Sources/Themes/ThemeManager.swift`:

```swift
let availableThemes: [any Theme] = [
    DefaultTheme(),
    CyberpunkTheme(),
]
```

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Themes/
git commit -m "feat(theme): 添加赛博朋克皮肤"
```

---

## Task 11: 可爱皮肤

**Goal:** 创建可爱风格主题

**Files:**
- Create: `ios/MacMonitor/Sources/Themes/CuteTheme.swift`

**Step 1: 创建 CuteTheme.swift**

```swift
import SwiftUI

struct CuteTheme: Theme {
    let id = "cute"
    let name = "可爱"

    let primaryColor = Color(hex: "FFB6C1")
    let secondaryColor = Color(hex: "FFF0F5")
    let accentColor = Color(hex: "FF69B4")

    let backgroundColor = Color(hex: "FFF5F8")
    let cardBackgroundColor = Color.white

    let primaryTextColor = Color(hex: "4A4A4A")
    let secondaryTextColor = Color(hex: "8E8E93")

    let cardCornerRadius: CGFloat = 20
    let cardShadowRadius: CGFloat = 2

    let chartColors: [Color] = [
        Color(hex: "FFB6C1"),
        Color(hex: "FF69B4"),
        Color(hex: "87CEEB"),
        Color(hex: "98FB98"),
        Color(hex: "DDA0DD")
    ]

    let hasGlowEffect = false
    let hasGradient = false
}
```

**Step 2: 更新 ThemeManager**

```swift
let availableThemes: [any Theme] = [
    DefaultTheme(),
    CyberpunkTheme(),
    CuteTheme(),
]
```

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Themes/
git commit -m "feat(theme): 添加可爱皮肤"
```

---

## Task 12: 大海皮肤

**Goal:** 创建大海风格主题

**Files:**
- Create: `ios/MacMonitor/Sources/Themes/OceanTheme.swift`

**Step 1: 创建 OceanTheme.swift**

```swift
import SwiftUI

struct OceanTheme: Theme {
    let id = "ocean"
    let name = "大海"

    let primaryColor = Color(hex: "4169E1")
    let secondaryColor = Color(hex: "87CEEB")
    let accentColor = Color(hex: "00CED1")

    let backgroundColor = Color(hex: "0A1929")
    let cardBackgroundColor = Color(hex: "132F4C")

    let primaryTextColor = Color.white
    let secondaryTextColor = Color(hex: "87CEEB")

    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 4

    let chartColors: [Color] = [
        Color(hex: "4169E1"),
        Color(hex: "00CED1"),
        Color(hex: "87CEEB"),
        Color(hex: "48D1CC"),
        Color(hex: "20B2AA")
    ]

    let hasGlowEffect = true
    let hasGradient = true
}
```

**Step 2: 更新 ThemeManager**

```swift
let availableThemes: [any Theme] = [
    DefaultTheme(),
    CyberpunkTheme(),
    CuteTheme(),
    OceanTheme(),
]
```

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Themes/
git commit -m "feat(theme): 添加大海皮肤"
```

---

## Task 13: 赛博少女皮肤

**Goal:** 创建赛博少女风格主题

**Files:**
- Create: `ios/MacMonitor/Sources/Themes/CyberGirlTheme.swift`

**Step 1: 创建 CyberGirlTheme.swift**

```swift
import SwiftUI

struct CyberGirlTheme: Theme {
    let id = "cybergirl"
    let name = "赛博少女"

    let primaryColor = Color(hex: "FF69B4")
    let secondaryColor = Color(hex: "9B59B6")
    let accentColor = Color(hex: "FF1493")

    let backgroundColor = Color(hex: "1E1E2E")
    let cardBackgroundColor = Color(hex: "2D2D44")

    let primaryTextColor = Color.white
    let secondaryTextColor = Color(hex: "FF69B4")

    let cardCornerRadius: CGFloat = 16
    let cardShadowRadius: CGFloat = 6

    let chartColors: [Color] = [
        Color(hex: "FF69B4"),
        Color(hex: "9B59B6"),
        Color(hex: "FF1493"),
        Color(hex: "DA70D6"),
        Color(hex: "EE82EE")
    ]

    let hasGlowEffect = true
    let hasGradient = true
}
```

**Step 2: 更新 ThemeManager**

```swift
let availableThemes: [any Theme] = [
    DefaultTheme(),
    CyberpunkTheme(),
    CuteTheme(),
    OceanTheme(),
    CyberGirlTheme(),
]
```

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Themes/
git commit -m "feat(theme): 添加赛博少女皮肤"
```

---

## Task 14: 田园皮肤

**Goal:** 创建田园风格主题

**Files:**
- Create: `ios/MacMonitor/Sources/Themes/PastoralTheme.swift`

**Step 1: 创建 PastoralTheme.swift**

```swift
import SwiftUI

struct PastoralTheme: Theme {
    let id = "pastoral"
    let name = "田园"

    let primaryColor = Color(hex: "90EE90")
    let secondaryColor = Color(hex: "F5F5DC")
    let accentColor = Color(hex: "8FBC8F")

    let backgroundColor = Color(hex: "F5FFF5")
    let cardBackgroundColor = Color.white

    let primaryTextColor = Color(hex: "2E4A2E")
    let secondaryTextColor = Color(hex: "6B8E6B")

    let cardCornerRadius: CGFloat = 18
    let cardShadowRadius: CGFloat = 3

    let chartColors: [Color] = [
        Color(hex: "90EE90"),
        Color(hex: "8FBC8F"),
        Color(hex: "98FB98"),
        Color(hex: "9ACD32"),
        Color(hex: "32CD32")
    ]

    let hasGlowEffect = false
    let hasGradient = false
}
```

**Step 2: 更新 ThemeManager**

```swift
let availableThemes: [any Theme] = [
    DefaultTheme(),
    CyberpunkTheme(),
    CuteTheme(),
    OceanTheme(),
    CyberGirlTheme(),
    PastoralTheme(),
]
```

**Step 3: 提交**

```bash
git add ios/MacMonitor/Sources/Themes/
git commit -m "feat(theme): 添加田园皮肤"
```

---

## Task 15: 主题预览组件

**Goal:** 创建主题预览组件，用于设置页面展示和切换

**Files:**
- Create: `ios/MacMonitor/Sources/Views/ThemePreviewCard.swift`

**Step 1: 创建 ThemePreviewCard.swift**

```swift
import SwiftUI

struct ThemePreviewCard: View {
    let theme: any Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.cardBackgroundColor)
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 4) {
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(theme.secondaryColor)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 12, height: 12)
                        }
                    )

                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(theme.primaryTextColor)
            }
            .padding(8)
            .background(theme.backgroundColor)
            .cornerRadius(theme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cardCornerRadius)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

**Step 2: 提交**

```bash
git add ios/MacMonitor/Sources/Views/
git commit -m "feat(theme): 添加主题预览组件"
```

---

## 验收标准

- [ ] 6套主题全部可切换 (Default + 5 皮肤)
- [ ] 主题切换后 UI 实时更新
- [ ] 主题设置持久化到 UserDefaults
- [ ] 主题预览组件正确显示
