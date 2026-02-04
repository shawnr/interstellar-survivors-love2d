-- Mapping Drone Tool
-- Fires homing projectiles that track the nearest enemy

class('MappingDrone').extends(Tool)

MappingDrone.DATA = {
    id = "mapping_drone",
    name = "Mapping Drone",
    description = "Homing missiles. Dmg: 18",
    imagePath = "assets/images/tools/tool_mapping_drone",
    projectileImage = "assets/images/tools/tool_mapping_drone_missile",

    baseDamage = 18,
    fireRate = 0.5,
    projectileSpeed = 120,
    pattern = "homing",
}

function MappingDrone:init()
    MappingDrone.super.init(self, MappingDrone.DATA)

    self.homingStrength = 180  -- Degrees per second turn rate
end

function MappingDrone:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    if GameplayScene and GameplayScene.projectilePool then
        local proj = GameplayScene.projectilePool:get(
            fireX, fireY, firingAngle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage
        )
        if proj then
            -- Enable homing
            proj.homing = true
            proj.homingStrength = self.homingStrength
        end
    end

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_frequency_scanner", 0.3)
    end
end

-- Override recalculate to also scale homing strength
function MappingDrone:recalculateStats()
    MappingDrone.super.recalculateStats(self)

    -- Increase homing strength with level
    if self.level >= 3 then
        self.homingStrength = 270
    elseif self.level >= 2 then
        self.homingStrength = 220
    end
end

return MappingDrone
