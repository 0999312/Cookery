# 集成分析 — Cookery

## MCP 服务器

项目配置了两个 MCP 服务器，分别在 `.mcp.json`（Claude Code）和 `opencode.json`（OpenCode）中声明。

### godot-docs

| 项目 | 值 |
|------|-----|
| 包名 | `@fernforestgames/mcp-server-godot-docs` |
| 类型 | stdio |
| 启动命令 | `npx -y @fernforestgames/mcp-server-godot-docs` |
| 环境变量 | `GODOT_PATH=E:/godot_learning/Godot_v4.6.2-stable_mono_win64/godot.exe` |
| 用途 | 查询 Godot 官方文档（类、方法、属性、信号、常量） |
| Claude Code 状态 | 已启用（`.claude/settings.local.json` → `enabledMcpjsonServers`） |

### godot-mcp

| 项目 | 值 |
|------|-----|
| 包名 | `@coding-solo/godot-mcp` |
| 类型 | stdio |
| 启动命令 | `npx -y @coding-solo/godot-mcp` |
| 环境变量 | `GODOT_PATH=...`, `DEBUG=true` |
| 用途 | 编辑器级操作：场景创建/保存、节点添加、项目运行/停止、MeshLibrary 导出、UID 管理 |
| OpenCode 状态 | 已启用（`opencode.json` → `mcp.godot-mcp.enabled=true`） |

## Claude Code 配置

### settings.local.json

```json
{
  "permissions": {
    "allow": ["WebSearch"]
  },
  "enabledMcpjsonServers": ["godot-docs"],
  "enableAllProjectMcpServers": true
}
```

- 允许 WebSearch 工具调用
- 启用 `.mcp.json` 中的 `godot-docs` 服务器
- 启用所有项目级 MCP 服务器

### CLAUDE.md

- 项目指令文件，定义了完整的架构约束、编码规范、工具优先级、反模式列表
- 强制中文交流语言
- 强制使用 mc_game_framework 的 EventBus/UIManager/Registry/Codec
- 强制通过 GUIDE 上下文系统处理输入
- 强制使用 Resource 子类作为运行时数据权威

## OpenCode 配置

| 项目 | 值 |
|------|-----|
| 配置文件 | `opencode.json` |
| 指令文件 | `AGENTS.md` |
| 权限 | `skill: allow` |
| MCP 服务器 | `godot-docs`（local）、`godot-mcp`（local，DEBUG=true） |

## Skills 配置

### game-architect

| 项目 | 值 |
|------|-----|
| 路径 | `.claude/skills/game-architect/SKILL.md` |
| 用途 | 架构范式选择指导（DDD / Data-Driven / Prototype） |
| 触发场景 | 设计或规划任何游戏系统架构时 |

### GodotPrompter（OpenCode 插件）

| 项目 | 值 |
|------|-----|
| 来源 | `godot-prompter@git+https://github.com/jame581/GodotPrompter.git` |
| 安装方式 | OpenCode plugin 系统 |
| 提供的 Skills 数量 | 30+ |
| 覆盖领域 | 2D/3D、UI、输入、动画、音频、物理、存档、本地化、测试、导出、调试等 |

GodotPrompter 提供的完整 Skills 列表：

| Skill ID | 领域 |
|----------|------|
| `godot-prompter:2d-essentials` | 2D 系统（TileMap、视差、灯光） |
| `godot-prompter:3d-essentials` | 3D 系统（材质、光照、LOD、雾效） |
| `godot-prompter:addon-development` | 编辑器插件开发 |
| `godot-prompter:animation-system` | 动画系统 |
| `godot-prompter:assets-pipeline` | 资产导入管线 |
| `godot-prompter:audio-system` | 音频系统 |
| `godot-prompter:camera-system` | 相机系统 |
| `godot-prompter:component-system` | 组件系统 |
| `godot-prompter:csharp-godot` | C# 集成（本项目不使用） |
| `godot-prompter:csharp-signals` | C# 信号（本项目不使用） |
| `godot-prompter:dedicated-server` | 专用服务器 |
| `godot-prompter:dependency-injection` | 依赖注入 |
| `godot-prompter:dialogue-system` | 对话系统 |
| `godot-prompter:event-bus` | 事件总线 |
| `godot-prompter:export-pipeline` | 导出管线 |
| `godot-prompter:gdscript-advanced` | GDScript 高级模式 |
| `godot-prompter:gdscript-patterns` | GDScript 基础模式 |
| `godot-prompter:godot-brainstorming` | 功能设计头脑风暴 |
| `godot-prompter:godot-code-review` | 代码审查 |
| `godot-prompter:godot-debugging` | 调试技术 |
| `godot-prompter:godot-optimization` | 性能优化 |
| `godot-prompter:godot-project-setup` | 项目初始化 |
| `godot-prompter:godot-testing` | 测试框架（GUT/gdUnit4） |
| `godot-prompter:godot-ui` | UI 构建 |
| `godot-prompter:hud-system` | HUD 系统 |
| `godot-prompter:input-handling` | 输入处理 |
| `godot-prompter:inventory-system` | 库存系统 |
| `godot-prompter:localization` | 本地化 |
| `godot-prompter:math-essentials` | 数学基础 |
| `godot-prompter:multiplayer-basics` | 多人联机基础 |
| `godot-prompter:multiplayer-sync` | 多人同步 |
| `godot-prompter:particles-vfx` | 粒子特效 |
| `godot-prompter:physics-system` | 物理系统 |
| `godot-prompter:player-controller` | 玩家控制器 |
| `godot-prompter:procedural-generation` | 程序化生成 |
| `godot-prompter:resource-pattern` | Resource 数据模式 |
| `godot-prompter:responsive-ui` | 响应式 UI |
| `godot-prompter:save-load` | 存档系统 |
| `godot-prompter:scene-organization` | 场景组织 |
| `godot-prompter:shader-basics` | Shader 基础 |
| `godot-prompter:state-machine` | 状态机 |
| `godot-prompter:tween-animation` | Tween 动画 |
| `godot-prompter:xr-development` | XR 开发 |
| `godot-prompter:using-godot-prompter` | 引导/入门 |

## 工具优先级

项目在 `AGENTS.md` 中定义了严格的工具调用优先级：

1. **MCP: godot-docs** — 查阅 Godot 官方文档
2. **MCP: godot-mcp** — 场景/节点编辑器操作
3. **Skills: GodotPrompter** — 领域专项指导
4. **Skills: game-architect** — 架构设计
5. **插件源码** — 直接阅读 `addons/` 源码
6. **自行推理** — 基于 Godot 4.x 惯用法

## GSD 工作流集成

项目配置了 GSD（Get Stuff Done）工作流系统，通过 Claude Code 的 skills 机制集成：

- 入口命令：`/gsd-quick`（小任务）、`/gsd-debug`（调试）、`/gsd-execute-phase`（阶段执行）
- 要求所有文件修改通过 GSD 工作流发起，保持规划产物和执行上下文同步
- `CLAUDE.md` 中强制声明了此约束

## 外部原型

| 项目 | 值 |
|------|-----|
| 路径 | `prototype/web/` |
| 技术栈 | HTML5 / CSS3 / JavaScript |
| 用途 | Web 端玩法验证原型（1900 行 JS、60+ 配方、3 种设备） |
| 运行方式 | `python -m http.server 8000` |
| 数据对齐要求 | Godot 项目的配方/材料数据必须与 Web 原型完全一致 |
