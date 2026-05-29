## 烹饪完成事件
##
## 当烹饪处理完成时触发

extends Event
class_name CookingCompletedEvent

## 烹饪结果
var result: CookingResult


func _init(p_result: CookingResult = null) -> void:
	result = p_result