## 图鉴界面
##
## 标签分类 + 网格卡片 + 详情弹窗

extends UIPanel

## 过滤类型
enum FilterType { ALL, MATERIAL, RECIPE, EQUIPMENT }

## 分类颜色
const CATEGORY_COLORS := {
	"grain": Color(0.96, 0.85, 0.56),
	"meat": Color(0.91, 0.40, 0.35),
	"vegetable": Color(0.55, 0.80, 0.45),
	"fruit": Color(0.98, 0.65, 0.30),
	"dairy": Color(0.60, 0.80, 0.95),
	"mineral": Color(0.75, 0.75, 0.75),
	"liquid": Color(0.40, 0.70, 0.90),
	"protein": Color(0.85, 0.65, 0.45),
}

## 当前过滤
var current_filter: FilterType = FilterType.ALL

## 搜索文本
var search_text: String = ""

## 搜索防抖
var _search_timer: float = 0.0
var _search_dirty: bool = false
const SEARCH_DELAY := 0.3

## UI 节点引用
@onready var back_button: Button = %BackButton
@onready var count_label: Label = %CountLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_percent: Label = %ProgressPercent
@onready var all_button: Button = %AllButton
@onready var material_button: Button = %MaterialButton
@onready var recipe_button: Button = %RecipeButton
@onready var equipment_button: Button = %EquipmentButton
@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var grid_container: GridContainer = %GridContainer

## 详情面板
@onready var detail_panel: PanelContainer = %DetailPanel
@onready var detail_title: Label = %DetailTitle
@onready var detail_content: RichTextLabel = %DetailContent
@onready var close_button: Button = %CloseButton

## 信号是否已连接
var _signals_connected: bool = false


func _on_init() -> void:
	# _on_init() 在 add_child() 之前调用，@onready 变量还未解析
	pass


## 确保信号已连接
func _ensure_signals() -> void:
	if _signals_connected:
		return
	_signals_connected = true

	back_button.pressed.connect(_on_back_pressed)
	all_button.pressed.connect(_on_filter_changed.bind(FilterType.ALL))
	material_button.pressed.connect(_on_filter_changed.bind(FilterType.MATERIAL))
	recipe_button.pressed.connect(_on_filter_changed.bind(FilterType.RECIPE))
	equipment_button.pressed.connect(_on_filter_changed.bind(FilterType.EQUIPMENT))
	search_line_edit.text_changed.connect(_on_search_changed)
	close_button.pressed.connect(_on_detail_closed)

	# 点击背景关闭详情
	var bg = detail_panel.get_node("Background")
	if bg:
		bg.gui_input.connect(_on_detail_bg_input)


func _on_open(data: Dictionary = {}) -> void:
	_ensure_signals()
	_update_grid()
	_update_progress()
	detail_panel.visible = false
	GuideSetup.switch_to_menu_context()


func _on_close() -> void:
	detail_panel.visible = false
	GuideSetup.switch_to_menu_context()


func _process(delta: float) -> void:
	if _search_dirty:
		_search_timer += delta
		if _search_timer >= SEARCH_DELAY:
			_search_dirty = false
			_search_timer = 0.0
			_update_grid()


## 过滤切换
func _on_filter_changed(filter: FilterType) -> void:
	current_filter = filter
	all_button.button_pressed = filter == FilterType.ALL
	material_button.button_pressed = filter == FilterType.MATERIAL
	recipe_button.button_pressed = filter == FilterType.RECIPE
	equipment_button.button_pressed = filter == FilterType.EQUIPMENT
	_update_grid()


## 搜索变化
func _on_search_changed(text: String) -> void:
	search_text = text
	_search_dirty = true
	_search_timer = 0.0


## 更新进度条
func _update_progress() -> void:
	var total = DataManager.get_all_materials().size() + DataManager.get_all_recipes().size() + DataManager.get_all_equipment().size()
	var discovered = DataManager.codex.discovery_count
	var percent = 0.0 if total == 0 else (discovered as float / total as float * 100.0)

	progress_bar.value = percent
	progress_percent.text = "%d%%" % int(percent)
	count_label.text = "已发现: %d / %d" % [discovered, total]


## 更新网格
func _update_grid() -> void:
	_clear_children(grid_container)
	var items = _get_filtered_items()
	for item in items:
		var card = _create_card(item)
		grid_container.add_child(card)


## 安全清空子节点
func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


## 获取过滤后的数据
func _get_filtered_items() -> Array:
	var items: Array = []

	match current_filter:
		FilterType.ALL:
			items.append_array(DataManager.get_discovered_materials())
			items.append_array(DataManager.get_discovered_recipes())
			items.append_array(DataManager.get_discovered_equipment())
		FilterType.MATERIAL:
			items = DataManager.get_discovered_materials()
		FilterType.RECIPE:
			items = DataManager.get_discovered_recipes()
		FilterType.EQUIPMENT:
			items = DataManager.get_discovered_equipment()

	if not search_text.is_empty():
		items = items.filter(func(item): return item.display_name.contains(search_text))

	return items


## 创建卡片
func _create_card(item: Variant) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(100, 80)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	# 类型标签
	var type_label = Label.new()
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_font_size_override("font_size", 11)

	# 名称
	var name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color.WHITE)

	# 描述预览
	var desc_label = Label.new()
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.max_lines_visible = 2
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	if item is MaterialData:
		type_label.text = "材料"
		type_label.add_theme_color_override("font_color", Color(0.60, 0.80, 0.95))
		name_label.text = item.display_name
		desc_label.text = item.description
		var style = StyleBoxFlat.new()
		var cat_color = CATEGORY_COLORS.get(item.category, Color.GRAY)
		style.bg_color = cat_color.darkened(0.7)
		style.border_color = cat_color.darkened(0.3)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		card.add_theme_stylebox_override("panel", style)
	elif item is RecipeData:
		type_label.text = "配方"
		type_label.add_theme_color_override("font_color", Color(0.60, 0.90, 0.60))
		name_label.text = item.display_name
		desc_label.text = item.description
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.18, 0.25, 0.18)
		style.border_color = Color(0.35, 0.55, 0.35)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		card.add_theme_stylebox_override("panel", style)
	elif item is EquipmentData:
		type_label.text = "设备"
		type_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.50))
		name_label.text = item.display_name
		desc_label.text = item.description
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.25, 0.22, 0.15)
		style.border_color = Color(0.55, 0.45, 0.25)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		card.add_theme_stylebox_override("panel", style)

	vbox.add_child(type_label)
	vbox.add_child(name_label)
	vbox.add_child(desc_label)
	card.add_child(vbox)

	# 点击事件
	card.gui_input.connect(_on_card_input.bind(item))

	return card


## 卡片点击
func _on_card_input(event: InputEvent, item: Variant) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_detail(item)


## 显示详情
func _show_detail(item: Variant) -> void:
	var title = ""
	var content = ""

	if item is MaterialData:
		title = item.display_name
		content = "[color=#99bbdd]类型: 材料[/color]\n\n"
		content += item.description + "\n\n"
		content += "分类: %s\n" % _get_category_name(item.category)
		content += "稀有度: %s\n" % _get_rarity_name(item.rarity)
		content += "标签: [color=#cccccc]%s[/color]\n" % ", ".join(item.tags)
	elif item is RecipeData:
		title = item.display_name
		content = "[color=#99dd99]类型: 配方[/color]\n\n"
		content += item.description + "\n\n"
		content += "需要标签: [color=#cccccc]%s[/color]\n" % ", ".join(item.required_tags)
		if not item.required_equipment.is_empty():
			content += "需要设备: %s\n" % item.required_equipment
		else:
			content += "需要设备: 任意\n"
		content += "产出: %s\n" % item.result_material
	elif item is EquipmentData:
		title = item.display_name
		content = "[color=#ddcc88]类型: 设备[/color]\n\n"
		content += item.description + "\n\n"
		content += "最大输入: %d\n" % item.max_inputs
		content += "处理时间: %.1f 秒\n" % item.process_time

	detail_title.text = title
	detail_content.text = content
	detail_panel.visible = true


## 关闭详情
func _on_detail_closed() -> void:
	detail_panel.visible = false


## 点击背景关闭
func _on_detail_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		detail_panel.visible = false


## 获取分类名
func _get_category_name(category: String) -> String:
	match category:
		"grain": return "谷物"
		"meat": return "肉类"
		"vegetable": return "蔬菜"
		"fruit": return "水果"
		"dairy": return "乳制品"
		"mineral": return "调味料"
		"liquid": return "液体"
		"protein": return "蛋白质"
		_: return category


## 获取稀有度名
func _get_rarity_name(rarity: int) -> String:
	match rarity:
		0: return "普通"
		1: return "[color=#99ccff]稀有[/color]"
		2: return "[color=#ffd700]传说[/color]"
		_: return "未知"


## 更新计数
func _update_count() -> void:
	_update_progress()


## 返回
func _on_back_pressed() -> void:
	UIManager.back()
