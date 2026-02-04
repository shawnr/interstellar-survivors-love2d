-- Bonus Items Data
-- 10 representative items with instant or persistent effects

BonusItemsData = {
    health_kit = {
        id = "health_kit",
        name = "Health Kit",
        description = "+20% max health",
        iconPath = "assets/images/icons_on_white/bonus_reinforced_hull",
        effectType = "persistent",
        effect = { type = "healthPercent", value = 0.20 },
        rarity = 1,
    },

    rapid_loader = {
        id = "rapid_loader",
        name = "Rapid Loader",
        description = "+15% fire rate",
        iconPath = "assets/images/icons_on_white/bonus_rapid_loader",
        effectType = "persistent",
        effect = { type = "fireRate", value = 0.15 },
        rarity = 1,
    },

    shield_booster = {
        id = "shield_booster",
        name = "Shield Booster",
        description = "+50% shield capacity",
        iconPath = "assets/images/icons_on_white/bonus_shield_capacitor",
        effectType = "persistent",
        effect = { type = "shieldPercent", value = 0.50 },
        rarity = 2,
    },

    magnet_module = {
        id = "magnet_module",
        name = "Magnet Module",
        description = "+30% collectible range",
        iconPath = "assets/images/icons_on_white/bonus_magnetic_coils",
        effectType = "persistent",
        effect = { type = "collectRange", value = 0.30 },
        rarity = 1,
    },

    armor_plating = {
        id = "armor_plating",
        name = "Armor Plating",
        description = "-10% damage taken",
        iconPath = "assets/images/icons_on_white/bonus_ablative_coating",
        effectType = "persistent",
        effect = { type = "damageReduction", value = 0.10 },
        rarity = 2,
    },

    speed_governor = {
        id = "speed_governor",
        name = "Speed Governor",
        description = "+10% rotation speed",
        iconPath = "assets/images/icons_on_white/bonus_fuel_injector",
        effectType = "persistent",
        effect = { type = "rotationSpeed", value = 0.10 },
        rarity = 1,
    },

    research_amplifier = {
        id = "research_amplifier",
        name = "Research Amplifier",
        description = "+20% RP earned",
        iconPath = "assets/images/icons_on_white/bonus_field_amplifier",
        effectType = "persistent",
        effect = { type = "rpBonus", value = 0.20 },
        rarity = 2,
    },

    coolant_system = {
        id = "coolant_system",
        name = "Coolant System",
        description = "-20% shield cooldown",
        iconPath = "assets/images/icons_on_white/bonus_cooling_vents",
        effectType = "persistent",
        effect = { type = "shieldCooldown", value = 0.20 },
        rarity = 2,
    },

    targeting_array = {
        id = "targeting_array",
        name = "Targeting Array",
        description = "+10% projectile speed",
        iconPath = "assets/images/icons_on_white/bonus_targeting_computer",
        effectType = "persistent",
        effect = { type = "projectileSpeed", value = 0.10 },
        rarity = 1,
    },

    emergency_repair = {
        id = "emergency_repair",
        name = "Emergency Repair",
        description = "Heal 50 HP",
        iconPath = "assets/images/icons_on_white/bonus_backup_generator",
        effectType = "instant",
        effect = { type = "heal", value = 50 },
        rarity = 1,
    },
}

-- List for random selection
BonusItemsData.all = {
    "health_kit", "rapid_loader", "shield_booster", "magnet_module",
    "armor_plating", "speed_governor", "research_amplifier",
    "coolant_system", "targeting_array", "emergency_repair",
}

-- Get a random bonus item
function BonusItemsData.getRandom()
    local id = BonusItemsData.all[math.random(#BonusItemsData.all)]
    return BonusItemsData[id]
end

return BonusItemsData
