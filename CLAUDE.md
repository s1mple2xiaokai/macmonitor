# MacMonitor 项目 Claude PM 职责

**项目**: MacMonitor - macOS 系统监控 iOS App
**当前阶段**: 阶段三已完成

---

## 项目进度

### 阶段一：Mac 端服务 ✅ 完成
- [x] Task 1: 创建 Go 项目结构
- [x] Task 2: 实现系统数据采集
- [x] Task 3: 实现进程和应用列表采集
- [x] Task 4: 实现 HTTP API 路由
- [x] Task 5: 添加日志和配置管理

### 阶段二：iOS 端基础架构 ✅ 完成
- [x] Task 6: 创建 XcodeGen 项目配置
- [x] Task 7: 实现数据模型
- [x] Task 8: 实现网络服务层
- [x] Task 9: 创建主题系统基础架构

### 阶段三：皮肤系统 ✅ 完成
- [x] Task 10: 赛博朋克皮肤
- [x] Task 11: 可爱皮肤
- [x] Task 12: 大海皮肤
- [x] Task 13: 赛博少女皮肤
- [x] Task 14: 田园皮肤
- [x] Task 15: 主题预览组件

### 阶段四：UI 界面
- [ ] Task 16: 实现仪表盘
- [ ] Task 17: 实现 CPU 监控页面
- [ ] Task 18: 实现内存监控页面
- [ ] Task 19: 实现磁盘监控页面
- [ ] Task 20: 实现网络监控页面
- [ ] Task 21: 实现进程列表页面
- [ ] Task 22: 实现应用列表页面
- [ ] Task 23: 实现设置页面

### 阶段五：整合与测试
- [ ] Task 24: 集成所有页面到 TabView
- [ ] Task 25: 添加动画效果
- [ ] Task 26: 测试与调试

---

## PM 职责

1. **永不写代码** - 只调度 Codex (后端) 和 Gemini (前端) 完成实现
2. **代码审查** - 调度 Codex/Gemini 审查代码质量
3. **E2E 测试** - 调度 Gemini 使用 Playwright 测试关键流程
4. **验证通过** - 才能报告任务完成

## CCB 状态

| Provider | 状态 |
|----------|------|
| Gemini | ✅ 已连接 |
| Codex | ✅ 已连接 |
| Opencode | ❌ 未连接 |

## 项目文件结构

```
/Users/myk/Desktop/111/
├── docs/plans/
│   ├── 2026-03-10-macmonitor-design.md
│   ├── 2026-03-10-macmonitor-implementation-plan.md
│   ├── 2026-03-10-ios-infrastructure.md
│   └── 2026-03-10-theme-system.md
├── backend/                    # Go 后端
│   ├── main.go
│   ├── config/
│   ├── logger/
│   ├── handlers/
│   ├── models/
│   └── collectors/
└── ios/MacMonitor/            # iOS 前端
    ├── project.yml
    ├── Sources/
    │   ├── App/MacMonitorApp.swift
    │   ├── ContentView.swift
    │   ├── Models/ (7个模型文件)
    │   ├── Services/ (APIClient, MonitorService)
    │   ├── Themes/ (6套皮肤 + ThemeManager)
    │   └── Views/ (ThemePreviewCard)
    └── Resources/Assets.xcassets/
```

## 下一步

继续 **阶段四：UI 界面**
- Task 16: 实现仪表盘
- Task 17: 实现 CPU 监控页面
- Task 18: 实现内存监控页面
- Task 19: 实现磁盘监控页面
- Task 20: 实现网络监控页面
- Task 21: 实现进程列表页面
- Task 22: 实现应用列表页面
- Task 23: 实现设置页面
