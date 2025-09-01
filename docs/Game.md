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

### Phase 1: Core Systems
1. Basic Bevy setup with pixel-perfect camera
2. Player movement (grid-based or smooth)
3. Simple tilemap rendering
4. The Lab room with UI sliders

### Phase 2: Procedural Generation
1. Chunk system implementation
2. Basic chunk types (meadow, forest, path)
3. Universe type influences generation
4. Box placement logic

### Phase 3: Polish
1. Building enter/exit system
2. Environmental hazards (dystopia)
3. Visual effects and atmosphere
4. Sound and music

## Next Steps
1. Set up Bevy project with basic player movement
2. Create first batch of pixel art chunks (5-6 types)
3. Implement basic chunk-based generation
4. Build the Lab with working calibration sliders
5. Test universe jumping between different world types