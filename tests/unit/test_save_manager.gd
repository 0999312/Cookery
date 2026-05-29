## 存档管理器测试

extends GutTest

## 测试存档保存
func test_save_game() -> void:
	var result = SaveManager.save_game(1)
	assert_true(result, "存档应该成功")
	assert_true(SaveManager.save_exists(1), "存档文件应该存在")


## 测试存档加载
func test_load_game() -> void:
	# 先保存
	SaveManager.save_game(2)

	# 加载
	var result = SaveManager.load_game(2)
	assert_true(result, "读档应该成功")
	assert_not_null(SaveManager.current_save, "当前存档应该存在")


## 测试存档删除
func test_delete_save() -> void:
	# 先保存
	SaveManager.save_game(3)

	# 删除
	var result = SaveManager.delete_save(3)
	assert_true(result, "删除应该成功")
	assert_false(SaveManager.save_exists(3), "存档文件应该不存在")


## 测试自动保存
func test_auto_save() -> void:
	SaveManager.auto_save()
	assert_true(SaveManager.save_exists(0), "自动存档应该存在")


## 测试 SaveData Codec
func test_save_data_codec() -> void:
	var save = SaveData.new()
	save.version = "1.0.0"
	save.timestamp = 1234567890.0
	save.play_time = 3600.0
	save.discovered_materials = ["flour", "water"]
	save.discovered_recipes = ["bread"]

	# 编码
	var json_result = save.to_json_data()
	assert_true(json_result.is_success(), "编码应该成功")

	# 解码
	var decoded = SaveData.from_json_data(json_result.get_value())
	assert_true(decoded.is_success(), "解码应该成功")

	var loaded_save = decoded.get_value()
	assert_eq(loaded_save.version, "1.0.0", "版本应该正确")
	assert_eq(loaded_save.discovered_materials.size(), 2, "应该有 2 个材料")