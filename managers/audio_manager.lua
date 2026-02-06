-- Audio Manager
-- Handles music and sound effect playback

AudioManager = {
    -- Sound cache
    sounds = {},

    -- Volume settings
    musicVolume = 0.7,
    sfxVolume = 0.7,

    -- Currently playing music
    currentMusic = nil,
}

-- Sound file mappings
local SOUND_FILES = {
    -- Tool sounds
    tool_rail_driver = "assets/sounds/sfx_tool_rail_driver.wav",
    tool_frequency_scanner = "assets/sounds/sfx_tool_frequency_scanner.wav",
    tool_tractor_pulse = "assets/sounds/sfx_tool_tractor_pulse.wav",
    tool_thermal_lance = "assets/sounds/sfx_tool_thermal_lance.wav",
    tool_cryo_projector = "assets/sounds/sfx_tool_cryo_projector.wav",
    tool_emp_burst = "assets/sounds/sfx_tool_emp_burst.wav",
    tool_probe_launcher = "assets/sounds/sfx_tool_probe_launcher.wav",
    tool_repulsor_field = "assets/sounds/sfx_tool_repulsor_field.wav",

    -- Placeholder mappings (reuse similar sounds until unique wavs are created)
    tool_plasma_sprayer = "assets/sounds/sfx_tool_rail_driver.wav",
    tool_micro_missile_pod = "assets/sounds/sfx_tool_emp_burst.wav",
    tool_singularity_core = "assets/sounds/sfx_tool_tractor_pulse.wav",
    tool_tesla_coil = "assets/sounds/sfx_tool_frequency_scanner.wav",

    -- Combat sounds
    mob_hit = "assets/sounds/sfx_mob_hit.wav",
    mob_destroyed = "assets/sounds/sfx_mob_destroyed.wav",
    mob_spawn = "assets/sounds/sfx_boss_warning.wav",
    mob_death_large = "assets/sounds/sfx_boss_defeated.wav",
    station_hit = "assets/sounds/sfx_station_hit.wav",
    station_destroyed = "assets/sounds/sfx_station_destroyed.wav",
    shield_hit = "assets/sounds/sfx_shield_hit.wav",
    boss_hit = "assets/sounds/sfx_boss_hit.wav",
    boss_defeated = "assets/sounds/sfx_boss_defeated.wav",
    boss_warning = "assets/sounds/sfx_boss_warning.wav",

    -- Collectible sounds
    collectible_get = "assets/sounds/sfx_collectible_get.wav",
    collectible_rare = "assets/sounds/sfx_collectible_rare.wav",

    -- UI sounds
    menu_select = "assets/sounds/sfx_menu_select.wav",
    menu_confirm = "assets/sounds/sfx_menu_confirm.wav",
    menu_move = "assets/sounds/sfx_menu_select.wav",
    menu_back = "assets/sounds/sfx_menu_back.wav",
    card_select = "assets/sounds/sfx_card_select.wav",
    card_confirm = "assets/sounds/sfx_card_confirm.wav",
    panel_advance = "assets/sounds/sfx_panel_advance.wav",

    -- Gameplay feedback
    level_up = "assets/sounds/sfx_level_up.wav",
    wave_start = "assets/sounds/sfx_wave_start.wav",
    tool_upgrade = "assets/sounds/sfx_tool_upgrade.wav",

    -- Music
    music_title = "assets/sounds/music_title_theme.wav",
    music_gameplay = "assets/sounds/music_gameplay.wav",
    music_boss = "assets/sounds/music_boss.wav",
}

function AudioManager:init()
    self.sounds = {}
    self.musicVolume = 0.7
    self.sfxVolume = 0.7
    self.currentMusic = nil

    -- Pre-load common sounds
    self:preloadSound("tool_rail_driver")
    self:preloadSound("mob_hit")
    self:preloadSound("mob_destroyed")
    self:preloadSound("station_hit")
    self:preloadSound("collectible_get")
    self:preloadSound("level_up")
    self:preloadSound("wave_start")
    self:preloadSound("menu_move")
    self:preloadSound("menu_back")

    print("AudioManager initialized")
end

-- Preload a sound into cache
function AudioManager:preloadSound(name)
    if self.sounds[name] then return end

    local path = SOUND_FILES[name]
    if not path then
        print("AudioManager: Unknown sound: " .. name)
        return
    end

    local success, source = pcall(love.audio.newSource, path, "static")
    if success and source then
        self.sounds[name] = source
    else
        print("AudioManager: Could not load sound: " .. path)
    end
end

-- Play a sound effect
function AudioManager:playSFX(name, volume)
    volume = volume or 1.0

    -- Load if not cached
    if not self.sounds[name] then
        self:preloadSound(name)
    end

    local sound = self.sounds[name]
    if not sound then return end

    -- Clone for overlapping playback
    local source = sound:clone()
    source:setVolume(self.sfxVolume * volume)
    source:play()
end

-- Play music
function AudioManager:playMusic(name, loop)
    loop = loop ~= false  -- Default to true

    -- Stop current music
    self:stopMusic()

    local path = SOUND_FILES[name]
    if not path then
        print("AudioManager: Unknown music: " .. name)
        return
    end

    local success, source = pcall(love.audio.newSource, path, "stream")
    if success and source then
        source:setLooping(loop)
        source:setVolume(self.musicVolume)
        source:play()
        self.currentMusic = source
    else
        print("AudioManager: Could not load music: " .. path)
    end
end

-- Stop music
function AudioManager:stopMusic()
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
    end
end

-- Set music volume
function AudioManager:setMusicVolume(volume)
    self.musicVolume = Utils.clamp(volume, 0, 1)
    if self.currentMusic then
        self.currentMusic:setVolume(self.musicVolume)
    end
end

-- Set SFX volume
function AudioManager:setSFXVolume(volume)
    self.sfxVolume = Utils.clamp(volume, 0, 1)
end

return AudioManager
