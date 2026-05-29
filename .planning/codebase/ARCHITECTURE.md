# 架构分析

## 系统架构概述

Cookery 是一个基于 Godot 4.6 引擎的沙盒烹饪游戏，采用"设备即界面"的核心理念。项目使用分离布局（Split Layout）目录结构，将框架代码（`common/`）与项目代码（根目录）分离，便于跨项目复用。

### 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    游戏场景层 (scenes/)                       │
│  main_menu.tscn, game_scene.tscn, ui/*.tscn                 │
├─────────────────────────────────────────────────────────────┤
│                    游戏逻辑层 (scripts/)                      │
│  autoloads/, systems/, data/                                │
├─────────────────────────────────────────────────────────────┤
│                    框架层 (common/addons/)                    │
│  mc_game_framework, guide, sound_manager, dialogue_manager  │
├─────────────────────────────────────────────────────────────┤
│                    引擎层 (Godot 4.6)                        │
│  Rendering: Mobile, Physics: Jolt                           │
└─────────────────────────────────────────────────────────────┘
```

## 核心模式

### 1. EventBus 模式（跨系统通信）

**位置**: `common/addons/mc_game_framework/autoload/event_bus.gd`

EventBus 是项目的核心通信枢纽，采用发布-订阅模式实现系统间解耦。

**核心 API**:
- `subscribe(event_type: StringName, listener: Callable)` - 订阅事件
- `unsubscribe(event_type: StringName, listener: Callable)` - 取消订阅
- `publish(event: Event)` - 发布事件
- `bind_signal(signal_target: Signal, event_factory: Callable)` - 绑定原生信号到事件系统

**特点**:
- 自动清理失效对象的 Callable（防止内存泄漏）
- 支持事件取消（`event.is_cancelled()`）
- 支持信号桥接（将 Godot 原生信号转换为 Event 对象）

**项目扩展**: `scripts/autoloads/event_bus.gd` 定义了游戏特定的信号（如 `cooking_completed`, `recipe_discovered`），但这些信号目前未与框架 EventBus 集成。

### 2. UIManager 模式（栈式 UI 管理）

**位置**: `common/addons/mc_game_framework/autoload/ui_manager.gd`

UIManager 实现了栈式 UI 面板管理，支持多层级、缓存、覆盖层、Toast 和弹窗队列。

**核心功能**:
- **面板栈**: 每个层级独立的面板栈，支持 push/pop 操作
- **生命周期**: `_on_init()`, `_on_open()`, `_on_pause()`, `_on_resume()`, `_on_close()`, `_on_destroy()`
- **缓存系统**: LRU 缓存淘汰（最多 10 个缓存面板）
- **覆盖层**: 持久性 HUD 元素（如小地图）
- **Toast 系统**: 自动消失的通知
- **弹窗队列**: 优先级排序的弹窗队列

**关键常量**:
- `MAX_OPEN_DEPTH = 8` - 防止循环导航
- `MAX_CACHED_PANELS = 10` - 缓存上限

**UI 层级**:
- `SCENE` (0) - 场景层
- `NORMAL` (10) - 普通面板
- `POPUP` (20) - 弹窗
- `OVERLAY` (30) - 覆盖层
- `TOAST` (40) - 通知

### 3. Resource 数据驱动模式

**位置**: `common/addons/mc_game_framework/codec/`

项目采用 Minecraft DFU（Data Fixer Upper）风格的数据驱动架构。

**核心组件**:
- **Codec**: 编解码器基类，支持组合式声明
- **DataResult**: 结果对象（success/error/partial），携带诊断信息
- **DynamicOps**: 数据操作接口（JSON/Godot Resource）
- **ResourceLocation**: Minecraft 风格资源标识符（`namespace:path`）

**Codec 组合器**:
- `field_of(name)` - 必填字段
- `optional_field_of(name, default)` - 可选字段
- `list_of()` - 列表
- `map_of(key, value)` - 键值对
- `either(first, second)` - 备选方案
- `dispatch(type_key, type_codec, dispatch_fn)` - 类型分发
- `xmap(decode_fn, encode_fn)` - 值变换

### 4. GUIDE 输入系统

**位置**: `common/addons/guide/guide.gd`

GUIDE 是一个高级输入映射系统，替代 Godot 原生的 Input Map。

**核心概念**:
- **MappingContext**: 输入上下文（如游戏、菜单、设备交互）
- **Action**: 输入动作（如移动、交互、确认）
- **InputMapping**: 动作到输入的映射
- **Trigger**: 触发条件（按下、释放、长按、组合键等）
- **Modifier**: 输入修饰器（死区、归一化、曲线等）

**特点**:
- 上下文切换（`enable_mapping_context` / `disable_mapping_context`）
- 优先级系统（高优先级上下文可阻塞低优先级输入）
- 输入合并（多个上下文可为同一动作提供不同输入）
- 重映射支持（运行时修改按键绑定）

### 5. Registry 模式（数据注册）

**位置**: `common/addons/mc_game_framework/registry/`

Registry 提供类型安全的数据注册和查找。

**Registry 类型**:
- `RegistryBase` - 基础注册表
- `UIRegistry` - UI 面板注册表
- `TagRegistry` - 标签注册表
- `ComponentTypeRegistry` - 组件类型注册表

**使用方式**:
```gdscript
RegistryManager.register_registry("ui", UIRegistry.new())
var panel = ui_registry.instantiate_panel(ResourceLocation.new("cookery", "ui/settings"))
```

## 数据流

### 1. 输入处理流程

```
用户输入
    ↓
GUIDE InputTracker (捕获 InputEvent)
    ↓
GUIDEInputState (维护输入状态)
    ↓
GUIDEInputMapping (输入映射)
    ↓
GUIDEModifier (修饰器处理)
    ↓
GUIDETrigger (触发条件判断)
    ↓
GUIDEAction (动作状态更新)
    ↓
游戏逻辑响应
```

### 2. UI 面板生命周期

```
UIManager.open_panel(id, data)
    ↓
UIRegistry.instantiate_panel(id) 或 缓存获取
    ↓
panel._on_init() (首次)
    ↓
当前栈顶 panel._on_pause()
    ↓
新面板入栈
    ↓
panel._on_open(data)
    ↓
EventBus.publish(UIOpenEvent)
    ↓
[用户交互]
    ↓
UIManager.back() 或 close_panel()
    ↓
panel._on_close()
    ↓
EventBus.publish(UICloseEvent)
    ↓
缓存或销毁面板
    ↓
下方面板 panel._on_resume()
    ↓
EventBus.publish(UIResumeEvent)
```

### 3. 事件通信流程

```
系统 A 产生事件
    ↓
EventBus.publish(Event)
    ↓
遍历 _listeners[event_type]
    ↓
清理失效 Callable
    ↓
检查 event.is_cancelled()
    ↓
调用 listener.call(event)
    ↓
系统 B 响应事件
```

### 4. 数据序列化流程

```
运行时对象
    ↓
Codec.encode(value, ops)
    ↓
DataResult (success/error/partial)
    ↓
DynamicOps (JSON/Godot Resource)
    ↓
存储/传输
    ↓
DynamicOps 读取
    ↓
Codec.decode(value, ops)
    ↓
DataResult (success/error/partial)
    ↓
运行时对象
```

## 关键抽象

### 1. ResourceLocation

**位置**: `common/addons/mc_game_framework/utils/resource_location.gd`

Minecraft 风格的资源标识符，格式为 `namespace:path`。

**特点**:
- 继承自 `RefCounted`（非 Node）
- 使用 `.to_string()` 作为 Dictionary key（避免引用比较问题）
- 支持严格模式校验（`parse()`）和宽松模式（`from_string()`）
- 合法字符：小写字母、数字、下划线、连字符、点（path 额外允许斜杠）

**示例**:
```gdscript
var id = ResourceLocation.new("cookery", "equipment/stove")
var id2 = ResourceLocation.from_string("cookery:material/flour")
```

### 2. DataResult

**位置**: `common/addons/mc_game_framework/codec/core/data_result.gd`

DFU 风格的结果对象，支持三种状态和函数式组合。

**状态**:
- `SUCCESS` - 完全成功
- `ERROR` - 无法继续
- `PARTIAL` - 部分成功（保留已解码数据）

**函数式组合**:
- `map(transform)` - 变换成功值
- `flat_map(transform)` - 变换返回 DataResult
- `apply(func_result)` - 应用函数结果

**诊断系统**:
- `Diagnostic` 内部类携带 level、message、path
- 支持嵌套路径（`inventory.items[3].count`）

### 3. UIPanel

**位置**: `common/addons/mc_game_framework/ui/ui_panel.gd`

所有 UI 面板的基类，提供生命周期管理。

**属性**:
- `panel_id: ResourceLocation` - 面板标识符
- `ui_layer: int` - UI 层级
- `cache_mode: CacheMode` - 缓存模式（NONE/CACHE）

**生命周期回调**:
- `_on_init()` - 首次创建
- `_on_open(data)` - 每次打开
- `_on_pause()` - 被新面板覆盖
- `_on_resume()` - 恢复显示
- `_on_close()` - 从栈移除
- `_on_destroy()` - 销毁前（仅 CacheMode.NONE）

### 4. Event

**位置**: `common/addons/mc_game_framework/event/event.gd`

事件基类，用于 EventBus 发布-订阅。

**子类**:
- `UIOpenEvent` - UI 面板打开
- `UICloseEvent` - UI 面板关闭
- `UIPauseEvent` - UI 面板暂停
- `UIResumeEvent` - UI 面板恢复
- `LanguageChangedEvent` - 语言变更

### 5. ComponentContainer

**位置**: `common/addons/mc_game_framework/component/component_container.gd`

Minecraft 风格的数据组件系统，支持动态附加数据到任何对象。

**使用方式**:
```gdscript
var container = ComponentHost.get_or_create(node)
container.set_component(HealthComponent, 100)
var health = container.get_component(HealthComponent)
```

## 架构约束

1. **单线程**: 所有游戏逻辑运行在主线程
2. **全局状态**: 仅通过 Autoload 单例访问（EventBus, UIManager, GUIDE, SoundManager, SaveManager, AudioManager）
3. **EventBus 唯一通道**: 系统间不得直接引用，必须通过 EventBus
4. **UI 通过 UIManager**: 禁止直接 `add_child()` 添加面板
5. **输入通过 GUIDE**: 禁止直接 `Input.is_action_*`
6. **Resource 是数据权威**: 运行时数据使用 Resource 子类，JSON 仅用于外部编辑
