## 数据管理器
##
## 管理所有游戏数据的注册和查询

extends Node

## 注册表实例
var material_registry: RegistryBase
var equipment_registry: RegistryBase
var recipe_registry: RegistryBase
var tag_registry: TagRegistry

## 图鉴数据
var codex: CodexData


func _ready() -> void:
	print("[DataManager] 初始化数据系统...")
	_init_registries()
	_load_all_data()
	_init_codex()
	print("[DataManager] 数据系统初始化完成")


## 初始化注册表
func _init_registries() -> void:
	material_registry = RegistryBase.new()
	equipment_registry = RegistryBase.new()
	recipe_registry = RegistryBase.new()
	tag_registry = TagRegistry.new()

	RegistryManager.register_registry("materials", material_registry)
	RegistryManager.register_registry("equipment", equipment_registry)
	RegistryManager.register_registry("recipes", recipe_registry)
	RegistryManager.register_registry("tags", tag_registry)


## 加载所有数据
func _load_all_data() -> void:
	_load_tags()
	_load_materials()
	_load_equipment()
	_load_recipes()


## 初始化图鉴
func _init_codex() -> void:
	codex = CodexData.new()

	# 自动发现所有基础材料
	for material in get_all_materials():
		if material.is_base:
			codex.discover_material(material)


## 加载标签
func _load_tags() -> void:
	var material_type := ResourceLocation.from_string("cookery:registry/material")

	# 状态标签
	_register_tag(&"raw", material_type)
	_register_tag(&"cooked", material_type)
	_register_tag(&"fermented", material_type)
	_register_tag(&"burned", material_type)

	# 元素标签
	_register_tag(&"fire", material_type)
	_register_tag(&"water", material_type)
	_register_tag(&"earth", material_type)
	_register_tag(&"air", material_type)

	# 材质标签
	_register_tag(&"liquid", material_type)
	_register_tag(&"solid", material_type)
	_register_tag(&"powder", material_type)
	_register_tag(&"gas", material_type)

	# 类别标签
	_register_tag(&"grain", material_type)
	_register_tag(&"meat", material_type)
	_register_tag(&"vegetable", material_type)
	_register_tag(&"fruit", material_type)
	_register_tag(&"dairy", material_type)
	_register_tag(&"protein", material_type)
	_register_tag(&"mineral", material_type)
	_register_tag(&"fat", material_type)

	# 效果标签
	_register_tag(&"spicy", material_type)
	_register_tag(&"sweet", material_type)
	_register_tag(&"sour", material_type)
	_register_tag(&"salty", material_type)
	_register_tag(&"bitter", material_type)
	_register_tag(&"umami", material_type)
	_register_tag(&"hot", material_type)
	_register_tag(&"crispy", material_type)

	print("[DataManager] 标签加载完成: ", tag_registry.get_all_tag_ids().size())


## 注册单个标签
func _register_tag(tag_name: StringName, registry_type: ResourceLocation) -> void:
	var tag_id := ResourceLocation.from_string("cookery:tag/" + tag_name)
	tag_registry.register_tag(tag_id, registry_type)


## 加载材料
func _load_materials() -> void:
	# ── 谷物类 (8) ──────────────────────────────────────
	_register_material(_create_material("flour", "面粉", "基础谷物粉末", [&"raw", &"grain", &"powder"], "grain"))
	_register_material(_create_material("rice", "大米", "亚洲主食", [&"raw", &"grain"], "grain"))
	_register_material(_create_material("oat", "燕麦", "健康谷物", [&"raw", &"grain", &"powder"], "grain"))
	_register_material(_create_material("corn", "玉米", "金黄色谷物", [&"raw", &"grain", &"sweet"], "grain"))
	_register_material(_create_material("barley", "大麦", "酿造原料", [&"raw", &"grain"], "grain"))
	_register_material(_create_material("wheat", "小麦", "面包原料", [&"raw", &"grain", &"powder"], "grain"))
	_register_material(_create_material("millet", "小米", "营养谷物", [&"raw", &"grain"], "grain"))
	_register_material(_create_material("sorghum", "高粱", "耐旱谷物", [&"raw", &"grain"], "grain"))

	# ── 肉类 (8) ──────────────────────────────────────
	_register_material(_create_material("meat", "肉", "新鲜的肉类", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("pork", "猪肉", "常见肉类", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("beef", "牛肉", "红肉", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("chicken", "鸡肉", "白肉", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("fish", "鱼", "海鲜", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("shrimp", "虾", "甲壳类海鲜", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("lamb", "羊肉", "风味肉类", [&"raw", &"meat", &"protein"], "meat"))
	_register_material(_create_material("duck", "鸭肉", "禽类肉", [&"raw", &"meat", &"protein"], "meat"))

	# ── 蔬菜类 (12) ──────────────────────────────────────
	_register_material(_create_material("tomato", "番茄", "红色的蔬菜", [&"raw", &"vegetable", &"sour"], "vegetable"))
	_register_material(_create_material("onion", "洋葱", "辛辣的蔬菜", [&"raw", &"vegetable", &"spicy"], "vegetable"))
	_register_material(_create_material("pepper", "辣椒", "辣味调味品", [&"raw", &"vegetable", &"spicy"], "vegetable"))
	_register_material(_create_material("carrot", "胡萝卜", "橙色蔬菜", [&"raw", &"vegetable", &"sweet"], "vegetable"))
	_register_material(_create_material("potato", "土豆", "淀粉类蔬菜", [&"raw", &"vegetable"], "vegetable"))
	_register_material(_create_material("cabbage", "白菜", "叶菜类", [&"raw", &"vegetable"], "vegetable"))
	_register_material(_create_material("spinach", "菠菜", "绿叶蔬菜", [&"raw", &"vegetable", &"bitter"], "vegetable"))
	_register_material(_create_material("broccoli", "西兰花", "十字花科蔬菜", [&"raw", &"vegetable"], "vegetable"))
	_register_material(_create_material("mushroom", "蘑菇", "菌类", [&"raw", &"vegetable", &"umami"], "vegetable"))
	_register_material(_create_material("garlic", "大蒜", "调味蔬菜", [&"raw", &"vegetable", &"spicy"], "vegetable"))
	_register_material(_create_material("ginger", "姜", "辛辣根茎", [&"raw", &"vegetable", &"spicy"], "vegetable"))
	_register_material(_create_material("celery", "芹菜", "脆嫩蔬菜", [&"raw", &"vegetable", &"salty"], "vegetable"))

	# ── 水果类 (8) ──────────────────────────────────────
	_register_material(_create_material("lemon", "柠檬", "酸味水果", [&"raw", &"fruit", &"sour"], "fruit"))
	_register_material(_create_material("apple", "苹果", "常见水果", [&"raw", &"fruit", &"sweet"], "fruit"))
	_register_material(_create_material("banana", "香蕉", "热带水果", [&"raw", &"fruit", &"sweet"], "fruit"))
	_register_material(_create_material("strawberry", "草莓", "红色浆果", [&"raw", &"fruit", &"sweet", &"sour"], "fruit"))
	_register_material(_create_material("orange", "橙子", "柑橘类水果", [&"raw", &"fruit", &"sweet", &"sour"], "fruit"))
	_register_material(_create_material("grape", "葡萄", "酿酒水果", [&"raw", &"fruit", &"sweet"], "fruit"))
	_register_material(_create_material("peach", "桃子", "夏季水果", [&"raw", &"fruit", &"sweet"], "fruit"))
	_register_material(_create_material("mango", "芒果", "热带水果", [&"raw", &"fruit", &"sweet"], "fruit"))

	# ── 乳制品类 (6) ──────────────────────────────────────
	_register_material(_create_material("milk", "牛奶", "新鲜的乳制品", [&"liquid", &"dairy"], "dairy"))
	_register_material(_create_material("butter", "黄油", "乳制品脂肪", [&"solid", &"dairy", &"fat"], "dairy"))
	_register_material(_create_material("cheese", "奶酪", "发酵乳制品", [&"solid", &"dairy", &"umami"], "dairy"))
	_register_material(_create_material("yogurt", "酸奶", "益生菌乳制品", [&"liquid", &"dairy", &"sour"], "dairy"))
	_register_material(_create_material("cream", "奶油", "高脂肪乳制品", [&"liquid", &"dairy", &"fat"], "dairy"))
	_register_material(_create_material("ice_cream", "冰淇淋", "冷冻甜品", [&"solid", &"dairy", &"sweet"], "dairy"))

	# ── 调味品类 (10) ──────────────────────────────────────
	_register_material(_create_material("salt", "盐", "调味用的矿物质", [&"solid", &"salty"], "mineral"))
	_register_material(_create_material("sugar", "糖", "甜味调味品", [&"solid", &"sweet"], "mineral"))
	_register_material(_create_material("soy_sauce", "酱油", "发酵调味品", [&"liquid", &"salty", &"umami"], "mineral"))
	_register_material(_create_material("vinegar", "醋", "酸味调味品", [&"liquid", &"sour"], "mineral"))
	_register_material(_create_material("black_pepper", "黑胡椒", "辛辣香料", [&"solid", &"spicy"], "mineral"))
	_register_material(_create_material("chili_powder", "辣椒粉", "辣味粉末", [&"powder", &"spicy"], "mineral"))
	_register_material(_create_material("cinnamon", "肉桂", "甜味香料", [&"powder", &"sweet", &"spicy"], "mineral"))
	_register_material(_create_material("garlic_powder", "蒜粉", "干燥蒜末", [&"powder", &"spicy", &"umami"], "mineral"))
	_register_material(_create_material("oregano", "牛至", "意大利香草", [&"powder", &"bitter"], "mineral"))
	_register_material(_create_material("basil", "罗勒", "芳香草本", [&"powder", &"sweet"], "mineral"))

	# ── 其他 (8) ──────────────────────────────────────
	_register_material(_create_material("egg", "鸡蛋", "常见的蛋白质来源", [&"raw", &"protein", &"liquid"], "protein"))
	_register_material(_create_material("water", "水", "清澈的液体", [&"liquid", &"water"], "liquid"))
	_register_material(_create_material("oil", "食用油", "烹饪用油", [&"liquid", &"fat"], "liquid"))
	_register_material(_create_material("honey", "蜂蜜", "天然甜味剂", [&"liquid", &"sweet"], "mineral"))
	_register_material(_create_material("chocolate", "巧克力", "可可制品", [&"solid", &"sweet", &"bitter"], "mineral"))
	_register_material(_create_material("tofu", "豆腐", "豆制品", [&"solid", &"protein"], "protein"))
	_register_material(_create_material("seaweed", "海苔", "海洋植物", [&"solid", &"salty", &"umami"], "vegetable"))
	_register_material(_create_material("nuts", "坚果", "营养零食", [&"solid", &"fat", &"protein"], "grain"))

	print("[DataManager] 材料加载完成: ", material_registry.get_all_entries().size())


## 创建材料
func _create_material(id: String, display_name: String, description: String, tags: Array[StringName], category: String) -> MaterialData:
	var material := MaterialData.new()
	material.id = id
	material.display_name = display_name
	material.description = description
	material.tags = tags
	material.category = category
	material.is_base = true
	return material


## 注册材料
func _register_material(material: MaterialData) -> void:
	var id := ResourceLocation.from_string("cookery:material/" + material.id)
	material_registry.register(id, material)


## 加载设备
func _load_equipment() -> void:
	# 烤箱
	var stove := EquipmentData.new()
	stove.id = "stove"
	stove.display_name = "烤箱"
	stove.description = "用于烘烤和加热食物"
	stove.max_inputs = 1
	stove.process_time = 2.0
	stove.transform_rules = [_create_convert_rule(&"raw", &"cooked")]
	_register_equipment(stove)

	# 锅
	var pot := EquipmentData.new()
	pot.id = "pot"
	pot.display_name = "锅"
	pot.description = "用于煮和混合食材"
	pot.max_inputs = 3
	pot.process_time = 3.0
	pot.transform_rules = [
		_create_convert_rule(&"raw", &"cooked"),
		_create_combine_rule([&"water", &"fire"], &"steam", false)
	]
	_register_equipment(pot)

	# 发酵器
	var fermenter := EquipmentData.new()
	fermenter.id = "fermenter"
	fermenter.display_name = "发酵器"
	fermenter.description = "用于发酵食物"
	fermenter.max_inputs = 1
	fermenter.process_time = 5.0
	fermenter.transform_rules = [
		_create_remove_rule(&"raw"),
		_create_amplify_rule(&"flavor", &"umami")
	]
	_register_equipment(fermenter)

	print("[DataManager] 设备加载完成: ", equipment_registry.get_all_entries().size())


## 创建转换规则
func _create_convert_rule(from_tag: StringName, to_tag: StringName) -> ConvertRule:
	var rule := ConvertRule.new()
	rule.from_tag = from_tag
	rule.to_tag = to_tag
	return rule


## 创建组合规则
func _create_combine_rule(required_tags: Array[StringName], result_tag: StringName, consume_inputs: bool) -> CombineRule:
	var rule := CombineRule.new()
	rule.required_tags = required_tags
	rule.result_tag = result_tag
	rule.consume_inputs = consume_inputs
	return rule


## 创建消除规则
func _create_remove_rule(tag: StringName) -> RemoveRule:
	var rule := RemoveRule.new()
	rule.tag = tag
	return rule


## 创建增幅规则
func _create_amplify_rule(tag: StringName, add_tag: StringName) -> AmplifyRule:
	var rule := AmplifyRule.new()
	rule.tag = tag
	rule.add_tag = add_tag
	return rule


## 注册设备
func _register_equipment(equipment: EquipmentData) -> void:
	var id := ResourceLocation.from_string("cookery:equipment/" + equipment.id)
	equipment_registry.register(id, equipment)


## 加载配方
func _load_recipes() -> void:
	# ── 烤箱配方 ──────────────────────────────────────
	_register_recipe(_create_recipe("bread", "面包", "基础烘焙食品",
		[&"raw", &"grain", &"powder"], "stove", "bread", [&"cooked", &"grain"]))
	_register_recipe(_create_recipe("grilled_meat", "烤肉", "经过烤制的肉类",
		[&"raw", &"meat"], "stove", "grilled_meat", [&"cooked", &"meat"]))
	_register_recipe(_create_recipe("grilled_chicken", "烤鸡", "香烤鸡肉",
		[&"raw", &"chicken"], "stove", "grilled_chicken", [&"cooked", &"meat"]))
	_register_recipe(_create_recipe("grilled_fish", "烤鱼", "香烤鱼类",
		[&"raw", &"fish"], "stove", "grilled_fish", [&"cooked", &"meat"]))
	_register_recipe(_create_recipe("steak", "牛排", "煎烤牛肉",
		[&"raw", &"beef"], "stove", "steak", [&"cooked", &"meat"]))
	_register_recipe(_create_recipe("roasted_vegetables", "烤蔬菜", "烤制蔬菜",
		[&"raw", &"vegetable"], "stove", "roasted_vegetables", [&"cooked", &"vegetable"]))
	_register_recipe(_create_recipe("honey_cake", "蜂蜜蛋糕", "甜蜜糕点",
		[&"grain", &"sweet", &"honey"], "stove", "honey_cake", [&"cooked", &"grain", &"sweet"]))

	# ── 锅配方 ──────────────────────────────────────
	_register_recipe(_create_recipe("boiled_water", "开水", "经过煮沸的水",
		[&"liquid", &"water"], "pot", "boiled_water", [&"liquid", &"water", &"hot"]))
	_register_recipe(_create_recipe("tomato_soup", "番茄汤", "温暖的番茄汤",
		[&"raw", &"vegetable", &"liquid"], "pot", "tomato_soup", [&"cooked", &"vegetable", &"liquid"]))
	_register_recipe(_create_recipe("fried_rice", "炒饭", "美味炒饭",
		[&"cooked", &"rice", &"egg"], "pot", "fried_rice", [&"cooked", &"grain", &"protein"]))
	_register_recipe(_create_recipe("pasta", "意面", "意大利面食",
		[&"raw", &"grain", &"water"], "pot", "pasta", [&"cooked", &"grain"]))
	_register_recipe(_create_recipe("soup", "肉汤", "营养肉汤",
		[&"raw", &"meat", &"liquid"], "pot", "soup", [&"cooked", &"meat", &"liquid"]))
	_register_recipe(_create_recipe("vegetable_soup", "蔬菜汤", "健康蔬菜汤",
		[&"raw", &"vegetable", &"liquid"], "pot", "vegetable_soup", [&"cooked", &"vegetable", &"liquid"]))
	_register_recipe(_create_recipe("fruit_juice", "果汁", "新鲜果汁",
		[&"raw", &"fruit", &"liquid"], "pot", "fruit_juice", [&"liquid", &"fruit", &"sweet"]))
	_register_recipe(_create_recipe("hot_chocolate", "热巧克力", "温暖饮品",
		[&"chocolate", &"milk"], "pot", "hot_chocolate", [&"liquid", &"sweet", &"hot"]))

	# ── 发酵器配方 ──────────────────────────────────────
	_register_recipe(_create_recipe("fermented_dough", "发酵面团", "经过发酵的面团",
		[&"raw", &"grain", &"powder"], "fermenter", "fermented_dough", [&"grain", &"powder", &"fermented"]))
	_register_recipe(_create_recipe("cheese", "奶酪", "发酵乳制品",
		[&"dairy", &"milk"], "fermenter", "cheese", [&"dairy", &"fermented", &"umami"]))
	_register_recipe(_create_recipe("yogurt", "酸奶", "益生菌乳制品",
		[&"dairy", &"milk"], "fermenter", "yogurt", [&"dairy", &"fermented", &"sour"]))
	_register_recipe(_create_recipe("kimchi", "泡菜", "发酵蔬菜",
		[&"vegetable", &"spicy"], "fermenter", "kimchi", [&"vegetable", &"fermented", &"spicy"]))
	_register_recipe(_create_recipe("soy_sauce", "酱油", "发酵调味品",
		[&"grain", &"salty"], "fermenter", "soy_sauce", [&"liquid", &"fermented", &"umami"]))

	print("[DataManager] 配方加载完成: ", recipe_registry.get_all_entries().size())


## 创建配方
func _create_recipe(id: String, display_name: String, description: String,
		required_tags: Array[StringName], required_equipment: String,
		result_material: String, result_tags: Array[StringName]) -> RecipeData:
	var recipe := RecipeData.new()
	recipe.id = id
	recipe.display_name = display_name
	recipe.description = description
	recipe.required_tags = required_tags
	recipe.required_equipment = required_equipment
	recipe.result_material = result_material
	recipe.result_tags = result_tags
	return recipe


## 注册配方
func _register_recipe(recipe: RecipeData) -> void:
	var id := ResourceLocation.from_string("cookery:recipe/" + recipe.id)
	recipe_registry.register(id, recipe)


## ── 查询 API ──────────────────────────────────────────

## 获取材料
func get_material(id: String) -> MaterialData:
	var loc := ResourceLocation.from_string("cookery:material/" + id)
	return material_registry.get_entry(loc)


## 获取所有材料
func get_all_materials() -> Array[MaterialData]:
	var result: Array[MaterialData] = []
	for entry in material_registry.get_all_entries().values():
		if entry is MaterialData:
			result.append(entry)
	return result


## 获取设备
func get_equipment(id: String) -> EquipmentData:
	var loc := ResourceLocation.from_string("cookery:equipment/" + id)
	return equipment_registry.get_entry(loc)


## 获取所有设备
func get_all_equipment() -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for entry in equipment_registry.get_all_entries().values():
		if entry is EquipmentData:
			result.append(entry)
	return result


## 获取配方
func get_recipe(id: String) -> RecipeData:
	var loc := ResourceLocation.from_string("cookery:recipe/" + id)
	return recipe_registry.get_entry(loc)


## 获取所有配方
func get_all_recipes() -> Array[RecipeData]:
	var result: Array[RecipeData] = []
	for entry in recipe_registry.get_all_entries().values():
		if entry is RecipeData:
			result.append(entry)
	return result


## 匹配配方
func find_matching_recipe(tags: Array[StringName], equipment_id: String) -> RecipeData:
	for recipe in get_all_recipes():
		if recipe.matches(tags, equipment_id):
			return recipe
	return null


## 发现配方
func discover_recipe(recipe: RecipeData) -> bool:
	if codex.discover_recipe(recipe):
		recipe.is_discovered = true
		return true
	return false


## ── 分类查询 API ──────────────────────────────────────

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


## 获取已发现的设备
func get_discovered_equipment() -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for equipment in codex.discovered_equipment.values():
		if equipment is EquipmentData:
			result.append(equipment)
	return result


## 检查材料是否已解锁
func is_material_unlocked(id: String) -> bool:
	return codex.has_material(id)


## 检查配方是否已发现
func is_recipe_discovered(id: String) -> bool:
	return codex.has_recipe(id)