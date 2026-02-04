-- Grants System
-- Manages between-run permanent upgrades

GrantsSystem = {}

-- Get current level of a grant
function GrantsSystem:getLevel(grantId)
    return SaveManager:getGrantLevel(grantId)
end

-- Attempt to purchase the next level of a grant
function GrantsSystem:purchase(grantId)
    local currentLevel = self:getLevel(grantId)
    local cost = GrantsData.getCost(grantId, currentLevel)

    if not cost then
        print("GrantsSystem: Grant " .. grantId .. " already max level")
        return false
    end

    local rp = SaveManager:getSpendableRP()
    if rp < cost then
        print("GrantsSystem: Not enough RP (" .. rp .. "/" .. cost .. ")")
        return false
    end

    SaveManager:spendRP(cost)
    SaveManager:setGrantLevel(grantId, currentLevel + 1)

    print("GrantsSystem: Purchased " .. grantId .. " level " .. (currentLevel + 1))
    return true
end

-- Get all active bonuses as a table
function GrantsSystem:getBonuses()
    local bonuses = {
        health = 0,
        damage = 0,
        shields = 0,
        research = 0,
    }

    for _, grantId in ipairs(GrantsData.order) do
        local level = self:getLevel(grantId)
        if level > 0 then
            local grant = GrantsData[grantId]
            bonuses[grant.bonusType] = GrantsData.getBonus(grantId, level)
        end
    end

    return bonuses
end

-- Apply grant bonuses at the start of a gameplay run
function GrantsSystem:applyToGameplay(station)
    local bonuses = self:getBonuses()

    -- Apply health bonus
    if bonuses.health > 0 and station then
        local healthBonus = math.floor(station.maxHealth * bonuses.health)
        station.maxHealth = station.maxHealth + healthBonus
        station.health = station.maxHealth
        print("GrantsSystem: Applied +" .. math.floor(bonuses.health * 100) .. "% health")
    end

    -- Apply shield bonus
    if bonuses.shields > 0 and station then
        local shieldBonus = math.floor(station.shieldDamageCapacity * bonuses.shields)
        station.shieldDamageCapacity = station.shieldDamageCapacity + shieldBonus
        station.shieldCurrentCapacity = station.shieldDamageCapacity
        print("GrantsSystem: Applied +" .. math.floor(bonuses.shields * 100) .. "% shields")
    end

    -- Damage and research bonuses are applied per-use, not here
    print("GrantsSystem: Bonuses applied to gameplay")
end

-- Get damage multiplier (used by tools)
function GrantsSystem:getDamageMultiplier()
    local bonuses = self:getBonuses()
    return 1.0 + bonuses.damage
end

-- Get RP multiplier (used by GameManager)
function GrantsSystem:getRPMultiplier()
    local bonuses = self:getBonuses()
    return 1.0 + bonuses.research
end

return GrantsSystem
