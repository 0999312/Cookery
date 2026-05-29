# Cookery 测试分析

> 最后更新：2026/05/29
> 分析范围：项目根目录、.gutconfig.json、addons/gut/

---

## 1. 测试框架配置

### 1.1 框架选择

| 框架 | 版本 | 用途 |
|------|------|------|
| **GUT** (GDScript Unit Testing) | v9.6.0 | GDScript 单元测试框架 |

### 1.2 配置文件

**位置：** `.gutconfig.json`

```json
{
    "dirs": ["res://tests/"],
    "include_subdirs": true,
    "prefix": "test_",
    "suffix": ".gd",
    "log_level": 1,
    "double_strategy": "SCRIPT_ONLY"
}
```

**配置说明：**

| 参数 | 值 | 说明 |
|------|-----|------|
| `dirs` | `["res://tests/"]` | 测试文件目录 |
| `include_subdirs` | `true` | 递归搜索子目录 |
| `prefix` | `"test_"` | 测试文件前缀 |
| `suffix` | `".gd"` | 测试文件后缀 |
| `log_level` | `1` | 日志级别（1 = 基本） |
| `double_strategy` | `"SCRIPT_ONLY"` | Mock 策略（仅脚本） |

### 1.3 插件配置

**位置：** `addons/gut/plugin.cfg`

```ini
[plugin]
name="GUT"
description="GDScript Unit Testing framework"
author="Tom \"Butch\" Wesley"
version="9.6.0"
script="gut_plugin.gd"
```

---

## 2. 测试结构

### 2.1 目录结构

```
cookery/
├── .gutconfig.json          # GUT 配置
├── addons/
│   └── gut/                 # GUT 插件源码
│       ├── plugin.cfg
│       ├── gut_plugin.gd
│       └── ...
└── tests/                   # 测试目录（待创建）
    ├── unit/                # 单元测试
    │   ├── test_event_bus.gd
    │   ├── test_ui_manager.gd
    │   └── ...
    ├── integration/         # 集成测试
    │   ├── test_save_load.gd
    │   └── ...
    └── test_runner.gd       # 测试运行器（可选）
```

### 2.2 测试文件命名

| 类型 | 约定 | 示例 |
|------|------|------|
| 测试文件 | `test_` 前缀 + `snake_case.gd` | `test_event_bus.gd` |
| 测试类 | 继承 `GutTest` | `extends GutTest` |
| 测试方法 | `test_` 前缀 | `func test_subscribe():` |

### 2.3 测试组织

**推荐结构：**
```gdscript
extends GutTest

# 常量
const EventBus = preload("res://scripts/autoloads/event_bus.gd")

# 变量
var _event_bus: Node

# 生命周期
func before_each():
    _event_bus = EventBus.new()
    add_child(_event_bus)

func after_each():
    _event_bus.queue_free()

# 测试方法
func test_subscribe():
    # 准备
    var listener = func(): pass
    
    # 执行
    _event_bus.subscribe("test_event", listener)
    
    # 断言
    assert_true(_event_bus._listeners.has("test_event"))

func test_publish():
    # 准备
    var received = false
    var listener = func(): received = true
    _event_bus.subscribe("test_event", listener)
    
    # 执行
    _event_bus.publish("test_event")
    
    # 断言
    assert_true(received)
```

---

## 3. 测试策略

### 3.1 测试金字塔

```
         /\
        /  \        E2E 测试（少量）
       /    \       - 完整游戏流程
      /------\
     /        \     集成测试（适量）
    /          \    - 系统间交互
   /------------\
  /              \  单元测试（大量）
 /                \ - 单个函数/类
/__________________\
```

### 3.2 测试类型

#### 单元测试

**目标：** 测试单个函数或类的行为

**示例场景：**
- EventBus 订阅/发布
- UIManager 面板打开/关闭
- AudioManager 音量控制
- SaveManager 存档验证

**原则：**
- 每个测试只测试一个行为
- 测试独立，不依赖外部状态
- 使用 `before_each()` 和 `after_each()` 清理状态

#### 集成测试

**目标：** 测试多个系统间的交互

**示例场景：**
- 存档保存后加载验证
- UI 面板打开触发事件
- 音频请求正确播放

**原则：**
- 测试真实系统交互
- 可以使用 Mock 替代外部依赖
- 验证端到端流程

#### E2E 测试

**目标：** 测试完整用户流程

**示例场景：**
- 启动游戏 → 开始新游戏 → 保存 → 加载
- 打开设置 → 修改音量 → 保存设置

**原则：**
- 少量关键路径
- 自动化执行
- 验证用户体验

### 3.3 测试覆盖目标

| 模块 | 目标覆盖率 | 优先级 |
|------|------------|--------|
| EventBus | 90%+ | 高 |
| UIManager | 80%+ | 高 |
| AudioManager | 70%+ | 中 |
| SaveManager | 80%+ | 高 |
| 游戏逻辑 | 60%+ | 中 |
| UI 面板 | 50%+ | 低 |

### 3.4 Mock 策略

**GUT Mock 功能：**
```gdscript
# 创建 Mock
var mock_audio = double(AudioStreamPlayer).new()
stub(mock_audio, "play").to_do_nothing()

# 验证调用
assert_called(mock_audio, "play")
assert_call_count(mock_audio, "play", 1)
```

**Mock 使用场景：**
- 文件系统操作（存档/读档）
- 音频播放
- 网络请求
- 外部 API 调用

---

## 4. 现有测试

### 4.1 当前状态

**测试目录：** `tests/` — **未创建**

**测试文件数量：** 0

**测试覆盖率：** 0%

### 4.2 缺失原因

项目处于早期开发阶段，优先实现核心功能，测试尚未编写。

### 4.3 建议测试清单

#### 高优先级（核心系统）

| 测试文件 | 测试目标 | 测试数量 |
|----------|----------|----------|
| `test_event_bus.gd` | EventBus 订阅/发布/取消 | 10+ |
| `test_ui_manager.gd` | UIManager 面板生命周期 | 15+ |
| `test_save_manager.gd` | 存档保存/加载/验证 | 12+ |
| `test_audio_manager.gd` | 音频播放/音量控制 | 8+ |

#### 中优先级（游戏逻辑）

| 测试文件 | 测试目标 | 测试数量 |
|----------|----------|----------|
| `test_cooking_system.gd` | 烹饪配方/属性变换 | 10+ |
| `test_inventory.gd` | 物品管理/堆叠 | 8+ |
| `test_recipe_codex.gd` | 图鉴解锁/查询 | 6+ |
| `test_equipment.gd` | 设备交互/升级 | 6+ |

#### 低优先级（UI 面板）

| 测试文件 | 测试目标 | 测试数量 |
|----------|----------|----------|
| `test_main_menu.gd` | 主菜单按钮响应 | 5+ |
| `test_settings_panel.gd` | 设置保存/应用 | 5+ |
| `test_pause_menu.gd` | 暂停/恢复逻辑 | 4+ |

---

## 5. 测试最佳实践

### 5.1 测试命名

**格式：** `test_<功能>_<场景>_<预期结果>`

**示例：**
```gdscript
func test_subscribe_when_listener_already_exists_should_not_duplicate():
    pass

func test_open_panel_when_panel_already_open_should_return_existing():
    pass

func test_save_game_when_file_write_fails_should_emit_false():
    pass
```

### 5.2 测试结构（AAA 模式）

```gdscript
func test_example():
    # Arrange（准备）
    var input = "test"
    var expected = "TEST"
    
    # Act（执行）
    var result = to_upper(input)
    
    # Assert（断言）
    assert_eq(result, expected)
```

### 5.3 测试隔离

**原则：**
- 每个测试独立运行
- 不依赖测试执行顺序
- 使用 `before_each()` 重置状态

**示例：**
```gdscript
var _event_bus: Node

func before_each():
    # 每个测试前创建新实例
    _event_bus = EventBus.new()
    add_child(_event_bus)

func after_each():
    # 每个测试后清理
    _event_bus.queue_free()
```

### 5.4 断言方法

**GUT 常用断言：**

| 方法 | 用途 | 示例 |
|------|------|------|
| `assert_eq(a, b)` | 相等 | `assert_eq(result, 10)` |
| `assert_ne(a, b)` | 不等 | `assert_ne(result, null)` |
| `assert_true(val)` | 真 | `assert_true(is_valid)` |
| `assert_false(val)` | 假 | `assert_false(is_error)` |
| `assert_null(val)` | 空 | `assert_null(result)` |
| `assert_not_null(val)` | 非空 | `assert_not_null(node)` |
| `assert_gt(a, b)` | 大于 | `assert_gt(score, 0)` |
| `assert_lt(a, b)` | 小于 | `assert_lt(health, 100)` |
| `assert_between(val, low, high)` | 范围 | `assert_between(volume, 0, 1)` |
| `assert_called(obj, method)` | 调用验证 | `assert_called(mock, "play")` |
| `assert_signal_emitted(obj, sig)` | 信号验证 | `assert_signal_emitted(bus, "fired")` |

### 5.5 异步测试

```gdscript
func test_async_operation():
    # 使用 await 等待异步操作
    await get_tree().create_timer(0.1).timeout
    
    # 断言
    assert_true(operation_completed)
```

### 5.6 信号测试

```gdscript
func test_signal_emission():
    # 监听信号
    watch_signals(_event_bus)
    
    # 触发操作
    _event_bus.emit_game_started()
    
    # 验证信号
    assert_signal_emitted(_event_bus, "game_started")
```

---

## 6. 测试工具配置

### 6.1 GUT 编辑器插件

**启用方式：**
1. 打开 Godot 编辑器
2. 项目 → 项目设置 → 插件
3. 启用 "GUT" 插件

**使用方式：**
- 底部面板出现 "GUT" 标签
- 点击 "Run All" 运行所有测试
- 点击单个测试文件运行特定测试

### 6.2 命令行运行

```bash
# 运行所有测试
godot -s addons/gut/gut_cmdln.gd -gdir=res://tests

# 运行特定目录
godot -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit

# 运行特定文件
godot -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit/test_event_bus.gd
```

### 6.3 CI/CD 集成

**GitHub Actions 示例：**
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.6.2
          
      - name: Run Tests
        run: godot -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

---

## 7. 测试覆盖率

### 7.1 覆盖率工具

**GUT 内置覆盖率：**
- GUT 9.x 支持基本的代码覆盖率报告
- 配置 `.gutconfig.json` 启用

**第三方工具：**
- `gdscript-coverage` — 社区覆盖率工具
- `gdUnit4` — 替代测试框架，内置覆盖率

### 7.2 覆盖率目标

| 阶段 | 目标 | 说明 |
|------|------|------|
| 原型阶段 | 30%+ | 核心系统基本覆盖 |
| Alpha 阶段 | 50%+ | 主要功能覆盖 |
| Beta 阶段 | 70%+ | 边界情况覆盖 |
| 发布阶段 | 80%+ | 高质量保障 |

---

## 8. 测试数据管理

### 8.1 测试夹具（Fixtures）

**位置：** `tests/fixtures/`

**用途：**
- 存储测试用的 Resource 文件
- JSON 测试数据
- 场景快照

**示例：**
```
tests/
└── fixtures/
    ├── saves/
    │   ├── valid_save.json
    │   ├── corrupted_save.json
    │   └── old_version_save.json
    ├── recipes/
    │   ├── simple_recipe.tres
    │   └── complex_recipe.tres
    └── materials/
        ├── basic_material.tres
        └── rare_material.tres
```

### 8.2 测试数据生成

```gdscript
# 创建测试用的 Resource
func _create_test_recipe() -> Resource:
    var recipe = RecipeData.new()
    recipe.id = "test_recipe"
    recipe.name = "Test Recipe"
    recipe.ingredients = ["flour", "water"]
    return recipe
```

---

## 9. 测试维护

### 9.1 测试审查清单

- [ ] 测试命名清晰
- [ ] 测试独立运行
- [ ] 断言明确
- [ ] 无硬编码路径
- [ ] Mock 使用合理
- [ ] 测试数据可维护

### 9.2 测试重构

**何时重构：**
- 测试重复代码过多
- 测试难以理解
- 测试经常失败（脆弱测试）
- 测试覆盖不足

**重构方法：**
- 提取公共测试辅助函数
- 使用测试基类
- 改进测试命名
- 添加测试注释

---

## 10. 参考资料

- [GUT 文档](https://gut.readthedocs.io/) — 官方文档
- [GUT GitHub](https://github.com/bitwes/Gut) — 源码仓库
- [Godot 测试最佳实践](https://docs.godotengine.org/en/stable/tutorials/best_practices/) — 官方指南
- [gdUnit4](https://github.com/MikeSchulze/gdUnit4) — 替代测试框架

---

## 11. 快速开始

### 11.1 创建第一个测试

1. 创建目录：`tests/unit/`
2. 创建文件：`tests/unit/test_example.gd`
3. 编写测试：

```gdscript
extends GutTest

func test_example():
    assert_eq(1 + 1, 2)
```

4. 运行测试：GUT 面板 → Run All

### 11.2 测试 EventBus

```gdscript
extends GutTest

const EventBus = preload("res://scripts/autoloads/event_bus.gd")

var _event_bus: Node

func before_each():
    _event_bus = EventBus.new()
    add_child(_event_bus)

func after_each():
    _event_bus.queue_free()

func test_subscribe_adds_listener():
    var listener = func(): pass
    _event_bus.subscribe("test", listener)
    assert_true(_event_bus._listeners.has("test"))

func test_publish_calls_listener():
    var received = false
    var listener = func(): received = true
    _event_bus.subscribe("test", listener)
    _event_bus.publish("test")
    assert_true(received)
```

---

## 12. 当前状态总结

| 项目 | 状态 | 说明 |
|------|------|------|
| 测试框架 | ✅ 已配置 | GUT v9.6.0 已安装 |
| 测试目录 | ❌ 未创建 | 需要创建 `tests/` |
| 测试文件 | ❌ 无 | 需要编写测试 |
| 覆盖率 | ❌ 0% | 需要逐步提升 |
| CI/CD | ❌ 未配置 | 建议添加 GitHub Actions |

**下一步行动：**
1. 创建 `tests/` 目录结构
2. 编写核心系统单元测试
3. 配置测试覆盖率报告
4. 集成 CI/CD 自动测试
