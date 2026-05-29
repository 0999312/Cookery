## GUIDE 输入系统初始化
##
## 在游戏启动时创建和配置 GUIDE Actions 和 MappingContexts

extends Node

## Action 名称常量
const ACTION_CONFIRM := &"confirm"
const ACTION_CANCEL := &"cancel"
const ACTION_NAVIGATE_UP := &"navigate_up"
const ACTION_NAVIGATE_DOWN := &"navigate_down"
const ACTION_NAVIGATE_LEFT := &"navigate_left"
const ACTION_NAVIGATE_RIGHT := &"navigate_right"
const ACTION_INTERACT := &"interact"
const ACTION_PAUSE := &"pause"
const ACTION_INVENTORY := &"inventory"

## 上下文资源
var menu_context: GUIDEMappingContext
var game_context: GUIDEMappingContext
var equipment_context: GUIDEMappingContext


func _ready() -> void:
	print("[GUIDE] 初始化输入系统...")
	_create_contexts()
	_enable_menu_context()
	print("[GUIDE] 输入系统初始化完成")


## 创建包含 action 和 input_mapping 的 ActionMapping
func _create_action_mapping(action_name: StringName, keys: Array[int]) -> GUIDEActionMapping:
	# 创建 Action
	var action := GUIDEAction.new()
	action.name = action_name
	action.action_value_type = GUIDEAction.GUIDEActionValueType.BOOL

	# 创建输入映射（每个按键一个映射）
	var input_mappings: Array[GUIDEInputMapping] = []
	for key in keys:
		var mapping := GUIDEInputMapping.new()

		# 创建键盘输入
		var key_input := GUIDEInputKey.new()
		key_input.key = key
		mapping.input = key_input

		# 创建按下触发器（默认触发器，留空即可）
		# GUIDEInputMapping 会在 triggers 为空时自动创建默认的 GUIDETriggerDown

		input_mappings.append(mapping)

	# 创建 ActionMapping
	var action_mapping := GUIDEActionMapping.new()
	action_mapping.action = action
	action_mapping.input_mappings = input_mappings

	return action_mapping


## 创建所有 MappingContext
func _create_contexts() -> void:
	menu_context = _create_context("菜单上下文", {
		ACTION_CONFIRM: [KEY_ENTER, KEY_SPACE],
		ACTION_CANCEL: [KEY_ESCAPE],
		ACTION_NAVIGATE_UP: [KEY_W, KEY_UP],
		ACTION_NAVIGATE_DOWN: [KEY_S, KEY_DOWN],
		ACTION_NAVIGATE_LEFT: [KEY_A, KEY_LEFT],
		ACTION_NAVIGATE_RIGHT: [KEY_D, KEY_RIGHT],
	})

	game_context = _create_context("游戏上下文", {
		ACTION_INTERACT: [KEY_E],
		ACTION_PAUSE: [KEY_P],  # 使用 P 键，避免与 CANCEL 冲突
		ACTION_INVENTORY: [KEY_TAB],
		ACTION_NAVIGATE_UP: [KEY_W, KEY_UP],
		ACTION_NAVIGATE_DOWN: [KEY_S, KEY_DOWN],
		ACTION_NAVIGATE_LEFT: [KEY_A, KEY_LEFT],
		ACTION_NAVIGATE_RIGHT: [KEY_D, KEY_RIGHT],
	})

	equipment_context = _create_context("设备上下文", {
		ACTION_CONFIRM: [KEY_ENTER, KEY_SPACE],
		ACTION_CANCEL: [KEY_ESCAPE],
		ACTION_INTERACT: [KEY_E],
	})


## 创建单个 MappingContext
func _create_context(display_name: String, action_keys: Dictionary) -> GUIDEMappingContext:
	var context := GUIDEMappingContext.new()
	context.display_name = display_name

	var mappings: Array[GUIDEActionMapping] = []
	for action_name in action_keys:
		# 从字典获取按键数组并转换为 Array[int]
		var raw_keys: Array = action_keys[action_name]
		var keys: Array[int] = []
		for k in raw_keys:
			keys.append(k)
		var mapping := _create_action_mapping(action_name, keys)
		mappings.append(mapping)

	context.mappings = mappings
	return context


## 启用菜单上下文
func _enable_menu_context() -> void:
	if menu_context:
		GUIDE.enable_mapping_context(menu_context)
		print("[GUIDE] 启用菜单上下文")


## 切换到游戏上下文
func switch_to_game_context() -> void:
	GUIDE.disable_mapping_context(menu_context)
	GUIDE.disable_mapping_context(equipment_context)
	GUIDE.enable_mapping_context(game_context)
	print("[GUIDE] 切换到游戏上下文")


## 切换到菜单上下文
func switch_to_menu_context() -> void:
	GUIDE.disable_mapping_context(game_context)
	GUIDE.disable_mapping_context(equipment_context)
	GUIDE.enable_mapping_context(menu_context)
	print("[GUIDE] 切换到菜单上下文")


## 切换到设备上下文
func switch_to_equipment_context() -> void:
	GUIDE.disable_mapping_context(game_context)
	GUIDE.disable_mapping_context(menu_context)
	GUIDE.enable_mapping_context(equipment_context)
	print("[GUIDE] 切换到设备上下文")