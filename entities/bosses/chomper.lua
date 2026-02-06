-- Chomper Boss (Episode 4)
-- Massive creature that charges at the station and spawns debris

class('Chomper').extends(MOB)

Chomper.DATA = {
    id = "chomper",
    name = "Chomper",
    description = "Mostly lonely. Also hungry.",
    imagePath = "assets/images/episodes/ep4/ep4_boss_chomper",

    -- Boss stats
    baseHealth = 500,
    baseSpeed = 25,
    baseDamage = 10,
    rpValue = 150,

    -- Collision
    width = 48,
    height = 48,
    range = 80,
    emits = false,  -- Chomper is melee, not a shooter
}

-- Boss phases
Chomper.PHASES = {
    APPROACH = 1,      -- Moving into position
    CIRCLING = 2,      -- Orbiting the station
    CHARGING = 3,      -- Rushing at station (3x speed)
    RECOVERING = 4,    -- Stunned after charge
    ENRAGED = 5,       -- Below 30% HP - spawns debris when hit
}

function Chomper:init(x, y)
    Chomper.super.init(self, x, y, Chomper.DATA, { health = 1, damage = 1, speed = 1 })

    self.phase = Chomper.PHASES.APPROACH
    self.phaseTimer = 0
    self.attackTimer = 0
    self.chargeCount = 0
    self.maxChargesBeforeCircle = 2
    self.stunDuration = 2.0
    self.enragedDebrisChance = 0.30

    self.orbitAngle = math.atan2(y - Constants.STATION_CENTER_Y, x - Constants.STATION_CENTER_X)

    -- Charge state
    self.chargeDx = 0
    self.chargeDy = 0
    self.chargeSpeed = 0

    -- Enraged charge sub-state
    self.enragedCharging = false
    self.enragedChargeTimer = 0

    print("Chomper boss spawned!")
end

function Chomper:update(dt)
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

    -- Check for enraged phase
    if self.health / self.maxHealth <= 0.3 and self.phase ~= Chomper.PHASES.ENRAGED then
        self:enterPhase(Chomper.PHASES.ENRAGED)
    end

    if self.phase == Chomper.PHASES.APPROACH then
        self:updateApproach(dt)
    elseif self.phase == Chomper.PHASES.CIRCLING then
        self:updateCircling(dt)
    elseif self.phase == Chomper.PHASES.CHARGING then
        self:updateCharging(dt)
    elseif self.phase == Chomper.PHASES.RECOVERING then
        self:updateRecovering(dt)
    elseif self.phase == Chomper.PHASES.ENRAGED then
        self:updateEnraged(dt)
    end
end

function Chomper:enterPhase(newPhase)
    self.phase = newPhase
    self.phaseTimer = 0
    self.attackTimer = 0

    if newPhase == Chomper.PHASES.CIRCLING then
        self.chargeCount = 0
        print("Chomper: Circling...")
    elseif newPhase == Chomper.PHASES.CHARGING then
        -- Calculate charge direction toward station
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0 then
            self.chargeDx = dx / dist
            self.chargeDy = dy / dist
        end
        self.chargeSpeed = self.speed * 3
        print("Chomper: CHARGING!")
    elseif newPhase == Chomper.PHASES.RECOVERING then
        print("Chomper: Stunned!")
    elseif newPhase == Chomper.PHASES.ENRAGED then
        print("Chomper: HUNGRY AND ANGRY! ENRAGED!")
        self.speed = self.speed * 1.3
    end
end

function Chomper:updateApproach(dt)
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > self.range then
        local moveX = (dx / dist) * self.speed * dt
        local moveY = (dy / dist) * self.speed * dt
        self.x = self.x + moveX
        self.y = self.y + moveY
    else
        self:enterPhase(Chomper.PHASES.CIRCLING)
    end

    local angle = Utils.vectorToAngle(dx, dy)
    self:setRotation(angle)
end

function Chomper:updateCircling(dt)
    self:orbitStation(dt)

    -- After circling for a while, start a charge
    if self.phaseTimer >= 3.0 then
        self:enterPhase(Chomper.PHASES.CHARGING)
    end
end

function Chomper:updateCharging(dt)
    -- Rush toward station at high speed
    self.x = self.x + self.chargeDx * self.chargeSpeed * dt
    self.y = self.y + self.chargeDy * self.chargeSpeed * dt

    -- Face charge direction
    local angle = Utils.vectorToAngle(self.chargeDx, self.chargeDy)
    self:setRotation(angle)

    -- Check if reached station
    local distSq = Utils.distanceSquared(self.x, self.y, self.targetX, self.targetY)
    local hitDist = Constants.STATION_RADIUS + self:getRadius()

    if distSq < hitDist * hitDist then
        -- Hit the station!
        if GameplayScene and GameplayScene.station then
            local attackAngle = Utils.vectorToAngle(self.x - self.targetX, self.y - self.targetY)
            GameplayScene.station:takeDamage(self.damage * 2, attackAngle)

            if VFXManager then
                VFXManager:startShake(6, 0.3)
            end
        end

        -- Bounce back slightly
        self.x = self.targetX + self.chargeDx * (hitDist + 20)
        self.y = self.targetY + self.chargeDy * (hitDist + 20)

        self.chargeCount = self.chargeCount + 1
        self:enterPhase(Chomper.PHASES.RECOVERING)
    end

    -- Safety: if charge goes off screen, recover
    if self.phaseTimer > 3 then
        self:enterPhase(Chomper.PHASES.RECOVERING)
    end
end

function Chomper:updateRecovering(dt)
    -- Stunned, don't move
    if self.phaseTimer >= self.stunDuration then
        if self.chargeCount >= self.maxChargesBeforeCircle then
            self:enterPhase(Chomper.PHASES.CIRCLING)
        else
            self:enterPhase(Chomper.PHASES.CHARGING)
        end
    end
end

function Chomper:updateEnraged(dt)
    if self.enragedCharging then
        -- Continuous charge movement (mirrors normal CHARGING phase)
        self.x = self.x + self.chargeDx * self.chargeSpeed * dt
        self.y = self.y + self.chargeDy * self.chargeSpeed * dt

        local angle = Utils.vectorToAngle(self.chargeDx, self.chargeDy)
        self:setRotation(angle)

        -- Check station hit
        local distSq = Utils.distanceSquared(self.x, self.y, self.targetX, self.targetY)
        local hitDist = Constants.STATION_RADIUS + self:getRadius()
        if distSq < hitDist * hitDist then
            if GameplayScene and GameplayScene.station then
                local attackAngle = Utils.vectorToAngle(self.x - self.targetX, self.y - self.targetY)
                GameplayScene.station:takeDamage(self.damage * 2, attackAngle)
                if VFXManager then
                    VFXManager:startShake(6, 0.3)
                end
            end
            self.x = self.targetX + self.chargeDx * (hitDist + 20)
            self.y = self.targetY + self.chargeDy * (hitDist + 20)
            self.enragedCharging = false
            self.phaseTimer = 0
            return
        end

        -- Timeout: stop charging after 1.5 seconds
        self.enragedChargeTimer = self.enragedChargeTimer + dt
        if self.enragedChargeTimer >= 1.5 then
            self.enragedCharging = false
            self.phaseTimer = 0
        end
        return
    end

    -- More aggressive orbiting with frequent charges
    self:orbitStation(dt, 1.3)

    if self.phaseTimer >= 2.0 then
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0 then
            self.chargeDx = dx / dist
            self.chargeDy = dy / dist
        end
        self.chargeSpeed = self.speed * 3.5
        self.enragedCharging = true
        self.enragedChargeTimer = 0
    end
end

function Chomper:orbitStation(dt, speedMult)
    speedMult = speedMult or 1.0

    local orbitSpeed = self.speed * speedMult * 0.015 * dt
    self.orbitAngle = self.orbitAngle + orbitSpeed

    self.x = self.targetX + math.cos(self.orbitAngle) * self.range
    self.y = self.targetY + math.sin(self.orbitAngle) * self.range

    local faceAngle = Utils.vectorToAngle(self.targetX - self.x, self.targetY - self.y)
    self:setRotation(faceAngle)
end

-- Override takeDamage: in enraged phase, chance to spawn debris
function Chomper:takeDamage(amount)
    Chomper.super.takeDamage(self, amount)

    if self.phase == Chomper.PHASES.ENRAGED and math.random() < self.enragedDebrisChance then
        self:spawnDebris()
    end
end

function Chomper:spawnDebris()
    if not GameplayScene then return end

    local offsetAngle = math.random() * math.pi * 2
    local spawnX = self.x + math.cos(offsetAngle) * 25
    local spawnY = self.y + math.sin(offsetAngle) * 25

    local debris = DebrisChunk(spawnX, spawnY, { health = 1, damage = 1, speed = 1 })
    table.insert(GameplayScene.mobs, debris)
end

function Chomper:onDestroyed()
    if VFXManager then
        VFXManager:addDeathEffect(self.x, self.y, self:getRadius())
    end

    self.active = false

    if GameManager then
        GameManager:awardRP(self.rpValue)
    end

    if GameplayScene and GameplayScene.collectiblePool then
        for i = 1, 12 do
            local angle = (i / 12) * math.pi * 2
            local dist = 20 + math.random(20)
            local cx = self.x + math.cos(angle) * dist
            local cy = self.y + math.sin(angle) * dist
            GameplayScene.collectiblePool:get(cx, cy, Collectible.TYPES.RP, 15)
        end
    end

    if AudioManager then
        AudioManager:playSFX("mob_death_large", 1.0)
    end

    print("Chomper defeated!")

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

function Chomper:getRadius()
    return 24
end

function Chomper:drawHealthBar()
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
    local bossName = "CHOMPER"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(bossName)
    love.graphics.print(bossName, barX + barWidth / 2 - textWidth / 2, barY + 1)
end

return Chomper
