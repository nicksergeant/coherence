# Coherence

**🎓 A learning project**: Building a game to learn Lua, Love2D, and game development fundamentals.

## The Game Concept

A top-down pixel art game about jumping between parallel universes, inspired by the novel "[Dark Matter](https://en.wikipedia.org/wiki/Dark_Matter_(Crouch_novel))" by Blake Crouch.

In Coherence, you control the chaos. Adjust your quantum device's parameters—Stability, Coherence, and Resonance—before each jump into the multiverse. Will you land in a utopian paradise or a collapsing dystopia? Every universe is procedurally generated, ensuring no two jumps are the same.

## Learning Journey

This project exists primarily to learn:

### What I'm Learning
- **Lua** - Simple, powerful scripting language (also useful for Neovim config)
- **Love2D** - 2D game framework with immediate mode rendering and hot reload
- **Game Development** - First game project, learning core concepts like game loops, collision, rendering
- **Procedural Generation** - Chunk-based world generation algorithms
- **AI Art Workflows** - Building automated pipelines for asset creation

### Current Progress

🚧 **Early Development** - Setting up Love2D foundation

- ✅ Project structure and documentation
- ⏳ Basic Love2D window and game loop
- ⏳ Player movement with keyboard input
- ⏳ Tilemap rendering with STI (Simple Tiled Implementation)
- ⏳ Collision detection with Bump
- ⏳ Game state management with HUMP
- ⏳ Universe transition system
- ⏳ Procedural world generation
- ⏳ Art pipeline setup

## Tech Stack

Chosen for rapid iteration and learning:

- **Game Framework**: Love2D - Fast iteration, proven track record (Balatro)
- **Language**: Lua - Simple, powerful, useful beyond gamedev (Neovim)
- **Tilemap Editor**: Tiled - Industry standard, works great with STI
- **Libraries**: Bump (collision), STI (tilemaps), HUMP (utilities)
- **Art Pipeline**: AI-generated pixel art - Since I can't draw
- **Distribution**: Love2D bundles to ~10-50MB native apps

## Documentation

Extensive documentation as part of the learning process:

- [Game Design](docs/Game.md) - Core mechanics and gameplay
- [Technical Architecture](docs/Tech.md) - Technology decisions and setup
- [Art Pipeline](docs/Art.md) - AI-powered asset generation
- [Testing Strategy](docs/Testing.md) - How to test games effectively
- [Project Guidelines](docs/Project.md) - Development principles

## Getting Started

```bash
# Clone the repository
git clone https://github.com/yourusername/coherence.git
cd coherence

# Install Love2D (macOS)
brew install love

# Run the game
love game/

# Or run with hot reload (if using a file watcher)
# Example with entr:
ls game/*.lua | entr -r love game/
```

## Project Structure

```
Coherence/
├── game/       # Love2D game code
│   ├── main.lua
│   ├── conf.lua
│   ├── states/
│   ├── lib/    # Third-party libraries (Bump, STI, HUMP)
│   └── assets/
├── art/        # AI art generation pipeline (not yet implemented)
├── docs/       # Extensive documentation
└── scripts/    # Build and utility scripts (planned)
```

## Development Approach

1. **Small Steps**: Every change is 10-50 lines for learning clarity
2. **Document Everything**: Understanding > implementation
3. **Test-Driven**: Tests explain what features should do
4. **Learn in Public**: Code and docs show the learning process

## Contributing

This is a personal learning project, but if you're also learning:
- Feel free to explore the code and documentation
- Issues/questions that help me learn are welcome
- Consider forking for your own learning journey

## Why This Stack?

- **Why Love2D over Godot/Unity?** Rapid iteration, simple distribution, learn Lua for Neovim
- **Why Lua over other languages?** Simple to learn, useful for config files, proven for games
- **Why not web-based?** Want native performance and simple binary distribution
- **Why AI art?** Can't draw, but want custom assets
- **Why so much documentation?** Writing helps understanding

## Current Focus

Setting up Love2D foundation with:
- Basic game loop (love.load, love.update, love.draw)
- Keyboard input handling
- Simple sprite rendering
- Understanding Lua tables and metatables
- Game state management patterns

## License

MIT - See [LICENSE](LICENSE) file for details. Feel free to use any code for your own learning!

---

*This is my first game and first Lua project. The code reflects a learning journey, not production best practices. That's intentional - this is about learning, not shipping.*