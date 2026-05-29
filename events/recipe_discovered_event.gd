## 配方发现事件
##
## 当玩家首次发现新配方时触发

extends Event
class_name RecipeDiscoveredEvent

## 发现的配方
var recipe: RecipeData


func _init(p_recipe: RecipeData = null) -> void:
	recipe = p_recipe