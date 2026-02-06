-- Repulsor Field Tool (Episode 5)
-- Pushes enemies away from the station. No damage, defensive utility.

class('RepulsorField').extends(Tool)

RepulsorField.DATA = {
    id = "repulsor_field",
    name = "Repulsor Field",
    description = "Pushes enemies away. No dmg",
    imagePath = "assets/images/tools/tool_repulsor_field",
    projectileImage = "assets/images/tools/tool_repulsor_wave",

    baseDamage = 0,
    fireRate = 0.6,
    projectileSpeed = 180,
    pattern = "push",
}

function RepulsorField:init()
    RepulsorField.super.init(self, RepulsorField.DATA)

    self.pushRange = 50         -- How far the push reaches
    self.pushForce = 180        -- Push speed in px/sec
    self.visualProjectiles = 8  -- Number of visual-only projectiles
end

function RepulsorField:fire()
    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    -- Push enemies away
    self:pushEnemies()

    -- Spawn visual-only projectiles in 360 degrees for aesthetics
    if GameplayScene and GameplayScene.projectilePool then
        local angleStep = 360 / self.visualProjectiles
        for i = 0, self.visualProjectiles - 1 do
            local angle = angleStep * i
            local dx, dy = Utils.angleToVector(angle)
            local fireX = self.x + dx * 8
            local fireY = self.y + dy * 8

            local proj = GameplayScene.projectilePool:get(
                fireX, fireY, angle,
                self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
                0,  -- No damage
                self.data.projectileImage
            )
            if proj then
                proj.maxTravelDist = self.pushRange + 10
            end
        end
    end

    -- Visual pulse effect
    if GameplayScene and GameplayScene.createPulseEffect then
        GameplayScene:createPulseEffect(
            Constants.STATION_CENTER_X,
            Constants.STATION_CENTER_Y,
            self.pushRange,
            0.3
        )
    end

    if AudioManager then
        AudioManager:playSFX("tool_repulsor_field", 0.5)
    end
end

function RepulsorField:pushEnemies()
    if not GameplayScene then return end

    local centerX = Constants.STATION_CENTER_X
    local centerY = Constants.STATION_CENTER_Y
    local maxRange = self.pushRange
    local force = self.pushForce
    local dt = 1 / 60  -- Approximate frame time for impulse

    -- Push mobs
    for _, mob in ipairs(GameplayScene.mobs) do
        if mob.active then
            local dx = mob.x - centerX
            local dy = mob.y - centerY
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist < maxRange and dist > 5 then
                local pushStrength = force * (1 - dist / maxRange) * dt
                local pushX = (dx / dist) * pushStrength
                local pushY = (dy / dist) * pushStrength
                mob.x = mob.x + pushX
                mob.y = mob.y + pushY
            end
        end
    end

    -- Push boss too
    if GameplayScene.boss and GameplayScene.boss.active then
        local dx = GameplayScene.boss.x - centerX
        local dy = GameplayScene.boss.y - centerY
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < maxRange and dist > 5 then
            -- Boss gets pushed less
            local pushStrength = force * 0.3 * (1 - dist / maxRange) * dt
            local pushX = (dx / dist) * pushStrength
            local pushY = (dy / dist) * pushStrength
            GameplayScene.boss.x = GameplayScene.boss.x + pushX
            GameplayScene.boss.y = GameplayScene.boss.y + pushY
        end
    end
end

function RepulsorField:recalculateStats()
    RepulsorField.super.recalculateStats(self)

    if self.level >= 3 then
        self.pushRange = 80
        self.pushForce = 240
        self.visualProjectiles = 12
    elseif self.level >= 2 then
        self.pushRange = 65
        self.pushForce = 210
        self.visualProjectiles = 10
    end
end

-- Evolution: Shockwave Generator — push x3, radius x2, adds collision damage
function RepulsorField:evolve()
    RepulsorField.super.evolve(self)
    self.pushRange = self.pushRange * 2
    self.pushForce = self.pushForce * 3
    self.collisionDamage = 5
    self.visualProjectiles = 16
end

return RepulsorField
