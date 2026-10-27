#!/bin/bash

# MacMonitor 一键启动脚本

echo "🚀 MacMonitor 启动脚本"
echo "======================"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/backend"

# 1. 启动后端
echo ""
echo "📡 启动 Go 后端..."

# 检查依赖
if [ ! -f "go.sum" ]; then
    echo "   下载 Go 依赖..."
    go mod tidy
fi

go run . &
BACKEND_PID=$!
echo "✅ 后端已启动 (PID: $BACKEND_PID)"
echo "   API: http://localhost:8080"

# 等待后端启动
sleep 2

# 2. 检查 iOS 模拟器
echo ""
echo "📱 检查 iOS 模拟器..."

if ! xcrun simctl list devices &> /dev/null; then
    echo "⚠️  模拟器工具不可用"
    echo "   - 需要安装完整版 Xcode (非 Command Line Tools)"
    echo "   - 或手动在 Xcode 中运行项目"
    echo ""
else
    SIMULATOR=$(xcrun simctl list devices available | grep -E "iPhone" | head -1)
    if [ -z "$SIMULATOR" ]; then
        echo "⚠️  未找到 iPhone 模拟器，请在 Xcode 中创建"
    else
        SIMULATOR_NAME=$(echo "$SIMULATOR" | grep -oE "iPhone [0-9]+" | head -1)
        echo "   使用: $SIMULATOR_NAME"
        open -a Simulator
    fi
fi

echo ""
echo "======================"
echo "🎉 MacMonitor 运行中!"
echo "   后端: http://localhost:8080"
echo ""
echo "下一步:"
echo "   1. 打开 Xcode: open ios/MacMonitor/MacMonitor.xcodeproj"
echo "   2. 选择模拟器并运行 (Cmd+R)"
echo ""
echo "按 Ctrl+C 停止后端"

trap "kill $BACKEND_PID 2>/dev/null; echo ''; echo '🔴 已停止'; exit" INT TERM
wait
