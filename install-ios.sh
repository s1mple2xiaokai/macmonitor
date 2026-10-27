#!/bin/bash

# MacMonitor iOS 一键安装脚本
# 用法: ./install-ios.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$PROJECT_DIR/ios/MacMonitor"
BUILD_DIR="$PROJECT_DIR/build"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MacMonitor iOS 一键安装${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查 Xcode 是否安装
echo -e "${YELLOW}[1/5] 检查 Xcode...${NC}"
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}错误: Xcode 未安装${NC}"
    echo -e "${YELLOW}请从 App Store 或 https://developer.apple.com/xcode/ 安装 Xcode${NC}"
    exit 1
fi

# 检查 Xcode 版本
XCODE_VERSION=$(xcodebuild -version | head -1)
echo -e "${GREEN}✓ $XCODE_VERSION${NC}"

# 检查 XcodeGen
echo -e "${YELLOW}[2/5] 检查 XcodeGen...${NC}"
if ! command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}XcodeGen 未安装，正在安装...${NC}"
    if command -v brew &> /dev/null; then
        brew install xcodegen
    else
        echo -e "${RED}错误: Homebrew 未安装${NC}"
        echo -e "${YELLOW}请先安装 Homebrew: https://brew.sh${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ XcodeGen 已安装${NC}"

# 生成 Xcode 项目
echo -e "${YELLOW}[3/5] 生成 Xcode 项目...${NC}"
cd "$IOS_DIR"
xcodegen generate
echo -e "${GREEN}✓ 项目生成成功${NC}"

# 查找可用的模拟器
echo -e "${YELLOW}[4/5] 查找可用模拟器...${NC}"
SIMULATOR_LINE=$(xcrun simctl list devices available | grep "iPhone 17 Pro" | head -1)
if [ -z "$SIMULATOR_LINE" ]; then
    # 如果没有 iPhone 17 Pro，尝试找任何 iPhone
    SIMULATOR_LINE=$(xcrun simctl list devices available | grep "iPhone" | head -1)
fi

if [ -z "$SIMULATOR_LINE" ]; then
    echo -e "${YELLOW}警告: 未找到 iPhone 模拟器${NC}"
    echo -e "${YELLOW}请手动打开 Simulator 添加设备:${NC}"
    echo -e "${YELLOW}open -a Simulator${NC}"
    exit 1
fi

# 提取模拟器名称（在括号前）
SIMULATOR=$(echo "$SIMULATOR_LINE" | sed 's/^[[:space:]]*\(.*\) ([A-F0-9-]*).*/\1/' | xargs)
echo -e "${GREEN}✓ 使用模拟器: $SIMULATOR${NC}"

# 编译项目
echo -e "${YELLOW}[5/5] 编译并安装...${NC}"

# 创建构建目录
mkdir -p "$BUILD_DIR"

# 编译
xcodebuild -project MacMonitor.xcodeproj \
    -scheme MacMonitor \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -derivedDataPath "$BUILD_DIR" \
    build

echo -e "${GREEN}✓ 编译成功${NC}"

# 安装到模拟器
SIMULATOR_ID=$(xcrun simctl list devices available | grep "$SIMULATOR" | grep -oE "[A-F0-9-]{36}" | head -1)
if [ -z "$SIMULATOR_ID" ]; then
    # 尝试使用设备名称
    SIMULATOR_ID=$(xcrun simctl list devices available | grep -A1 "$SIMULATOR" | grep -oE "[A-F0-9-]{36}" | head -1)
fi

if [ -n "$SIMULATOR_ID" ]; then
    echo -e "${GREEN}✓ 启动模拟器...${NC}"
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    xcrun simctl install "$SIMULATOR_ID" "$BUILD_DIR/Build/Products/Debug-iphonesimulator/MacMonitor.app" || true
    echo -e "${GREEN}✓ 安装成功${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}启动应用:${NC}"
echo -e "  方式1: 在 Simulator 中点击 MacMonitor 图标"
echo -e "  方式2: 命令行启动"
if [ -n "$SIMULATOR_ID" ]; then
    echo -e "         xcrun simctl launch booted com.macmonitor.MacMonitor --args\"-SimulatorTargetDeviceUUID=$SIMULATOR_ID\""
fi
echo ""
echo -e "${YELLOW}后端服务:${NC}"
echo -e "  确保 Go 后端已运行: cd backend && go run main.go"
echo -e "  默认地址: http://localhost:8080"
echo ""
