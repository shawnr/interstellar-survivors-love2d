-- Productivity Liaison Boss (Episode 2)
-- Corporate consultant who evaluates your efficiency with drones and debuffs

class('ProductivityLiaison').extends(MOB)

ProductivityLiaison.DATA = {
    id = "productivity_liaison",
    name = "Productivity Liaison",
    description = "Your feedback is important to us",
    imagePath = "assets/images/episodes/ep2/ep2_boss_productivity_liaison",

    -- Boss stats
    baseHealth = 300,
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
ProductivityLiaison.PHASES = {
    APPROACH = 1,        -- Moving into position
    SURVEY_SWARM = 2,    -- Deploying survey drones
    FEEDBACK = 3,        -- Performance feedback (fire rate debuff)
    ENRAGED = 4,         -- Below 30% health - more aggressive
}

function ProductivityLiaison:init(x, y)
    -- Bosses don't use wave multipliers
    ProductivityLiaison.super.init(self, x, y, ProductivityLiaison.DATA, { health = 1, damage = 1, speed = 1 })

    -- Boss-specific state
    self.phase = ProductivityLiaison.PHASES.APPROACH
    self.phaseTimer = 0
    self.attackTimer = 0
    self.dronesSpawned = 0
    self.maxDronesPerWave = 4

    -- Orbit angle
    self.orbitAngle = math.atan2(y - Constants.STATION_CENTER_Y, x - Constants.STATION_CENTER_X)

    print("Productivity Liaison boss spawned!")
end

function ProductivityLiaison:update(dt)
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
    if self.health / self.maxHealth <= 0.3 and self.phase ~= ProductivityLiaison.PHASES.ENRAGED then
        self:enterPhase(ProductivityLiaison.PHASES.ENRAGED)
    end

    -- Execute current phase
    if self.phase == ProductivityLiaison.PHASES.APPROACH then
        self:updateApproach(dt)
    elseif self.phase == ProductivityLiaison.PHASES.SURVEY_SWARM then
        self:updateSurveySwarm(dt)
    elseif self.phase == ProductivityLiaison.PHASES.FEEDBACK then
        self:updateFeedback(dt)
    elseif self.phase == ProductivityLiaison.PHASES.ENRAGED then
        self:updateEnraged(dt)
    end
end

function ProductivityLiaison:enterPhase(newPhase)
    self.phase = newPhase
    self.phaseTimer = 0
    self.attackTimer = 0

    if newPhase == ProductivityLiaison.PHASES.SURVEY_SWARM then
        self.dronesSpawned = 0
        print("Productivity Liaison: Deploying survey drones!")
    elseif newPhase == ProductivityLiaison.PHASES.FEEDBACK then
        print("Productivity Liaison: Delivering performance feedback!")
    elseif newPhase == ProductivityLiaison.PHASES.ENRAGED then
        print("Productivity Liaison: METRICS UNACCEPTABLE! ENRAGED!")
        self.speed = self.speed * 1.5
        self.maxDronesPerWave = 6
    end
end

function ProductivityLiaison:updateApproach(dt)
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
        self:enterPhase(ProductivityLiaison.PHASES.SURVEY_SWARM)
    end

    -- Face the station
    local angle = Utils.vectorToAngle(dx, dy)
    self:setRotation(angle)
end

function ProductivityLiaison:updateSurveySwarm(dt)
    -- Orbit the station
    self:orbitStation(dt)

    -- Spawn drones periodically
    if self.attackTimer >= 1.2 and self.dronesSpawned < self.maxDronesPerWave then
        self:spawnDrone()
        self.attackTimer = 0
        self.dronesSpawned = self.dronesSpawned + 1
    end

    -- After spawning all drones, switch to feedback phase
    if self.dronesSpawned >= self.maxDronesPerWave and self.phaseTimer >= 5 then
        self:enterPhase(ProductivityLiaison.PHASES.FEEDBACK)
    end
end

function ProductivityLiaison:updateFeedback(dt)
    -- Orbit the station
    self:orbitStation(dt)

    -- Apply fire rate debuff at start of phase
    if self.phaseTimer >= 0.5 and self.phaseTimer - dt < 0.5 then
        self:applyFeedbackDebuff()
    end

    -- End feedback phase after duration
    if self.phaseTimer >= 4 then
        self:enterPhase(ProductivityLiaison.PHASES.SURVEY_SWARM)
    end
end

function ProductivityLiaison:updateEnraged(dt)
    -- More aggressive orbit
    self:orbitStation(dt, 1.5)

    -- Rapidly spawn drones and apply debuff
    if self.attackTimer >= 0.6 then
        if math.random() < 0.6 then
            self:spawnDrone()
        else
            self:applyFeedbackDebuff()
        end
        self.attackTimer = 0
    end
end

function ProductivityLiaison:orbitStation(dt, speedMult)
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

function ProductivityLiaison:spawnDrone()
    if not GameplayScene then return end

    -- Spawn a survey drone near the boss
    local offsetAngle = math.random() * math.pi * 2
    local spawnX = self.x + math.cos(offsetAngle) * 30
    local spawnY = self.y + math.sin(offsetAngle) * 30

    local drone = SurveyDrone(spawnX, spawnY, { health = 1, damage = 1, speed = 1 })
    table.insert(GameplayScene.mobs, drone)

    -- Play spawn sound
    if AudioManager then
        AudioManager:playSFX("mob_spawn", 0.4)
    end
end

function ProductivityLiaison:applyFeedbackDebuff()
    -- Use the GameplayScene fire rate debuff system
    if GameplayScene and GameplayScene.applyFireRateDebuff then
        GameplayScene:applyFireRateDebuff()
        print("Performance feedback slows fire rate!")
    end
end

function ProductivityLiaison:onDestroyed()
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
            GameplayScene.collectiblePool:get(cx, cy, Collectible.TYPES.RP, 12)
        end
    end

    -- Play destruction sound
    if AudioManager then
        AudioManager:playSFX("mob_death_large", 1.0)
    end

    print("Productivity Liaison defeated!")

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
function ProductivityLiaison:getRadius()
    return 24  -- Larger than normal mobs
end

-- Override health bar for boss (larger bar at bottom of screen)
function ProductivityLiaison:drawHealthBar()
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
    local bossName = "LIAISON"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(bossName)
    love.graphics.print(bossName, barX + barWidth / 2 - textWidth / 2, barY + 1)
end

return ProductivityLiaison
