-- Micro-Missile Pod Tool
-- Fires 3 projectiles in a tight burst spread

class('MicroMissilePod').extends(Tool)

MicroMissilePod.DATA = {
    id = "micro_missile_pod",
    name = "Micro-Missile Pod",
    description = "Burst fire. Dmg: 4x3",
    imagePath = "assets/images/tools/tool_micro_missile_pod",
    projectileImage = "assets/images/tools/tool_micro_missile",

    baseDamage = 4,
    fireRate = 0.6,
    projectileSpeed = 210,
    pattern = "burst",
}

function MicroMissilePod:init()
    MicroMissilePod.super.init(self, MicroMissilePod.DATA)

    self.projectilesPerShot = 3
    self.spreadAngle = 15  -- Total spread angle in degrees
end

function MicroMissilePod:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    -- Fire projectiles in a tight burst spread
    local halfSpread = self.spreadAngle / 2
    local angleStep = self.spreadAngle / (self.projectilesPerShot - 1)

    for i = 0, self.projectilesPerShot - 1 do
        local angle = firingAngle - halfSpread + (angleStep * i)

        if GameplayScene and GameplayScene.projectilePool then
            GameplayScene.projectilePool:get(
                fireX, fireY, angle,
                self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
                self.damage,
                self.data.projectileImage
            )
        end
    end

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_micro_missile_pod", 0.4)
    end
end

-- Override recalculate to also scale burst properties
function MicroMissilePod:recalculateStats()
    MicroMissilePod.super.recalculateStats(self)

    -- Scale burst with level
    if self.level >= 3 then
        self.projectilesPerShot = 5
        self.spreadAngle = 25
    elseif self.level >= 2 then
        self.projectilesPerShot = 4
        self.spreadAngle = 20
    end
end

-- Evolution: Swarm Launcher — 8 dmg, +2 missiles per burst
function MicroMissilePod:evolve()
    MicroMissilePod.super.evolve(self)
    self.damage = 8
    self.projectilesPerShot = self.projectilesPerShot + 2
    self.spreadAngle = 30
    if GrantsSystem then
        self.damage = self.damage * GrantsSystem:getDamageMultiplier()
    end
end

return MicroMissilePod
