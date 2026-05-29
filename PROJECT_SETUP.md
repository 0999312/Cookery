# 项目设置总结

> Godot 4.6 项目初始化完成

## 项目信息

| 项目 | 值 |
|------|-----|
| 项目名称 | Cookery |
| 项目描述 | 基于设备即界面理念的沙盒烹饪游戏 |
| Godot 版本 | 4.6 |
| 渲染方法 | Mobile |
| 基础分辨率 | 1920x1080 |
| 输入系统 | GUIDE 插件 |

## 目录结构

```
res://
├── assets/                    # 资源文件
│   ├── audio/                 # 音频文件
│   │   ├── music/            # 背景音乐
│   │   └── sfx/              # 音效
│   ├── fonts/                # 字体文件
│   ├── shaders/              # 着色器
│   ├── sprites/              # 精灵图
│   │   ├── characters/       # 角色精灵
│   │   ├── environment/      # 环境精灵
│   │   └── ui/               # UI 精灵
│   ├── textures/             # 纹理
│   └── theme/                # 主题资源
├── scenes/                    # 场景文件
│   ├── autoloads/            # 自动加载场景
│   ├── characters/           # 角色场景
│   ├── environment/          # 环境场景
│   ├── levels/               # 关卡场景
│   ├── screens/              # 屏幕场景（主菜单等）
│   └── ui/                   # UI 场景
├── scripts/                   # 脚本文件
│   ├── autoloads/            # 自动加载脚本
│   ├── characters/           # 角色脚本
│   ├── components/           # 组件脚本
│   ├── resources/            # 资源脚本
│   └── ui/                   # UI 脚本
├── resources/                 # 资源定义
│   ├── items/                # 物品资源
│   ├── levels/               # 关卡资源
│   └── themes/               # 主题资源
├── addons/                    # 插件
├── common/                    # 通用内容（工作流复用）
└── tools/                     # 工具脚本
```

## 自动加载

| 名称 | 路径 | 用途 |
|------|------|------|
| `EventBus` | `scripts/autoloads/event_bus.gd` | 跨系统事件通信 |
| `UIManager` | `scripts/autoloads/ui_manager.gd` | UI 面板管理 |
| `AudioManager` | `scripts/autoloads/audio_manager.gd` | 音频播放管理 |
| `SaveManager` | `scripts/autoloads/save_manager.gd` | 存档管理 |

## 输入映射

| 动作 | 按键 | 用途 |
|------|------|------|
| `pause` | Escape | 暂停游戏 |
| `move_left` | A | 向左移动 |
| `move_right` | D | 向右移动 |
| `move_up` | W | 向上移动 |
| `move_down` | S | 向下移动 |
| `interact` | E | 交互 |
| `confirm` | Enter | 确认 |
| `cancel` | Escape | 取消 |

## 物理层

| 层 | 名称 | 用途 |
|----|------|------|
| 1 | Player | 玩家 |
| 2 | Environment | 环境 |
| 3 | Items | 物品 |
| 4 | UI | UI |
| 5 | Interactable | 可交互对象 |

## 插件

| 插件 | 版本 | 用途 |
|------|------|------|
| `mc_game_framework` | v1.0.0 | 核心框架 |
| `guide` | v0.13.0 | 输入映射系统 |
| `dialogue_manager` | v3.10.4 | 对话系统 |
| `sound_manager` | v2.6.1 | 音频管理 |
| `gut` | v9.6.0 | 测试框架 |
| `kenney_interface_sounds` | - | UI 音效素材 |

## 通用内容

通用内容已提取到 `common/` 文件夹，包含：
- addons/ - Godot 插件
- assets/ - 通用资源（字体、图标、主题）
- config/ - ClaudeCode/OpenCode 配置
- git/ - Git 相关配置
- skills/ - MCP 和 Skills 工具
- tools/ - 工具脚本

## 下一步

1. **创建游戏场景**：在 `scenes/` 目录下创建游戏主场景
2. **实现玩家控制**：在 `scripts/characters/` 目录下创建玩家脚本
3. **设计 UI 界面**：在 `scenes/ui/` 目录下创建 UI 面板
4. **添加游戏资源**：在 `assets/` 目录下添加精灵、音频等资源
5. **实现游戏逻辑**：在 `scripts/` 目录下实现游戏系统

## 配置文件

- `project.godot` - Godot 项目配置
- `.gitignore` - Git 忽略规则
- `.gitattributes` - Git 属性配置
- `.editorconfig` - 编辑器配置
- `.mcp.json` - MCP 服务器配置
- `opencode.json` - OpenCode 配置
- `.claude/settings.local.json` - ClaudeCode 配置

---

*创建时间：2026/05/29*