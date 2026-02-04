-- Improbability Engine Boss (Episode 3)
-- Reality-warping entity that scrambles controls and spawns probability mobs

class('ImprobabilityEngine').extends(MOB)

ImprobabilityEngine.DATA = {
    id = "improbability_engine",
    name = "Improbability Engine",
    description = "Reality is more of a suggestion",
    imagePath = "assets/images/episodes/ep3/ep3_boss_improbability_engine",

    -- Boss stats
    baseHealth = 400,
    baseSpeed = 22,
    baseDamage = 6,
    rpValue = 120,

    -- Collision
    width = 48,
    height = 48,
    range = 90,
    emits = true,
}

-- Boss phases
ImprobabilityEngine.PHASES = {
    APPROACH = 1,            -- Moving into position
    PROBABILITY_STORM = 2,   -- Spawns ProbabilityFluctuations
    REALITY_WARP = 3,        -- Control inversion debuff
    PARADOX = 4,             -- Spawns ParadoxNodes
    ENRAGED = 5,             -- Below 30% HP - teleports, rapid attacks
}

function ImprobabilityEngine:init(x, y)
    ImprobabilityEngine.super.init(self, x, y, ImprobabilityEngine.DATA, { health = 1, damage = 1, speed = 1 })

    self.phase = ImprobabilityEngine.PHASES.APPROACH
    self.phaseTimer = 0
    self.attackTimer = 0
    self.mobsSpawned = 0
    self.maxMobsPerPhase = 3

    self.orbitAngle = math.atan2(y - Constants.STATION_CENTER_Y, x - Constants.STATION_CENTER_X)
    self.teleportCooldown = 0

    print("Improbability Engine boss spawned!")
end

function ImprobabilityEngine:update(dt)
    if not self.active then return end

    if GameplayScene and (GameplayScene.isPaused or GameplayScene.isLevelingUp) then
        return
    end

    if self.showHealthBar then
        self.healthBarTimer = self.healthBarTimer - dt
        if self.healthBarTimer <= 0 then
            self.showHealthBar = false
        end
    end

    self.phaseTimer = self.phaseTimer + dt
    self.attackTimer = self.attackTimer + dt

    if self.teleportCooldown > 0 then
        self.teleportCooldown = self.teleportCooldown - dt
    end

    -- Check for enraged phase
    if self.health / self.maxHealth <= 0.3 and self.phase ~= ImprobabilityEngine.PHASES.ENRAGED then
        self:enterPhase(ImprobabilityEngine.PHASES.ENRAGED)
    end

    if self.phase == ImprobabilityEngine.PHASES.APPROACH then
        self:updateApproach(dt)
    elseif self.phase == ImprobabilityEngine.PHASES.PROBABILITY_STORM then
        self:updateProbabilityStorm(dt)
    elseif self.phase == ImprobabilityEngine.PHASES.REALITY_WARP then
        self:updateRealityWarp(dt)
    elseif self.phase == ImprobabilityEngine.PHASES.PARADOX then
        self:updateParadox(dt)
    elseif self.phase == ImprobabilityEngine.PHASES.ENRAGED then
        self:updateEnraged(dt)
    end
end

function ImprobabilityEngine:enterPhase(newPhase)
    self.phase = newPhase
    self.phaseTimer = 0
    self.attackTimer = 0

    if newPhase == ImprobabilityEngine.PHASES.PROBABILITY_STORM then
        self.mobsSpawned = 0
        print("Improbability Engine: Probability storm!")
    elseif newPhase == ImprobabilityEngine.PHASES.REALITY_WARP then
        print("Improbability Engine: Reality warp!")
    elseif newPhase == ImprobabilityEngine.PHASES.PARADOX then
        self.mobsSpawned = 0
        print("Improbability Engine: Paradox phase!")
    elseif newPhase == ImprobabilityEngine.PHASES.ENRAGED then
        print("Improbability Engine: REALITY COLLAPSE! ENRAGED!")
        self.speed = self.speed * 1.5
    end
end

function ImprobabilityEngine:updateApproach(dt)
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > self.range then
        local moveX = (dx / dist) * self.speed * dt
        local moveY = (dy / dist) * self.speed * dt
        self.x = self.x + moveX
        self.y = self.y + moveY
    else
        self:enterPhase(ImprobabilityEngine.PHASES.PROBABILITY_STORM)
    end

    local angle = Utils.vectorToAngle(dx, dy)
    self:setRotation(angle)
end

function ImprobabilityEngine:updateProbabilityStorm(dt)
    self:orbitStation(dt)

    if self.attackTimer >= 1.5 and self.mobsSpawned < self.maxMobsPerPhase then
        self:spawnMob("ProbabilityFluctuation")
        self.attackTimer = 0
        self.mobsSpawned = self.mobsSpawned + 1
    end

    if self.mobsSpawned >= self.maxMobsPerPhase and self.phaseTimer >= 5 then
        self:enterPhase(ImprobabilityEngine.PHASES.REALITY_WARP)
    end
end

function ImprobabilityEngine:updateRealityWarp(dt)
    self:orbitStation(dt)

    -- Apply control inversion at start of phase
    if self.phaseTimer >= 0.5 and self.phaseTimer - dt < 0.5 then
        self:applyControlInversion()
    end

    -- End phase after duration
    if self.phaseTimer >= 4 then
        self:enterPhase(ImprobabilityEngine.PHASES.PARADOX)
    end
end

function ImprobabilityEngine:updateParadox(dt)
    self:orbitStation(dt)

    if self.attackTimer >= 2.0 and self.mobsSpawned < 2 then
        self:spawnMob("ParadoxNode")
        self.attackTimer = 0
        self.mobsSpawned = self.mobsSpawned + 1
    end

    if self.mobsSpawned >= 2 and self.phaseTimer >= 5 then
        self:enterPhase(ImprobabilityEngine.PHASES.PROBABILITY_STORM)
    end
end

function ImprobabilityEngine:updateEnraged(dt)
    self:orbitStation(dt, 1.5)

    -- Teleport randomly
    if self.teleportCooldown <= 0 and math.random() < 0.01 then
        self:teleport()
        self.teleportCooldown = 3.0
    end

    -- Rapid attacks
    if self.attackTimer >= 0.7 then
        local roll = math.random()
        if roll < 0.4 then
            self:spawnMob("ProbabilityFluctuation")
        elseif roll < 0.7 then
            self:applyControlInversion()
        else
            self:spawnMob("ParadoxNode")
        end
        self.attackTimer = 0
    end
end

function ImprobabilityEngine:orbitStation(dt, speedMult)
    speedMult = speedMult or 1.0

    local orbitSpeed = self.speed * speedMult * 0.015 * dt
    self.orbitAngle = self.orbitAngle + orbitSpeed

    self.x = self.targetX + math.cos(self.orbitAngle) * self.range
    self.y = self.targetY + math.sin(self.orbitAngle) * self.range

    local faceAngle = Utils.vectorToAngle(self.targetX - self.x, self.targetY - self.y)
    self:setRotation(faceAngle)
end

function ImprobabilityEngine:teleport()
    -- Teleport to a random position at orbit range
    self.orbitAngle = math.random() * math.pi * 2
    self.x = self.targetX + math.cos(self.orbitAngle) * self.range
    self.y = self.targetY + math.sin(self.orbitAngle) * self.range

    -- Visual effect
    if VFXManager then
        VFXManager:addDeathEffect(self.x, self.y, 12)
    end

    print("Improbability Engine teleported!")
end

function ImprobabilityEngine:spawnMob(className)
    if not GameplayScene then return end

    local offsetAngle = math.random() * math.pi * 2
    local spawnX = self.x + math.cos(offsetAngle) * 30
    local spawnY = self.y + math.sin(offsetAngle) * 30

    local mob
    if className == "ProbabilityFluctuation" then
        mob = ProbabilityFluctuation(spawnX, spawnY, { health = 1, damage = 1, speed = 1 })
    elseif className == "ParadoxNode" then
        mob = ParadoxNode(spawnX, spawnY, { health = 1, damage = 1, speed = 1 })
    end

    if mob then
        table.insert(GameplayScene.mobs, mob)
    end

    if AudioManager then
        AudioManager:playSFX("mob_spawn", 0.4)
    end
end

function ImprobabilityEngine:applyControlInversion()
    if GameplayScene and GameplayScene.applyControlInversion then
        GameplayScene:applyControlInversion()
    end
end

function ImprobabilityEngine:onDestroyed()
    if VFXManager then
        VFXManager:addDeathEffect(self.x, self.y, self:getRadius())
    end

    self.active = false

    if GameManager then
        GameManager:awardRP(self.rpValue)
    end

    if GameplayScene and GameplayScene.collectiblePool then
        for i = 1, 10 do
            local angle = (i / 10) * math.pi * 2
            local dist = 20 + math.random(20)
            local cx = self.x + math.cos(angle) * dist
            local cy = self.y + math.sin(angle) * dist
            GameplayScene.collectiblePool:get(cx, cy, Collectible.TYPES.RP, 12)
        end
    end

    if AudioManager then
        AudioManager:playSFX("mob_death_large", 1.0)
    end

    print("Improbability Engine defeated!")

    if VFXManager then
        VFXManager:startDefeatCelebration(function()
            if GameManager then
                GameManager:onBossDefeated()
            end
        end)
    else
        if GameManager then
            GameManager:onBossDefeated()
        end
    end
end

function ImprobabilityEngine:getRadius()
    return 24
end

function ImprobabilityEngine:drawHealthBar()
    if not self.active then return end

    local barWidth = 140
    local barHeight = 14
    local barX = 8
    local barY = Constants.SCREEN_HEIGHT - 36

    local healthPercent = self.health / self.maxHealth

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barWidth + 2, barHeight + 2)

    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth * healthPercent, barHeight)

    love.graphics.setColor(1, 1, 1)
    local bossName = "ENGINE"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(bossName)
    love.graphics.print(bossName, barX + barWidth / 2 - textWidth / 2, barY + 1)
end

return ImprobabilityEngine
