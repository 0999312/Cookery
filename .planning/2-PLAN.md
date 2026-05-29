# 2-PLAN.md - 阶段 2 执行计划

> 阶段: 数据层
> 创建时间: 2026/05/29
> 预计时间: 3-4 天
> 参考: 2-CONTEXT.md, 2-RESEARCH.md

## 目标

实现材料、属性标签、设备、配方的数据系统，建立完整的数据层基础。

## 任务分解

### Wave 1: 数据目录和基础类

#### 任务 1.1: 创建数据目录结构
- **描述**: 创建 data/ 目录及子目录
- **目录**:
```
data/
├── materials/          # 材料数据
│   └── base/          # 基础材料
├── equipment/         # 设备数据
├── recipes/           # 配方数据
└── tags/              # 标签定义
```

#### 任务 1.2: 定义变换规则类
- **目录**: `scripts/data/rules/`
- **文件**:
  - `convert_rule.gd` - 转换规则（from_tag → to_tag）
  - `combine_rule.gd` - 组合规则（tags[] → result_tag）
  - `remove_rule.gd` - 消除规则（移除 tag）
  - `amplify_rule.gd` - 增幅规则（tag → add_tag）

**ConvertRule**:
```gdscript
extends Resource
class_name ConvertRule

@export var from_tag: StringName
@export var to_tag: StringName

func apply(tags: Array[StringName]) -> Array[StringName]:
    var result := tags.duplicate()
    var idx := result.find(from_tag)
    if idx != -1:
        result[idx] = to_tag
    return result
```

**CombineRule**:
```gdscript
extends Resource
class_name CombineRule

@export var required_tags: Array[StringName]
@export var result_tag: StringName
@export var consume_inputs: bool = false

func can_apply(tags: Array[StringName]) -> bool:
    for tag in required_tags:
        if tag not in tags:
            return false
    return true

func apply(tags: Array[StringName]) -> Array[StringName]:
    var result := tags.duplicate()
    if consume_inputs:
        for tag in required_tags:
            result.erase(tag)
    result.append(result_tag)
    return result
```

**RemoveRule**:
```gdscript
extends Resource
class_name RemoveRule

@export var tag: StringName

func apply(tags: Array[StringName]) -> Array[StringName]:
    var result := tags.duplicate()
    result.erase(tag)
    return result
```

**AmplifyRule**:
```gdscript
extends Resource
class_name AmplifyRule

@export var tag: StringName
@export var add_tag: StringName

func apply(tags: Array[StringName]) -> Array[StringName]:
    var result := tags.duplicate()
    if tag in result:
        result.append(add_tag)
    return result
```

---

### Wave 2: 核心数据类

#### 任务 2.1: 定义 MaterialData
- **文件**: `scripts/data/material_data.gd`
- **继承**: `CodecResource`
- **属性**:
  - `id: String` - 唯一标识符
  - `display_name: String` - 显示名称
  - `description: String` - 描述
  - `icon_path: String` - 图标路径
  - `tags: Array[StringName]` - 属性标签列表
  - `category: String` - 分类
  - `rarity: int` - 稀有度（0=普通, 1=稀有, 2=传说）
  - `is_base: bool` - 是否是基础材料
- **Codec**: 使用 MapCodec.build 定义

```gdscript
extends CodecResource
class_name MaterialData

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""
@export var tags: Array[StringName] = []
@export var category: String = ""
@export var rarity: int = 0
@export var is_base: bool = true

static func get_type_id() -> String:
    return "cookery:material"

static func get_codec() -> Codec:
    return MapCodec.build([
        Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
        Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name),
        Codec.STRING().optional_field_of("description", "").for_getter(func(obj): return obj.description),
        Codec.STRING().optional_field_of("icon_path", "").for_getter(func(obj): return obj.icon_path),
        Codec.STRING().list_of().field_of("tags").for_getter(func(obj): return obj.tags),
        Codec.STRING().optional_field_of("category", "").for_getter(func(obj): return obj.category),
        Codec.INT().optional_field_of("rarity", 0).for_getter(func(obj): return obj.rarity),
        Codec.BOOL().optional_field_of("is_base", true).for_getter(func(obj): return obj.is_base),
    ], func(id, display_name, description, icon_path, tags, category, rarity, is_base):
        var mat = MaterialData.new()
        mat.id = id
        mat.display_name = display_name
        mat.description = description
        mat.icon_path = icon_path
        mat.tags = tags
        mat.category = category
        mat.rarity = rarity
        mat.is_base = is_base
        return mat
    ).codec()
```

#### 任务 2.2: 定义 EquipmentData
- **文件**: `scripts/data/equipment_data.gd`
- **继承**: `CodecResource`
- **属性**:
  - `id: String` - 唯一标识符
  - `display_name: String` - 显示名称
  - `description: String` - 描述
  - `icon_path: String` - 图标路径
  - `max_inputs: int` - 最大输入槽数量
  - `process_time: float` - 加工时间（秒）
  - `transform_rules: Array[Resource]` - 变换规则列表
- **Codec**: 使用 MapCodec.build 定义

#### 任务 2.3: 定义 RecipeData
- **文件**: `scripts/data/recipe_data.gd`
- **继承**: `CodecResource`
- **属性**:
  - `id: String` - 配方 ID
  - `display_name: String` - 配方名称
  - `description: String` - 配方描述
  - `required_tags: Array[StringName]` - 需要的标签组合
  - `required_equipment: String` - 需要的设备 ID
  - `result_material: String` - 结果材料 ID
  - `result_tags: Array[StringName]` - 结果标签
  - `unlock_reward: String` - 解锁奖励
  - `is_discovered: bool` - 是否已发现

#### 任务 2.4: 定义 CodexData
- **文件**: `scripts/data/codex_data.gd`
- **继承**: `Resource`
- **属性**:
  - `discovered_materials: Dictionary` - 已发现材料
  - `discovered_recipes: Dictionary` - 已发现配方
  - `discovered_equipment: Dictionary` - 已发现设备
  - `discovery_count: int` - 发现计数

---

### Wave 3: 数据管理器

#### 任务 3.1: 创建 DataManager Autoload
- **文件**: `scripts/autoloads/data_manager.gd`
- **功能**:
  - 注册所有 Registry（materials, equipment, recipes, tags）
  - 加载和注册所有数据
  - 提供数据查询 API

```gdscript
extends Node

var material_registry: RegistryBase
var equipment_registry: RegistryBase
var recipe_registry: RegistryBase
var tag_registry: TagRegistry

func _ready() -> void:
    _init_registries()
    _load_all_data()

func _init_registries() -> void:
    material_registry = RegistryBase.new()
    equipment_registry = RegistryBase.new()
    recipe_registry = RegistryBase.new()
    tag_registry = TagRegistry.new()

    RegistryManager.register_registry("materials", material_registry)
    RegistryManager.register_registry("equipment", equipment_registry)
    RegistryManager.register_registry("recipes", recipe_registry)
    RegistryManager.register_registry("tags", tag_registry)

func _load_all_data() -> void:
    _load_tags()
    _load_materials()
    _load_equipment()
    _load_recipes()

func get_material(id: String) -> MaterialData:
    return material_registry.get_entry(ResourceLocation.from_string("cookery:material/" + id))

func get_equipment(id: String) -> EquipmentData:
    return equipment_registry.get_entry(ResourceLocation.from_string("cookery:equipment/" + id))

func get_recipe(id: String) -> RecipeData:
    return recipe_registry.get_entry(ResourceLocation.from_string("cookery:recipe/" + id))
```

#### 任务 3.2: 注册 DataManager 到 project.godot
- **配置**: `DataManager="*res://scripts/autoloads/data_manager.gd"`

---

### Wave 4: 标签数据

#### 任务 4.1: 创建标签定义
- **文件**: `scripts/data/tag_definitions.gd`
- **内容**: 定义所有标签常量和注册逻辑

```gdscript
class_name TagDefinitions

# 状态标签
const RAW := &"raw"
const COOKED := &"cooked"
const FERMENTED := &"fermented"
const BURNED := &"burned"

# 元素标签
const FIRE := &"fire"
const WATER := &"water"
const EARTH := &"earth"
const AIR := &"air"

# 材质标签
const LIQUID := &"liquid"
const SOLID := &"solid"
const POWDER := &"powder"
const GAS := &"gas"

# 类别标签
const GRAIN := &"grain"
const MEAT := &"meat"
const VEGETABLE := &"vegetable"
const FRUIT := &"fruit"
const DAIRY := &"dairy"

# 效果标签
const SPICY := &"spicy"
const SWEET := &"sweet"
const SOUR := &"sour"
const SALTY := &"salty"
const BITTER := &"bitter"
const UMAMI := &"umami"

static func register_all_tags(tag_registry: TagRegistry) -> void:
    var material_type := ResourceLocation.from_string("cookery:registry/material")

    # 注册所有标签
    for tag_name in [RAW, COOKED, FERMENTED, BURNED,
                     FIRE, WATER, EARTH, AIR,
                     LIQUID, SOLID, POWDER, GAS,
                     GRAIN, MEAT, VEGETABLE, FRUIT, DAIRY,
                     SPICY, SWEET, SOUR, SALTY, BITTER, UMAMI]:
        var tag_id := ResourceLocation.from_string("cookery:tag/" + tag_name)
        tag_registry.register_tag(tag_id, material_type)
```

---

### Wave 5: 基础材料数据

#### 任务 5.1: 创建基础材料
- **目录**: `data/materials/base/`
- **文件**: 10+ 个 .tres 文件
- **材料清单**:

| ID | 名称 | 标签 | 分类 |
|----|------|------|------|
| flour | 面粉 | raw, grain, powder | grain |
| water | 水 | liquid, water | liquid |
| salt | 盐 | solid, salty | mineral |
| sugar | 糖 | solid, sweet | mineral |
| butter | 黄油 | solid, dairy, fat | dairy |
| egg | 鸡蛋 | raw, protein, liquid | protein |
| milk | 牛奶 | liquid, dairy | dairy |
| meat | 肉 | raw, meat, protein | meat |
| tomato | 番茄 | raw, vegetable, sour | vegetable |
| onion | 洋葱 | raw, vegetable, spicy | vegetable |
| pepper | 辣椒 | raw, vegetable, spicy | vegetable |
| lemon | 柠檬 | raw, fruit, sour | fruit |

#### 任务 5.2: 创建 DataManager 加载方法
- **方法**: `_load_materials()`
- **逻辑**: 从 data/materials/ 加载所有 .tres 文件

---

### Wave 6: 基础设备数据

#### 任务 6.1: 创建烤箱设备
- **文件**: `data/equipment/stove.tres`
- **属性**:
  - id: "stove"
  - display_name: "烤箱"
  - max_inputs: 1
  - process_time: 2.0
  - transform_rules: [ConvertRule(raw → cooked)]

#### 任务 6.2: 创建锅设备
- **文件**: `data/equipment/pot.tres`
- **属性**:
  - id: "pot"
  - display_name: "锅"
  - max_inputs: 3
  - process_time: 3.0
  - transform_rules: [CombineRule(water + fire → steam), ConvertRule(raw → cooked)]

#### 任务 6.3: 创建发酵器设备
- **文件**: `data/equipment/fermenter.tres`
- **属性**:
  - id: "fermenter"
  - display_name: "发酵器"
  - max_inputs: 1
  - process_time: 5.0
  - transform_rules: [RemoveRule(raw), AmplifyRule(flavor → umami)]

#### 任务 6.4: 创建 DataManager 加载方法
- **方法**: `_load_equipment()`

---

### Wave 7: 基础配方数据

#### 任务 7.1: 创建基础配方
- **目录**: `data/recipes/`
- **文件**: 5+ 个 .tres 文件
- **配方清单**:

| ID | 名称 | 需要标签 | 设备 | 结果 |
|----|------|----------|------|------|
| bread | 面包 | raw, grain, powder | stove | bread (cooked, grain) |
| boiled_water | 开水 | liquid, water | pot | boiled_water (liquid, water, hot) |
| grilled_meat | 烤肉 | raw, meat | stove | grilled_meat (cooked, meat) |
| tomato_soup | 番茄汤 | raw, vegetable, liquid | pot | tomato_soup (cooked, vegetable, liquid) |
| fermented_dough | 发酵面团 | raw, grain, powder | fermenter | fermented_dough (grain, powder, fermented) |

#### 任务 7.2: 创建 DataManager 加载方法
- **方法**: `_load_recipes()`

---

### Wave 8: 验证和测试

#### 任务 8.1: 验证数据加载
- **验证**: 所有数据类可正确加载
- **验证**: Registry 包含所有注册的数据

#### 任务 8.2: 验证 Codec 序列化
- **验证**: MaterialData 可序列化到 JSON
- **验证**: JSON 可反序列化为 MaterialData

#### 任务 8.3: 验证标签系统
- **验证**: TagRegistry 正确注册所有标签
- **验证**: 标签查询正常工作

---

## 依赖关系

```
Wave 1 (目录/基础类) ──→ Wave 2 (核心数据类) ──→ Wave 3 (DataManager)
                                                        │
                                                        ├──→ Wave 4 (标签)
                                                        ├──→ Wave 5 (材料)
                                                        ├──→ Wave 6 (设备)
                                                        └──→ Wave 7 (配方)
                                                                │
                                                                └──→ Wave 8 (验证)
```

## 验收标准

- [ ] 变换规则类定义完成（4 种类型）
- [ ] MaterialData/EquipmentData/RecipeData 定义完成
- [ ] CodexData 定义完成
- [ ] DataManager Autoload 正常工作
- [ ] 标签系统使用框架 TagRegistry
- [ ] 10+ 种基础材料数据可加载
- [ ] 3 种设备数据可加载
- [ ] 5+ 种配方数据可加载
- [ ] 所有数据注册到 Registry
- [ ] Codec 序列化/反序列化正常
- [ ] 无运行时错误

## 风险和缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Codec API 复杂 | 中 | 参考 2-RESEARCH.md 示例 |
| Resource 序列化问题 | 中 | 使用 CodecResource 基类 |
| 标签命名冲突 | 低 | 使用 ResourceLocation 格式 |

## 下一步

完成阶段 2 后，运行 `/gsd-plan-phase 3` 开始核心系统实现。