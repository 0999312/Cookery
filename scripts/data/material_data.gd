## 材料数据
##
## 定义游戏中所有材料的属性

extends CodecResource
class_name MaterialData

## 唯一标识符
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 描述
@export var description: String = ""

## 图标路径
@export var icon_path: String = ""

## 属性标签列表
@export var tags: Array[StringName] = []

## 分类（grain, meat, vegetable, fruit, dairy, mineral, liquid）
@export var category: String = ""

## 稀有度（0=普通, 1=稀有, 2=传说）
@export var rarity: int = 0

## 是否是基础材料
@export var is_base: bool = true


## 获取类型 ID
static func get_type_id() -> String:
	return "cookery:material"


## 获取 Codec
static func get_codec() -> Codec:
	return MapCodec.build([
		Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
		Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name),
		Codec.STRING().optional_field_of("description", "").for_getter(func(obj): return obj.description),
		Codec.STRING().optional_field_of("icon_path", "").for_getter(func(obj): return obj.icon_path),
		Codec.STRING().list_of().field_of("tags").for_getter(func(obj): return obj.tags),
		Codec.STRING().optional_field_of("category", "").for_getter(func(obj): return obj.category),
		Codec.INT().optional_field_of("rarity", 0).for_getter(func(obj): return obj.rarity),
		Codec.BOOL().optional_field_of("is_base", true).for_getter(func(obj): return obj.is_base),
	], func(id, display_name, description, icon_path, tags, category, rarity, is_base):
		var mat = MaterialData.new()
		mat.id = id
		mat.display_name = display_name
		mat.description = description
		mat.icon_path = icon_path
		mat.tags = tags
		mat.category = category
		mat.rarity = rarity
		mat.is_base = is_base
		return mat
	).codec()


## 检查是否包含指定标签
func has_tag(tag: StringName) -> bool:
	return tag in tags


## 获取 ResourceLocation
func get_resource_location() -> ResourceLocation:
	return ResourceLocation.from_string("cookery:material/" + id)