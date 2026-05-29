# 1-RESEARCH.md -- mc_game_framework 与相关插件 API 研究

> 阶段 1 实现参考文档
> 研究时间: 2026/05/29

---

## 1. Autoload 系统总览

### 1.1 当前 project.godot 注册（需替换）

```
[autoload]
EventBus="*res://scripts/autoloads/event_bus.gd"
UIManager="*res://scripts/autoloads/ui_manager.gd"
AudioManager="*res://scripts/autoloads/audio_manager.gd"
SaveManager="*res://scripts/autoloads/save_manager.gd"
```

### 1.2 目标注册（7 个框架 Autoload）

```
[autoload]
RegistryManager="*res://addons/mc_game_framework/autoload/registry_manager.gd"
EventBus="*res://addons/mc_game_framework/autoload/event_bus.gd"
UIManager="*res://addons/mc_game_framework/autoload/ui_manager.gd"
I18NManager="*res://addons/mc_game_framework/autoload/i18n_manager.gd"
SoundManager="*res://addons/sound_manager/sound_manager.gd"
GUIDE="*res://addons/guide/guide.gd"
DialogueManager="*res://addons/dialogue_manager/dialogue_manager.gd"
```

**注意**: `*` 前缀表示 Godot 自动创建单例节点。GUIDE 和 SoundManager 的插件脚本会自动注册，但为确保一致性，建议显式注册。

---

## 2. EventBus（addons/mc_game_framework/autoload/event_bus.gd）

### 2.1 核心 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `subscribe` | `subscribe(event_type: StringName, listener: Callable) -> void` | 订阅事件类型 |
| `unsubscribe` | `unsubscribe(event_type: StringName, listener: Callable) -> void` | 取消订阅 |
| `publish` | `publish(event: Event) -> void` | 发布事件（自动清理失效监听器） |
| `bind_signal` | `bind_signal(signal_target: Signal, event_factory: Callable) -> Signal` | 将 Godot Signal 桥接为 EventBus 事件 |
| `unbind_signal` | `unbind_signal(signal_target: Signal) -> void` | 解除 Signal 桥接 |
| `clear_listeners` | `clear_listeners(event_type: StringName) -> void` | 清除指定事件类型的所有监听器 |
| `clear_all_listeners` | `clear_all_listeners() -> void` | 清除所有监听器 |

### 2.2 Event 基类（addons/mc_game_framework/event/event.gd）

```gdscript
extends RefCounted
class_name Event

var _cancelled := false

func cancel() -> void         # 取消事件，阻止后续监听器处理
func is_cancelled() -> bool   # 检查是否已取消
func get_event_type() -> StringName  # 返回事件类型（默认使用 class_name）
```

### 2.3 已定义的框架事件

| 事件类 | 文件 | 数据字段 |
|--------|------|----------|
| `UIOpenEvent` | `event/ui/ui_open_event.gd` | `panel_id: ResourceLocation`, `layer: int` |
| `UICloseEvent` | `event/ui/ui_close_event.gd` | `panel_id: ResourceLocation`, `layer: int` |
| `UIPauseEvent` | `event/ui/ui_pause_event.gd` | `panel_id: ResourceLocation`, `layer: int` |
| `UIResumeEvent` | `event/ui/ui_resume_event.gd` | `panel_id: ResourceLocation`, `layer: int` |
| `LanguageChangedEvent` | `event/language_changed_event.gd` | `lang_code: String` |
| `SignalEvent` | `event/signal_event.gd` | 通用 Signal 桥接事件 |

### 2.4 创建自定义事件示例

```gdscript
extends Event
class_name GameStartedEvent
# 无额外数据，使用默认 get_event_type()

# 带数据的事件
extends Event
class_name GamePausedEvent
var is_paused: bool

func _init(p_is_paused: bool) -> void:
    is_paused = p_is_paused
```

### 2.5 使用模式

```gdscript
# 订阅
EventBus.subscribe(&"GamePausedEvent", _on_game_paused)

# 回调
func _on_game_paused(event: GamePausedEvent) -> void:
    if event.is_paused:
        # 处理暂停

# 发布
EventBus.publish(GamePausedEvent.new(true))

# Signal 桥接
EventBus.bind_signal(some_node.some_signal, func(args): return SomeEvent.new(args))
```

---

## 3. UIManager（addons/mc_game_framework/autoload/ui_manager.gd）

### 3.1 核心 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `open_panel` | `open_panel(id: ResourceLocation, data: Dictionary = {}, layer_override: int = -1) -> UIPanel` | 打开面板（栈管理） |
| `back` | `back(layer: int = UILayer.NORMAL) -> void` | 弹出栈顶面板 |
| `close_panel` | `close_panel(id: ResourceLocation) -> void` | 关闭指定面板 |
| `close_all` | `close_all(layer: int = -1) -> void` | 关闭指定层级或全部面板 |
| `get_top_panel` | `get_top_panel(layer: int = UILayer.NORMAL) -> UIPanel` | 获取栈顶面板 |
| `is_panel_open` | `is_panel_open(id: ResourceLocation) -> bool` | 检查面板是否打开 |
| `add_overlay` | `add_overlay(id: ResourceLocation, overlay: Control, layer: int = UILayer.SCENE) -> void` | 添加覆盖层 |
| `remove_overlay` | `remove_overlay(id: ResourceLocation) -> void` | 移除覆盖层 |
| `get_overlay` | `get_overlay(id: ResourceLocation) -> Control` | 获取覆盖层实例 |
| `set_overlay_visible` | `set_overlay_visible(id: ResourceLocation, visible: bool) -> void` | 显示/隐藏覆盖层 |
| `show_toast` | `show_toast(toast_id: ResourceLocation, data: Dictionary = {}, duration: float = 3.0) -> UIToast` | 显示 Toast 通知 |
| `dismiss_toast` | `dismiss_toast(toast: UIToast) -> void` | 关闭 Toast |
| `dismiss_all_toasts` | `dismiss_all_toasts() -> void` | 关闭所有 Toast |
| `queue_popup` | `queue_popup(panel_id: ResourceLocation, data: Dictionary = {}, priority: int = 0) -> void` | 将弹窗加入队列 |

### 3.2 内部机制

- **递归保护**: `MAX_OPEN_DEPTH = 8`，单帧最大连续 open_panel 深度
- **缓存管理**: `MAX_CACHED_PANELS = 10`，LRU 淘汰策略
- **层级系统**: 每个层级独立栈，CanvasLayer 节点自动创建
- **背景遮罩**: NORMAL 及以上层级自动添加半透明黑色遮罩

### 3.3 UILayer 常量

```gdscript
const SCENE  := 0      # 场景内UI（伤害数字、名字牌）
const NORMAL := 100    # 普通全屏面板（背包、地图、商店）
const POPUP  := 200    # 弹窗（确认框、提示框）
const TOAST  := 300    # 通知提示（自动消失）
const SYSTEM := 400    # 系统级（Loading画面、断网提示）
```

### 3.4 前置条件

UIManager 依赖 `UIRegistry`，必须在使用前注册：

```gdscript
# 在游戏初始化时
var ui_registry = UIRegistry.new()
RegistryManager.register_registry("ui", ui_registry)
```

---

## 4. UIPanel 基类（addons/mc_game_framework/ui/ui_panel.gd）

### 4.1 类定义

```gdscript
extends Control
class_name UIPanel

var panel_id: ResourceLocation    # 面板标识符（UIManager 自动赋值）
var ui_layer: int = UILayer.NORMAL  # 面板层级（UIManager 自动赋值）
var cache_mode: int = CacheMode.NONE  # 缓存模式

enum CacheMode {
    NONE,    # 关闭时销毁（queue_free）
    CACHE,   # 关闭时隐藏，下次打开时复用
}
```

### 4.2 生命周期回调（子类覆写）

| 回调 | 调用时机 | 说明 |
|------|----------|------|
| `_on_init()` | 首次创建时 | 仅调用一次，用于初始化 |
| `_on_open(data: Dictionary = {})` | 每次打开时 | `data` 为外部传入的参数字典 |
| `_on_pause()` | 被新面板覆盖时 | 当前面板进入暂停状态 |
| `_on_resume()` | 上方面板关闭后恢复时 | 面板重新成为栈顶 |
| `_on_close()` | 从栈中移除时 | 面板关闭前的清理 |
| `_on_destroy()` | 销毁前 | 仅 `CacheMode.NONE` 时调用 |

### 4.3 使用示例

```gdscript
extends UIPanel

func _on_init() -> void:
    # 首次创建时的初始化
    pass

func _on_open(data: Dictionary = {}) -> void:
    # 每次打开时调用
    var panel_id = data.get("panel_id", "")
    # 更新 UI 显示

func _on_close() -> void:
    # 清理资源
    pass
```

---

## 5. UIToast 基类（addons/mc_game_framework/ui/ui_toast.gd）

### 5.1 类定义

```gdscript
extends Control
class_name UIToast

var toast_id: ResourceLocation
var duration: float = 3.0
signal dismissed()

func start_dismiss_timer(p_duration: float) -> void  # 启动自动消失计时
func _on_show(_data: Dictionary = {}) -> void         # 显示时回调
func _on_dismiss() -> void                            # 消失时回调
```

---

## 6. RegistryManager（addons/mc_game_framework/autoload/registry_manager.gd）

### 6.1 核心 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `register_registry` | `register_registry(type_name: String, registry: RegistryBase) -> void` | 注册一个注册表实例 |
| `get_registry` | `get_registry(type_name: String) -> RegistryBase` | 获取指定类型的注册表 |
| `has_registry` | `has_registry(type_name: String) -> bool` | 检查注册表是否存在 |
| `unregister_registry` | `unregister_registry(type_name: String) -> bool` | 移除注册表 |

### 6.2 RegistryBase（addons/mc_game_framework/registry/registry_base.gd）

```gdscript
extends RefCounted
class_name RegistryBase

var _entries: Dictionary = {}  # 键为 ResourceLocation 字符串，值为任意类型

func register(id: ResourceLocation, entry: Variant) -> bool
func unregister(id: ResourceLocation) -> bool
func get_entry(id: ResourceLocation) -> Variant
func has_entry(id: ResourceLocation) -> bool
func get_all_entries() -> Dictionary
func get_all_keys() -> Array
func clear() -> void
```

### 6.3 UIRegistry（addons/mc_game_framework/registry/ui_registry.gd）

```gdscript
extends RegistryBase
class_name UIRegistry

func register_panel(id: ResourceLocation, scene: PackedScene,
                    default_layer: int = UILayer.NORMAL,
                    cache_mode: int = UIPanel.CacheMode.NONE) -> void

func register_toast(id: ResourceLocation, scene: PackedScene) -> void

func instantiate_panel(id: ResourceLocation) -> UIPanel
func instantiate_toast(id: ResourceLocation) -> UIToast
```

---

## 7. ResourceLocation（addons/mc_game_framework/utils/resource_location.gd）

### 7.1 格式规范

- 格式: `namespace:path`
- 示例: `cookery:equipment/stove`, `cookery:material/flour`, `core:ui/inventory`
- namespace 和 path 均使用小写
- 合法字符: 小写字母(a-z)、数字(0-9)、下划线(_)、连字符(-)、点(.)
- path 中额外允许斜杠(/)用于层级分隔

### 7.2 核心 API

```gdscript
extends RefCounted
class_name ResourceLocation

var namespace_id: String
var id: String

func _init(p_namespace: String = "", p_path: String = "") -> void
static func from_string(location_str: String) -> ResourceLocation  # 从字符串解析
static func parse(location_str: String) -> DataResult              # 严格模式解析（带校验）
static func validate(location_str: String) -> DataResult           # 校验格式
static func is_valid(location_str: String) -> bool                 # 判断是否合法
func _to_string() -> String                                        # 返回 "namespace:path"
func equals(other: ResourceLocation) -> bool                       # 比较两个 ResourceLocation
```

### 7.3 重要注意事项

**Dictionary 键必须使用 `.to_string()`**，不能直接用 ResourceLocation 对象作为键（RefCounted 使用引用比较）：

```gdscript
# 正确
var key = id.to_string()
_entries[key] = entry

# 错误
_entries[id] = entry  # 不可靠
```

---

## 8. GUIDE 输入系统（addons/guide/）

### 8.1 核心类

| 类 | 文件 | 说明 |
|----|------|------|
| `GUIDEAction` | `guide_action.gd` | 输入动作定义（Resource） |
| `GUIDEMappingContext` | `guide_mapping_context.gd` | 映射上下文（Resource） |
| `GUIDEActionMapping` | `guide_action_mapping.gd` | 动作到输入的映射（Resource） |
| `GUIDEInputMapping` | `guide_input_mapping.gd` | 输入映射配置（Resource） |
| `GUIDEInput` | `inputs/guide_input.gd` | 输入源基类（Resource） |
| `GUIDEInputKey` | `inputs/guide_input_key.gd` | 键盘输入 |
| `GUIDETrigger` | `triggers/guide_trigger.gd` | 触发器基类（Resource） |
| `GUIDETriggerDown` | `triggers/guide_trigger_down.gd` | 按下触发 |

### 8.2 GUIDE 核心 API（addons/guide/guide.gd）

| 方法 | 签名 | 说明 |
|------|------|------|
| `enable_mapping_context` | `enable_mapping_context(context: GUIDEMappingContext, disable_others: bool = false, priority: int = 0) -> void` | 启用映射上下文 |
| `disable_mapping_context` | `disable_mapping_context(context: GUIDEMappingContext) -> void` | 禁用映射上下文 |
| `set_enabled_mapping_contexts` | `set_enabled_mapping_contexts(contexts: Array[GUIDEMappingContext]) -> Array[GUIDEMappingContext]` | 批量替换上下文 |
| `is_mapping_context_enabled` | `is_mapping_context_enabled(context: GUIDEMappingContext) -> bool` | 检查上下文是否启用 |
| `get_enabled_mapping_contexts` | `get_enabled_mapping_contexts() -> Array[GUIDEMappingContext]` | 获取所有启用的上下文 |
| `set_remapping_config` | `set_remapping_config(config: GUIDERemappingConfig) -> void` | 应用重映射配置 |
| `inject_input` | `inject_input(event: InputEvent) -> void` | 手动注入输入事件 |

### 8.3 GUIDEAction 属性与信号

```gdscript
@export var name: StringName                        # 动作名称
@export var action_value_type: GUIDEActionValueType  # 值类型：BOOL/AXIS_1D/AXIS_2D/AXIS_3D
@export var block_lower_priority_actions: bool       # 是否阻止低优先级动作
@export var emit_as_godot_actions: bool              # 是否发射到 Godot 原生系统
@export var is_remappable: bool                      # 是否允许重映射
@export var display_name: String                     # 显示名称
@export var display_category: String                 # 显示分类

# 值属性
var value_bool: bool          # 布尔值
var value_axis_1d: float      # 1D 轴值
var value_axis_2d: Vector2    # 2D 轴值
var value_axis_3d: Vector3    # 3D 轴值
var elapsed_seconds: float    # 动作开始后的经过秒数
var elapsed_ratio: float      # 按住时间比例
var triggered_seconds: float  # 触发后的经过秒数

# 状态查询
func is_triggered() -> bool   # 是否正在触发
func is_completed() -> bool   # 是否已完成
func is_ongoing() -> bool     # 是否进行中

# 信号
signal triggered()       # 每帧触发时
signal just_triggered()  # 首次触发时
signal started()         # 开始评估时
signal ongoing()         # 每帧评估中
signal completed()       # 评估完成时
signal cancelled()       # 取消时
```

### 8.4 GUIDEMappingContext 结构

```gdscript
@tool
class_name GUIDEMappingContext
extends Resource

@export var display_name: String
@export var mappings: Array[GUIDEActionMapping] = []

signal enabled()
signal disabled()
```

### 8.5 GUIDEActionMapping 结构

```gdscript
@tool
class_name GUIDEActionMapping
extends Resource

@export var action: GUIDEAction
@export var input_mappings: Array[GUIDEInputMapping] = []
```

### 8.6 GUIDEInputMapping 结构

```gdscript
@tool
class_name GUIDEInputMapping
extends Resource

@export var input: GUIDEInput           # 输入源
@export var modifiers: Array[GUIDEModifier] = []  # 修饰器
@export var triggers: Array[GUIDETrigger] = []    # 触发器
@export var is_remappable: bool
@export var display_name: String
@export var display_category: String
```

### 8.7 GUIDEInputKey（键盘输入）

```gdscript
@tool
class_name GUIDEInputKey
extends GUIDEInput

@export var key: Key           # 按键码
@export var shift: bool        # 是否需要 Shift
@export var control: bool      # 是否需要 Ctrl
@export var alt: bool          # 是否需要 Alt
@export var meta: bool         # 是否需要 Meta/Win/Cmd
@export var allow_additional_modifiers: bool  # 是否允许额外修饰键
```

### 8.8 GUIDETriggerDown（按下触发）

```gdscript
@tool
class_name GUIDETriggerDown
extends GUIDETrigger

# 当输入超过 actuation_threshold 时触发
# 默认 actuation_threshold = 0.5
```

### 8.9 创建 GUIDE 资源的代码方式

GUIDE 资源通常是 `.tres` 文件，通过编辑器创建。但也可以用代码创建：

```gdscript
# 创建 Action
var action = GUIDEAction.new()
action.name = &"confirm"
action.action_value_type = GUIDEAction.GUIDEActionValueType.BOOL

# 创建 Input
var input = GUIDEInputKey.new()
input.key = KEY_ENTER

# 创建 Trigger
var trigger = GUIDETriggerDown.new()

# 创建 InputMapping
var input_mapping = GUIDEInputMapping.new()
input_mapping.input = input
input_mapping.triggers = [trigger]

# 创建 ActionMapping
var action_mapping = GUIDEActionMapping.new()
action_mapping.action = action
action_mapping.input_mappings = [input_mapping]

# 创建 MappingContext
var context = GUIDEMappingContext.new()
context.display_name = "Menu Context"
context.mappings = [action_mapping]

# 启用上下文
GUIDE.enable_mapping_context(context)
```

### 8.10 已有的 GUIDE 资源（git status 中提到的）

从 git status 看，已有以下资源文件（但可能需要重建）：

- `input/actions/clear_action.tres`
- `input/actions/next_device_action.tres`
- `input/actions/pause_action.tres`
- `input/actions/prev_device_action.tres`
- `input/actions/process_action.tres`
- `input/contexts/equipment_context.tres`
- `input/contexts/game_context.tres`

### 8.11 GUIDE 上下文切换模式

```gdscript
# 方式 1: 单独启用/禁用
GUIDE.enable_mapping_context(menu_context)
GUIDE.disable_mapping_context(menu_context)

# 方式 2: 批量替换（更高效）
var previous = GUIDE.set_enabled_mapping_contexts([game_context])
# previous 包含之前启用的上下文

# 方式 3: 禁用其他
GUIDE.enable_mapping_context(menu_context, true)  # disable_others = true
```

---

## 9. I18NManager（addons/mc_game_framework/autoload/i18n_manager.gd）

### 9.1 核心 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `load_translation` | `load_translation(lang_code: String, file_path: String) -> bool` | 加载 JSON 翻译文件 |
| `set_language` | `set_language(lang_code: String) -> void` | 切换语言并发布事件 |
| `get_current_language` | `get_current_language() -> String` | 获取当前语言代码 |
| `get_text` | `get_text(key: String, args: Array = []) -> String` | 获取翻译文本，支持占位符 |

### 9.2 JSON 翻译文件格式

```json
{
  "ui": {
    "menu": {
      "start": "开始游戏",
      "continue": "继续游戏",
      "settings": "设置",
      "exit": "退出"
    }
  }
}
```

加载后自动展平为：`ui.menu.start`、`ui.menu.continue` 等。

---

## 10. SoundManager（addons/sound_manager/sound_manager.gd）

### 10.1 核心 API

#### 音效（Sound Effects）

| 方法 | 签名 | 说明 |
|------|------|------|
| `play_sound` | `play_sound(resource: AudioStream, override_bus: String = "") -> AudioStreamPlayer` | 播放音效 |
| `play_sound_with_pitch` | `play_sound_with_pitch(resource: AudioStream, pitch: float = 1.0, override_bus: String = "") -> AudioStreamPlayer` | 播放音效（可调音高） |
| `stop_sound` | `stop_sound(resource: AudioStream) -> void` | 停止音效 |
| `play_ui_sound` | `play_ui_sound(resource: AudioStream, override_bus: String = "") -> AudioStreamPlayer` | 播放 UI 音效 |
| `stop_ui_sound` | `stop_ui_sound(resource: AudioStream) -> void` | 停止 UI 音效 |

#### 背景音乐（Music）

| 方法 | 签名 | 说明 |
|------|------|------|
| `play_music` | `play_music(resource: AudioStream, crossfade_duration: float = 0.0, override_bus: String = "") -> AudioStreamPlayer` | 播放音乐（支持交叉淡入） |
| `play_music_from_position` | `play_music_from_position(resource: AudioStream, position: float = 0.0, crossfade_duration: float = 0.0, override_bus: String = "") -> AudioStreamPlayer` | 从指定位置播放 |
| `stop_music` | `stop_music(fade_out_duration: float = 0.0) -> void` | 停止音乐 |
| `pause_music` | `pause_music(resource: AudioStream = null) -> void` | 暂停音乐 |
| `resume_music` | `resume_music(resource: AudioStream = null) -> void` | 恢复音乐 |
| `is_music_playing` | `is_music_playing(resource: AudioStream = null) -> bool` | 检查音乐是否播放中 |

#### 环境音（Ambient）

| 方法 | 签名 | 说明 |
|------|------|------|
| `play_ambient_sound` | `play_ambient_sound(resource: AudioStream, fade_in_duration: float = 0.0, override_bus: String = "") -> AudioStreamPlayer` | 播放环境音 |
| `stop_ambient_sound` | `stop_ambient_sound(resource: AudioStream, fade_out_duration: float = 0.0) -> void` | 停止环境音 |
| `stop_all_ambient_sounds` | `stop_all_ambient_sounds(fade_out_duration: float = 0.0) -> void` | 停止所有环境音 |

#### 音量控制

| 方法 | 签名 | 说明 |
|------|------|------|
| `set_sound_volume` | `set_sound_volume(volume_between_0_and_1: float) -> void` | 设置音效音量（0-1） |
| `set_music_volume` | `set_music_volume(volume_between_0_and_1: float) -> void` | 设置音乐音量（0-1） |
| `set_ambient_sound_volume` | `set_ambient_sound_volume(volume_between_0_and_1: float) -> void` | 设置环境音音量（0-1） |
| `get_sound_volume` | `get_sound_volume() -> float` | 获取音效音量 |
| `get_music_volume` | `get_music_volume() -> float` | 获取音乐音量 |
| `get_ambient_sound_volume` | `get_ambient_sound_volume() -> float` | 获取环境音音量 |

### 10.2 音频总线配置

SoundManager 默认使用以下音频总线：
- 音效: `["Sounds", "SFX"]`（按顺序查找）
- UI 音效: `["UI", "Interface", "Sounds", "SFX"]`
- 环境音: `["Sounds", "SFX"]`
- 音乐: `["Music"]`

可通过以下方法自定义：
```gdscript
SoundManager.set_default_sound_bus("CustomSFX")
SoundManager.set_default_music_bus("CustomMusic")
```

### 10.3 ProcessMode

```gdscript
SoundManager.sound_process_mode = PROCESS_MODE_PAUSABLE      # 音效（游戏暂停时暂停）
SoundManager.ui_sound_process_mode = PROCESS_MODE_ALWAYS     # UI 音效（始终播放）
SoundManager.ambient_sound_process_mode = PROCESS_MODE_ALWAYS # 环境音（始终播放）
SoundManager.music_process_mode = PROCESS_MODE_ALWAYS        # 音乐（始终播放）
```

---

## 11. Codec 系统（addons/mc_game_framework/codec/）

### 11.1 核心类

| 类 | 文件 | 说明 |
|----|------|------|
| `Codec` | `codec/core/codec.gd` | 编解码器基类 |
| `DataResult` | `codec/core/data_result.gd` | 结果类型（成功/错误/部分成功） |
| `DynamicOps` | `codec/core/dynamic_ops.gd` | 动态操作接口 |
| `JsonOps` | `codec/ops/json_ops.gd` | JSON 操作实现 |
| `GodotResourceOps` | `codec/ops/godot_resource_ops.gd` | Godot Resource 操作实现 |
| `CodecResource` | `codec/core/codec_resource.gd` | 支持 Codec 的 Resource 基类 |

### 11.2 DataResult API

```gdscript
extends RefCounted
class_name DataResult

static func success(value: Variant) -> DataResult
static func error(message: String) -> DataResult
static func partial(value: Variant, diagnostics: Array = []) -> DataResult

func is_success() -> bool
func is_error() -> bool
func is_partial() -> bool
func get_value() -> Variant
func get_diagnostics() -> Array
func map(transform: Callable) -> DataResult
```

---

## 12. Component 系统（addons/mc_game_framework/component/）

### 12.1 核心类

| 类 | 文件 | 说明 |
|----|------|------|
| `ComponentContainer` | `component/component_container.gd` | 数据组件容器 |
| `ComponentHost` | `component/component_host.gd` | 静态适配器，将容器附加到 Node/Resource |
| `ComponentType` | `component/component_type.gd` | 组件类型定义 |

---

## 13. 阶段 1 实现要点

### 13.1 Autoload 注册顺序

1. 删除 `scripts/autoloads/event_bus.gd`、`ui_manager.gd`、`audio_manager.gd`
2. 保留 `scripts/autoloads/save_manager.gd`（框架未提供）
3. 更新 `project.godot` 的 `[autoload]` 部分
4. 注册顺序：RegistryManager -> EventBus -> UIManager -> I18NManager -> SoundManager -> GUIDE -> DialogueManager

### 13.2 初始化流程

```gdscript
# 在主场景或初始化脚本中
func _ready() -> void:
    # 1. 注册 UIRegistry
    var ui_registry = UIRegistry.new()
    RegistryManager.register_registry("ui", ui_registry)

    # 2. 注册面板
    var main_menu_id = ResourceLocation.new("cookery", "ui/main_menu")
    ui_registry.register_panel(main_menu_id, preload("res://scenes/screens/main_menu.tscn"))

    # 3. 启用 GUIDE 上下文
    var menu_context = preload("res://input/contexts/menu_context.tres")
    GUIDE.enable_mapping_context(menu_context)

    # 4. 打开主菜单
    UIManager.open_panel(main_menu_id)
```

### 13.3 面板创建模板

```gdscript
extends UIPanel

func _on_init() -> void:
    # 初始化 UI 元素
    pass

func _on_open(data: Dictionary = {}) -> void:
    # 显示面板，更新数据
    visible = true

func _on_close() -> void:
    # 清理
    visible = false

func _on_pause() -> void:
    # 被覆盖时暂停
    set_process(false)

func _on_resume() -> void:
    # 恢复时
    set_process(true)
```

### 13.4 事件定义模板

```gdscript
# events/game_events.gd
extends Event
class_name GameStartedEvent

extends Event
class_name GamePausedEvent
var is_paused: bool
func _init(p_is_paused: bool) -> void:
    is_paused = p_is_paused

extends Event
class_name SceneChangedEvent
var scene_path: String
func _init(p_scene_path: String) -> void:
    scene_path = p_scene_path
```

---

## 14. 已知问题与注意事项

### 14.1 EventBus 与框架 EventBus 的差异

当前 `scripts/autoloads/event_bus.gd` 使用 Godot 原生 Signal，框架 EventBus 使用 `Event` 对象 + `StringName` 类型。迁移时需要：
- 将 `signal xxx` 改为 `Event` 子类
- 将 `xxx.emit()` 改为 `EventBus.publish(XxxEvent.new())`
- 将 `xxx.connect()` 改为 `EventBus.subscribe(&"XxxEvent", callback)`

### 14.2 UIManager 与框架 UIManager 的差异

当前 `scripts/autoloads/ui_manager.gd` 使用场景路径字符串，框架 UIManager 使用 `ResourceLocation`。迁移时需要：
- 将 `open_panel("res://...")` 改为 `open_panel(ResourceLocation.new("cookery", "ui/xxx"))`
- 面板需要注册到 `UIRegistry`
- 面板需要继承 `UIPanel`

### 14.3 AudioManager 与 SoundManager 的差异

当前 `scripts/autoloads/audio_manager.gd` 是自定义实现，框架使用 `sound_manager` 插件。迁移时需要：
- 将 `AudioManager.play_music()` 改为 `SoundManager.play_music()`
- 将 `AudioManager.play_sfx()` 改为 `SoundManager.play_sound()`
- 音频总线名称可能需要调整

### 14.4 GUIDE 资源文件

GUIDE 资源（`.tres`）建议通过 Godot 编辑器的 GUIDE 面板创建，而非代码。编辑器提供了可视化的配置界面。

---

## 15. 参考文件路径

| 文件 | 路径 |
|------|------|
| EventBus | `addons/mc_game_framework/autoload/event_bus.gd` |
| UIManager | `addons/mc_game_framework/autoload/ui_manager.gd` |
| RegistryManager | `addons/mc_game_framework/autoload/registry_manager.gd` |
| I18NManager | `addons/mc_game_framework/autoload/i18n_manager.gd` |
| UIPanel | `addons/mc_game_framework/ui/ui_panel.gd` |
| UIToast | `addons/mc_game_framework/ui/ui_toast.gd` |
| UILayer | `addons/mc_game_framework/ui/ui_layer.gd` |
| UIRegistry | `addons/mc_game_framework/registry/ui_registry.gd` |
| RegistryBase | `addons/mc_game_framework/registry/registry_base.gd` |
| Event | `addons/mc_game_framework/event/event.gd` |
| ResourceLocation | `addons/mc_game_framework/utils/resource_location.gd` |
| GUIDE | `addons/guide/guide.gd` |
| GUIDEAction | `addons/guide/guide_action.gd` |
| GUIDEMappingContext | `addons/guide/guide_mapping_context.gd` |
| GUIDEActionMapping | `addons/guide/guide_action_mapping.gd` |
| GUIDEInputMapping | `addons/guide/guide_input_mapping.gd` |
| GUIDEInputKey | `addons/guide/inputs/guide_input_key.gd` |
| GUIDETriggerDown | `addons/guide/triggers/guide_trigger_down.gd` |
| SoundManager | `addons/sound_manager/sound_manager.gd` |
| 自定义 EventBus | `scripts/autoloads/event_bus.gd` |
| 自定义 UIManager | `scripts/autoloads/ui_manager.gd` |
| 自定义 AudioManager | `scripts/autoloads/audio_manager.gd` |
| 自定义 SaveManager | `scripts/autoloads/save_manager.gd` |
