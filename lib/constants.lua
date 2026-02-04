-- Game Constants
-- Ported from Playdate version

Constants = {
    -- Version info
    VERSION = "0.1.0-love2d",

    -- Screen dimensions (native resolution)
    SCREEN_WIDTH = 400,
    SCREEN_HEIGHT = 240,

    -- Station
    STATION_CENTER_X = 200,
    STATION_CENTER_Y = 120,
    STATION_BASE_HEALTH = 500,
    STATION_RADIUS = 32,
    STATION_SLOTS = 8,

    -- Rotation (keyboard-based)
    ROTATION_SPEED = 180,           -- Degrees per second when key held
    ROTATION_SMOOTHING = 0.3,       -- Lerp factor for smooth rotation

    -- Gameplay
    MAX_EQUIPMENT = 8,

    -- XP/Leveling
    BASE_XP = 50,
    BASE_LEVEL_EXPONENT = 1.15,

    -- Collectibles
    COLLECTIBLE_DRIFT_SPEED = 15,   -- px/sec (was 0.5 px/frame at 30fps)
    TRACTOR_PULL_SPEED = 90,        -- px/sec
    TRACTOR_UPGRADED_SPEED = 150,   -- px/sec
    STANDARD_COLLECTIBLE_RP = 10,
    RARE_COLLECTIBLE_RP = 25,
    RARE_COLLECTIBLE_CHANCE = 20,   -- percent

    -- MOB damage multiplier (global)
    MOB_DAMAGE_MULTIPLIER = 1,

    -- Wave spawn limits (for performance)
    MAX_ACTIVE_PROJECTILES = 50,
    MAX_ACTIVE_MOBS = 30,

    -- UI positions
    RP_BAR_Y = 0,
    RP_BAR_HEIGHT = 2,
    BOSS_HEALTH_BAR_Y = 0,
    BOSS_HEALTH_BAR_WIDTH = 200,
    BOSS_HEALTH_BAR_HEIGHT = 6,

    -- Timing
    HEALTH_BAR_SHOW_DURATION = 1.0,
    WAVE_INDICATOR_DURATION = 0.5,
    STARTING_MESSAGE_DURATION = 1.5,
    BOSS_WARNING_TIME = 405,

    -- Tool slot positions (angle in degrees, offset from center)
    TOOL_SLOTS = {
        [0] = { angle = 0,   x = 0,   y = -32 },  -- Top
        [1] = { angle = 45,  x = 23,  y = -23 },  -- Top-right
        [2] = { angle = 90,  x = 32,  y = 0 },    -- Right
        [3] = { angle = 135, x = 23,  y = 23 },   -- Bottom-right
        [4] = { angle = 180, x = 0,   y = 32 },   -- Bottom
        [5] = { angle = 225, x = -23, y = 23 },   -- Bottom-left
        [6] = { angle = 270, x = -32, y = 0 },    -- Left
        [7] = { angle = 315, x = -23, y = -23 },  -- Top-left
    },

    -- Episode count
    TOTAL_EPISODES = 5,
    TOTAL_RESEARCH_SPECS = 8,

    -- VFX Constants
    VFX = {
        HIT_FLASH_DURATION = 0.08,
        DEATH_EFFECT_DURATION = 0.3,
        DEATH_EFFECT_MAX_RADIUS = 20,
        FLOATING_TEXT_DURATION = 1.0,
        FLOATING_TEXT_RISE = 20,
        TRANSITION_FADE_SPEED = 0.3,
        WAVE_ANNOUNCEMENT_DURATION = 2.0,
        BOSS_WARNING_DURATION = 2.0,
        DESTRUCTION_DURATION = 1.5,
        CELEBRATION_DURATION = 0.8,
    },

    -- Colors (for tinting)
    COLORS = {
        STATION = {0, 1, 1},           -- Cyan
        PLAYER_PROJECTILE = {0.3, 0.53, 1},  -- Blue-cyan
        ENEMY_PROJECTILE = {1, 0.53, 0},     -- Orange
        MELEE_MOB = {1, 0.27, 0.27},    -- Red
        SHOOTER_MOB = {0.8, 0.27, 1},   -- Purple
        BOSS = {1, 0, 1},              -- Magenta
        COLLECTIBLE = {1, 0.9, 0.2},   -- Yellow/Gold
        SHIELD = {0, 1, 0.53},         -- Green
        UI_TEXT = {1, 1, 1},           -- White
    },
}

return Constants
