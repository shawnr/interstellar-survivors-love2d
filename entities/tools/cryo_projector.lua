-- Cryo Projector Tool (Episode 2)
-- Fires a spread of projectiles in a cone

class('CryoProjector').extends(Tool)

CryoProjector.DATA = {
    id = "cryo_projector",
    name = "Cryo Projector",
    description = "Spread shot. Dmg: 4x3",
    imagePath = "assets/images/tools/tool_cryo_projector",
    projectileImage = "assets/images/tools/tool_cryo_shard",

    baseDamage = 4,
    fireRate = 1.0,
    projectileSpeed = 240,
    pattern = "spread",
}

function CryoProjector:init()
    CryoProjector.super.init(self, CryoProjector.DATA)

    self.projectilesPerShot = 3
    self.spreadAngle = 15  -- Total spread angle in degrees
end

function CryoProjector:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    -- Fire projectiles in a spread
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

    if AudioManager then
        AudioManager:playSFX("tool_cryo_projector", 0.4)
    end
end

function CryoProjector:recalculateStats()
    CryoProjector.super.recalculateStats(self)

    if self.level >= 3 then
        self.projectilesPerShot = 5
        self.spreadAngle = 20
    elseif self.level >= 2 then
        self.projectilesPerShot = 4
        self.spreadAngle = 18
    end
end

return CryoProjector
