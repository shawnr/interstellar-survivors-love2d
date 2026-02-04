-- Save Manager
-- Handles persistent game data using love.filesystem

local json = require("lib.json")

SaveManager = {
    data = nil,
    dirty = false,
    saveFile = "save_data.json",
}

-- Default save data structure
local DEFAULT_DATA = {
    completedEpisodes = {},
    settings = {
        musicVolume = 0.7,
        sfxVolume = 0.8,
    },
    -- Meta-progression
    spendableRP = 0,
    grantLevels = {},     -- { health = 0, damage = 0, shields = 0, research = 0 }
    equippedSpecs = {},   -- Array of spec IDs (max 3)
    unlockedSpecs = {},   -- Array of spec IDs
    totalVictories = 0,
    totalDeaths = 0,
    discoveredEntries = {},  -- Set of codex entry IDs
}

function SaveManager:init()
    self.dirty = false
    self:load()
    print("SaveManager initialized")
end

-- Load save data from disk
function SaveManager:load()
    if love.filesystem.getInfo(self.saveFile) then
        local contents = love.filesystem.read(self.saveFile)
        if contents then
            local success, decoded = pcall(json.decode, contents)
            if success and decoded then
                self.data = decoded
                -- Fill in any missing fields from defaults
                for key, value in pairs(DEFAULT_DATA) do
                    if self.data[key] == nil then
                        self.data[key] = value
                    end
                end
                print("SaveManager: Loaded save data")
                return
            end
        end
    end

    -- No save file or corrupted — use defaults
    self.data = {}
    for key, value in pairs(DEFAULT_DATA) do
        if type(value) == "table" then
            self.data[key] = {}
            for k, v in pairs(value) do
                self.data[key][k] = v
            end
        else
            self.data[key] = value
        end
    end
    print("SaveManager: Created new save data")
end

-- Save data to disk
function SaveManager:save()
    if not self.data then return end

    local success, encoded = pcall(json.encode, self.data)
    if success and encoded then
        love.filesystem.write(self.saveFile, encoded)
        self.dirty = false
        print("SaveManager: Data saved")
    else
        print("SaveManager: Failed to encode save data")
    end
end

-- Mark an episode as completed
function SaveManager:completeEpisode(episodeId)
    if not self.data.completedEpisodes then
        self.data.completedEpisodes = {}
    end

    -- Check if already completed
    for _, id in ipairs(self.data.completedEpisodes) do
        if id == episodeId then return end
    end

    table.insert(self.data.completedEpisodes, episodeId)
    self.dirty = true
    self:save()
    print("SaveManager: Episode " .. episodeId .. " completed")
end

-- Check if an episode is completed
function SaveManager:isEpisodeCompleted(episodeId)
    if not self.data.completedEpisodes then return false end
    for _, id in ipairs(self.data.completedEpisodes) do
        if id == episodeId then return true end
    end
    return false
end

-- Check if an episode is unlocked
function SaveManager:isEpisodeUnlocked(episodeId)
    if episodeId == 1 then return true end
    -- Episode N requires Episode N-1 completed
    return self:isEpisodeCompleted(episodeId - 1)
end

-- RP management
function SaveManager:getSpendableRP()
    return self.data.spendableRP or 0
end

function SaveManager:earnRP(amount)
    self.data.spendableRP = (self.data.spendableRP or 0) + amount
    self.dirty = true
    self:save()
end

function SaveManager:spendRP(amount)
    self.data.spendableRP = (self.data.spendableRP or 0) - amount
    if self.data.spendableRP < 0 then self.data.spendableRP = 0 end
    self.dirty = true
    self:save()
end

-- Grant levels
function SaveManager:getGrantLevel(grantId)
    if not self.data.grantLevels then return 0 end
    return self.data.grantLevels[grantId] or 0
end

function SaveManager:setGrantLevel(grantId, level)
    if not self.data.grantLevels then self.data.grantLevels = {} end
    self.data.grantLevels[grantId] = level
    self.dirty = true
    self:save()
end

-- Victory/death tracking
function SaveManager:incrementVictories()
    self.data.totalVictories = (self.data.totalVictories or 0) + 1
    self.dirty = true
    self:save()
end

function SaveManager:incrementDeaths()
    self.data.totalDeaths = (self.data.totalDeaths or 0) + 1
    self.dirty = true
    self:save()
end

function SaveManager:getTotalVictories()
    return self.data.totalVictories or 0
end

function SaveManager:getTotalDeaths()
    return self.data.totalDeaths or 0
end

-- Specs
function SaveManager:getUnlockedSpecs()
    return self.data.unlockedSpecs or {}
end

function SaveManager:unlockSpec(specId)
    if not self.data.unlockedSpecs then self.data.unlockedSpecs = {} end
    for _, id in ipairs(self.data.unlockedSpecs) do
        if id == specId then return end
    end
    table.insert(self.data.unlockedSpecs, specId)
    self.dirty = true
    self:save()
end

function SaveManager:isSpecUnlocked(specId)
    if not self.data.unlockedSpecs then return false end
    for _, id in ipairs(self.data.unlockedSpecs) do
        if id == specId then return true end
    end
    return false
end

function SaveManager:getEquippedSpecs()
    return self.data.equippedSpecs or {}
end

function SaveManager:setEquippedSpecs(specs)
    self.data.equippedSpecs = specs
    self.dirty = true
    self:save()
end

-- Codex entries
function SaveManager:discoverEntry(entryId)
    if not self.data.discoveredEntries then self.data.discoveredEntries = {} end
    self.data.discoveredEntries[entryId] = true
    self.dirty = true
end

function SaveManager:isDiscovered(entryId)
    if not self.data.discoveredEntries then return false end
    return self.data.discoveredEntries[entryId] == true
end

-- Get/set settings
function SaveManager:getSetting(key)
    if self.data.settings then
        return self.data.settings[key]
    end
    return nil
end

function SaveManager:setSetting(key, value)
    if not self.data.settings then
        self.data.settings = {}
    end
    self.data.settings[key] = value
    self.dirty = true
    self:save()
end

return SaveManager
