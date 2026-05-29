## 主菜单场景
##
## 游戏的入口场景，提供开始游戏、继续游戏、设置、退出等选项

extends Control

## UI 节点引用
@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	# 设置版本号
	version_label.text = "v" + ProjectSettings.get_setting("application/config/version", "1.0.0")

	# 检查是否有存档
	continue_button.disabled = not SaveManager.save_exists(0)

	# 连接按钮信号
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# 确保菜单上下文启用
	GuideSetup.switch_to_menu_context()

	# 确保主菜单可见（从游戏返回时可能被隐藏）
	visible = true


## 开始新游戏
func _on_start_pressed() -> void:
	EventBus.publish(GameStartedEvent.new())
	SaveManager.save_game(0)
	_open_game_panel()


## 继续游戏
func _on_continue_pressed() -> void:
	var success := SaveManager.load_game(0)
	if not success:
		push_error("[MainMenu] 加载存档失败")
		return
	_open_game_panel()


## 通过 UIManager 打开游戏面板
func _open_game_panel() -> void:
	var game_id := ResourceLocation.from_string("cookery:ui/game")
	UIManager.open_panel(game_id)
	# 隐藏主菜单（UIManager 会管理游戏面板的显示）
	visible = false


## 打开设置
func _on_settings_pressed() -> void:
	var settings_id := ResourceLocation.from_string("cookery:ui/settings")
	UIManager.open_panel(settings_id)


## 退出游戏
func _on_quit_pressed() -> void:
	get_tree().quit()