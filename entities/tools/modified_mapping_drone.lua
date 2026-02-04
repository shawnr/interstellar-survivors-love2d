-- Modified Mapping Drone Tool (Episode 2)
-- Homing missile that targets the highest-HP enemy, with limited lifetime

class('ModifiedMappingDrone').extends(Tool)

ModifiedMappingDrone.DATA = {
    id = "modified_mapping_drone",
    name = "Modified Mapping Drone",
    description = "Targets strongest foe. Dmg: 18",
    imagePath = "assets/images/tools/tool_modified_mapping_drone",
    projectileImage = "assets/images/tools/tool_modified_drone_missile",

    baseDamage = 18,
    fireRate = 0.5,
    projectileSpeed = 120,
    pattern = "homing",
}

function ModifiedMappingDrone:init()
    ModifiedMappingDrone.super.init(self, ModifiedMappingDrone.DATA)

    self.homingStrength = 200
    self.missileLifetime = 6  -- Seconds before missile despawns
end

function ModifiedMappingDrone:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    -- Find the highest-HP enemy
    local bestTarget = self:findHighestHPTarget()

    if GameplayScene and GameplayScene.projectilePool then
        local proj = GameplayScene.projectilePool:get(
            fireX, fireY, firingAngle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage
        )
        if proj then
            proj.homing = true
            proj.homingStrength = self.homingStrength
            proj.lifetime = self.missileLifetime
            if bestTarget then
                proj.homingTarget = bestTarget
            end
        end
    end

    if AudioManager then
        AudioManager:playSFX("tool_frequency_scanner", 0.3)
    end
end

-- Find the enemy with the highest current HP
function ModifiedMappingDrone:findHighestHPTarget()
    if not GameplayScene then return nil end

    local bestTarget = nil
    local bestHP = 0

    for _, mob in ipairs(GameplayScene.mobs) do
        if mob.active and mob.health > bestHP then
            bestHP = mob.health
            bestTarget = mob
        end
    end

    -- Also check boss
    if GameplayScene.boss and GameplayScene.boss.active then
        if GameplayScene.boss.health > bestHP then
            bestTarget = GameplayScene.boss
        end
    end

    return bestTarget
end

function ModifiedMappingDrone:recalculateStats()
    ModifiedMappingDrone.super.recalculateStats(self)

    if self.level >= 3 then
        self.homingStrength = 280
        self.missileLifetime = 8
    elseif self.level >= 2 then
        self.homingStrength = 240
        self.missileLifetime = 7
    end
end

return ModifiedMappingDrone
