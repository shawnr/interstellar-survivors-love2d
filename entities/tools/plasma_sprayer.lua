-- Plasma Sprayer Tool
-- Fires multiple short-range plasma droplets in a cone pattern

class('PlasmaSprayer').extends(Tool)

PlasmaSprayer.DATA = {
    id = "plasma_sprayer",
    name = "Plasma Sprayer",
    description = "Cone spray. Dmg: 3x5",
    imagePath = "assets/images/tools/tool_plasma_sprayer",
    projectileImage = "assets/images/tools/tool_plasma_droplet",

    baseDamage = 3,
    fireRate = 1.5,
    projectileSpeed = 240,
    pattern = "cone",
}

function PlasmaSprayer:init()
    PlasmaSprayer.super.init(self, PlasmaSprayer.DATA)

    self.projectilesPerShot = 5
    self.spreadAngle = 45  -- Total cone angle in degrees
    self.maxRange = 80     -- Short range
end

function PlasmaSprayer:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Fire multiple projectiles in a cone
    local halfSpread = self.spreadAngle / 2
    local angleStep = self.spreadAngle / (self.projectilesPerShot - 1)

    for i = 0, self.projectilesPerShot - 1 do
        local angle = firingAngle - halfSpread + (angleStep * i)
        -- Add slight randomness
        angle = angle + (math.random() - 0.5) * 5

        if GameplayScene and GameplayScene.projectilePool then
            local proj = GameplayScene.projectilePool:get(
                fireX, fireY, angle,
                self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
                self.damage,
                self.data.projectileImage
            )
            if proj then
                proj.maxTravelDist = self.maxRange
            end
        end
    end

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_rail_driver", 0.3)
    end
end

-- Override recalculate to also scale cone properties
function PlasmaSprayer:recalculateStats()
    PlasmaSprayer.super.recalculateStats(self)

    -- Scale cone with level
    if self.level >= 3 then
        self.projectilesPerShot = 7
        self.spreadAngle = 60
        self.maxRange = 100
    elseif self.level >= 2 then
        self.projectilesPerShot = 6
        self.spreadAngle = 50
        self.maxRange = 90
    end
end

return PlasmaSprayer
