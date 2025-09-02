-- Constants for Coherence game
-- All magic numbers should be defined here

return {
    -- Window Configuration
    WINDOW_WIDTH = 1024,
    WINDOW_HEIGHT = 768,
    WINDOW_TITLE = "Coherence",
    
    -- Player Settings
    PLAYER_SPEED = 200,        -- Pixels per second
    PLAYER_SIZE = 32,          -- Width and height in pixels
    PLAYER_START_X = 512,      -- Starting position
    PLAYER_START_Y = 384,
    
    -- World Generation
    CHUNK_SIZE = 10,           -- Tiles per chunk (10x10)
    TILE_SIZE = 32,            -- Pixels per tile
    WORLD_SIZE = 5,            -- Chunks per world (5x5)
    CHUNKS_VISIBLE = 3,        -- Visible chunks around player (3x3)
    
    -- Universe Parameters
    UTOPIA_THRESHOLD = 0.7,    -- Stability > 0.7 = Utopia
    DYSTOPIA_THRESHOLD = 0.3,  -- Stability < 0.3 = Dystopia
    MAX_BOX_DISTANCE = 5,      -- Maximum chunks from spawn to box
    
    -- Chunk Types and Weights
    UTOPIA_WEIGHTS = {
        nature = 0.6,
        town = 0.3,
        water = 0.1
    },
    NEUTRAL_WEIGHTS = {
        nature = 0.33,
        town = 0.33,
        water = 0.34
    },
    DYSTOPIA_WEIGHTS = {
        ruins = 0.7,
        toxic = 0.2,
        other = 0.1
    },
    
    -- Colors (RGBA, 0-1 range)
    COLORS = {
        -- UI Colors
        WHITE = {1, 1, 1, 1},
        BLACK = {0, 0, 0, 1},
        DEBUG_RED = {1, 0, 0, 0.5},
        DEBUG_GREEN = {0, 1, 0, 0.5},
        
        -- Tile Colors (for procedural graphics)
        GRASS = {0.2, 0.8, 0.2, 1},
        WATER = {0.2, 0.4, 0.8, 1},
        STONE = {0.5, 0.5, 0.5, 1},
        TOXIC = {0.5, 0, 0.5, 1},
        FLOWERS = {1, 0.8, 0.2, 1},
        
        -- Player
        PLAYER = {0, 1, 0, 1},
        
        -- Universe-specific
        UTOPIA_TINT = {1, 1, 0.9, 1},
        DYSTOPIA_TINT = {0.8, 0.7, 0.7, 1},
        NEUTRAL_TINT = {1, 1, 1, 1}
    },
    
    -- Debug Settings
    DEBUG_KEY = "f1",
    SHOW_FPS = true,
    SHOW_CHUNKS = true,
    SHOW_COLLISION = false,
    LOG_MOVEMENT = false,
    LOG_CHUNKS = true,
    LOG_STATE_CHANGES = true,
    
    -- Logging Categories
    LOG = {
        INIT = "INIT",
        PLAYER = "PLAYER",
        CHUNK = "CHUNK",
        UNIVERSE = "UNIVERSE",
        STATE = "STATE",
        COLLISION = "COLLISION",
        ERROR = "ERROR",
        DEBUG = "DEBUG",
        MAP = "MAP",
        LAB = "LAB"
    },
    
    -- Lab Settings
    LAB = {
        SLIDER_MIN = 0.0,
        SLIDER_MAX = 1.0,
        SLIDER_DEFAULT = 0.5,
        SLIDER_WIDTH = 200,
        SLIDER_HEIGHT = 20
    },
    
    -- Performance
    TARGET_FPS = 60,
    MAX_CHUNKS_LOADED = 9,     -- 3x3 grid
    CHUNK_UNLOAD_DISTANCE = 2,  -- Chunks away before unloading
    
    -- Collision Types (for Bump)
    COLLISION_TYPES = {
        PLAYER = "player",
        WALL = "wall",
        HAZARD = "hazard",
        BOX = "box",
        DOOR = "door"
    },
    
    -- Tile IDs (matching Tiled)
    TILES = {
        EMPTY = 0,
        GRASS = 1,
        STONE = 2,
        WATER = 3,
        TOXIC = 4,
        WALL = 5,
        DOOR = 6,
        BOX = 7,
        HAZARD = 8
    }
}