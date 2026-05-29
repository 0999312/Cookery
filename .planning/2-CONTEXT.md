# 2-CONTEXT.md - 阶段 2 决策文档

> 阶段: 数据层
> 决策时间: 2026/05/29

## 决策摘要

| 决策 | 选择 | 原因 |
|------|------|------|
| 标签系统 | 使用框架 Tag 机制 | 复用现有基础设施 |
| 变换规则 | 设备内置规则 | 简化数据结构，设备决定变换逻辑 |
| 结果系统 | 配方 + 图鉴 + 动态涌现 | 平衡确定性和探索性 |
| 数据格式 | 使用 Codec 系统 | 支持 JSON 序列化，未来可扩展 |
| 数据目录 | `data/` | 遵循项目约定 |
| 命名空间 | `cookery` | 统一标识符前缀 |

---

## 1. 标签系统

**决策**: 使用 mc_game_framework 的 Tag 机制

**实现方式**:
- 使用 `TagRegistry` 注册标签
- 使用 `Tag` 对象管理标签条目
- 材料通过 `ResourceLocation` 引用标签

**标签分类**:

| 类别 | 示例 | 用途 |
|------|------|------|
| 状态标签 | `raw`, `cooked`, `fermented` | 材料加工状态 |
| 元素标签 | `fire`, `water`, `earth` | 元素属性 |
| 材质标签 | `liquid`, `solid`, `powder` | 物理形态 |
| 类别标签 | `grain`, `meat`, `vegetable` | 材料分类 |
| 效果标签 | `spicy`, `sweet`, `sour` | 口味效果 |

**标签注册**:

```gdscript
# 在游戏初始化时
var tag_registry = TagRegistry.new()
RegistryManager.register_registry("tags", tag_registry)

# 注册标签
tag_registry.register_tag(
    ResourceLocation.from_string("cookery:tag/raw"),
    ResourceLocation.from_string("cookery:registry/material")
)
```

---

## 2. 标签变换规则

**决策**: 设备内置规则

**规则类型**:

### 2.1 转换规则（Convert）

```gdscript
class_name ConvertRule extends Resource

@export var from_tag: StringName  # 原始标签
@export var to_tag: StringName    # 目标标签

# 示例：raw → cooked
```

### 2.2 组合规则（Combine）

```gdscript
class_name CombineRule extends Resource

@export var required_tags: Array[StringName]  # 需要的标签
@export var result_tag: StringName            # 结果标签
@export var consume_inputs: bool = false      # 是否消耗输入

# 示例：water + fire → steam
```

### 2.3 消除规则（Remove）

```gdscript
class_name RemoveRule extends Resource

@export var tag: StringName  # 要移除的标签

# 示例：移除 raw
```

### 2.4 增幅规则（Amplify）

```gdscript
class_name AmplifyRule extends Resource

@export var tag: StringName      # 要增幅的标签
@export var add_tag: StringName  # 增幅后添加的标签

# 示例：heat → heat + crispy
```

**变换流程**:

```
1. 设备读取输入材料的标签列表
2. 按顺序应用变换规则
3. 生成新的标签组合
4. 查询配方表（如果匹配，返回配方结果）
5. 如果无配方匹配，生成动态结果
```

---

## 3. 材料数据结构

**决策**: MaterialData 作为 Resource 子类

```gdscript
class_name MaterialData extends Resource

@export var id: String                    # 唯一标识符
@export var display_name: String          # 显示名称
@export var description: String           # 描述
@export var icon_path: String             # 图标路径
@export var tags: Array[StringName]       # 属性标签列表
@export var category: String              # 分类（grain, meat, vegetable...）
@export var rarity: int = 0               # 稀有度（0=普通, 1=稀有, 2=传说）
@export var is_base: bool = true          # 是否是基础材料
@export var unlock_condition: String = "" # 解锁条件
```

**示例数据**:

```gdscript
# 面粉
var flour = MaterialData.new()
flour.id = "flour"
flour.display_name = "面粉"
flour.description = "基础谷物粉末"
flour.tags = [&"raw", &"grain", &"powder"]
flour.category = "grain"
flour.is_base = true
```

---

## 4. 设备数据结构

**决策**: EquipmentData 作为 Resource 子类

```gdscript
class_name EquipmentData extends Resource

@export var id: String                    # 唯一标识符
@export var display_name: String          # 显示名称
@export var description: String           # 描述
@export var icon_path: String             # 图标路径
@export var max_inputs: int = 1           # 最大输入槽数量
@export var process_time: float = 1.0     # 加工时间（秒）
@export var transform_rules: Array[Resource]  # 变换规则列表
@export var unlock_condition: String = "" # 解锁条件
```

**三种设备**:

| 设备 | 最大输入 | 主要变换 | 特点 |
|------|----------|----------|------|
| 烤箱 | 1 | raw → cooked | 单输入，加热烹饪 |
| 锅 | 3 | 组合 + 转换 | 多输入，混合烹饪 |
| 发酵器 | 1 | 移除 + 增幅 | 单输入，长时间发酵 |

---

## 5. 配方系统

**决策**: 配方 + 图鉴 + 动态涌现混合

### 5.1 配方表（RecipeData）

```gdscript
class_name RecipeData extends Resource

@export var id: String                    # 配方 ID
@export var display_name: String          # 配方名称
@export var description: String           # 配方描述
@export var required_tags: Array[StringName]  # 需要的标签组合
@export var required_equipment: String    # 需要的设备 ID
@export var result_material: String       # 结果材料 ID
@export var result_tags: Array[StringName]  # 结果标签
@export var unlock_reward: String = ""    # 解锁奖励
@export var is_discovered: bool = false   # 是否已发现
```

### 5.2 动态结果系统

当标签组合不匹配任何配方时，系统动态生成结果：

```gdscript
func generate_dynamic_result(tags: Array[StringName], equipment: EquipmentData) -> MaterialData:
    # 1. 生成结果名称（基于标签组合）
    var name = _generate_name_from_tags(tags)

    # 2. 创建动态材料
    var result = MaterialData.new()
    result.id = "dynamic_%d" % _next_id
    result.display_name = name
    result.tags = tags
    result.is_base = false

    # 3. 检查是否触发特殊效果
    _check_special_effects(tags, equipment)

    return result
```

### 5.3 动态结果效果

动态结果可以触发特殊效果：

| 效果 | 触发条件 | 结果 |
|------|----------|------|
| 解锁材料 | 特定标签组合 | 新材料加入图鉴 |
| 解锁配方 | 首次发现标签组合 | 新配方加入图鉴 |
| 解锁设备 | 完成特定配方 | 新设备可用 |
| 获得成就 | 特殊条件达成 | 成就解锁 |

---

## 6. 图鉴系统（CodexData）

```gdscript
class_name CodexData extends Resource

@export var discovered_materials: Dictionary = {}  # id → MaterialData
@export var discovered_recipes: Dictionary = {}    # id → RecipeData
@export var discovered_equipment: Dictionary = {}  # id → EquipmentData
@export var discovery_count: int = 0
@export var total_discoveries: int = 0
```

---

## 7. 数据目录结构

```
data/
├── materials/          # 材料数据
│   ├── base/          # 基础材料
│   └── processed/     # 加工材料
├── equipment/         # 设备数据
├── recipes/           # 配方数据
├── tags/              # 标签定义
└── codex/             # 图鉴数据
```

---

## 8. Codec 集成

**决策**: 使用框架 Codec 系统

**实现方式**:

```gdscript
# 为 MaterialData 定义 Codec
static func codec() -> Codec:
    return Codec.record(
        Codec.STRING().field_of("id")
            .and(Codec.STRING().field_of("display_name"))
            .and(Codec.STRING().field_of("description"))
            .and(Codec.STRING().list_of().field_of("tags"))
            .and(Codec.STRING().field_of("category"))
            .and(Codec.INT().optional_field_of("rarity", 0))
            .and(Codec.BOOL().optional_field_of("is_base", true))
    ).xmap(
        func(data): return _from_dict(data),
        func(mat): return _to_dict(mat)
    )
```

---

## 9. 命名空间策略

**决策**: 使用 `cookery` 作为命名空间

**格式**: `cookery:<type>/<id>`

**示例**:
- `cookery:material/flour` - 面粉
- `cookery:equipment/stove` - 烤箱
- `cookery:recipe/bread` - 面包配方
- `cookery:tag/raw` - 生标签

---

## 10. 注册策略

**决策**: 游戏启动时注册所有数据

```gdscript
# scripts/autoloads/data_manager.gd
extends Node

func _ready() -> void:
    _register_tags()
    _register_materials()
    _register_equipment()
    _register_recipes()


func _register_tags() -> void:
    var tag_registry = TagRegistry.new()
    RegistryManager.register_registry("tags", tag_registry)
    # 注册所有标签...


func _register_materials() -> void:
    var material_registry = RegistryBase.new()
    RegistryManager.register_registry("materials", material_registry)
    # 注册所有材料...


func _register_equipment() -> void:
    var equipment_registry = RegistryBase.new()
    RegistryManager.register_registry("equipment", equipment_registry)
    # 注册所有设备...


func _register_recipes() -> void:
    var recipe_registry = RegistryBase.new()
    RegistryManager.register_registry("recipes", recipe_registry)
    # 注册所有配方...
```

---

## 验收标准

- [ ] MaterialData Resource 定义完成
- [ ] EquipmentData Resource 定义完成
- [ ] 变换规则类定义完成（Convert/Combine/Remove/Amplify）
- [ ] 配方系统定义完成
- [ ] 图鉴系统定义完成
- [ ] 10+ 种基础材料数据创建
- [ ] 3 种设备数据创建
- [ ] 所有数据注册到 Registry
- [ ] Codec 定义完成

---

## 下一步

运行 `/gsd-plan-phase 2` 进行详细任务规划。