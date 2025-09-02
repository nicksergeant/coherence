# Testing Strategy

## Core Philosophy

We test **game features**, not code structure. A test should answer: "Can the player do X?" not "Does function Y work?"

### Interactive Testing First
Love2D games are best tested interactively. The fast iteration cycle means we can test by playing. Automated tests come second for regression prevention.

## Testing Principles

### 1. Debug Mode Features
Build debugging tools directly into the game:

```lua
-- Show collision boxes
if DEBUG then
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("line", player.x, player.y, player.w, player.h)
end

-- Show FPS and stats
if DEBUG then
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Chunks: " .. #activeChunks, 10, 30)
end
```

### 2. Test Through Play
The best test is playing the game. Focus on:

**Manual Testing Checklist:**
- Player moves smoothly with keyboard
- Collision stops player at walls
- Chunks load/unload properly
- Universe transitions work
- Performance stays above 60 FPS

**Debug Commands:**
```lua
-- Add debug keys
function love.keypressed(key)
    if key == "f1" then DEBUG = not DEBUG end
    if key == "f2" then showCollision = not showCollision end
    if key == "f3" then teleportToBox() end
    if key == "f4" then regenerateWorld() end
end
```

### 3. Automated Testing with Busted
For critical logic, use Busted (Lua testing framework):

```lua
-- tests/player_spec.lua
describe("Player", function()
    it("should move right", function()
        local player = require("src.player")
        player.x = 0
        player:move("right", 1.0) -- dt = 1 second
        assert.are.equal(100, player.x)
    end)
end)
```

Run tests: `busted tests/`

## Love2D Testing Approaches

### 1. Visual Debugging
The fastest way to test in Love2D:

```lua
-- Debug overlay
function drawDebug()
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Player: " .. player.x .. ", " .. player.y, 10, 50)
    love.graphics.print("State: " .. currentState, 10, 70)
    love.graphics.print("Universe: " .. universe.type, 10, 90)
    love.graphics.pop()
end
```

### 2. Assertion Helpers
Build assertions into the game:

```lua
function assert_player_in_bounds()
    assert(player.x >= 0 and player.x <= world.width)
    assert(player.y >= 0 and player.y <= world.height)
end

-- Call in update loop during development
if DEBUG then
    assert_player_in_bounds()
end
```
```

### 3. Performance Monitoring
Build in performance tracking:

```lua
local perfStats = {
    fps = 0,
    drawCalls = 0,
    memoryUsage = 0,
}

function updatePerfStats(dt)
    perfStats.fps = love.timer.getFPS()
    perfStats.memoryUsage = collectgarbage("count")
end
```

## Test Categories

### 1. Interactive Feature Testing
Test by playing with debug mode enabled:

**Debug Checklist:**
- Player movement feels smooth
- Collision detection works at all speeds
- Chunks load without visible pop-in
- Universe transitions maintain state
- No memory leaks (watch Lua memory usage)

### 2. Test States
Create specific game states for testing:

```lua
-- states/test_collision.lua
local TestCollision = {}

function TestCollision:enter()
    -- Create test scenario
    self.player = {x = 100, y = 100, w = 32, h = 32}
    self.wall = {x = 200, y = 100, w = 32, h = 32}
end

function TestCollision:update(dt)
    -- Test movement toward wall
    self.player.x = self.player.x + 100 * dt
    
    -- Check collision
    if checkCollision(self.player, self.wall) then
        print("Collision detected!")
    end
end

function TestCollision:draw()
    love.graphics.rectangle("fill", self.player.x, self.player.y, 32, 32)
    love.graphics.rectangle("fill", self.wall.x, self.wall.y, 32, 32)
end

return TestCollision
```

### 3. Console Commands
Add a debug console for live testing:

```lua
-- Debug console commands
local commands = {
    teleport = function(x, y)
        player.x = tonumber(x) or 0
        player.y = tonumber(y) or 0
    end,
    
    spawn_box = function()
        spawnQuantumBox(player.x + 100, player.y)
    end,
    
    set_universe = function(type)
        changeUniverse(type)
    end,
    
    reload_chunks = function()
        clearChunks()
        loadChunksAroundPlayer()
    end
}
```

### 4. Performance Benchmarks
Monitor critical operations:

```lua
function benchmarkChunkGeneration()
    local start = love.timer.getTime()
    for i = 1, 100 do
        generateChunk(i, i)
    end
    local elapsed = love.timer.getTime() - start
    print("Generated 100 chunks in " .. elapsed .. " seconds")
end
```

## Test Utilities

Common testing helpers for Love2D:

### Simulate Input
```lua
-- Fake keyboard input
function simulateKeypress(key)
    love.keypressed(key)
end

function simulateKeyrelease(key)
    love.keyreleased(key)
end

-- Fake mouse input
function simulateClick(x, y)
    love.mousepressed(x, y, 1)
    love.mousereleased(x, y, 1)
end
```

### Time Control
```lua
-- Speed up/slow down time for testing
local timeScale = 1.0

function love.update(dt)
    dt = dt * timeScale
    -- Rest of update logic
end

-- In tests
timeScale = 10  -- Run 10x faster
timeScale = 0.1 -- Run in slow motion
```

### State Snapshots
```lua
-- Save and restore game state
function saveState()
    return {
        player = {x = player.x, y = player.y},
        universe = universe.type,
        chunks = table.copy(activeChunks)
    }
end

function restoreState(state)
    player.x = state.player.x
    player.y = state.player.y
    universe.type = state.universe
    activeChunks = state.chunks
end
```

## Love2D Testing Philosophy

### Interactive First
Love2D's strength is rapid iteration. Use it:
- Test by playing the game
- Add debug visualizations liberally
- Use hot reload to test changes instantly

### Automated When Beneficial
Write automated tests for:
- Core game logic (collision math, etc.)
- Procedural generation consistency
- Save/load functionality

### Visual Testing is Valid
Unlike unit tests, visual confirmation is legitimate:
- "Does it look right?" is a valid test
- "Does it feel good?" matters for games
- Performance "feels" smooth at 60 FPS

## Common Love2D Testing Patterns

### Debug Mode Toggle
```lua
-- Global debug flag
DEBUG = false

function love.keypressed(key)
    if key == "f1" then
        DEBUG = not DEBUG
    end
end

function love.draw()
    -- Normal game drawing
    drawGame()
    
    -- Debug overlay
    if DEBUG then
        drawDebugInfo()
    end
end
```

### Test Harness State
```lua
-- Create a test harness game state
local TestHarness = {}

function TestHarness:init()
    self.tests = {
        "movement",
        "collision", 
        "chunks",
        "universe"
    }
    self.currentTest = 1
end

function TestHarness:keypressed(key)
    if key == "space" then
        self.currentTest = self.currentTest + 1
        self:loadTest(self.tests[self.currentTest])
    end
end
```

## Practical Workflow

### Adding a New Feature
1. Create feature in isolation (test state)
2. Play with it interactively
3. Add debug visualizations
4. Integrate into main game
5. Add automated tests if needed

### When to Test What
- **Always test interactively**: Every feature
- **Add debug mode for**: Complex systems (chunks, collision)
- **Write automated tests for**: Math functions, algorithms
- **Create test states for**: Isolated feature development

## LLM Development Workflow

### The Right Way
1. **Ask LLM to implement ONE feature**
2. **IMMEDIATELY run the game** (don't accumulate changes)
3. **Play the feature yourself**
4. **Check the console for logs**
5. **Report issues WITH the log output**
6. **Ask for more logging if behavior is unclear**
7. **Only mark task complete after it works**

### Common LLM Issues and Fixes

**Issue:** LLM doesn't understand what's happening
**Fix:** Ask it to add logging to that specific feature

**Issue:** Feature works differently than expected
**Fix:** Share gameplay logs so LLM sees actual behavior

**Issue:** LLM makes changes to Tiled map files
**Fix:** STOP! Revert changes, edit maps only in Tiled

**Issue:** Constants hardcoded everywhere
**Fix:** Remind LLM to use constants.lua

**Issue:** No logging of state changes
**Fix:** Ask LLM to add print() statements with [CATEGORY] prefix

### Testing Checklist for LLM
```markdown
- [ ] Feature implemented
- [ ] Game runs without errors
- [ ] Logging added for state changes
- [ ] Constants in constants.lua
- [ ] Tested interactively
- [ ] Debug mode shows useful info
- [ ] Task marked complete in Tasks.md
```

## Running Tests

```bash
# Run the game normally
love game/

# Run with debug mode
love game/ --debug

# Run automated tests (if using Busted)
cd game && busted

# Run with console visible (macOS)
love game/ --console

# Profile performance
love game/ --profile
```

## Development Tips

### Hot Reload Setup
```lua
-- main.lua
lurker = require "lib.lurker"
lurker.postswap = function(f)
    print("Reloaded: " .. f)
end

function love.update(dt)
    lurker.update()
    -- rest of update
end
```

### Quick Iteration Loop
1. Make change in editor
2. Save file (triggers hot reload)
3. See change immediately in game
4. Press F1 for debug info
5. Press F5 to reload current state

## Example: Complete Movement Test

```lua
-- game/tests/movement_test.lua
local Player = require("src.player")

-- Simple movement test
describe("Player Movement", function()
    local player
    
    before_each(function()
        player = Player:new(100, 100)
    end)
    
    it("moves right", function()
        player:update(1.0, {right = true})
        assert.are.equal(200, player.x)
        assert.are.equal(100, player.y)
    end)
    
    it("moves left", function()
        player:update(1.0, {left = true})
        assert.are.equal(0, player.x)
        assert.are.equal(100, player.y)
    end)
    
    it("normalizes diagonal movement", function()
        player:update(1.0, {right = true, up = true})
        -- Should move at ~70.7 pixels in each direction (normalized)
        assert.is_true(math.abs(player.x - 170.7) < 1)
        assert.is_true(math.abs(player.y - 29.3) < 1)
    end)
end)

-- Interactive test state
-- game/states/test_movement.lua
local TestMovement = {}

function TestMovement:init()
    self.player = {x = 400, y = 300, speed = 200}
    self.trails = {}  -- Visual trail for debugging
end

function TestMovement:update(dt)
    -- Store trail
    table.insert(self.trails, {x = self.player.x, y = self.player.y})
    if #self.trails > 100 then
        table.remove(self.trails, 1)
    end
    
    -- Handle movement
    local dx, dy = 0, 0
    if love.keyboard.isDown("right") then dx = dx + 1 end
    if love.keyboard.isDown("left") then dx = dx - 1 end
    if love.keyboard.isDown("up") then dy = dy - 1 end
    if love.keyboard.isDown("down") then dy = dy + 1 end
    
    -- Normalize diagonal
    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.707
        dy = dy * 0.707
    end
    
    self.player.x = self.player.x + dx * self.player.speed * dt
    self.player.y = self.player.y + dy * self.player.speed * dt
end

function TestMovement:draw()
    -- Draw trail
    love.graphics.setColor(0.5, 0.5, 1, 0.3)
    for _, pos in ipairs(self.trails) do
        love.graphics.circle("fill", pos.x, pos.y, 2)
    end
    
    -- Draw player
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.player.x, self.player.y, 16)
    
    -- Debug info
    love.graphics.print("Movement Test - Arrow keys to move", 10, 10)
    love.graphics.print(string.format("Position: %.1f, %.1f", self.player.x, self.player.y), 10, 30)
end

return TestMovement
```

## Key Takeaway

**In Love2D, playing IS testing.** The rapid iteration cycle means you can test ideas immediately. Add debug visualization and interactive test states to make testing enjoyable and productive.