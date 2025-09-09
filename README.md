# Coherence

A top-down pixel art game about jumping between parallel universes, inspired by "Dark Matter" by Blake Crouch. Built with Love2D as a learning project for Lua and game development.

## Current Status

✅ **Playable Alpha** - Core gameplay loop complete with universe jumping, timers, and game over mechanics.

### What's Working

- **Universe System** - Three distinct universes (Utopian, Neutral, Dystopian) with unique mechanics
- **Portal Mechanic** - Enter the mysterious box to randomly jump between universes
- **Timer Challenges** - Each universe has different time limits to find your way back
- **Visual Effects** - Screen shake, thought bubbles, directional arrows
- **Game Over/Restart** - Full game loop with restart functionality
- **Procedural Positioning** - Portal and player randomly positioned after each jump

### What I've Learned So Far

- **Lua** - Tables, metatables, module system, 1-indexing
- **Love2D** - Game loops, collision detection (Bump), camera systems
- **Game Architecture** - Room management, entity systems, state machines
- **Visual Feedback** - Screen effects, UI overlays, sprite handling

## Running

```bash
# Install Love2D (macOS)
brew install love

# Run the game
love game/
```

## Documentation

- [Game Design](docs/Game.md) - What we're building
- [Technical Notes](docs/Tech.md) - Love2D and Lua setup
- [Learning Guidelines](docs/Project.md) - How this learning project works

---

*This is my first game and first Lua project. The code reflects a learning journey.*