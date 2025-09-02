# Technical Architecture

## Overview

Core technology stack: **Lua + Love2D** for rapid, iterative game development.

### Why Love2D/Lua
- **Rapid Iteration**: Hot reload, immediate feedback, no compile times
- **Simple Distribution**: 10-50MB native apps for macOS/Linux
- **Proven Success**: Used by commercial hits like Balatro
- **Lua Benefits**: Simple language, useful for Neovim config too
- **Active Community**: Extensive libraries and resources

### Development Environment
- **Editor**: Neovim with Lua LSP
- **Key Tools**:
  - `love`: The Love2D runtime
  - `lurker`: Hot reload library for Love2D
  - `Tiled`: Map editor for creating tilemaps
  - `entr` or `watchman`: File watchers for auto-restart
- **Iteration Speed**: Instant - save file and see changes

## Lua Learning Path
1. **Tables everywhere**: Lua's only data structure
2. **1-indexed arrays**: Different from most languages
3. **Metatables**: Lua's approach to OOP and operators
4. **Local by default**: Use `local` keyword extensively
5. **No built-in classes**: Use libraries like HUMP.class

## Love2D Benefits
- Immediate mode rendering
- Built-in physics (Box2D)
- Cross-platform from single codebase
- Excellent 2D performance

## Repository Structure

### Monorepo Architecture
Single repository with separate directories for each component:

```
Coherence/
├── game/                      # Love2D game
│   ├── main.lua              # ONLY Love2D callbacks (load, update, draw)
│   ├── conf.lua              # Love2D configuration ONLY
│   ├── constants.lua         # ALL game constants in one place
│   ├── states/               # Game states (menu, play, etc)
│   │   ├── menu.lua
│   │   ├── play.lua
│   │   └── lab.lua
│   ├── lib/                  # Third-party libraries (DO NOT MODIFY)
│   │   ├── bump/            # Collision detection
│   │   ├── sti/             # Simple Tiled Implementation
│   │   ├── hump/            # Utilities (gamestate, camera)
│   │   └── lurker/          # Hot reload
│   ├── logic/                # Game logic (separate from rendering)
│   │   ├── player.lua       # Player movement and state
│   │   ├── chunks.lua       # Chunk generation and management
│   │   ├── universe.lua     # Universe generation rules
│   │   └── collision.lua    # Collision handling
│   ├── render/               # Rendering code only
│   │   ├── sprites.lua      # Sprite drawing
│   │   ├── tilemap.lua      # Tilemap rendering
│   │   └── debug.lua        # Debug overlay rendering
│   ├── assets/               # Game assets
│   │   ├── sprites/
│   │   │   ├── characters/
│   │   │   │   ├── player.png (32x32)
│   │   │   │   └── player_walk.png (128x32 sprite sheet)
│   │   │   ├── tiles/
│   │   │   │   └── tileset.png (256x256)
│   │   │   └── ui/
│   │   │       └── icons.png
│   │   ├── maps/            # Tiled map files (NEVER modify programmatically!)
│   │   │   ├── lab.lua      # Exported from Tiled
│   │   │   ├── lab.json     # Tiled project file
│   │   │   └── chunks/      # Procedural chunk templates
│   │   └── fonts/
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
│   └── Art.md
│
├── scripts/                   # Root-level convenience scripts
│   ├── setup.sh              # Install Love2D and dependencies
│   ├── generate-assets.sh   # Run art generation
│   ├── run.sh               # Run game with Love2D
│   └── package.sh           # Package for distribution
│
├── .gitignore
└── README.md
```

### Monorepo Benefits
- **Single source of truth**: All code, assets, and docs in one place
- **Atomic commits**: Changes to art pipeline and game can be committed together
- **Simplified development**: No need to manage multiple repos or symlinks
- **Easier onboarding**: Clone once, install Love2D, run game
- **Hot reload friendly**: All assets in predictable locations

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
3. Love2D automatically uses new assets (no compilation needed)
4. Commit both generation code and assets together

**Convenience Scripts:**
```bash
# From project root
./scripts/setup.sh              # Install Love2D, Python deps
./scripts/generate-assets.sh dystopia  # Generate universe assets
./scripts/run.sh               # Run game with Love2D
./scripts/package.sh           # Create distributable .love file
```

**Love2D Asset Loading:**
```lua
-- Assets are loaded directly
local playerSprite = love.graphics.newImage("assets/sprites/player.png")
-- Hot reload with lurker library
lurker = require "lib.lurker"
lurker.postswap = function(f) print("Reloaded " .. f) end
```

### Development Workflow

1. **Initial Setup:**
   ```bash
   git clone <repo>
   cd Coherence
   brew install love  # macOS
   # or: sudo apt install love  # Linux
   ```

2. **Game Development:**
   ```bash
   # Run with hot reload
   love game/
   # Or with file watcher for auto-restart
   ls game/**/*.lua | entr -r love game/
   ```

3. **Create Tiled Maps:**
   ```bash
   # Open Tiled, create map, export as Lua
   # Save to game/assets/maps/
   ```

4. **Package for Distribution:**
   ```bash
   # Create .love file
   cd game && zip -r ../coherence.love . && cd ..
   # Run packaged game
   love coherence.love
   ```

## Key Love2D Libraries

### Core Libraries We'll Use

**Bump** - Collision detection
- Simple AABB collision
- Perfect for tile-based games
- `local world = bump.newWorld()`

**STI (Simple Tiled Implementation)** - Tilemap loading
- Load Tiled maps directly
- Built-in Bump integration
- `local map = sti('map.lua', {'bump'})`

**HUMP** - Helper utilities
- Gamestate management
- Camera system
- Timer utilities
- Class system

**Lurker** - Hot reload
- Auto-reload changed files
- Essential for rapid iteration

### Game Structure

```lua
-- main.lua (ONLY callbacks, no game logic!)
local constants = require "constants"
local gameLogic = require "logic.game"
local renderer = require "render.renderer"

function love.load()
    gameLogic.init()
    print("[INIT] Game started")
end

function love.update(dt)
    gameLogic.update(dt)
end

function love.draw()
    renderer.draw()
end
```

```lua
-- conf.lua (Configuration ONLY)
function love.conf(t)
    t.window.title = "Coherence"
    t.window.width = 1024
    t.window.height = 768
    t.window.vsync = true
    t.console = true  -- Show console on Windows
end
```

```lua
-- constants.lua (ALL constants here!)
return {
    -- Window
    WINDOW_WIDTH = 1024,
    WINDOW_HEIGHT = 768,
    
    -- Player
    PLAYER_SPEED = 200,
    PLAYER_SIZE = 32,
    
    -- World
    CHUNK_SIZE = 10,
    TILE_SIZE = 32,
    WORLD_SIZE = 5,  -- 5x5 chunks
    
    -- Universe thresholds
    UTOPIA_THRESHOLD = 0.7,
    DYSTOPIA_THRESHOLD = 0.3,
    
    -- Debug
    DEBUG_KEY = "f1",
    LOG_LEVEL = "INFO"  -- "DEBUG", "INFO", "WARN", "ERROR"
}
```

## Learning Resources

### Lua Basics
- Programming in Lua (PIL) - Official book
- Learn Lua in 15 Minutes
- Lua Users Wiki

### Love2D Specific
- Love2D Wiki - Comprehensive documentation
- Sheepolution's Love2D Tutorial
- CS50's Game Development course (uses Love2D)
- Simple Tiled Implementation docs
- Bump.lua documentation

### Example Projects
- Simple Farmer (farming game in Love2D)
- Mari0 (Mario + Portal mashup)
- Move or Die source exploration

## Getting Started

### Installation
```bash
# macOS
brew install love
brew cask install tiled  # Map editor

# Linux
sudo apt install love
sudo apt install tiled

# Verify installation
love --version
```

### First Love2D Game
1. Create `game/` directory
2. Add `main.lua` with basic callbacks
3. Run with `love game/`
4. Add conf.lua for window settings
5. Install libraries (bump, STI, hump)
6. Set up hot reload with lurker

## Tiled Map Editor Integration

### Creating Maps in Tiled
1. **New Map Settings:**
   - Orientation: Orthogonal
   - Tile size: 32x32 pixels
   - Map size: 10x10 tiles (for chunks)
   - Use CSV encoding (not compressed)

2. **Export Settings:**
   - Format: Lua (.lua)
   - DO NOT use compression
   - Save to `game/assets/maps/`

3. **Layer Setup:**
   - "ground" layer - walkable tiles
   - "collision" layer - walls and obstacles
   - "objects" layer - interactive elements

4. **Custom Properties:**
   - Add "collidable" bool property to tiles
   - Add "type" string property for universe types

### Loading Maps with STI
```lua
local sti = require "lib.sti"
local map

function love.load()
    -- Load Tiled map
    map = sti("assets/maps/lab.lua")
    print("[MAP] Loaded: lab.lua")
end

function love.update(dt)
    map:update(dt)
end

function love.draw()
    map:draw()
end
```

### IMPORTANT: Never Let LLM Modify Map Files
- Tiled exports are DATA files, not code
- Always edit maps in Tiled, not in code
- If LLM tries to modify .lua map files, STOP IT

## Performance Considerations
- Use sprite batches for tiles
- Limit draw calls with canvas/render targets
- Chunk-based world loading/unloading
- Efficient collision with spatial hashing (Bump)
- Profile with `love.profiler` or jprof

## Technical Questions
- Chunk system: How to efficiently load/unload world chunks?
- Save system: Serialize Lua tables or use SQLite?
- Procedural generation: Perlin noise or Wave Function Collapse?
- UI: Use SUIT library or custom implementation?
- Distribution: .love file or fused executable?
- Multiplayer: Possible with sock.lua for future?
- Mobile: Love2D supports iOS/Android - consider later?

## Open Source References
Key Love2D projects to study:
- **Simple Farmer** - Basic farming game example
- **Push** - Resolution handling library
- **Windfield** - Physics module wrapper
- **anim8** - Animation library
- **Tiled + STI examples** - Tilemap integration
- **Cartographer** - Alternative to STI
- **2D World Chunking** - Example infinite world system

## Next Technical Steps
1. Install Love2D and create basic window
2. Implement player movement with keyboard
3. Load and render a tilemap with STI
4. Add collision detection with Bump
5. Create game state system with HUMP
6. Build chunk-based world generation
7. Implement universe jumping mechanic