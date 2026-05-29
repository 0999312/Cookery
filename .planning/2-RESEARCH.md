# 2-RESEARCH.md - mc_game_framework 数据基础设施研究

> 研究目标：为阶段 2 数据层实现提供 Codec、Tag、Registry 系统的完整 API 参考
> 研究时间：2026/05/29
> 源码版本：mc_game_framework v1.0.0

---

## 目录

1. [Codec 系统](#1-codec-系统)
2. [MapCodec 系统](#2-mapcodec-系统)
3. [DataResult 结果类型](#3-dataresult-结果类型)
4. [DynamicOps 数据载体](#4-dynamicops-数据载体)
5. [JsonOps 实现](#5-jsonops-实现)
6. [GodotResourceOps 实现](#6-godotresourceops-实现)
7. [CodecResource 基类](#7-codecresource-基类)
8. [Tag 系统](#8-tag-系统)
9. [TagRegistry 注册表](#9-tagregistry-注册表)
10. [RegistryBase 注册表基类](#10-registrybase-注册表基类)
11. [ResourceLocation 标识符](#11-resourcelocation-标识符)
12. [综合示例：为自定义 Resource 定义 Codec](#12-综合示例为自定义-resource-定义-codec)
13. [综合示例：JSON 序列化/反序列化](#13-综合示例json-序列化反序列化)
14. [综合示例：TagRegistry 管理标签](#14-综合示例tagregistry-管理标签)
15. [阶段 2 实践指南](#15-阶段-2-实践指南)

---

## 1. Codec 系统

**文件**: `addons/mc_game_framework/codec/core/codec.gd`
**类名**: `Codec` (extends RefCounted)

DFU 风格编解码器，支持组合式声明。同一个 Codec 定义可用于多个 DynamicOps 实现（JSON / Godot Resource）。

### 1.1 核心 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `encode` | `func encode(value: Variant, ops: DynamicOps) -> DataResult` | 将运行时值编码到 ops 载体格式（子类实现） |
| `decode` | `func decode(value: Variant, ops: DynamicOps) -> DataResult` | 从 ops 载体格式解码为运行时值（子类实现） |

### 1.2 组合器 API（实例方法）

| 方法 | 签名 | 说明 |
|------|------|------|
| `field_of` | `func field_of(name: String) -> MapCodec` | 转为 MapCodec 中的**必填**字段 |
| `optional_field_of` | `func optional_field_of(name: String, default_value: Variant = null) -> MapCodec` | 转为 MapCodec 中的**可选**字段（带默认值） |
| `list_of` | `func list_of() -> Codec` | 构造列表 Codec |
| `xmap` | `func xmap(decode_fn: Callable, encode_fn: Callable) -> Codec` | 同步变换编解码值 |
| `flat_xmap` | `func flat_xmap(decode_fn: Callable, encode_fn: Callable) -> Codec` | 变换可能失败（返回 DataResult） |

### 1.3 静态工厂方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `BOOL` | `static func BOOL() -> Codec` | bool 类型 Codec |
| `INT` | `static func INT() -> Codec` | int 类型 Codec |
| `FLOAT` | `static func FLOAT() -> Codec` | float 类型 Codec |
| `STRING` | `static func STRING() -> Codec` | String 类型 Codec |
| `RESOURCE_LOCATION` | `static func RESOURCE_LOCATION() -> Codec` | ResourceLocation Codec |
| `map_of` | `static func map_of(key_codec: Codec, value_codec: Codec) -> Codec` | 键值对 map Codec |
| `either` | `static func either(first: Codec, second: Codec) -> Codec` | 优先尝试 first，失败则尝试 second |
| `dispatch` | `static func dispatch(type_key: String, type_codec: Codec, dispatch_fn: Callable) -> Codec` | 根据类型字段分发到不同子 Codec |
| `record` | `static func record(map_codec: MapCodec) -> Codec` | 从 MapCodec 构建 Record 风格 Codec |
| `unit` | `static func unit(value: Variant) -> Codec` | 始终返回固定值的 Codec |

### 1.4 内部 Codec 类

| 类名 | 说明 |
|------|------|
| `PrimitiveCodec` | 基本类型编解码（BOOL/INT/FLOAT/STRING） |
| `ResourceLocationCodec` | ResourceLocation 编解码（字符串 <-> ResourceLocation） |
| `ListCodec` | 列表编解码，支持部分解码成功 |
| `MapOfCodec` | 键值对字典编解码 |
| `XmapCodec` | 同步变换编解码 |
| `FlatXmapCodec` | 可失败变换编解码 |
| `EitherCodec` | 两种 Codec 的备选方案 |
| `DispatchCodec` | 基于类型字段的分发编解码 |
| `UnitCodec` | 固定值 Codec（编码为空，解码返回固定值） |
| `RecordCodec` | 从 MapCodec 构建的 Record Codec |

---

## 2. MapCodec 系统

**文件**: `addons/mc_game_framework/codec/core/map_codec.gd`
**类名**: `MapCodec` (extends RefCounted)

字段级结构编解码器，负责对象/字段级结构编解码。

### 2.1 核心 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `decode_from_map` | `func decode_from_map(map_value: Variant, ops: DynamicOps) -> DataResult` | 从 Map 数据解码为运行时对象 |
| `encode_to_map` | `func encode_to_map(value: Variant, ops: DynamicOps) -> DataResult` | 将运行时对象编码为 Map 数据 |
| `codec` | `func codec() -> Codec` | 转为 Codec（通过 RecordCodec 包装） |

### 2.2 组合器 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `for_getter` | `func for_getter(getter: Callable) -> MapCodec` | 附加 getter 函数，用于从大对象中提取本字段值 |

### 2.3 静态工厂方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `build` | `static func build(fields: Array, constructor: Callable) -> MapCodec` | 组合多个 MapCodec 字段，创建 Record 结构 |

### 2.4 内部类

| 类名 | 说明 |
|------|------|
| `FieldCodec` | 单字段 MapCodec，支持必填/可选 |
| `GetterMapCodec` | 附加 getter 的 MapCodec 包装 |
| `RecordMapCodec` | 多字段组合 MapCodec |

### 2.5 Record 构建模式

`MapCodec.build()` 是构建复杂对象 Codec 的推荐方式：

```gdscript
# 步骤 1: 定义各字段的 MapCodec（通过 for_getter 绑定 getter）
var id_field = Codec.STRING().field_of("id").for_getter(func(obj): return obj.id)
var name_field = Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name)

# 步骤 2: 组合为 RecordMapCodec
var record_codec = MapCodec.build(
    [id_field, name_field],
    func(id, name):  # 构造函数，参数顺序与 fields 数组一致
        var obj = MyData.new()
        obj.id = id
        obj.display_name = name
        return obj
)

# 步骤 3: 转为 Codec
var codec = record_codec.codec()
```

---

## 3. DataResult 结果类型

**文件**: `addons/mc_game_framework/codec/core/data_result.gd`
**类名**: `DataResult` (extends RefCounted)

DFU 风格结果对象，支持三种状态：成功、错误、部分成功。

### 3.1 状态枚举

| 枚举值 | 说明 |
|--------|------|
| `Status.SUCCESS` | 完全成功 |
| `Status.ERROR` | 无法继续解码 |
| `Status.PARTIAL` | 部分成功（使用默认值继续） |

### 3.2 诊断级别

| 枚举值 | 说明 |
|--------|------|
| `DiagnosticLevel.FATAL` | 无法继续 |
| `DiagnosticLevel.RECOVERABLE` | 使用默认值继续 |
| `DiagnosticLevel.WARNING` | 结构合法但存在潜在问题 |

### 3.3 静态构造方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `success` | `static func success(value: Variant) -> DataResult` | 创建成功结果 |
| `error` | `static func error(message: String) -> DataResult` | 创建错误结果 |
| `partial` | `static func partial(partial_value: Variant, message: String) -> DataResult` | 创建部分成功结果 |

### 3.4 查询方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `is_success` | `func is_success() -> bool` | 是否成功 |
| `is_error` | `func is_error() -> bool` | 是否错误 |
| `is_partial` | `func is_partial() -> bool` | 是否部分成功 |
| `get_status` | `func get_status() -> Status` | 获取状态枚举 |
| `get_value` | `func get_value() -> Variant` | 获取结果值（成功或部分成功时有效） |
| `get_or_default` | `func get_or_default(default: Variant) -> Variant` | 获取结果值，若无值则使用默认值 |
| `get_error` | `func get_error() -> String` | 获取错误信息 |
| `get_diagnostics` | `func get_diagnostics() -> Array` | 获取所有诊断信息 |
| `get_partial_value` | `func get_partial_value() -> Variant` | 获取部分值（仅 PARTIAL 状态有效） |

### 3.5 函数式组合方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `map` | `func map(transform: Callable) -> DataResult` | 对成功值施加变换 |
| `flat_map` | `func flat_map(transform: Callable) -> DataResult` | 对成功值施加返回 DataResult 的变换 |
| `apply` | `func apply(func_result: DataResult) -> DataResult` | 将另一个 DataResult<Callable> 应用到当前值 |
| `add_diagnostic` | `func add_diagnostic(level: DiagnosticLevel, message: String, path: String = "") -> DataResult` | 添加诊断信息 |
| `set_path_prefix` | `func set_path_prefix(prefix: String) -> DataResult` | 设置路径前缀（用于嵌套字段的错误定位） |

### 3.6 Diagnostic 内部类

| 属性 | 类型 | 说明 |
|------|------|------|
| `level` | `DiagnosticLevel` | 诊断级别 |
| `message` | `String` | 诊断消息 |
| `path` | `String` | 字段路径，例如 `"inventory.items[3].count"` |

---

## 4. DynamicOps 数据载体

**文件**: `addons/mc_game_framework/codec/core/dynamic_ops.gd`
**类名**: `DynamicOps` (extends RefCounted)

数据载体抽象层，将底层数据格式统一抽象。上层 Codec 不关心载体，只关心读写语义。

### 4.1 基本类型创建

| 方法 | 签名 | 说明 |
|------|------|------|
| `empty` | `func empty() -> Variant` | 创建空值 |
| `create_int` | `func create_int(value: int) -> Variant` | 从 int 创建值 |
| `create_float` | `func create_float(value: float) -> Variant` | 从 float 创建值 |
| `create_bool` | `func create_bool(value: bool) -> Variant` | 从 bool 创建值 |
| `create_string` | `func create_string(value: String) -> Variant` | 从 String 创建值 |
| `create_list` | `func create_list(values: Array) -> Variant` | 创建列表 |
| `create_map` | `func create_map(entries: Dictionary) -> Variant` | 创建 Map |

### 4.2 基本类型读取

| 方法 | 签名 | 说明 |
|------|------|------|
| `get_int` | `func get_int(value: Variant) -> DataResult` | 读取为 int |
| `get_float` | `func get_float(value: Variant) -> DataResult` | 读取为 float |
| `get_bool` | `func get_bool(value: Variant) -> DataResult` | 读取为 bool |
| `get_string` | `func get_string(value: Variant) -> DataResult` | 读取为 String |

### 4.3 复合类型操作

| 方法 | 签名 | 说明 |
|------|------|------|
| `get_map_value` | `func get_map_value(map_value: Variant, key: String) -> DataResult` | 从 Map 中获取指定 key 的值 |
| `set_map_value` | `func set_map_value(map_value: Variant, key: String, value: Variant) -> Variant` | 设置 Map 中指定 key 的值（返回新 Map） |
| `remove_map_value` | `func remove_map_value(map_value: Variant, key: String) -> Variant` | 移除 Map 中指定 key |
| `get_map_keys` | `func get_map_keys(map_value: Variant) -> DataResult` | 获取 Map 所有键 |
| `get_map_entries` | `func get_map_entries(map_value: Variant) -> DataResult` | 获取 Map 所有键值对 |
| `get_list` | `func get_list(value: Variant) -> DataResult` | 将值解读为列表 |
| `merge_maps` | `func merge_maps(first: Variant, second: Variant) -> Variant` | 合并两个 Map |

### 4.4 类型判断

| 方法 | 签名 | 说明 |
|------|------|------|
| `is_map` | `func is_map(value: Variant) -> bool` | 是否是 Map 类型 |
| `is_list` | `func is_list(value: Variant) -> bool` | 是否是 List 类型 |
| `is_number` | `func is_number(value: Variant) -> bool` | 是否是数值类型 |
| `is_string` | `func is_string(value: Variant) -> bool` | 是否是字符串类型 |
| `get_name` | `func get_name() -> String` | 获取 Ops 的名称标识 |

---

## 5. JsonOps 实现

**文件**: `addons/mc_game_framework/codec/ops/json_ops.gd`
**类名**: `JsonOps` (extends DynamicOps)

JSON 格式的 DynamicOps 实现。使用 Godot Variant 作为 JSON 中间表示。

### 5.1 单例访问

```gdscript
var ops := JsonOps.INSTANCE
```

### 5.2 类型映射

| JSON 类型 | Godot Variant 类型 |
|-----------|-------------------|
| object | Dictionary |
| array | Array |
| string | String |
| number (int) | int |
| number (float) | float |
| boolean | bool |
| null | null |

### 5.3 辅助方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `to_json_string` | `static func to_json_string(value: Variant, indent: String = "\t") -> String` | 将 Variant 序列化为 JSON 字符串 |
| `from_json_string` | `static func from_json_string(json_str: String) -> DataResult` | 将 JSON 字符串解析为 Variant |

### 5.4 宽松类型转换

JsonOps 支持宽松的数值类型转换：
- `get_int()` 接受 `float` 并转换为 `int`
- `get_float()` 接受 `int` 并转换为 `float`

---

## 6. GodotResourceOps 实现

**文件**: `addons/mc_game_framework/codec/ops/godot_resource_ops.gd`
**类名**: `GodotResourceOps` (extends DynamicOps)

Godot Resource 格式的 DynamicOps 实现。支持 Resource 对象的属性反射读写。

### 6.1 单例访问

```gdscript
var ops := GodotResourceOps.INSTANCE
```

### 6.2 特殊能力

- 支持 `Dictionary` 和 `Resource` 两种来源的 Map 操作
- `get_map_value()` 可以从 Resource 的 `@export` 属性中读取值
- `get_map_entries()` 可以将 Resource 对象转为 Dictionary

### 6.3 Resource 辅助方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `resource_to_dict` | `static func resource_to_dict(res: Resource) -> Dictionary` | 将 Resource 的 @export 属性转为 Dictionary |
| `dict_to_resource` | `static func dict_to_resource(dict: Dictionary, res: Resource) -> DataResult` | 将 Dictionary 值写回 Resource 属性 |
| `save_resource` | `static func save_resource(res: Resource, path: String) -> DataResult` | 保存 Resource 到 .tres 文件 |
| `load_resource` | `static func load_resource(path: String) -> DataResult` | 从 .tres/.res 文件加载 Resource |

### 6.4 属性过滤规则

`resource_to_dict()` 只导出满足以下条件的属性：
- `PROPERTY_USAGE_STORAGE` 标志位为真
- `PROPERTY_USAGE_SCRIPT_VARIABLE` 标志位为真

即只导出脚本中声明的 `@export` 变量。

---

## 7. CodecResource 基类

**文件**: `addons/mc_game_framework/codec/core/codec_resource.gd`
**类名**: `CodecResource` (extends Resource)

Codec 驱动的 Godot Resource 基类，桥接运行时对象与 Godot Resource 持久化。

### 7.1 子类必须覆写的方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `get_type_id` | `static func get_type_id() -> String` | 资源类型 ID |
| `get_codec` | `static func get_codec() -> Codec` | 获取此资源类型的 Codec |

### 7.2 可选覆写

| 方法 | 签名 | 说明 |
|------|------|------|
| `allows_resource_persistence` | `static func allows_resource_persistence() -> bool` | 是否允许落盘为 Godot Resource（默认 true） |

### 7.3 序列化 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `encode_with` | `func encode_with(ops: DynamicOps) -> DataResult` | 使用 Codec 编码为指定 ops 格式 |
| `decode_with` | `static func decode_with(data: Variant, ops: DynamicOps) -> DataResult` | 使用 Codec 从数据解码（类方法） |
| `to_json_data` | `func to_json_data() -> DataResult` | 编码为 JSON 字典 |
| `from_json_data` | `static func from_json_data(data: Variant) -> DataResult` | 从 JSON 字典解码 |
| `to_resource_data` | `func to_resource_data() -> DataResult` | 编码为 Godot Resource 属性字典 |
| `save_to_file` | `func save_to_file(path: String) -> DataResult` | 保存为 .tres 文件 |
| `load_from_file` | `static func load_from_file(path: String) -> DataResult` | 从 .tres/.res 文件加载 |

---

## 8. Tag 系统

**文件**: `addons/mc_game_framework/tag/tag.gd`
**类名**: `Tag` (extends Resource)

标签对象，管理一组 ResourceLocation 条目。

### 8.1 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `registry_type` | `ResourceLocation` | 指向注册表的 ResourceLocation |
| `_entries` | `Dictionary` | 内部存储，键为 ResourceLocation 字符串形式 |

### 8.2 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `_init` | `func _init(p_registry_type: ResourceLocation) -> void` | 构造函数，需要指定 registry_type |
| `add_entry` | `func add_entry(entry_id: ResourceLocation) -> void` | 向标签添加条目 |
| `remove_entry` | `func remove_entry(entry_id: ResourceLocation) -> bool` | 从标签移除条目，返回是否成功 |
| `has_entry` | `func has_entry(entry_id: ResourceLocation) -> bool` | 检查条目是否属于标签 |
| `get_all_entries` | `func get_all_entries() -> Array` | 获取所有条目（返回 ResourceLocation 数组） |
| `get_entry_count` | `func get_entry_count() -> int` | 获取条目数量 |
| `clear_entries` | `func clear_entries() -> void` | 清空所有条目 |

### 8.3 内部存储说明

Tag 使用 `_entries: Dictionary` 存储条目，键为 `ResourceLocation.to_string()` 的结果（字符串），值为 `true`。这是因为 RefCounted 对象在 Dictionary 中使用引用比较，而非值比较。

---

## 9. TagRegistry 注册表

**文件**: `addons/mc_game_framework/tag/tag_registry.gd`
**类名**: `TagRegistry` (extends RegistryBase)

标签注册表，管理所有标签的注册和查询。

### 9.1 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `register_tag` | `func register_tag(tag_id: ResourceLocation, registry_type: ResourceLocation) -> Tag` | 注册新标签，返回 Tag 对象 |
| `get_tag` | `func get_tag(tag_id: ResourceLocation) -> Tag` | 获取标签对象 |
| `add_to_tag` | `func add_to_tag(tag_id: ResourceLocation, entry_id: ResourceLocation) -> void` | 向标签添加条目 |
| `remove_from_tag` | `func remove_from_tag(tag_id: ResourceLocation, entry_id: ResourceLocation) -> bool` | 从标签移除条目 |
| `has_entry_in_tag` | `func has_entry_in_tag(tag_id: ResourceLocation, entry_id: ResourceLocation) -> bool` | 检查条目是否属于标签 |
| `get_all_entries_of_tag` | `func get_all_entries_of_tag(tag_id: ResourceLocation) -> Array` | 获取标签的所有条目 |
| `delete_tag` | `func delete_tag(tag_id: ResourceLocation) -> bool` | 删除标签（同时从注册表中移除） |
| `get_all_tag_ids` | `func get_all_tag_ids() -> Array` | 获取所有标签 ID（返回 ResourceLocation 数组） |

### 9.2 继承自 RegistryBase 的方法

TagRegistry 继承了 RegistryBase 的所有方法，包括：
- `register(id, entry)` - 注册条目
- `unregister(id)` - 注销条目
- `get_entry(id)` - 获取条目
- `has_entry(id)` - 检查条目是否存在
- `get_all_entries()` - 获取所有条目
- `get_all_keys()` - 获取所有键
- `clear()` - 清空注册表

### 9.3 幂等性

`register_tag()` 具有幂等性：如果标签已存在，返回已有的 Tag 对象，不会重复创建。

---

## 10. RegistryBase 注册表基类

**文件**: `addons/mc_game_framework/registry/registry_base.gd`
**类名**: `RegistryBase` (extends RefCounted)

通用注册表基类，使用 ResourceLocation 字符串形式作为键。

### 10.1 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `register` | `func register(id: ResourceLocation, entry: Variant) -> bool` | 注册条目，返回是否成功 |
| `unregister` | `func unregister(id: ResourceLocation) -> bool` | 注销条目，返回是否成功 |
| `get_entry` | `func get_entry(id: ResourceLocation) -> Variant` | 获取条目（不存在返回 null） |
| `has_entry` | `func has_entry(id: ResourceLocation) -> bool` | 检查条目是否存在 |
| `get_all_entries` | `func get_all_entries() -> Dictionary` | 获取所有条目的副本 |
| `get_all_keys` | `func get_all_keys() -> Array` | 获取所有键（字符串数组） |
| `clear` | `func clear() -> void` | 清空注册表 |

### 10.2 虚方法（子类可覆写）

| 方法 | 签名 | 说明 |
|------|------|------|
| `_validate_entry` | `func _validate_entry(_entry: Variant) -> bool` | 条目类型校验（默认返回 true） |
| `_get_expected_type_name` | `func _get_expected_type_name() -> String` | 校验失败时显示的期望类型名 |

### 10.3 覆盖警告

`register()` 在覆盖已有条目时会输出 `push_warning()`，不会阻止注册。

### 10.4 自定义类型校验示例

```gdscript
class_name MaterialRegistry extends RegistryBase

func _validate_entry(entry: Variant) -> bool:
    return entry is MaterialData

func _get_expected_type_name() -> String:
    return "MaterialData"
```

---

## 11. ResourceLocation 标识符

**文件**: `addons/mc_game_framework/utils/resource_location.gd`
**类名**: `ResourceLocation` (extends RefCounted)

Minecraft 风格资源标识符，格式为 `namespace:path`。

### 11.1 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `namespace_id` | `String` | 命名空间 |
| `id` | `String` | 路径 |

### 11.2 静态常量

| 常量 | 值 | 说明 |
|------|-----|------|
| `NAMESPACE_PATTERN` | `"^[a-z0-9_\\-.]+$"` | namespace 合法字符正则 |
| `PATH_PATTERN` | `"^[a-z0-9_\\-./]+$"` | path 合法字符正则 |

### 11.3 API

| 方法 | 签名 | 说明 |
|------|------|------|
| `_init` | `func _init(p_namespace: String = "", p_path: String = "") -> void` | 构造函数 |
| `from_string` | `static func from_string(location_str: String) -> ResourceLocation` | 从字符串解析（宽松模式） |
| `parse` | `static func parse(location_str: String) -> DataResult` | 严格模式解析（带合法性校验） |
| `validate` | `static func validate(location_str: String) -> DataResult` | 校验完整字符串格式 |
| `validate_namespace` | `static func validate_namespace(ns: String) -> DataResult` | 校验 namespace 合法性 |
| `validate_path` | `static func validate_path(path: String) -> DataResult` | 校验 path 合法性 |
| `is_valid` | `static func is_valid(location_str: String) -> bool` | 判断字符串是否为合法格式 |
| `equals` | `func equals(other: ResourceLocation) -> bool` | 值比较（替代 `==` 引用比较） |
| `_to_string` | `func _to_string() -> String` | 返回 `"namespace:path"` 格式字符串 |

### 11.4 重要注意事项

**ResourceLocation 继承自 RefCounted，Godot Dictionary 使用对象引用比较而非 equals()。请始终使用 `.to_string()` 作为 Dictionary key，勿直接用 ResourceLocation 对象。**

```gdscript
# 正确做法
var key = ResourceLocation.from_string("cookery:material/flour")
dict[key.to_string()] = data

# 错误做法（会导致查找失败）
dict[key] = data
```

---

## 12. 综合示例：为自定义 Resource 定义 Codec

### 12.1 使用 CodecResource 基类（推荐）

```gdscript
## material_data.gd
extends CodecResource
class_name MaterialData

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""
@export var tags: Array[String] = []
@export var category: String = ""
@export var rarity: int = 0
@export var is_base: bool = true

# ── CodecResource 必须覆写 ──

static func get_type_id() -> String:
    return "cookery:material"

static func get_codec() -> Codec:
    return MapCodec.build([
        Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
        Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name),
        Codec.STRING().optional_field_of("description", "").for_getter(func(obj): return obj.description),
        Codec.STRING().optional_field_of("icon_path", "").for_getter(func(obj): return obj.icon_path),
        Codec.STRING().list_of().field_of("tags").for_getter(func(obj): return obj.tags),
        Codec.STRING().field_of("category").for_getter(func(obj): return obj.category),
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
```

### 12.2 使用普通 Resource + 独立 Codec

```gdscript
## material_codec.gd
class_name MaterialCodec

static func create() -> Codec:
    return MapCodec.build([
        Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
        Codec.STRING().field_of("display_name").for_getter(func(obj): return obj.display_name),
        Codec.STRING().list_of().field_of("tags").for_getter(func(obj): return obj.tags),
    ], func(id, display_name, tags):
        var mat = MaterialData.new()
        mat.id = id
        mat.display_name = display_name
        mat.tags = tags
        return mat
    ).codec()
```

### 12.3 使用 xmap 变换

```gdscript
# 将原始 Dictionary 编解码映射到 MaterialData
var raw_codec = MapCodec.build([
    Codec.STRING().field_of("id").for_getter(func(obj): return obj.id),
    Codec.STRING().field_of("name").for_getter(func(obj): return obj.display_name),
], func(id, name):
    return {"id": id, "name": name}
).codec()

var material_codec = raw_codec.xmap(
    func(data):  # decode: Dictionary -> MaterialData
        var mat = MaterialData.new()
        mat.id = data.id
        mat.display_name = data.name
        return mat,
    func(mat):  # encode: MaterialData -> Dictionary
        return {"id": mat.id, "name": mat.display_name}
)
```

---

## 13. 综合示例：JSON 序列化/反序列化

### 13.1 编码为 JSON 字符串

```gdscript
# 创建材料数据
var material = MaterialData.new()
material.id = "flour"
material.display_name = "面粉"
material.tags = ["raw", "grain", "powder"]
material.category = "grain"

# 方式 1: 使用 CodecResource 便捷方法
var json_result = material.to_json_data()
if json_result.is_success():
    var json_str = JsonOps.to_json_string(json_result.get_value())
    print(json_str)

# 方式 2: 手动使用 Codec + JsonOps
var codec = MaterialData.get_codec()
var encode_result = codec.encode(material, JsonOps.INSTANCE)
if encode_result.is_success():
    var json_str = JsonOps.to_json_string(encode_result.get_value())
    print(json_str)
```

### 13.2 从 JSON 字符串解码

```gdscript
var json_str = '{"id":"flour","display_name":"面粉","tags":["raw","grain","powder"],"category":"grain"}'

# 方式 1: 使用 CodecResource 便捷方法
var parse_result = JsonOps.from_json_string(json_str)
if parse_result.is_success():
    var decode_result = MaterialData.from_json_data(parse_result.get_value())
    if decode_result.is_success():
        var material: MaterialData = decode_result.get_value()
        print(material.display_name)  # 输出: 面粉

# 方式 2: 手动使用 Codec + JsonOps
var codec = MaterialData.get_codec()
var parse_result2 = JsonOps.from_json_string(json_str)
if parse_result2.is_success():
    var decode_result2 = codec.decode(parse_result2.get_value(), JsonOps.INSTANCE)
    if decode_result2.is_success():
        var material: MaterialData = decode_result2.get_value()
```

### 13.3 处理部分解码

```gdscript
# JSON 缺少可选字段时，使用默认值继续
var json_str = '{"id":"flour","display_name":"面粉","tags":["raw"],"category":"grain"}'
# 缺少 description, icon_path, rarity, is_base

var parse_result = JsonOps.from_json_string(json_str)
if parse_result.is_success():
    var decode_result = MaterialData.get_codec().decode(parse_result.get_value(), JsonOps.INSTANCE)

    if decode_result.is_success():
        print("完全成功")
    elif decode_result.is_partial():
        print("部分成功: ", decode_result.get_error())
        var material: MaterialData = decode_result.get_value()
        # material.description 将使用默认值 ""
        # material.rarity 将使用默认值 0

    # 查看诊断信息
    for diag in decode_result.get_diagnostics():
        print(diag)  # 输出: [RECOVERABLE] description: Missing required field 'description'
```

### 13.4 保存/加载 .tres 文件

```gdscript
# 保存
var material = MaterialData.new()
material.id = "flour"
material.display_name = "面粉"
var save_result = material.save_to_file("res://data/materials/flour.tres")
if save_result.is_error():
    push_error(save_result.get_error())

# 加载
var load_result = MaterialData.load_from_file("res://data/materials/flour.tres")
if load_result.is_success():
    var material: MaterialData = load_result.get_value()
```

---

## 14. 综合示例：TagRegistry 管理标签

### 14.1 初始化 TagRegistry

```gdscript
# 在游戏初始化时
var tag_registry = TagRegistry.new()

# 注册到 RegistryManager（如果框架支持）
# RegistryManager.register_registry("tags", tag_registry)
```

### 14.2 注册标签

```gdscript
# 注册"生"标签，指向材料注册表
tag_registry.register_tag(
    ResourceLocation.from_string("cookery:tag/raw"),
    ResourceLocation.from_string("cookery:registry/material")
)

# 注册"谷物"标签
tag_registry.register_tag(
    ResourceLocation.from_string("cookery:tag/grain"),
    ResourceLocation.from_string("cookery:registry/material")
)

# 注册"粉末"标签
tag_registry.register_tag(
    ResourceLocation.from_string("cookery:tag/powder"),
    ResourceLocation.from_string("cookery:registry/material")
)
```

### 14.3 向标签添加条目

```gdscript
# 将面粉添加到"生"标签
tag_registry.add_to_tag(
    ResourceLocation.from_string("cookery:tag/raw"),
    ResourceLocation.from_string("cookery:material/flour")
)

# 将面粉添加到"谷物"标签
tag_registry.add_to_tag(
    ResourceLocation.from_string("cookery:tag/grain"),
    ResourceLocation.from_string("cookery:material/flour")
)

# 将面粉添加到"粉末"标签
tag_registry.add_to_tag(
    ResourceLocation.from_string("cookery:tag/powder"),
    ResourceLocation.from_string("cookery:material/flour")
)
```

### 14.4 查询标签

```gdscript
# 获取标签对象
var raw_tag = tag_registry.get_tag(ResourceLocation.from_string("cookery:tag/raw"))

# 检查面粉是否属于"生"标签
var is_raw = tag_registry.has_entry_in_tag(
    ResourceLocation.from_string("cookery:tag/raw"),
    ResourceLocation.from_string("cookery:material/flour")
)
print(is_raw)  # 输出: true

# 获取"生"标签下的所有材料
var raw_materials = tag_registry.get_all_entries_of_tag(
    ResourceLocation.from_string("cookery:tag/raw")
)
for mat_id in raw_materials:
    print(mat_id)  # 输出: cookery:material/flour

# 获取标签条目数量
var count = raw_tag.get_entry_count()
```

### 14.5 批量注册示例

```gdscript
func _register_all_tags() -> void:
    # 定义标签结构
    var tag_definitions = {
        "cookery:tag/raw": "cookery:registry/material",
        "cookery:tag/cooked": "cookery:registry/material",
        "cookery:tag/fermented": "cookery:registry/material",
        "cookery:tag/grain": "cookery:registry/material",
        "cookery:tag/meat": "cookery:registry/material",
        "cookery:tag/vegetable": "cookery:registry/material",
        "cookery:tag/liquid": "cookery:registry/material",
        "cookery:tag/solid": "cookery:registry/material",
        "cookery:tag/powder": "cookery:registry/material",
    }

    # 注册所有标签
    for tag_str in tag_definitions:
        var tag_id = ResourceLocation.from_string(tag_str)
        var registry_type = ResourceLocation.from_string(tag_definitions[tag_str])
        tag_registry.register_tag(tag_id, registry_type)

    # 定义材料 -> 标签映射
    var material_tags = {
        "cookery:material/flour": ["cookery:tag/raw", "cookery:tag/grain", "cookery:tag/powder"],
        "cookery:material/rice": ["cookery:tag/raw", "cookery:tag/grain", "cookery:tag/solid"],
        "cookery:material/water": ["cookery:tag/raw", "cookery:tag/liquid"],
    }

    # 批量添加条目到标签
    for mat_str in material_tags:
        var mat_id = ResourceLocation.from_string(mat_str)
        for tag_str in material_tags[mat_str]:
            var tag_id = ResourceLocation.from_string(tag_str)
            tag_registry.add_to_tag(tag_id, mat_id)
```

### 14.6 删除标签

```gdscript
# 删除标签（同时从注册表中移除）
tag_registry.delete_tag(ResourceLocation.from_string("cookery:tag/powder"))
```

---

## 15. 阶段 2 实践指南

### 15.1 数据类设计模式

**推荐模式：继承 CodecResource**

```gdscript
extends CodecResource
class_name MaterialData

@export var id: String = ""
@export var display_name: String = ""
# ... 其他属性

static func get_type_id() -> String:
    return "cookery:material"

static func get_codec() -> Codec:
    return MapCodec.build([...], func(...): ...).codec()
```

**优势**：
- 自动获得 `to_json_data()` / `from_json_data()` 便捷方法
- 自动获得 `save_to_file()` / `load_from_file()` 持久化能力
- 与 Godot 编辑器 Inspector 集成

### 15.2 Codec 定义模式

**单字段 Codec**：

```gdscript
Codec.STRING().field_of("id")  # 必填字段
Codec.INT().optional_field_of("rarity", 0)  # 可选字段，默认值 0
```

**列表字段 Codec**：

```gdscript
Codec.STRING().list_of().field_of("tags")  # 字符串列表
```

**嵌套对象 Codec**：

```gdscript
Codec.record(SubObject.get_codec()).field_of("sub_object")
```

**Record 构建**：

```gdscript
MapCodec.build([
    field1.for_getter(func(obj): return obj.field1),
    field2.for_getter(func(obj): return obj.field2),
], func(val1, val2):
    var obj = MyData.new()
    obj.field1 = val1
    obj.field2 = val2
    return obj
).codec()
```

### 15.3 标签与 Codec 集成

标签数据在 Codec 中应存储为字符串数组（ResourceLocation 的字符串形式）：

```gdscript
# 在 MaterialData 的 Codec 中
Codec.STRING().list_of().field_of("tags").for_getter(func(obj): return obj.tags)

# 在运行时转换为 ResourceLocation 数组
func get_tag_locations() -> Array[ResourceLocation]:
    var result: Array[ResourceLocation] = []
    for tag_str in tags:
        var loc = ResourceLocation.from_string(tag_str)
        if loc:
            result.append(loc)
    return result
```

### 15.4 错误处理模式

```gdscript
# 编解码操作始终检查 DataResult
var result = codec.decode(data, JsonOps.INSTANCE)
if result.is_error():
    push_error("解码失败: %s" % result.get_error())
    return

if result.is_partial():
    push_warning("部分解码: %s" % result.get_error())
    # 仍然可以使用 result.get_value()

var value = result.get_value()
```

### 15.5 注册表使用模式

```gdscript
# 创建类型化注册表
class_name MaterialRegistry extends RegistryBase
func _validate_entry(entry: Variant) -> bool:
    return entry is MaterialData
func _get_expected_type_name() -> String:
    return "MaterialData"

# 注册数据
var registry = MaterialRegistry.new()
registry.register(ResourceLocation.from_string("cookery:material/flour"), flour_data)

# 查询数据
var flour = registry.get_entry(ResourceLocation.from_string("cookery:material/flour"))
```

### 15.6 目录结构建议

```
data/
├── materials/
│   ├── material_data.gd          # MaterialData (CodecResource)
│   ├── material_codec.gd         # MaterialCodec（如果不用 CodecResource）
│   ├── material_registry.gd      # MaterialRegistry (RegistryBase)
│   ├── base/
│   │   ├── flour.tres
│   │   ├── rice.tres
│   │   └── water.tres
│   └── processed/
│       ├── bread.tres
│       └── cooked_rice.tres
├── equipment/
│   ├── equipment_data.gd
│   ├── equipment_registry.gd
│   └── stove.tres
├── recipes/
│   ├── recipe_data.gd
│   ├── recipe_registry.gd
│   └── bread_recipe.tres
└── tags/
    ├── tag_manager.gd            # 标签初始化脚本
    └── tag_definitions.gd        # 标签定义常量
```

### 15.7 初始化流程

```gdscript
## data_manager.gd (Autoload)
extends Node

var tag_registry: TagRegistry
var material_registry: MaterialRegistry
var equipment_registry: EquipmentRegistry
var recipe_registry: RecipeRegistry

func _ready() -> void:
    _init_registries()
    _register_tags()
    _load_data()

func _init_registries() -> void:
    tag_registry = TagRegistry.new()
    material_registry = MaterialRegistry.new()
    equipment_registry = EquipmentRegistry.new()
    recipe_registry = RecipeRegistry.new()

func _register_tags() -> void:
    # 注册所有标签定义
    tag_registry.register_tag(
        ResourceLocation.from_string("cookery:tag/raw"),
        ResourceLocation.from_string("cookery:registry/material")
    )
    # ... 更多标签

func _load_data() -> void:
    # 从 .tres 文件加载数据
    var flour_result = MaterialData.load_from_file("res://data/materials/base/flour.tres")
    if flour_result.is_success():
        var flour: MaterialData = flour_result.get_value()
        material_registry.register(
            ResourceLocation.from_string("cookery:material/flour"),
            flour
        )
        # 添加到标签
        for tag_str in flour.tags:
            tag_registry.add_to_tag(
                ResourceLocation.from_string(tag_str),
                ResourceLocation.from_string("cookery:material/flour")
            )
```

---

## 附录：文件路径汇总

| 文件 | 路径 |
|------|------|
| Codec | `addons/mc_game_framework/codec/core/codec.gd` |
| MapCodec | `addons/mc_game_framework/codec/core/map_codec.gd` |
| DataResult | `addons/mc_game_framework/codec/core/data_result.gd` |
| DynamicOps | `addons/mc_game_framework/codec/core/dynamic_ops.gd` |
| JsonOps | `addons/mc_game_framework/codec/ops/json_ops.gd` |
| GodotResourceOps | `addons/mc_game_framework/codec/ops/godot_resource_ops.gd` |
| CodecResource | `addons/mc_game_framework/codec/core/codec_resource.gd` |
| Tag | `addons/mc_game_framework/tag/tag.gd` |
| TagRegistry | `addons/mc_game_framework/tag/tag_registry.gd` |
| RegistryBase | `addons/mc_game_framework/registry/registry_base.gd` |
| ResourceLocation | `addons/mc_game_framework/utils/resource_location.gd` |
