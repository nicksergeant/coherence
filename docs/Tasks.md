# Development Tasks

Track development progress by marking tasks complete. The LLM should update this file as tasks are completed.

## Phase 0: Environment Setup ✅
- [x] Install Love2D
- [x] Create project structure
- [x] Set up documentation
- [ ] Create basic Love2D window
- [ ] Add conf.lua with window settings
- [ ] Verify hot reload with lurker

## Phase 1: Core Game Loop
- [ ] Implement love.load, love.update, love.draw
- [ ] Add FPS counter in debug mode
- [ ] Create constants.lua file
- [ ] Add logging system for debugging
- [ ] Test with "Hello World" text

## Phase 2: Player Movement
- [ ] Draw player as colored rectangle (32x32)
- [ ] Implement WASD keyboard input
- [ ] Add player position and speed
- [ ] Frame-independent movement with dt
- [ ] Add screen boundaries
- [ ] Log player position changes

## Phase 3: Tilemap System
- [ ] Install Tiled map editor
- [ ] Create test map (5x5 chunks, 10x10 tiles each)
- [ ] Export map as Lua file
- [ ] Integrate STI library
- [ ] Load and render tilemap
- [ ] Add camera following player

## Phase 4: Collision Detection
- [ ] Integrate Bump library
- [ ] Add player to collision world
- [ ] Define wall tiles as solid
- [ ] Implement collision response
- [ ] Test collision at different speeds
- [ ] Add debug collision box visualization

## Phase 5: Chunk System
- [ ] Implement chunk data structure
- [ ] Create chunk loading logic
- [ ] Add chunk unloading when distant
- [ ] Generate chunks procedurally
- [ ] Save/load chunk state
- [ ] Performance test with 25 chunks

## Phase 6: Game States
- [ ] Integrate HUMP gamestate
- [ ] Create menu state
- [ ] Create lab state
- [ ] Create play state
- [ ] Implement state transitions
- [ ] Add pause functionality

## Phase 7: The Lab
- [ ] Design lab room in Tiled
- [ ] Create quantum device UI
- [ ] Add three calibration sliders:
  - [ ] Stability slider (Utopia/Dystopia)
  - [ ] Coherence slider (Logical/Chaotic)
  - [ ] Resonance slider (Box distance)
- [ ] Implement jump button
- [ ] Store slider values for generation

## Phase 8: Universe Generation
- [ ] Create universe types (Utopia, Neutral, Dystopia)
- [ ] Implement chunk templates for each type
- [ ] Add distribution rules per universe
- [ ] Place quantum box based on Resonance
- [ ] Ensure path to box exists
- [ ] Add universe-specific color palettes

## Phase 9: Universe Features
- [ ] Add building enter/exit system
- [ ] Create building interiors
- [ ] Implement environmental hazards (Dystopia)
- [ ] Add particle effects
- [ ] Create atmosphere shaders
- [ ] Add ambient sounds

## Phase 10: Polish
- [ ] Add sprite graphics (replace rectangles)
- [ ] Implement smooth transitions
- [ ] Add sound effects
- [ ] Create background music
- [ ] Add save/load system
- [ ] Package for distribution

## Current Focus
**Active Task:** Create basic Love2D window

## Completed Milestones
- Documentation system created
- Tech stack decided (Love2D + Lua)
- Game design documented

## Bugs to Fix
- [ ] (None yet)

## Performance Goals
- [ ] Maintain 60 FPS with 25 chunks loaded
- [ ] Chunk load time < 100ms
- [ ] Memory usage < 100MB

## Notes for LLM
- Always mark tasks with [x] when complete
- Add new bugs to "Bugs to Fix" section
- Update "Current Focus" when switching tasks
- Log all major state changes in console
- Test each feature before marking complete