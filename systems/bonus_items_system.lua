-- Bonus Items System
-- Tracks active bonus items per run and applies their effects

BonusItemsSystem = {
    activeItems = {},   -- List of active bonus item IDs this run
}

function BonusItemsSystem:reset()
    self.activeItems = {}
end

-- Grant a random bonus item
function BonusItemsSystem:grantRandom(station)
    local item = BonusItemsData.getRandom()
    if item then
        self:applyItem(item, station)
        return item
    end
    return nil
end

-- Apply a bonus item's effects
function BonusItemsSystem:applyItem(item, station)
    if not item or not station then return end

    if item.effectType == "instant" then
        self:applyInstantEffect(item.effect, station)
    elseif item.effectType == "persistent" then
        table.insert(self.activeItems, item.id)
        self:applyPersistentEffect(item.effect, station)
    end

    print("BonusItemsSystem: Applied " .. item.name)

    -- Recalculate stats on all existing tools to pick up the new bonus
    if station and station.tools then
        for _, tool in ipairs(station.tools) do
            tool:recalculateStats()
        end
    end
end

-- Apply instant effects
function BonusItemsSystem:applyInstantEffect(effect, station)
    if not effect then return end

    if effect.type == "heal" then
        station:heal(effect.value)
    end
end

-- Apply persistent effects
function BonusItemsSystem:applyPersistentEffect(effect, station)
    if not effect then return end

    if effect.type == "healthPercent" then
        local bonus = math.floor(station.maxHealth * effect.value)
        station.maxHealth = station.maxHealth + bonus
        station.health = station.health + bonus

    elseif effect.type == "shieldPercent" then
        local bonus = math.floor(station.shieldDamageCapacity * effect.value)
        station.shieldDamageCapacity = station.shieldDamageCapacity + bonus
        station.shieldCurrentCapacity = station.shieldDamageCapacity

    elseif effect.type == "fireRate" then
        -- Applied via getFireRateBonus()
    elseif effect.type == "collectRange" then
        -- Applied via getCollectRangeBonus()
    elseif effect.type == "damageReduction" then
        -- Applied via getDamageReduction()
    elseif effect.type == "rotationSpeed" then
        -- Applied via getRotationSpeedBonus()
    elseif effect.type == "rpBonus" then
        -- Applied via getRPBonus()
    elseif effect.type == "shieldCooldown" then
        -- Applied via getShieldCooldownReduction()
    elseif effect.type == "projectileSpeed" then
        -- Applied via getProjectileSpeedBonus()
    end
end

-- Aggregate bonus getters (called by relevant systems)
function BonusItemsSystem:getFireRateBonus()
    local bonus = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "fireRate" then
            bonus = bonus + item.effect.value
        end
    end
    return bonus
end

function BonusItemsSystem:getDamageReduction()
    local reduction = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "damageReduction" then
            reduction = reduction + item.effect.value
        end
    end
    return reduction
end

function BonusItemsSystem:getRPBonus()
    local bonus = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "rpBonus" then
            bonus = bonus + item.effect.value
        end
    end
    return bonus
end

function BonusItemsSystem:getProjectileSpeedBonus()
    local bonus = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "projectileSpeed" then
            bonus = bonus + item.effect.value
        end
    end
    return bonus
end

function BonusItemsSystem:getCollectRangeBonus()
    local bonus = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "collectRange" then
            bonus = bonus + item.effect.value
        end
    end
    return bonus
end

function BonusItemsSystem:getRotationSpeedBonus()
    local bonus = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "rotationSpeed" then
            bonus = bonus + item.effect.value
        end
    end
    return bonus
end

function BonusItemsSystem:getShieldCooldownReduction()
    local reduction = 0
    for _, itemId in ipairs(self.activeItems) do
        local item = BonusItemsData[itemId]
        if item and item.effect and item.effect.type == "shieldCooldown" then
            reduction = reduction + item.effect.value
        end
    end
    return reduction
end

return BonusItemsSystem
