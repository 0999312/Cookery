## 存档数据
##
## 使用 CodecResource 定义存档数据结构

extends CodecResource
class_name SaveData

## 当前存档格式版本
const CURRENT_VERSION := "1.0.0"

## 存档版本
@export var version: String = CURRENT_VERSION

## 存档时间戳
@export var timestamp: float = 0.0

## 游戏时间（秒）
@export var play_time: float = 0.0

## 已发现材料 ID 列表
@export var discovered_materials: Array[String] = []

## 已发现配方 ID 列表
@export var discovered_recipes: Array[String] = []

## 已发现设备 ID 列表
@export var discovered_equipment: Array[String] = []

## 设置（不通过 Codec 序列化，使用 ConfigFile 单独保存）
var settings: Dictionary = {}


## 获取类型 ID
static func get_type_id() -> String:
	return "cookery:save"


## 获取 Codec（settings 不序列化，使用 ConfigFile 单独管理）
static func get_codec() -> Codec:
	return MapCodec.build([
		Codec.STRING().optional_field_of("version", CURRENT_VERSION).for_getter(func(obj): return obj.version),
		Codec.FLOAT().field_of("timestamp").for_getter(func(obj): return obj.timestamp),
		Codec.FLOAT().optional_field_of("play_time", 0.0).for_getter(func(obj): return obj.play_time),
		Codec.STRING().list_of().optional_field_of("discovered_materials", []).for_getter(func(obj): return obj.discovered_materials),
		Codec.STRING().list_of().optional_field_of("discovered_recipes", []).for_getter(func(obj): return obj.discovered_recipes),
		Codec.STRING().list_of().optional_field_of("discovered_equipment", []).for_getter(func(obj): return obj.discovered_equipment),
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


## 检查版本兼容性
func is_compatible() -> bool:
	# 当前版本 1.0.0 兼容所有 1.x.x 版本
	return version.begins_with("1.")


## 从图鉴数据创建存档
static func from_codex(codex: CodexData) -> SaveData:
	var save = SaveData.new()
	save.timestamp = Time.get_unix_time_from_system()

	# 收集已发现材料
	for material in codex.discovered_materials.values():
		if material is MaterialData:
			save.discovered_materials.append(material.id)

	# 收集已发现配方
	for recipe in codex.discovered_recipes.values():
		if recipe is RecipeData:
			save.discovered_recipes.append(recipe.id)

	# 收集已发现设备
	for equipment in codex.discovered_equipment.values():
		if equipment is EquipmentData:
			save.discovered_equipment.append(equipment.id)

	return save


## 应用存档数据到图鉴
func apply_to_codex(codex: CodexData) -> void:
	# 恢复已发现材料
	for material_id in discovered_materials:
		var material = DataManager.get_material(material_id)
		if material:
			codex.discover_material(material)

	# 恢复已发现配方
	for recipe_id in discovered_recipes:
		var recipe = DataManager.get_recipe(recipe_id)
		if recipe:
			codex.discover_recipe(recipe)

	# 恢复已发现设备
	for equipment_id in discovered_equipment:
		var equipment = DataManager.get_equipment(equipment_id)
		if equipment:
			codex.discover_equipment(equipment)