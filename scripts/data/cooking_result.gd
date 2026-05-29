## 烹饪结果数据类
##
## 存储烹饪过程的结果信息

class_name CookingResult

## 是否成功
var success: bool = false

## 使用的设备
var equipment: EquipmentData

## 输入材料
var input_materials: Array[MaterialData] = []

## 输出材料
var output_material: MaterialData

## 输出标签
var output_tags: Array[StringName] = []

## 匹配的配方（可为 null）
var matched_recipe: RecipeData

## 是否是新发现
var is_new_discovery: bool = false

## 处理时间
var processing_time: float = 0.0


## 创建失败结果
static func create_failed(error_message: String = "") -> CookingResult:
	push_error("[CookingResult] ", error_message)
	var result = CookingResult.new()
	result.success = false
	return result


## 创建成功结果
static func create_success(
	equipment: EquipmentData,
	input_materials: Array[MaterialData],
	output_material: MaterialData,
	output_tags: Array[StringName],
	matched_recipe: RecipeData = null,
	is_new_discovery: bool = false
) -> CookingResult:
	var result = CookingResult.new()
	result.success = true
	result.equipment = equipment
	result.input_materials = input_materials
	result.output_material = output_material
	result.output_tags = output_tags
	result.matched_recipe = matched_recipe
	result.is_new_discovery = is_new_discovery
	result.processing_time = equipment.process_time
	return result


## 获取结果描述
func get_description() -> String:
	if not success:
		return "烹饪失败"

	var desc = "使用%s制作了%s" % [equipment.display_name, output_material.display_name]

	if matched_recipe:
		desc += "（配方: %s）" % matched_recipe.display_name
	else:
		desc += "（新发现!）"

	return desc