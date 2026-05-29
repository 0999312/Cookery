## UI 初始化
##
## 注册所有面板到 UIRegistry

extends Node


func _ready() -> void:
	_register_panels()


func _register_panels() -> void:
	var ui_registry = RegistryManager.get_registry("ui")
	if not ui_registry:
		ui_registry = UIRegistry.new()
		RegistryManager.register_registry("ui", ui_registry)

	# 注册游戏主界面（不缓存，返回主菜单时需要完全销毁）
	ui_registry.register_panel(
		ResourceLocation.from_string("cookery:ui/game"),
		preload("res://scenes/ui/game_panel.tscn"),
		UILayer.NORMAL,
		UIPanel.CacheMode.NONE
	)

	# 注册图鉴界面
	ui_registry.register_panel(
		ResourceLocation.from_string("cookery:ui/codex"),
		preload("res://scenes/ui/codex_panel.tscn"),
		UILayer.NORMAL,
		UIPanel.CacheMode.CACHE
	)

	# 注册结果弹窗
	ui_registry.register_panel(
		ResourceLocation.from_string("cookery:ui/result"),
		preload("res://scenes/ui/result_popup.tscn"),
		UILayer.POPUP,
		UIPanel.CacheMode.NONE
	)

	# 注册暂停菜单
	ui_registry.register_panel(
		ResourceLocation.from_string("cookery:ui/pause"),
		preload("res://scenes/ui/pause_menu.tscn"),
		UILayer.POPUP,
		UIPanel.CacheMode.NONE
	)

	# 注册设置面板
	ui_registry.register_panel(
		ResourceLocation.from_string("cookery:ui/settings"),
		preload("res://scenes/ui/settings_panel.tscn"),
		UILayer.POPUP,
		UIPanel.CacheMode.NONE
	)

	print("[UISetup] 面板注册完成")