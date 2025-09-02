# Game Design

## Overview

A top-down pixel art game inspired by "Dark Matter" where players travel between parallel universes. Each universe is procedurally generated using a chunk-based system, creating infinite unique worlds to explore.

## Core Concept
A top-down pixel art game inspired by the novel "Dark Matter" where players travel between parallel universes. Each universe is procedurally generated using a chunk-based system, creating infinite unique worlds to explore.

## Visual Style
- Top-down perspective similar to Stardew Valley and Jarl
- 16-bit pixel art aesthetic
- Low-fi graphics focusing on gameplay over visual complexity
- Jarl-like atmosphere with cozy yet mysterious feeling
- Dynamic lighting effects for different universes (if feasible)

## MVP Core Gameplay Loop

### 1. The Lab (Starting Point)
- Simple indoor room with the quantum device (the "box")
- Three calibration sliders to adjust before jumping:
  - **Stability**: High = Utopia likely, Low = Dystopia likely
  - **Coherence**: Affects how "logical" vs "chaotic" world generation is
  - **Resonance**: Affects how far the box spawns from your starting point
- Jump button to initiate universe travel

**Example Lab State:**
```lua
local labState = {
    stability = 0.5,   -- Range: 0.0 to 1.0
    coherence = 0.5,   -- Range: 0.0 to 1.0
    resonance = 0.5,   -- Range: 0.0 to 1.0
}

function generateUniverse(lab)
    local universe = {}
    
    -- Determine type based on stability
    if lab.stability > 0.7 then
        universe.type = "utopia"
    elseif lab.stability < 0.3 then
        universe.type = "dystopia"
    else
        universe.type = "neutral"
    end
    
    -- Box distance based on resonance
    universe.boxDistance = math.floor(lab.resonance * 5) + 1  -- 1-5 chunks away
    
    -- Chaos level based on coherence
    universe.chaosFactor = 1.0 - lab.coherence
    
    print(string.format("[LAB] Jumping to %s (box %d chunks away)", 
        universe.type, universe.boxDistance))
    
    return universe
end
```

### 2. Universe Exploration
- Land in a procedurally generated outdoor world (Stardew-style overworld)
- Explore the map, enter buildings, discover the environment
- No NPCs in MVP - focus on environmental storytelling
- Find the quantum box somewhere in the world to return to the lab
- Can jump at any time once you find the box (free return)

### 3. Universe Types

**Utopia**
- Box spawns near center, clearly visible
- Beautiful environments: gardens, clean paths, pristine buildings
- Explorable buildings: Library, greenhouse, cottages
- Easy to navigate, no environmental hazards

**Neutral**
- Box spawns at random location
- Mixed environments: nature and simple structures
- Explorable buildings: Abandoned cabin, old barn, caves
- Standard navigation difficulty

**Dystopia**
- Box spawns far from start point
- Hostile environments: ruins, toxic areas, decay
- Explorable buildings: Ruined factory, bunker, collapsed structures
- Environmental hazards: toxic pools, unstable ground
- Optional: Visual timer showing world collapse/countdown pressure

## Procedural Generation System

### Chunk-Based World Generation
- Each world is a **5x5 grid** of chunks (25 total)
- Each chunk is **10x10 tiles** (manageable, hand-craftable size)
- Chunks are pre-designed but assembled randomly

### Chunk Types

**Base Chunks** (appear in all universe types):
- Meadow (3 variants: flowers, tall grass, mixed)
- Forest (3 variants: dense, sparse, clearing)
- Water (3 variants: pond, river, lake)
- Path (4 variants: crossroads, straight, curved, dead-end)

**Universe-Specific Chunks**:
- **Utopia**: Garden, fountain plaza, cozy village
- **Neutral**: Abandoned farm, old crossroads, empty market
- **Dystopia**: Toxic waste, crater, collapsed building, burning forest

**Special Chunks**:
- Start chunk (player always spawns here)
- Box chunk (contains the quantum box for return)
- Building chunks (contain explorable interiors)

### Example Chunk Definition
```lua
-- Dystopia toxic waste chunk
local toxicChunk = {
    type = "toxic_waste",
    universe = "dystopia",
    tiles = {
        {1,1,1,2,2,2,1,1,1,1},  -- 1=toxic, 2=waste
        {1,3,3,2,2,2,3,3,1,1},  -- 3=debris
        {1,3,0,0,0,0,0,3,1,1},  -- 0=walkable
        {2,2,0,4,4,4,0,2,2,2},  -- 4=hazard
        {2,2,0,4,5,4,0,2,2,2},  -- 5=container
        {2,2,0,4,4,4,0,2,2,2},
        {1,3,0,0,0,0,0,3,1,1},
        {1,3,3,2,2,2,3,3,1,1},
        {1,1,1,2,2,2,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1}
    },
    hazards = {{x=4,y=5,damage=10}},
    spawnWeight = 0.3  -- 30% chance in dystopia
}
```

### Generation Rules
- Universe type determines chunk distribution percentages
  - Utopia: 60% nature, 30% town, 10% water
  - Neutral: Equal distribution
  - Dystopia: 70% ruins, 20% toxic, 10% other
- Smart adjacency rules (water chunks prefer water neighbors, towns cluster)
- Always ensure path connectivity to box location
- Building entrances always accessible

### Why This System Works
- **Manageable scope**: Design 20-30 chunks, get infinite worlds
- **Designed quality**: Hand-crafted chunks ensure quality over pure noise
- **True exploration**: Every jump creates a unique world to discover
- **Easy expansion**: Add new chunk types to increase variety

## Simplified MVP Features

### What's In
- Walking and exploration
- Enter/exit buildings (simple door interaction)
- Find and use the quantum box
- Basic procedural world generation
- Environmental storytelling through world design

### What's Out (for now)
- NPCs and dialogue
- Inventory system
- Combat or enemies
- Resource gathering
- Complex puzzles
- Save system (each session starts fresh)

## Design Principles
- **Exploration over mechanics**: The joy is in discovering new worlds
- **Atmosphere over complexity**: Focus on mood and environment
- **Player agency**: Choose your risk level with calibration
- **No failure states**: You can always find the box and return
- **Emergent storytelling**: Procedural generation creates unique narratives

## Inspirations
- **Dark Matter** (novel): Core parallel universe concept
- **Stardew Valley**: Visual style, cozy feeling, self-paced gameplay
- **Jarl**: Art direction, colony/settlement mechanics, Viking aesthetic influence
- **Banished**: Systems-building, meaningful failure states
- **No Man's Sky**: Planet hopping, exploration
- **Project Hail Mary**: Space exploration, problem-solving

## Art Direction References
- **Jarl** (https://www.jarl-game.com/): Primary art style reference for atmosphere and environmental design
- **Stardew Valley**: Character design and cozy aesthetic
- Combination creates a unique "cozy yet mysterious multiverse" feeling

## Technical Implementation Plan

### Phase 1: Core Systems (Love2D)
1. Basic Love2D window with conf.lua settings
2. Player sprite and smooth movement
3. Load tilemap with STI from Tiled
4. Collision detection with Bump
5. The Lab room as separate game state

### Phase 2: Procedural Generation
1. Chunk system with Love2D tables
2. Generate chunks using Perlin noise
3. Universe type influences chunk selection
4. Dynamic loading/unloading of chunks
5. Box placement with pathfinding check

### Phase 3: Polish
1. Game states with HUMP (menu, lab, world)
2. Building enter/exit transitions
3. Environmental hazards using Bump filters
4. Shader effects for universe atmosphere
5. Sound with Love2D audio

## Love2D Implementation Details

### Chunk Loading Strategy
```lua
-- Each chunk is 10x10 tiles
-- Load 3x3 chunks around player
-- Unload chunks > 2 chunks away
local activeChunks = {}
local CHUNK_SIZE = 10
local TILE_SIZE = 32
```

### State Management with HUMP
```lua
-- states/lab.lua
-- states/universe.lua
-- states/menu.lua
Gamestate = require "lib.hump.gamestate"
```

### Collision with Bump
```lua
-- Different collision types
-- "player", "wall", "hazard", "box"
local world = bump.newWorld(32)
```

## Next Steps
1. Create basic Love2D game structure
2. Implement player movement with Bump
3. Design chunks in Tiled, export as Lua
4. Build chunk loading system
5. Create Lab state with UI sliders
6. Test universe generation with different parameters