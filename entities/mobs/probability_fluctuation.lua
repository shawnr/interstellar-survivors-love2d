-- Probability Fluctuation MOB (Episode 3)
-- Fast, fragile manifestation of improbability

class('ProbabilityFluctuation').extends(MOB)

ProbabilityFluctuation.DATA = {
    id = "probability_fluctuation",
    name = "Probability Fluctuation",
    description = "Fast, unstable probability manifestation",
    imagePath = "assets/images/episodes/ep3/ep3_probability_fluctuation",

    -- Stats - fast and fragile
    baseHealth = 7,
    baseSpeed = 33,
    baseDamage = 5,
    rpValue = 12,

    -- Collision
    width = 14,
    height = 14,
    range = 1,
    emits = false,
}

function ProbabilityFluctuation:init(x, y, waveMultipliers)
    ProbabilityFluctuation.super.init(self, x, y, ProbabilityFluctuation.DATA, waveMultipliers)
end

return ProbabilityFluctuation
