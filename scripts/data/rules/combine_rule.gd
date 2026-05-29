## 组合规则
##
## 将多个标签组合为一个新标签
## 示例：water + fire → steam

extends Resource
class_name CombineRule

## 需要的标签组合
@export var required_tags: Array[StringName]

## 结果标签
@export var result_tag: StringName

## 是否消耗输入标签
@export var consume_inputs: bool = false


## 检查是否可以应用
func can_apply(tags: Array[StringName]) -> bool:
	for tag in required_tags:
		if tag not in tags:
			return false
	return true


## 应用组合规则
func apply(tags: Array[StringName]) -> Array[StringName]:
	var result := tags.duplicate()

	# 如果需要消耗输入，移除所需标签
	if consume_inputs:
		for tag in required_tags:
			result.erase(tag)

	# 添加结果标签
	result.append(result_tag)
	return result