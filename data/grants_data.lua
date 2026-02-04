-- Grants Data
-- Between-run permanent upgrades purchased with accumulated RP

GrantsData = {
    health = {
        id = "health",
        name = "Hull Reinforcement",
        description = "Increases station max health",
        maxLevel = 4,
        costs = { 100, 300, 900, 2700 },
        bonusPerLevel = 0.25,  -- +25% per level
        bonusType = "health",
    },

    damage = {
        id = "damage",
        name = "Weapons Research",
        description = "Increases all tool damage",
        maxLevel = 4,
        costs = { 100, 300, 900, 2700 },
        bonusPerLevel = 0.25,  -- +25% per level
        bonusType = "damage",
    },

    shields = {
        id = "shields",
        name = "Shield Technology",
        description = "Increases shield capacity",
        maxLevel = 4,
        costs = { 100, 300, 900, 2700 },
        bonusPerLevel = 0.25,  -- +25% per level
        bonusType = "shields",
    },

    research = {
        id = "research",
        name = "Research Methodology",
        description = "Increases RP earned",
        maxLevel = 4,
        costs = { 300, 900, 2700, 8100 },
        bonusPerLevel = 0.25,  -- +25% per level
        bonusType = "research",
    },
}

-- Ordered list for UI display
GrantsData.order = { "health", "damage", "shields", "research" }

-- Get cost for next level of a grant
function GrantsData.getCost(grantId, currentLevel)
    local grant = GrantsData[grantId]
    if not grant then return nil end
    if currentLevel >= grant.maxLevel then return nil end
    return grant.costs[currentLevel + 1]
end

-- Get bonus multiplier for a grant at a given level
function GrantsData.getBonus(grantId, level)
    local grant = GrantsData[grantId]
    if not grant or level <= 0 then return 0 end
    return grant.bonusPerLevel * level
end

return GrantsData
