# 5-CONTEXT.md - 阶段 5 决策文档

> 阶段: 完善和优化
> 决策时间: 2026/05/29

## 决策摘要

| 决策 | 选择 | 原因 |
|------|------|------|
| 存档系统 | Codec 重构 | 使用框架序列化，支持自动保存 |
| 音频集成 | UI 音效 | 按钮点击、烹饪完成音效 |
| 单元测试 | 全面测试 | 覆盖所有核心系统 |
| 数据扩展 | 完整迁移 | 扩展到 60+ 种材料 |

---

## 1. 存档系统增强

**决策**: 使用框架 Codec 重构存档系统

**实现方式**:
- 为 SaveData 定义 Codec
- 使用 JsonOps 序列化/反序列化
- 添加自动保存功能

**SaveData 结构**:

```gdscript
class_name SaveData extends CodecResource

@export var version: String = "1.0.0"
@export var timestamp: float = 0.0
@export var play_time: float = 0.0
@export var discovered_materials: Array[String] = []
@export var discovered_recipes: Array[String] = []
@export var discovered_equipment: Array[String] = []
@export var settings: Dictionary = {}
```

**自动保存触发时机**:
- 烹饪完成时
- 发现新配方时
- 退出游戏时

**存档槽位**:
- 3 个存档槽位
- 自动保存使用槽位 0

---

## 2. 音频集成

**决策**: 添加 UI 音效

**音效清单**:

| 音效 | 触发时机 | 文件路径 |
|------|----------|----------|
| 按钮点击 | 点击任何按钮 | assets/audio/sfx/ui_click.ogg |
| 烹饪开始 | 开始烹饪 | assets/audio/sfx/cooking_start.ogg |
| 烹饪完成 | 烹饪完成 | assets/audio/sfx/cooking_complete.ogg |
| 新发现 | 发现新配方/材料 | assets/audio/sfx/discovery.ogg |
| 错误提示 | 操作失败 | assets/audio/sfx/error.ogg |

**实现方式**:
- 使用 SoundManager.play_sfx()
- 在关键事件中调用

---

## 3. 单元测试

**决策**: 全面测试

**测试范围**:

| 系统 | 测试内容 | 优先级 |
|------|----------|--------|
| CookingSystem | 变换规则、配方匹配、动态结果 | 高 |
| DataManager | 数据加载、查询、注册 | 高 |
| SaveManager | 保存、加载、删除 | 中 |
| TagRegistry | 标签注册、查询 | 中 |
| Codec | 序列化、反序列化 | 低 |

**测试框架**: GUT (gut v9.6.0)

**测试目录**: `tests/`

**测试文件命名**: `test_<系统名>.gd`

---

## 4. 数据扩展

**决策**: 完整迁移 Web 原型数据

**目标**: 扩展到 60+ 种材料

**材料分类**:

| 分类 | 数量 | 示例 |
|------|------|------|
| 谷物 | 8 | 面粉、大米、燕麦、玉米... |
| 肉类 | 8 | 猪肉、牛肉、鸡肉、鱼... |
| 蔬菜 | 12 | 番茄、洋葱、胡萝卜、土豆... |
| 水果 | 8 | 苹果、香蕉、柠檬、草莓... |
| 乳制品 | 6 | 牛奶、黄油、奶酪、酸奶... |
| 调味品 | 10 | 盐、糖、酱油、醋、辣椒... |
| 其他 | 8 | 鸡蛋、水、油、面粉... |

**设备扩展**: 保持 3 种基础设备

**配方扩展**: 扩展到 20+ 种配方

---

## 5. 性能优化

**决策**: 一般性优化

**优化点**:
- 确保稳定 60 FPS
- 优化场景加载时间
- 减少不必要的节点创建

---

## 验收标准

- [ ] SaveData Codec 定义完成
- [ ] 自动保存功能正常
- [ ] UI 音效播放正常
- [ ] 单元测试通过
- [ ] 60+ 种材料数据可加载
- [ ] 20+ 种配方数据可加载
- [ ] 稳定 60 FPS
- [ ] 无运行时错误

---

## 下一步

运行 `/gsd-plan-phase 5` 进行详细任务规划。