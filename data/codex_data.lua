-- Codex Data
-- Encyclopedia entries for all discoverable content

CodexData = {
    -- Categories
    categories = {
        { id = "tools", name = "Tools" },
        { id = "mobs", name = "Creatures" },
        { id = "bosses", name = "Bosses" },
        { id = "episodes", name = "Episodes" },
    },

    -- Entries organized by category
    entries = {
        tools = {
            { id = "tool_rail_driver", name = "Rail Driver", description = "Standard kinetic launcher. Reliable and effective at breaking things apart." },
            { id = "tool_frequency_scanner", name = "Frequency Scanner", description = "Fires high-frequency beams. Fast projectiles, moderate damage." },
            { id = "tool_tractor_pulse", name = "Tractor Pulse", description = "Pulls collectibles toward the station. Essential for resource gathering." },
            { id = "tool_thermal_lance", name = "Thermal Lance", description = "Concentrated heat beam. Slow but devastating." },
            { id = "tool_plasma_sprayer", name = "Plasma Sprayer", description = "Cone of plasma droplets. Good for crowds." },
            { id = "tool_micro_missile_pod", name = "Micro-Missile Pod", description = "Fires a burst of small missiles in a tight spread." },
            { id = "tool_mapping_drone", name = "Mapping Drone", description = "Homing missiles that track the nearest enemy." },
            { id = "tool_cryo_projector", name = "Cryo Projector", description = "Spread of cryo shards. Covers a wide area." },
            { id = "tool_modified_mapping_drone", name = "Modified Mapping Drone", description = "Targets the strongest enemy. Someone improved the algorithm." },
            { id = "tool_emp_burst", name = "EMP Burst", description = "360-degree electromagnetic pulse. Hits everything nearby." },
            { id = "tool_singularity_core", name = "Singularity Core", description = "Creates orbiting projectiles. Persistent area denial." },
            { id = "tool_tesla_coil", name = "Tesla Coil", description = "Chain lightning. Jumps between enemies." },
            { id = "tool_phase_disruptor", name = "Phase Disruptor", description = "Piercing beam that passes through unlimited targets." },
            { id = "tool_probe_launcher", name = "Probe Launcher", description = "Multiple homing probes. Quantity over quality." },
            { id = "tool_repulsor_field", name = "Repulsor Field", description = "Pushes enemies away. No damage, pure crowd control." },
        },

        mobs = {
            { id = "mob_asteroid", name = "Asteroid", description = "Space rock. Comes in three sizes. Not actually hostile, just inconsiderate." },
            { id = "mob_greeting_drone", name = "Greeting Drone", description = "Enthusiastic spider-built drone. Greets you at ramming speed." },
            { id = "mob_silk_weaver", name = "Silk Weaver", description = "Orbiting spider platform. Fires sticky projectiles that slow rotation." },
            { id = "mob_survey_drone", name = "Survey Drone", description = "Corporate drone. Wants to evaluate your performance. Violently." },
            { id = "mob_efficiency_monitor", name = "Efficiency Monitor", description = "Slow corporate enforcer. Very durable. Very annoying." },
            { id = "mob_probability_fluctuation", name = "Probability Fluctuation", description = "Fast, fragile reality glitch. Exists because probability said so." },
            { id = "mob_paradox_node", name = "Paradox Node", description = "Slow, tanky impossibility. Should not exist, yet here it is." },
            { id = "mob_debris_chunk", name = "Debris Chunk", description = "Tumbling ancient wreckage. Still has some fight left in it." },
            { id = "mob_defense_turret", name = "Defense Turret", description = "Automated gun platform from a forgotten war. Still on duty." },
            { id = "mob_debate_drone", name = "Debate Drone", description = "Fast academic delegate. Physical collision is peer review." },
            { id = "mob_citation_platform", name = "Citation Platform", description = "Shares research aggressively via data beams." },
        },

        bosses = {
            { id = "boss_cultural_attache", name = "Cultural Attache", description = "Spider diplomatic vessel. Demands you appreciate their poetry. Or else." },
            { id = "boss_productivity_liaison", name = "Productivity Liaison", description = "Corporate consultant. Jams your weapons while questioning your metrics." },
            { id = "boss_improbability_engine", name = "Improbability Engine", description = "Reality-warping device. Scrambles your controls and spawns impossible things." },
            { id = "boss_chomper", name = "Chomper", description = "Very large. Very hungry. Charges at you repeatedly. Possibly lonely." },
            { id = "boss_distinguished_professor", name = "Distinguished Professor", description = "Academic authority. Lectures you with citation beams. Your research is 'merely obvious.'" },
        },

        episodes = {
            { id = "ep_1", name = "Ep 1: Spin Cycle", description = "Uplift spiders want to be friends. Aggressively." },
            { id = "ep_2", name = "Ep 2: Productivity Review", description = "Corporate consultants evaluate your efficiency. With explosions." },
            { id = "ep_3", name = "Ep 3: Whose Idea Was This?", description = "An Improbability Drive test went wrong. Reality is now optional." },
            { id = "ep_4", name = "Ep 4: Garbage Day", description = "Salvage mission in ancient debris. Something large lives here." },
            { id = "ep_5", name = "Ep 5: Academic Standards", description = "Interspecies research symposium. Peer review can be brutal." },
        },
    },
}

-- Get entries for a category
function CodexData.getEntries(categoryId)
    return CodexData.entries[categoryId] or {}
end

-- Get total entry count
function CodexData.getTotalCount()
    local count = 0
    for _, entries in pairs(CodexData.entries) do
        count = count + #entries
    end
    return count
end

-- Get discovered count
function CodexData.getDiscoveredCount()
    local count = 0
    for _, entries in pairs(CodexData.entries) do
        for _, entry in ipairs(entries) do
            if SaveManager:isDiscovered(entry.id) then
                count = count + 1
            end
        end
    end
    return count
end

return CodexData
