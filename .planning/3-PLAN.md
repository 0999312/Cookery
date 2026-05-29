# 3-PLAN.md - 阶段 3 执行计划

> 阶段: 核心系统
> 创建时间: 2026/05/29
> 预计时间: 4-5 天
> 参考: 3-CONTEXT.md

## 目标

实现烹饪流程和设备交互，建立完整的核心游戏循环。

## 任务分解

### Wave 1: 数据类和事件定义

#### 任务 1.1: 定义 CookingResult 数据类
- **文件**: `scripts/data/cooking_result.gd`
- **属性**:
  - `success: bool` - 是否成功
  - `equipment: EquipmentData` - 使用的设备
  - `input_materials: Array[MaterialData]` - 输入材料
  - `output_material: MaterialData` - 输出材料
  - `output_tags: Array[StringName]` - 输出标签
  - `matched_recipe: RecipeData` - 匹配的配方（可为 null）
  - `is_new_discovery: bool` - 是否是新发现
  - `processing_time: float` - 处理时间

```gdscript
class_name CookingResult

var success: bool = false
var equipment: EquipmentData
var input_materials: Array[MaterialData] = []
var output_material: MaterialData
var output_tags: Array[StringName] = []
var matched_recipe: RecipeData
var is_new_discovery: bool = false
var processing_time: float = 0.0
```

#### 任务 1.2: 定义烹饪事件类
- **目录**: `events/`
- **文件**:
  - `cooking_started_event.gd` - 烹饪开始事件
  - `cooking_completed_event.gd` - 烹饪完成事件
  - `recipe_discovered_event.gd` - 配方发现事件
  - `material_unlocked_event.gd` - 材料解锁事件

**CookingStartedEvent**:
```gdscript
extends Event
class_name CookingStartedEvent

var equipment_id: String
var material_ids: Array[String]

func _init(p_equipment_id: String = "", p_material_ids: Array[String] = []) -> void:
    equipment_id = p_equipment_id
    material_ids = p_material_ids
```

**CookingCompletedEvent**:
```gdscript
extends Event
class_name CookingCompletedEvent

var result: CookingResult

func _init(p_result: CookingResult = null) -> void:
    result = p_result
```

**RecipeDiscoveredEvent**:
```gdscript
extends Event
class_name RecipeDiscoveredEvent

var recipe: RecipeData

func _init(p_recipe: RecipeData = null) -> void:
    recipe = p_recipe
```

**MaterialUnlockedEvent**:
```gdscript
extends Event
class_name MaterialUnlockedEvent

var material: MaterialData

func _init(p_material: MaterialData = null) -> void:
    material = p_material
```

---

### Wave 2: 烹饪系统核心

#### 任务 2.1: 创建 CookingSystem 类
- **文件**: `scripts/systems/cooking_system.gd`
- **功能**:
  - 开始烹饪
  - 应用变换规则
  - 匹配配方
  - 生成动态结果
  - 完成烹饪

```gdscript
class_name CookingSystem

## 开始烹饪
func start_cooking(equipment_id: String, material_ids: Array[String]) -> CookingResult:
    # 1. 获取设备数据
    var equipment = DataManager.get_equipment(equipment_id)
    if not equipment:
        return _create_failed_result("设备不存在")

    # 2. 获取材料数据
    var materials: Array[MaterialData] = []
    for id in material_ids:
        var material = DataManager.get_material(id)
        if not material:
            return _create_failed_result("材料不存在: " + id)
        materials.append(material)

    # 3. 验证材料数量
    if materials.size() > equipment.max_inputs:
        return _create_failed_result("材料数量超过设备限制")

    # 4. 应用变换规则
    var input_tags = _collect_tags(materials)
    var output_tags = equipment.apply_transforms(input_tags)

    # 5. 匹配配方
    var recipe = DataManager.find_matching_recipe(output_tags, equipment_id)

    # 6. 生成结果
    var output_material: MaterialData
    var is_new_discovery = false

    if recipe:
        # 使用配方结果
        output_material = DataManager.get_material(recipe.result_material)
        if not output_material:
            output_material = _create_material_from_recipe(recipe, output_tags)
    else:
        # 生成动态结果
        output_material = _generate_dynamic_result(output_tags, equipment)
        is_new_discovery = true

    # 7. 创建结果
    var result = CookingResult.new()
    result.success = true
    result.equipment = equipment
    result.input_materials = materials
    result.output_material = output_material
    result.output_tags = output_tags
    result.matched_recipe = recipe
    result.is_new_discovery = is_new_discovery
    result.processing_time = equipment.process_time

    return result


## 完成烹饪
func complete_cooking(result: CookingResult) -> void:
    if not result.success:
        return

    # 发布烹饪完成事件
    EventBus.publish(CookingCompletedEvent.new(result))

    # 更新图鉴
    _update_codex(result)


## 收集材料标签
func _collect_tags(materials: Array[MaterialData]) -> Array[StringName]:
    var tags: Array[StringName] = []
    for material in materials:
        for tag in material.tags:
            if tag not in tags:
                tags.append(tag)
    return tags


## 生成动态结果
func _generate_dynamic_result(tags: Array[StringName], equipment: EquipmentData) -> MaterialData:
    var material = MaterialData.new()
    material.id = "dynamic_%d" % Time.get_ticks_msec()
    material.display_name = _generate_name_from_tags(tags)
    material.description = "通过%s加工的神秘料理" % equipment.display_name
    material.tags = tags
    material.category = "processed"
    material.rarity = 0
    material.is_base = false

    # 注册到 DataManager
    DataManager._register_material(material)

    return material


## 从配方创建材料
func _create_material_from_recipe(recipe: RecipeData, tags: Array[StringName]) -> MaterialData:
    var material = MaterialData.new()
    material.id = recipe.result_material
    material.display_name = recipe.display_name
    material.description = recipe.description
    material.tags = tags
    material.category = "processed"
    material.rarity = 1
    material.is_base = false

    # 注册到 DataManager
    DataManager._register_material(material)

    return material


## 生成名称
func _generate_name_from_tags(tags: Array[StringName]) -> String:
    var parts: Array[String] = []

    # 状态标签（优先）
    if &"cooked" in tags:
        parts.append("熟")
    elif &"fermented" in tags:
        parts.append("发酵")
    elif &"burned" in tags:
        parts.append("焦")

    # 类别标签
    if &"grain" in tags:
        parts.append("谷物")
    elif &"meat" in tags:
        parts.append("肉")
    elif &"vegetable" in tags:
        parts.append("蔬菜")
    elif &"fruit" in tags:
        parts.append("水果")
    elif &"dairy" in tags:
        parts.append("乳制品")

    # 材质标签
    if &"powder" in tags:
        parts.append("粉")
    elif &"liquid" in tags:
        parts.append("汁")
    elif &"solid" in tags:
        parts.append("块")

    # 效果标签（可选）
    if &"spicy" in tags:
        parts.append("辣")
    elif &"sweet" in tags:
        parts.append("甜")
    elif &"sour" in tags:
        parts.append("酸")

    # 如果没有匹配的标签，使用通用名称
    if parts.is_empty():
        return "神秘料理"

    return "".join(parts)


## 更新图鉴
func _update_codex(result: CookingResult) -> void:
    # 检查材料发现
    if not DataManager.codex.has_material(result.output_material.id):
        DataManager.codex.discover_material(result.output_material)
        EventBus.publish(MaterialUnlockedEvent.new(result.output_material))

    # 检查配方发现
    if result.matched_recipe and not DataManager.codex.has_recipe(result.matched_recipe.id):
        DataManager.codex.discover_recipe(result.matched_recipe)
        EventBus.publish(RecipeDiscoveredEvent.new(result.matched_recipe))


## 创建失败结果
func _create_failed_result(error_message: String) -> CookingResult:
    push_error("[CookingSystem] ", error_message)
    var result = CookingResult.new()
    result.success = false
    return result
```

---

### Wave 3: DataManager 扩展

#### 任务 3.1: 添加分类查询 API
- **文件**: `scripts/autoloads/data_manager.gd`
- **新增方法**:

```gdscript
## 按分类获取材料
func get_materials_by_category(category: String) -> Array[MaterialData]:
    var result: Array[MaterialData] = []
    for material in get_all_materials():
        if material.category == category:
            result.append(material)
    return result


## 按设备获取配方
func get_recipes_by_equipment(equipment_id: String) -> Array[RecipeData]:
    var result: Array[RecipeData] = []
    for recipe in get_all_recipes():
        if recipe.required_equipment == equipment_id:
            result.append(recipe)
    return result


## 获取已发现的材料
func get_discovered_materials() -> Array[MaterialData]:
    var result: Array[MaterialData] = []
    for material in codex.discovered_materials.values():
        if material is MaterialData:
            result.append(material)
    return result


## 获取已发现的配方
func get_discovered_recipes() -> Array[RecipeData]:
    var result: Array[RecipeData] = []
    for recipe in codex.discovered_recipes.values():
        if recipe is RecipeData:
            result.append(recipe)
    return result
```

---

### Wave 4: 验证和测试

#### 任务 4.1: 验证烹饪流程
- **测试场景**:
  1. 面粉 + 烤箱 → 面包（配方匹配）
  2. 肉 + 锅 → 熟肉（变换规则）
  3. 未知组合 → 动态结果（标签命名）

#### 任务 4.2: 验证图鉴更新
- **测试场景**:
  1. 首次烹饪新配方 → 配方发现事件
  2. 首次获得新材料 → 材料解锁事件
  3. 重复烹饪 → 不触发事件

#### 任务 4.3: 验证事件系统
- **测试场景**:
  1. 烹饪开始 → CookingStartedEvent
  2. 烹饪完成 → CookingCompletedEvent
  3. 配方发现 → RecipeDiscoveredEvent
  4. 材料解锁 → MaterialUnlockedEvent

---

## 依赖关系

```
Wave 1 (数据类/事件) ──→ Wave 2 (烹饪系统) ──→ Wave 3 (DataManager扩展) ──→ Wave 4 (验证)
```

## 验收标准

- [ ] CookingResult 数据类定义完成
- [ ] 4 个事件类定义完成
- [ ] CookingSystem 类实现完成
- [ ] 变换规则正确应用
- [ ] 配方匹配逻辑正确
- [ ] 动态结果命名正确
- [ ] 图鉴自动更新
- [ ] 事件正确发布
- [ ] 分类查询 API 可用
- [ ] 无运行时错误

## 风险和缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 变换规则顺序问题 | 中 | 按设备定义的顺序应用 |
| 动态结果 ID 冲突 | 低 | 使用时间戳生成唯一 ID |
| 配方匹配歧义 | 低 | 使用严格匹配（所有必需标签） |

## 下一步

完成阶段 3 后，运行 `/gsd-plan-phase 4` 开始 UI 界面实现。