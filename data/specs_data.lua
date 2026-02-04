-- Research Specs Data
-- Passive bonuses unlocked by achievements, equip up to 3

SpecsData = {
    silk_weave_plating = {
        id = "silk_weave_plating",
        name = "Silk-Weave Plating",
        description = "+10% max health",
        unlockCondition = "episode_1",
        unlockText = "Complete Episode 1",
        effect = { type = "health", value = 0.10 },
    },

    efficiency_protocols = {
        id = "efficiency_protocols",
        name = "Efficiency Protocols",
        description = "+5% fire rate",
        unlockCondition = "episode_2",
        unlockText = "Complete Episode 2",
        effect = { type = "fireRate", value = 0.05 },
    },

    probability_shield = {
        id = "probability_shield",
        name = "Probability Shield",
        description = "5% dodge chance",
        unlockCondition = "episode_3",
        unlockText = "Complete Episode 3",
        effect = { type = "dodge", value = 0.05 },
    },

    ancient_alloys = {
        id = "ancient_alloys",
        name = "Ancient Alloys",
        description = "+15% max health",
        unlockCondition = "episode_4",
        unlockText = "Complete Episode 4",
        effect = { type = "health", value = 0.15 },
    },

    peer_review = {
        id = "peer_review",
        name = "Peer Review",
        description = "+10% RP bonus",
        unlockCondition = "episode_5",
        unlockText = "Complete Episode 5",
        effect = { type = "research", value = 0.10 },
    },

    emergency_reserves = {
        id = "emergency_reserves",
        name = "Emergency Reserves",
        description = "+25 starting health",
        unlockCondition = "victories_3",
        unlockText = "Win 3 episodes",
        effect = { type = "flatHealth", value = 25 },
    },

    magnetic_attraction = {
        id = "magnetic_attraction",
        name = "Magnetic Attraction",
        description = "+20% collectible range",
        unlockCondition = "deaths_5",
        unlockText = "Die 5 times",
        effect = { type = "collectRange", value = 0.20 },
    },

    veteran_instincts = {
        id = "veteran_instincts",
        name = "Veteran Instincts",
        description = "Start at Level 2",
        unlockCondition = "all_episodes",
        unlockText = "Complete all episodes",
        effect = { type = "startLevel", value = 2 },
    },

    tool_mastery = {
        id = "tool_mastery",
        name = "Tool Mastery",
        description = "Start with random bonus tool",
        unlockCondition = "all_episodes",
        unlockText = "Complete all episodes",
        effect = { type = "bonusTool", value = 1 },
    },
}

-- Ordered list for UI
SpecsData.order = {
    "silk_weave_plating",
    "efficiency_protocols",
    "probability_shield",
    "ancient_alloys",
    "peer_review",
    "emergency_reserves",
    "magnetic_attraction",
    "veteran_instincts",
    "tool_mastery",
}

SpecsData.MAX_EQUIPPED = 3

return SpecsData
