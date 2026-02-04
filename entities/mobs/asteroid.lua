-- Asteroid MOB
-- Basic ramming enemy that moves toward the station

class('Asteroid').extends(MOB)

-- Asteroid data
Asteroid.DATA = {
    id = "asteroid",
    name = "Asteroid",
    description = "Common space debris that threatens the station by ramming",
    imagePath = "assets/images/shared/asteroid",

    -- Base stats (easiest enemy)
    baseHealth = 3,
    baseSpeed = 30,    -- px/sec (was 0.5 px/frame at 30fps = 15, but let's make faster)
    baseDamage = 5,
    rpValue = 5,

    -- Collision
    width = 16,
    height = 16,
    range = 1,
    emits = false,  -- Ramming, not shooting

    -- Levels (asteroids have 3 size levels)
    levels = 3,
}

function Asteroid:init(x, y, waveMultipliers, level)
    -- Adjust stats based on level
    level = level or 1
    local data = table.deepcopy(Asteroid.DATA)

    -- Scale stats by level
    if level == 2 then
        data.baseHealth = data.baseHealth * 1.5
        data.baseDamage = data.baseDamage * 1.3
        data.rpValue = data.rpValue * 1.5
        data.width = 20
        data.height = 20
    elseif level == 3 then
        data.baseHealth = data.baseHealth * 2.5
        data.baseDamage = data.baseDamage * 1.8
        data.rpValue = data.rpValue * 2.5
        data.width = 24
        data.height = 24
    end

    self.level = level

    -- Call parent init
    Asteroid.super.init(self, x, y, data, waveMultipliers)
end

return Asteroid
