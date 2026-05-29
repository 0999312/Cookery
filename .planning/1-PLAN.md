# 1-PLAN.md - 阶段 1 执行计划

> 阶段: 基础架构修复
> 创建时间: 2026/05/29
> 预计时间: 3-4 天

## 目标

修复 P0 问题，统一架构实现，建立坚实基础。

## 任务分解

### Wave 1: 清理和配置（基础）

#### 任务 1.1: 删除 common/ 目录
- **描述**: 删除整个 common/ 文件夹
- **命令**: `rm -rf common/`
- **验证**: 目录不存在

#### 任务 1.2: 删除自定义 Autoload
- **描述**: 删除 scripts/autoloads/ 下的自定义实现
- **文件**:
  - `scripts/autoloads/event_bus.gd`
  - `scripts/autoloads/ui_manager.gd`
  - `scripts/autoloads/audio_manager.gd`
- **保留**: `scripts/autoloads/save_manager.gd`
- **验证**: 文件不存在

#### 任务 1.3: 更新 project.godot Autoload
- **描述**: 注册 7 个框架 Autoload
- **配置**:
```ini
[autoload]
RegistryManager="*res://addons/mc_game_framework/autoload/registry_manager.gd"
EventBus="*res://addons/mc_game_framework/autoload/event_bus.gd"
UIManager="*res://addons/mc_game_framework/autoload/ui_manager.gd"
I18NManager="*res://addons/mc_game_framework/autoload/i18n_manager.gd"
SoundManager="*res://addons/sound_manager/sound_manager.gd"
GUIDE="*res://addons/guide/guide.gd"
DialogueManager="*res://addons/dialogue_manager/dialogue_manager.gd"
SaveManager="*res://scripts/autoloads/save_manager.gd"
```
- **验证**: project.godot 包含正确的 Autoload 配置

#### 任务 1.4: 移除原生 Input Map
- **描述**: 删除 project.godot 中的 [input] 配置段
- **验证**: 无 [input] 配置

---

### Wave 2: GUIDE 输入系统

#### 任务 2.1: 创建 GUIDE Action 资源
- **目录**: `input/actions/`
- **文件**:
  - `confirm_action.tres` - 确认（Enter/Space）
  - `cancel_action.tres` - 取消（Escape）
  - `navigate_up_action.tres` - 向上（W/↑）
  - `navigate_down_action.tres` - 向下（S/↓）
  - `navigate_left_action.tres` - 向左（A/←）
  - `navigate_right_action.tres` - 向右（D/→）
  - `move_action.tres` - 移动（WASD）
  - `interact_action.tres` - 交互（E）
  - `pause_action.tres` - 暂停（Escape）
  - `inventory_action.tres` - 背包（Tab）

#### 任务 2.2: 创建 GUIDE MappingContext 资源
- **目录**: `input/contexts/`
- **文件**:
  - `menu_context.tres` - 菜单上下文（confirm, cancel, navigate_*）
  - `game_context.tres` - 游戏上下文（move, interact, pause, inventory）
  - `equipment_context.tres` - 设备上下文（interact, cancel, confirm）

#### 任务 2.3: 验证 GUIDE 资源
- **验证**: 资源可加载，无错误

---

### Wave 3: 事件系统

#### 任务 3.1: 创建游戏事件类
- **目录**: `events/`
- **文件**:
  - `game_started_event.gd` - 游戏开始
  - `game_paused_event.gd` - 游戏暂停（is_paused: bool）
  - `scene_changed_event.gd` - 场景切换（scene_path: String）
  - `save_completed_event.gd` - 存档完成（slot: int, success: bool）
  - `load_completed_event.gd` - 读档完成（slot: int, success: bool）

#### 任务 3.2: 验证事件类
- **验证**: 类可实例化，EventBus.publish() 正常工作

---

### Wave 4: 存档系统

#### 任务 4.1: 重写 SaveManager
- **文件**: `scripts/autoloads/save_manager.gd`
- **功能**:
  - `save_game(slot: int)` - 保存到 JSON
  - `load_game(slot: int)` - 从 JSON 加载
  - `delete_save(slot: int)` - 删除存档
  - `save_exists(slot: int)` - 检查存档
  - `get_save_info(slot: int)` - 获取存档信息
- **存档路径**: `user://saves/save_0.json`
- **存档格式**:
```json
{
  "version": "1.0.0",
  "timestamp": 1234567890,
  "play_time": 0,
  "game_state": {},
  "settings": {}
}
```

#### 任务 4.2: 验证存档系统
- **验证**: 保存/加载/删除正常工作

---

### Wave 5: UI 面板

#### 任务 5.1: 创建设置面板
- **文件**:
  - `scenes/ui/settings_panel.tscn`
  - `scenes/ui/settings_panel.gd`
- **功能**:
  - 音量滑块（音乐、音效）
  - 全屏切换
  - 返回按钮
- **技术**:
  - 继承 UIPanel
  - 使用 ResourceLocation 标识
  - 通过 UIManager 打开

#### 任务 5.2: 注册面板到 UIRegistry
- **位置**: 游戏初始化脚本
- **注册**:
```gdscript
var ui_registry = UIRegistry.new()
RegistryManager.register_registry("ui", ui_registry)
ui_registry.register_panel(
    ResourceLocation.from_string("cookery:ui/settings"),
    preload("res://scenes/ui/settings_panel.tscn"),
    UILayer.NORMAL,
    UIPanel.CacheMode.CACHE
)
```

#### 任务 5.3: 验证设置面板
- **验证**: 面板可打开、调整、关闭

---

### Wave 6: 主菜单

#### 任务 6.1: 重写主菜单脚本
- **文件**: `scenes/screens/main_menu.gd`
- **功能**:
  - 开始游戏 - 创建新存档，跳转场景
  - 继续游戏 - 加载存档，跳转场景
  - 设置 - 打开设置面板
  - 退出 - 保存设置，退出游戏
- **技术**:
  - 使用 GUIDE 上下文
  - 使用 UIManager 打开设置
  - 使用 SaveManager 管理存档

#### 任务 6.2: 更新主菜单场景
- **文件**: `scenes/screens/main_menu.tscn`
- **UI 元素**:
  - 标题 Label
  - 4 个 Button（开始、继续、设置、退出）
  - 版本号 Label

#### 任务 6.3: 验证主菜单
- **验证**: 所有按钮功能正常

---

## 依赖关系

```
Wave 1 (清理) ──→ Wave 2 (GUIDE) ──→ Wave 5 (UI) ──→ Wave 6 (主菜单)
      │                │                  │
      └──→ Wave 3 (事件) ────────────────→┘
      │
      └──→ Wave 4 (存档) ────────────────→┘
```

## 验收标准

- [ ] `common/` 目录已删除
- [ ] `project.godot` 注册 8 个 Autoload（7 框架 + SaveManager）
- [ ] 无自定义 EventBus/UIManager/AudioManager
- [ ] GUIDE 输入系统正常工作（3 个上下文）
- [ ] 游戏事件类可正常使用
- [ ] 存档/读档功能正常
- [ ] 设置面板可打开和调整
- [ ] 主菜单 4 个按钮正常工作
- [ ] 无运行时错误

## 风险和缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 框架 API 不熟悉 | 中 | 参考 1-RESEARCH.md |
| GUIDE 资源创建复杂 | 中 | 使用代码生成或手动创建 .tres |
| UIPanel 生命周期问题 | 低 | 参考框架示例代码 |

## 下一步

完成阶段 1 后，运行 `/gsd-plan-phase 2` 开始数据层实现。