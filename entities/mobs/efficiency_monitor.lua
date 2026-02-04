-- Efficiency Monitor MOB (Episode 2)
-- Slow but tanky drone that evaluates your performance

class('EfficiencyMonitor').extends(MOB)

EfficiencyMonitor.DATA = {
    id = "efficiency_monitor",
    name = "Efficiency Monitor",
    description = "Slow, tanky evaluator drone",
    imagePath = "assets/images/episodes/ep2/ep2_efficiency_monitor",

    -- Stats - slow but tough
    baseHealth = 15,
    baseSpeed = 18,     -- px/sec
    baseDamage = 8,
    rpValue = 20,

    -- Collision
    width = 18,
    height = 18,
    range = 1,
    emits = false,  -- Ramming MOB
}

function EfficiencyMonitor:init(x, y, waveMultipliers)
    EfficiencyMonitor.super.init(self, x, y, EfficiencyMonitor.DATA, waveMultipliers)
end

return EfficiencyMonitor
