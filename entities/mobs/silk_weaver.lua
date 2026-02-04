-- Silk Weaver MOB (Episode 1)
-- Hovers at range and fires sticky webbing that slows rotation

class('SilkWeaver').extends(MOB)

SilkWeaver.DATA = {
    id = "silk_weaver",
    name = "Silk Weaver",
    description = "Fires sticky webbing that slows rotation",
    imagePath = "assets/images/episodes/ep1/ep1_silk_weaver",
    projectileImage = "assets/images/episodes/ep1/ep1_silk_projectile",

    -- Stats - hovers at range
    baseHealth = 12,
    baseSpeed = 18,     -- px/sec
    baseDamage = 2,
    rpValue = 15,

    -- Collision
    width = 20,
    height = 20,
    range = 80,
    emits = true,   -- Shooting MOB

    -- Attack properties (used by MOB base class)
    fireRate = 0.5,
    projectileSpeed = 90,
    projectileEffect = "slow",
}

function SilkWeaver:init(x, y, waveMultipliers)
    SilkWeaver.super.init(self, x, y, SilkWeaver.DATA, waveMultipliers)
end

return SilkWeaver
