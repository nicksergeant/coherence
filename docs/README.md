# Coherence Documentation

## Overview
Coherence is a top-down pixel art game about jumping between parallel universes, inspired by Blake Crouch's "Dark Matter". This is a learning project built with Rust and Bevy.

## Documentation Structure

### Core Documents

1. **[Game Design](Game.md)** - Core mechanics, gameplay loop, and universe system
2. **[Technical Architecture](Tech.md)** - Technology stack, Bevy/Rust setup, and architecture
3. **[Art Pipeline](Art.md)** - AI-first pixel art generation workflow
4. **[Testing Strategy](Testing.md)** - Pragmatic testing approach for game development
5. **[Project Guidelines](Project.md)** - Development principles and LLM interaction rules

### Quick Links

- **Getting Started**: See [Technical Architecture](Tech.md#getting-started)
- **Game Concept**: See [Game Design](Game.md#core-concept)
- **Contributing**: Follow [Project Guidelines](Project.md#core-principle)
- **Running Tests**: See [Testing Strategy](Testing.md#running-tests)

## Project Status

**Current Phase**: Environment Setup & Core Mechanics
- ✅ Project structure created
- ✅ Bevy window rendering
- ✅ Testing strategy defined
- 🚧 Player movement implementation
- ⏳ Sprite rendering
- ⏳ Collision detection
- ⏳ Universe transition system

## Key Principles

1. **Learning First** - Every decision prioritizes learning Rust/Bevy/gamedev
2. **Small Steps** - Changes are atomic and reviewable (10-50 lines)
3. **Test-Driven** - Features have tests that document expected behavior
4. **AI-Generated Art** - All visuals created through AI pipeline
5. **Documentation-Driven** - Document design before implementation

## Technology Stack

- **Language**: Rust
- **Engine**: Bevy 0.16.1
- **Art**: AI-generated (ComfyUI + SDXL)
- **Style**: Top-down pixel art (Stardew Valley inspired)
- **Platform**: Native macOS/Windows/Linux

## Development Workflow

1. Read relevant documentation
2. Write/update tests for new feature
3. Implement in small increments
4. Verify with `cargo test`
5. Update documentation if needed

## Contact

This is a personal learning project. For context on design decisions, see the individual documentation files.