## 数据管理器测试

extends GutTest

## 测试数据加载
func test_data_loading() -> void:
	assert_not_null(DataManager, "DataManager 应该存在")
	assert_true(DataManager.get_all_materials().size() > 0, "应该加载了材料数据")
	assert_true(DataManager.get_all_equipment().size() > 0, "应该加载了设备数据")
	assert_true(DataManager.get_all_recipes().size() > 0, "应该加载了配方数据")


## 测试材料查询
func test_material_query() -> void:
	var flour = DataManager.get_material("flour")
	assert_not_null(flour, "应该能查询到面粉")
	assert_eq(flour.display_name, "面粉", "面粉显示名称应该正确")
	assert_true(&"raw" in flour.tags, "面粉应该有 raw 标签")


## 测试设备查询
func test_equipment_query() -> void:
	var stove = DataManager.get_equipment("stove")
	assert_not_null(stove, "应该能查询到烤箱")
	assert_eq(stove.display_name, "烤箱", "烤箱显示名称应该正确")
	assert_eq(stove.max_inputs, 1, "烤箱最大输入应该是 1")


## 测试配方查询
func test_recipe_query() -> void:
	var bread = DataManager.get_recipe("bread")
	assert_not_null(bread, "应该能查询到面包配方")
	assert_eq(bread.display_name, "面包", "面包配方显示名称应该正确")
	assert_true(&"raw" in bread.required_tags, "面包配方应该需要 raw 标签")


## 测试配方匹配
func test_recipe_matching() -> void:
	var tags: Array[StringName] = [&"raw", &"grain", &"powder"]
	var recipe = DataManager.find_matching_recipe(tags, "stove")

	assert_not_null(recipe, "应该匹配到配方")
	assert_eq(recipe.id, "bread", "应该匹配到面包配方")


## 测试分类查询
func test_category_query() -> void:
	var grains = DataManager.get_materials_by_category("grain")
	assert_true(grains.size() > 0, "应该有谷物类材料")

	var meats = DataManager.get_materials_by_category("meat")
	assert_true(meats.size() > 0, "应该有肉类材料")


## 测试标签注册
func test_tag_registration() -> void:
	assert_not_null(DataManager.tag_registry, "标签注册表应该存在")

	var raw_tag = DataManager.tag_registry.get_tag(ResourceLocation.from_string("cookery:tag/raw"))
	assert_not_null(raw_tag, "raw 标签应该存在")