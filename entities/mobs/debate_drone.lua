-- Debate Drone MOB (Episode 5)
-- Fast, weak swarm mob representing alien delegates

class('DebateDrone').extends(MOB)

DebateDrone.DATA = {
    id = "debate_drone",
    name = "Debate Drone",
    description = "Physical collision is peer review",
    imagePath = "assets/images/episodes/ep5/ep5_debate_drone",

    -- Stats - fast and weak
    baseHealth = 5,
    baseSpeed = 36,
    baseDamage = 3,
    rpValue = 8,

    -- Collision
    width = 14,
    height = 14,
    range = 1,
    emits = false,
}

function DebateDrone:init(x, y, waveMultipliers)
    DebateDrone.super.init(self, x, y, DebateDrone.DATA, waveMultipliers)
end

return DebateDrone
