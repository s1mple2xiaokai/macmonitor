# MacMonitor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 创建一个 iOS 原生 App，用于在手机上实时监控 Mac Mini 的系统活动（CPU/内存/磁盘/网络/进程/应用），支持5套精美皮肤切换。

**Architecture:** 整体采用客户端-服务器架构，iOS 端使用 SwiftUI 构建，Mac 端提供轻量 HTTP 服务返回 JSON 数据。通过局域网 WiFi 通信，2秒刷新频率。

**Tech Stack:**
- iOS: SwiftUI + Charts + Combine
- Mac: Go + gopsutil
- 通信: HTTP REST API

---

## 执行方式

**请选择：**

**1. Subagent-Driven (当前会话)** - 我为每个任务调度独立的 subagent，任务间进行代码审查，快速迭代

**2. Parallel Session (新会话)** - 在新会话中使用 executing-plans，批量执行带检查点

---

## 实现任务清单

### 阶段一：Mac 端服务 (Backend)

- [ ] Task 1: 创建 Go 项目结构
- [ ] Task 2: 实现系统数据采集 (CPU/内存/磁盘/网络)
- [ ] Task 3: 实现进程和应用列表采集
- [ ] Task 4: 实现 HTTP API 路由
- [ ] Task 5: 添加日志和配置管理

### 阶段二：iOS 端基础架构 (iOS Foundation)

- [ ] Task 6: 创建 XcodeGen 项目配置
- [ ] Task 7: 实现数据模型 (SystemStats, CPUStats, etc.)
- [ ] Task 8: 实现网络服务层 (MacDataService)
- [ ] Task 9: 创建主题系统基础架构

### 阶段三：皮肤系统 (Themes)

- [ ] Task 10: 实现赛博朋克皮肤
- [ ] Task 11: 实现可爱皮肤
- [ ] Task 12: 实现大海皮肤
- [ ] Task 13: 实现赛博少女皮肤（含动态立绘）
- [ ] Task 14: 实现田园皮肤
- [ ] Task 15: 实现主题管理器

### 阶段四：UI 界面 (Views)

- [ ] Task 16: 实现仪表盘 (Dashboard)
- [ ] Task 17: 实现 CPU 监控页面
- [ ] Task 18: 实现内存监控页面
- [ ] Task 19: 实现磁盘监控页面
- [ ] Task 20: 实现网络监控页面
- [ ] Task 21: 实现进程列表页面
- [ ] Task 22: 实现应用列表页面
- [ ] Task 23: 实现设置页面（皮肤切换）

### 阶段五：整合与测试 (Integration)

- [ ] Task 24: 集成所有页面到 TabView
- [ ] Task 25: 添加动画效果
- [ ] Task 26: 测试与调试

---
