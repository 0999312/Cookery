## 配方数据
##
## 定义游戏中的配方，用于匹配标签组合生成结果

extends CodecResource
class_name RecipeData

## 配方 ID
@export var id: String = ""

## 配方名称
@export var display_name: String = ""

## 配方描述
@export var description: String = ""

## 需要的标签组合
@export var required_tags: Array[StringName] = []

## 需要的设备 ID
@export var required_equipment: String = ""

## 结果材料 ID
@export var result_material: String = ""

## 结果标签
@export var result_tags: Array[StringName] = []

## 解锁奖励（材料/配方/设备 ID）
@export var unlock_reward: String = ""

## 是否已发现
@export var is_discovered: bool = false


## 获取类型 ID
static func get_type_id() -> String:
	return "cookery:recipe"


## 获取 Codec
static func get_codec() -> Codec:
	return MapCodec.build([
		Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
		Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name),
		Codec.STRING().optional_field_of("description", "").for_getter(func(obj): return obj.description),
		Codec.STRING().list_of().field_of("required_tags").for_getter(func(obj): return obj.required_tags),
		Codec.STRING().field_of("required_equipment").for_getter(func(obj): return obj.required_equipment),
		Codec.STRING().field_of("result_material").for_getter(func(obj): return obj.result_material),
		Codec.STRING().list_of().optional_field_of("result_tags", []).for_getter(func(obj): return obj.result_tags),
		Codec.STRING().optional_field_of("unlock_reward", "").for_getter(func(obj): return obj.unlock_reward),
		Codec.BOOL().optional_field_of("is_discovered", false).for_getter(func(obj): return obj.is_discovered),
	], func(id, display_name, description, required_tags, required_equipment, result_material, result_tags, unlock_reward, is_discovered):
		var recipe = RecipeData.new()
		recipe.id = id
		recipe.display_name = display_name
		recipe.description = description
		recipe.required_tags = required_tags
		recipe.required_equipment = required_equipment
		recipe.result_material = result_material
		recipe.result_tags = result_tags
		recipe.unlock_reward = unlock_reward
		recipe.is_discovered = is_discovered
		return recipe
	).codec()


## 检查标签是否匹配配方
func matches(tags: Array[StringName], equipment_id: String) -> bool:
	# 检查设备
	if required_equipment != "" and required_equipment != equipment_id:
		return false

	# 检查必需标签
	for tag in required_tags:
		if tag not in tags:
			return false

	return true


## 获取 ResourceLocation
func get_resource_location() -> ResourceLocation:
	return ResourceLocation.from_string("cookery:recipe/" + id)