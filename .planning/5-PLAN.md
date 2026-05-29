# 5-PLAN.md - 阶段 5 执行计划

> 阶段: 完善和优化
> 创建时间: 2026/05/29
> 预计时间: 5-7 天
> 参考: 5-CONTEXT.md, 2-RESEARCH.md

## 目标

完善存档系统、集成音频、编写测试、扩展数据，完成游戏原型。

## 任务分解

### Wave 1: SaveData 和存档重构

#### 任务 1.1: 定义 SaveData
- **文件**: `scripts/data/save_data.gd`
- **继承**: CodecResource
- **属性**:
  - `version: String` - 存档版本
  - `timestamp: float` - 存档时间戳
  - `play_time: float` - 游戏时间
  - `discovered_materials: Array[String]` - 已发现材料
  - `discovered_recipes: Array[String]` - 已发现配方
  - `discovered_equipment: Array[String]` - 已发现设备
  - `settings: Dictionary` - 设置

```gdscript
extends CodecResource
class_name SaveData

@export var version: String = "1.0.0"
@export var timestamp: float = 0.0
@export var play_time: float = 0.0
@export var discovered_materials: Array[String] = []
@export var discovered_recipes: Array[String] = []
@export var discovered_equipment: Array[String] = []
@export var settings: Dictionary = {}

static func get_type_id() -> String:
    return "cookery:save"

static func get_codec() -> Codec:
    return MapCodec.build([
        Codec.STRING().field_of("version").for_getter(func(obj): return obj.version),
        Codec.FLOAT().field_of("timestamp").for_getter(func(obj): return obj.timestamp),
        Codec.FLOAT().field_of("play_time").for_getter(func(obj): return obj.play_time),
        Codec.STRING().list_of().field_of("discovered_materials").for_getter(func(obj): return obj.discovered_materials),
        Codec.STRING().list_of().field_of("discovered_recipes").for_getter(func(obj): return obj.discovered_recipes),
        Codec.STRING().list_of().field_of("discovered_equipment").for_getter(func(obj): return obj.discovered_equipment),
    ], func(version, timestamp, play_time, discovered_materials, discovered_recipes, discovered_equipment):
        var save = SaveData.new()
        save.version = version
        save.timestamp = timestamp
        save.play_time = play_time
        save.discovered_materials = discovered_materials
        save.discovered_recipes = discovered_recipes
        save.discovered_equipment = discovered_equipment
        return save
    ).codec()
```

#### 任务 1.2: 重构 SaveManager
- **文件**: `scripts/autoloads/save_manager.gd`
- **功能**:
  - 使用 SaveData 替代 Dictionary
  - 使用 Codec 序列化
  - 添加自动保存功能
  - 连接 EventBus 事件

```gdscript
extends Node

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3

var current_save: SaveData
var auto_save_enabled: bool = true

func _ready() -> void:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    _connect_events()

func _connect_events() -> void:
    EventBus.subscribe(&"CookingCompletedEvent", _on_cooking_completed)
    EventBus.subscribe(&"RecipeDiscoveredEvent", _on_recipe_discovered)

func save_game(slot: int) -> bool:
    var path = _get_save_path(slot)
    var result = current_save.save_to_file(path)
    if result.is_success():
        EventBus.publish(SaveCompletedEvent.new(slot, true))
        return true
    else:
        EventBus.publish(SaveCompletedEvent.new(slot, false))
        return false

func load_game(slot: int) -> bool:
    var path = _get_save_path(slot)
    var result = SaveData.load_from_file(path)
    if result.is_success():
        current_save = result.get_value()
        EventBus.publish(LoadCompletedEvent.new(slot, true))
        return true
    else:
        EventBus.publish(LoadCompletedEvent.new(slot, false))
        return false

func auto_save() -> void:
    if auto_save_enabled:
        save_game(0)

func _on_cooking_completed(event: CookingCompletedEvent) -> void:
    auto_save()

func _on_recipe_discovered(event: RecipeDiscoveredEvent) -> void:
    auto_save()

func _get_save_path(slot: int) -> String:
    return "%s/save_%d.json" % [SAVE_DIR, slot]
```

---

### Wave 2: UI 音效集成

#### 任务 2.1: 创建音效管理脚本
- **文件**: `scripts/autoloads/sfx_manager.gd`
- **功能**: 管理 UI 音效播放

```gdscript
extends Node

const SFX_CLICK := "res://assets/audio/sfx/ui_click.ogg"
const SFX_COOKING_START := "res://assets/audio/sfx/cooking_start.ogg"
const SFX_COOKING_COMPLETE := "res://assets/audio/sfx/cooking_complete.ogg"
const SFX_DISCOVERY := "res://assets/audio/sfx/discovery.ogg"
const SFX_ERROR := "res://assets/audio/sfx/error.ogg"

func _ready() -> void:
    _connect_events()

func _connect_events() -> void:
    EventBus.subscribe(&"CookingStartedEvent", _on_cooking_started)
    EventBus.subscribe(&"CookingCompletedEvent", _on_cooking_completed)
    EventBus.subscribe(&"RecipeDiscoveredEvent", _on_recipe_discovered)

func play_click() -> void:
    SoundManager.play_sfx(SFX_CLICK)

func play_cooking_start() -> void:
    SoundManager.play_sfx(SFX_COOKING_START)

func play_cooking_complete() -> void:
    SoundManager.play_sfx(SFX_COOKING_COMPLETE)

func play_discovery() -> void:
    SoundManager.play_sfx(SFX_DISCOVERY)

func play_error() -> void:
    SoundManager.play_sfx(SFX_ERROR)

func _on_cooking_started(event: CookingStartedEvent) -> void:
    play_cooking_start()

func _on_cooking_completed(event: CookingCompletedEvent) -> void:
    play_cooking_complete()

func _on_recipe_discovered(event: RecipeDiscoveredEvent) -> void:
    play_discovery()
```

#### 任务 2.2: 添加 SFXManager 到 project.godot
- **配置**: `SFXManager="*res://scripts/autoloads/sfx_manager.gd"`

#### 任务 2.3: 创建占位音效文件
- **目录**: `assets/audio/sfx/`
- **文件**: 创建空的 .ogg 文件作为占位符

---

### Wave 3: 单元测试

#### 任务 3.1: 创建测试目录
- **目录**: `tests/unit/`

#### 任务 3.2: 编写 CookingSystem 测试
- **文件**: `tests/unit/test_cooking_system.gd`
- **测试用例**:
  - 测试变换规则应用
  - 测试配方匹配
  - 测试动态结果生成
  - 测试图鉴更新

```gdscript
extends GutTest

func test_convert_rule():
    var rule = ConvertRule.new()
    rule.from_tag = &"raw"
    rule.to_tag = &"cooked"

    var tags: Array[StringName] = [&"raw", &"grain"]
    var result = rule.apply(tags)

    assert_true(&"cooked" in result)
    assert_false(&"raw" in result)

func test_combine_rule():
    var rule = CombineRule.new()
    rule.required_tags = [&"water", &"fire"]
    rule.result_tag = &"steam"
    rule.consume_inputs = true

    var tags: Array[StringName] = [&"water", &"fire", &"other"]
    var result = rule.apply(tags)

    assert_true(&"steam" in result)
    assert_false(&"water" in result)
    assert_false(&"fire" in result)
    assert_true(&"other" in result)

func test_cooking_system():
    var result = CookingSystem.start_cooking("stove", ["flour"])
    assert_true(result.success)
    assert_not_null(result.output_material)
```

#### 任务 3.3: 编写 DataManager 测试
- **文件**: `tests/unit/test_data_manager.gd`
- **测试用例**:
  - 测试数据加载
  - 测试材料查询
  - 测试配方匹配

#### 任务 3.4: 编写 SaveManager 测试
- **文件**: `tests/unit/test_save_manager.gd`
- **测试用例**:
  - 测试保存
  - 测试加载
  - 测试自动保存

---

### Wave 4: 数据扩展

#### 任务 4.1: 扩展材料数据
- **文件**: `scripts/autoloads/data_manager.gd`
- **新增材料**: 50+ 种（扩展到 60+ 总数）

**谷物类** (8):
- rice (大米), oat (燕麦), corn (玉米), barley (大麦)
- wheat (小麦), millet (小米), sorghum (高粱), buckwheat (荞麦)

**肉类** (8):
- pork (猪肉), beef (牛肉), chicken (鸡肉), fish (鱼)
- shrimp (虾), lamb (羊肉), duck (鸭肉), turkey (火鸡)

**蔬菜类** (12):
- carrot (胡萝卜), potato (土豆), cabbage (白菜), spinach (菠菜)
- broccoli (西兰花), mushroom (蘑菇), garlic (大蒜), ginger (姜)
- celery (芹菜), lettuce (生菜), cucumber (黄瓜), eggplant (茄子)

**水果类** (8):
- apple (苹果), banana (香蕉), strawberry (草莓), orange (橙子)
- grape (葡萄), peach (桃子), mango (芒果), pineapple (菠萝)

**乳制品类** (6):
- cheese (奶酪), yogurt (酸奶), cream (奶油), ice cream (冰淇淋)
- butter (黄油 - 已有), milk (牛奶 - 已有)

**调味品类** (10):
- soy sauce (酱油), vinegar (醋), pepper (胡椒), chili (辣椒粉)
- cinnamon (肉桂), ginger (姜粉), garlic powder (蒜粉)
- oregano (牛至), basil (罗勒), thyme (百里香)

**其他** (8):
- oil (油), honey (蜂蜜), chocolate (巧克力), flour (面粉 - 已有)
- water (水 - 已有), egg (鸡蛋 - 已有), salt (盐 - 已有), sugar (糖 - 已有)

#### 任务 4.2: 扩展配方数据
- **新增配方**: 15+ 种（扩展到 20+ 总数）

| 配方 | 标签 | 设备 | 结果 |
|------|------|------|------|
| fried_rice | cooked, rice, egg | pot | 炒饭 |
| grilled_fish | raw, fish | stove | 烤鱼 |
| tomato_soup | raw, vegetable, liquid | pot | 番茄汤 |
| cheese | dairy, fermented | fermenter | 奶酪 |
| bread | raw, grain, powder | stove | 面包 |
| pasta | raw, grain, water | pot | 意面 |
| sushi | raw, fish, rice | - | 寿司 |
| salad | raw, vegetable, fruit | - | 沙拉 |
| steak | raw, meat | stove | 牛排 |
| soup | raw, meat, liquid | pot | 肉汤 |
| yogurt | dairy, fermented | fermenter | 酸奶 |
| grilled_chicken | raw, chicken | stove | 烤鸡 |
| chocolate | cocoa, sweet | - | 工克力 |
| honey_cake | grain, sweet, honey | stove | 蜂蜜蛋糕 |
| fruit_juice | fruit, liquid | pot | 果汁 |

---

### Wave 5: 验证和优化

#### 任务 5.1: 运行单元测试
- **验证**: 所有测试通过

#### 任务 5.2: 性能测试
- **验证**: 稳定 60 FPS
- **验证**: 场景加载 < 3 秒

#### 任务 5.3: 集成测试
- **验证**: 完整烹饪流程
- **验证**: 存档/读档功能
- **验证**: 音效播放

---

## 依赖关系

```
Wave 1 (存档) ──→ Wave 5 (验证)
Wave 2 (音效) ──→ Wave 5 (验证)
Wave 3 (测试) ──→ Wave 5 (验证)
Wave 4 (数据) ──→ Wave 5 (验证)
```

## 验收标准

- [ ] SaveData Codec 定义完成
- [ ] 自动保存功能正常
- [ ] UI 音效播放正常
- [ ] 单元测试通过
- [ ] 60+ 种材料数据可加载
- [ ] 20+ 种配方数据可加载
- [ ] 稳定 60 FPS
- [ ] 无运行时错误

## 风险和缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Codec 集成复杂 | 中 | 参考 2-RESEARCH.md 示例 |
| 音效文件缺失 | 低 | 使用占位符 |
| 测试覆盖不全 | 中 | 优先测试核心功能 |

## 下一步

完成阶段 5 后，项目原型完成。可以开始游戏玩法迭代。