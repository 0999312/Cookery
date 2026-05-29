## 烹饪系统
##
## 实现核心烹饪流程：材料 → 设备 → 变换 → 结果

class_name CookingSystem

## 动态材料计数器
static var _dynamic_counter: int = 0


## 执行烹饪（纯数据处理，不发布事件）
## 事件由调用方（UI 层）负责发布
static func start_cooking(equipment_id: String, material_ids: Array[String]) -> CookingResult:
	# 1. 获取设备数据
	var equipment = DataManager.get_equipment(equipment_id)
	if not equipment:
		return CookingResult.create_failed("设备不存在: " + equipment_id)

	# 2. 获取材料数据
	var materials: Array[MaterialData] = []
	for id in material_ids:
		var material = DataManager.get_material(id)
		if not material:
			return CookingResult.create_failed("材料不存在: " + id)
		materials.append(material)

	# 3. 验证材料数量
	if materials.size() > equipment.max_inputs:
		return CookingResult.create_failed("材料数量超过设备限制 (%d > %d)" % [materials.size(), equipment.max_inputs])

	# 4. 收集输入标签
	var input_tags = _collect_tags(materials)

	# 5. 应用变换规则
	var output_tags = equipment.apply_transforms(input_tags)

	# 6. 匹配配方
	var recipe = DataManager.find_matching_recipe(output_tags, equipment_id)

	# 7. 生成结果
	var output_material: MaterialData
	var is_new_discovery = false

	if recipe:
		# 使用配方结果
		output_material = DataManager.get_material(recipe.result_material)
		if not output_material:
			output_material = _create_material_from_recipe(recipe, output_tags)
		is_new_discovery = not DataManager.codex.has_recipe(recipe.id)
	else:
		# 生成动态结果
		output_material = _generate_dynamic_result(output_tags, equipment)
		is_new_discovery = true

	# 8. 创建并返回结果
	return CookingResult.create_success(
		equipment,
		materials,
		output_material,
		output_tags,
		recipe,
		is_new_discovery
	)


## 完成烹饪（更新图鉴和发布事件）
static func complete_cooking(result: CookingResult) -> void:
	if not result.success:
		return

	# 发布烹饪完成事件
	EventBus.publish(CookingCompletedEvent.new(result))

	# 更新图鉴
	_update_codex(result)


## 收集材料标签
static func _collect_tags(materials: Array[MaterialData]) -> Array[StringName]:
	var tags: Array[StringName] = []
	for material in materials:
		for tag in material.tags:
			if tag not in tags:
				tags.append(tag)
	return tags


## 生成动态结果
static func _generate_dynamic_result(tags: Array[StringName], equipment: EquipmentData) -> MaterialData:
	_dynamic_counter += 1

	var material = MaterialData.new()
	material.id = "dynamic_%d_%d" % [Time.get_ticks_msec(), _dynamic_counter]
	material.display_name = _generate_name_from_tags(tags)
	material.description = "通过%s加工的料理" % equipment.display_name
	material.tags = tags
	material.category = "processed"
	material.rarity = 0
	material.is_base = false

	# 注册到 DataManager
	DataManager._register_material(material)

	return material


## 从配方创建材料
static func _create_material_from_recipe(recipe: RecipeData, tags: Array[StringName]) -> MaterialData:
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


## 从标签生成名称
static func _generate_name_from_tags(tags: Array[StringName]) -> String:
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
static func _update_codex(result: CookingResult) -> void:
	# 检查材料发现
	if not DataManager.codex.has_material(result.output_material.id):
		DataManager.codex.discover_material(result.output_material)
		EventBus.publish(MaterialUnlockedEvent.new(result.output_material))

	# 检查配方发现
	if result.matched_recipe and not DataManager.codex.has_recipe(result.matched_recipe.id):
		DataManager.codex.discover_recipe(result.matched_recipe)
		EventBus.publish(RecipeDiscoveredEvent.new(result.matched_recipe))