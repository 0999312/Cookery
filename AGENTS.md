# Cookery — Agent 指令

> 项目：Godot 4.6 沙盒烹饪游戏「厨房」
> 设计文档：`.planning/PROJECT.md`
> 语言：所有思考与输出均使用中文。

---

## 核心原则

### 1. Addon 优先

实现任何功能时，**先查 `addons/` 目录是否有现成方案**，再考虑自研。

| 插件 | Autoload | 覆盖范围 |
|------|----------|----------|
| `mc_game_framework` | `RegistryManager` | EventBus 跨系统通信、UIManager 界面栈、I18N 多语言、Registry 数据注册 |
| `sound_manager` | `SoundManager` | 背景音乐、音效、环境音播放与混音 |
| `guide` | `GUIDE` | 输入映射、输入上下文切换（替代原生 Input Map） |
| `dialogue_manager` | `DialogueManager` | 分支对话、条件判断、对话 UI |
| `gut` | — | GDScript 单元测试框架 |
| `kenney_interface_sounds` | — | 预制 UI 音效素材包 |

**决策流程：**
1. 需求拆解后，先在对应插件源码（`addons/<name>/`）中搜索是否已有接口
2. 插件可满足 → 直接使用，遵循其 API 约定
3. 插件部分满足 → 扩展插件，不重写其核心
4. 插件完全不覆盖 → 自研，但复用插件提供的基础设施（EventBus、Resource 模式等）

### 2. 最佳实践代码

- **静态类型**：所有变量声明标注类型（`var hp: int = 100`），返回值标注（`-> void`）
- **4 空格缩进**，常量 `UPPER_SNAKE_CASE`，枚举 `enum`
- **节点引用**：优先 `%UniqueName`，避免绝对路径 `$"../../.."`
- **时间相关**：`_process(delta)` 中所有速度/计时乘以 `delta`
- **输入检测**：通过 `GUIDE` 上下文系统，不直接 `Input.is_action_*`，不硬编码键名
- **信号连接**：优先编辑器绑定；代码连接时使用 `signal.connect(callable)` 语法
- **`@onready`**：仅延迟初始化时使用，不在 `_ready()` 中赋值后又声明 `@onready`
- **Resource 数据驱动**：游戏数据用 `Resource` 子类定义，JSON 仅用于外部编辑/模组
- **场景组织**：单一职责原则，一个 `.tscn` 做一件事；组合优于继承

### 3. 工具优先

处理 Godot 相关任务时，**按以下顺序调用工具**：

| 优先级 | 工具 | 用途 |
|--------|------|------|
| 1 | **MCP: `godot-docs`** | 查阅 Godot 官方文档（类、方法、属性、信号、常量），以返回内容为准 |
| 2 | **MCP: `godot-mcp`** | 场景操作、节点管理、项目运行/停止等编辑器级操作 |
| 3 | **Skills: GodotPrompter** | 领域专项指导（见下方 Skills 速查表） |
| 4 | **Skills: `game-architect`** | 架构设计、范式选择、系统规划 |
| 5 | 插件源码 | 当 MCP 文档无法覆盖插件 API 时，直接阅读 `addons/` 源码 |
| 6 | 自行推理 | 以上均无覆盖时，基于 Godot 4.x 惯用法推理 |

**MCP 服务端点：**
- `godot-docs` — `@nuskey8/godot-docs-mcp`（`.mcp.json` 已配置）
- `godot-mcp` — `@coding-solo/godot-mcp`（`opencode.json` 已配置）

---

## Skills 速查表

| 场景 | Skill | 说明 |
|------|-------|------|
| 架构规划/范式选择 | `game-architect` | DDD / Data-Driven / 混合范式指导 |
| 2D 系统（TileMap、视差、灯光） | `godot-prompter:2d-essentials` | |
| UI 构建 | `godot-prompter:godot-ui` | Control 节点、容器、主题 |
| 响应式/多分辨率 UI | `godot-prompter:responsive-ui` | |
| 玩家控制器 | `godot-prompter:player-controller` | CharacterBody2D、输入、物理 |
| 输入系统 | `godot-prompter:input-handling` | InputEvent、重映射、手柄 |
| 动画系统 | `godot-prompter:animation-system` | AnimationPlayer/Tree、状态机 |
| Tween 动画 | `godot-prompter:tween-animation` | 属性动画、缓动曲线 |
| 粒子特效 | `godot-prompter:particles-vfx` | GPUParticles2D/3D |
| 音频系统 | `godot-prompter:audio-system` | 音频总线、空间音频、混音 |
| 资源模式（Resource） | `godot-prompter:resource-pattern` | 自定义 Resource 数据容器 |
| 状态机 | `godot-prompter:state-machine` | 枚举/节点/资源 FSM |
| 事件总线 | `godot-prompter:event-bus` | 解耦通信 |
| 组件系统 | `godot-prompter:component-system` | 组合式节点组件 |
| 场景组织 | `godot-prompter:scene-organization` | 场景树设计、拆分策略 |
| 依赖注入 | `godot-prompter:dependency-injection` | Autoload、@export 注入 |
| 存档/读档 | `godot-prompter:save-load` | JSON/ConfigFile/Resource 序列化 |
| 本地化 | `godot-prompter:localization` | TranslationServer、CSV/PO |
| 对话系统 | `godot-prompter:dialogue-system` | 分支对话数据结构 |
| 库存系统 | `godot-prompter:inventory-system` | 物品槽、堆叠、UI 绑定 |
| HUD | `godot-prompter:hud-system` | 血条、小地图、通知 |
| 相机系统 | `godot-prompter:camera-system` | 跟随、震屏、转场 |
| 程序化生成 | `godot-prompter:procedural-generation` | 噪声地形、BSP、WFC |
| GDScript 高级 | `godot-prompter:gdscript-advanced` | 性能惯用法、元编程、异步陷阱 |
| GDScript 模式 | `godot-prompter:gdscript-patterns` | 静态类型、await、lambda、match |
| Shader | `godot-prompter:shader-basics` | Godot 着色器语言、Visual Shader |
| 性能优化 | `godot-prompter:godot-optimization` | Profiler、绘制调用、物理调优 |
| 调试 | `godot-prompter:godot-debugging` | 远程调试、信号追踪、常见错误 |
| 代码审查 | `godot-prompter:godot-code-review` | 最佳实践检查、反模式识别 |
| 测试 | `godot-prompter:godot-testing` | GUT / gdUnit4 TDD |
| 导出发布 | `godot-prompter:export-pipeline` | 导出预设、CI/CD |
| 插件开发 | `godot-prompter:addon-development` | EditorPlugin、@tool 脚本 |
| 数学基础 | `godot-prompter:math-essentials` | 向量、变换、插值、曲线 |
| 物理系统 | `godot-prompter:physics-system` | 碰撞、射线、Jolt、物理插值 |

---

## 架构约束

| 规则 | 说明 |
|------|------|
| **EventBus 是唯一跨系统通信通道** | 系统间不直接引用，通过 EventBus 发射/监听信号 |
| **UI 必须通过 UIManager** | 不直接 `add_child()` 面板，由 UIManager 管理生命周期和界面栈 |
| **输入通过 GUIDE 上下文** | 不直接使用 `Input.is_action_*`，通过 GUIDE 上下文切换管理输入映射 |
| **Resource 是数据权威** | 运行时数据用 Resource 子类；JSON 仅用于外部编辑和模组支持 |

---

## GSD 工作流

本项目使用 GSD（Get Shit Done）工作流管理开发进度：

| 命令 | 用途 |
|------|------|
| `/gsd-discuss-phase N` | 讨论阶段 N 的决策 |
| `/gsd-plan-phase N` | 创建阶段 N 的执行计划 |
| `/gsd-execute-phase N` | 执行阶段 N 的计划 |
| `/gsd-code-review` | 代码审查 |
| `/gsd-quick` | 快速修复 |

**规划文档位置**: `.planning/`

---

## 开发行为准则

- **不确定时主动发问**：遇到模糊需求、不明确的节点架构或多种可行方案时，向开发者确认。
- **保持简洁**：用最少节点和代码完成任务。一个脚本能解决就不抽象接口。
- **只改任务相关代码**：不触碰正交的不相关场景、脚本、资源。
- **发现更好方案时主动提出**：发现需求矛盾或更优 Godot 惯用方案时，提出建议。
- **原型先行**：复杂功能优先搭建可运行的最小原型，再迭代打磨。