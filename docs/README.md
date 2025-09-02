# Coherence Documentation

## Overview
Coherence is a top-down pixel art game about jumping between parallel universes, inspired by Blake Crouch's "Dark Matter". This is a learning project built with Lua and Love2D.

## Documentation Structure

### Core Documents

1. **[Game Design](Game.md)** - Core mechanics, gameplay loop, and universe system
2. **[Technical Architecture](Tech.md)** - Technology stack, Love2D/Lua setup, and architecture
3. **[Art Pipeline](Art.md)** - AI-first pixel art generation workflow
4. **[Testing Strategy](Testing.md)** - Pragmatic testing approach for Love2D games
5. **[Project Guidelines](Project.md)** - Development principles and LLM interaction rules

### Quick Links

- **Getting Started**: See [Technical Architecture](Tech.md#getting-started)
- **Game Concept**: See [Game Design](Game.md#core-concept)
- **Contributing**: Follow [Project Guidelines](Project.md#core-principle)
- **Running Tests**: See [Testing Strategy](Testing.md#running-tests)

## Project Status

**Current Phase**: Love2D Foundation & Core Mechanics
- ✅ Project structure created
- ⏳ Love2D basic window and game loop
- ⏳ Player movement with keyboard
- ⏳ Tilemap loading with STI
- ⏳ Collision detection with Bump
- ⏳ Game state management
- ⏳ Universe transition system

## Key Principles

1. **Learning First** - Every decision prioritizes learning Lua/Love2D/gamedev
2. **Small Steps** - Changes are atomic and reviewable (10-50 lines)
3. **Rapid Iteration** - Hot reload and immediate feedback
4. **AI-Generated Art** - All visuals created through AI pipeline
5. **Documentation-Driven** - Document design before implementation

## Technology Stack

- **Language**: Lua
- **Framework**: Love2D 11.5
- **Libraries**: Bump (collision), STI (tilemaps), HUMP (utilities)
- **Tilemap Editor**: Tiled
- **Art**: AI-generated (ComfyUI + SDXL)
- **Style**: Top-down pixel art (Stardew Valley inspired)
- **Platform**: Native macOS/Linux (10-50MB bundles)

## Development Workflow

1. Read relevant documentation
2. Write code with hot reload running
3. Test interactively in-game
4. Iterate rapidly based on feedback
5. Update documentation if needed

## Contact

This is a personal learning project. For context on design decisions, see the individual documentation files.