-- Upgrade System
-- Manages tool selection, bonus item upgrades, and tool evolution on level up
-- Matches original Playdate design: 2 tool options + 2 bonus item options per level up

local MAX_LEVEL = 4  -- Maximum upgrade level for tools and items
local MAX_EQUIPMENT = 8  -- Combined limit for tools + bonus items

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
    if condition == "all_episodes" then
        return self.currentEpisode >= 5
    end
    local reqEp = condition and condition:match("episode_(%d+)")
    if reqEp then
        return self.currentEpisode >= tonumber(reqEp)
    end
    return false
end

-- Get random selection of upgrade options for level up
-- Returns array of options: up to 2 tools + up to 2 bonus items (matching original design)
function UpgradeSystem:getUpgradeOptions(station)
    local options = {}
    local currentToolCount = #station.tools

    -- Combined equipment count (tools + bonus items share 8 slots)
    local bonusItemCount = BonusItemsSystem and BonusItemsSystem:getActiveItemCount() or 0
    local totalEquipment = currentToolCount + bonusItemCount

    -- =====================
    -- 1. Build tool options (new or upgrade, exclude evolved tools)
    -- =====================
    local toolEligible = {}
    for _, toolData in ipairs(self.availableTools) do
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
            -- Only offer new tools if under the combined equipment limit
            if totalEquipment < MAX_EQUIPMENT then
                table.insert(toolEligible, {
                    data = toolData,
                    isNew = true,
                    currentLevel = 0,
                    nextLevel = 1
                })
            end
        elseif currentLevel < MAX_LEVEL and not (toolRef and toolRef.evolved) then
            table.insert(toolEligible, {
                data = toolData,
                isNew = false,
                currentLevel = currentLevel,
                nextLevel = currentLevel + 1,
                toolRef = toolRef
            })
        end
    end

    -- Add up to 2 tool options
    self:shuffleArray(toolEligible)
    local toolSlots = math.min(2, #toolEligible)
    for i = 1, toolSlots do
        local option = toolEligible[i]
        local displayData = {
            id = option.data.id,
            type = "tool",
            name = option.data.name,
            description = option.isNew and option.data.description or ("Level " .. option.nextLevel),
            isNew = option.isNew,
            currentLevel = option.currentLevel,
            nextLevel = option.nextLevel,
            originalData = option.data,
            toolRef = option.toolRef
        }

        if not option.isNew then
            displayData.name = displayData.name .. " Lv" .. option.nextLevel
            local stats = ToolsData.getStatsAtLevel(option.data.id, option.nextLevel)
            if stats then
                displayData.description = "Dmg: " .. stats.damage .. " | Rate: " .. string.format("%.1f", stats.fireRate)
            end
        end

        table.insert(options, displayData)
    end

    -- =====================
    -- 2. Build bonus item options (new or upgrade)
    -- =====================
    local bonusEligible = {}
    local preferredItems = {}

    if BonusItemsData then
        -- Collect equipped tool IDs for preferential pairing
        local equippedToolIds = {}
        for _, equippedTool in ipairs(station.tools) do
            if equippedTool.data then
                equippedToolIds[equippedTool.data.id] = true
            end
        end

        for _, itemId in ipairs(BonusItemsData.allIds) do
            local itemData = BonusItemsData.get(itemId)
            if itemData and BonusItemsData.isUnlocked(itemData.unlockCondition, self.currentEpisode) then
                local currentLevel = BonusItemsSystem and BonusItemsSystem:getItemLevel(itemId) or 0
                if currentLevel < MAX_LEVEL then
                    -- Only offer new items if under the combined equipment limit
                    if currentLevel == 0 and totalEquipment >= MAX_EQUIPMENT then
                        -- Skip: can't add new equipment
                    else
                        local entry = {
                            data = itemData,
                            currentLevel = currentLevel,
                            isUpgrade = currentLevel > 0,
                        }

                        -- Preferentially include items that pair with equipped tools
                        if itemData.pairsWithTool and equippedToolIds[itemData.pairsWithTool] then
                            table.insert(preferredItems, entry)
                        else
                            table.insert(bonusEligible, entry)
                        end
                    end
                end
            end
        end
    end

    -- Shuffle both pools
    self:shuffleArray(preferredItems)
    self:shuffleArray(bonusEligible)

    -- Fill up to 2 bonus item slots (preferred first)
    local bonusAdded = 0
    local usedBonusIds = {}

    -- Add preferred items first
    for _, entry in ipairs(preferredItems) do
        if bonusAdded >= 2 then break end
        if not usedBonusIds[entry.data.id] then
            usedBonusIds[entry.data.id] = true
            table.insert(options, self:makeBonusItemOption(entry))
            bonusAdded = bonusAdded + 1
        end
    end

    -- Fill remaining with general items
    for _, entry in ipairs(bonusEligible) do
        if bonusAdded >= 2 then break end
        if not usedBonusIds[entry.data.id] then
            usedBonusIds[entry.data.id] = true
            table.insert(options, self:makeBonusItemOption(entry))
            bonusAdded = bonusAdded + 1
        end
    end

    return options
end

-- Helper: create a display option for a bonus item
function UpgradeSystem:makeBonusItemOption(entry)
    local itemData = entry.data
    local isUpgrade = entry.isUpgrade
    local nextLevel = entry.currentLevel + 1

    local name = itemData.name
    if isUpgrade then
        name = name .. " Lv" .. nextLevel
    end

    -- Look up paired tool name if this item upgrades a specific tool
    local pairsWithToolName = nil
    if itemData.pairsWithTool then
        local toolData = ToolsData.get(itemData.pairsWithTool)
        if toolData then
            pairsWithToolName = toolData.name
        end
    end

    return {
        id = itemData.id,
        type = "bonus_item",
        name = name,
        description = itemData.description,
        isNew = false,
        isUpgrade = isUpgrade,
        currentLevel = entry.currentLevel,
        nextLevel = nextLevel,
        bonusItemData = itemData,
        pairsWithToolName = pairsWithToolName,
    }
end

-- Apply a tool selection (returns success, evolutionInfo)
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

            if AudioManager then
                AudioManager:playSFX("tool_upgrade", 0.6)
            end

            return true, nil
        end
    else
        -- Upgrade existing tool
        if option.toolRef then
            option.toolRef.level = option.nextLevel
            self.toolLevels[option.id] = option.nextLevel

            if option.toolRef.recalculateStats then
                option.toolRef:recalculateStats()
            end

            print("Upgraded tool: " .. option.originalData.id .. " to Lv" .. option.nextLevel)

            if AudioManager then
                AudioManager:playSFX("tool_upgrade", 0.6)
            end

            -- Check for auto-evolution: tool at max level + matching bonus at max level
            local evolutionInfo = nil
            if option.nextLevel >= MAX_LEVEL and option.originalData.pairsWithBonus then
                if BonusItemsSystem and BonusItemsSystem:canEvolve(option.originalData.id) then
                    option.toolRef:evolve()
                    evolutionInfo = {
                        evolved = true,
                        evolvedName = option.originalData.upgradedName or (option.originalData.name .. " EVO"),
                        originalData = option.originalData,
                    }
                    print("Auto-evolved: " .. option.originalData.id .. " -> " .. (evolutionInfo.evolvedName or "???"))
                end
            end

            return true, evolutionInfo
        end
    end

    return false, nil
end

-- Check and trigger evolution when a bonus item is applied
-- Call this after BonusItemsSystem:applyItem() to check if evolution should happen
function UpgradeSystem:checkBonusEvolution(bonusItemData, station)
    if not bonusItemData or not bonusItemData.pairsWithTool then return nil end

    local bonusLevel = BonusItemsSystem and BonusItemsSystem:getItemLevel(bonusItemData.id) or 0
    if bonusLevel < MAX_LEVEL then return nil end

    -- Bonus is at max level, check if the paired tool is also at max level
    for _, equippedTool in ipairs(station.tools) do
        if equippedTool.data and equippedTool.data.id == bonusItemData.pairsWithTool then
            if equippedTool.level >= MAX_LEVEL and not equippedTool.evolved then
                equippedTool:evolve()
                local evolvedName = equippedTool.data.upgradedName or (equippedTool.data.name .. " EVO")
                print("Auto-evolved (via bonus): " .. equippedTool.data.id .. " -> " .. evolvedName)
                return {
                    evolved = true,
                    evolvedName = evolvedName,
                    originalData = equippedTool.data,
                }
            end
        end
    end

    return nil
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
