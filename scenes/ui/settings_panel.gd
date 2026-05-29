## 设置面板
##
## 游戏设置界面，包含音量控制和显示设置

extends UIPanel

## UI 节点引用
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var sfx_slider: HSlider = %SFXSlider
@onready var sfx_value: Label = %SFXValue
@onready var fullscreen_check: CheckBox = %FullscreenCheck
@onready var back_button: Button = %BackButton

var _signals_connected: bool = false


func _on_init() -> void:
	pass


func _ensure_signals() -> void:
	if _signals_connected:
		return
	_signals_connected = true
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)


func _on_open(data: Dictionary = {}) -> void:
	_ensure_signals()
	_load_settings()


func _on_close() -> void:
	_save_settings()


## 加载设置
func _load_settings() -> void:
	music_slider.value = 80
	sfx_slider.value = 100
	music_value.text = "80"
	sfx_value.text = "100"
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


## 保存设置
func _save_settings() -> void:
	pass


## 音乐音量变化
func _on_music_volume_changed(value: float) -> void:
	var volume := value / 100.0
	SoundManager.set_music_volume(volume)
	music_value.text = "%d" % int(value)


## 音效音量变化
func _on_sfx_volume_changed(value: float) -> void:
	var volume := value / 100.0
	SoundManager.set_sfx_volume(volume)
	sfx_value.text = "%d" % int(value)


## 全屏切换
func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


## 返回按钮
func _on_back_pressed() -> void:
	UIManager.back(UILayer.POPUP)
