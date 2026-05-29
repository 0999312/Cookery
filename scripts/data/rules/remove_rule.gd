## 消除规则
##
## 移除指定标签
## 示例：移除 raw 标签

extends Resource
class_name RemoveRule

## 要移除的标签
@export var tag: StringName


## 检查是否可以应用
func can_apply(tags: Array[StringName]) -> bool:
	return tag in tags


## 应用消除规则
func apply(tags: Array[StringName]) -> Array[StringName]:
	var result := tags.duplicate()
	result.erase(tag)
	return result