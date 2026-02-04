-- Station Entity
-- The player's space station that rotates with keyboard controls

class('Station').extends(Entity)

function Station:init()
    -- Initialize base entity at screen center
    Station.super.init(self, Constants.STATION_CENTER_X, Constants.STATION_CENTER_Y, "assets/images/shared/station_base")

    -- Health
    self.maxHealth = Constants.STATION_BASE_HEALTH
    self.health = self.maxHealth

    -- Rotation (controlled by InputManager)
    self.currentRotation = 0

    -- Tools attached to station
    self.tools = {}
    self.usedSlots = {}

    -- Damage state tracking (for sprite changes)
    self.damageState = 0  -- 0 = healthy, 1 = damaged, 2 = critical

    -- Cached trig values for tool positioning
    self.cachedCos = 1
    self.cachedSin = 0

    -- Shield system
    self.shieldLevel = 1
    self.shieldDamageCapacity = 10
    self.shieldCurrentCapacity = 10
    self.shieldCooldown = 0
    self.shieldBaseCooldown = 2.0
    self.shieldCoverage = 0.25            -- 25% = 90 degrees
    self.shieldProjectileBlock = 1.0      -- 100% projectile damage blocked
    self.shieldRamBlock = 0.5             -- 50% ram damage blocked at level 1
    self.shieldAngleOffset = 180          -- Shield opposite the first tool
    self.shieldOpacity = 1.0

    -- Shield flash effect
    self.shieldFlashTimer = 0
    self.shieldFlashAngle = 0

    -- Initialize shield stats
    self:updateShieldStats()

    print("Station initialized at " .. self.x .. ", " .. self.y)
end

-- Update shield stats based on level
function Station:updateShieldStats()
    local level = self.shieldLevel

    -- Level 1: 10 capacity, 25% coverage, 2.0s cooldown, 50% ram block
    -- Level 2: 15 capacity, 33% coverage, 1.6s cooldown, 60% ram block
    -- Level 3: 20 capacity, 42% coverage, 1.2s cooldown, 70% ram block
    -- Level 4: 25 capacity, 50% coverage, 0.8s cooldown, 80% ram block

    self.shieldDamageCapacity = 10 + (level - 1) * 5
    self.shieldCurrentCapacity = self.shieldDamageCapacity
    self.shieldCoverage = 0.25 + (level - 1) * 0.083
    self.shieldBaseCooldown = 2.0 - (level - 1) * 0.4
    self.shieldProjectileBlock = 1.0
    self.shieldRamBlock = 0.5 + (level - 1) * 0.1
end

-- Upgrade shield
function Station:upgradeShield()
    if self.shieldLevel < 4 then
        self.shieldLevel = self.shieldLevel + 1
        self:updateShieldStats()
        print("Shield upgraded to level " .. self.shieldLevel)
        return true
    end
    return false
end

function Station:update(dt)
    if not self.active then return end

    -- Get rotation from input manager
    self.currentRotation = InputManager:getRotation()

    -- Apply rotation to entity
    self:setRotation(self.currentRotation)

    -- Cache trig values for tool position updates
    local angle = Utils.degToRad(self.currentRotation)
    self.cachedCos = math.cos(angle)
    self.cachedSin = math.sin(angle)

    -- Update all attached tools
    for _, tool in ipairs(self.tools) do
        tool:updatePosition(self.currentRotation)
    end

    -- Update shield cooldown
    if self.shieldCooldown > 0 then
        self.shieldCooldown = self.shieldCooldown - dt
        local effectiveCooldown = self.shieldBaseCooldown
        if BonusItemsSystem then
            effectiveCooldown = effectiveCooldown * (1 - BonusItemsSystem:getShieldCooldownReduction())
        end
        self.shieldOpacity = 1.0 - (self.shieldCooldown / math.max(0.1, effectiveCooldown))
        if self.shieldCooldown <= 0 then
            self.shieldCooldown = 0
            self.shieldCurrentCapacity = self.shieldDamageCapacity
            self.shieldOpacity = 1.0
            if VFXManager then
                VFXManager:addShieldRechargeFlash(self.x, self.y)
            end
        end
    else
        self.shieldOpacity = 1.0
    end

    -- Update shield flash
    if self.shieldFlashTimer > 0 then
        self.shieldFlashTimer = self.shieldFlashTimer - dt
    end
end

-- Check if attack angle is covered by shield
function Station:isShieldCovering(attackAngle)
    if self.shieldCurrentCapacity <= 0 or self.shieldCooldown > 0 then
        return false
    end

    -- Shield center is opposite the first tool (slot 0)
    local shieldCenter = (self.currentRotation + self.shieldAngleOffset) % 360

    -- Half-angle of coverage
    local halfCoverage = (self.shieldCoverage * 360) / 2

    -- Normalize attack angle
    attackAngle = attackAngle % 360

    -- Check if attack angle is within shield coverage
    local diff = math.abs(attackAngle - shieldCenter)
    if diff > 180 then
        diff = 360 - diff
    end

    return diff <= halfCoverage
end

-- Attach a tool to the station
function Station:attachTool(tool, slotIndex)
    -- Find next available slot if not specified
    if slotIndex == nil then
        slotIndex = self:getNextAvailableSlot()
    end

    if slotIndex == nil then
        print("No available slots for tool!")
        return false
    end

    if #self.tools >= Constants.MAX_EQUIPMENT then
        print("Maximum tools reached!")
        return false
    end

    -- Mark slot as used
    self.usedSlots[slotIndex] = true

    -- Configure tool with slot info
    tool.station = self
    tool.slotIndex = slotIndex
    tool.slotData = Constants.TOOL_SLOTS[slotIndex]

    -- Add tool to list
    table.insert(self.tools, tool)

    -- Position tool initially
    tool:updatePosition(self.currentRotation)

    print("Tool attached to slot " .. slotIndex)
    return true
end

-- Get next available slot
function Station:getNextAvailableSlot()
    for i = 0, Constants.STATION_SLOTS - 1 do
        if not self.usedSlots[i] then
            return i
        end
    end
    return nil
end

-- Take damage (with shield support)
-- damageType: "projectile" or "ram" (defaults to "ram")
function Station:takeDamage(amount, attackAngle, damageType)
    damageType = damageType or "ram"

    -- Check dodge (from specs)
    if SpecsSystem then
        local dodgeChance = SpecsSystem:getDodgeChance()
        if dodgeChance > 0 and math.random() < dodgeChance then
            if VFXManager then
                VFXManager:addFloatingText("DODGE!", self.x, self.y - 20, {0.5, 1, 0.5})
            end
            return false
        end
    end

    -- Check shield coverage
    if attackAngle and self:isShieldCovering(attackAngle) then
        -- Calculate how much damage the shield blocks
        local blockEffectiveness = damageType == "projectile" and self.shieldProjectileBlock or self.shieldRamBlock
        local damageToBlock = math.floor(amount * blockEffectiveness)
        local damageBlocked = math.min(damageToBlock, self.shieldCurrentCapacity)
        local damagePassthrough = amount - damageBlocked

        -- Reduce shield capacity
        self.shieldCurrentCapacity = self.shieldCurrentCapacity - damageBlocked

        -- Play shield hit sound
        if AudioManager then
            AudioManager:playSFX("shield_hit", 0.8)
        end

        -- Trigger shield flash
        self.shieldFlashTimer = 0.15
        self.shieldFlashAngle = attackAngle

        -- Start cooldown if shield depleted
        if self.shieldCurrentCapacity <= 0 then
            local cooldownReduction = 0
            if BonusItemsSystem then
                cooldownReduction = BonusItemsSystem:getShieldCooldownReduction()
            end
            self.shieldCooldown = self.shieldBaseCooldown * (1 - cooldownReduction)
        end

        -- If shield fully absorbed the hit
        if damagePassthrough <= 0 then
            return false
        end

        -- Continue with passthrough damage
        amount = damagePassthrough
    end

    -- Apply damage reduction from bonus items
    if BonusItemsSystem then
        local reduction = BonusItemsSystem:getDamageReduction()
        if reduction > 0 then
            amount = math.max(1, math.floor(amount * (1 - reduction)))
        end
    end

    -- Apply damage to health
    self.health = math.max(0, self.health - amount)

    -- Screen shake proportional to damage
    if VFXManager then
        local shakeIntensity = Utils.clamp(amount / 10, 1, 5)
        local shakeDuration = Utils.clamp(amount / 50, 0.1, 0.3)
        VFXManager:startShake(shakeIntensity, shakeDuration)
    end

    -- Play hit sound
    if AudioManager then
        AudioManager:playSFX("station_hit", 0.7)
    end

    -- Update damage visual state
    local healthPercent = self.health / self.maxHealth

    if healthPercent <= 0.50 and self.damageState ~= 2 then
        self.damageState = 2
        self:loadImage("assets/images/shared/station_damaged_2")
    elseif healthPercent <= 0.75 and healthPercent > 0.50 and self.damageState ~= 1 then
        self.damageState = 1
        self:loadImage("assets/images/shared/station_damaged_1")
    end

    -- Check for destruction
    if self.health <= 0 then
        self:onDestroyed()
        return true
    end

    return false
end

-- Called when station is destroyed
function Station:onDestroyed()
    print("Station destroyed!")

    -- Start destruction sequence (delays transition)
    if VFXManager then
        VFXManager:startDestructionSequence(self.x, self.y, function()
            self.active = false
            if GameManager then
                GameManager:onStationDestroyed()
            end
        end)
    else
        -- Fallback without VFX
        self.active = false
        if AudioManager then
            AudioManager:playSFX("station_destroyed", 1.0)
        end
        if GameManager then
            GameManager:onStationDestroyed()
        end
    end
end

-- Heal the station
function Station:heal(amount)
    local oldHealth = self.health
    self.health = math.min(self.maxHealth, self.health + amount)

    -- Update visual state if healed enough
    local healthPercent = self.health / self.maxHealth
    if healthPercent > 0.75 and self.damageState ~= 0 then
        self.damageState = 0
        self:loadImage("assets/images/shared/station_base")
    elseif healthPercent > 0.50 and self.damageState == 2 then
        self.damageState = 1
        self:loadImage("assets/images/shared/station_damaged_1")
    end

    return self.health - oldHealth
end

-- Get health percentage (0-1)
function Station:getHealthPercent()
    return self.health / self.maxHealth
end

-- Get shield percentage (0-1)
function Station:getShieldPercent()
    if self.shieldCooldown > 0 then
        return 0
    end
    return self.shieldCurrentCapacity / self.shieldDamageCapacity
end

-- Check if shield is active
function Station:isShieldActive()
    return self.shieldCurrentCapacity > 0 and self.shieldCooldown <= 0
end

-- Get current rotation
function Station:getRotation()
    return self.currentRotation
end

-- Get position of a specific slot (world coordinates)
function Station:getSlotPosition(slotIndex)
    local slotData = Constants.TOOL_SLOTS[slotIndex]
    if not slotData then return self.x, self.y end

    -- Use cached trig values
    local cos = self.cachedCos
    local sin = self.cachedSin

    local rotatedX = slotData.x * cos - slotData.y * sin
    local rotatedY = slotData.x * sin + slotData.y * cos

    return self.x + rotatedX, self.y + rotatedY
end

-- Get firing angle for a specific slot (in game coordinate system where 0=up)
function Station:getSlotFiringAngle(slotIndex)
    local slotData = Constants.TOOL_SLOTS[slotIndex]
    if not slotData then return self.currentRotation end

    return self.currentRotation + slotData.angle
end

-- Draw station (tools are drawn separately)
function Station:draw()
    if not self.active then return end

    -- Draw the station sprite
    Station.super.draw(self)
end

-- Draw shield arc
function Station:drawShield()
    if self.shieldDamageCapacity <= 0 then return end

    local shieldCenter = (self.currentRotation + self.shieldAngleOffset) % 360
    local halfAngle = (self.shieldCoverage * 360) / 2
    local startAngle = shieldCenter - halfAngle - 90  -- -90 for Love2D coordinate system
    local endAngle = shieldCenter + halfAngle - 90
    local radius = Constants.STATION_RADIUS + 8

    -- Convert to radians
    local startRad = math.rad(startAngle)
    local endRad = math.rad(endAngle)

    -- Draw arc segments
    local segments = 16
    local angleStep = (endRad - startRad) / segments

    -- Set shield color based on state
    if self.shieldFlashTimer > 0 then
        -- Flash white when hit
        love.graphics.setColor(1, 1, 1, self.shieldOpacity)
    elseif self.shieldCooldown > 0 then
        -- Blue-ish when recharging (faded)
        love.graphics.setColor(0.3, 0.6, 1.0, self.shieldOpacity * 0.5)
    else
        -- Cyan when active
        love.graphics.setColor(0, 0.8, 1.0, self.shieldOpacity * 0.8)
    end

    -- Draw arc using line segments
    love.graphics.setLineWidth(2 + self.shieldLevel)
    for i = 0, segments - 1 do
        local a1 = startRad + i * angleStep
        local a2 = startRad + (i + 1) * angleStep

        local x1 = self.x + math.cos(a1) * radius
        local y1 = self.y + math.sin(a1) * radius
        local x2 = self.x + math.cos(a2) * radius
        local y2 = self.y + math.sin(a2) * radius

        love.graphics.line(x1, y1, x2, y2)
    end

    love.graphics.setLineWidth(1)

    -- Draw capacity indicator (small dots along the arc)
    local capacityPercent = self.shieldCurrentCapacity / self.shieldDamageCapacity
    if capacityPercent > 0 and self.shieldCooldown <= 0 then
        local dots = math.ceil(capacityPercent * 5)
        love.graphics.setColor(1, 1, 1, self.shieldOpacity)
        for i = 1, dots do
            local t = (i - 0.5) / 5
            local dotAngle = startRad + t * (endRad - startRad)
            local dotX = self.x + math.cos(dotAngle) * (radius + 4)
            local dotY = self.y + math.sin(dotAngle) * (radius + 4)
            love.graphics.circle("fill", dotX, dotY, 2)
        end
    end
end

-- Draw all attached tools
function Station:drawTools()
    for _, tool in ipairs(self.tools) do
        tool:draw()
    end
end

return Station
