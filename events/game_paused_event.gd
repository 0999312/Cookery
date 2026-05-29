## 游戏暂停事件
##
## 当游戏暂停或恢复时触发

extends Event
class_name GamePausedEvent

## 是否暂停
var is_paused: bool


func _init(p_is_paused: bool = false) -> void:
	is_paused = p_is_paused