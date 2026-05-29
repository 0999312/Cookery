# 项目清理记录

> 记录通用内容提取和项目特定内容清空的更改

## 更改概述

**日期**：2026/05/29
**目的**：提取通用内容用于工作流复用，清空项目特定内容

## 执行的操作

### 1. 创建通用内容文件夹

创建了 `common/` 文件夹，包含以下子目录：

```
common/
├── addons/          # Godot 插件
├── assets/          # 通用资源
├── config/          # ClaudeCode/OpenCode 配置
├── git/             # Git 相关配置
├── skills/          # MCP 和 Skills 工具
└── tools/           # 工具脚本
```

### 2. 复制通用内容

#### addons/ - Godot 插件
- `mc_game_framework` v1.0.0 - 核心框架
- `guide` v0.13.0 - 输入映射系统
- `dialogue_manager` v3.10.4 - 对话系统
- `sound_manager` v2.6.1 - 音频管理
- `gut` v9.6.0 - 测试框架
- `kenney_interface_sounds` - UI 音效素材

#### config/ - 配置文件
- `.claude/settings.local.json` - ClaudeCode 配置
- `opencode.json` - OpenCode 配置
- `.mcp.json` - MCP 服务器配置
- `skills/` - Skills 目录（game-architect）

#### git/ - Git 配置
- `.gitignore` - Git 忽略规则
- `.gitattributes` - Git 属性配置
- `.editorconfig` - 编辑器配置

#### assets/ - 通用资源
- `fonts/` - MiSans Semibold 字体
- `icons/` - 单色 SVG 矢量图标
- `theme/` - 极简矢量主题

#### tools/ - 工具脚本
- `generate_guide_context.gd` - GUIDE 上下文生成工具

### 3. 清空项目特定内容

删除了以下目录和文件：

#### 删除的目录
- `data/` - 游戏数据
- `scenes/` - 游戏场景
- `scripts/` - 游戏脚本
- `events/` - 事件定义
- `input/` - 输入配置
- `prototype/` - 原型代码
- `tests/` - 测试文件
- `.planning/` - 项目规划
- `.godot/` - Godot 生成的文件
- `docs/` - 项目文档

#### 删除的文件
- `project.godot` - Godot 项目配置
- `icon.svg` - 项目图标
- `icon.svg.import` - 图标导入文件

## 保留的通用内容

清理后的项目结构只包含通用内容：

```
.
├── .claude/                # ClaudeCode 配置
├── .editorconfig           # 编辑器配置
├── .git/                   # Git 仓库
├── .gitattributes          # Git 属性
├── .gitignore              # Git 忽略规则
├── .gutconfig.json         # 测试框架配置
├── .mcp.json               # MCP 服务器配置
├── .opencode/              # OpenCode 配置
├── AGENTS.md               # Agent 指令
├── CLAUDE.md               # ClaudeCode 项目指令
├── addons/                 # Godot 插件
├── assets/                 # 通用资源
├── common/                 # 通用内容文件夹（新增）
├── opencode.json           # OpenCode 配置
└── tools/                  # 工具脚本
```

## 使用说明

### 复制通用内容到新项目

```bash
# 复制通用内容
cp -r common/addons <新项目目录>/
cp -r common/assets <新项目目录>/
cp -r common/config/.claude <新项目目录>/
cp -r common/config/.opencode <新项目目录>/
cp common/config/opencode.json <新项目目录>/
cp common/config/.mcp.json <新项目目录>/
cp common/git/.gitignore <新项目目录>/
cp common/git/.gitattributes <新项目目录>/
cp common/git/.editorconfig <新项目目录>/
```

### 自定义配置

1. 修改 `.mcp.json` 和 `opencode.json` 中的 `GODOT_PATH`
2. 调整 `.claude/settings.local.json` 中的权限设置
3. 根据项目需要添加新的 Skills

## 注意事项

1. **路径配置**：使用前请修改配置文件中的绝对路径
2. **版本兼容**：确保 addons 版本与 Godot 引擎版本兼容
3. **资源引用**：根据新项目结构调整资源引用路径
4. **Skills 更新**：定期检查 Skills 是否有新版本

## Git 状态

清理后的 Git 状态显示：
- 大量项目特定文件被删除
- 通用内容文件被标记为未跟踪
- 新增的 `common/` 文件夹包含所有通用内容

## 后续步骤

1. 根据需要创建新的 Godot 项目
2. 复制通用内容到新项目
3. 配置项目特定的路径和设置
4. 开始新的开发工作

---

*最后更新：2026/05/29*