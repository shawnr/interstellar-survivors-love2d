-- Rail Driver Tool
-- Basic kinetic launcher that fires straight projectiles

class('RailDriver').extends(Tool)

-- Rail Driver data
RailDriver.DATA = {
    id = "rail_driver",
    name = "Rail Driver",
    description = "Kinetic launcher for breaking asteroids",
    imagePath = "assets/images/tools/tool_rail_driver",
    projectileImage = "assets/images/tools/tool_rail_driver_projectile",

    -- Base stats
    baseDamage = 3,
    fireRate = 1.5,        -- 1.5 shots per second
    projectileSpeed = 240, -- px/sec (was 8 px/frame at 30fps)
    pattern = "straight",
}

function RailDriver:init()
    RailDriver.super.init(self, RailDriver.DATA)

    -- Rail Driver specific properties
    self.piercing = false
end

-- Override createProjectile to pass the piercing parameter
function RailDriver:createProjectile(x, y, angle)
    if GameplayScene and GameplayScene.projectilePool then
        local projectile = GameplayScene.projectilePool:get(
            x, y, angle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage,
            self.piercing
        )
        return projectile
    end
end

-- Override fire to play sound
function RailDriver:fire()
    -- Call parent fire
    RailDriver.super.fire(self)

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_rail_driver", 0.4)
    end
end

return RailDriver
