-- MOB Base Class
-- Enemies that attack the station

class('MOB').extends(Entity)

function MOB:init(x, y, mobData, waveMultipliers)
    MOB.super.init(self, x, y, mobData.imagePath)

    -- Store data
    self.data = mobData
    self.mobType = mobData.id or "unknown"

    -- Apply wave multipliers
    waveMultipliers = waveMultipliers or { health = 1, damage = 1, speed = 1 }

    -- Stats
    self.health = mobData.baseHealth * waveMultipliers.health
    self.maxHealth = self.health
    self.damage = mobData.baseDamage * waveMultipliers.damage
    self.speed = mobData.baseSpeed * waveMultipliers.speed
    self.rpValue = mobData.rpValue or 5
    self.range = mobData.range or 1
    self.emits = mobData.emits or false  -- true = shooter, false = rammer

    -- Movement target (station center)
    self.targetX = Constants.STATION_CENTER_X
    self.targetY = Constants.STATION_CENTER_Y

    -- Collision radius (use explicit dimensions)
    local collisionW = mobData.width or 16
    local collisionH = mobData.height or 16
    self.cachedRadius = math.max(collisionW, collisionH) / 2

    -- Health bar display
    self.showHealthBar = false
    self.healthBarTimer = 0

    -- Hit flash
    self.isFlashing = false
    self.flashTimer = 0

    -- Death animation
    self.isDying = false
    self.deathTimer = 0
    self.deathDuration = 0.2
    self.deathScale = 1.0

    -- Shooter properties (initialized from data if emits)
    if self.emits then
        self.fireCooldown = 0
        self.fireInterval = 1 / (mobData.fireRate or 0.5)
        self.projectileImage = mobData.projectileImage or nil
        self.projectileEffect = mobData.projectileEffect or nil
        self.projectileSpeed = mobData.projectileSpeed or 90
        self.orbitDirection = (math.random() > 0.5) and 1 or -1
        self.orbitAngle = math.atan2(y - Constants.STATION_CENTER_Y, x - Constants.STATION_CENTER_X)
    end
end

function MOB:update(dt)
    if not self.active then return end

    -- Don't update if game is paused
    if GameplayScene and GameplayScene.isPaused then
        return
    end

    -- Death animation
    if self.isDying then
        self.deathTimer = self.deathTimer + dt
        if self.deathTimer >= self.deathDuration then
            self.active = false
            return
        end
        self.deathScale = 1.0 - (self.deathTimer / self.deathDuration)
        self.rotation = (self.rotation or 0) + 720 * dt
        return
    end

    -- Update health bar timer
    if self.showHealthBar then
        self.healthBarTimer = self.healthBarTimer - dt
        if self.healthBarTimer <= 0 then
            self.showHealthBar = false
        end
    end

    -- Update flash timer
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then
            self.isFlashing = false
        end
    end

    -- Movement
    if self.emits then
        self:updateShooterMovement(dt)
        self:updateShooterFiring(dt)
    else
        self:updateRammerMovement(dt)
    end
end

-- Movement for ramming MOBs (straight line toward station)
function MOB:updateRammerMovement(dt)
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local distSq = dx * dx + dy * dy

    if distSq > 1 then
        -- Normalize and apply speed
        local dist = math.sqrt(distSq)
        local moveX = (dx / dist) * self.speed * dt
        local moveY = (dy / dist) * self.speed * dt

        self.x = self.x + moveX
        self.y = self.y + moveY

        -- Rotate to face movement direction
        local angle = Utils.vectorToAngle(dx, dy)
        self:setRotation(angle)
    end
end

-- Movement for shooting MOBs (approach then orbit at range)
function MOB:updateShooterMovement(dt)
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local distSq = dx * dx + dy * dy
    local rangeSq = self.range * self.range

    if distSq > rangeSq then
        -- Move closer to station
        local dist = math.sqrt(distSq)
        self.x = self.x + (dx / dist) * self.speed * dt
        self.y = self.y + (dy / dist) * self.speed * dt
    else
        -- Orbit around station at range
        local orbitSpeed = self.speed * 0.04 * self.orbitDirection * dt
        self.orbitAngle = self.orbitAngle + orbitSpeed
        self.x = self.targetX + math.cos(self.orbitAngle) * self.range
        self.y = self.targetY + math.sin(self.orbitAngle) * self.range
    end

    -- Always face the station
    local faceAngle = Utils.vectorToAngle(self.targetX - self.x, self.targetY - self.y)
    self:setRotation(faceAngle)
end

-- Firing logic for shooter MOBs
function MOB:updateShooterFiring(dt)
    if not self.emits then return end

    self.fireCooldown = self.fireCooldown - dt
    if self.fireCooldown <= 0 then
        local dist = Utils.distance(self.x, self.y, self.targetX, self.targetY)
        if dist <= self.range + 20 then
            self:fireAtStation()
            self.fireCooldown = self.fireInterval
        end
    end
end

-- Fire a projectile at the station
function MOB:fireAtStation()
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local angle = Utils.vectorToAngle(dx, dy)

    if GameplayScene and GameplayScene.enemyProjectilePool then
        GameplayScene.enemyProjectilePool:get(
            self.x, self.y, angle,
            self.projectileSpeed, self.damage,
            self.projectileImage, self.projectileEffect
        )
    end
end

-- Take damage
function MOB:takeDamage(amount, damageType, sourceX, sourceY)
    if self.isDying then return false end

    self.health = self.health - amount

    -- Show health bar
    self.showHealthBar = true
    self.healthBarTimer = Constants.HEALTH_BAR_SHOW_DURATION

    -- Hit flash
    self.isFlashing = true
    self.flashTimer = Constants.VFX.HIT_FLASH_DURATION

    -- VFX hit flash
    if VFXManager then
        VFXManager:addHitFlash(self.x, self.y, self:getRadius())
    end

    -- Play hit sound
    if AudioManager then
        AudioManager:playSFX("mob_hit", 0.3)
    end

    -- Check for death
    if self.health <= 0 then
        self:onDestroyed()
        return true
    end

    return false
end

-- Called when MOB is destroyed
function MOB:onDestroyed()
    if self.isDying then return end

    -- Death effect
    if VFXManager then
        VFXManager:addDeathEffect(self.x, self.y, self:getRadius())
    end

    -- Play destroyed sound
    if AudioManager then
        AudioManager:playSFX("mob_destroyed", 0.5)
    end

    -- Spawn collectibles
    self:spawnCollectibles()

    -- Start death animation
    self.isDying = true
    self.deathTimer = 0
    self.deathScale = 1.0
end

-- Spawn collectibles at death location
function MOB:spawnCollectibles()
    if not GameplayScene or not GameplayScene.collectiblePool then return end

    -- Spawn RP orbs based on rpValue
    local orbCount = math.max(1, math.floor(self.rpValue / 5))
    local valuePerOrb = self.rpValue / orbCount

    for i = 1, orbCount do
        -- Slight random offset for each orb
        local offsetX = (math.random() - 0.5) * 16
        local offsetY = (math.random() - 0.5) * 16

        GameplayScene.collectiblePool:get(
            self.x + offsetX,
            self.y + offsetY,
            "rp",
            valuePerOrb
        )
    end

    -- 3% chance to drop bonus item
    if math.random(100) <= 3 then
        GameplayScene.collectiblePool:get(
            self.x, self.y,
            Collectible.TYPES.BONUS_ITEM, 1
        )
    end
end

-- Draw mob (with death animation support)
function MOB:draw()
    if not self.active and not self.isDying then return end
    if not self.image then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(math.rad((self.rotation or 0) - 90))
    love.graphics.scale(self.deathScale, self.deathScale)
    love.graphics.draw(
        self.image,
        -self.width * self.originX,
        -self.height * self.originY
    )
    love.graphics.pop()
end

-- Draw health bar
function MOB:drawHealthBar()
    if not self.showHealthBar or not self.active then return end

    local barWidth = 20
    local barHeight = 3
    local barX = self.x - barWidth / 2
    local barY = self.y - self:getRadius() - 6

    -- Background (black)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    -- Fill (white)
    local fillWidth = (self.health / self.maxHealth) * (barWidth - 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", barX + 1, barY + 1, fillWidth, barHeight - 2)
end

-- Get radius for collision
function MOB:getRadius()
    return self.cachedRadius or 8
end

-- Check if MOB has reached the station
function MOB:hasReachedStation()
    local dist = Utils.distance(self.x, self.y, self.targetX, self.targetY)
    return dist < (Constants.STATION_RADIUS + self:getRadius())
end

return MOB
