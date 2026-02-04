-- Interstellar Survivors
-- Love2D port of the Playdate auto-shooter roguelike

-- Load libraries
class = require("lib.class")
require("lib.constants")
require("lib.utils")

-- Load managers
require("managers.input_manager")
require("managers.game_manager")
require("managers.audio_manager")
require("managers.save_manager")
require("managers.vfx_manager")

-- Load data
require("data.tools_data")
require("data.episodes_data")
require("data.grants_data")
require("data.specs_data")
require("data.codex_data")
require("data.bonus_items_data")

-- Load systems
require("systems.upgrade_system")
require("systems.grants_system")
require("systems.specs_system")
require("systems.bonus_items_system")

-- Load UI
require("ui.upgrade_selection")
require("ui.pause_menu")
require("ui.slot_picker")

-- Load entities
require("entities.entity")
require("entities.station")
require("entities.tool")
require("entities.projectile")
require("entities.mob")
require("entities.collectible")

-- Load specific tools
require("entities.tools.rail_driver")
require("entities.tools.frequency_scanner")
require("entities.tools.tractor_pulse")
require("entities.tools.plasma_sprayer")
require("entities.tools.thermal_lance")
require("entities.tools.micro_missile_pod")
require("entities.tools.mapping_drone")
require("entities.tools.cryo_projector")
require("entities.tools.modified_mapping_drone")
require("entities.tools.emp_burst")
require("entities.tools.singularity_core")
require("entities.tools.tesla_coil")
require("entities.tools.phase_disruptor")
require("entities.tools.probe_launcher")
require("entities.tools.repulsor_field")

-- Load specific mobs
require("entities.mobs.asteroid")
require("entities.mobs.greeting_drone")
require("entities.mobs.silk_weaver")
require("entities.mobs.survey_drone")
require("entities.mobs.efficiency_monitor")
require("entities.mobs.probability_fluctuation")
require("entities.mobs.paradox_node")
require("entities.mobs.debris_chunk")
require("entities.mobs.defense_turret")
require("entities.mobs.debate_drone")
require("entities.mobs.citation_platform")

-- Load bosses
require("entities.bosses.cultural_attache")
require("entities.bosses.productivity_liaison")
require("entities.bosses.improbability_engine")
require("entities.bosses.chomper")
require("entities.bosses.distinguished_professor")

-- Load scenes
require("scenes.title_scene")
require("scenes.story_scene")
require("scenes.gameplay_scene")
require("scenes.results_scene")
require("scenes.grants_scene")
require("scenes.specs_scene")
require("scenes.codex_scene")
require("scenes.settings_scene")

-- Scaling
local scale = 2
local gameCanvas = nil

function love.load()
    -- Set up pixel-perfect scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Create game canvas at native resolution
    gameCanvas = love.graphics.newCanvas(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- Initialize managers
    InputManager:init()
    GameManager:init()
    AudioManager:init()
    SaveManager:init()

    -- Initialize systems
    UpgradeSystem:init()
    UpgradeSelection:init()
    VFXManager:init()
    PauseMenu:init()
    SlotPicker:init()

    -- Initialize scenes
    TitleScene:init()
    StoryScene:init()
    GameplayScene:init()
    ResultsScene:init()
    GrantsScene:init()
    SpecsScene:init()
    CodexScene:init()
    SettingsScene:init()

    -- Load saved volume settings
    local savedMusicVol = SaveManager:getSetting("musicVolume")
    local savedSfxVol = SaveManager:getSetting("sfxVolume")
    if savedMusicVol then AudioManager:setMusicVolume(savedMusicVol) end
    if savedSfxVol then AudioManager:setSFXVolume(savedSfxVol) end

    -- Start at title screen
    GameManager:goToTitle()

    print("Interstellar Survivors - Love2D version loaded!")
    print("Controls: A/D or Left/Right arrows to rotate station")
    print("W/S to navigate menus, Enter to select")
end

function love.update(dt)
    -- Cap delta time to prevent physics issues
    dt = math.min(dt, 1/30)

    -- Update input
    InputManager:update(dt)

    -- Update VFX (always runs, even during transitions)
    VFXManager:update(dt)

    -- Update current scene
    local state = GameManager.currentState
    if state == GameManager.states.TITLE then
        TitleScene:update(dt)
    elseif state == GameManager.states.EPISODE_INTRO or state == GameManager.states.EPISODE_ENDING then
        StoryScene:update(dt)
    elseif state == GameManager.states.GAMEPLAY then
        GameplayScene:update(dt)
    elseif state == GameManager.states.RESULTS then
        ResultsScene:update(dt)
    elseif state == GameManager.states.GRANTS then
        GrantsScene:update(dt)
    elseif state == GameManager.states.SPECS then
        SpecsScene:update(dt)
    elseif state == GameManager.states.CODEX then
        CodexScene:update(dt)
    elseif state == GameManager.states.SETTINGS then
        SettingsScene:update(dt)
    end

    -- Clear per-frame input state (must be last)
    InputManager:endFrame()
end

function love.draw()
    -- Draw to game canvas at native resolution
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0)

    -- Apply screen shake offset
    local shakeX, shakeY = VFXManager:getShakeOffset()
    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)

    -- Draw current scene
    local state = GameManager.currentState
    if state == GameManager.states.TITLE then
        TitleScene:draw()
    elseif state == GameManager.states.EPISODE_INTRO or state == GameManager.states.EPISODE_ENDING then
        StoryScene:draw()
    elseif state == GameManager.states.GAMEPLAY then
        GameplayScene:draw()
    elseif state == GameManager.states.RESULTS then
        ResultsScene:draw()
    elseif state == GameManager.states.GRANTS then
        GrantsScene:draw()
    elseif state == GameManager.states.SPECS then
        SpecsScene:draw()
    elseif state == GameManager.states.CODEX then
        CodexScene:draw()
    elseif state == GameManager.states.SETTINGS then
        SettingsScene:draw()
    end

    love.graphics.pop()

    -- Draw screen-space overlays (transitions, announcements - not affected by shake)
    VFXManager:drawOverlay()

    love.graphics.setCanvas()

    -- Calculate scale to fit window while maintaining aspect ratio
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scaleX = windowWidth / Constants.SCREEN_WIDTH
    local scaleY = windowHeight / Constants.SCREEN_HEIGHT
    scale = math.min(scaleX, scaleY)

    -- Center the scaled canvas
    local offsetX = (windowWidth - Constants.SCREEN_WIDTH * scale) / 2
    local offsetY = (windowHeight - Constants.SCREEN_HEIGHT * scale) / 2

    -- Draw scaled canvas
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, offsetX, offsetY, 0, scale, scale)

    -- Draw FPS in corner (outside game canvas)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)
end

function love.keypressed(key)
    InputManager:onKeyPressed(key)
end

function love.keyreleased(key)
    InputManager:onKeyReleased(key)
end

function love.resize(w, h)
    -- Recalculate scale on window resize
    local scaleX = w / Constants.SCREEN_WIDTH
    local scaleY = h / Constants.SCREEN_HEIGHT
    scale = math.min(scaleX, scaleY)
end
