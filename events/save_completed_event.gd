## 存档完成事件
##
## 当存档操作完成时触发

extends Event
class_name SaveCompletedEvent

## 存档槽位
var slot: int

## 是否成功
var success: bool


func _init(p_slot: int = 0, p_success: bool = true) -> void:
	slot = p_slot
	success = p_success