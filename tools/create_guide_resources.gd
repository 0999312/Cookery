## GUIDE 资源生成脚本
##
## 运行此脚本可自动创建所有 GUIDE Action 和 MappingContext 资源

extends SceneTree

## Action 定义
const ACTIONS := {
	"confirm": {
		"name": &"confirm",
		"value_type": 0,  # BOOL
		"keys": [KEY_ENTER, KEY_SPACE]
	},
	"cancel": {
		"name": &"cancel",
		"value_type": 0,
		"keys": [KEY_ESCAPE]
	},
	"navigate_up": {
		"name": &"navigate_up",
		"value_type": 0,
		"keys": [KEY_W, KEY_UP]
	},
	"navigate_down": {
		"name": &"navigate_down",
		"value_type": 0,
		"keys": [KEY_S, KEY_DOWN]
	},
	"navigate_left": {
		"name": &"navigate_left",
		"value_type": 0,
		"keys": [KEY_A, KEY_LEFT]
	},
	"navigate_right": {
		"name": &"navigate_right",
		"value_type": 0,
		"keys": [KEY_D, KEY_RIGHT]
	},
	"interact": {
		"name": &"interact",
		"value_type": 0,
		"keys": [KEY_E]
	},
	"pause": {
		"name": &"pause",
		"value_type": 0,
		"keys": [KEY_ESCAPE]
	},
	"inventory": {
		"name": &"inventory",
		"value_type": 0,
		"keys": [KEY_TAB]
	}
}

## 上下文定义
const CONTEXTS := {
	"menu": {
		"display_name": "菜单上下文",
		"actions": ["confirm", "cancel", "navigate_up", "navigate_down", "navigate_left", "navigate_right"]
	},
	"game": {
		"display_name": "游戏上下文",
		"actions": ["interact", "pause", "inventory", "navigate_up", "navigate_down", "navigate_left", "navigate_right"]
	},
	"equipment": {
		"display_name": "设备上下文",
		"actions": ["confirm", "cancel", "interact"]
	}
}


func _init() -> void:
	print("开始创建 GUIDE 资源...")

	# 创建目录
	DirAccess.make_dir_recursive_absolute("res://input/actions")
	DirAccess.make_dir_recursive_absolute("res://input/contexts")

	# 创建 Action 资源
	for action_id in ACTIONS:
		_create_action(action_id, ACTIONS[action_id])

	# 创建 MappingContext 资源
	for context_id in CONTEXTS:
		_create_context(context_id, CONTEXTS[context_id])

	print("GUIDE 资源创建完成！")
	quit()


## 创建 Action 资源
func _create_action(id: String, data: Dictionary) -> void:
	var action = GUIDEAction.new()
	action.name = data.name
	action.action_value_type = data.value_type as GUIDEAction.GUIDEActionValueType

	# 创建映射
	var mappings: Array[GUIDEActionMapping] = []
	for key in data.keys:
		var mapping = GUIDEActionMapping.new()

		# 创建输入
		var input = GUIDEInputKey.new()
		input.key = key

		# 创建触发器
		var trigger = GUIDETriggerDown.new()

		mapping.input = input
		mapping.trigger = trigger
		mappings.append(action)

	action.action_mappings = mappings

	# 保存资源
	var path = "res://input/actions/%s_action.tres" % id
	var error = ResourceSaver.save(action, path)
	if error == OK:
		print("  创建 Action: ", path)
	else:
		push_error("  创建 Action 失败: %s (错误: %d)" % [path, error])


## 创建 MappingContext 资源
func _create_context(id: String, data: Dictionary) -> void:
	var context = GUIDEMappingContext.new()
	context.display_name = data.display_name

	# 加载 Action 并创建映射
	var mappings: Array[GUIDEActionMapping] = []
	for action_id in data.actions:
		var action_path = "res://input/actions/%s_action.tres" % action_id
		var action = load(action_path) as GUIDEAction
		if action:
			# 创建 ActionMapping
			var action_mapping = GUIDEActionMapping.new()
			action_mapping.action = action
			mappings.append(action_mapping)

	context.mappings = mappings

	# 保存资源
	var path = "res://input/contexts/%s_context.tres" % id
	var error = ResourceSaver.save(context, path)
	if error == OK:
		print("  创建 Context: ", path)
	else:
		push_error("  创建 Context 失败: %s (错误: %d)" % [path, error])