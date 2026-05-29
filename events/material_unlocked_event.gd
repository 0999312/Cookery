## 材料解锁事件
##
## 当玩家解锁新材料时触发

extends Event
class_name MaterialUnlockedEvent

## 解锁的材料
var material: MaterialData


func _init(p_material: MaterialData = null) -> void:
	material = p_material