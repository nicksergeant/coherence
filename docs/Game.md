# Game Design

## Current Implementation

A playable top-down pixel art game where players jump between parallel universes through a mysterious portal box. Each universe has distinct visual themes and gameplay challenges.

## Core Gameplay (Implemented)

### Universe System
- **Utopian** - Safe green world, no initial timer, but 60-second timer after first jump
- **Neutral** - Snowy world with 30-second timer to return
- **Dystopian** - Fiery chaos with screen shake and only 10 seconds to escape

### Portal Mechanics
- Enter the portal box by pressing X when near
- Press SPACE inside to randomly jump to another universe
- Portal and player randomly repositioned after each jump (min 1500px apart)
- Press X to exit without jumping

### Visual Feedback
- **Thought Bubbles** - Display universe-specific thoughts on arrival
- **Directional Arrows** - Guide player to portal when >300px away
- **Screen Shake** - Universe transition effect and dystopian ambience
- **Timer Display** - Shows remaining time in timed universes
- **Game Over Screen** - Full restart system with ENTER key

### Controls
- **WASD** - Movement (250 speed walk, 500 speed run with Shift)
- **X** - Interact with portal
- **SPACE** - Jump universes (when inside portal)
- **ENTER** - Restart after game over
- **F1** - Debug mode toggle

## Technical Architecture

### Room System
- `room_manager.lua` - Handles transitions between rooms
- `overworld.lua` - Main game world with universe mechanics
- `portal_interior.lua` - Inside the portal box

### Entity System  
- `player.lua` - Player character with collision and movement
- `portal.lua` - Portal box entity with interaction zones

### Constants
All magic numbers extracted to `constants.lua` for easy tuning:
- Portal positioning
- Arrow visibility thresholds  
- Universe timers
- Shake intensities
- Map dimensions

## Visual Style (Implemented)
- Top-down 3/4 perspective
- 48x48 character sprites
- 128x128 tile size  
- Procedurally generated snow tiles for Neutral universe
- Fire tiles for Dystopian universe
- Y-sorted rendering for proper depth

## Future Enhancements

### Planned Features
- Multiple portal boxes to discover
- Universe-specific hazards and obstacles
- Collectible items that persist across jumps
- More universe types (Frozen, Overgrown, Mechanical, etc.)
- Save system to track best times and universes visited

### Technical Improvements
- Convert entities from singletons to instances
- Implement proper chunk-based infinite world
- Add particle effects for universe transitions
- Sound effects and ambient music per universe