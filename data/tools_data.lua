-- Tools Data
-- All tool definitions

ToolsData = {
    rail_driver = {
        id = "rail_driver",
        name = "Rail Driver",
        description = "Kinetic launcher. Dmg: 8",
        imagePath = "assets/images/tools/tool_rail_driver",
        iconPath = "assets/images/tools/tool_rail_driver",
        projectileImage = "assets/images/tools/tool_rail_driver_projectile",
        baseDamage = 8,
        fireRate = 2.0,
        projectileSpeed = 300,  -- px/sec
        pattern = "straight",
        unlockCondition = "start",
        pairsWithBonus = "alloy_gears",
        upgradedName = "Rail Cannon",
        damagePerLevel = 4,
        fireRatePerLevel = 0.3,
    },

    frequency_scanner = {
        id = "frequency_scanner",
        name = "Frequency Scanner",
        description = "Frequency damage. Dmg: 10",
        imagePath = "assets/images/tools/tool_frequency_scanner",
        iconPath = "assets/images/tools/tool_frequency_scanner",
        projectileImage = "assets/images/tools/tool_frequency_scanner_beam",
        baseDamage = 10,
        fireRate = 1.2,
        projectileSpeed = 420,  -- px/sec (14 * 30)
        pattern = "straight",
        unlockCondition = "start",
        pairsWithBonus = "expanded_dish",
        upgradedName = "Harmonic Disruptor",
        damagePerLevel = 5,
        fireRatePerLevel = 0.2,
    },

    tractor_pulse = {
        id = "tractor_pulse",
        name = "Tractor Pulse",
        description = "Pulls collectibles. No dmg",
        imagePath = "assets/images/tools/tool_tractor_pulse",
        iconPath = "assets/images/tools/tool_tractor_pulse",
        baseDamage = 0,
        fireRate = 0.8,
        projectileSpeed = 0,
        pattern = "pulse",
        unlockCondition = "start",
        pairsWithBonus = "magnetic_coils",
        upgradedName = "Gravity Well",
        rangePerLevel = 15,
    },

    thermal_lance = {
        id = "thermal_lance",
        name = "Thermal Lance",
        description = "Heat beam. Dmg: 12",
        imagePath = "assets/images/tools/tool_thermal_lance",
        iconPath = "assets/images/tools/tool_thermal_lance",
        projectileImage = "assets/images/tools/tool_thermal_beam",
        baseDamage = 12,
        fireRate = 0.6,
        projectileSpeed = 0,
        pattern = "beam",
        unlockCondition = "episode_1",
        pairsWithBonus = "cooling_vents",
        upgradedName = "Plasma Cutter",
        damagePerLevel = 6,
        fireRatePerLevel = 0.15,
    },

    plasma_sprayer = {
        id = "plasma_sprayer",
        name = "Plasma Sprayer",
        description = "Cone spray. Dmg: 3x5",
        imagePath = "assets/images/tools/tool_plasma_sprayer",
        iconPath = "assets/images/tools/tool_plasma_sprayer",
        projectileImage = "assets/images/tools/tool_plasma_droplet",
        baseDamage = 3,
        fireRate = 1.5,
        projectileSpeed = 240,
        pattern = "cone",
        unlockCondition = "episode_1",
        pairsWithBonus = "fuel_injector",
        upgradedName = "Inferno Cannon",
        damagePerLevel = 1,
        fireRatePerLevel = 0.3,
        projectilesPerShot = 5,
        spreadAngle = 45,
    },

    micro_missile_pod = {
        id = "micro_missile_pod",
        name = "Micro-Missile Pod",
        description = "Burst fire. Dmg: 4x3",
        imagePath = "assets/images/tools/tool_micro_missile_pod",
        iconPath = "assets/images/tools/tool_micro_missile_pod",
        projectileImage = "assets/images/tools/tool_micro_missile",
        baseDamage = 4,
        fireRate = 0.6,
        projectileSpeed = 210,
        pattern = "burst",
        unlockCondition = "episode_2",
        pairsWithBonus = "guidance_module",
        upgradedName = "Cluster Launcher",
        damagePerLevel = 2,
        fireRatePerLevel = 0.15,
        projectilesPerShot = 3,
        spreadAngle = 15,
    },

    mapping_drone = {
        id = "mapping_drone",
        name = "Mapping Drone",
        description = "Homing missiles. Dmg: 18",
        imagePath = "assets/images/tools/tool_mapping_drone",
        iconPath = "assets/images/tools/tool_mapping_drone",
        projectileImage = "assets/images/tools/tool_mapping_drone_missile",
        baseDamage = 18,
        fireRate = 0.5,
        projectileSpeed = 120,
        pattern = "homing",
        unlockCondition = "episode_2",
        pairsWithBonus = "targeting_matrix",
        upgradedName = "Perihelion Strike",
        damagePerLevel = 9,
        fireRatePerLevel = 0.1,
    },

    cryo_projector = {
        id = "cryo_projector",
        name = "Cryo Projector",
        description = "Spread shot. Dmg: 4x3",
        imagePath = "assets/images/tools/tool_cryo_projector",
        iconPath = "assets/images/tools/tool_cryo_projector",
        projectileImage = "assets/images/tools/tool_cryo_shard",
        baseDamage = 4,
        fireRate = 1.0,
        projectileSpeed = 240,
        pattern = "spread",
        unlockCondition = "episode_2",
        pairsWithBonus = "frost_capacitor",
        upgradedName = "Absolute Zero",
        damagePerLevel = 2,
        fireRatePerLevel = 0.2,
        projectilesPerShot = 3,
        spreadAngle = 15,
    },

    modified_mapping_drone = {
        id = "modified_mapping_drone",
        name = "Modified Mapping Drone",
        description = "Targets strongest foe. Dmg: 18",
        imagePath = "assets/images/tools/tool_modified_mapping_drone",
        iconPath = "assets/images/tools/tool_mapping_drone",
        projectileImage = "assets/images/tools/tool_modified_drone_missile",
        baseDamage = 18,
        fireRate = 0.5,
        projectileSpeed = 120,
        pattern = "homing",
        unlockCondition = "episode_2",
        pairsWithBonus = "priority_scanner",
        upgradedName = "Executive Strike",
        damagePerLevel = 9,
        fireRatePerLevel = 0.1,
    },

    emp_burst = {
        id = "emp_burst",
        name = "EMP Burst",
        description = "360 burst. Dmg: 6x8",
        imagePath = "assets/images/tools/tool_emp_burst",
        iconPath = "assets/images/tools/tool_emp_burst",
        projectileImage = "assets/images/tools/tool_emp_pulse",
        baseDamage = 6,
        fireRate = 0.5,
        projectileSpeed = 240,
        pattern = "radial",
        unlockCondition = "episode_3",
        pairsWithBonus = "overcharger",
        upgradedName = "Ion Storm",
        damagePerLevel = 3,
        fireRatePerLevel = 0.1,
    },

    singularity_core = {
        id = "singularity_core",
        name = "Singularity Core",
        description = "Orbiting damage field. Dmg: 3/tick",
        imagePath = "assets/images/tools/tool_singularity_core",
        iconPath = "assets/images/tools/tool_singularity_core",
        projectileImage = "assets/images/tools/tool_singularity_orb",
        baseDamage = 3,
        fireRate = 0.2,
        projectileSpeed = 0,
        pattern = "orbital",
        unlockCondition = "episode_3",
        pairsWithBonus = "event_horizon",
        upgradedName = "Black Hole Generator",
        damagePerLevel = 1,
        fireRatePerLevel = 0.05,
    },

    tesla_coil = {
        id = "tesla_coil",
        name = "Tesla Coil",
        description = "Chain lightning. Dmg: 8 chain",
        imagePath = "assets/images/tools/tool_tesla_coil",
        iconPath = "assets/images/tools/tool_tesla_coil",
        projectileImage = "assets/images/tools/tool_lightning_bolt",
        baseDamage = 8,
        fireRate = 0.7,
        projectileSpeed = 350,
        pattern = "chain",
        unlockCondition = "episode_3",
        pairsWithBonus = "superconductor",
        upgradedName = "Arc Reactor",
        damagePerLevel = 4,
        fireRatePerLevel = 0.15,
    },

    phase_disruptor = {
        id = "phase_disruptor",
        name = "Phase Disruptor",
        description = "Piercing beam. Dmg: 15",
        imagePath = "assets/images/tools/tool_phase_disruptor",
        iconPath = "assets/images/tools/tool_phase_disruptor",
        projectileImage = "assets/images/tools/tool_phase_beam",
        baseDamage = 15,
        fireRate = 0.4,
        projectileSpeed = 450,
        pattern = "piercing",
        unlockCondition = "episode_4",
        pairsWithBonus = "phase_amplifier",
        upgradedName = "Dimensional Rift",
        damagePerLevel = 7,
        fireRatePerLevel = 0.1,
    },

    probe_launcher = {
        id = "probe_launcher",
        name = "Probe Launcher",
        description = "Homing probes. Dmg: 5",
        imagePath = "assets/images/tools/tool_probe_launcher",
        iconPath = "assets/images/tools/tool_probe_launcher",
        projectileImage = "assets/images/tools/tool_probe",
        baseDamage = 5,
        fireRate = 0.8,
        projectileSpeed = 180,
        pattern = "homing",
        unlockCondition = "episode_4",
        pairsWithBonus = "swarm_protocol",
        upgradedName = "Drone Swarm",
        damagePerLevel = 3,
        fireRatePerLevel = 0.2,
    },

    repulsor_field = {
        id = "repulsor_field",
        name = "Repulsor Field",
        description = "Pushes enemies away. No dmg",
        imagePath = "assets/images/tools/tool_repulsor_field",
        iconPath = "assets/images/tools/tool_repulsor_field",
        projectileImage = "assets/images/tools/tool_repulsor_wave",
        baseDamage = 0,
        fireRate = 0.6,
        projectileSpeed = 180,
        pattern = "push",
        unlockCondition = "episode_5",
        pairsWithBonus = "force_multiplier",
        upgradedName = "Gravity Reversal",
        rangePerLevel = 10,
    },
}

-- Get tools available at game start
function ToolsData.getStarterTools()
    local starters = {}
    for id, data in pairs(ToolsData) do
        if type(data) == "table" and data.unlockCondition == "start" then
            table.insert(starters, id)
        end
    end
    return starters
end

-- Get tool by ID
function ToolsData.get(id)
    return ToolsData[id]
end

-- Get tools unlocked by episode
function ToolsData.getUnlockedTools(episodeId)
    local unlocked = {}
    for id, data in pairs(ToolsData) do
        if type(data) == "table" and data.id then
            if data.unlockCondition == "start" then
                table.insert(unlocked, id)
            elseif data.unlockCondition then
                local reqEp = data.unlockCondition:match("episode_(%d+)")
                if reqEp and episodeId >= tonumber(reqEp) then
                    table.insert(unlocked, id)
                end
            end
        end
    end
    return unlocked
end

-- Calculate stats for a tool at a specific level (1-4)
function ToolsData.getStatsAtLevel(id, level)
    local data = ToolsData[id]
    if not data then return nil end

    level = math.max(1, math.min(4, level or 1))
    local levelBonus = level - 1

    return {
        damage = data.baseDamage + (data.damagePerLevel or 0) * levelBonus,
        fireRate = data.fireRate + (data.fireRatePerLevel or 0) * levelBonus,
        range = 100 + (data.rangePerLevel or 0) * levelBonus,
    }
end

return ToolsData
