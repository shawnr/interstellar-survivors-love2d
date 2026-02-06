-- Bonus Items Data
-- Full 33-item set: 14 tool-pairing items + 19 general passive items
-- Ported from original Playdate source with Love2D effect format

BonusItemsData = {
    -- ============================================
    -- Tool Upgrade Items (14) — pair with specific tools for evolution
    -- ============================================

    alloy_gears = {
        id = "alloy_gears",
        name = "Alloy Gears",
        description = "+25% physical dmg",
        iconPath = "assets/images/icons_on_white/bonus_alloy_gears",
        effect = "damage_physical",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = "rail_driver",
        upgradesTo = "Rail Cannon",
        unlockCondition = "start",
    },

    expanded_dish = {
        id = "expanded_dish",
        name = "Expanded Dish",
        description = "+25% frequency dmg",
        iconPath = "assets/images/icons_on_white/bonus_expanded_dish",
        effect = "damage_frequency",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = "frequency_scanner",
        upgradesTo = "Harmonic Disruptor",
        unlockCondition = "start",
    },

    magnetic_coils = {
        id = "magnetic_coils",
        name = "Magnetic Coils",
        description = "Tractor range +50%",
        iconPath = "assets/images/icons_on_white/bonus_magnetic_coils",
        effect = "tractor_range",
        effectValue = 0.5,
        effectPerLevel = 0.25,
        pairsWithTool = "tractor_pulse",
        upgradesTo = "Gravity Well",
        unlockCondition = "start",
    },

    cooling_vents = {
        id = "cooling_vents",
        name = "Cooling Vents",
        description = "+25% thermal dmg",
        iconPath = "assets/images/icons_on_white/bonus_cooling_vents",
        effect = "damage_thermal",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = "thermal_lance",
        upgradesTo = "Plasma Cutter",
        unlockCondition = "episode_1",
    },

    fuel_injector = {
        id = "fuel_injector",
        name = "Fuel Injector",
        description = "+25% plasma dmg",
        iconPath = "assets/images/icons_on_white/bonus_fuel_injector",
        effect = "damage_plasma",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = "plasma_sprayer",
        upgradesTo = "Inferno Cannon",
        unlockCondition = "episode_1",
    },

    compressor_unit = {
        id = "compressor_unit",
        name = "Compressor Unit",
        description = "Slow duration +50%",
        iconPath = "assets/images/icons_on_white/bonus_compressor_unit",
        effect = "slow_duration",
        effectValue = 0.5,
        effectPerLevel = 0.25,
        pairsWithTool = "cryo_projector",
        upgradesTo = "Absolute Zero",
        unlockCondition = "episode_2",
    },

    targeting_matrix = {
        id = "targeting_matrix",
        name = "Targeting Matrix",
        description = "+30% homing accuracy",
        iconPath = "assets/images/icons_on_white/bonus_targeting_matrix",
        effect = "homing_accuracy",
        effectValue = 0.3,
        effectPerLevel = 0.15,
        pairsWithTool = "mapping_drone",
        upgradesTo = "Perihelion Strike",
        unlockCondition = "episode_2",
    },

    guidance_module = {
        id = "guidance_module",
        name = "Guidance Module",
        description = "+2 missiles per burst",
        iconPath = "assets/images/icons_on_white/bonus_guidance_module",
        effect = "missiles_per_burst",
        effectValue = 2,
        effectPerLevel = 1,
        pairsWithTool = "micro_missile_pod",
        upgradesTo = "Swarm Launcher",
        unlockCondition = "episode_2",
    },

    capacitor_bank = {
        id = "capacitor_bank",
        name = "Capacitor Bank",
        description = "+25% electric dmg",
        iconPath = "assets/images/icons_on_white/bonus_capacitor_bank",
        effect = "damage_electric",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = "emp_burst",
        upgradesTo = "Ion Storm",
        unlockCondition = "episode_3",
    },

    graviton_lens = {
        id = "graviton_lens",
        name = "Graviton Lens",
        description = "+50% orbital range",
        iconPath = "assets/images/icons_on_white/bonus_graviton_lens",
        effect = "orbital_range",
        effectValue = 0.5,
        effectPerLevel = 0.25,
        pairsWithTool = "singularity_core",
        upgradesTo = "Black Hole Generator",
        unlockCondition = "episode_3",
    },

    arc_capacitors = {
        id = "arc_capacitors",
        name = "Arc Capacitors",
        description = "+1 chain target",
        iconPath = "assets/images/icons_on_white/bonus_arc_capacitors",
        effect = "chain_targets",
        effectValue = 1,
        effectPerLevel = 1,
        pairsWithTool = "tesla_coil",
        upgradesTo = "Storm Generator",
        unlockCondition = "episode_3",
    },

    probe_swarm = {
        id = "probe_swarm",
        name = "Probe Swarm",
        description = "+2 probes per shot",
        iconPath = "assets/images/icons_on_white/bonus_probe_swarm",
        effect = "extra_probes",
        effectValue = 2,
        effectPerLevel = 1,
        pairsWithTool = "probe_launcher",
        upgradesTo = "Drone Carrier",
        unlockCondition = "episode_4",
    },

    phase_modulators = {
        id = "phase_modulators",
        name = "Phase Modulators",
        description = "+25% phase dmg",
        iconPath = "assets/images/icons_on_white/bonus_phase_modulators",
        effect = "damage_phase",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = "phase_disruptor",
        upgradesTo = "Dimensional Rift",
        unlockCondition = "episode_4",
    },

    field_amplifier = {
        id = "field_amplifier",
        name = "Field Amplifier",
        description = "Push force +50%",
        iconPath = "assets/images/icons_on_white/bonus_field_amplifier",
        effect = "push_force",
        effectValue = 0.5,
        effectPerLevel = 0.25,
        pairsWithTool = "repulsor_field",
        upgradesTo = "Shockwave Generator",
        unlockCondition = "episode_5",
    },

    -- ============================================
    -- General Passive Items (19) — no tool pairing
    -- ============================================

    reinforced_hull = {
        id = "reinforced_hull",
        name = "Reinforced Hull",
        description = "+20% max health",
        iconPath = "assets/images/icons_on_white/bonus_reinforced_hull",
        effect = "max_health",
        effectValue = 0.20,
        effectPerLevel = 0.10,
        pairsWithTool = nil,
        unlockCondition = "start",
    },

    emergency_thrusters = {
        id = "emergency_thrusters",
        name = "Emergency Thrusters",
        description = "+25% projectile speed",
        iconPath = "assets/images/icons_on_white/bonus_emergency_thrusters",
        effect = "projectile_speed",
        effectValue = 0.25,
        effectPerLevel = 0.12,
        pairsWithTool = nil,
        unlockCondition = "start",
    },

    shield_capacitor = {
        id = "shield_capacitor",
        name = "Shield Capacitor",
        description = "Upgrades shield",
        iconPath = "assets/images/icons_on_white/bonus_shield_capacitor",
        effect = "shield_upgrade",
        effectValue = 1,
        effectPerLevel = 1,
        pairsWithTool = nil,
        unlockCondition = "start",
    },

    overclocked_capacitors = {
        id = "overclocked_capacitors",
        name = "Overclocked Caps",
        description = "+15% fire rate (all)",
        iconPath = "assets/images/icons_on_white/bonus_overclocked_caps",
        effect = "fire_rate",
        effectValue = 0.15,
        effectPerLevel = 0.08,
        pairsWithTool = nil,
        unlockCondition = "episode_1",
    },

    power_relay = {
        id = "power_relay",
        name = "Power Relay",
        description = "+10% all damage",
        iconPath = "assets/images/icons_on_white/bonus_power_relay",
        effect = "damage_boost",
        effectValue = 0.10,
        effectPerLevel = 0.05,
        pairsWithTool = nil,
        unlockCondition = "episode_1",
    },

    salvage_drone = {
        id = "salvage_drone",
        name = "Salvage Drone",
        description = "Auto-collects RP nearby",
        iconPath = "assets/images/icons_on_white/bonus_salvage_drone",
        effect = "auto_collect",
        effectValue = 60,
        effectPerLevel = 20,
        pairsWithTool = nil,
        unlockCondition = "episode_1",
    },

    rapid_repair = {
        id = "rapid_repair",
        name = "Rapid Repair",
        description = "Faster HP regen",
        iconPath = "assets/images/icons_on_white/bonus_rapid_repair",
        effect = "regen_speed",
        effectValue = 1,
        effectPerLevel = 0.5,
        pairsWithTool = nil,
        unlockCondition = "episode_2",
    },

    quantum_stabilizer = {
        id = "quantum_stabilizer",
        name = "Quantum Stabilizer",
        description = "-10% all damage taken",
        iconPath = "assets/images/icons_on_white/bonus_quantum_stabilizer",
        effect = "damage_reduction",
        effectValue = 0.10,
        effectPerLevel = 0.05,
        pairsWithTool = nil,
        unlockCondition = "episode_2",
    },

    critical_matrix = {
        id = "critical_matrix",
        name = "Critical Matrix",
        description = "+15% crit chance (2x dmg)",
        iconPath = "assets/images/icons_on_white/bonus_critical_matrix",
        effect = "crit_chance",
        effectValue = 0.15,
        effectPerLevel = 0.08,
        pairsWithTool = nil,
        unlockCondition = "episode_2",
    },

    brain_buddy = {
        id = "brain_buddy",
        name = "BrainBuddy",
        description = "+15% fire rate",
        iconPath = "assets/images/icons_on_white/bonus_brain_buddy",
        effect = "fire_rate",
        effectValue = 0.15,
        effectPerLevel = 0.08,
        pairsWithTool = nil,
        unlockCondition = "episode_3",
    },

    scrap_collector = {
        id = "scrap_collector",
        name = "Scrap Collector",
        description = "+15% RP from MOBs",
        iconPath = "assets/images/icons_on_white/bonus_scrap_collector",
        effect = "rp_bonus",
        effectValue = 0.15,
        effectPerLevel = 0.08,
        pairsWithTool = nil,
        unlockCondition = "episode_3",
    },

    kinetic_absorber = {
        id = "kinetic_absorber",
        name = "Kinetic Absorber",
        description = "+1 HP per 10 kills",
        iconPath = "assets/images/icons_on_white/bonus_kinetic_absorber",
        effect = "hp_on_kill",
        effectValue = 10,
        effectPerLevel = -2,
        pairsWithTool = nil,
        unlockCondition = "episode_3",
    },

    backup_generator = {
        id = "backup_generator",
        name = "Backup Generator",
        description = "Regen 1 HP/5 sec",
        iconPath = "assets/images/icons_on_white/bonus_backup_generator",
        effect = "health_regen",
        effectValue = 1,
        effectPerLevel = 0.5,
        pairsWithTool = nil,
        unlockCondition = "episode_4",
    },

    rapid_loader = {
        id = "rapid_loader",
        name = "Rapid Loader",
        description = "-20% cooldown on kill",
        iconPath = "assets/images/icons_on_white/bonus_rapid_loader",
        effect = "cooldown_on_kill",
        effectValue = 0.20,
        effectPerLevel = 0.10,
        pairsWithTool = nil,
        unlockCondition = "episode_4",
    },

    ablative_coating = {
        id = "ablative_coating",
        name = "Ablative Coating",
        description = "-15% ram damage",
        iconPath = "assets/images/icons_on_white/bonus_ablative_coating",
        effect = "ram_resistance",
        effectValue = 0.15,
        effectPerLevel = 0.08,
        pairsWithTool = nil,
        unlockCondition = "all_episodes",
    },

    multi_spectrum_rounds = {
        id = "multi_spectrum_rounds",
        name = "Multi-Spectrum",
        description = "+5% dmg per tool equipped",
        iconPath = "assets/images/icons_on_white/bonus_multi_spectrum",
        effect = "damage_per_tool",
        effectValue = 0.05,
        effectPerLevel = 0.025,
        pairsWithTool = nil,
        unlockCondition = "episode_5",
    },
}

-- Build lookup lists
BonusItemsData.allIds = {}
BonusItemsData.toolPairingIds = {}
BonusItemsData.generalIds = {}

for id, data in pairs(BonusItemsData) do
    if type(data) == "table" and data.id then
        table.insert(BonusItemsData.allIds, id)
        if data.pairsWithTool then
            table.insert(BonusItemsData.toolPairingIds, id)
        else
            table.insert(BonusItemsData.generalIds, id)
        end
    end
end

-- Get bonus item by ID
function BonusItemsData.get(id)
    local data = BonusItemsData[id]
    if type(data) == "table" and data.id then
        return data
    end
    return nil
end

-- Calculate effect value for a bonus item at a specific level (1-4)
function BonusItemsData.getEffectAtLevel(id, level)
    local data = BonusItemsData[id]
    if not data then return nil end

    level = math.max(1, math.min(4, level or 1))
    local levelBonus = level - 1

    local perLevel = data.effectPerLevel or (data.effectValue * 0.5)
    return data.effectValue + perLevel * levelBonus
end

-- Get a random bonus item (respects unlock conditions)
function BonusItemsData.getRandom(currentEpisode)
    currentEpisode = currentEpisode or 1
    local eligible = {}
    for _, id in ipairs(BonusItemsData.allIds) do
        local data = BonusItemsData[id]
        if BonusItemsData.isUnlocked(data.unlockCondition, currentEpisode) then
            table.insert(eligible, data)
        end
    end
    if #eligible == 0 then return nil end
    return eligible[math.random(#eligible)]
end

-- Get the item that pairs with a specific tool
function BonusItemsData.getPairForTool(toolId)
    for _, id in ipairs(BonusItemsData.toolPairingIds) do
        local data = BonusItemsData[id]
        if data.pairsWithTool == toolId then
            return data
        end
    end
    return nil
end

-- Check unlock condition
function BonusItemsData.isUnlocked(condition, currentEpisode)
    if condition == "start" then
        return true
    end
    if condition == "all_episodes" then
        return currentEpisode >= 5
    end
    local reqEp = condition and condition:match("episode_(%d+)")
    if reqEp then
        return currentEpisode >= tonumber(reqEp)
    end
    return false
end

return BonusItemsData
