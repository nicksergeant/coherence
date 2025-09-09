# Development Tasks

Track development progress by marking tasks complete.

## Phase 0: Environment Setup ✅
- [x] Install Love2D
- [x] Create project structure
- [x] Set up documentation
- [x] Create basic Love2D window
- [x] Add conf.lua with window settings
- [x] Verify hot reload with lurker

## Phase 1: Core Game Loop ✅
- [x] Implement love.load, love.update, love.draw
- [x] Add FPS counter in debug mode
- [x] Create constants.lua file
- [x] Add logging system for debugging
- [x] Test with basic game

## Phase 2: Player Movement ✅
- [x] Draw player with sprites
- [x] Implement WASD keyboard input
- [x] Add player position and speed
- [x] Frame-independent movement with dt
- [x] Add world boundaries
- [x] Walk/run with shift key

## Phase 3: Room & Entity System ✅
- [x] Create room manager for transitions
- [x] Implement entity system
- [x] Add portal entity with interactions
- [x] Create portal interior room
- [x] Add fade transitions between rooms
- [x] Implement Y-sorted rendering

## Phase 4: Collision Detection ✅
- [x] Integrate Bump library
- [x] Add player to collision world
- [x] Add portal collision boxes
- [x] Implement collision response
- [x] Test collision at different speeds
- [x] Add debug collision box visualization

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
**Active Task:** Import constants and continue polish

## Completed Milestones
- ✅ Playable game with core mechanics
- ✅ Three universe system with unique mechanics  
- ✅ Portal jumping with random positioning
- ✅ Timer challenges and game over system
- ✅ Visual feedback (arrows, shake, thought bubbles)
- ✅ Complete game loop with restart
- ✅ Code cleanup and documentation update

## Recent Bug Fixes
- [x] Fixed arrow directions being inverted
- [x] Fixed player position not updating (wrong entity reference)
- [x] Fixed portal position persistence across jumps
- [x] Fixed collision world update issues

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