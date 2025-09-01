# Coherence

**🎓 A learning project**: Building a game to learn Rust, Bevy, and game development fundamentals.

## The Game Concept

A top-down pixel art game about jumping between parallel universes, inspired by the novel "[Dark Matter](https://en.wikipedia.org/wiki/Dark_Matter_(Crouch_novel))" by Blake Crouch.

In Coherence, you control the chaos. Adjust your quantum device's parameters—Stability, Coherence, and Resonance—before each jump into the multiverse. Will you land in a utopian paradise or a collapsing dystopia? Every universe is procedurally generated, ensuring no two jumps are the same.

## Learning Journey

This project exists primarily to learn:

### What I'm Learning
- **Rust** - Coming from TypeScript, learning ownership, borrowing, and systems programming
- **Bevy** - Understanding Entity Component System (ECS) architecture
- **Game Development** - First game project, learning core concepts like game loops, collision, rendering
- **Procedural Generation** - Chunk-based world generation algorithms
- **AI Art Workflows** - Building automated pipelines for asset creation

### Current Progress

🚧 **Early Development** - Building foundational systems

- ✅ Project structure and documentation
- ✅ Basic Bevy window rendering
- ✅ Testing strategy defined
- 🚧 Player movement implementation
- ⏳ Sprite rendering and collision
- ⏳ Universe transition system
- ⏳ Procedural world generation
- ⏳ Art pipeline setup

## Tech Stack

Chosen for maximum learning opportunity:

- **Game Engine**: Bevy (Rust) - Chose over Unity/Godot to learn Rust
- **Language**: Rust - Challenging coming from TypeScript, but valuable
- **Art Pipeline**: AI-generated pixel art - Since I can't draw
- **Testing**: Comprehensive test suite - Learning TDD in game context

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

# Run the game (currently just a window with a white square)
cd game
cargo run

# Run tests
cargo test

# Watch mode for development
cargo watch -x run
```

## Project Structure

```
Coherence/
├── game/       # Rust/Bevy game code
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

- **Why Rust over easier options?** Maximum learning, transferable skills
- **Why Bevy over Godot?** To learn ECS patterns and Rust together
- **Why AI art?** Can't draw, but want custom assets
- **Why so much documentation?** Writing helps understanding

## Current Focus

Building player movement with full understanding of:
- How Bevy's ECS works
- How input systems connect to movement
- How to test game mechanics
- How transforms work in 2D space

## License

MIT - See [LICENSE](LICENSE) file for details. Feel free to use any code for your own learning!

---

*This is my first game and first Rust project. The code reflects a learning journey, not production best practices. That's intentional - this is about learning, not shipping.*