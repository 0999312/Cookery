## 存档管理器
##
## 使用 JSON 管理游戏存档

extends Node

## 存档目录
const SAVE_DIR := "user://saves"

## 最大存档槽位
const MAX_SLOTS := 3

## 自动保存延迟（秒）
const AUTO_SAVE_DELAY := 1.0

## 当前存档数据
var current_save: Dictionary = {}

## 自动保存开关
var auto_save_enabled: bool = true

## 自动保存脏标志
var _auto_save_dirty: bool = false

## 自动保存计时器
var _auto_save_timer: float = 0.0


func _ready() -> void:
	# 确保存档目录存在
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	# 初始化当前存档
	current_save = _create_default_save()

	# 连接事件
	_connect_events()


func _process(delta: float) -> void:
	# 自动保存防抖逻辑
	if _auto_save_dirty:
		_auto_save_timer += delta
		if _auto_save_timer >= AUTO_SAVE_DELAY:
			_auto_save_dirty = false
			_auto_save_timer = 0.0
			_do_auto_save()


## 创建默认存档数据
func _create_default_save() -> Dictionary:
	return {
		"version": "1.0.0",
		"timestamp": Time.get_unix_time_from_system(),
		"play_time": 0.0,
		"discovered_materials": [],
		"discovered_recipes": [],
		"discovered_equipment": [],
		"settings": {}
	}


## 连接 EventBus 事件
func _connect_events() -> void:
	EventBus.subscribe(&"CookingCompletedEvent", _on_cooking_completed)
	EventBus.subscribe(&"RecipeDiscoveredEvent", _on_recipe_discovered)
	EventBus.subscribe(&"MaterialUnlockedEvent", _on_material_unlocked)


## 保存游戏
func save_game(slot: int) -> bool:
	# 边界检查
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("[SaveManager] 无效的存档槽位: %d" % slot)
		return false

	var path := _get_save_path(slot)

	# 更新存档数据
	current_save["timestamp"] = Time.get_unix_time_from_system()

	# 从图鉴更新存档
	current_save["discovered_materials"] = _get_discovered_ids(DataManager.codex.discovered_materials)
	current_save["discovered_recipes"] = _get_discovered_ids(DataManager.codex.discovered_recipes)
	current_save["discovered_equipment"] = _get_discovered_ids(DataManager.codex.discovered_equipment)

	# 写入 JSON 文件
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("[SaveManager] 存档失败: %s (错误: %d)" % [path, FileAccess.get_open_error()])
		EventBus.publish(SaveCompletedEvent.new(slot, false))
		return false

	file.store_string(JSON.stringify(current_save, "\t"))
	file.close()

	print("[SaveManager] 存档成功: %s" % path)
	EventBus.publish(SaveCompletedEvent.new(slot, true))
	return true


## 获取已发现 ID 列表
func _get_discovered_ids(dict: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for key in dict.keys():
		ids.append(key)
	return ids


## 加载游戏
func load_game(slot: int) -> bool:
	# 边界检查
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("[SaveManager] 无效的存档槽位: %d" % slot)
		return false

	var path := _get_save_path(slot)

	# 检查文件是否存在
	if not FileAccess.file_exists(path):
		push_warning("[SaveManager] 存档文件不存在: %s" % path)
		EventBus.publish(LoadCompletedEvent.new(slot, false))
		return false

	# 读取文件
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[SaveManager] 读档失败: %s" % path)
		EventBus.publish(LoadCompletedEvent.new(slot, false))
		return false

	var json_string := file.get_as_text()
	file.close()

	# 解析 JSON
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("[SaveManager] JSON 解析失败: %s" % json.get_error_message())
		EventBus.publish(LoadCompletedEvent.new(slot, false))
		return false

	current_save = json.data

	# 应用存档数据到图鉴
	_apply_to_codex()

	print("[SaveManager] 读档成功: %s" % path)
	EventBus.publish(LoadCompletedEvent.new(slot, true))
	return true


## 应用存档数据到图鉴
func _apply_to_codex() -> void:
	# 恢复已发现材料
	for material_id in current_save.get("discovered_materials", []):
		var material = DataManager.get_material(material_id)
		if material:
			DataManager.codex.discover_material(material)

	# 恢复已发现配方
	for recipe_id in current_save.get("discovered_recipes", []):
		var recipe = DataManager.get_recipe(recipe_id)
		if recipe:
			DataManager.codex.discover_recipe(recipe)

	# 恢复已发现设备
	for equipment_id in current_save.get("discovered_equipment", []):
		var equipment = DataManager.get_equipment(equipment_id)
		if equipment:
			DataManager.codex.discover_equipment(equipment)


## 删除存档
func delete_save(slot: int) -> bool:
	# 边界检查
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("[SaveManager] 无效的存档槽位: %d" % slot)
		return false

	var path := _get_save_path(slot)

	if not FileAccess.file_exists(path):
		push_warning("[SaveManager] 存档文件不存在: %s" % path)
		return false

	var error := DirAccess.remove_absolute(path)
	if error != OK:
		push_error("[SaveManager] 删除存档失败: %s" % path)
		return false

	print("[SaveManager] 删除存档成功: %s" % path)
	return true


## 检查存档是否存在
func save_exists(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		return false
	return FileAccess.file_exists(_get_save_path(slot))


## 标记需要自动保存（防抖）
func mark_dirty() -> void:
	if auto_save_enabled:
		_auto_save_dirty = true
		_auto_save_timer = 0.0


## 执行自动保存
func _do_auto_save() -> void:
	save_game(0)


## 获取存档路径
func _get_save_path(slot: int) -> String:
	return "%s/save_%d.json" % [SAVE_DIR, slot]


## 事件回调：烹饪完成
func _on_cooking_completed(_event: CookingCompletedEvent) -> void:
	mark_dirty()


## 事件回调：配方发现
func _on_recipe_discovered(_event: RecipeDiscoveredEvent) -> void:
	mark_dirty()


## 事件回调：材料解锁
func _on_material_unlocked(_event: MaterialUnlockedEvent) -> void:
	mark_dirty()