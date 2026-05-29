## 场景切换事件
##
## 当场景切换时触发

extends Event
class_name SceneChangedEvent

## 场景路径
var scene_path: String


func _init(p_scene_path: String = "") -> void:
	scene_path = p_scene_path