## 游戏主界面
##
## 烹饪界面：左侧材料选择 + 右侧烹饪台

extends UIPanel

## 分类过滤类型
enum CategoryFilter { ALL, GRAIN, MEAT, VEGETABLE, FRUIT, DAIRY, OTHER }

## 分类显示名
const CATEGORY_NAMES := {
	CategoryFilter.ALL: "全部",
	CategoryFilter.GRAIN: "谷物",
	CategoryFilter.MEAT: "肉类",
	CategoryFilter.VEGETABLE: "蔬菜",
	CategoryFilter.FRUIT: "水果",
	CategoryFilter.DAIRY: "乳制品",
	CategoryFilter.OTHER: "其他",
}

## 分类对应的数据 category 值
const CATEGORY_MAP := {
	CategoryFilter.GRAIN: "grain",
	CategoryFilter.MEAT: "meat",
	CategoryFilter.VEGETABLE: "vegetable",
	CategoryFilter.FRUIT: "fruit",
	CategoryFilter.DAIRY: "dairy",
}

## 分类按钮的强调色
const CATEGORY_COLORS := {
	"grain": Color(0.96, 0.85, 0.56),    # 暖黄
	"meat": Color(0.91, 0.40, 0.35),     # 红
	"vegetable": Color(0.55, 0.80, 0.45), # 绿
	"fruit": Color(0.98, 0.65, 0.30),     # 橙
	"dairy": Color(0.60, 0.80, 0.95),     # 蓝
	"mineral": Color(0.75, 0.75, 0.75),   # 灰
	"liquid": Color(0.40, 0.70, 0.90),    # 天蓝
	"protein": Color(0.85, 0.65, 0.45),   # 棕
}

## 稀有度颜色
const RARITY_COLORS := {
	0: Color.WHITE,               # 普通
	1: Color(0.60, 0.80, 1.00),   # 稀有 - 蓝
	2: Color(1.00, 0.84, 0.00),   # 传说 - 金
}

## 当前选择的设备
var current_equipment: EquipmentData

## 已选择的材料 ID
var selected_materials: Array[String] = []

## 是否正在处理
var is_processing: bool = false

## 当前分类过滤
var current_category: CategoryFilter = CategoryFilter.ALL

## UI 节点引用
@onready var stove_button: Button = %StoveButton
@onready var pot_button: Button = %PotButton
@onready var fermenter_button: Button = %FermenterButton
@onready var codex_button: Button = %CodexButton
@onready var settings_button: Button = %SettingsButton
@onready var pause_button: Button = %PauseButton
@onready var equipment_info: Label = %EquipmentInfo

@onready var material_grid: GridContainer = %MaterialGrid

@onready var input_slot_1: PanelContainer = %InputSlot1
@onready var input_slot_2: PanelContainer = %InputSlot2
@onready var input_slot_3: PanelContainer = %InputSlot3
@onready var start_button: Button = %StartButton
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var clear_button: Button = %ClearButton
@onready var result_label: RichTextLabel = %ResultLabel

@onready var material_count_label: Label = %MaterialCountLabel
@onready var recipe_count_label: Label = %RecipeCountLabel

## 分类按钮引用
@onready var all_button: Button = %AllButton
@onready var grain_button: Button = %GrainButton
@onready var meat_button: Button = %MeatButton
@onready var vegetable_button: Button = %VegetableButton
@onready var fruit_button: Button = %FruitButton
@onready var dairy_button: Button = %DairyButton
@onready var other_button: Button = %OtherButton


## 信号是否已连接
var _signals_connected: bool = false


func _on_init() -> void:
	# 注意：_on_init() 在 add_child() 之前调用，@onready 变量还未解析
	# 信号连接延迟到 _on_open() 中执行
	pass


## 确保信号已连接（在 _on_open 中调用，此时面板已在场景树中）
func _ensure_signals() -> void:
	if _signals_connected:
		return
	_signals_connected = true

	# 设备按钮
	stove_button.pressed.connect(_on_equipment_selected.bind("stove"))
	pot_button.pressed.connect(_on_equipment_selected.bind("pot"))
	fermenter_button.pressed.connect(_on_equipment_selected.bind("fermenter"))

	# 工具按钮
	codex_button.pressed.connect(_on_codex_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	start_button.pressed.connect(_on_start_pressed)
	clear_button.pressed.connect(_on_clear_pressed)

	# 分类按钮
	all_button.pressed.connect(_on_category_changed.bind(CategoryFilter.ALL))
	grain_button.pressed.connect(_on_category_changed.bind(CategoryFilter.GRAIN))
	meat_button.pressed.connect(_on_category_changed.bind(CategoryFilter.MEAT))
	vegetable_button.pressed.connect(_on_category_changed.bind(CategoryFilter.VEGETABLE))
	fruit_button.pressed.connect(_on_category_changed.bind(CategoryFilter.FRUIT))
	dairy_button.pressed.connect(_on_category_changed.bind(CategoryFilter.DAIRY))
	other_button.pressed.connect(_on_category_changed.bind(CategoryFilter.OTHER))

	print("[GamePanel] 信号连接完成")


func _on_open(data: Dictionary = {}) -> void:
	_ensure_signals()
	_on_equipment_selected("stove")
	_update_material_list()
	_update_status_bar()
	result_label.text = "选择材料开始烹饪..."
	GuideSetup.switch_to_game_context()


func _on_close() -> void:
	selected_materials.clear()
	is_processing = false
	progress_bar.visible = false
	GuideSetup.switch_to_menu_context()


## 分类过滤切换
func _on_category_changed(category: CategoryFilter) -> void:
	current_category = category
	_update_category_buttons()
	_update_material_list()


## 更新分类按钮状态
func _update_category_buttons() -> void:
	all_button.button_pressed = current_category == CategoryFilter.ALL
	grain_button.button_pressed = current_category == CategoryFilter.GRAIN
	meat_button.button_pressed = current_category == CategoryFilter.MEAT
	vegetable_button.button_pressed = current_category == CategoryFilter.VEGETABLE
	fruit_button.button_pressed = current_category == CategoryFilter.FRUIT
	dairy_button.button_pressed = current_category == CategoryFilter.DAIRY
	other_button.button_pressed = current_category == CategoryFilter.OTHER


## 设备选择
func _on_equipment_selected(equipment_id: String) -> void:
	current_equipment = DataManager.get_equipment(equipment_id)
	if not current_equipment:
		push_error("[GamePanel] 设备不存在: ", equipment_id)
		return

	stove_button.button_pressed = equipment_id == "stove"
	pot_button.button_pressed = equipment_id == "pot"
	fermenter_button.button_pressed = equipment_id == "fermenter"

	# 显示设备信息
	equipment_info.text = "%s | 最多 %d 种材料 | %.1f 秒" % [
		current_equipment.display_name,
		current_equipment.max_inputs,
		current_equipment.process_time
	]

	selected_materials.clear()
	_update_input_slots()


## 更新材料列表
func _update_material_list() -> void:
	_clear_children(material_grid)

	var all_materials = DataManager.get_all_materials()
	for material in all_materials:
		# 分类过滤
		if current_category != CategoryFilter.ALL:
			var target_category = CATEGORY_MAP.get(current_category, "")
			if target_category.is_empty():
				# "其他" 分类：不属于 grain/meat/vegetable/fruit/dairy
				if material.category in ["grain", "meat", "vegetable", "fruit", "dairy"]:
					continue
			elif material.category != target_category:
				continue

		var card = _create_material_card(material)
		material_grid.add_child(card)


## 安全清空子节点
func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


## 创建材料卡片
func _create_material_card(material: MaterialData) -> Button:
	var card = Button.new()
	card.custom_minimum_size = Vector2(90, 64)
	card.text = material.display_name
	card.tooltip_text = "%s\n%s\n标签: %s" % [
		material.display_name,
		material.description,
		", ".join(material.tags)
	]

	# 卡片样式：分类颜色背景
	var cat_color = CATEGORY_COLORS.get(material.category, Color.GRAY)
	var style = StyleBoxFlat.new()
	style.bg_color = cat_color.darkened(0.65)
	style.border_color = cat_color.darkened(0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	card.add_theme_stylebox_override("normal", style)

	# 悬停样式
	var hover_style = style.duplicate()
	hover_style.bg_color = cat_color.darkened(0.45)
	hover_style.border_color = cat_color
	card.add_theme_stylebox_override("hover", hover_style)

	# 按下样式
	var pressed_style = style.duplicate()
	pressed_style.bg_color = cat_color.darkened(0.3)
	card.add_theme_stylebox_override("pressed", pressed_style)

	# 文字颜色
	var rarity_color = RARITY_COLORS.get(material.rarity, Color.WHITE)
	card.add_theme_color_override("font_color", rarity_color)
	card.add_theme_color_override("font_hover_color", Color.WHITE)
	card.add_theme_font_size_override("font_size", 15)

	# 分类短名作为副标题（通过 tooltip 展示详情）
	card.pressed.connect(_on_material_selected.bind(material.id))

	return card


## 获取分类短名
func _get_category_short_name(category: String) -> String:
	match category:
		"grain": return "谷物"
		"meat": return "肉类"
		"vegetable": return "蔬菜"
		"fruit": return "水果"
		"dairy": return "乳制品"
		"mineral": return "调味"
		"liquid": return "液体"
		"protein": return "蛋白"
		_: return category


## 材料选择
func _on_material_selected(material_id: String) -> void:
	if is_processing:
		return
	if not current_equipment:
		return
	if selected_materials.size() >= current_equipment.max_inputs:
		return

	selected_materials.append(material_id)
	_update_input_slots()


## 更新输入槽显示
func _update_input_slots() -> void:
	input_slot_1.visible = false
	input_slot_2.visible = false
	input_slot_3.visible = false

	if not current_equipment:
		return

	var slots = [input_slot_1, input_slot_2, input_slot_3]
	for i in range(min(current_equipment.max_inputs, slots.size())):
		slots[i].visible = true

		var slot_label = slots[i].find_child("SlotLabel", true, false)
		if slot_label:
			if i < selected_materials.size():
				var material = DataManager.get_material(selected_materials[i])
				if material:
					slot_label.text = material.display_name
					# 设置槽位背景色
					var cat_color = CATEGORY_COLORS.get(material.category, Color.GRAY)
					var style = StyleBoxFlat.new()
					style.bg_color = cat_color.darkened(0.6)
					style.border_color = cat_color
					style.set_border_width_all(2)
					style.set_corner_radius_all(8)
					slots[i].add_theme_stylebox_override("panel", style)
				else:
					slot_label.text = "空"
			else:
				slot_label.text = "空"
				# 默认空槽样式
				var style = StyleBoxFlat.new()
				style.bg_color = Color(0.15, 0.17, 0.22)
				style.border_color = Color(0.30, 0.35, 0.45)
				style.set_border_width_all(2)
				style.set_corner_radius_all(8)
				slots[i].add_theme_stylebox_override("panel", style)


## 开始烹饪
func _on_start_pressed() -> void:
	if is_processing:
		return
	if selected_materials.is_empty():
		return
	if not current_equipment:
		return

	is_processing = true
	start_button.disabled = true
	progress_bar.visible = true
	progress_bar.value = 0

	EventBus.publish(CookingStartedEvent.new(current_equipment.id, selected_materials))

	# 进度条动画
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100.0, current_equipment.process_time)
	await tween.finished

	if not is_instance_valid(self) or not is_processing:
		return

	var result = CookingSystem.start_cooking(current_equipment.id, selected_materials)
	CookingSystem.complete_cooking(result)

	_show_result(result)

	selected_materials.clear()
	_update_input_slots()
	is_processing = false
	start_button.disabled = false
	progress_bar.visible = false


## 显示结果（在结果区域）
func _show_result(result: CookingResult) -> void:
	if not result.success:
		result_label.text = "[center][color=#e74c3c]烹饪失败[/color][/center]"
		return

	var text = ""
	var name_color = "#ffffff"
	if result.is_new_discovery:
		name_color = "#ffd700"
		text += "[center][color=#ffd700]★ 新发现! ★[/color][/center]\n"

	text += "[center][font_size=20][color=%s]%s[/color][/font_size][/center]\n" % [name_color, result.output_material.display_name]

	# 标签
	var tags_text = ", ".join(result.output_tags)
	text += "[center][color=#aaaaaa]标签: %s[/color][/center]\n" % tags_text

	# 配方
	if result.matched_recipe:
		text += "[center]配方: [color=#60d060]%s[/color][/center]" % result.matched_recipe.display_name
	else:
		text += "[center][color=#888888]无匹配配方[/color][/center]"

	result_label.text = text

	# 同时打开结果弹窗
	var result_id := ResourceLocation.from_string("cookery:ui/result")
	UIManager.open_panel(result_id, {"result": result})


## 清空材料
func _on_clear_pressed() -> void:
	if is_processing:
		return
	selected_materials.clear()
	_update_input_slots()


## 更新状态栏
func _update_status_bar() -> void:
	var discovered_materials = DataManager.codex.get_material_count()
	var total_materials = DataManager.get_all_materials().size()
	material_count_label.text = "材料: %d/%d" % [discovered_materials, total_materials]

	var discovered_recipes = DataManager.codex.get_recipe_count()
	var total_recipes = DataManager.get_all_recipes().size()
	recipe_count_label.text = "配方: %d/%d" % [discovered_recipes, total_recipes]


## 打开图鉴
func _on_codex_pressed() -> void:
	var codex_id := ResourceLocation.from_string("cookery:ui/codex")
	UIManager.open_panel(codex_id)


## 打开设置
func _on_settings_pressed() -> void:
	var settings_id := ResourceLocation.from_string("cookery:ui/settings")
	UIManager.open_panel(settings_id)


## 暂停
func _on_pause_pressed() -> void:
	var pause_id := ResourceLocation.from_string("cookery:ui/pause")
	UIManager.open_panel(pause_id)
