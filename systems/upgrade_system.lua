-- Upgrade System
-- Manages tool selection and upgrades on level up
-- Simplified for Love2D port

local MAX_LEVEL = 4  -- Maximum upgrade level for tools
local MAX_TOOLS = 8  -- Maximum tools on station

UpgradeSystem = {
    -- Tool levels (by id)
    toolLevels = {},

    -- Available tools pool
    availableTools = {},

    -- Episode context
    currentEpisode = 1,
}

function UpgradeSystem:init()
    self:reset()
end

function UpgradeSystem:reset()
    self.toolLevels = {}
    self:refreshAvailablePools()
end

-- Set current episode (affects unlock conditions)
function UpgradeSystem:setEpisode(episodeNum)
    self.currentEpisode = episodeNum
    self:refreshAvailablePools()
end

-- Get current level of a tool (0 if not owned)
function UpgradeSystem:getToolLevel(toolId)
    return self.toolLevels[toolId] or 0
end

-- Refresh available tool pool based on current episode
function UpgradeSystem:refreshAvailablePools()
    self.availableTools = {}

    for id, data in pairs(ToolsData) do
        if type(data) == "table" and data.id then
            if self:isUnlocked(data.unlockCondition) then
                table.insert(self.availableTools, data)
            end
        end
    end

    print("UpgradeSystem: " .. #self.availableTools .. " tools available")
end

-- Check if an unlock condition is met
function UpgradeSystem:isUnlocked(condition)
    if condition == "start" then
        return true
    end
    -- Parse "episode_N" pattern
    local reqEp = condition and condition:match("episode_(%d+)")
    if reqEp then
        return self.currentEpisode >= tonumber(reqEp)
    end
    return false
end

-- Get random selection of upgrade options for level up
-- Returns array of options (tools - either new or upgrades)
function UpgradeSystem:getUpgradeOptions(station)
    local options = {}

    -- Count current tools
    local currentToolCount = #station.tools

    -- Build list of eligible options
    local eligible = {}

    for _, toolData in ipairs(self.availableTools) do
        -- Check if station already has this tool
        local hasTool = false
        local currentLevel = 0
        local toolRef = nil

        for _, equippedTool in ipairs(station.tools) do
            if equippedTool.data and equippedTool.data.id == toolData.id then
                hasTool = true
                currentLevel = equippedTool.level or 1
                toolRef = equippedTool
                break
            end
        end

        if not hasTool then
            -- Can add new tool if under limit
            if currentToolCount < MAX_TOOLS then
                table.insert(eligible, {
                    data = toolData,
                    isNew = true,
                    currentLevel = 0,
                    nextLevel = 1
                })
            end
        elseif currentLevel < MAX_LEVEL then
            -- Can upgrade existing tool
            table.insert(eligible, {
                data = toolData,
                isNew = false,
                currentLevel = currentLevel,
                nextLevel = currentLevel + 1,
                toolRef = toolRef
            })
        end
    end

    -- Shuffle and select up to 2 tool options (reserve 2 slots for bonus items)
    self:shuffleArray(eligible)
    local toolSlots = math.min(2, #eligible)
    for i = 1, toolSlots do
        local option = eligible[i]
        local displayData = {
            id = option.data.id,
            type = "tool",
            name = option.data.name,
            description = option.isNew and option.data.description or ("Upgrade to Level " .. option.nextLevel),
            isNew = option.isNew,
            currentLevel = option.currentLevel,
            nextLevel = option.nextLevel,
            originalData = option.data,
            toolRef = option.toolRef
        }

        -- Add level indicator to name if upgrading
        if not option.isNew then
            displayData.name = displayData.name .. " Lv" .. option.nextLevel
        end

        -- Show upgraded stats in description
        if not option.isNew then
            local stats = ToolsData.getStatsAtLevel(option.data.id, option.nextLevel)
            if stats then
                displayData.description = "Dmg: " .. stats.damage .. " | Rate: " .. string.format("%.1f", stats.fireRate)
            end
        end

        table.insert(options, displayData)
    end

    -- Add 2 random bonus item options (no duplicates)
    if BonusItemsData then
        local usedIds = {}
        for attempt = 1, 2 do
            -- Try a few times to avoid duplicates
            for try = 1, 10 do
                local bonusItem = BonusItemsData.getRandom()
                if bonusItem and not usedIds[bonusItem.id] then
                    usedIds[bonusItem.id] = true
                    table.insert(options, {
                        id = bonusItem.id,
                        type = "bonus_item",
                        name = bonusItem.name,
                        description = bonusItem.description,
                        isNew = false,
                        bonusItemData = bonusItem,
                    })
                    break
                end
            end
        end
    end

    return options
end

-- Apply a tool selection
function UpgradeSystem:applyToolSelection(option, station, slotIndex)
    if option.isNew then
        -- Attach new tool
        local toolClass = self:getToolClass(option.originalData.id)
        if toolClass then
            local newTool = toolClass()
            newTool.level = 1
            self.toolLevels[option.id] = 1
            station:attachTool(newTool, slotIndex)

            print("Attached new tool: " .. option.name .. " (Lv1)")

            -- Play upgrade sound
            if AudioManager then
                AudioManager:playSFX("tool_upgrade", 0.6)
            end

            return true
        end
    else
        -- Upgrade existing tool
        if option.toolRef then
            option.toolRef.level = option.nextLevel
            self.toolLevels[option.id] = option.nextLevel

            -- Recalculate tool stats
            if option.toolRef.recalculateStats then
                option.toolRef:recalculateStats()
            end

            print("Upgraded tool: " .. option.originalData.id .. " to Lv" .. option.nextLevel)

            -- Play upgrade sound
            if AudioManager then
                AudioManager:playSFX("tool_upgrade", 0.6)
            end

            return true
        end
    end

    return false
end

-- Get tool class by ID
function UpgradeSystem:getToolClass(toolId)
    local toolClasses = {
        rail_driver = RailDriver,
        frequency_scanner = FrequencyScanner,
        tractor_pulse = TractorPulse,
        plasma_sprayer = PlasmaSprayer,
        thermal_lance = ThermalLance,
        micro_missile_pod = MicroMissilePod,
        mapping_drone = MappingDrone,
        cryo_projector = CryoProjector,
        modified_mapping_drone = ModifiedMappingDrone,
        emp_burst = EMPBurst,
        singularity_core = SingularityCore,
        tesla_coil = TeslaCoil,
        phase_disruptor = PhaseDisruptor,
        probe_launcher = ProbeLauncher,
        repulsor_field = RepulsorField,
    }
    return toolClasses[toolId]
end

-- Fisher-Yates shuffle
function UpgradeSystem:shuffleArray(arr)
    for i = #arr, 2, -1 do
        local j = math.random(i)
        arr[i], arr[j] = arr[j], arr[i]
    end
end

return UpgradeSystem
