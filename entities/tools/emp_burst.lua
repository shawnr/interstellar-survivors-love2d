-- EMP Burst Tool (Episode 3)
-- Fires projectiles in all directions (360 degree radial burst)

class('EMPBurst').extends(Tool)

EMPBurst.DATA = {
    id = "emp_burst",
    name = "EMP Burst",
    description = "360 burst. Dmg: 6x8",
    imagePath = "assets/images/tools/tool_emp_burst",
    projectileImage = "assets/images/tools/tool_emp_pulse",

    baseDamage = 6,
    fireRate = 0.5,
    projectileSpeed = 240,
    pattern = "radial",
}

function EMPBurst:init()
    EMPBurst.super.init(self, EMPBurst.DATA)

    self.projectilesPerShot = 8
end

function EMPBurst:fire()
    local offsetDist = 12

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    -- Fire projectiles in 360 degrees
    local angleStep = 360 / self.projectilesPerShot

    for i = 0, self.projectilesPerShot - 1 do
        local angle = angleStep * i
        local dx, dy = Utils.angleToVector(angle)
        local fireX = self.x + dx * offsetDist
        local fireY = self.y + dy * offsetDist

        if GameplayScene and GameplayScene.projectilePool then
            GameplayScene.projectilePool:get(
                fireX, fireY, angle,
                self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
                self.damage,
                self.data.projectileImage
            )
        end
    end

    -- Visual pulse
    if GameplayScene and GameplayScene.createPulseEffect then
        GameplayScene:createPulseEffect(self.x, self.y, 30, 0.2)
    end

    if AudioManager then
        AudioManager:playSFX("tool_emp_burst", 0.5)
    end
end

function EMPBurst:recalculateStats()
    EMPBurst.super.recalculateStats(self)

    if self.level >= 3 then
        self.projectilesPerShot = 12
    elseif self.level >= 2 then
        self.projectilesPerShot = 10
    end
end

-- Evolution: Ion Storm — 15 dmg, radius x2 (more projectiles)
function EMPBurst:evolve()
    EMPBurst.super.evolve(self)
    self.damage = 15
    self.projectilesPerShot = 16
    if GrantsSystem then
        self.damage = self.damage * GrantsSystem:getDamageMultiplier()
    end
end

return EMPBurst
