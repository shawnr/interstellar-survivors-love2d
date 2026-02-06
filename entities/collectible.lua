-- Collectible Entity
-- Items dropped by MOBs that can be collected

class('Collectible').extends(Entity)

-- Collectible types
Collectible.TYPES = {
    RP = "rp",              -- Research Points (XP)
    HEALTH = "health",      -- Heals station
    BONUS_ITEM = "bonus_item",  -- Random bonus item
}

function Collectible:init()
    Collectible.super.init(self, 0, 0, nil)

    -- Properties
    self.collectibleType = Collectible.TYPES.RP
    self.value = 1
    self.active = false

    -- Movement (in px/sec)
    self.speed = Constants.COLLECTIBLE_DRIFT_SPEED
    self.maxSpeed = 120        -- px/sec
    self.passiveDrift = 2.4    -- px/sec

    -- Collection
    self.collectRadius = 50
    self.pickupRadius = 20

    -- Animation
    self.bobOffset = 0
    self.bobSpeed = 5
    self.bobAmount = 2

    -- Lifetime
    self.lifetime = 15
    self.age = 0

    -- Visual
    self.visualSize = 8
    self.blinking = false
end

-- Reset collectible for reuse (object pooling)
function Collectible:reset(x, y, collectibleType, value)
    self.x = x
    self.y = y
    self.collectibleType = collectibleType or Collectible.TYPES.RP
    self.value = value or 1
    self.active = true

    -- Movement
    self.speed = Constants.COLLECTIBLE_DRIFT_SPEED
    self.maxSpeed = 120
    self.passiveDrift = 2.4

    -- Collection
    local baseRadius = 50
    if BonusItemsSystem then
        baseRadius = baseRadius * (1 + BonusItemsSystem:getCollectRangeBonus())
    end
    self.collectRadius = baseRadius
    self.pickupRadius = 20

    -- Animation
    self.bobOffset = math.random() * math.pi * 2
    self.bobSpeed = 5
    self.bobAmount = 2

    -- Lifetime
    self.lifetime = 15
    self.age = 0
    self.blinking = false
end

function Collectible:update(dt)
    if not self.active then return end

    -- Don't update if game is paused
    if GameplayScene and GameplayScene.isPaused then
        return
    end

    -- Age and check lifetime
    self.age = self.age + dt
    if self.age >= self.lifetime then
        self:collect(false)
        return
    end

    -- Calculate distance to station
    local dx = Constants.STATION_CENTER_X - self.x
    local dy = Constants.STATION_CENTER_Y - self.y
    local distSq = dx * dx + dy * dy
    local collectRadiusSq = self.collectRadius * self.collectRadius
    local pickupRadiusSq = self.pickupRadius * self.pickupRadius

    -- Salvage Drone auto-collection: RP orbs get pulled from extended range
    if self.collectibleType == Collectible.TYPES.RP then
        local autoRange = BonusItemsSystem and BonusItemsSystem:getAutoCollectRange() or 0
        if autoRange > 0 and distSq < autoRange * autoRange and distSq > collectRadiusSq then
            -- Pull toward station at higher speed than passive drift
            local dist = math.sqrt(distSq)
            local pullSpeed = 180
            local invDist = 1 / dist
            self.x = self.x + dx * invDist * pullSpeed * dt
            self.y = self.y + dy * invDist * pullSpeed * dt
            return  -- Skip normal movement
        end
    end

    -- Move toward station
    if distSq > 1 then
        if distSq < collectRadiusSq then
            -- Within collect radius: accelerate toward station
            local dist = math.sqrt(distSq)
            local speedMult = 1 + (1 - dist / self.collectRadius) * 3
            local currentSpeed = math.min(self.speed * speedMult, self.maxSpeed)
            local invDist = 1 / dist
            self.x = self.x + dx * invDist * currentSpeed * dt
            self.y = self.y + dy * invDist * currentSpeed * dt
        elseif self.collectibleType == Collectible.TYPES.RP then
            -- RP collectibles: slow passive drift toward station
            local invDist = 1 / math.sqrt(distSq)
            self.x = self.x + dx * invDist * self.passiveDrift * dt
            self.y = self.y + dy * invDist * self.passiveDrift * dt
        end
    end

    -- Check for pickup
    if distSq < pickupRadiusSq then
        self:collect(true)
    end

    -- Fade out near end of lifetime
    if self.age > self.lifetime - 2 then
        self.blinking = true
    end
end

function Collectible:collect(applyEffect)
    if not self.active then return end

    self.active = false

    if applyEffect then
        -- Play collect sound
        if AudioManager then
            if self.collectibleType == Collectible.TYPES.HEALTH or self.collectibleType == Collectible.TYPES.BONUS_ITEM then
                AudioManager:playSFX("collectible_rare", 0.6)
            else
                AudioManager:playSFX("collectible_get", 0.3)
            end
        end

        if self.collectibleType == Collectible.TYPES.RP then
            -- Floating text
            if VFXManager then
                VFXManager:addFloatingText("+" .. math.floor(self.value) .. " RP", self.x, self.y, {1, 0.9, 0.2})
            end

            -- Award RP
            if GameManager then
                GameManager:awardRP(self.value)
            end
        elseif self.collectibleType == Collectible.TYPES.HEALTH then
            -- Heal station
            if GameplayScene and GameplayScene.station then
                GameplayScene.station:heal(self.value)
            end
        elseif self.collectibleType == Collectible.TYPES.BONUS_ITEM then
            -- Grant random bonus item
            if BonusItemsSystem and GameplayScene and GameplayScene.station then
                local item = BonusItemsSystem:grantRandom(GameplayScene.station)
                if item and VFXManager then
                    VFXManager:addFloatingText(item.name, self.x, self.y, {0.2, 1, 0.5})
                end
            end
        end
    end
end

function Collectible:draw()
    if not self.active then return end

    -- Blinking effect near death
    if self.blinking then
        local blinkRate = 10
        if math.floor(self.age * blinkRate) % 2 ~= 0 then
            return  -- Skip drawing (invisible)
        end
    end

    -- Bobbing animation
    local bob = math.sin(self.age * self.bobSpeed + self.bobOffset) * self.bobAmount
    local drawY = self.y + bob

    -- Draw based on type (with gentle pulse)
    local pulse = 1 + math.sin(self.age * 4) * 0.15
    local size = self.visualSize * pulse

    if self.collectibleType == Collectible.TYPES.RP then
        -- RP orb: filled circle with dot
        love.graphics.circle("fill", self.x, drawY, size/2 - 1)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", self.x, drawY, 2)
    elseif self.collectibleType == Collectible.TYPES.HEALTH then
        -- Health: cross/plus shape
        love.graphics.rectangle("fill", self.x - size/2 + 2, drawY - 1, size - 4, 2)
        love.graphics.rectangle("fill", self.x - 1, drawY - size/2 + 2, 2, size - 4)
    elseif self.collectibleType == Collectible.TYPES.BONUS_ITEM then
        -- Bonus item: green diamond shape
        love.graphics.setColor(0.2, 1, 0.5)
        local half = size / 2
        love.graphics.polygon("fill",
            self.x, drawY - half,
            self.x + half, drawY,
            self.x, drawY + half,
            self.x - half, drawY)
    else
        -- Default: simple circle
        love.graphics.circle("fill", self.x, drawY, size/2 - 1)
    end
end

-- Deactivate for pooling
function Collectible:deactivate()
    self.active = false
end


-- ============================================
-- Collectible Pool (Object Pooling)
-- ============================================

class('CollectiblePool')

function CollectiblePool:init(initialSize)
    self.pool = {}
    self.active = {}

    -- Pre-allocate collectibles
    initialSize = initialSize or 100
    for i = 1, initialSize do
        local c = Collectible()
        c.active = false
        table.insert(self.pool, c)
    end

    print("CollectiblePool initialized with " .. initialSize .. " collectibles")
end

-- Get a collectible from the pool
function CollectiblePool:get(x, y, collectibleType, value)
    local c

    if #self.pool > 0 then
        c = table.remove(self.pool)
    else
        c = Collectible()
        print("CollectiblePool: Created new collectible (pool exhausted)")
    end

    c:reset(x, y, collectibleType, value)
    table.insert(self.active, c)

    return c
end

-- Update all active collectibles
function CollectiblePool:update(dt)
    local active = self.active
    local pool = self.pool
    local n = #active
    local i = 1

    while i <= n do
        local c = active[i]
        if c.active then
            c:update(dt)
            i = i + 1
        else
            -- Swap-and-pop
            active[i] = active[n]
            active[n] = nil
            n = n - 1
            pool[#pool + 1] = c
        end
    end
end

-- Draw all active collectibles
function CollectiblePool:draw()
    for _, c in ipairs(self.active) do
        if c.active then
            c:draw()
        end
    end
end

-- Get all active collectibles
function CollectiblePool:getActive()
    return self.active
end

-- Get count of active collectibles
function CollectiblePool:getActiveCount()
    return #self.active
end

-- Release all collectibles
function CollectiblePool:releaseAll()
    for i = #self.active, 1, -1 do
        local c = self.active[i]
        c:deactivate()
        table.insert(self.pool, c)
    end
    self.active = {}
end

return CollectiblePool
