## 暂停菜单
##
## 弹窗式暂停菜单

extends UIPanel

## UI 节点引用
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

var _signals_connected: bool = false


func _on_init() -> void:
	pass


func _ensure_signals() -> void:
	if _signals_connected:
		return
	_signals_connected = true
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_open(data: Dictionary = {}) -> void:
	_ensure_signals()
	EventBus.publish(GamePausedEvent.new(true))
	GuideSetup.switch_to_menu_context()


func _on_close() -> void:
	# 发布恢复事件
	EventBus.publish(GamePausedEvent.new(false))


## 继续游戏
func _on_continue_pressed() -> void:
	UIManager.back(UILayer.POPUP)


## 打开设置
func _on_settings_pressed() -> void:
	var settings_id := ResourceLocation.from_string("cookery:ui/settings")
	UIManager.open_panel(settings_id)


## 返回主菜单
func _on_main_menu_pressed() -> void:
	# 先保存场景树引用（close_all 会将本节点从树中移除）
	var tree := get_tree()
	# 关闭所有面板并完全清理 UIManager 状态
	UIManager.close_all()
	UIManager.clear_for_scene_change()
	# 恢复输入上下文
	GuideSetup.switch_to_menu_context()
	# 切换场景
	tree.change_scene_to_file("res://scenes/screens/main_menu.tscn")


## 退出游戏
func _on_quit_pressed() -> void:
	get_tree().quit()