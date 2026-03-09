# MacMonitor 项目 Claude PM 职责

**项目**: MacMonitor - macOS 系统监控 iOS App
**当前阶段**: 阶段二：iOS 端基础架构

---

## 项目进度

### 阶段一：Mac 端服务 ✅ 完成
- [x] Task 1: 创建 Go 项目结构
- [x] Task 2: 实现系统数据采集
- [x] Task 3: 实现进程和应用列表采集
- [x] Task 4: 实现 HTTP API 路由
- [x] Task 5: 添加日志和配置管理

### 阶段二：iOS 端基础架构 🔄 进行中
- [ ] Task 6: 创建 XcodeGen 项目配置
- [ ] Task 7: 实现数据模型
- [ ] Task 8: 实现网络服务层
- [ ] Task 9: 创建主题系统基础架构

### 阶段三：皮肤系统
- [ ] Task 10-14: 5套皮肤实现
- [ ] Task 15: 主题管理器

### 阶段四：UI 界面
- [ ] Task 16-23: 各监控页面

### 阶段五：整合与测试
- [ ] Task 24-26: 集成与测试

---

## PM 职责

1. **永不写代码** - 只调度 Codex (后端) 和 Gemini (前端) 完成实现
2. **代码审查** - 调度 Gemini 审查代码质量
3. **E2E 测试** - 调度 Gemini 使用 Playwright 测试关键流程
4. **验证通过** - 才能报告任务完成

## CCB 状态

| Provider | 状态 |
|----------|------|
| Gemini | ✅ 已连接 |
| Codex | ✅ 已连接 |
| Opencode | ❌ 未连接 |

## 下一步

继续 **阶段二：iOS 端基础架构**
- Task 6: 创建 XcodeGen 项目配置
- Task 7: 实现数据模型
- Task 8: 实现网络服务层
- Task 9: 创建主题系统基础架构
