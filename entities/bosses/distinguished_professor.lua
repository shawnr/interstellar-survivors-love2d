-- Distinguished Professor Boss (Episode 5)
-- Academic authority that fires citation beams and summons debate drones

class('DistinguishedProfessor').extends(MOB)

DistinguishedProfessor.DATA = {
    id = "distinguished_professor",
    name = "Distinguished Professor",
    description = "Your research is 'merely obvious'",
    imagePath = "assets/images/episodes/ep5/ep5_boss_distinguished_professor",
    projectileImage = "assets/images/episodes/ep5/ep5_citation_beam",

    -- Boss stats
    baseHealth = 600,
    baseSpeed = 20,
    baseDamage = 8,
    rpValue = 200,

    -- Collision
    width = 48,
    height = 48,
    range = 100,
    emits = true,

    -- Projectile firing (used by boss custom logic, not base class)
    fireRate = 0.8,
    projectileSpeed = 130,
}

-- Boss phases
DistinguishedProfessor.PHASES = {
    APPROACH = 1,       -- Moving into position
    LECTURING = 2,      -- Fires citation beams at station
    SUMMONING = 3,      -- Spawns DebateDrones
    ENRAGED = 4,        -- Below 30% HP - rapid fire 3 beams
}

function DistinguishedProfessor:init(x, y)
    DistinguishedProfessor.super.init(self, x, y, DistinguishedProfessor.DATA, { health = 1, damage = 1, speed = 1 })

    self.phase = DistinguishedProfessor.PHASES.APPROACH
    self.phaseTimer = 0
    self.attackTimer = 0
    self.dronesSpawned = 0
    self.maxDronesPerWave = 4
    self.beamsFired = 0
    self.maxBeamsPerLecture = 5

    -- Firing cooldown for beams
    self.beamCooldown = 0
    self.beamInterval = 1 / DistinguishedProfessor.DATA.fireRate

    self.orbitAngle = math.atan2(y - Constants.STATION_CENTER_Y, x - Constants.STATION_CENTER_X)

    print("Distinguished Professor boss spawned!")
end

function DistinguishedProfessor:update(dt)
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

    if self.beamCooldown > 0 then
        self.beamCooldown = self.beamCooldown - dt
    end

    -- Check for enraged phase
    if self.health / self.maxHealth <= 0.3 and self.phase ~= DistinguishedProfessor.PHASES.ENRAGED then
        self:enterPhase(DistinguishedProfessor.PHASES.ENRAGED)
    end

    if self.phase == DistinguishedProfessor.PHASES.APPROACH then
        self:updateApproach(dt)
    elseif self.phase == DistinguishedProfessor.PHASES.LECTURING then
        self:updateLecturing(dt)
    elseif self.phase == DistinguishedProfessor.PHASES.SUMMONING then
        self:updateSummoning(dt)
    elseif self.phase == DistinguishedProfessor.PHASES.ENRAGED then
        self:updateEnraged(dt)
    end
end

function DistinguishedProfessor:enterPhase(newPhase)
    self.phase = newPhase
    self.phaseTimer = 0
    self.attackTimer = 0

    if newPhase == DistinguishedProfessor.PHASES.LECTURING then
        self.beamsFired = 0
        print("Distinguished Professor: Beginning lecture!")
    elseif newPhase == DistinguishedProfessor.PHASES.SUMMONING then
        self.dronesSpawned = 0
        print("Distinguished Professor: Summoning the delegation!")
    elseif newPhase == DistinguishedProfessor.PHASES.ENRAGED then
        print("Distinguished Professor: YOUR METHODOLOGY IS FLAWED! ENRAGED!")
        self.speed = self.speed * 1.4
        self.beamInterval = self.beamInterval * 0.5  -- Fire twice as fast
    end
end

function DistinguishedProfessor:updateApproach(dt)
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > self.range then
        local moveX = (dx / dist) * self.speed * dt
        local moveY = (dy / dist) * self.speed * dt
        self.x = self.x + moveX
        self.y = self.y + moveY
    else
        self:enterPhase(DistinguishedProfessor.PHASES.LECTURING)
    end

    local angle = Utils.vectorToAngle(dx, dy)
    self:setRotation(angle)
end

function DistinguishedProfessor:updateLecturing(dt)
    self:orbitStation(dt)

    -- Fire beams at station
    if self.beamCooldown <= 0 and self.beamsFired < self.maxBeamsPerLecture then
        self:fireBeam()
        self.beamCooldown = self.beamInterval
        self.beamsFired = self.beamsFired + 1
    end

    -- After firing all beams, switch to summoning
    if self.beamsFired >= self.maxBeamsPerLecture and self.phaseTimer >= 5 then
        self:enterPhase(DistinguishedProfessor.PHASES.SUMMONING)
    end
end

function DistinguishedProfessor:updateSummoning(dt)
    self:orbitStation(dt)

    if self.attackTimer >= 1.0 and self.dronesSpawned < self.maxDronesPerWave then
        self:spawnDrone()
        self.attackTimer = 0
        self.dronesSpawned = self.dronesSpawned + 1
    end

    if self.dronesSpawned >= self.maxDronesPerWave and self.phaseTimer >= 5 then
        self:enterPhase(DistinguishedProfessor.PHASES.LECTURING)
    end
end

function DistinguishedProfessor:updateEnraged(dt)
    self:orbitStation(dt, 1.5)

    -- Rapid fire beams and spawn drones
    if self.beamCooldown <= 0 then
        -- Fire 3 beams at offset angles
        self:fireBeam(0)
        self:fireBeam(-15)
        self:fireBeam(15)
        self.beamCooldown = self.beamInterval
    end

    -- Occasionally spawn drones
    if self.attackTimer >= 2.0 then
        self:spawnDrone()
        self.attackTimer = 0
    end
end

function DistinguishedProfessor:fireBeam(angleOffset)
    angleOffset = angleOffset or 0

    if not GameplayScene or not GameplayScene.enemyProjectilePool then return end

    -- Calculate angle to station
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local angle = Utils.vectorToAngle(dx, dy) + angleOffset

    local proj = GameplayScene.enemyProjectilePool:get(
        self.x, self.y,
        angle,
        DistinguishedProfessor.DATA.projectileSpeed,
        self.damage,
        DistinguishedProfessor.DATA.projectileImage
    )

    if AudioManager then
        AudioManager:playSFX("tool_frequency_scanner", 0.3)
    end
end

function DistinguishedProfessor:spawnDrone()
    if not GameplayScene then return end

    local offsetAngle = math.random() * math.pi * 2
    local spawnX = self.x + math.cos(offsetAngle) * 30
    local spawnY = self.y + math.sin(offsetAngle) * 30

    local drone = DebateDrone(spawnX, spawnY, { health = 1, damage = 1, speed = 1 })
    table.insert(GameplayScene.mobs, drone)

    if AudioManager then
        AudioManager:playSFX("mob_spawn", 0.4)
    end
end

function DistinguishedProfessor:orbitStation(dt, speedMult)
    speedMult = speedMult or 1.0

    local orbitSpeed = self.speed * speedMult * 0.015 * dt
    self.orbitAngle = self.orbitAngle + orbitSpeed

    self.x = self.targetX + math.cos(self.orbitAngle) * self.range
    self.y = self.targetY + math.sin(self.orbitAngle) * self.range

    local faceAngle = Utils.vectorToAngle(self.targetX - self.x, self.targetY - self.y)
    self:setRotation(faceAngle)
end

function DistinguishedProfessor:onDestroyed()
    if VFXManager then
        VFXManager:addDeathEffect(self.x, self.y, self:getRadius())
    end

    self.active = false

    if GameManager then
        GameManager:awardRP(self.rpValue)
    end

    if GameplayScene and GameplayScene.collectiblePool then
        for i = 1, 15 do
            local angle = (i / 15) * math.pi * 2
            local dist = 20 + math.random(25)
            local cx = self.x + math.cos(angle) * dist
            local cy = self.y + math.sin(angle) * dist
            GameplayScene.collectiblePool:get(cx, cy, Collectible.TYPES.RP, 15)
        end
    end

    if AudioManager then
        AudioManager:playSFX("mob_death_large", 1.0)
    end

    print("Distinguished Professor defeated!")

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

function DistinguishedProfessor:getRadius()
    return 24
end

function DistinguishedProfessor:drawHealthBar()
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
    local bossName = "PROFESSOR"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(bossName)
    love.graphics.print(bossName, barX + barWidth / 2 - textWidth / 2, barY + 1)
end

return DistinguishedProfessor
