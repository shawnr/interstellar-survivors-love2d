-- Thermal Lance Tool
-- Fires a piercing heat beam that passes through enemies

class('ThermalLance').extends(Tool)

ThermalLance.DATA = {
    id = "thermal_lance",
    name = "Thermal Lance",
    description = "Heat beam. Dmg: 12",
    imagePath = "assets/images/tools/tool_thermal_lance",
    projectileImage = "assets/images/tools/tool_thermal_beam",

    baseDamage = 12,
    fireRate = 0.6,
    projectileSpeed = 600,  -- Very fast (beam-like)
    pattern = "beam",
}

function ThermalLance:init()
    ThermalLance.super.init(self, ThermalLance.DATA)

    self.beamLength = 150
    self.piercing = true
    self.maxHits = 2  -- Pierces through 2 enemies
end

function ThermalLance:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Create piercing beam projectile
    if GameplayScene and GameplayScene.projectilePool then
        local proj = GameplayScene.projectilePool:get(
            fireX, fireY, firingAngle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage,
            true  -- piercing
        )
        if proj then
            proj.maxHits = self.maxHits
        end
    end

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_thermal_lance", 0.4)
    end
end

-- Override recalculate to also scale beam properties
function ThermalLance:recalculateStats()
    ThermalLance.super.recalculateStats(self)

    -- Scale pierce count with level
    if self.level >= 3 then
        self.maxHits = 4
    elseif self.level >= 2 then
        self.maxHits = 3
    end
end

return ThermalLance
