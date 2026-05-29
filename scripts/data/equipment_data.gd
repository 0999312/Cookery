## 设备数据
##
## 定义游戏中所有设备的属性和变换规则
## 注意：transform_rules 不通过 Codec 序列化，由 DataManager 在加载时程序化设置

extends CodecResource
class_name EquipmentData

## 唯一标识符
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 描述
@export var description: String = ""

## 图标路径
@export var icon_path: String = ""

## 最大输入槽数量
@export var max_inputs: int = 1

## 加工时间（秒）
@export var process_time: float = 1.0

## 变换规则列表（ConvertRule, CombineRule, RemoveRule, AmplifyRule）
## 由 DataManager 在加载时程序化设置，不通过 Codec 序列化
var transform_rules: Array[Resource] = []


## 获取类型 ID
static func get_type_id() -> String:
	return "cookery:equipment"


## 获取 Codec（仅序列化基础属性，transform_rules 由 DataManager 程序化设置）
static func get_codec() -> Codec:
	return MapCodec.build([
		Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
		Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name),
		Codec.STRING().optional_field_of("description", "").for_getter(func(obj): return obj.description),
		Codec.STRING().optional_field_of("icon_path", "").for_getter(func(obj): return obj.icon_path),
		Codec.INT().optional_field_of("max_inputs", 1).for_getter(func(obj): return obj.max_inputs),
		Codec.FLOAT().optional_field_of("process_time", 1.0).for_getter(func(obj): return obj.process_time),
	], func(id, display_name, description, icon_path, max_inputs, process_time):
		var equip = EquipmentData.new()
		equip.id = id
		equip.display_name = display_name
		equip.description = description
		equip.icon_path = icon_path
		equip.max_inputs = max_inputs
		equip.process_time = process_time
		return equip
	).codec()


## 应用所有变换规则
func apply_transforms(tags: Array[StringName]) -> Array[StringName]:
	var result := tags.duplicate()

	for rule in transform_rules:
		if rule is ConvertRule:
			result = rule.apply(result)
		elif rule is CombineRule:
			if rule.can_apply(result):
				result = rule.apply(result)
		elif rule is RemoveRule:
			result = rule.apply(result)
		elif rule is AmplifyRule:
			result = rule.apply(result)

	return result


## 获取 ResourceLocation
func get_resource_location() -> ResourceLocation:
	return ResourceLocation.from_string("cookery:equipment/" + id)