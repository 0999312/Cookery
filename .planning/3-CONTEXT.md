# 3-CONTEXT.md - 阶段 3 决策文档

> 阶段: 核心系统
> 决策时间: 2026/05/29

## 决策摘要

| 决策 | 选择 | 原因 |
|------|------|------|
| 烹饪系统设计 | 独立类 | 解耦，便于测试和复用 |
| 处理流程 | 手动触发 | 玩家主动控制，增加策略性 |
| 动态结果命名 | 标签组合命名 | 直观，易于理解 |
| 事件系统 | 使用框架 EventBus | 遵循项目约束 |

---

## 1. 烹饪系统设计

**决策**: CookingSystem 作为独立类

**设计**:
- `scripts/systems/cooking_system.gd` - 烹饪系统类
- 被场景脚本调用，不依赖特定节点
- 使用 DataManager 查询数据
- 使用 EventBus 发布事件

**API**:

```gdscript
class_name CookingSystem

## 开始烹饪
func start_cooking(equipment_id: String, material_ids: Array[String]) -> CookingResult

## 应用变换规则
func apply_transforms(equipment: EquipmentData, materials: Array[MaterialData]) -> Array[StringName]

## 匹配配方
func match_recipe(tags: Array[StringName], equipment_id: String) -> RecipeData

## 生成动态结果
func generate_dynamic_result(tags: Array[StringName], equipment: EquipmentData) -> MaterialData

## 处理完成
func complete_cooking(result: CookingResult) -> void
```

**CookingResult 数据类**:

```gdscript
class_name CookingResult

var success: bool
var equipment: EquipmentData
var input_materials: Array[MaterialData]
var output_material: MaterialData
var output_tags: Array[StringName]
var matched_recipe: RecipeData  # null if dynamic
var is_new_discovery: bool
var processing_time: float
```

---

## 2. 处理流程

**决策**: 手动触发流程

**流程步骤**:

```
1. 玩家选择设备
   └── 显示设备界面，包含输入槽

2. 玩家放入材料
   └── 从材料列表拖拽到输入槽
   └── 验证材料数量不超过设备限制

3. 玩家点击"开始"按钮
   └── 验证所有槽位已填充
   └── 开始处理计时

4. 等待处理时间
   └── 显示进度条
   └── 设备动画（可选）

5. 处理完成
   └── 应用变换规则
   └── 匹配配方或生成动态结果
   └── 显示结果界面

6. 玩家获取结果
   └── 结果添加到材料库
   └── 更新图鉴
   └── 发布事件
```

---

## 3. 动态结果命名

**决策**: 标签组合命名

**命名规则**:

```gdscript
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
```

**示例**:

| 标签组合 | 生成名称 |
|----------|----------|
| [cooked, grain, powder] | 熟谷物粉 |
| [fermented, dairy] | 发酵乳制品 |
| [cooked, meat, spicy] | 熟辣肉 |
| [liquid, vegetable, sour] | 蔬菜酸汁 |
| [unknown] | 神秘料理 |

---

## 4. 游戏事件定义

**决策**: 使用框架 EventBus 发布事件

**新增事件**:

```gdscript
# 烹饪开始事件
class_name CookingStartedEvent extends Event
var equipment_id: String
var material_ids: Array[String]

# 烹饪完成事件
class_name CookingCompletedEvent extends Event
var result: CookingResult

# 配方发现事件
class_name RecipeDiscoveredEvent extends Event
var recipe: RecipeData

# 材料解锁事件
class_name MaterialUnlockedEvent extends Event
var material: MaterialData
```

**事件发布时机**:

| 事件 | 触发时机 |
|------|----------|
| CookingStartedEvent | 玩家点击"开始"按钮 |
| CookingCompletedEvent | 处理完成，结果生成 |
| RecipeDiscoveredEvent | 首次匹配到配方 |
| MaterialUnlockedEvent | 新材料加入图鉴 |

---

## 5. 分类系统

**决策**: 基于标签的分类查询

**实现方式**:
- 使用 DataManager 的查询 API
- 通过标签过滤材料和配方
- 不需要额外的分类数据结构

**API**:

```gdscript
# DataManager 中添加
func get_materials_by_category(category: String) -> Array[MaterialData]:
    var result: Array[MaterialData] = []
    for material in get_all_materials():
        if material.category == category:
            result.append(material)
    return result

func get_recipes_by_equipment(equipment_id: String) -> Array[RecipeData]:
    var result: Array[RecipeData] = []
    for recipe in get_all_recipes():
        if recipe.required_equipment == equipment_id:
            result.append(recipe)
    return result
```

---

## 6. 配方匹配逻辑

**决策**: 严格标签匹配

**匹配规则**:
1. 检查设备是否匹配（required_equipment）
2. 检查所有必需标签是否存在于输入标签中
3. 忽略多余的标签（允许超集匹配）

**匹配示例**:

```
输入标签: [raw, grain, powder, water]
设备: stove
配方: bread (required_tags: [raw, grain, powder], equipment: stove)

匹配结果: ✅ 成功（所有必需标签都存在）
```

```
输入标签: [raw, meat]
设备: pot
配方: grilled_meat (required_tags: [raw, meat], equipment: stove)

匹配结果: ❌ 失败（设备不匹配）
```

---

## 7. 图鉴更新逻辑

**决策**: 自动更新

**更新规则**:
1. 烹饪完成时，检查结果材料是否已发现
2. 如果是新发现，添加到图鉴
3. 如果匹配到配方且是首次发现，添加配方到图鉴
4. 发布相应事件

```gdscript
func _update_codex(result: CookingResult) -> void:
    # 检查材料发现
    if not DataManager.codex.has_material(result.output_material.id):
        DataManager.codex.discover_material(result.output_material)
        EventBus.publish(MaterialUnlockedEvent.new(result.output_material))

    # 检查配方发现
    if result.matched_recipe and not DataManager.codex.has_recipe(result.matched_recipe.id):
        DataManager.codex.discover_recipe(result.matched_recipe)
        EventBus.publish(RecipeDiscoveredEvent.new(result.matched_recipe))
```

---

## 验收标准

- [ ] CookingSystem 类定义完成
- [ ] CookingResult 数据类定义完成
- [ ] 手动触发流程实现
- [ ] 变换规则正确应用
- [ ] 配方匹配逻辑正确
- [ ] 动态结果命名正确
- [ ] 图鉴自动更新
- [ ] 事件正确发布
- [ ] 分类查询 API 可用

---

## 下一步

运行 `/gsd-plan-phase 3` 进行详细任务规划。