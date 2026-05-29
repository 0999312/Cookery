# 4-PLAN.md - 阶段 4 执行计划

> 阶段: UI 界面
> 创建时间: 2026/05/29
> 预计时间: 5-6 天
> 参考: 4-CONTEXT.md

## 目标

实现所有游戏界面，建立完整的游戏 UI 系统。

## 任务分解

### Wave 1: 面板注册和基础设置

#### 任务 1.1: 创建面板注册脚本
- **文件**: `scripts/autoloads/ui_setup.gd`
- **功能**: 注册所有面板到 UIRegistry

```gdscript
extends Node

func _ready() -> void:
    _register_panels()


func _register_panels() -> void:
    var ui_registry = RegistryManager.get_registry("ui")
    if not ui_registry:
        ui_registry = UIRegistry.new()
        RegistryManager.register_registry("ui", ui_registry)

    # 注册游戏主界面
    ui_registry.register_panel(
        ResourceLocation.from_string("cookery:ui/game"),
        preload("res://scenes/ui/game_panel.tscn"),
        UILayer.NORMAL,
        UIPanel.CacheMode.CACHE
    )

    # 注册图鉴界面
    ui_registry.register_panel(
        ResourceLocation.from_string("cookery:ui/codex"),
        preload("res://scenes/ui/codex_panel.tscn"),
        UILayer.NORMAL,
        UIPanel.CacheMode.CACHE
    )

    # 注册结果弹窗
    ui_registry.register_panel(
        ResourceLocation.from_string("cookery:ui/result"),
        preload("res://scenes/ui/result_popup.tscn"),
        UILayer.POPUP,
        UIPanel.CacheMode.NONE
    )

    # 注册暂停菜单
    ui_registry.register_panel(
        ResourceLocation.from_string("cookery:ui/pause"),
        preload("res://scenes/ui/pause_menu.tscn"),
        UILayer.POPUP,
        UIPanel.CacheMode.NONE
    )

    print("[UISetup] 面板注册完成")
```

#### 任务 1.2: 添加 UISetup 到 project.godot
- **配置**: `UISetup="*res://scripts/autoloads/ui_setup.gd"`

---

### Wave 2: 游戏主界面

#### 任务 2.1: 创建游戏主界面脚本
- **文件**: `scenes/ui/game_panel.gd`
- **继承**: UIPanel
- **功能**:
  - 设备选择（菜单栏）
  - 材料选择（左侧面板）
  - 设备操作（右侧面板）
  - 状态显示（底部状态栏）

**节点结构**:
```
GamePanel (UIPanel)
├── MenuBar (HBoxContainer)
│   ├── StoveButton (Button)
│   ├── PotButton (Button)
│   ├── FermenterButton (Button)
│   ├── CodexButton (Button)
│   ├── SettingsButton (Button)
│   └── PauseButton (Button)
├── ContentContainer (HBoxContainer)
│   ├── MaterialPanel (VBoxContainer)
│   │   ├── BaseMaterialsLabel (Label)
│   │   ├── BaseMaterialsGrid (GridContainer)
│   │   ├── ProcessedMaterialsLabel (Label)
│   │   └── ProcessedMaterialsGrid (GridContainer)
│   └── EquipmentPanel (VBoxContainer)
│       ├── InputSlotsContainer (HBoxContainer)
│       │   ├── InputSlot1 (PanelContainer)
│       │   └── InputSlot2 (PanelContainer)
│       ├── StartButton (Button)
│       └── ResultPreview (PanelContainer)
└── StatusBar (HBoxContainer)
    ├── MaterialCountLabel (Label)
    └── RecipeCountLabel (Label)
```

**核心逻辑**:
```gdscript
extends UIPanel

var current_equipment: EquipmentData
var selected_materials: Array[String] = []
var is_processing: bool = false

func _on_open(data: Dictionary = {}) -> void:
    _update_material_list()
    _update_status_bar()
    GuideSetup.switch_to_game_context()

func _on_equipment_selected(equipment_id: String) -> void:
    current_equipment = DataManager.get_equipment(equipment_id)
    _update_input_slots()

func _on_material_selected(material_id: String) -> void:
    if selected_materials.size() < current_equipment.max_inputs:
        selected_materials.append(material_id)
        _update_input_slots()

func _on_start_pressed() -> void:
    if selected_materials.is_empty():
        return

    is_processing = true
    EventBus.publish(CookingStartedEvent.new(current_equipment.id, selected_materials))

    # 等待处理时间
    await get_tree().create_timer(current_equipment.process_time).timeout

    # 执行烹饪
    var result = CookingSystem.start_cooking(current_equipment.id, selected_materials)
    CookingSystem.complete_cooking(result)

    # 显示结果
    _show_result(result)
    is_processing = false
```

#### 任务 2.2: 创建游戏主界面场景
- **文件**: `scenes/ui/game_panel.tscn`
- **布局**: 按照 4-CONTEXT.md 设计

---

### Wave 3: 图鉴界面

#### 任务 3.1: 创建图鉴界面脚本
- **文件**: `scenes/ui/codex_panel.gd`
- **继承**: UIPanel
- **功能**:
  - 分类标签切换
  - 网格卡片显示
  - 搜索过滤
  - 详情弹窗

**节点结构**:
```
CodexPanel (UIPanel)
├── Header (HBoxContainer)
│   ├── BackButton (Button)
│   ├── TitleLabel (Label)
│   └── CountLabel (Label)
├── FilterBar (HBoxContainer)
│   ├── AllButton (Button)
│   ├── MaterialButton (Button)
│   ├── RecipeButton (Button)
│   ├── EquipmentButton (Button)
│   └── SearchLineEdit (LineEdit)
└── ScrollContainer (ScrollContainer)
    └── GridContainer (GridContainer)
        ├── MaterialCard1 (PanelContainer)
        ├── MaterialCard2 (PanelContainer)
        └── ...
```

**核心逻辑**:
```gdscript
extends UIPanel

enum FilterType { ALL, MATERIAL, RECIPE, EQUIPMENT }
var current_filter: FilterType = FilterType.ALL
var search_text: String = ""

func _on_open(data: Dictionary = {}) -> void:
    _update_grid()
    GuideSetup.switch_to_menu_context()

func _update_grid() -> void:
    # 清空现有卡片
    for child in grid_container.get_children():
        child.queue_free()

    # 获取数据
    var items = _get_filtered_items()

    # 创建卡片
    for item in items:
        var card = _create_card(item)
        grid_container.add_child(card)

func _get_filtered_items() -> Array:
    var items: Array = []

    match current_filter:
        FilterType.ALL:
            items.append_array(DataManager.get_discovered_materials())
            items.append_array(DataManager.get_discovered_recipes())
            items.append_array(DataManager.get_discovered_equipment())
        FilterType.MATERIAL:
            items = DataManager.get_discovered_materials()
        FilterType.RECIPE:
            items = DataManager.get_discovered_recipes()
        FilterType.EQUIPMENT:
            items = DataManager.get_discovered_equipment()

    # 搜索过滤
    if not search_text.is_empty():
        items = items.filter(func(item):
            return item.display_name.contains(search_text)
        )

    return items
```

#### 任务 3.2: 创建图鉴界面场景
- **文件**: `scenes/ui/codex_panel.tscn`

---

### Wave 4: 暂停菜单

#### 任务 4.1: 创建暂停菜单脚本
- **文件**: `scenes/ui/pause_menu.gd`
- **继承**: UIPanel
- **功能**:
  - 继续游戏
  - 打开设置
  - 返回主菜单
  - 退出游戏

**节点结构**:
```
PauseMenu (UIPanel)
├── Background (ColorRect)
└── VBoxContainer (VBoxContainer)
    ├── TitleLabel (Label)
    ├── ContinueButton (Button)
    ├── SettingsButton (Button)
    ├── MainMenuButton (Button)
    └── QuitButton (Button)
```

**核心逻辑**:
```gdscript
extends UIPanel

func _on_open(data: Dictionary = {}) -> void:
    GuideSetup.switch_to_menu_context()

func _on_continue_pressed() -> void:
    UIManager.back()

func _on_settings_pressed() -> void:
    var settings_id := ResourceLocation.from_string("cookery:ui/settings")
    UIManager.open_panel(settings_id)

func _on_main_menu_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")

func _on_quit_pressed() -> void:
    get_tree().quit()
```

#### 任务 4.2: 创建暂停菜单场景
- **文件**: `scenes/ui/pause_menu.tscn`

---

### Wave 5: 结果弹窗

#### 任务 5.1: 创建结果弹窗脚本
- **文件**: `scenes/ui/result_popup.gd`
- **继承**: UIPanel
- **功能**:
  - 显示结果图标
  - 显示结果名称
  - 显示标签列表
  - 显示配方信息
  - 新发现提示

**节点结构**:
```
ResultPopup (UIPanel)
├── Background (ColorRect)
└── VBoxContainer (VBoxContainer)
    ├── TitleLabel (Label)
    ├── IconTexture (TextureRect)
    ├── NameLabel (Label)
    ├── TagsLabel (Label)
    ├── RecipeLabel (Label)
    ├── DiscoveryLabel (Label)
    └── ConfirmButton (Button)
```

**核心逻辑**:
```gdscript
extends UIPanel

var cooking_result: CookingResult

func _on_open(data: Dictionary = {}) -> void:
    cooking_result = data.get("result")
    if not cooking_result:
        return

    _update_display()
    GuideSetup.switch_to_menu_context()

func _update_display() -> void:
    # 更新图标
    # icon_texture.texture = load(cooking_result.output_material.icon_path)

    # 更新名称
    name_label.text = cooking_result.output_material.display_name

    # 更新标签
    var tags_text = ", ".join(cooking_result.output_tags)
    tags_label.text = "标签: " + tags_text

    # 更新配方信息
    if cooking_result.matched_recipe:
        recipe_label.text = "配方: " + cooking_result.matched_recipe.display_name
    else:
        recipe_label.text = "配方: 无"

    # 更新发现提示
    if cooking_result.is_new_discovery:
        discovery_label.text = "新发现!"
        discovery_label.visible = true
    else:
        discovery_label.visible = false

func _on_confirm_pressed() -> void:
    UIManager.back()
```

#### 任务 5.2: 创建结果弹窗场景
- **文件**: `scenes/ui/result_popup.tscn`

---

### Wave 6: UI 主题和集成

#### 任务 6.1: 应用 UI 主题
- **文件**: `assets/theme/minimal_vector.tres`
- **操作**: 确保所有面板使用主题

#### 任务 6.2: 更新主菜单
- **文件**: `scenes/screens/main_menu.gd`
- **操作**: 添加"继续游戏"按钮功能

#### 任务 6.3: 集成测试
- **验证**: 所有面板可正常打开和关闭
- **验证**: GUIDE 上下文切换正常
- **验证**: 烹饪流程完整可操作

---

## 依赖关系

```
Wave 1 (面板注册) ──→ Wave 2 (游戏主界面) ──→ Wave 5 (结果弹窗)
      │                     │
      ├──→ Wave 3 (图鉴)    │
      │                     │
      └──→ Wave 4 (暂停)    │
                            │
                            └──→ Wave 6 (主题和集成)
```

## 验收标准

- [ ] 面板注册到 UIRegistry
- [ ] 游戏主界面布局正确
- [ ] 设备选择功能正常
- [ ] 材料选择功能正常
- [ ] 烹饪流程可操作
- [ ] 结果弹窗显示正确
- [ ] 图鉴界面可浏览
- [ ] 暂停菜单功能正常
- [ ] 所有面板继承 UIPanel
- [ ] GUIDE 上下文切换正常
- [ ] 无运行时错误

## 风险和缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| UIPanel 生命周期问题 | 中 | 参考 settings_panel.gd 模式 |
| GUIDE 上下文冲突 | 中 | 明确切换时机 |
| 布局适配问题 | 低 | 使用容器布局 |

## 下一步

完成阶段 4 后，运行 `/gsd-plan-phase 5` 开始完善和优化。