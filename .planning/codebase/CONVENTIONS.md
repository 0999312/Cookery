# Cookery 项目约定分析

> 最后更新：2026/05/29
> 分析范围：项目根目录、scripts/、scenes/、addons/mc_game_framework/

---

## 1. 命名约定

### 1.1 文件命名

| 类型 | 约定 | 示例 |
|------|------|------|
| GDScript 文件 | `snake_case.gd` | `event_bus.gd`, `ui_manager.gd` |
| 场景文件 | `snake_case.tscn` | `main_menu.tscn` |
| 测试文件 | `test_` 前缀 + `snake_case.gd` | `test_inventory.gd` |
| Resource 文件 | `snake_case.tres` | `minimal_vector.tres` |
| 类名文件 | 文件名与 `class_name` 对应 | `resource_location.gd` → `class_name ResourceLocation` |

### 1.2 代码命名

| 类型 | 约定 | 示例 |
|------|------|------|
| 类名 | `PascalCase` | `UIPanel`, `ResourceLocation`, `DataResult` |
| 函数/方法 | `snake_case` | `open_panel()`, `_on_open()` |
| 私有函数 | `_` 前缀 + `snake_case` | `_update_caches()`, `_do_close_panel()` |
| 生命周期回调 | `_on_` 前缀 | `_on_init()`, `_on_open()`, `_on_close()` |
| 变量 | `snake_case` | `panel_stack`, `_active_panel` |
| 私有变量 | `_` 前缀 + `snake_case` | `_listeners`, `_cached_panels` |
| 常量 | `UPPER_SNAKE_CASE` | `LAYER_NORMAL`, `MAX_OPEN_DEPTH` |
| 枚举值 | `UPPER_SNAKE_CASE` | `CacheMode.NONE`, `UILayer.NORMAL` |
| 信号 | `snake_case` | `game_started`, `ui_panel_opened` |
| 布尔 getter | `is_` 或 `has_` 前缀 | `is_success()`, `has_entry()` |

### 1.3 路径标识符

- 使用 Minecraft 风格的 `namespace:path` 格式
- 示例：`cookery:equipment/stove`, `cookery:material/flour`
- 以 `.to_string()` 作为 Dictionary 键（RefCounted 身份比较不可靠）

---

## 2. 代码风格

### 2.1 缩进与格式

| 规则 | 说明 |
|------|------|
| 缩进 | 4 空格（无制表符） |
| 行尾 | LF（`.gitattributes` 强制转换） |
| 字符集 | UTF-8（`.editorconfig` 配置） |
| 空行 | 函数之间添加空行 |

### 2.2 注释规范

| 类型 | 语法 | 用途 |
|------|------|------|
| 文档注释 | `##` | 公共 API、类描述、Inspector 属性 |
| 内联注释 | `#` | 实现细节、非显而易见的决策 |
| 中文注释 | 允许 | 项目交流语言为中文 |

**示例：**
```gdscript
## UI 管理器 - 管理所有 UI 面板的生命周期
##
## 负责面板的打开、关闭、暂停、恢复
## 管理 UI 层级和面板栈

extends Node

## UI 层级常量
const LAYER_BACKGROUND: int = 0
const LAYER_NORMAL: int = 10
```

### 2.3 类型标注

**强制要求：**
- 所有变量声明必须标注类型
- 所有函数返回值必须标注类型
- 参数必须标注类型

**示例：**
```gdscript
var _panel_stack: Array[Node] = []
var _active_panel: Node = null
var _panel_cache: Dictionary = {}

func open_panel(panel_scene: String, data: Dictionary = {}, layer: int = LAYER_NORMAL) -> Node:
    pass

func _on_open(_data: Dictionary = {}) -> void:
    pass
```

**特殊情况：**
- 使用 `Variant` 表示接受多种类型的参数
- 使用 `Variant` 存储异构数据（如 Registry/Container 模式）

### 2.4 函数设计

| 规则 | 说明 |
|------|------|
| 返回值 | 始终标注返回类型 |
| 可选结果 | 返回 `null` 或 `false` |
| 丰富错误上下文 | 返回 `DataResult` |
| 默认值 | 可选参数使用默认值 |
| 未使用参数 | 使用 `_` 前缀（如 `_data`） |
| Lambda 未使用参数 | 使用 `_` 或 `ig`（如 `func(ig, ig2):`） |

---

## 3. 架构约定

### 3.1 核心架构原则

| 原则 | 说明 |
|------|------|
| **Addon 优先** | 先查 `addons/` 是否有现成方案，再考虑自研 |
| **EventBus 是唯一跨系统通信通道** | 系统间不直接引用，通过 EventBus 解耦 |
| **UI 必须通过 UIManager** | 不直接 `add_child()` 面板 |
| **输入通过 GUIDE 上下文** | 不直接使用 `Input.is_action_*` |
| **Resource 是数据权威** | 运行时数据用 Resource 子类；JSON 仅用于外部编辑 |

### 3.2 Autoload 单例

| 单例 | 职责 |
|------|------|
| `EventBus` | 跨系统事件发布/订阅 |
| `UIManager` | 面板栈管理、生命周期 |
| `AudioManager` | 音频播放、音量控制 |
| `SaveManager` | 存档/读档、设置管理 |
| `RegistryManager` | 数据注册中心（mc_game_framework） |
| `I18NManager` | 多语言支持（mc_game_framework） |
| `GUIDE` | 输入映射与上下文管理 |

### 3.3 EventBus 模式

**发布事件：**
```gdscript
EventBus.game_started.emit()
EventBus.ui_panel_opened.emit(panel_scene)
```

**订阅事件：**
```gdscript
EventBus.music_requested.connect(_on_music_requested)
EventBus.save_requested.connect(save_game)
```

**事件定义规范：**
- 信号在 EventBus 中统一定义
- 使用 `snake_case` 命名
- 提供类型化的参数（如 `is_paused: bool`）

### 3.4 UIManager 模式

**打开面板：**
```gdscript
UIManager.open_panel(SETTINGS_SCENE)
UIManager.open_panel(panel_scene, data, layer)
```

**面板生命周期：**
```gdscript
func _on_init() -> void:     # 首次创建
func _on_open(data) -> void: # 每次打开
func _on_pause() -> void:    # 被覆盖
func _on_resume() -> void:   # 恢复显示
func _on_close() -> void:    # 从栈移除
func _on_destroy() -> void:  # 销毁前
```

**缓存模式：**
- `CacheMode.NONE` — 关闭时销毁（`queue_free`）
- `CacheMode.CACHE` — 关闭时隐藏，下次复用

### 3.5 Resource 数据驱动

**原则：**
- 游戏数据用 `Resource` 子类定义
- JSON 仅用于外部编辑和模组支持
- Codec 系统负责序列化/反序列化

**ResourceLocation 标识：**
```gdscript
const PANEL_ID: ResourceLocation = ResourceLocation.from("cookery:ui/settings")
```

### 3.6 节点引用

| 方式 | 用途 | 示例 |
|------|------|------|
| `%UniqueName` | 优先使用 | `@onready var button: Button = %StartButton` |
| `@onready` | 延迟初始化 | 不在 `_ready()` 中赋值后又声明 |
| 绝对路径 | 避免使用 | 不使用 `$"../../.."` |

---

## 4. 最佳实践

### 4.1 输入处理

**正确做法：**
```gdscript
# 通过 GUIDE 上下文系统
var action = GUIDE.create_action("interact")
if action.is_pressed():
    pass
```

**错误做法：**
```gdscript
# 直接使用 Input（禁止）
if Input.is_action_just_pressed("interact"):
    pass
```

### 4.2 时间处理

**正确做法：**
```gdscript
func _process(delta: float) -> void:
    position += velocity * delta
    _timer += delta
```

**错误做法：**
```gdscript
func _process(delta: float) -> void:
    position += velocity  # 忘记乘以 delta
```

### 4.3 信号连接

**推荐语法：**
```gdscript
button.pressed.connect(_on_button_pressed)
signal.connect(callable)
```

**编辑器绑定优先：**
- 在场景编辑器中连接信号
- 代码连接作为补充

### 4.4 场景组织

| 原则 | 说明 |
|------|------|
| 单一职责 | 一个 `.tscn` 做一件事 |
| 组合优于继承 | 使用节点组合而非深层继承 |
| 场景拆分 | 复杂 UI 拆分为子场景 |

### 4.5 错误处理

| 情况 | 方法 |
|------|------|
| 不可恢复错误 | `push_error()` |
| 可恢复问题 | `push_warning()` |
| 调试输出 | `print()`（生产环境移除） |
| 丰富错误上下文 | `DataResult` |

### 4.6 性能优化

- 使用对象池（如音频播放器池）
- 缓存已加载的资源
- 使用 `create_tween()` 进行动画
- 避免在 `_process()` 中创建新对象

---

## 5. 工具优先级

| 优先级 | 工具 | 用途 |
|--------|------|------|
| 1 | MCP: `godot-docs` | Godot 官方文档查询 |
| 2 | MCP: `godot-mcp` | 场景操作、节点管理 |
| 3 | Skills: GodotPrompter | 领域专项指导 |
| 4 | Skills: `game-architect` | 架构设计 |
| 5 | 插件源码 | 直接阅读 `addons/` |
| 6 | 自行推理 | 基于 Godot 4.x 惯用法 |

---

## 6. 开发行为准则

- **不确定时主动发问**：遇到模糊需求时向开发者确认
- **保持简洁**：用最少节点和代码完成任务
- **只改任务相关代码**：不触碰不相关的场景/脚本/资源
- **发现更好方案时主动提出**：提出建议而非盲目执行
- **原型先行**：复杂功能优先搭建最小可运行原型

---

## 7. 当前代码质量评估

### 7.1 优点

- ✅ 代码注释完整（中文）
- ✅ 类型标注规范
- ✅ 架构分层清晰
- ✅ 使用 Autoload 单例模式
- ✅ EventBus 解耦通信
- ✅ 遵循 Godot 命名约定

### 7.2 待改进

- ⚠️ 测试目录缺失（`tests/` 未创建）
- ⚠️ 部分代码使用自定义 EventBus 而非 mc_game_framework 的 EventBus
- ⚠️ UIManager 使用字符串路径而非 ResourceLocation
- ⚠️ 缺少代码格式化工具配置

### 7.3 建议

1. **统一 EventBus**：将自定义 EventBus 迁移到 mc_game_framework 的 EventBus
2. **使用 ResourceLocation**：UIManager 应使用 ResourceLocation 而非字符串路径
3. **添加测试**：创建 `tests/` 目录并添加单元测试
4. **配置 linter**：添加 GDScript 静态分析工具配置

---

## 8. 参考资料

- [CLAUDE.md](../../CLAUDE.md) — 项目详细配置
- [AGENTS.md](../../AGENTS.md) — Agent 指令
- [mc_game_framework 源码](../../addons/mc_game_framework/) — 框架实现
- [Godot 文档](https://docs.godotengine.org/) — 官方参考
