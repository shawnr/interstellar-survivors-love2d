-- Bonus Items System
-- Tracks active bonus items per run with leveling (1-4) and applies their effects

BonusItemsSystem = {
    activeItems = {},   -- { [itemId] = level } — levels 1-4
}

function BonusItemsSystem:reset()
    self.activeItems = {}
end

-- Check if an item is owned
function BonusItemsSystem:hasItem(itemId)
    return self.activeItems[itemId] ~= nil
end

-- Get the current level of an owned item (0 if not owned)
function BonusItemsSystem:getItemLevel(itemId)
    return self.activeItems[itemId] or 0
end

-- Get count of active items
function BonusItemsSystem:getActiveItemCount()
    local count = 0
    for _ in pairs(self.activeItems) do
        count = count + 1
    end
    return count
end

-- Get list of active items with levels
function BonusItemsSystem:getActiveItemList()
    local list = {}
    for id, level in pairs(self.activeItems) do
        table.insert(list, { id = id, level = level })
    end
    return list
end

-- Grant a random bonus item (used by collectible pickups)
function BonusItemsSystem:grantRandom(station)
    local episode = UpgradeSystem and UpgradeSystem.currentEpisode or 1
    local item = BonusItemsData.getRandom(episode)
    if item then
        self:applyItem(item, station)
        return item
    end
    return nil
end

-- Apply a bonus item (new or upgrade)
function BonusItemsSystem:applyItem(item, station)
    if not item or not station then return end

    local currentLevel = self.activeItems[item.id] or 0
    if currentLevel >= 4 then
        print("BonusItemsSystem: " .. item.name .. " already at max level")
        return
    end

    local newLevel = currentLevel + 1
    local isUpgrade = currentLevel > 0
    self.activeItems[item.id] = newLevel

    -- Apply "on acquire" effects (health, shield — applied immediately)
    self:applyOnAcquireEffect(item, station, newLevel, isUpgrade)

    print("BonusItemsSystem: " .. (isUpgrade and "Upgraded" or "Applied") ..
          " " .. item.name .. " to Lv" .. newLevel)

    -- Recalculate stats on all existing tools to pick up the new bonus
    if station and station.tools then
        for _, tool in ipairs(station.tools) do
            tool:recalculateStats()
        end
    end
end

-- Apply effects that take effect immediately on acquisition/upgrade
function BonusItemsSystem:applyOnAcquireEffect(item, station, level, isUpgrade)
    local effect = item.effect

    if effect == "max_health" then
        -- Percentage of current max health
        local pct = isUpgrade and item.effectPerLevel or item.effectValue
        local bonus = math.floor(station.maxHealth * pct)
        station.maxHealth = station.maxHealth + bonus
        station.health = station.health + bonus

    elseif effect == "shield_upgrade" then
        -- Add shield capacity
        local bonus = isUpgrade and item.effectPerLevel or item.effectValue
        station.shieldDamageCapacity = (station.shieldDamageCapacity or 0) + bonus
        station.shieldCurrentCapacity = station.shieldDamageCapacity
    end
    -- All other effects are passive (calculated by getter methods on demand)
end

-- ============================================
-- Aggregate bonus getters
-- ============================================

-- Helper: sum effect values for all active items matching a specific effect type
function BonusItemsSystem:sumEffect(effectType)
    local total = 0
    for itemId, level in pairs(self.activeItems) do
        local item = BonusItemsData.get(itemId)
        if item and item.effect == effectType then
            total = total + BonusItemsData.getEffectAtLevel(itemId, level)
        end
    end
    return total
end

-- General passive bonuses (applied globally)
function BonusItemsSystem:getFireRateBonus()
    return self:sumEffect("fire_rate")
end

function BonusItemsSystem:getDamageReduction()
    return self:sumEffect("damage_reduction")
end

function BonusItemsSystem:getRPBonus()
    return self:sumEffect("rp_bonus")
end

function BonusItemsSystem:getProjectileSpeedBonus()
    return self:sumEffect("projectile_speed")
end

function BonusItemsSystem:getDamageBoost()
    return self:sumEffect("damage_boost")
end

function BonusItemsSystem:getCritChance()
    return self:sumEffect("crit_chance")
end

function BonusItemsSystem:getAutoCollectRange()
    return self:sumEffect("auto_collect")
end

function BonusItemsSystem:getHealthRegen()
    return self:sumEffect("health_regen")
end

function BonusItemsSystem:getRegenSpeed()
    return self:sumEffect("regen_speed")
end

function BonusItemsSystem:getHPOnKillThreshold()
    return self:sumEffect("hp_on_kill")
end

function BonusItemsSystem:getCooldownOnKill()
    return self:sumEffect("cooldown_on_kill")
end

function BonusItemsSystem:getDamagePerTool()
    return self:sumEffect("damage_per_tool")
end

function BonusItemsSystem:getRamResistance()
    return self:sumEffect("ram_resistance")
end

-- Backward-compatible getters (old effect types no longer in new item set)
function BonusItemsSystem:getCollectRangeBonus()
    return 0
end

function BonusItemsSystem:getRotationSpeedBonus()
    return 0
end

function BonusItemsSystem:getShieldCooldownReduction()
    return 0
end

-- ============================================
-- Tool-pairing support
-- ============================================

-- Get the effect bonus from a tool's paired item (if owned)
function BonusItemsSystem:getToolPairingBonus(toolId)
    local pairedItem = BonusItemsData.getPairForTool(toolId)
    if pairedItem and self.activeItems[pairedItem.id] then
        local level = self.activeItems[pairedItem.id]
        return BonusItemsData.getEffectAtLevel(pairedItem.id, level)
    end
    return 0
end

-- Check if a tool is eligible for evolution (paired item at Lv4)
function BonusItemsSystem:canEvolve(toolId)
    local toolData = ToolsData.get(toolId)
    if not toolData or not toolData.pairsWithBonus then return false end

    local itemLevel = self.activeItems[toolData.pairsWithBonus] or 0
    return itemLevel >= 4
end

return BonusItemsSystem
