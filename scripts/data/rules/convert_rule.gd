## 转换规则
##
## 将一个标签转换为另一个标签
## 示例：raw → cooked

extends Resource
class_name ConvertRule

## 原始标签
@export var from_tag: StringName

## 目标标签
@export var to_tag: StringName


## 应用转换规则
func apply(tags: Array[StringName]) -> Array[StringName]:
	var result := tags.duplicate()
	var idx := result.find(from_tag)
	if idx != -1:
		result[idx] = to_tag
	return result


## 检查是否可以应用
func can_apply(tags: Array[StringName]) -> bool:
	return from_tag in tags