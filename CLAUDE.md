# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Coherence is a top-down pixel art game about jumping between parallel universes, inspired by "Dark Matter" by Blake Crouch. This is a learning project for someone with programming experience but zero game development or Lua knowledge.

## Tech Stack

- **Game Framework**: Love2D (11.5)
- **Language**: Lua
- **Libraries**: 
  - Bump (collision detection)
  - STI (Simple Tiled Implementation for tilemaps)
  - HUMP (gamestate, camera, utilities)
  - Lurker (hot reload)
- **Tilemap Editor**: Tiled
- **Art Pipeline**: AI-generated pixel art (ComfyUI + SDXL) - not yet implemented
- **Style**: Top-down 16-bit pixel art inspired by Stardew Valley and Jarl

## Development Commands

### Setup (macOS)
```bash
# Install Love2D
brew install love

# Verify installation
love --version
```

### Setup (Linux)
```bash
# Install Love2D
sudo apt install love

# Verify installation
love --version
```

### Running the Game
```bash
# Run the game
love game/

# Run with console visible (debugging)
love game/ --console

# Run with hot reload (using entr)
ls game/**/*.lua | entr -r love game/

# Run with hot reload (using watchman)
watchman-make -p 'game/**/*.lua' --run 'love game/'
```

### Testing
```bash
# Run automated tests (if using Busted)
cd game && busted

# Run with debug mode
DEBUG=true love game/
```

### Distribution
```bash
# Create .love file for distribution
cd game && zip -r ../coherence.love . && cd ..

# Test the .love file
love coherence.love

# Create fused executable (macOS)
cat /Applications/love.app/Contents/MacOS/love coherence.love > coherence
chmod +x coherence
```

## Architecture

### Project Structure
```
Coherence/
├── game/                    # Love2D game code
│   ├── main.lua            # Entry point (love.load, love.update, love.draw)
│   ├── conf.lua            # Love2D configuration
│   ├── states/             # Game states (menu, play, lab)
│   │   ├── menu.lua
│   │   ├── play.lua
│   │   └── lab.lua
│   ├── lib/                # Third-party libraries
│   │   ├── bump/          # Collision detection
│   │   ├── sti/           # Tiled map loader
│   │   ├── hump/          # Utilities
│   │   └── lurker/        # Hot reload
│   ├── src/                # Game source code
│   │   ├── player.lua
│   │   ├── world.lua
│   │   └── universe.lua
│   └── assets/             # Game assets
│       ├── sprites/
│       ├── maps/          # Tiled map files (.lua export)
│       └── fonts/
├── art/                     # AI art generation pipeline
├── docs/                    # Design documents
└── scripts/                 # Build and utility scripts
```

### Love2D Basics

#### Core Callbacks
```lua
function love.load()
    -- Called once at startup
end

function love.update(dt)
    -- Called every frame, dt is delta time in seconds
end

function love.draw()
    -- Called every frame for rendering
end

function love.keypressed(key)
    -- Called when a key is pressed
end
```

#### Configuration (conf.lua)
```lua
function love.conf(t)
    t.window.title = "Coherence"
    t.window.width = 1024
    t.window.height = 768
    t.window.vsync = true
end
```

## Development Guidelines

### IMPORTANT: Teaching Role
**Claude must act as a Lua/Love2D instructor throughout this entire project:**
- Explain EVERY new Lua concept (tables, metatables, 1-indexing, local vs global)
- Break down Love2D's callback system and how it works
- Explain delta time and frame-independent movement
- Describe coordinate systems (top-left origin)
- Never assume prior Lua or game development knowledge
- Use analogies to JavaScript/TypeScript where helpful
- Explain Love2D idioms and patterns as they appear

### Learning Project Principles
1. **Small, atomic changes**: Each change should be 10-50 lines when learning new concepts
2. **Explain everything**: Every Lua quirk, Love2D function, game concept
3. **NO COMMENTS in code**: Code should be self-documenting
4. **Interactive testing first**: Use Love2D's rapid iteration, add debug modes
5. **One concept at a time**: Never combine multiple new Lua/Love2D concepts
6. **Hot reload everything**: Use lurker for instant feedback
7. **Visual debugging**: Add debug overlays and visualizations liberally

### Current Development Phase
**Phase 0: Love2D Setup** (Current)
- Install Love2D
- Create basic main.lua with callbacks
- Understand game loop
- Next: Draw a sprite and move it with keyboard

### Key Lua Concepts to Explain
- **Tables**: Lua's only data structure (arrays AND objects)
- **1-indexed**: Arrays start at 1, not 0
- **Local by default**: Always use `local` keyword
- **Metatables**: How Lua does OOP
- **nil**: Lua's null/undefined
- **Colon syntax**: `object:method()` vs `object.method(object)`

### Love2D-Specific Notes
- Assets go in `game/assets/` directory
- Use lurker for hot reload during development
- Coordinate system: (0,0) is top-left
- Delta time (dt) for frame-independent movement
- love.graphics.push/pop for state management

### Key Libraries We're Using
- **Bump**: Simple AABB collision, perfect for tile-based games
- **STI**: Load Tiled maps directly, integrates with Bump
- **HUMP**: Gamestate management, camera, timers, class system
- **Lurker**: Hot reload changed files without restarting

## Important References
- **Love2D Wiki**: https://love2d.org/wiki/Main_Page
- **Sheepolution Tutorial**: Excellent Love2D tutorial series
- **Bump documentation**: https://github.com/kikito/bump.lua
- **STI documentation**: https://github.com/karai17/Simple-Tiled-Implementation
- **HUMP documentation**: https://github.com/vrld/hump
- **Programming in Lua**: https://www.lua.org/pil/

## Debug Mode Features
Always implement debug mode for new features:
```lua
-- Global debug flag
DEBUG = false

function love.keypressed(key)
    if key == "f1" then DEBUG = not DEBUG end
end

function love.draw()
    drawGame()
    if DEBUG then drawDebugInfo() end
end
```

## Common Patterns

### Player Movement
```lua
function updatePlayer(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("right") then dx = 1 end
    if love.keyboard.isDown("left") then dx = -1 end
    
    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        dx, dy = dx * 0.707, dy * 0.707
    end
    
    player.x = player.x + dx * player.speed * dt
end
```

### State Management with HUMP
```lua
Gamestate = require "lib.hump.gamestate"
local menu = require "states.menu"
local play = require "states.play"

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
```

### Collision with Bump
```lua
local bump = require "lib.bump"
local world = bump.newWorld()

-- Add player to world
world:add(player, player.x, player.y, player.w, player.h)

-- Move with collision
local actualX, actualY = world:move(player, newX, newY)
player.x, player.y = actualX, actualY
```

## Performance Tips
- Use sprite batches for tiles
- Limit active chunks to visible area + buffer
- Profile with love.profiler when needed
- Target 60 FPS consistently

## Next Steps
1. Create basic Love2D window
2. Draw a sprite
3. Implement keyboard movement
4. Add Bump collision
5. Load a Tiled map with STI
6. Implement chunk system
7. Add universe jumping mechanic