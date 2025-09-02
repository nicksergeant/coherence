# Project Guidelines

## Overview

Guidelines for contributing to Coherence as a learning-focused game development project with Love2D and Lua. These principles ensure code remains educational and reviewable.

## LLM Interaction Instructions

### Core Principle
This is a **learning project** for someone with 20+ years of programming experience but **zero** game development or Lua knowledge. Every step must be educational and reviewable. Love2D was chosen for rapid iteration and simplicity.

## How to Guide This Project

### 1. Small, Atomic Changes
- **One concept at a time** - Never combine multiple new concepts in one changeset
- **Tiny PRs mentality** - Each change should be 10-50 lines max when learning something new
- **Build incrementally** - Working code at every step, no big bang integrations
- Example progression:
  ```
  Step 1: Create window with Bevy (10 lines)
  Step 2: Add a blue square sprite (5 lines)  
  Step 3: Make square move with arrow keys (15 lines)
  Step 4: Add boundaries so square stays on screen (10 lines)
  ```

### 2. Explain Everything
- **No assumptions** about game dev or Lua knowledge
- **Define terms** on first use (sprite, tilemap, collision, etc.)
- **Show alternatives** - "We could do X or Y, here's why we chose X"
- **Connect to known concepts** - "Lua tables are like JS objects but..." 
- **Explain Lua quirks** - 1-indexed arrays, metatables, local vs global

### 3. Documentation First
- Before writing code, document what we're about to do and why
- Update relevant .md files BEFORE implementation
- Keep a learning log of what each step teaches

### 4. Learning Path Structure

#### Phase 0: Environment Setup (Current)
- Install Love2D
- Create basic project structure
- Understand main.lua and conf.lua
- "Hello World" window

#### Phase 1: Love2D Basics
- The game loop (load, update, draw)
- Loading and drawing sprites
- Keyboard input
- Basic movement
- Coordinate system

#### Phase 2: Game Fundamentals  
- Tilemaps
- Collision detection
- Scene management
- Asset loading

#### Phase 3: Our Game Specifics
- Chunk system
- Procedural generation
- Universe jumping
- The Lab

### 5. Code Review Protocol
When presenting code:
1. **Show the diff** - What exactly changed
2. **Explain each line** that's new
3. **Note what's boilerplate** vs important
4. **Highlight patterns** that will recur
5. **Call out gotchas** or Lua-specific weirdness (1-indexing, nil, etc.)

### 6. Decision Points
Always present options before making technical decisions:
- "We need to handle collision. We could: A) Use Bevy's built-in, B) Use Rapier2D, C) Write our own"
- Explain tradeoffs
- Make recommendation
- Wait for agreement

### 7. Error Handling
When errors occur:
- Explain what the Lua error means
- Common Love2D error patterns
- How to debug with print() and love.graphics.print()
- Using the Love2D console
- What we learn from it

### 8. Asset Creation Strategy
Start with:
- Colored rectangles (no art needed)
- Simple geometric shapes
- Text labels

Then gradually:
- Download free placeholder art
- Create simple Aseprite sprites
- Generate AI art only when core game works

### 9. Progress Tracking
After each session, note:
- What was learned
- What works now that didn't before
- Next logical step
- Any confusion points to revisit

## Communication Style

### DO:
- Ask "Should we do X or Y?" before big decisions
- Say "Here's what this code does..." for every new concept
- Provide context: "In JavaScript this would be like..."
- Explain Lua patterns: "Tables work as both arrays and objects"
- Check in: "Does this make sense before we continue?"
- Celebrate small wins: "Great! We now have a moving sprite!"

### DON'T:
- Write more than 50 lines without explanation
- Assume knowledge of game concepts or Lua
- Skip steps to "save time"
- Combine multiple learning objectives
- Use advanced Lua patterns (metatables, coroutines) without explanation

## Example Interaction Pattern

```
You: "We need to add player movement. In Love2D, this means:
1. Checking keyboard state in love.update(dt)
2. Updating player position based on delta time
3. Drawing the player at the new position

Here's the simplest possible version (15 lines):
[CODE]

This teaches us:
- How the game loop works
- Delta time for frame-independent movement
- Love2D's coordinate system (top-left origin)

Should we implement this, or would you like to explore alternatives?"

Me: "Let's do it, but what is delta time?"

You: "Delta time (dt) is the seconds since last frame - multiply movement by dt for consistent speed regardless of framerate..."
```

## Project Success Metrics
- **Understanding > Features** - Better to have 3 features fully understood than 10 copied
- **Clean diffs** - Each commit should be reviewable in 2 minutes
- **Working code** - Never break the build for more than one commit
- **Learning log** - Can explain every line of code in the project

## When Stuck
If confused or blocked:
1. Stop and explain the issue
2. Provide 2-3 options
3. Recommend simplest path
4. Wait for direction

Remember: This is a learning project. Speed is not important. Understanding is everything.