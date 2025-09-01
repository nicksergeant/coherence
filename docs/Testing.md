# Testing Strategy for Coherence

## Core Philosophy

We test **game features**, not code structure. A test should answer: "Can the player do X?" not "Does system Y work?"

### The Neural Network Test
Every test we write should still be valid if we replaced our entire ECS implementation with a magic AI that produces the right game state. This forces us to test observable behavior, not implementation.

## Testing Principles

### 1. Data-Driven Tests
Tests are defined by input → expected output, not by code that exercises APIs.

```rust
// Good: Data describes the test
check_player_movement(
    start_pos: Vec2::new(0.0, 0.0),
    input: KeyCode::ArrowRight,
    duration: 1.0,
    expected_pos: Vec2::new(100.0, 0.0),
);

// Bad: Test knows about internals
let mut velocity = Velocity::default();
velocity.x = 100.0;
assert_eq!(velocity.x, 100.0);
```

### 2. Test Features at the Boundary
The boundary is what the player experiences, not internal APIs.

**What we test:**
- Player moves when arrow key pressed
- Collision prevents movement through walls
- Picking up items increases inventory
- Universe transitions maintain player state

**What we DON'T test (usually):**
- Individual ECS components
- System execution order (unless critical)
- Internal helper functions
- Resource management

### 3. Fast Tests by Default, Visual When Needed
Tests run headless with MinimalPlugins by default. Add graphics when debugging:

```rust
fn test_app() -> App {
    let mut app = App::new();
    
    if std::env::var("VISUAL_TEST").is_ok() {
        app.add_plugins(DefaultPlugins);
    } else {
        app.add_plugins(MinimalPlugins);
    }
    
    app
}
```

Run visual: `VISUAL_TEST=1 cargo test collision -- --nocapture`

## Test Patterns

Choose the right pattern for your testing scenario:

### Pattern 1: Simple Check Functions
For basic invariants and simple mechanics.

```rust
#[track_caller]
fn check_movement(start: Vec2, input: KeyCode, expected: Vec2) {
    let mut app = test_app();
    
    app.world.spawn((
        Player,
        Transform::from_translation(start.extend(0.0))
    ));
    
    app.world.resource_mut::<ButtonInput<KeyCode>>().press(input);
    app.update();
    
    let player = app.world
        .query_filtered::<&Transform, With<Player>>()
        .single(&app.world);
    
    assert_eq!(player.translation.truncate(), expected);
}
```

### Pattern 2: Test Struct (for Complex Scenarios)
For tests that benefit from being playable and have complex setup.

```rust
struct Test<T> {
    setup: fn(&mut App) -> T,
    setup_graphics: fn(&mut App, &T),
    frames: u64,
    check: fn(&App, T),
}

impl<T> Test<T> {
    pub fn run(self) {
        let mut app = App::new();
        
        // Add MinimalPlugins or DefaultPlugins based on env
        if std::env::var("VISUAL_TEST").is_ok() {
            app.add_plugins(DefaultPlugins);
            let data = (self.setup)(&mut app);
            (self.setup_graphics)(&mut app, &data);
        } else {
            app.add_plugins(MinimalPlugins);
            let data = (self.setup)(&mut app);
        }
        
        // Run simulation
        for _ in 0..self.frames {
            app.update();
        }
        
        // Check results
        (self.check)(&app, data);
    }
}
```

### Pattern 3: Direct System Testing
For testing isolated systems without full app overhead.

```rust
#[test]
fn test_collision_calculation() {
    let mut world = World::new();
    
    // Setup entities directly
    let entity_a = world.spawn((
        Transform::from_xyz(0.0, 0.0, 0.0),
        Collider { radius: 1.0 }
    )).id();
    
    // Run system directly using SystemState
    let mut state: SystemState<Query<&Transform>> = 
        SystemState::new(&mut world);
    let query = state.get(&world);
    
    // Check results
    assert!(check_collision(query));
}
```

## Test Categories

### 1. Feature Tests (Core Tests)
Test complete game features as player would experience them.

Location: `game/tests/features/`

Examples:
- `movement.rs` - Player movement in all directions
- `collision.rs` - Can't walk through walls
- `universe_transition.rs` - Travel between universes
- `items.rs` - Picking up and using items

### 2. Development Test Scenes
Test scenes that double as development environments. These are both automated tests AND playable scenes for iteration.

Location: `game/tests/scenes/`

Use when:
- Testing complex multi-system interactions
- Need visual debugging
- Iterating on game feel (movement speed, jump height)
- Testing procedural generation

Example:
```rust
#[test]
fn universe_transition_scene() {
    Test {
        setup: |app| {
            // Create two universes with portal between them
            let player = app.world.spawn((
                Player,
                Transform::from_xyz(0.0, 0.0, 0.0),
            )).id();
            
            setup_test_universes(app);
            player
        },
        setup_graphics: |app, _| {
            app.world.spawn(Camera2d);
            // Add lights, debug UI, etc.
        },
        frames: 300,  // 5 seconds at 60fps
        check: |app, player_id| {
            // Player should have transitioned
            let universe = app.world.get::<CurrentUniverse>(player_id);
            assert_eq!(universe.unwrap().0, Universe::Dystopia);
        }
    }.run();
}
```

### 3. Visual Regression Tests
Ensure game looks correct (when we have sprites).

Location: `game/tests/visual/`

Approach: Render to image buffer, compare with golden images.

### 4. Performance Tests
Ensure features stay fast.

```rust
#[test]
fn world_generation_is_linear() {
    let times = vec![
        measure_generation(100),   // 100 chunks
        measure_generation(200),   // 200 chunks
        measure_generation(400),   // 400 chunks
    ];
    assert_is_linear(times);
}
```

### 5. Property Tests
For procedural generation and physics.

```rust
#[test]
fn all_generated_worlds_are_playable() {
    for seed in 0..100 {
        let world = generate_world(seed);
        assert!(has_path_to_exit(world));
        assert!(has_required_items(world));
    }
}
```

## Test Utilities

Common patterns for Bevy testing:

### Fake Input
```rust
// Keyboard
app.world.resource_mut::<ButtonInput<KeyCode>>().press(KeyCode::Up);

// Mouse
app.world.resource_mut::<ButtonInput<MouseButton>>().press(MouseButton::Left);
```

### Send Events
```rust
app.world.resource_mut::<Events<Direction>>().send(Direction::Down);
```

### Query Without System
```rust
let player = app.world
    .query_filtered::<&Transform, With<Player>>()
    .single(&app.world);
```

### Access Commands
```rust
use bevy::ecs::system::SystemState;

let mut state: SystemState<Commands> = SystemState::new(&mut app.world);
let mut commands = state.get_mut(&mut app.world);
commands.spawn((/* components */));
state.apply(&mut app.world);
```

### Control Time (Bevy 0.16+)
```rust
// Advance time by specific amount
let mut time = app.world.resource_mut::<Time>();
time.advance_by(Duration::from_secs(2));
```

## What We DON'T Do (Usually)

### Avoid Mocks When Possible
Prefer minimal real implementations. But if Bevy's Time is hard to control, using `thread::sleep` in one test is acceptable.

### Test Systems Directly When It Makes Sense
While we prefer feature tests, testing a pure calculation system directly is fine if it's cleaner.

### Accept Practical Trade-offs
A slow test that catches bugs is better than no test. Mark slow tests:

```rust
#[test]
#[ignore]  // Run with: cargo test -- --ignored
fn slow_integration_test() {
    // Test that takes 10+ seconds
}
```

### No Flaky Tests
But if timing is unavoidable, use generous timeouts and mark as potentially flaky.

## Known Bevy Testing Limitations

Be aware of these current limitations:

- **Time mocking**: Limited in older Bevy versions, use `Time::advance_by` in 0.16+
- **Rendering tests**: Need headless rendering or Mesa's Lavapipe for CI
- **Commands access**: Must use `SystemState` pattern (shown above)
- **Query syntax**: Test queries use single tuple: `Query<(&A, &B, With<C>)>` not `Query<(&A, &B), With<C>>`
- **Main thread**: Some plugins require main thread, won't work in tests

## Practical Workflow

### Adding a New Feature
1. Decide on test pattern (check function, Test struct, or direct)
2. Write the simplest test that could fail
3. Implement until test passes
4. Add edge cases as new tests

### When to Write Tests
- **Immediately**: Core mechanics (movement, collision)
- **Soon**: Game rules (universe transitions, item effects)
- **As needed**: Complex interactions (use Test struct pattern)
- **Eventually**: Polish features (particle effects, animations)
- **Never**: Prototypes we're exploring

### Making Tests Trivial to Add
The check function pattern means adding a test is one line:

```rust
#[test]
fn player_moves_right() {
    check_movement(Vec2::ZERO, KeyCode::ArrowRight, Vec2::new(5.0, 0.0));
}

#[test]
fn player_moves_diagonal() {
    check_movement_multi(
        Vec2::ZERO, 
        vec![KeyCode::ArrowRight, KeyCode::ArrowUp],
        Vec2::new(3.5, 3.5)  // Normalized diagonal
    );
}
```

## Running Tests

```bash
# Fast tests only (default)
cargo test

# Include slow tests
cargo test -- --ignored

# Run with visual debugging
VISUAL_TEST=1 cargo test movement

# Specific feature
cargo test movement

# With timing info
cargo test -- --nocapture --test-threads=1

# Watch mode (requires cargo-watch)
cargo watch -x test
```

## Test Infrastructure Investment

Priority order for test infrastructure:

1. **Now**: Basic check functions for movement/collision
2. **Soon**: Test struct pattern for complex scenes
3. **Later**: Visual regression testing
4. **Eventually**: Fuzzing for procedural generation
5. **Maybe**: Snapshot testing for game state

## Example: Complete Movement Test

```rust
// game/tests/features/movement.rs

use bevy::prelude::*;
use coherence::*;

// Simple check function for basic movement
#[track_caller]
fn check_movement(start: Vec2, input: KeyCode, expected: Vec2) {
    let mut app = App::new();
    app.add_plugins(MinimalPlugins)
       .add_systems(Update, player_movement_system);
    
    app.world.spawn((
        Player,
        Transform::from_translation(start.extend(0.0)),
        Velocity::default(),
    ));
    
    app.world.resource_mut::<ButtonInput<KeyCode>>().press(input);
    app.update();
    
    let player_transform = app.world
        .query_filtered::<&Transform, With<Player>>()
        .single(&app.world);
        
    assert_eq!(
        player_transform.translation.truncate(), 
        expected,
        "Player should move from {:?} to {:?} when {:?} is pressed",
        start, expected, input
    );
}

// Test struct for complex movement scenario
#[test]
fn movement_with_collision_scene() {
    Test {
        setup: |app| {
            app.add_systems(Update, (movement_system, collision_system));
            
            // Spawn player
            let player = app.world.spawn((
                Player,
                Transform::from_xyz(0.0, 0.0, 0.0),
                Collider { radius: 0.5 },
            )).id();
            
            // Spawn wall
            app.world.spawn((
                Wall,
                Transform::from_xyz(5.0, 0.0, 0.0),
                Collider { radius: 1.0 },
            ));
            
            player
        },
        setup_graphics: |app, _| {
            app.world.spawn(Camera2d);
        },
        frames: 60,
        check: |app, player_id| {
            let pos = app.world.get::<Transform>(player_id)
                .unwrap()
                .translation;
            
            // Should stop before wall
            assert!(pos.x < 3.5, "Player should stop before wall");
        }
    }.run();
}

// Basic movement tests
#[test]
fn moves_right() {
    check_movement(Vec2::ZERO, KeyCode::ArrowRight, Vec2::new(5.0, 0.0));
}

#[test]
fn moves_left() {
    check_movement(Vec2::ZERO, KeyCode::ArrowLeft, Vec2::new(-5.0, 0.0));
}
```

## Teaching Notes

When implementing these patterns, we'll:

1. **Start simple**: Basic check functions you can understand
2. **Explain every line**: What each Bevy API does and why
3. **Build up complexity**: Add Test struct only when needed
4. **Learn by debugging**: Use VISUAL_TEST to see what's happening
5. **Iterate quickly**: Tests as development tools, not just validation

## Key Takeaway

**Test what the player sees and does, not how the code does it.**

But be pragmatic - a working test that's slightly impure beats a perfect test that never gets written.