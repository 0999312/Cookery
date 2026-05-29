## 增幅规则
##
## 当存在指定标签时，添加新标签
## 示例：存在 heat 时添加 crispy

extends Resource
class_name AmplifyRule

## 要检查的标签
@export var tag: StringName

## 增幅后添加的标签
@export var add_tag: StringName


## 检查是否可以应用
func can_apply(tags: Array[StringName]) -> bool:
	return tag in tags


## 应用增幅规则
func apply(tags: Array[StringName]) -> Array[StringName]:
	var result := tags.duplicate()
	if tag in result:
		result.append(add_tag)
	return result