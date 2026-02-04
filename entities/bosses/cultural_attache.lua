-- Cultural Attache Boss (Episode 1)
-- Large ceremonial vessel that launches drones and demands you accept their poetry

class('CulturalAttache').extends(MOB)

CulturalAttache.DATA = {
    id = "cultural_attache",
    name = "Cultural Attache",
    description = "Demands you accept their poetry",
    imagePath = "assets/images/episodes/ep1/ep1_boss_cultural_attache",

    -- Boss stats
    baseHealth = 200,
    baseSpeed = 30,      -- px/sec (slower than normal mobs)
    baseDamage = 5,
    rpValue = 100,

    -- Collision
    width = 48,
    height = 48,
    range = 130,
    emits = true,        -- Boss is a shooter type
}

-- Boss phases
CulturalAttache.PHASES = {
    APPROACH = 1,        -- Moving into position
    DRONE_WAVE = 2,      -- Launching greeting drones
    POETRY = 3,          -- Poetry attack (slows rotation)
    ENRAGED = 4,         -- Below 30% health - more aggressive
}

function CulturalAttache:init(x, y)
    -- Bosses don't use wave multipliers
    CulturalAttache.super.init(self, x, y, CulturalAttache.DATA, { health = 1, damage = 1, speed = 1 })

    -- Boss-specific state
    self.phase = CulturalAttache.PHASES.APPROACH
    self.phaseTimer = 0
    self.attackTimer = 0
    self.dronesSpawned = 0
    self.maxDronesPerWave = 3

    -- Poetry state
    self.showingPoetry = false

    -- Orbit angle
    self.orbitAngle = math.atan2(y - Constants.STATION_CENTER_Y, x - Constants.STATION_CENTER_X)

    print("Cultural Attache boss spawned!")
end

function CulturalAttache:update(dt)
    if not self.active then return end

    -- Don't update if game is paused/leveling up
    if GameplayScene and (GameplayScene.isPaused or GameplayScene.isLevelingUp) then
        return
    end

    -- Update health bar
    if self.showHealthBar then
        self.healthBarTimer = self.healthBarTimer - dt
        if self.healthBarTimer <= 0 then
            self.showHealthBar = false
        end
    end

    -- Update phase timer
    self.phaseTimer = self.phaseTimer + dt
    self.attackTimer = self.attackTimer + dt

    -- Check for enraged phase
    if self.health / self.maxHealth <= 0.3 and self.phase ~= CulturalAttache.PHASES.ENRAGED then
        self:enterPhase(CulturalAttache.PHASES.ENRAGED)
    end

    -- Execute current phase
    if self.phase == CulturalAttache.PHASES.APPROACH then
        self:updateApproach(dt)
    elseif self.phase == CulturalAttache.PHASES.DRONE_WAVE then
        self:updateDroneWave(dt)
    elseif self.phase == CulturalAttache.PHASES.POETRY then
        self:updatePoetry(dt)
    elseif self.phase == CulturalAttache.PHASES.ENRAGED then
        self:updateEnraged(dt)
    end
end

function CulturalAttache:enterPhase(newPhase)
    self.phase = newPhase
    self.phaseTimer = 0
    self.attackTimer = 0

    if newPhase == CulturalAttache.PHASES.DRONE_WAVE then
        self.dronesSpawned = 0
        print("Cultural Attache: Deploying greeting drones!")
    elseif newPhase == CulturalAttache.PHASES.POETRY then
        print("Cultural Attache: Reciting epic poetry!")
    elseif newPhase == CulturalAttache.PHASES.ENRAGED then
        print("Cultural Attache: INSULTED! NOW ENRAGED!")
        self.speed = self.speed * 1.5
    end
end

function CulturalAttache:updateApproach(dt)
    -- Move toward station until in range
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > self.range then
        local moveX = (dx / dist) * self.speed * dt
        local moveY = (dy / dist) * self.speed * dt
        self.x = self.x + moveX
        self.y = self.y + moveY
    else
        -- In position, start attack cycle
        self:enterPhase(CulturalAttache.PHASES.DRONE_WAVE)
    end

    -- Face the station
    local angle = Utils.vectorToAngle(dx, dy)
    self:setRotation(angle)
end

function CulturalAttache:updateDroneWave(dt)
    -- Orbit the station
    self:orbitStation(dt)

    -- Spawn drones periodically
    if self.attackTimer >= 1.5 and self.dronesSpawned < self.maxDronesPerWave then
        self:spawnDrone()
        self.attackTimer = 0
        self.dronesSpawned = self.dronesSpawned + 1
    end

    -- After spawning all drones, switch to poetry phase
    if self.dronesSpawned >= self.maxDronesPerWave and self.phaseTimer >= 5 then
        self:enterPhase(CulturalAttache.PHASES.POETRY)
    end
end

function CulturalAttache:updatePoetry(dt)
    -- Orbit the station
    self:orbitStation(dt)

    -- Apply slow at start of phase
    if not self.showingPoetry and self.phaseTimer >= 0.5 then
        self:startPoetryAttack()
    end

    -- End poetry phase after duration
    if self.phaseTimer >= 4 then
        self:endPoetryAttack()
        self:enterPhase(CulturalAttache.PHASES.DRONE_WAVE)
    end
end

function CulturalAttache:updateEnraged(dt)
    -- More aggressive orbit
    self:orbitStation(dt, 1.5)

    -- Rapidly spawn drones and use poetry
    if self.attackTimer >= 0.8 then
        if math.random() < 0.6 then
            self:spawnDrone()
        else
            self:applySlowEffect()
        end
        self.attackTimer = 0
    end
end

function CulturalAttache:orbitStation(dt, speedMult)
    speedMult = speedMult or 1.0

    -- Orbit behavior
    local orbitSpeed = self.speed * speedMult * 0.015 * dt
    self.orbitAngle = self.orbitAngle + orbitSpeed

    self.x = self.targetX + math.cos(self.orbitAngle) * self.range
    self.y = self.targetY + math.sin(self.orbitAngle) * self.range

    -- Face the station
    local faceAngle = Utils.vectorToAngle(self.targetX - self.x, self.targetY - self.y)
    self:setRotation(faceAngle)
end

function CulturalAttache:spawnDrone()
    if not GameplayScene then return end

    -- Spawn a greeting drone near the boss
    local offsetAngle = math.random() * math.pi * 2
    local spawnX = self.x + math.cos(offsetAngle) * 30
    local spawnY = self.y + math.sin(offsetAngle) * 30

    local drone = GreetingDrone(spawnX, spawnY, { health = 1, damage = 1, speed = 1 })
    table.insert(GameplayScene.mobs, drone)

    -- Play spawn sound
    if AudioManager then
        AudioManager:playSFX("mob_spawn", 0.4)
    end
end

function CulturalAttache:startPoetryAttack()
    self.showingPoetry = true
    self:applySlowEffect()
end

function CulturalAttache:endPoetryAttack()
    self.showingPoetry = false
end

function CulturalAttache:applySlowEffect()
    -- Use the GameplayScene slow effect system
    if GameplayScene then
        GameplayScene.slowEffect = true
        GameplayScene.slowTimer = 2.5
        InputManager:setRotationSpeedMultiplier(0.4)  -- 60% slower
        print("Poetry slows rotation!")
    end
end

function CulturalAttache:onDestroyed()
    -- Death effect
    if VFXManager then
        VFXManager:addDeathEffect(self.x, self.y, self:getRadius())
    end

    self.active = false

    -- Award RP
    if GameManager then
        GameManager:awardRP(self.rpValue)
    end

    -- Spawn lots of collectibles
    if GameplayScene and GameplayScene.collectiblePool then
        for i = 1, 10 do
            local angle = (i / 10) * math.pi * 2
            local dist = 20 + math.random(20)
            local cx = self.x + math.cos(angle) * dist
            local cy = self.y + math.sin(angle) * dist
            GameplayScene.collectiblePool:get(cx, cy, Collectible.TYPES.RP, 10)
        end
    end

    -- Play destruction sound
    if AudioManager then
        AudioManager:playSFX("mob_death_large", 1.0)
    end

    print("Cultural Attache defeated!")

    -- Start defeat celebration, then trigger victory
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

-- Override to get larger radius for boss
function CulturalAttache:getRadius()
    return 24  -- Larger than normal mobs
end

-- Override health bar for boss (larger bar at bottom of screen)
function CulturalAttache:drawHealthBar()
    if not self.active then return end

    -- Boss health bar in bottom left area
    local barWidth = 140
    local barHeight = 14
    local barX = 8
    local barY = Constants.SCREEN_HEIGHT - 36

    local healthPercent = self.health / self.maxHealth

    -- Health bar background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barWidth + 2, barHeight + 2)

    -- Health bar fill (red for boss)
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth * healthPercent, barHeight)

    -- Boss name
    love.graphics.setColor(1, 1, 1)
    local bossName = "ATTACHE"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(bossName)
    love.graphics.print(bossName, barX + barWidth / 2 - textWidth / 2, barY + 1)
end

return CulturalAttache
