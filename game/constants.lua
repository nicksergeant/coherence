local constants = {}

-- Portal positioning
constants.PORTAL_INITIAL_X = 1500
constants.PORTAL_INITIAL_Y = 800

-- Arrow visibility
constants.ARROW_HIDE_DISTANCE = 300
constants.ARROW_MIN_DIRECTION_THRESHOLD = 50
constants.ARROW_SIZE = 30
constants.ARROW_MARGIN = 50

-- Universe jumping positioning
constants.UNIVERSE_JUMP_MIN_DISTANCE = 1500
constants.UNIVERSE_JUMP_MAX_ATTEMPTS = 50
constants.UNIVERSE_JUMP_BORDER_MARGIN = 200
constants.UNIVERSE_JUMP_PORTAL_MARGIN = 600
constants.UNIVERSE_JUMP_PLAYER_MARGIN = 400

-- Shake effects
constants.UNIVERSE_SHAKE_DURATION = 0.5
constants.UNIVERSE_SHAKE_AMOUNT = 30
constants.DYSTOPIAN_FIERCE_SHAKE = 15

-- Map dimensions
constants.MAP_WIDTH = 40
constants.MAP_HEIGHT = 30
constants.TILE_SIZE = 128

-- Bump collision
constants.BUMP_CELL_SIZE = 64

-- Timers
constants.THOUGHT_DURATION = 3
constants.UTOPIAN_RETURN_TIMER = 60
constants.NEUTRAL_TIMER = 30
constants.DYSTOPIAN_TIMER = 10

-- Dystopian shake timing
constants.DYSTOPIAN_FIERCE_MIN_TIME = 0.5
constants.DYSTOPIAN_FIERCE_MAX_TIME = 2.0
constants.DYSTOPIAN_CALM_MIN_TIME = 1.0
constants.DYSTOPIAN_CALM_MAX_TIME = 4.0

return constants