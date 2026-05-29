# 里程碑总结 v1.0 — Cookery 原型交付

> 生成时间: 2026/05/29
> 项目: Cookery（厨房）
> 引擎: Godot 4.6.2 stable

---

## 1. 项目概述

**Cookery** 是一款基于"设备即界面"理念的沙盒烹饪游戏。玩家自由搭配材料与制作设备，通过属性标签的变换/组合/消除/增幅，涌现出意料之外的料理成品。

**核心循环**: 材料 → 设备 → 属性变换 → 涌现结果 → 发现

**v1.0 里程碑**: 从零搭建完整的可玩原型，包含数据系统、烹饪逻辑、UI 界面和存档功能。

### 交付统计

| 指标 | 数值 |
|------|------|
| GDScript 文件 | 16 个 |
| 场景文件 | 6 个 |
| 测试文件 | 3 个 |
| 代码总行数 | ~3,023 行 |
| 材料数据 | 60 种 |
| 配方数据 | 20 个 |
| 设备数据 | 3 种 |
| 标签数据 | 28 个 |

---

## 2. 架构总览

```
┌─────────────────────────────────────────────────────────────┐
│                       主菜单场景                              │
│                    (main_menu.tscn)                          │
├─────────────────────────────────────────────────────────────┤
│                     UIManager 面板栈                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ GamePanel│  │CodexPanel│  │PauseMenu │  │Settings  │    │
│  │ (NORMAL) │  │ (NORMAL) │  │ (POPUP)  │  │ (POPUP)  │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
├─────────────────────────────────────────────────────────────┤
│                      数据层                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ DataManager  │  │CookingSystem │  │ SaveManager  │      │
│  │ (Autoload)   │  │  (静态类)     │  │ (Autoload)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                   mc_game_framework                          │
│  EventBus | UIManager | Registry | Codec | GUIDE            │
└─────────────────────────────────────────────────────────────┘
```

### 关键设计决策

| 决策 | 选择 | 原因 |
|------|------|------|
| 标签系统 | 框架 TagRegistry | 复用现有基础设施 |
| 变换规则 | 设备内置规则 | 设备决定变换逻辑 |
| 结果系统 | 配方 + 动态涌现 | 平衡确定性和探索性 |
| UI 框架 | UIManager 面板栈 | 遵循项目约束 |
| 输入系统 | GUIDE 上下文 | 遵循项目约束 |
| 数据格式 | Resource + Codec | 数据驱动，支持序列化 |

---

## 3. 阶段执行

### 阶段 1: 基础架构修复 ✅

**目标**: 修复 P0 问题，统一架构实现

**交付内容**:
- 删除重复的 `common/` 目录
- 注册 9 个框架 Autoload（含游戏层）
- 配置 GUIDE 输入系统（3 个上下文、10+ 个动作）
- 实现 JSON 存档系统（3 个槽位）
- 创建设置面板（音量、全屏）
- 重写主菜单（开始、继续、设置、退出）

### 阶段 2: 数据层 ✅

**目标**: 实现材料、属性标签、设备的数据系统

**交付内容**:
- 定义 4 种变换规则类（Convert、Combine、Remove、Amplify）
- 定义 MaterialData、EquipmentData、RecipeData、CodexData
- 注册 28 个标签（状态、元素、材质、类别、效果）
- 创建 60 种基础材料（7 大分类）
- 创建 3 种设备（烤箱、锅、发酵器）
- 创建 20 个配方

### 阶段 3: 核心系统 ✅

**目标**: 实现烹饪流程和设备交互

**交付内容**:
- 实现 CookingSystem 核心烹饪逻辑
- 支持变换规则应用、配方匹配、动态结果生成
- 实现图鉴自动更新
- 定义游戏事件（CookingStarted/Completed、RecipeDiscovered、MaterialUnlocked）

### 阶段 4: UI 界面 ✅

**目标**: 实现所有游戏界面

**交付内容**:
- 游戏主界面（材料选择 + 设备切换 + 烹饪台）
- 图鉴界面（分类过滤 + 搜索 + 详情弹窗）
- 暂停菜单（继续、设置、返回主菜单、退出）
- 结果弹窗（烹饪结果 + 新发现提示）
- 设置面板（音量、全屏）
- 扁平化主题（modern_flat.tres）

### 阶段 5: 完善和优化 ✅

**目标**: 测试、优化、完善游戏体验

**交付内容**:
- SaveData Codec 定义
- 自动保存功能（烹饪完成、发现新配方时触发）
- UI 音效集成（SFXManager）
- 单元测试（CookingSystem、DataManager、SaveManager）

---

## 4. 关键技术决策

### UIPanel 生命周期陷阱

UIManager 的 `_on_init()` 在 `add_child()` 之前调用，此时 `@onready` 变量还是 null。所有信号连接必须延迟到 `_on_open()` 中执行。

```gdscript
func _on_init() -> void:
    pass  # @onready 还未解析

func _ensure_signals() -> void:
    if _signals_connected: return
    _signals_connected = true
    # 在这里连接信号...

func _on_open(data: Dictionary) -> void:
    _ensure_signals()
    # 正常初始化...
```

### POPUP 层返回问题

POPUP 层面板必须显式指定层级：`UIManager.back(UILayer.POPUP)`，否则默认弹出 NORMAL 层。

### 场景切换与 UIManager 清理

返回主菜单时，`UIManager.close_all()` 会将当前面板从场景树移除，导致 `get_tree()` 返回 null。必须先保存引用：

```gdscript
var tree := get_tree()
UIManager.close_all()
UIManager.clear_for_scene_change()
tree.change_scene_to_file("res://scenes/screens/main_menu.tscn")
```

---

## 5. 需求覆盖

| 需求 | 状态 | 说明 |
|------|------|------|
| 设备即界面 | ✅ | 3 种设备，各有不同变换规则 |
| 属性标签变换 | ✅ | 4 种规则类型（转换、组合、消除、增幅） |
| 发现式玩法 | ✅ | 无固定配方表，标签匹配 + 动态涌现 |
| 60+ 种材料 | ✅ | 7 大分类，60 种基础材料 |
| 20+ 种配方 | ✅ | 3 种设备对应 20 个配方 |
| 图鉴系统 | ✅ | 分类过滤、搜索、详情弹窗 |
| 存档系统 | ✅ | 3 个槽位、自动保存 |
| 扁平化 UI | ✅ | modern_flat.tres 主题 |

---

## 6. 已知技术债务

| 项目 | 说明 | 优先级 |
|------|------|--------|
| SlotLabel 命名冲突 | 三个 InputSlot 同名，需改用 find_child | 低 |
| 变量遮蔽警告 | Codec 构造函数参数与 @export 属性同名 | 低 |
| 图鉴卡片点击 | 使用 gui_input 而非 Button，交互不够直观 | 中 |
| 动态结果命名 | 仅基于标签组合，未考虑材料名称 | 中 |
| 音效集成 | SFXManager 已创建但音效文件缺失 | 中 |

---

## 7. 快速上手

### 运行项目

1. 用 Godot 4.6 打开 `E:\godot_learning\projects\cookery`
2. 按 F5 运行
3. 主菜单 → 开始游戏 → 选择设备和材料 → 烹饪

### 关键文件

| 文件 | 用途 |
|------|------|
| `scripts/autoloads/data_manager.gd` | 所有游戏数据（60 材料、3 设备、20 配方） |
| `scripts/systems/cooking_system.gd` | 烹饪核心逻辑 |
| `scenes/ui/game_panel.gd` | 游戏主界面逻辑 |
| `scripts/autoloads/save_manager.gd` | 存档系统 |
| `scripts/autoloads/ui_setup.gd` | UI 面板注册 |

### 扩展指南

- **添加材料**: 在 `data_manager.gd` 的 `_load_materials()` 中调用 `_register_material()`
- **添加配方**: 在 `_load_recipes()` 中调用 `_create_recipe()`
- **添加设备**: 在 `_load_equipment()` 中创建 EquipmentData 并设置变换规则
- **添加 UI 面板**: 创建 UIPanel 子类，在 `ui_setup.gd` 中注册

---

## 8. 后续方向

| 方向 | 说明 |
|------|------|
| 音效和音乐 | 添加烹饪音效、背景音乐 |
| 更多材料和配方 | 扩展到 100+ 材料、50+ 配方 |
| 设备升级 | 设备可升级，解锁新变换规则 |
| 成就系统 | 特定配方组合解锁成就 |
| 教程引导 | 新手引导流程 |
| 移动端适配 | 触屏交互重新设计 |
