# Technical Architecture

## Overview

Core technology stack: **Rust + Bevy** for learning-focused game development.

### Why Bevy/Rust
- **ECS Architecture**: Perfect for managing different universe systems and rules
- **Native binaries**: Compiles to standalone macOS/Windows/Linux executables
- **Performance**: Can handle complex simulations and thousands of entities
- **Type safety**: Rust's compiler catches bugs early
- **Modern ecosystem**: Active community, good documentation

### Development Environment
- **Editor**: Neovim with rust-analyzer LSP
- **Key Tools**:
  - `rust-analyzer`: LSP for autocomplete/linting
  - `rustfmt`: Code formatting
  - `clippy`: Additional linting
  - `cargo-watch`: Hot reload during development
- **Build times**: Initial builds 30-60s (use cargo-watch for iteration)

## Rust Learning Challenges
1. **Ownership/Borrowing**: Can't freely pass references around
2. **No null/undefined**: Explicit `Option<T>` and `Result<T,E>`
3. **Upfront edge case handling**: Less "make it work" flexibility
4. **Compile times**: Longer than JS/TS development

## Rust Benefits
- Pattern matching (similar to Elixir)
- Zero-cost abstractions
- Compiler-driven development
- ECS forces good architectural thinking

## Repository Structure

### Monorepo Architecture
Single repository with separate directories for each component:

```
Coherence/
├── game/                      # Rust/Bevy game
│   ├── src/
│   │   ├── main.rs
│   │   └── systems/
│   ├── assets/               # Game assets (generated + manual)
│   │   ├── sprites/
│   │   │   ├── characters/
│   │   │   │   ├── player/
│   │   │   │   │   ├── idle.png (32x32)
│   │   │   │   │   ├── walk.png (32x128 sprite sheet)
│   │   │   │   │   └── metadata.json
│   │   │   │   └── npcs/
│   │   │   ├── tiles/
│   │   │   │   ├── grass.png (32x32)
│   │   │   │   ├── stone.png (32x32)
│   │   │   │   └── tileset.json
│   │   │   ├── objects/
│   │   │   │   ├── portal.png (64x64)
│   │   │   │   └── items.atlas
│   │   │   └── ui/
│   │   │       └── icons.png (256x256 atlas)
│   │   ├── universes/
│   │   │   ├── dystopia/
│   │   │   │   └── palette.json
│   │   │   ├── utopia/
│   │   │   │   └── palette.json
│   │   │   └── shared/
│   │   │       └── base_palette.json
│   │   └── metadata/
│   │       └── generation_log.json
│   ├── Cargo.toml
│   └── README.md
│
├── art/                       # Python AI generation pipeline
│   ├── src/
│   │   ├── generator.py
│   │   ├── style_manager.py
│   │   └── batch_processor.py
│   ├── config/
│   │   ├── styles.yaml
│   │   └── assets.yaml
│   ├── references/
│   │   └── universe_styles/
│   ├── scripts/
│   │   └── generate.py
│   ├── requirements.txt
│   └── README.md
│
├── docs/                      # Shared documentation
│   ├── Game.md
│   ├── Tech.md
│   └── AI-Art-Pipeline.md
│
├── scripts/                   # Root-level convenience scripts
│   ├── setup.sh              # Install all dependencies
│   ├── generate-assets.sh   # Run art generation
│   └── run-game.sh          # Build and run game
│
├── .gitignore
└── README.md
```

### Monorepo Benefits
- **Single source of truth**: All code, assets, and docs in one place
- **Atomic commits**: Changes to art pipeline and game can be committed together
- **Simplified development**: No need to manage multiple repos or symlinks
- **Easier onboarding**: Clone once, run setup script, everything works
- **Consistent tooling**: Shared git hooks, CI/CD, formatting rules

### Asset Specifications

**Sprite Standards:**
- **Tiles**: 32x32px, seamless edges
- **Characters**: 32x32px base, 4-direction sprites
- **Objects**: Variable (32x32, 64x64), centered anchor
- **UI Elements**: 16x16px or 32x32px icons
- **Format**: PNG with transparency
- **Palette**: 16-color restriction per universe theme

**Metadata Format (JSON):**
```json
{
  "source": "ai_generated",
  "generator_version": "1.0.0",
  "prompt": "character idle pose, top-down perspective",
  "universe_style": "dystopia",
  "animations": {
    "idle": { "frames": 1, "duration": 0 },
    "walk": { "frames": 4, "duration": 200 }
  },
  "collision_box": { "x": 4, "y": 4, "width": 24, "height": 24 }
}
```

### Asset Pipeline Integration

**Generation Workflow:**
1. Run generator from root: `./scripts/generate-assets.sh`
2. Python pipeline in `art/` outputs to `game/assets/`
3. Bevy hot-reloads assets during development
4. Commit both generation code and assets together

**Convenience Scripts:**
```bash
# From project root
./scripts/setup.sh              # Install Rust, Python deps, ComfyUI
./scripts/generate-assets.sh dystopia  # Generate universe assets
./scripts/run-game.sh           # cargo run in game directory
```

**Bevy Asset Loading:**
```rust
// Assets are loaded using Bevy's asset system
// Hot-reloading enabled in development
let texture_handle = asset_server.load("sprites/characters/player/idle.png");
```

### Development Workflow

1. **Initial Setup:**
   ```bash
   git clone <repo>
   cd Coherence
   ./scripts/setup.sh
   ```

2. **Asset Generation:**
   ```bash
   cd art
   python scripts/generate.py --universe dystopia
   ```

3. **Game Development:**
   ```bash
   cd game
   cargo watch -x run  # Hot reload on code changes
   ```

4. **Full Pipeline:**
   ```bash
   # From root, generate then run
   make assets && make run
   ```

## Alternatives Considered

### Love2D + Lua
- ✅ Fast iteration, simple API
- ❌ Limited architecture, need to build own ECS
- ❌ Lua quirks (1-indexed, tables for everything)

### Godot + GDScript
- ✅ Full game engine, easier learning curve
- ❌ IDE-centric workflow (not vim-friendly)
- ❌ Point-and-click approach

### Web-based (Elm, ClojureScript)
- ✅ Functional programming paradigms
- ❌ Want native binary, not browser game

## Learning Resources

### Rust Basics
- The Rust Book (official documentation)
- Rustlings (exercises)
- Rust by Example

### Bevy Specific
- Bevy Book (official guide)
- Bevy examples repository
- Unofficial Bevy Cheat Book

### ECS Concepts
- Understanding Entity-Component-System architecture
- Bevy's specific implementation

## Getting Started
1. Install Rust toolchain (rustup)
2. Set up Neovim with rust-analyzer
3. Create new Bevy project
4. Configure for fast iteration (dynamic linking in dev)
5. Set up basic game loop and rendering
6. Implement sprite loading and rendering

## Performance Considerations
- Use texture atlases for sprites
- Implement frustum culling for off-screen entities
- Consider chunk-based loading for large universes
- Profile early and often with cargo flamegraph

## Technical Questions
- Asset pipeline: How to manage and load pixel art efficiently?
- Save system: How to serialize universe states?
- Procedural generation: Use Wave Function Collapse for universe generation?
- UI framework: egui vs custom implementation?
- Sound/music: Which audio crate to use with Bevy?
- Input handling: Keyboard only or gamepad support?
- Lighting: Implement Jarl-like 2D lighting with bevy_magic_light_2d?

## Open Source References
Key Bevy projects to study:
- **AspenHalls** (https://github.com/Hellzbellz123/AspenHalls) - 2D top-down RPG
- **bevy-colony-sim-game** (https://github.com/frederickjjoubert/bevy-colony-sim-game) - Colony sim mechanics
- **colony** (https://github.com/ryankopf/colony) - Another colony sim with pathfinding
- **seldom_pixel** - Bevy plugin for pixel art games
- **bevy_pixel_camera** - Pixel-perfect camera handling

## Next Technical Steps
1. Set up Rust/Bevy development environment
2. Complete Rust basics tutorial
3. Build "Hello World" Bevy app with sprite rendering
4. Implement basic top-down movement system
5. Create simple tilemap renderer
6. Prototype universe switching mechanism