# CONCERNS.md - Cookery 项目关注点分析

> 生成时间: 2026-05-29
> 项目状态: 项目清理后重建阶段，大量游戏代码已删除

---

## 1. 技术债务

### 1.1 双重 EventBus 实现冲突

**严重程度: 高**

`addons/mc_game_framework/autoload/event_bus.gd` 和 `scripts/autoloads/event_bus.gd` 是两个完全不同的实现：

| 维度 | 框架版 (addons/) | 自定义版 (scripts/) |
|------|------------------|---------------------|
| 模式 | publish/subscribe + Event 对象 | 原生 Signal |
| API | `subscribe()` / `publish()` | 直接 `signal.emit()` |
| 特性 | 事件取消、信号桥接、过期清理 | 无 |

`project.godot` 注册的是 `scripts/autoloads/event_bus.gd`，但 CLAUDE.md 明确要求使用框架的 EventBus。当前自定义版缺少事件取消、信号桥接等关键功能，且与框架的 UIPanel/UIManager 事件系统（UIOpenEvent、UICloseEvent 等）不兼容。

**风险**: 后续所有使用框架 UIPanel 生命周期的代码都无法正常工作。

### 1.2 双重 UIManager 实现冲突

**严重程度: 高**

同样的问题存在于 UIManager：

| 维度 | 框架版 (addons/) | 自定义版 (scripts/) |
|------|------------------|---------------------|
| 面板标识 | `ResourceLocation` | `String` 路径 |
| 层级系统 | `UILayer` 枚举 + CanvasLayer | 简单整数常量 + z_index |
| 缓存 | LRU 缓存淘汰 | 无限缓存 |
| 特性 | 覆盖层、Toast、弹窗队列、循环保护 | 仅面板栈 |

当前 `main_menu.gd` 调用 `UIManager.open_panel(SETTINGS_SCENE)` 用的是字符串路径，这是自定义版 API。框架版要求 `ResourceLocation`。

### 1.3 双重音频管理器

**严重程度: 中**

- `addons/sound_manager/` — 完整的音频管理插件（Music、SFX、Ambient 池化）
- `scripts/autoloads/audio_manager.gd` — 自定义简化版

`project.godot` 注册的是自定义版 `AudioManager`，但框架要求使用 `SoundManager`。自定义版存在以下问题：
- `_init_audio_buses()` 会覆盖已有的 Master 总线（`set_bus_name(0, BUS_MASTER)`）
- `_fade_in()` 只接受 `AudioStreamPlayer`，不支持 `AudioStreamPlayer2D`
- 音频缓存无限增长，无淘汰机制

### 1.4 addons/ 与 common/addons/ 目录重复

**严重程度: 中**

`addons/` 和 `common/addons/` 包含完全相同的插件集合（dialogue_manager、guide、gut、kenney_interface_sounds、mc_game_framework、sound_manager）。这意味着：
- 插件存在两份副本，占用空间
- 修改一份不会同步到另一份
- 容易造成混淆（哪个是权威版本）

`project.godot` 的 `editor_plugins` 指向 `res://addons/`，但 CLAUDE.md 中的很多引用指向 `common/addons/`。

---

## 2. 潜在问题

### 2.1 main_menu.gd 引用不存在的场景

**严重程度: 高**

```gdscript
const GAME_SCENE: String = "res://scenes/game_scene.tscn"
const SETTINGS_SCENE: String = "res://scenes/ui/settings_panel.tscn"
```

这两个场景文件都已被删除。点击"开始游戏"或"设置"会导致运行时崩溃。

### 2.2 project.godot 缺少框架 Autoload 注册

**严重程度: 高**

`project.godot` 只注册了 4 个自定义 autoload：
```ini
EventBus="*res://scripts/autoloads/event_bus.gd"
UIManager="*res://scripts/autoloads/ui_manager.gd"
AudioManager="*res://scripts/autoloads/audio_manager.gd"
SaveManager="*res://scripts/autoloads/save_manager.gd"
```

缺少 CLAUDE.md 要求的：
- `RegistryManager` — 框架数据注册中心
- `I18NManager` — 国际化管理器
- `GUIDE` — 输入系统（虽然插件已安装，但未注册为 autoload）
- `SoundManager` — 框架音频管理器
- `DialogueManager` — 对话系统

### 2.3 GUIDE 输入系统未被使用

**严重程度: 中**

CLAUDE.md 明确要求"必须通过 GUIDE 上下文系统，不得直接使用 Input.is_action_*"，但：
- `project.godot` 中定义了原生 `input` 映射（pause、move_left 等）
- `main_menu.gd` 没有使用 GUIDE
- 之前创建的 GUIDE action/context 资源（`input/` 目录）已被删除

### 2.4 SaveManager 存根方法

**严重程度: 中**

`scripts/autoloads/save_manager.gd` 中多个关键方法是空实现：
- `_collect_game_state()` 返回硬编码空字典
- `_collect_player_data()` 返回假数据
- `_get_play_time()` 始终返回 0.0
- `_validate_save_version()` 始终返回 true
- `_apply_game_state()` 等应用方法为空 `pass`

存档系统在架构上完整但功能上不可用。

### 2.5 version 字段未定义

**严重程度: 低**

`main_menu.gd` 读取 `application/config/version`：
```gdscript
version_label.text = "v" + ProjectSettings.get_setting("application/config/version", "1.0.0")
```

但 `project.godot` 的 `[application]` 段没有定义 `config/version`，会始终显示 "v1.0.0"。

---

## 3. 迁移风险

### 3.1 Web 原型数据丢失风险

**严重程度: 高**

Web 原型目录 (`prototype/`) 已从仓库中删除。根据 CLAUDE.md 描述，原型包含：
- 1900 行 JavaScript
- 60+ 配方数据
- 3 种设备逻辑
- 谱系/分类/图鉴系统

如果这些数据没有在其他地方保留（如 git 历史或外部备份），迁移所需的参考数据将丢失。

### 3.2 已实现的游戏数据层全部删除

**严重程度: 高**

以下数据 Resource 子类已全部删除：
- `data/materials/material_data.gd` — 材料数据
- `data/equipment/equipment_data.gd` — 设备数据
- `data/recipes/recipe_data.gd` — 配方数据
- `data/achievements/achievement_data.gd` — 成就数据
- `data/categories/food_category_data.gd` — 食物分类数据
- `data/discovery/recipe_codex_data.gd` — 图鉴数据
- `data/tags/tag_definitions.gd` — 标签定义
- `data/save/*.gd` — 存档数据结构
- `data/i18n/*.json` — 翻译文件

这些是之前 4 个阶段的产出物，删除后需要重新实现。

### 3.3 已实现的系统逻辑全部删除

**严重程度: 高**

以下系统脚本已删除：
- `scripts/systems/crafting_system.gd` — 烹饪系统
- `scripts/systems/recipe_codex.gd` — 图鉴系统
- `scripts/systems/lineage_system.gd` — 谱系系统
- `scripts/systems/food_category_system.gd` — 分类系统
- `scripts/systems/achievement_system.gd` — 成就系统
- `scripts/systems/dynamic_naming.gd` — 动态命名
- `scripts/systems/fermenter_handler.gd` — 发酵设备处理

### 3.4 UI 面板全部删除

**严重程度: 高**

已删除的 UI 场景和脚本：
- 游戏主场景 (`game_scene.gd/tscn`)
- 加载屏幕 (`loading_screen.gd/tscn`)
- 暂停菜单、设置面板、存档面板
- 材料面板、设备面板、图鉴面板
- 成就面板、分类面板、谱系面板
- 输入/输出槽位、结果详情卡

### 3.5 测试全部删除

**严重程度: 中**

已删除的测试文件：
- `test_crafting_system.gd`
- `test_crafting_events.gd`
- `test_fermenter_naming.gd`
- `test_recipe_migration.gd`

### 3.6 配方数据与原型对齐风险

**严重程度: 中**

CLAUDE.md 要求"配方数据、材料数据必须与 Web 原型完全一致，不得自行增删"。但：
- 原型数据不可直接访问（prototype/ 已删除）
- 已实现的数据资源已删除
- 没有自动化验证机制确保数据一致性

---

## 4. 架构问题

### 4.1 Input Map 与 GUIDE 系统共存

**严重程度: 中**

`project.godot` 同时定义了原生 Input Map（pause、move_left 等）和 GUIDE 插件。这违反了 CLAUDE.md 的约束。应该：
- 移除 `[input]` 段中的所有原生映射
- 通过 GUIDE 的 action/context 资源定义所有输入

### 4.2 2D 项目配置了 3D 物理引擎

**严重程度: 低**

`project.godot` 启用了 Jolt Physics 3D，但这是一个 2D 烹饪游戏。虽然不影响功能，但增加了不必要的引擎开销。

### 4.3 default_texture_filter=0 (最近邻)

**严重程度: 低**

```ini
textures/canvas_textures/default_texture_filter=0
```

这是像素风格的设置。但 CLAUDE.md 明确指出画风是"扁平化（Flat Design），非像素风格"，应使用双线性过滤（值为 1）。

### 4.4 未使用框架的 Codec/Component 系统

**严重程度: 中**

mc_game_framework 提供了完整的序列化框架（Codec、DataResult、ComponentContainer），但当前 SaveManager 使用原始 JSON 手动序列化。这导致：
- 无法利用 DataResult 的错误恢复能力
- 无法利用 Codec 的可组合编解码
- 存档数据迁移困难（无版本化编解码）

### 4.5 缺少 Registry 初始化

**严重程度: 中**

`RegistryManager`（框架 autoload）未在 `project.godot` 中注册。即使注册后，也没有代码调用 `RegistryManager.register_registry()` 来注册 UIRegistry、TagRegistry、ComponentTypeRegistry。UIManager 依赖 UIRegistry 来实例化面板。

---

## 5. 安全考虑

### 5.1 存档数据无加密

**严重程度: 低（原型阶段可接受）**

SaveManager 将存档以明文 JSON 写入 `user://saves/`。玩家可以轻松篡改存档数据。对于原型阶段这是可接受的，但正式发布前需要考虑：
- 存档校验和
- 关键数据加密
- 版本迁移时的数据完整性验证

### 5.2 存档版本验证形同虚设

**严重程度: 低**

`_validate_save_version()` 始终返回 true，不检查版本兼容性。如果存档格式变更，旧存档可能导致数据丢失或崩溃。

### 5.3 无存档备份机制

**严重程度: 低**

自动保存直接覆盖当前槽位，没有备份。如果自动保存时游戏崩溃，存档可能损坏。

---

## 6. 优化机会

### 6.1 统一使用框架 Autoload

将 `project.godot` 的 autoload 全部替换为框架提供的实现：
- `EventBus` -> `addons/mc_game_framework/autoload/event_bus.gd`
- `UIManager` -> `addons/mc_game_framework/autoload/ui_manager.gd`
- 添加 `RegistryManager`、`I18NManager`

自定义的 `audio_manager.gd` 应替换为 `addons/sound_manager/sound_manager.gd`。

### 6.2 移除 common/ 目录或 addons/ 目录

选择一个权威目录：
- 如果 `common/` 是跨项目共享的模板，保留它作为源头，`addons/` 通过符号链接或复制脚本同步
- 如果不需要跨项目共享，删除 `common/` 只保留 `addons/`

### 6.3 建立数据验证机制

创建测试脚本验证游戏数据与 Web 原型的一致性：
- 材料属性标签映射验证
- 配方输入/输出验证
- 设备变换规则验证

### 6.4 利用框架 Codec 替代手动 JSON

将 SaveManager 的序列化迁移到 Codec 系统：
- 为每种游戏数据定义 Codec
- 使用 DataResult 处理解析错误
- 利用 Codec 的版本迁移能力

### 6.5 清理 project.godot Input Map

移除原生 Input Map 定义，全面迁移到 GUIDE 系统。

---

## 7. 优先级排序

| 优先级 | 关注点 | 影响范围 |
|--------|--------|----------|
| P0 | 统一 EventBus/UIManager 为框架版 | 所有系统 |
| P0 | 注册缺失的框架 Autoload | 所有系统 |
| P0 | 修复 main_menu.gd 的断裂引用 | 游戏可运行性 |
| P1 | 恢复或重新实现游戏数据层 | 核心玩法 |
| P1 | 恢复或重新实现系统逻辑 | 核心玩法 |
| P1 | 恢复或重新实现 UI 面板 | 玩家交互 |
| P1 | 保留 Web 原型数据的访问途径 | 迁移准确性 |
| P2 | 清理 common/ 与 addons/ 重复 | 项目整洁度 |
| P2 | 迁移输入系统到 GUIDE | 架构一致性 |
| P2 | 迁移存档系统到 Codec | 数据可靠性 |
| P3 | 移除 Jolt 3D 配置 | 包体积 |
| P3 | 修正 texture_filter 设置 | 视觉一致性 |
| P3 | 添加存档加密/校验 | 发布准备 |
