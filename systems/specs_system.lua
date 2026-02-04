-- Specs System
-- Research Specs unlock, equip, and apply logic

SpecsSystem = {}

-- Check all unlock conditions and unlock any new specs
function SpecsSystem:checkUnlocks()
    for _, specId in ipairs(SpecsData.order) do
        if not SaveManager:isSpecUnlocked(specId) then
            local spec = SpecsData[specId]
            if spec and self:isConditionMet(spec.unlockCondition) then
                SaveManager:unlockSpec(specId)
                print("SpecsSystem: Unlocked " .. spec.name)
            end
        end
    end
end

-- Check if an unlock condition is met
function SpecsSystem:isConditionMet(condition)
    if not condition then return false end

    -- Parse episode_N
    local epNum = condition:match("episode_(%d+)")
    if epNum then
        return SaveManager:isEpisodeCompleted(tonumber(epNum))
    end

    -- Parse victories_N
    local vicNum = condition:match("victories_(%d+)")
    if vicNum then
        return SaveManager:getTotalVictories() >= tonumber(vicNum)
    end

    -- Parse deaths_N
    local deathNum = condition:match("deaths_(%d+)")
    if deathNum then
        return SaveManager:getTotalDeaths() >= tonumber(deathNum)
    end

    -- all_episodes
    if condition == "all_episodes" then
        for i = 1, 5 do
            if not SaveManager:isEpisodeCompleted(i) then
                return false
            end
        end
        return true
    end

    return false
end

-- Equip a spec (max 3)
function SpecsSystem:equip(specId)
    if not SaveManager:isSpecUnlocked(specId) then return false end

    local equipped = SaveManager:getEquippedSpecs()

    -- Check if already equipped
    for _, id in ipairs(equipped) do
        if id == specId then return false end
    end

    -- Check max
    if #equipped >= SpecsData.MAX_EQUIPPED then return false end

    table.insert(equipped, specId)
    SaveManager:setEquippedSpecs(equipped)
    return true
end

-- Unequip a spec
function SpecsSystem:unequip(specId)
    local equipped = SaveManager:getEquippedSpecs()
    for i, id in ipairs(equipped) do
        if id == specId then
            table.remove(equipped, i)
            SaveManager:setEquippedSpecs(equipped)
            return true
        end
    end
    return false
end

-- Check if a spec is equipped
function SpecsSystem:isEquipped(specId)
    local equipped = SaveManager:getEquippedSpecs()
    for _, id in ipairs(equipped) do
        if id == specId then return true end
    end
    return false
end

-- Toggle equip/unequip
function SpecsSystem:toggleEquip(specId)
    if self:isEquipped(specId) then
        return self:unequip(specId)
    else
        return self:equip(specId)
    end
end

-- Apply equipped spec effects at the start of a gameplay run
function SpecsSystem:applyToGameplay(station)
    local equipped = SaveManager:getEquippedSpecs()

    for _, specId in ipairs(equipped) do
        local spec = SpecsData[specId]
        if spec and spec.effect then
            self:applyEffect(spec.effect, station)
        end
    end

    print("SpecsSystem: Applied " .. #equipped .. " spec(s)")
end

-- Apply a single spec effect
function SpecsSystem:applyEffect(effect, station)
    if not effect or not station then return end

    if effect.type == "health" then
        local bonus = math.floor(station.maxHealth * effect.value)
        station.maxHealth = station.maxHealth + bonus
        station.health = station.maxHealth

    elseif effect.type == "flatHealth" then
        station.maxHealth = station.maxHealth + effect.value
        station.health = station.maxHealth

    elseif effect.type == "startLevel" then
        -- Start at higher level
        if GameManager then
            while GameManager.playerLevel < effect.value do
                GameManager:levelUp()
            end
        end
    end

    -- fireRate, dodge, research, collectRange, bonusTool are checked at use-time
end

-- Get fire rate bonus from equipped specs
function SpecsSystem:getFireRateBonus()
    local bonus = 0
    local equipped = SaveManager:getEquippedSpecs()
    for _, specId in ipairs(equipped) do
        local spec = SpecsData[specId]
        if spec and spec.effect and spec.effect.type == "fireRate" then
            bonus = bonus + spec.effect.value
        end
    end
    return bonus
end

-- Get dodge chance from equipped specs
function SpecsSystem:getDodgeChance()
    local dodge = 0
    local equipped = SaveManager:getEquippedSpecs()
    for _, specId in ipairs(equipped) do
        local spec = SpecsData[specId]
        if spec and spec.effect and spec.effect.type == "dodge" then
            dodge = dodge + spec.effect.value
        end
    end
    return dodge
end

-- Get RP bonus from equipped specs
function SpecsSystem:getRPBonus()
    local bonus = 0
    local equipped = SaveManager:getEquippedSpecs()
    for _, specId in ipairs(equipped) do
        local spec = SpecsData[specId]
        if spec and spec.effect and spec.effect.type == "research" then
            bonus = bonus + spec.effect.value
        end
    end
    return bonus
end

return SpecsSystem
