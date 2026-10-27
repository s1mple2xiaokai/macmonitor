# MacMonitor iOS 一键安装指南

## 快速开始

### 方式一：通过模拟器运行（开发测试用）

1. **安装 Xcode**
   ```bash
   # 在 App Store 搜索 "Xcode" 并安装
   # 或者访问 https://developer.apple.com/xcode/
   ```

2. **一键安装到模拟器**
   ```bash
   cd /Users/myk/Desktop/111
   ./install-ios.sh
   ```

---

### 方式二：通过 USB 安装到真机（需要苹果开发者账号）

需要：
- 苹果开发者账号 ($99/年)
- USB 数据线连接 iPhone 和 Mac
- Xcode 已安装

---

## 系统要求

- macOS 12.0+
- Xcode 15.0+
- iPhone/iPad (iOS 16.0+)

---

## 故障排除

### "xcodebuild: error: No simulator"

说明 Xcode 未正确安装。请从 App Store 安装完整版 Xcode。

### "No available devices"

尝试手动启动模拟器：
```bash
open -a Simulator
```

---

## 相关命令

```bash
# 查看可用模拟器
xcrun simctl list devices

# 安装到模拟器
xcrun simctl boot "iPhone 15 Pro"
xcrun simctl install booted build/iphonesimulator/MacMonitor.app
xcrun simctl launch booted com.macmonitor.MacMonitor
```
