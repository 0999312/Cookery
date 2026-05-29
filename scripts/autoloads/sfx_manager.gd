## 音效管理器
##
## 管理 UI 音效播放

extends Node

## 音效路径常量
const SFX_CLICK := "res://assets/audio/sfx/ui_click.ogg"
const SFX_COOKING_START := "res://assets/audio/sfx/cooking_start.ogg"
const SFX_COOKING_COMPLETE := "res://assets/audio/sfx/cooking_complete.ogg"
const SFX_DISCOVERY := "res://assets/audio/sfx/discovery.ogg"
const SFX_ERROR := "res://assets/audio/sfx/error.ogg"


func _ready() -> void:
	_connect_events()


## 连接 EventBus 事件
func _connect_events() -> void:
	EventBus.subscribe(&"CookingStartedEvent", _on_cooking_started)
	EventBus.subscribe(&"CookingCompletedEvent", _on_cooking_completed)
	EventBus.subscribe(&"RecipeDiscoveredEvent", _on_recipe_discovered)
	EventBus.subscribe(&"MaterialUnlockedEvent", _on_material_unlocked)


## 播放点击音效
func play_click() -> void:
	_play_sfx(SFX_CLICK)


## 播放烹饪开始音效
func play_cooking_start() -> void:
	_play_sfx(SFX_COOKING_START)


## 播放烹饪完成音效
func play_cooking_complete() -> void:
	_play_sfx(SFX_COOKING_COMPLETE)


## 播放发现音效
func play_discovery() -> void:
	_play_sfx(SFX_DISCOVERY)


## 播放错误音效
func play_error() -> void:
	_play_sfx(SFX_ERROR)


## 内部播放方法
func _play_sfx(path: String) -> void:
	# 检查文件是否存在
	if not ResourceLoader.exists(path):
		# 音效文件不存在，跳过播放
		return

	SoundManager.play_sfx(path)


## 事件回调：烹饪开始
func _on_cooking_started(event: CookingStartedEvent) -> void:
	play_cooking_start()


## 事件回调：烹饪完成
func _on_cooking_completed(event: CookingCompletedEvent) -> void:
	play_cooking_complete()


## 事件回调：配方发现
func _on_recipe_discovered(event: RecipeDiscoveredEvent) -> void:
	play_discovery()


## 事件回调：材料解锁
func _on_material_unlocked(event: MaterialUnlockedEvent) -> void:
	play_discovery()