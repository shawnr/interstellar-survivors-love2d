-- Tool Base Class
-- Weapons/tools that attach to the station and fire automatically

class('Tool').extends(Entity)

function Tool:init(toolData)
    -- Store tool data
    self.data = toolData

    -- Initialize without position (will be set when attached)
    Tool.super.init(self, 0, 0, toolData.imagePath)

    -- Station reference (set when attached)
    self.station = nil
    self.slotIndex = nil
    self.slotData = nil

    -- Level system (1-4), evolution
    self.level = 1
    self.evolved = false
    self.evolvedName = nil

    -- Tool stats from data
    self.damage = toolData.baseDamage or 1
    self.fireRate = toolData.fireRate or 1.0
    self.projectileSpeed = toolData.projectileSpeed or 10
    self.pattern = toolData.pattern or "straight"

    -- Apply grants damage multiplier to initial damage
    if GrantsSystem then
        self.damage = self.damage * GrantsSystem:getDamageMultiplier()
    end

    -- Firing state
    self.fireCooldown = 0
    self.fireInterval = 1 / self.fireRate

    -- Bonus modifiers
    self.damageBonus = 0
    self.fireRateBonus = 0
    self.projectileSpeedBonus = 0
    if BonusItemsSystem then
        self.projectileSpeedBonus = BonusItemsSystem:getProjectileSpeedBonus()
    end

    -- Muzzle flash
    self.muzzleFlashTimer = 0
end

-- Update tool position based on station rotation
function Tool:updatePosition(stationRotation)
    if not self.station or not self.slotData then return end

    -- Use station's cached trig values
    local cos = self.station.cachedCos
    local sin = self.station.cachedSin

    local baseX = self.slotData.x
    local baseY = self.slotData.y

    local rotatedX = baseX * cos - baseY * sin
    local rotatedY = baseX * sin + baseY * cos

    -- Set position
    self.x = self.station.x + rotatedX
    self.y = self.station.y + rotatedY

    -- Rotate tool sprite to face outward
    -- Tool sprites face RIGHT (0°), game uses 0°=UP, so offset by -90°
    local toolAngle = stationRotation + self.slotData.angle
    self:setRotation(toolAngle)
end

-- Update method called each frame
function Tool:update(dt)
    if not self.station then return end

    -- Don't fire if game is paused
    if GameplayScene and GameplayScene.isPaused then
        return
    end

    -- Update fire cooldown
    self.fireCooldown = math.max(0, self.fireCooldown - dt)

    -- Update muzzle flash
    if self.muzzleFlashTimer > 0 then
        self.muzzleFlashTimer = self.muzzleFlashTimer - dt
    end

    -- Fire if ready
    if self.fireCooldown <= 0 then
        self:fire()
        self.fireCooldown = self.fireInterval
    end
end

-- Fire the tool (override in specific tools)
function Tool:fire()
    -- Get firing angle
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)

    -- Get firing position (slightly in front of tool)
    local offsetDist = 10
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05
    if VFXManager then
        VFXManager:addToolFlash(fireX, fireY)
    end

    -- Create projectile (override in subclass for different patterns)
    self:createProjectile(fireX, fireY, firingAngle)
end

-- Create a projectile (override for different patterns)
function Tool:createProjectile(x, y, angle)
    -- Default: single straight projectile
    if GameplayScene and GameplayScene.projectilePool then
        local projectile = GameplayScene.projectilePool:get(
            x, y, angle,
            self.projectileSpeed * (1 + self.projectileSpeedBonus),
            self.damage,
            self.data.projectileImage or "assets/images/tools/tool_rail_driver_projectile"
        )
        return projectile
    end
end

-- Recalculate stats based on level and bonuses
function Tool:recalculateStats()
    if not self.data then return end

    -- Get level-scaled stats from ToolsData
    local stats = ToolsData.getStatsAtLevel(self.data.id, self.level)
    if stats then
        self.damage = stats.damage + (self.damageBonus or 0)
        self.fireRate = stats.fireRate + (self.fireRateBonus or 0)

        -- Apply grants damage multiplier
        if GrantsSystem then
            self.damage = self.damage * GrantsSystem:getDamageMultiplier()
        end

        -- Apply specs fire rate bonus
        if SpecsSystem then
            self.fireRate = self.fireRate * (1 + SpecsSystem:getFireRateBonus())
        end

        -- Apply bonus items fire rate bonus
        if BonusItemsSystem then
            self.fireRate = self.fireRate * (1 + BonusItemsSystem:getFireRateBonus())
        end

        -- Apply bonus items projectile speed bonus
        if BonusItemsSystem then
            self.projectileSpeedBonus = BonusItemsSystem:getProjectileSpeedBonus()
        end

        self.fireInterval = 1 / math.max(0.1, self.fireRate)
    end

    print("Tool " .. self.data.id .. " stats recalculated: Lv" .. self.level ..
          " Dmg=" .. self.damage .. " Rate=" .. self.fireRate)
end

-- Draw tool with muzzle flash
function Tool:draw()
    Tool.super.draw(self)

    -- Muzzle flash
    if self.muzzleFlashTimer and self.muzzleFlashTimer > 0 then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("fill", self.x, self.y, 4)
    end
end

-- Evolve the tool (override in subclasses for specific effects)
function Tool:evolve()
    self.evolved = true
    local toolData = ToolsData.get(self.data.id)
    if toolData and toolData.upgradedName then
        self.evolvedName = toolData.upgradedName
    end
    self:recalculateStats()
    print("Tool " .. self.data.id .. " EVOLVED to " .. (self.evolvedName or "???"))
end

-- Get tool info for UI
function Tool:getInfo()
    return {
        name = self.evolved and self.evolvedName or self.data.name,
        level = self.evolved and "EVO" or self.level,
        damage = self.damage,
        fireRate = self.fireRate,
        pattern = self.pattern,
    }
end

return Tool
