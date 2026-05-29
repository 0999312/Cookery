## 烹饪系统测试

extends GutTest

## 测试转换规则
func test_convert_rule() -> void:
	var rule = ConvertRule.new()
	rule.from_tag = &"raw"
	rule.to_tag = &"cooked"

	var tags: Array[StringName] = [&"raw", &"grain"]
	var result = rule.apply(tags)

	assert_true(&"cooked" in result, "应该包含 cooked 标签")
	assert_false(&"raw" in result, "不应该包含 raw 标签")
	assert_true(&"grain" in result, "应该保留 grain 标签")


## 测试组合规则
func test_combine_rule() -> void:
	var rule = CombineRule.new()
	rule.required_tags = [&"water", &"fire"]
	rule.result_tag = &"steam"
	rule.consume_inputs = true

	var tags: Array[StringName] = [&"water", &"fire", &"other"]
	var result = rule.apply(tags)

	assert_true(&"steam" in result, "应该包含 steam 标签")
	assert_false(&"water" in result, "不应该包含 water 标签")
	assert_false(&"fire" in result, "不应该包含 fire 标签")
	assert_true(&"other" in result, "应该保留 other 标签")


## 测试消除规则
func test_remove_rule() -> void:
	var rule = RemoveRule.new()
	rule.tag = &"raw"

	var tags: Array[StringName] = [&"raw", &"grain"]
	var result = rule.apply(tags)

	assert_false(&"raw" in result, "不应该包含 raw 标签")
	assert_true(&"grain" in result, "应该保留 grain 标签")


## 测试增幅规则
func test_amplify_rule() -> void:
	var rule = AmplifyRule.new()
	rule.tag = &"heat"
	rule.add_tag = &"crispy"

	var tags: Array[StringName] = [&"heat", &"meat"]
	var result = rule.apply(tags)

	assert_true(&"crispy" in result, "应该包含 crispy 标签")
	assert_true(&"heat" in result, "应该保留 heat 标签")


## 测试烹饪系统 - 配方匹配
func test_cooking_system_recipe_match() -> void:
	var result = CookingSystem.start_cooking("stove", ["flour"])

	assert_true(result.success, "烹饪应该成功")
	assert_not_null(result.output_material, "应该有输出材料")
	assert_not_null(result.matched_recipe, "应该匹配到配方")


## 测试烹饪系统 - 动态结果
func test_cooking_system_dynamic_result() -> void:
	# 使用不存在的材料组合
	var result = CookingSystem.start_cooking("stove", ["salt", "sugar"])

	assert_true(result.success, "烹饪应该成功")
	assert_not_null(result.output_material, "应该有输出材料")
	assert_true(result.is_new_discovery, "应该是新发现")


## 测试名称生成
func test_name_generation() -> void:
	var tags: Array[StringName] = [&"cooked", &"grain", &"powder"]
	var name = CookingSystem._generate_name_from_tags(tags)

	assert_eq(name, "熟谷物粉", "名称应该是 '熟谷物粉'")


## 测试名称生成 - 空标签
func test_name_generation_empty() -> void:
	var tags: Array[StringName] = []
	var name = CookingSystem._generate_name_from_tags(tags)

	assert_eq(name, "神秘料理", "空标签应该返回 '神秘料理'")