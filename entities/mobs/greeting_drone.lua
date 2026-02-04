-- Greeting Drone MOB (Episode 1)
-- Small, fast ramming enemy that wants to "hug" your station

class('GreetingDrone').extends(MOB)

GreetingDrone.DATA = {
    id = "greeting_drone",
    name = "Greeting Drone",
    description = "Small, fast, eager to hug your station",
    imagePath = "assets/images/episodes/ep1/ep1_greeting_drone",

    -- Stats - faster than asteroids but less damage
    baseHealth = 5,
    baseSpeed = 36,     -- px/sec (was 1.2 px/frame at 30fps)
    baseDamage = 3,
    rpValue = 8,

    -- Collision
    width = 12,
    height = 12,
    range = 1,
    emits = false,  -- Ramming MOB
}

function GreetingDrone:init(x, y, waveMultipliers)
    GreetingDrone.super.init(self, x, y, GreetingDrone.DATA, waveMultipliers)
end

return GreetingDrone
