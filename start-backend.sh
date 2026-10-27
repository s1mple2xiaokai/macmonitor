#!/bin/bash

# MacMonitor 一键启动脚本（后端 + iOS）
# 用法: ./start.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$PROJECT_DIR/backend"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MacMonitor 一键启动${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 启动后端服务
echo -e "${YELLOW}启动后端服务...${NC}"
cd "$BACKEND_DIR"

# 检查是否已编译
if [ ! -f "./macmonitor" ]; then
    echo -e "编译后端..."
    go build -o macmonitor .
fi

# 后台运行后端
./macmonitor &
BACKEND_PID=$!

echo -e "${GREEN}✓ 后端已启动 (PID: $BACKEND_PID)${NC}"
echo -e "${GREEN}✓ API 地址: http://localhost:8080${NC}"
echo ""

# 等待后端启动
sleep 2

# 检查后端是否运行
if kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${GREEN}后端服务运行正常${NC}"
else
    echo -e "${RED}后端启动失败${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MacMonitor 运行中${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "停止服务: kill $BACKEND_PID"
echo ""
