<!-- GSD:project-start source:PROJECT.md -->
## Project

**Cookery（厨房）**

基于"设备即界面"理念的沙盒烹饪游戏。玩家自由搭配材料与制作设备，通过属性标签的变换/组合/消除/增幅，涌现出意料之外的料理成品。没有固定配方表，只有属性逻辑驱动的发现式玩法。目标是将已验证的 Web 原型（1900行JS、60+配方、3种设备、谱系/分类/图鉴系统）迁移到 Godot 4.6 引擎，产出可交互的 PC 端游戏原型。

**Core Value:** 设备作为界面 — 材料通过设备的属性变换产生涌现式结果，玩家通过实验和发现来推进游戏。如果这个核心循环不成立，其他一切都没有意义。

### Constraints

- **语言**：所有代码使用GDScript，静态类型，中文注释/文档
- **交流语言**：所有思考与输出均使用中文
- **框架优先**：必须使用mc_game_framework的EventBus/UIManager/Registry/Codec，不得绕过
- **输入系统**：必须通过GUIDE上下文系统，不得直接使用Input.is_action_*
- **数据驱动**：游戏数据用Resource子类定义，JSON仅用于外部编辑
- **原型对齐**：配方数据、材料数据必须与Web原型完全一致，不得自行增删
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- GDScript - All game logic, UI, systems, and addon code (`*.gd` files throughout project)
- No C# usage despite `dialogue_manager` and `sound_manager` addons including `.cs` files (GDScript-only project)
- HTML5/CSS3/JavaScript - Web prototype for gameplay validation (已删除，数据已迁移到 Godot)
- JSON - Data files for i18n translations, mod support (`addons/mc_game_framework/autoload/i18n_manager.gd`)
## Runtime
- Godot Engine 4.6 (stable) - `config/features=PackedStringArray("4.6", "Mobile")` in `project.godot`
- Windows 11 (development platform) - Godot binary at `E:/godot_learning/Godot_v4.6.2-stable_mono_win64/godot.exe`
- None (Godot uses built-in asset management; addons are vendored in `addons/`)
- No lockfile (addon versions tracked via `plugin.cfg`)
## Frameworks
- Godot 4.6 - Game engine with mobile rendering method (`project.godot:15`)
- Jolt Physics - 3D physics engine override (`project.godot:19`)
- mc_game_framework v1.0.0 - Minecraft-style game framework with EventBus, UIManager, I18N, Registry, Tag, Component systems (`addons/mc_game_framework/plugin.cfg`)
- dialogue_manager v3.10.4 - Nonlinear dialogue system with branching and conditions (`addons/dialogue_manager/plugin.cfg`)
- guide v0.13.0 - Input mapping and context system (replaces native Input Map) (`addons/guide/plugin.cfg`)
- sound_manager v2.6.1 - Music, sound effects, and ambient audio management (`addons/sound_manager/plugin.cfg`)
- gut v9.6.0 - GDScript unit testing framework (`addons/gut/plugin.cfg`)
- kenney_interface_sounds - Pre-made UI sound effects asset pack (`addons/kenney_interface_sounds/`)
- MCP servers for Godot documentation and editor operations (`.mcp.json`, `opencode.json`)
- GodotPrompter plugin for domain-specific guidance (`opencode.json:11`)
- game-architect skill for architecture decisions (`.claude/skills/game-architect/SKILL.md`)
## Key Dependencies
- `mc_game_framework` - Provides core architecture: EventBus for cross-system communication, UIManager for panel stack management, I18N for localization, Registry for data registration, Tag system, Component system (`addons/mc_game_framework/`)
- `guide` - All input handling must go through GUIDE context system, not direct `Input.is_action_*` (`addons/guide/`)
- `dialogue_manager` - Required for narrative system (story mode dialogue) (`addons/dialogue_manager/`)
- `sound_manager` - All audio playback (music, SFX, ambient) (`addons/sound_manager/`)
- `ResourceLocation` - Minecraft-style `namespace:path` identifier used throughout framework (`addons/mc_game_framework/utils/resource_location.gd`)
- `DataResult` - Result type for error handling in codec operations (`addons/mc_game_framework/codec/core/data_result.gd`)
- `Codec` - Serialization/deserialization system for Resource data (`addons/mc_game_framework/codec/core/codec.gd`)
## Configuration
- `project.godot` - Engine config: 4.6 Mobile features, Jolt Physics, D3D12 renderer on Windows
- `.editorconfig` - UTF-8 charset, LF line endings
- `.gitattributes` - Normalize EOL to LF for all text files
- `.gitignore` - Excludes `.godot/`, `/android/`, `/export/`, `prototype/`, IDE files, build artifacts
- `.mcp.json` - Primary MCP config: `@nuskey8/godot-docs-mcp` for Godot documentation
- `opencode.json` - OpenCode config: `@coding-solo/godot-mcp` for editor operations, GodotPrompter plugin
- `.claude/settings.local.json` - Permissions and MCP server enablement
- `AGENTS.md` - Agent instructions in Chinese, defines coding conventions, addon priority, tool hierarchy
- `.claude/skills/game-architect/` - Architecture paradigm selection guide (DDD, Data-Driven, Prototype)
- Each addon has `plugin.cfg` with name, description, author, version, and entry script
- Autoload singletons registered (13): `RegistryManager`, `EventBus`, `UIManager`, `I18NManager`, `SoundManager`, `GUIDE`, `DialogueManager`, `SaveManager`, `GuideSetup`, `DataManager`, `UISetup`, `SFXManager`
## Rendering Configuration
- Method: `mobile` (optimized for mobile/low-end devices) - `project.godot:15`
- Driver (Windows): `d3d12` (Direct3D 12) - `project.godot:14`
- Target: 60 FPS, low-end PC and integrated graphics support
- Engine: Jolt Physics (3D) - `project.godot:19`
- Override: Replaces Godot's default GodotPhysics3D
## Visual Style
- **画风**: 扁平化（Flat Design），非像素风格
- **图标格式**: 单色SVG矢量图标，支持缩放不失真
- **图标目录**: `assets/icons/` 按功能分类（ui/feedback/user/media/food/emoji/arrow/device/misc）
- **配色原则**: 单色图标+强调色，避免渐变和阴影
- **字体**: MiSans Semibold（中文友好）- `assets/fonts/`
- **主题资源**: 极简矢量主题 - `assets/theme/minimal_vector.tres`
## Platform Requirements
- Windows 11 (primary development platform)
- Godot 4.6.2 stable (mono build path used, but no C# code)
- Python 3 (for running web prototype: `python -m http.server 8000`)
- Target platforms: PC (Windows, macOS, Linux)
- Future consideration: Mobile (iOS, Android) - interaction redesign needed
- Export: Godot's built-in export system (no CI/CD detected)
- No build pipeline detected (no CI/CD configuration files)
- Manual export via Godot editor
- `.gitignore` excludes `/export/` directory for build artifacts
## Development Tools
- `godot-docs` (`@nuskey8/godot-docs-mcp`) - Godot official documentation lookup (classes, methods, properties, signals, constants)
- `godot-mcp` (`@coding-solo/godot-mcp`) - Scene operations, node management, project run/stop (DEBUG mode enabled)
- GodotPrompter plugin - Domain-specific guidance for 20+ game development areas (UI, input, animation, physics, etc.)
- game-architect skill - Architecture paradigm selection (DDD vs Data-Driven vs Prototype)
- Skills defined in `AGENTS.md` covering: 2D systems, UI, player controller, input, animation, tween, particles, audio, resources, state machines, event bus, components, scene organization, DI, save/load, localization, dialogue, inventory, HUD, camera, procedural generation, GDScript patterns, shaders, optimization, debugging, code review, testing, export, addon development, math, physics
- MiSans Semibold (OTF + TTF) - Chinese-friendly font for UI (`assets/fonts/`)
- Minimal vector theme resource (`assets/theme/minimal_vector.tres`)
## Data Architecture
- Game data defined as `Resource` subclasses (authoritative data layer)
- JSON used only for external editing and mod support
- `ResourceLocation` (namespace:path) pattern for identifying resources (Minecraft-style)
- `Codec` system for serialization/deserialization of Resource data
- `Registry` pattern for runtime data registration and lookup
- JSON translation files loaded via `I18NManager.load_translation()`
- Nested JSON keys flattened to dot-separated format
- `TranslationServer` integration with EventBus notification on language change
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Use `snake_case.gd` for all GDScript files
- Class files use `snake_case.gd` matching their `class_name` in PascalCase (e.g., `resource_location.gd` defines `class_name ResourceLocation`)
- Scene files: `snake_case.tscn`
- Test files: prefix with `test_` (e.g., `test_inventory.gd`)
- Use `snake_case` for all functions and methods
- Private/internal functions: prefix with `_` (e.g., `_update_caches()`, `_do_close_panel()`)
- Virtual lifecycle callbacks: prefix with `_on_` (e.g., `_on_init()`, `_on_open()`, `_on_close()`, `_on_pause()`, `_on_resume()`, `_on_destroy()`)
- Getter/setter: use `get_` / `set_` prefix (e.g., `get_entry()`, `set_container()`)
- Boolean getters: use `is_` or `has_` prefix (e.g., `is_success()`, `has_entry()`, `is_cancelled()`)
- Use `snake_case` for all variables
- Private/internal variables: prefix with `_` (e.g., `_listeners`, `_cached_panels`, `_active_contexts`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_OPEN_DEPTH`, `REGISTRY_NAMESPACE`, `NAMESPACE_PATTERN`)
- Enum values: `UPPER_SNAKE_CASE` (e.g., `CacheMode.NONE`, `PersistentPolicy.NON_DEFAULT`)
- Use `PascalCase` for `class_name` declarations (e.g., `ResourceLocation`, `ComponentType`, `DataResult`, `UIPanel`)
- Inner classes: `PascalCase` (e.g., `class Builder`, `class Diagnostic`, `class PrimitiveCodec`)
## Code Style
- 4-space indentation (no tabs)
- Blank line between functions
- Use `##` (double hash) for doc comments that should appear in the editor inspector
- Use `#` (single hash) for inline/internal comments
- No explicit linter config detected
- Rely on Godot editor built-in warnings
## Type Annotations
- Use `Variant` when the function genuinely accepts multiple types (e.g., `register(id: ResourceLocation, entry: Variant)`)
- Use `Variant` for registry/container patterns that store heterogeneous data
## Import Organization
- Use `preload()` for loading scripts at compile time: `const GUIDESet = preload("guide_set.gd")`
- Use relative paths with `preload()`: `const SoundEffectsPlayer = preload("./sound_effects.gd")`
- No `@onready` path aliases for addon scripts — use `preload()` instead
## Node References
- Use `%UniqueName` syntax for referencing nodes in scenes
- Avoid absolute paths like `$"../../.."`
- Use `@onready` only for deferred initialization, not for things assigned in `_ready()`
## Signal Patterns
## EventBus Pattern (Cross-System Communication)
- File location: `addons/mc_game_framework/event/` for framework events
- Game events: create under game source directory following same pattern
## Resource Data-Driven Pattern
## Error Handling
- Use `push_error()` for errors that should appear in the debugger
- Use `push_warning()` for non-fatal issues (e.g., overwriting registry entries, duplicate operations)
- Return `null` or `false` on failure for simple operations
- Use `DataResult` for operations that need rich error context (see Codec/serialization pattern)
- Functions that can fail should return a nullable type or `DataResult`
## Logging
- `push_error()`: unrecoverable errors, invalid state, missing required data
- `push_warning()`: recoverable issues, duplicate operations, deprecated usage
- `print()`: debug output during development (remove before production)
## Function Design
- Use default values for optional parameters: `func open_panel(id: ResourceLocation, data: Dictionary = {}, layer_override: int = -1) -> UIPanel:`
- Use `_` prefix for unused parameters in lambdas: `func(ig, ig2): input_mappings_changed.emit()`
- Prefix unused parameters with `_`: `func encode(_value_unused: Variant, ops: DynamicOps) -> DataResult:`
- Always annotate return type
- Return `null` for optional results: `func get_top_panel(layer: int = UILayer.NORMAL) -> UIPanel:`
- Return `bool` for success/failure: `func register(id: ResourceLocation, entry: Variant) -> bool:`
- Return `DataResult` for rich error context in serialization/validation
## Module Design
- Use `class_name` for all reusable classes (makes them globally accessible)
- Use `extends` for inheritance chains
- Use `const` with `preload()` for internal script references
- Use inner classes for closely related types that don't need global access (e.g., `Codec.PrimitiveCodec`, `DataResult.Diagnostic`, `ComponentType.Builder`)
- Inner classes that need global access should be extracted to their own files
## Delta Time
## Input Handling
## Scene Organization
- Single responsibility: one `.tscn` does one thing
- Composition over inheritance
- UIPanel base class for all managed UI panels
- Use `UIPanel.CacheMode.CACHE` for frequently opened panels, `CacheMode.NONE` for one-shot panels
## Comments
- Use `##` doc comments for public API, class descriptions, and properties that appear in the inspector
- Use `#` for internal logic, implementation notes, and non-obvious decisions
- Chinese comments are acceptable (project language is Chinese per AGENTS.md)
- Include file path references in complex module doc comments
## 打开面板
## id: 面板在 UIRegistry 中的 ResourceLocation
## data: 传递给 _on_open() 的参数字典
## Autoload Singletons
- `RegistryManager` — central registry for typed data stores
- `EventBus` — cross-system event pub/sub
- `UIManager` — stack-based UI panel management
- `GUIDE` — input mapping and context management
- `SoundManager` — audio playback (music, SFX, ambient)
- `DialogueManager` — dialogue system
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## System Overview
```text
|                     Game Scenes (tscn / gd)                          |
|  (not yet created - to be built under res://)                        |
|                   mc_game_framework (Addon)                          |
|  +----------------+  +----------+  +----------+  +----------------+ |
|  | RegistryManager|  | EventBus |  | UIManager|  | I18NManager    | |
|  | (Autoload)     |  |(Autoload)|  |(Autoload)|  | (Autoload)     | |
|  +-------+--------+  +----+-----+  +----+-----+  +--------+-------+ |
|          |                |             |                   |         |
|          v                v             v                   v         |
|  +----------------+  +----------+  +----------+  +----------------+ |
|  | RegistryBase   |  | Event    |  | UIPanel  |  | Translation    | |
|  | UIRegistry     |  | (base)   |  | UIToast  |  | Server         | |
|  | TagRegistry    |  |          |  | UILayer  |  |                | |
|  | ComponentType  |  +----------+  +----------+  +----------------+ |
|  | Registry       |                                                  |
|  +----------------+                                                  |
|  +----------------+  +----------------+  +-------------------------+ |
|  | Codec          |  | Component      |  | ResourceLocation        | |
|  | DataResult     |  | Container/Host |  | Tag                     | |
|  | DynamicOps     |  | ComponentType  |  |                         | |
|  | JsonOps        |  |                |  |                         | |
|  | GodotResource  |  +----------------+  +-------------------------+ |
|  | Ops            |                                                  |
|  +----------------+                                                  |
|                    Other Addons                                      |
|  +----------------+ +----------+ +----------+ +------------------+  |
|  | guide (GUIDE)  | | sound_   | | dialogue | | gut (testing)    |  |
|  | Input contexts | | manager  | | _manager | | kenney_sounds    |  |
|  +----------------+ +----------+ +----------+ +------------------+  |
|              Godot 4.6 Engine                                        |
|  Rendering: Mobile method (D3D12 on Windows)                         |
|  Physics: Jolt                                                       |
```
## Component Responsibilities
| Component | Responsibility | File |
|-----------|----------------|------|
| RegistryManager | Meta-registry; stores and retrieves typed registries (UI, tags, components) | `addons/mc_game_framework/autoload/registry_manager.gd` |
| EventBus | Pub/sub event dispatch; sole cross-system communication channel | `addons/mc_game_framework/autoload/event_bus.gd` |
| UIManager | Stack-based UI lifecycle; panel open/close/pause/resume; overlays, toasts, popup queue | `addons/mc_game_framework/autoload/ui_manager.gd` |
| I18NManager | JSON-based translation loading; locale switching via EventBus | `addons/mc_game_framework/autoload/i18n_manager.gd` |
| GUIDE | Input mapping with context switching; replaces raw `Input.is_action_*` | `addons/guide/guide.gd` |
| SoundManager | BGM, SFX, ambient audio with pooling and crossfade | `addons/sound_manager/sound_manager.gd` |
| DialogueManager | Branching dialogue compiler and runtime | `addons/dialogue_manager/` |
| Codec / DataResult | DFU-style composable encode/decode with diagnostics | `addons/mc_game_framework/codec/core/codec.gd`, `data_result.gd` |
| ComponentContainer | Minecraft-style Data Component map; supports patch/merge/serialize | `addons/mc_game_framework/component/component_container.gd` |
| ComponentHost | Static adapter attaching ComponentContainer to Node/Resource/RefCounted | `addons/mc_game_framework/component/component_host.gd` |
| ResourceLocation | Minecraft-style `namespace:path` identifier with validation | `addons/mc_game_framework/utils/resource_location.gd` |
| Tag / TagRegistry | Grouping system for entries by tag (e.g., food properties) | `addons/mc_game_framework/tag/tag.gd`, `tag_registry.gd` |
| UIPanel | Base class for all managed UI panels with lifecycle callbacks | `addons/mc_game_framework/ui/ui_panel.gd` |
| UIToast | Base class for auto-dismissing notification widgets | `addons/mc_game_framework/ui/ui_toast.gd` |
## Pattern Overview
- All cross-system communication goes through `EventBus.publish()` / `EventBus.subscribe()` -- no direct node-to-node calls across system boundaries
- UI is fully managed by `UIManager` -- panels are registered in `UIRegistry` and opened by `ResourceLocation`, never via `add_child()`
- Input flows through `GUIDE` mapping contexts -- raw `Input.is_action_*` is forbidden
- Runtime data uses `Resource` subclasses; JSON only for external editing and mod support
- The `mc_game_framework` addon provides a Minecraft-inspired infrastructure layer (ResourceLocation identifiers, Codec serialization, Data Component system, Tag system)
- Scenes follow single-responsibility principle: one `.tscn` does one thing; composition over inheritance
## Layers
- Purpose: Provide reusable engine services (events, UI, input, audio, i18n, dialogue, testing)
- Location: `addons/`
- Contains: Autoload singletons, base classes, codecs, component system
- Depends on: Godot 4.6 engine only
- Used by: All game code
- Purpose: Define game-specific Resource subclasses (materials, equipment, recipes, attributes)
- Location: `res://` (root, likely `scripts/data/` or `data/` based on convention)
- Contains: Resource definitions, Codec declarations, ComponentType registrations
- Depends on: Addon infrastructure (Codec, ComponentType, ResourceLocation, Tag)
- Used by: Game logic, UI, save/load
- Purpose: Implement gameplay systems (crafting, equipment logic, attribute resolution, recipe discovery)
- Location: `res://` (likely `scripts/` or `systems/`)
- Contains: System scripts, state machines, processing pipelines
- Depends on: Addon infrastructure + Game data
- Used by: Scenes, UI
- Purpose: All visual interface (panels, HUD, toasts)
- Location: `res://` (likely `scenes/ui/` or `ui/`)
- Contains: UIPanel/UIToast subclasses as `.tscn` + `.gd` pairs
- Depends on: UIManager, EventBus, Game logic
- Used by: Player interaction
- Purpose: Game world scenes, device scenes, kitchen scenes
- Location: `res://` (likely `scenes/`)
- Contains: `.tscn` files with scene-specific scripts
- Depends on: All layers
## Data Flow
### Primary Request Path: Crafting (Material + Equipment = Product)
### UI Panel Lifecycle
### Event Communication
- Runtime state lives in `Resource` subclasses (not plain dictionaries)
- EventBus is the sole decoupled communication channel
- UIManager owns all UI state (panel stacks, overlays, toasts)
- GUIDE owns input state (active contexts, action mappings)
## Key Abstractions
- Purpose: Universal identifier format `namespace:path` (Minecraft-inspired)
- Examples: `cookery:equipment/stove`, `cookery:material/flour`, `core:ui/inventory`
- Pattern: Always use `.to_string()` as Dictionary key (RefCounted identity comparison is unreliable)
- Purpose: Composable serialization with error recovery
- Examples: `addons/mc_game_framework/codec/core/codec.gd`, `data_result.gd`
- Pattern: Declare codecs as static methods on data classes; chain with `.field_of()`, `.list_of()`, `.xmap()`
- Purpose: Attach typed data components to any object (Node, Resource, RefCounted)
- Examples: `addons/mc_game_framework/component/component_container.gd`
- Pattern: Use `ComponentHost.get_or_create(host)` then `container.set_component(type, value)`
- Purpose: Typed event objects for EventBus pub/sub
- Examples: `addons/mc_game_framework/event/event.gd`, `ui_open_event.gd`, `language_changed_event.gd`
- Pattern: Subclass `Event`, declare `class_name`, add data fields; publish via `EventBus.publish()`
- Purpose: Managed UI panel with stack lifecycle
- Examples: `addons/mc_game_framework/ui/ui_panel.gd`
- Pattern: Extend `UIPanel`, override `_on_open/_on_close/_on_pause/_on_resume`; open via `UIManager.open_panel()`
## Entry Points
- Location: `project.godot` -- configures engine settings, no main scene set yet
- Triggers: Godot editor loads project
- Responsibilities: Engine configuration (rendering: mobile/D3D12, physics: Jolt)
- `RegistryManager` -> `addons/mc_game_framework/autoload/registry_manager.gd`
- `EventBus` -> `addons/mc_game_framework/autoload/event_bus.gd`
- `UIManager` -> `addons/mc_game_framework/autoload/ui_manager.gd`
- `I18NManager` -> `addons/mc_game_framework/autoload/i18n_manager.gd`
- `GUIDE` -> `addons/guide/guide.gd`
- `SoundManager` -> `addons/sound_manager/sound_manager.gd`
- `DialogueManager` -> `addons/dialogue_manager/dialogue_manager.gd`
- `SaveManager` -> `scripts/autoloads/save_manager.gd`
- `GuideSetup` -> `scripts/autoloads/guide_setup.gd`
- `DataManager` -> `scripts/autoloads/data_manager.gd`
- `UISetup` -> `scripts/autoloads/ui_setup.gd`
- `SFXManager` -> `scripts/autoloads/sfx_manager.gd`
## Architectural Constraints
- **Threading:** Single-threaded; all game logic runs on the main thread via `_process`/`_physics_process`. No worker threads.
- **Global state:** 13 autoload singletons — 框架层 (`RegistryManager`, `EventBus`, `UIManager`, `I18NManager`, `GUIDE`, `SoundManager`, `DialogueManager`) + 游戏层 (`SaveManager`, `GuideSetup`, `DataManager`, `UISetup`, `SFXManager`).
- **Circular imports:** Not applicable yet (no game code exists). The addon layer has no circular dependencies.
- **EventBus is the sole cross-system channel:** Systems must not hold direct references to each other. Use `EventBus.publish()` and `EventBus.subscribe()`.
- **UI through UIManager only:** Never call `add_child()` to add panels. Always use `UIManager.open_panel()` with a registered `ResourceLocation`.
- **Input through GUIDE only:** Never call `Input.is_action_just_pressed()` etc. Use GUIDE actions and mapping contexts.
- **Resource is data authority:** Game data uses `Resource` subclasses. JSON is only for external editing and mod support.
- **Addon-first:** Check `addons/` before building custom solutions. If an addon partially satisfies a need, extend it rather than rewriting.
## Anti-Patterns
### Direct add_child for UI Panels
### Raw Input Detection
### Direct Node-to-Node Communication
### Using Dictionary for Runtime Game Data
## Error Handling
- All Codec operations return `DataResult` (success/error/partial) -- never throw exceptions
- `DataResult.partial()` preserves partially-decoded data with diagnostics for recovery
- `EventBus.publish()` auto-cleans stale listener Callables (freed objects)
- `UIManager` has recursive navigation protection (`MAX_OPEN_DEPTH = 8`)
- Addon code uses `push_error()` / `push_warning()` for non-fatal issues
## Cross-Cutting Concerns
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

| Skill | Description | Path |
|-------|-------------|------|
| game-architect | READ this skill when designing or planning any game system architecture — including combat, skills, AI, UI, multiplayer, narrative, or scene systems. Contains paradigm selection guides (DDD / Data-Driven / Prototype), system-specific design references, and mixing strategies. Works as a domain knowledge plugin alongside workflow skills (OpenSpec, SpecKit) or plan mode of an agent. | `.claude/skills/game-architect/SKILL.md` |
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
