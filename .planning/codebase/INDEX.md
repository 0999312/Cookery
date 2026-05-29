# 代码库分析索引

> 自动生成于 2026/05/29

## 文档列表

| 文档 | 行数 | 描述 |
|------|------|------|
| [STACK.md](STACK.md) | 90 | 技术栈分析 - 引擎、插件、依赖、配置 |
| [INTEGRATIONS.md](INTEGRATIONS.md) | 159 | 集成分析 - MCP、ClaudeCode、Skills、工具 |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 315 | 架构分析 - 系统架构、核心模式、数据流 |
| [STRUCTURE.md](STRUCTURE.md) | 357 | 结构分析 - 目录组织、文件模式、模块职责 |
| [CONVENTIONS.md](CONVENTIONS.md) | 327 | 约定分析 - 命名、代码风格、最佳实践 |
| [TESTING.md](TESTING.md) | 584 | 测试分析 - 框架、策略、测试清单 |
| [CONCERNS.md](CONCERNS.md) | 331 | 关注点 - 技术债务、问题、风险、优化 |

**总计**: 2163 行分析文档

## 快速参考

### 技术栈
- Godot 4.6.2 stable (Mobile 渲染, Jolt 物理)
- 6 个插件: mc_game_framework, guide, dialogue_manager, sound_manager, gut, kenney_interface_sounds
- GDScript 静态类型

### 架构模式
- EventBus 跨系统通信
- UIManager 面板栈管理
- Resource 数据驱动
- GUIDE 输入上下文

### 关键问题 (P0)
1. EventBus/UIManager 双重实现冲突
2. 缺少框架 Autoload 注册
3. main_menu.gd 引用断裂

### 下一步
- `/gsd-new-project` - 初始化项目规划
- `/gsd-plan-phase` - 规划具体阶段