# 结构分析

## 目录结构说明

```
cookery/
├── .claude/                    # Claude Code 配置
│   └── skills/                 # 项目特定技能
│       └── game-architect/     # 游戏架构设计技能
├── .planning/                  # GSD 工作流规划目录
│   └── codebase/               # 代码库分析文档
├── addons/                     # 项目直接使用的插件（从 common/ 复制）
│   ├── dialogue_manager/       # 对话系统 v3.10.4
│   ├── guide/                  # GUIDE 输入系统 v0.13.0
│   ├── gut/                    # GDScript 单元测试框架 v9.6.0
│   ├── kenney_interface_sounds/# UI 音效资源包
│   ├── mc_game_framework/      # Minecraft 风格游戏框架 v1.0.0
│   └── sound_manager/          # 音频管理器 v2.6.1
├── assets/                     # 游戏资源
│   ├── fonts/                  # 字体文件（MiSans-Semibold）
│   ├── icons/                  # SVG 矢量图标（按功能分类）
│   │   ├── arrow/              # 箭头图标
│   │   ├── device/             # 设备图标
│   │   ├── emoji/              # 表情图标
│   │   ├── feedback/           # 反馈图标
│   │   ├── food/               # 食物图标
│   │   ├── media/              # 媒体图标
│   │   ├── misc/               # 杂项图标
│   │   └── ui/                 # UI 图标
│   └── theme/                  # 主题资源
│       ├── minimal_vector.tres # 极简矢量主题
│       └── modern_flat.tres    # 现代扁平主题
├── common/                     # 跨项目复用的框架和工具
│   ├── addons/                 # 框架插件（源码）
│   ├── assets/                 # 通用资源
│   └── tools/                  # 通用工具脚本
├── resources/                  # Godot 资源文件（当前为空）
├── scenes/                     # 场景文件
│   └── screens/                # 屏幕场景
│       ├── main_menu.gd        # 主菜单脚本
│       └── main_menu.tscn      # 主菜单场景
├── scripts/                    # GDScript 脚本
│   └── autoloads/              # Autoload 单例
│       ├── audio_manager.gd    # 音频管理器
│       ├── event_bus.gd        # 事件总线（游戏特定）
│       ├── save_manager.gd     # 存档管理器
│       └── ui_manager.gd       # UI 管理器（游戏特定）
├── tools/                      # 项目特定工具
│   └── generate_guide_context.gd # GUIDE 上下文生成器
├── project.godot               # Godot 项目配置
├── CLAUDE.md                   # Claude Code 项目文档
├── AGENTS.md                   # Agent 指令文档
└── README.md                   # 项目说明
```

## 文件组织模式

### 1. 分离布局（Split Layout）

项目采用分离布局模式，将可复用的框架代码放在 `common/` 目录，项目特定代码放在根目录。

**优势**:
- 框架代码可在多个项目间复用
- 清晰的职责分离
- 便于框架独立更新

**结构**:
- `common/addons/` - 框架源码（mc_game_framework, guide, sound_manager 等）
- `addons/` - 项目使用的插件副本（从 common/ 复制或链接）
- `scripts/` - 项目特定的游戏逻辑
- `scenes/` - 项目特定的场景

### 2. 场景-脚本配对

每个场景（`.tscn`）通常配有一个同名的脚本文件（`.gd`）。

**示例**:
```
scenes/screens/main_menu.tscn
scenes/screens/main_menu.gd
```

### 3. Autoload 单例组织

所有 Autoload 单例放在 `scripts/autoloads/` 目录。

**当前单例**:
- `EventBus` - 事件总线（游戏特定信号）
- `UIManager` - UI 管理器（游戏特定实现）
- `AudioManager` - 音频管理器
- `SaveManager` - 存档管理器

**注意**: 框架层的 Autoload（如 `mc_game_framework` 的 EventBus, UIManager）通过插件系统注册，不在 `scripts/autoloads/` 中。

### 4. 资源分类组织

`assets/` 目录按资源类型分类：

```
assets/
├── fonts/          # 字体文件
├── icons/          # 图标（按功能子目录）
│   ├── arrow/      # 箭头
│   ├── device/     # 设备
│   ├── emoji/      # 表情
│   ├── feedback/   # 反馈
│   ├── food/       # 食物
│   ├── media/      # 媒体
│   ├── misc/       # 杂项
│   └── ui/         # UI
└── theme/          # 主题资源
```

### 5. 插件目录结构

每个插件遵循标准的 Godot 插件结构：

```
addons/plugin_name/
├── plugin.cfg          # 插件配置
├── plugin.gd           # 插件入口脚本
├── autoload/           # Autoload 单例（如有）
├── editor/             # 编辑器扩展（如有）
├── ui/                 # UI 组件（如有）
└── ...                 # 其他模块
```

## 命名约定

### 文件命名

| 类型 | 约定 | 示例 |
|------|------|------|
| GDScript 文件 | `snake_case.gd` | `event_bus.gd`, `main_menu.gd` |
| 场景文件 | `snake_case.tscn` | `main_menu.tscn`, `settings_panel.tscn` |
| 资源文件 | `snake_case.tres` | `minimal_vector.tres` |
| 测试文件 | `test_*.gd` | `test_inventory.gd` |
| 插件配置 | `plugin.cfg` | - |

### 代码命名

| 类型 | 约定 | 示例 |
|------|------|------|
| 类名 | `PascalCase` | `ResourceLocation`, `UIPanel`, `DataResult` |
| 函数/方法 | `snake_case` | `open_panel()`, `_on_init()` |
| 私有函数 | `_snake_case` | `_update_caches()`, `_do_close_panel()` |
| 变量 | `snake_case` | `panel_id`, `ui_layer` |
| 私有变量 | `_snake_case` | `_panel_stack`, `_cached_panels` |
| 常量 | `UPPER_SNAKE_CASE` | `MAX_OPEN_DEPTH`, `NAMESPACE_PATTERN` |
| 枚举值 | `UPPER_SNAKE_CASE` | `CacheMode.NONE`, `Status.SUCCESS` |
| 信号 | `snake_case` | `game_started`, `ui_panel_opened` |

### 路径命名

| 类型 | 约定 | 示例 |
|------|------|------|
| ResourceLocation | `namespace:path` | `cookery:equipment/stove` |
| 场景路径 | `res://scenes/...` | `res://scenes/screens/main_menu.tscn` |
| 资源路径 | `res://assets/...` | `res://assets/icons/ui/settings.svg` |

## 模块职责

### 1. 框架层 (`common/addons/`)

#### mc_game_framework

**职责**: 提供 Minecraft 风格的游戏基础设施

**组件**:
- **EventBus** (`autoload/event_bus.gd`) - 跨系统事件通信
- **UIManager** (`autoload/ui_manager.gd`) - 栈式 UI 管理
- **RegistryManager** (`autoload/registry_manager.gd`) - 数据注册表管理
- **I18NManager** (`autoload/i18n_manager.gd`) - 国际化管理
- **Codec** (`codec/core/codec.gd`) - 数据编解码
- **DataResult** (`codec/core/data_result.gd`) - 结果对象
- **ResourceLocation** (`utils/resource_location.gd`) - 资源标识符
- **UIPanel** (`ui/ui_panel.gd`) - UI 面板基类
- **UIToast** (`ui/ui_toast.gd`) - 通知基类
- **ComponentContainer** (`component/component_container.gd`) - 数据组件容器
- **TagRegistry** (`tag/tag_registry.gd`) - 标签注册表

#### guide

**职责**: 高级输入映射和上下文管理

**组件**:
- **GUIDE** (`guide.gd`) - 输入系统主类
- **GUIDEMappingContext** (`guide_mapping_context.gd`) - 输入上下文
- **GUIDEAction** (`guide_action.gd`) - 输入动作
- **GUIDEInputMapping** (`guide_input_mapping.gd`) - 输入映射
- **GUIDETrigger** (`triggers/guide_trigger.gd`) - 触发器基类
- **GUIDEModifier** (`modifiers/guide_modifier.gd`) - 修饰器基类

#### sound_manager

**职责**: 音频播放和管理

**组件**:
- **SoundManager** (`sound_manager.gd`) - 音频管理器
- **Music** (`music.gd`) - 音乐播放
- **SoundEffects** (`sound_effects.gd`) - 音效播放
- **AmbientSounds** (`ambient_sounds.gd`) - 环境音播放

#### dialogue_manager

**职责**: 非线性对话系统

**组件**:
- **DialogueManager** (`dialogue_manager.gd`) - 对话管理器
- **DialogueResource** (`dialogue_resource.gd`) - 对话资源
- **DialogueLine** (`dialogue_line.gd`) - 对话行

#### gut

**职责**: GDScript 单元测试框架

**组件**:
- **Gut** (`gut.gd`) - 测试运行器
- **Test** (`test.gd`) - 测试基类

### 2. 游戏逻辑层 (`scripts/`)

#### Autoload 单例

**EventBus** (`autoloads/event_bus.gd`)
- 定义游戏特定的信号（烹饪、配方、设备等）
- 提供信号发射的便捷方法
- **注意**: 当前实现使用 Godot 原生信号，未与框架 EventBus 集成

**UIManager** (`autoloads/ui_manager.gd`)
- 简化的 UI 面板管理
- 面板栈和缓存
- **注意**: 当前实现是独立的，未使用框架 UIManager

**AudioManager** (`autoloads/audio_manager.gd`)
- 音频总线管理（Master, Music, SFX, Ambient）
- 音频播放器池
- 淡入淡出效果
- 音量控制
- **注意**: 使用框架 EventBus 接收音频请求

**SaveManager** (`autoloads/save_manager.gd`)
- 存档槽位管理（最多 3 个）
- 自动保存（5 分钟间隔）
- 存档验证和版本管理
- 设置保存/加载
- **注意**: 使用框架 EventBus 接收存档请求

### 3. 场景层 (`scenes/`)

#### screens/

**main_menu.gd / main_menu.tscn**
- 游戏入口场景
- 提供开始游戏、继续游戏、设置、退出选项
- 检查存档状态
- 连接按钮信号
- 使用 `UIManager` 打开设置面板

### 4. 资源层 (`assets/`)

#### fonts/

- `MiSans-Semibold.otf` / `.ttf` - 中文友好字体

#### icons/

- SVG 矢量图标，按功能分类
- 单色设计，支持缩放

#### theme/

- `minimal_vector.tres` - 极简矢量主题
- `modern_flat.tres` - 现代扁平主题

### 5. 工具层 (`tools/`)

**generate_guide_context.gd**
- 生成 GUIDE 输入上下文配置
- 用于自动化输入映射设置

## 模块依赖关系

```
scenes/screens/main_menu.gd
    ├── scripts/autoloads/event_bus.gd (EventBus)
    ├── scripts/autoloads/ui_manager.gd (UIManager)
    ├── scripts/autoloads/save_manager.gd (SaveManager)
    └── scripts/autoloads/audio_manager.gd (AudioManager)

scripts/autoloads/event_bus.gd
    └── (无外部依赖，使用 Godot 原生信号)

scripts/autoloads/ui_manager.gd
    └── scripts/autoloads/event_bus.gd (EventBus)

scripts/autoloads/audio_manager.gd
    └── scripts/autoloads/event_bus.gd (EventBus)

scripts/autoloads/save_manager.gd
    ├── scripts/autoloads/event_bus.gd (EventBus)
    └── scripts/autoloads/audio_manager.gd (AudioManager)
```

## 当前状态

### 已实现

- [x] 项目基础结构
- [x] 框架插件集成
- [x] Autoload 单例（EventBus, UIManager, AudioManager, SaveManager）
- [x] 主菜单场景
- [x] 资源组织（字体、图标、主题）
- [x] GUIDE 输入系统集成

### 待实现

- [ ] 游戏核心场景（厨房、设备交互）
- [ ] 烹饪系统
- [ ] 材料和配方数据
- [ ] 设备系统
- [ ] 图鉴和分类系统
- [ ] 谱系系统
- [ ] 与框架 EventBus/UIManager 的集成
- [ ] 完整的存档系统实现
- [ ] 音频资源和播放逻辑
- [ ] UI 面板（设置、图鉴、设备交互等）

## 关键发现

### 1. 双重实现问题

项目存在两套 EventBus 和 UIManager 实现：
- 框架层：`common/addons/mc_game_framework/autoload/event_bus.gd`（Event 对象，publish/subscribe）
- 游戏层：`scripts/autoloads/event_bus.gd`（Godot 原生信号，emit/connect）

**建议**: 统一使用框架 EventBus，将游戏特定的信号转换为 Event 对象。

### 2. 插件复制问题

`addons/` 和 `common/addons/` 存在重复的插件代码。

**原因**: Godot 要求插件必须在 `addons/` 目录，而 `common/` 用于跨项目复用。

**建议**: 使用符号链接或构建脚本自动同步。

### 3. 输入系统混合

项目同时定义了 Godot 原生 Input Map（`project.godot` 中的 `[input]` 段）和 GUIDE 系统。

**建议**: 完全迁移到 GUIDE 系统，移除原生 Input Map 配置。

### 4. 资源目录空置

`resources/` 目录当前为空，游戏数据（材料、配方、设备等）尚未定义。

**建议**: 按照 Resource 数据驱动模式，在 `resources/` 下创建数据资源文件。
