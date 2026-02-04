-- Defense Turret MOB (Episode 4)
-- Ancient automated gun platform that orbits and fires

class('DefenseTurret').extends(MOB)

DefenseTurret.DATA = {
    id = "defense_turret",
    name = "Defense Turret",
    description = "Ancient automated defense system",
    imagePath = "assets/images/episodes/ep4/ep4_defense_turret",
    projectileImage = "assets/images/episodes/ep4/ep4_turret_projectile",

    -- Stats - slow, tough, ranged
    baseHealth = 20,
    baseSpeed = 9,
    baseDamage = 6,
    rpValue = 20,

    -- Collision
    width = 20,
    height = 20,
    range = 100,
    emits = true,

    -- Attack properties (used by MOB base class)
    fireRate = 0.6,
    projectileSpeed = 120,
}

function DefenseTurret:init(x, y, waveMultipliers)
    DefenseTurret.super.init(self, x, y, DefenseTurret.DATA, waveMultipliers)
end

return DefenseTurret
