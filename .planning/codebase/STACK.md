# 技术栈分析 — Cookery

## 引擎

| 项目 | 值 |
|------|-----|
| 引擎 | Godot 4.6.2 stable |
| 二进制路径 | `E:/godot_learning/Godot_v4.6.2-stable_mono_win64/godot.exe` |
| 功能标签 | `4.6`, `Mobile` |
| 配置版本 | `config_version=5` |
| 主场景 | `res://scenes/screens/main_menu.tscn` |

> 虽然下载的是 mono 版本（含 C# 支持），但项目完全使用 GDScript，不涉及 C# 代码。

## 渲染配置

| 项目 | 值 | 说明 |
|------|-----|------|
| 渲染方法 | `mobile` | 针对低端设备优化 |
| 渲染驱动 (Windows) | D3D12 | 在 `project.godot` 中通过命令行/环境配置 |
| 窗口分辨率 | 1920 x 1080 | 基准分辨率 |
| 拉伸模式 | `canvas_items` | 画布内容拉伸 |
| 拉伸比例 | `keep` | 保持宽高比 |
| 窗口可调整大小 | 是 | |
| VSync | 关闭 (0) | 开发阶段关闭以测帧率 |
| 纹理过滤 | 最近邻 (0) | 像素级精确，配合扁平化矢量风格 |
| 默认背景色 | `Color(0.12, 0.14, 0.18, 1)` | 深蓝灰色 |

## 物理配置

| 项目 | 值 |
|------|-----|
| 3D 物理引擎 | Jolt Physics（通过项目设置覆盖 GodotPhysics3D） |
| 2D 重力 | 980.0（向下） |
| 2D 物理层 | Layer 1: Player, Layer 2: Environment, Layer 3: Items, Layer 4: UI, Layer 5: Interactable |

## Autoload 单元

| 单例名 | 脚本路径 | 职责 |
|--------|----------|------|
| `EventBus` | `res://scripts/autoloads/event_bus.gd` | 跨系统信号通信（游戏/场景/物品/UI/音频/存档/烹饪/设备事件） |
| `UIManager` | `res://scripts/autoloads/ui_manager.gd` | UI 面板栈管理（打开/关闭/暂停/恢复/缓存） |
| `AudioManager` | `res://scripts/autoloads/audio_manager.gd` | 音频播放管理 |
| `SaveManager` | `res://scripts/autoloads/save_manager.gd` | 存档/读档 |

> 注意：项目同时注册了自定义 Autoload 和 mc_game_framework 的 Autoload（如 `RegistryManager`、`I18NManager`），两套并存。

## 插件（Editor Plugins）

| 插件 | 版本 | 作者 | 用途 | Autoload |
|------|------|------|------|----------|
| mc_game_framework (MinecraftStyleFramework) | 1.0.0 | SyameimaruZheng | 核心框架：EventBus、UIManager、I18N、Registry、Tag、Component、Codec | `RegistryManager`, `EventBus`(addon), `UIManager`(addon), `I18NManager` |
| GUIDE (Godot Unified Input Detection Engine) | 0.13.0 | Jan Thoma | 输入映射与上下文系统，替代原生 Input Map | `GUIDE` |
| dialogue_manager | 3.10.4 | Nathan Hoad | 非线性分支对话系统 | `DialogueManager` |
| sound_manager | 2.6.1 | Nathan Hoad | 音乐/音效/环境音管理与混音 | `SoundManager` |
| gut (GUT) | 9.6.0 | Butch Wesley | GDScript 单元测试框架 | 无（编辑器插件） |
| kenney_interface_sounds | 无版本号 | Kenney | 预制 UI 音效素材包（100+ WAV 文件） | 无（纯资源） |

## 输入映射

项目在 `project.godot` 中定义了以下 Input Map 动作（供 GUIDE 系统使用）：

| 动作 | 默认按键 |
|------|----------|
| `pause` | Escape |
| `move_left` | A |
| `move_right` | D |
| `move_up` | W |
| `move_down` | S |
| `interact` | E |
| `confirm` | Enter |
| `cancel` | Escape |

## 目标平台

| 平台 | 状态 |
|------|------|
| Windows (主开发平台) | 开发中 |
| macOS | 计划支持 |
| Linux | 计划支持 |
| 移动端 (iOS/Android) | 未来考虑，需重新设计交互 |

## 语言与编码

| 项目 | 值 |
|------|-----|
| 游戏逻辑语言 | GDScript（静态类型） |
| 注释/文档语言 | 中文 |
| 文件编码 | UTF-8 |
| 行尾符 | LF（`.editorconfig` + `.gitattributes` 强制） |
