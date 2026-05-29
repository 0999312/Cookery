# 1-CONTEXT.md - 阶段 1 决策文档

> 阶段: 基础架构修复
> 决策时间: 2026/05/29

## 决策摘要

| 决策 | 选择 | 原因 |
|------|------|------|
| 目录策略 | 删除 common/，保留 addons/ | project.godot 已指向 addons/ |
| 主菜单范围 | 完整菜单 | 包含开始、继续、设置、退出 |
| 设置面板 | 阶段 1 实现 | 主菜单需要设置功能 |
| 存档系统 | 阶段 1 基础实现 | 继续游戏需要存档 |
| GUIDE 配置 | 完整输入系统 | 配置所有上下文 |

---

## 1. 目录策略

**决策**: 删除 `common/` 文件夹，保留 `addons/`

**原因**:
- `project.godot` 的 `editor_plugins` 指向 `res://addons/`
- `common/` 是之前提取的通用内容，现在不需要了
- 保持项目结构简洁

**执行**:
```bash
rm -rf common/
```

---

## 2. 框架 Autoload 注册

**决策**: 注册 7 个框架 Autoload

**清单**:

| 名称 | 路径 | 用途 |
|------|------|------|
| `RegistryManager` | `addons/mc_game_framework/autoload/registry_manager.gd` | 数据注册中心 |
| `EventBus` | `addons/mc_game_framework/autoload/event_bus.gd` | 跨系统事件通信 |
| `UIManager` | `addons/mc_game_framework/autoload/ui_manager.gd` | UI 面板栈管理 |
| `I18NManager` | `addons/mc_game_framework/autoload/i18n_manager.gd` | 国际化管理 |
| `SoundManager` | `addons/sound_manager/sound_manager.gd` | 音频播放管理 |
| `GUIDE` | `addons/guide/guide.gd` | 输入映射系统 |
| `DialogueManager` | `addons/dialogue_manager/dialogue_manager.gd` | 对话系统 |

**注意**:
- 删除自定义的 `scripts/autoloads/event_bus.gd`、`ui_manager.gd`、`audio_manager.gd`
- 保留 `scripts/autoloads/save_manager.gd`（框架未提供）

---

## 3. 主菜单设计

**决策**: 完整菜单，4 个按钮

**功能**:
- **开始游戏**: 创建新存档，跳转到游戏场景
- **继续游戏**: 加载存档，跳转到游戏场景
- **设置**: 打开设置面板（UIManager）
- **退出**: 保存设置，退出游戏

**技术要求**:
- 使用 `UIPanel` 基类（如果作为面板）
- 使用 `GUIDE` 上下文处理输入
- 使用 `ResourceLocation` 标识面板

---

## 4. 设置面板

**决策**: 阶段 1 实现基础设置面板

**功能**:
- 音量控制（音乐、音效）
- 全屏切换
- 语言选择（可选）

**技术要求**:
- 继承 `UIPanel`
- 通过 `UIManager.open_panel()` 打开
- 使用 `SoundManager` 控制音量

---

## 5. 存档系统

**决策**: 阶段 1 实现基础 JSON 存档

**功能**:
- 保存游戏状态到 JSON
- 从 JSON 加载游戏状态
- 支持 3 个存档槽位
- 检查存档是否存在

**技术要求**:
- 使用 `ConfigFile` 或 `JSON` 类
- 存档路径: `user://saves/`
- 存档格式: `save_0.json`、`save_1.json`、`save_2.json`

---

## 6. GUIDE 输入系统

**决策**: 配置完整输入系统

**上下文清单**:

| 上下文 | 用途 | Actions |
|--------|------|---------|
| `menu_context` | 主菜单/设置 | confirm, cancel, navigate_up, navigate_down |
| `game_context` | 游戏场景 | move, interact, pause, inventory |
| `equipment_context` | 设备交互 | add_item, remove_item, process, cancel |

**Actions 清单**:

| Action | 默认按键 | 用途 |
|--------|----------|------|
| `confirm` | Enter/Space | 确认选择 |
| `cancel` | Escape | 取消/返回 |
| `navigate_up` | W/↑ | 向上导航 |
| `navigate_down` | S/↓ | 向下导航 |
| `navigate_left` | A/← | 向左导航 |
| `navigate_right` | D/→ | 向右导航 |
| `move` | WASD | 移动 |
| `interact` | E | 交互 |
| `pause` | Escape | 暂停 |
| `inventory` | Tab | 打开背包 |

---

## 7. 事件定义

**决策**: 阶段 1 定义基础游戏事件

**事件清单**:

| 事件 | 数据 | 触发时机 |
|------|------|----------|
| `GameStartedEvent` | 无 | 游戏开始 |
| `GamePausedEvent` | `is_paused: bool` | 游戏暂停 |
| `SceneChangedEvent` | `scene_path: String` | 场景切换 |
| `SaveCompletedEvent` | `slot: int, success: bool` | 存档完成 |
| `LoadCompletedEvent` | `slot: int, success: bool` | 读档完成 |

---

## 验收标准

- [ ] `common/` 目录已删除
- [ ] `project.godot` 注册 7 个框架 Autoload
- [ ] 无自定义 EventBus/UIManager/AudioManager
- [ ] 主菜单 4 个按钮正常工作
- [ ] 设置面板可打开和调整
- [ ] 存档/读档功能正常
- [ ] GUIDE 上下文切换正常
- [ ] 无运行时错误

---

## 下一步

运行 `/gsd-plan-phase 1` 进行详细任务规划。