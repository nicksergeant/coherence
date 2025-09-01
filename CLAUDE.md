# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Coherence is a top-down pixel art game about jumping between parallel universes, inspired by "Dark Matter" by Blake Crouch. This is a learning project for someone with programming experience but zero game development, Rust, or Bevy knowledge.

## Tech Stack

- **Game Engine**: Bevy (Rust ECS framework)
- **Language**: Rust
- **Art Pipeline**: AI-generated pixel art (ComfyUI + SDXL) - not yet implemented
- **Style**: Top-down 16-bit pixel art inspired by Stardew Valley and Jarl

## Development Commands

### Game Development (from `game/` directory)
```bash
# Build the game
cargo build

# Run the game
cargo run

# Check for compilation errors without building
cargo check

# Run linter for code quality
cargo clippy

# Format code
cargo fmt

# Watch for changes and auto-rebuild (if cargo-watch is installed)
cargo watch -x run

# Run with release optimizations
cargo build --release
cargo run --release
```

### Development Tools Setup
```bash
# Install recommended development tools
rustup component add clippy rustfmt rust-analyzer
cargo install cargo-watch  # For hot-reload during development
```

## Architecture

### Project Structure
```
Coherence/
├── game/           # Rust/Bevy game code
│   ├── src/       # Source code (currently just main.rs)
│   ├── assets/    # Game assets (sprites, sounds, etc.) - to be created
│   └── Cargo.toml # Rust dependencies
├── art/           # AI art generation pipeline - planned
├── docs/          # Design documents
│   ├── Game.md    # Core mechanics and gameplay
│   ├── Tech.md    # Architecture and technical details
│   ├── Art.md     # Art pipeline documentation
│   └── Project.md # Development guidelines
└── scripts/       # Build and utility scripts - planned
```

### Game Architecture (Planned)
- **ECS (Entity-Component-System)**: Bevy's architecture for managing game entities
- **Chunk-based world generation**: Procedural universe generation
- **Universe types**: Utopia, Neutral, Dystopia with different characteristics
- **Core loop**: Lab → Universe exploration → Find quantum box → Return

## Development Guidelines

### IMPORTANT: Teaching Role
**Claude must act as a Rust/Bevy instructor throughout this entire project:**
- Explain EVERY new concept, no matter how basic
- Break down each line of code and its purpose
- Explain Rust syntax, conventions, and idioms as they appear
- Describe what each Cargo command does and why
- Never assume prior Rust or game development knowledge
- Use analogies to TypeScript/JavaScript where helpful
- Explain error messages in detail when they occur

### Learning Project Principles
1. **Small, atomic changes**: Each change should be 10-50 lines when learning new concepts
2. **Explain everything**: Every macro (!), trait, ownership concept, etc.
3. **NO COMMENTS in code**: Never add code comments unless something is genuinely unusual or complex that requires inline documentation
4. **Document first**: Update docs before implementation
5. **One concept at a time**: Never combine multiple new Rust/Bevy concepts
6. **Working code at every step**: No big bang integrations
7. **Teaching moments**: Every step is an opportunity to learn Rust fundamentals

### Current Development Phase
**Phase 0: Environment Setup** (Current)
- Basic Rust/Bevy project created
- Minimal `main.rs` with "Hello, world!"
- Next: Create Bevy window and basic game loop

### Bevy-Specific Notes
- Assets should be placed in `game/assets/` directory
- Use Bevy's hot-reload feature during development
- Sprite standards: 32x32px tiles, PNG with transparency
- ECS components should be small and focused

### Key Technical Decisions
- **Bevy over Godot/Unity**: For Rust learning and ECS architecture
- **Native binaries**: Not a web game
- **Pixel art style**: Low-fi graphics focusing on gameplay
- **Procedural generation**: Each universe is unique

## Important References
- **IMPORTANT**: Always check Bevy version (currently 0.16.1) and use latest API
- **Bevy Official Docs**: https://docs.rs/bevy/latest/bevy/
- **Bevy Examples**: https://github.com/bevyengine/bevy/tree/main/examples
- **Bevy Book**: https://bevyengine.org/learn/book/introduction/
- **Unofficial Bevy Cheat Book**: Essential resource for Bevy patterns
- **Example projects to study**:
  - AspenHalls: 2D top-down RPG in Bevy
  - bevy-colony-sim-game: Colony sim mechanics
  - seldom_pixel: Bevy plugin for pixel art games