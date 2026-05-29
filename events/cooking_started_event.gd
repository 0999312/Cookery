## 烹饪开始事件
##
## 当玩家开始烹饪时触发

extends Event
class_name CookingStartedEvent

## 设备 ID
var equipment_id: String

## 材料 ID 列表
var material_ids: Array[String]


func _init(p_equipment_id: String = "", p_material_ids: Array[String] = []) -> void:
	equipment_id = p_equipment_id
	material_ids = p_material_ids