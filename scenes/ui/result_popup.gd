## 结果弹窗
##
## 显示烹饪结果的弹窗

extends UIPanel

## 烹饪结果
var cooking_result: CookingResult

## UI 节点引用
@onready var title_label: Label = %TitleLabel
@onready var icon_label: Label = %IconLabel
@onready var name_label: Label = %NameLabel
@onready var tags_label: Label = %TagsLabel
@onready var recipe_label: Label = %RecipeLabel
@onready var discovery_label: Label = %DiscoveryLabel
@onready var confirm_button: Button = %ConfirmButton

var _signals_connected: bool = false


func _on_init() -> void:
	pass


func _ensure_signals() -> void:
	if _signals_connected:
		return
	_signals_connected = true
	confirm_button.pressed.connect(_on_confirm_pressed)


func _on_open(data: Dictionary = {}) -> void:
	_ensure_signals()
	cooking_result = data.get("result")

	if not cooking_result:
		title_label.text = "错误"
		name_label.text = "未提供烹饪结果"
		tags_label.text = ""
		recipe_label.text = ""
		discovery_label.visible = false
		icon_label.text = "!"
		return

	_update_display()
	GuideSetup.switch_to_menu_context()


## 更新显示
func _update_display() -> void:
	if not cooking_result.success:
		title_label.text = "烹饪失败"
		name_label.text = "无法完成烹饪"
		tags_label.text = ""
		recipe_label.text = ""
		discovery_label.visible = false
		icon_label.text = "X"
		icon_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return

	title_label.text = "烹饪完成!"

	if not cooking_result.output_material:
		name_label.text = "未知材料"
		tags_label.text = ""
		recipe_label.text = ""
		discovery_label.visible = false
		icon_label.text = "?"
		return

	# 图标
	if cooking_result.is_new_discovery:
		icon_label.text = "★"
		icon_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	else:
		icon_label.text = "✓"
		icon_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))

	# 名称
	name_label.text = cooking_result.output_material.display_name

	# 标签
	var tags_text = ", ".join(cooking_result.output_tags)
	tags_label.text = "标签: " + tags_text

	# 配方
	if cooking_result.matched_recipe:
		recipe_label.text = "配方: " + cooking_result.matched_recipe.display_name
	else:
		recipe_label.text = "配方: 无匹配"

	# 发现
	if cooking_result.is_new_discovery:
		discovery_label.text = "★ 新发现! ★"
		discovery_label.visible = true
		# 发现动画
		discovery_label.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(discovery_label, "modulate", Color(1, 1, 1, 1), 0.5)
	else:
		discovery_label.visible = false


## 确认按钮
func _on_confirm_pressed() -> void:
	UIManager.back(UILayer.POPUP)
