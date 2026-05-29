## 图鉴数据
##
## 记录玩家已发现的材料、配方、设备

extends Resource
class_name CodexData

## 已发现材料（id → MaterialData）
@export var discovered_materials: Dictionary = {}

## 已发现配方（id → RecipeData）
@export var discovered_recipes: Dictionary = {}

## 已发现设备（id → EquipmentData）
@export var discovered_equipment: Dictionary = {}

## 发现计数
@export var discovery_count: int = 0


## 添加发现的材料
func discover_material(material: MaterialData) -> bool:
	if material.id in discovered_materials:
		return false

	discovered_materials[material.id] = material
	discovery_count += 1
	return true


## 添加发现的配方
func discover_recipe(recipe: RecipeData) -> bool:
	if recipe.id in discovered_recipes:
		return false

	discovered_recipes[recipe.id] = recipe
	discovery_count += 1
	return true


## 添加发现的设备
func discover_equipment(equipment: EquipmentData) -> bool:
	if equipment.id in discovered_equipment:
		return false

	discovered_equipment[equipment.id] = equipment
	discovery_count += 1
	return true


## 检查材料是否已发现
func has_material(id: String) -> bool:
	return id in discovered_materials


## 检查配方是否已发现
func has_recipe(id: String) -> bool:
	return id in discovered_recipes


## 检查设备是否已发现
func has_equipment(id: String) -> bool:
	return id in discovered_equipment


## 获取已发现材料数量
func get_material_count() -> int:
	return discovered_materials.size()


## 获取已发现配方数量
func get_recipe_count() -> int:
	return discovered_recipes.size()


## 获取已发现设备数量
func get_equipment_count() -> int:
	return discovered_equipment.size()