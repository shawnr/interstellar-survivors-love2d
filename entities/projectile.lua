-- Projectile Entity
-- Fired by tools, damages MOBs

class('Projectile').extends(Entity)

function Projectile:init()
    Projectile.super.init(self, 0, 0, nil)

    -- Projectile properties
    self.speed = 240       -- px/sec
    self.damage = 1
    self.angle = 0
    self.piercing = false
    self.hitCount = 0
    self.maxHits = 1

    -- Movement direction
    self.dx = 0
    self.dy = 0

    -- Track spawn position for minimum travel distance
    self.spawnX = 0
    self.spawnY = 0

    -- Max travel distance (0 = unlimited)
    self.maxTravelDist = 0

    -- Homing properties (optional, set after creation by tool)
    self.homing = false
    self.homingStrength = 0      -- Turn rate in degrees/sec
    self.homingTarget = nil      -- Reference to target entity

    -- Orbital properties (for SingularityCore-style orbiting projectiles)
    self.orbital = false
    self.orbitRadius = 0
    self.orbitAngle = 0
    self.orbitSpeed = 0          -- radians/sec
    self.orbitCenterX = 0
    self.orbitCenterY = 0

    -- Tick damage (for orbital projectiles that damage periodically)
    self.tickTimer = 0
    self.tickInterval = 0        -- 0 = normal single-hit behavior
    self.hitTargets = nil        -- Set of recently hit targets (reset on tick)

    -- Age/lifetime (for time-based despawn)
    self.age = 0
    self.lifetime = 0            -- 0 = no time limit

    -- Callback on hit (for chain lightning etc.)
    self.onHitCallback = nil     -- function(proj, target) called after hit

    -- Collision
    self.radius = 4
end

-- Reset projectile for reuse (object pooling)
function Projectile:reset(x, y, angle, speed, damage, imagePath, piercing)
    self.x = x
    self.y = y
    self.angle = angle
    self.speed = speed or 240
    self.damage = damage or 1
    self.piercing = piercing or false
    self.hitCount = 0
    self.maxHits = self.piercing and 2 or 1
    self.active = true

    -- Track spawn position
    self.spawnX = x
    self.spawnY = y

    -- Reset max travel distance
    self.maxTravelDist = 0

    -- Reset homing (configured by tool after pool:get())
    self.homing = false
    self.homingStrength = 0
    self.homingTarget = nil

    -- Reset orbital
    self.orbital = false
    self.orbitRadius = 0
    self.orbitAngle = 0
    self.orbitSpeed = 0
    self.orbitCenterX = 0
    self.orbitCenterY = 0

    -- Reset tick damage
    self.tickTimer = 0
    self.tickInterval = 0
    self.hitTargets = nil

    -- Reset age/lifetime
    self.age = 0
    self.lifetime = 0

    -- Reset callback
    self.onHitCallback = nil

    -- Calculate direction
    self.dx, self.dy = Utils.angleToVector(angle)

    -- Load image
    if imagePath then
        self:loadImage(imagePath)
    end

    -- Set rotation to face movement direction
    self:setRotation(angle)
end

function Projectile:update(dt)
    if not self.active then return end

    -- Orbital projectiles use entirely different movement
    if self.orbital then
        self:updateOrbital(dt)
        return
    end

    -- Age tracking for lifetime-based despawn
    if self.lifetime > 0 then
        self.age = self.age + dt
        if self.age >= self.lifetime then
            self:deactivate()
            return
        end
    end

    -- Homing behavior: steer toward target
    if self.homing and self.homingStrength > 0 then
        local target = self:findHomingTarget()
        if target then
            local targetDx = target.x - self.x
            local targetDy = target.y - self.y
            local desiredAngle = Utils.vectorToAngle(targetDx, targetDy)
            local currentAngle = self.angle

            -- Calculate shortest angle difference
            local angleDiff = (desiredAngle - currentAngle) % 360
            if angleDiff > 180 then angleDiff = angleDiff - 360 end

            -- Turn toward target, clamped by turn rate
            local maxTurn = self.homingStrength * dt
            local turnAmount = Utils.clamp(angleDiff, -maxTurn, maxTurn)

            self.angle = Utils.normalizeAngle(self.angle + turnAmount)
            self.dx, self.dy = Utils.angleToVector(self.angle)
        end
    end

    -- Move in direction
    self.x = self.x + self.dx * self.speed * dt
    self.y = self.y + self.dy * self.speed * dt

    -- Check max travel distance
    if self.maxTravelDist > 0 then
        local distSq = Utils.distanceSquared(self.x, self.y, self.spawnX, self.spawnY)
        if distSq > self.maxTravelDist * self.maxTravelDist then
            self:deactivate()
            return
        end
    end

    -- Check if off screen
    if not self:isOnScreen(20) then
        self:deactivate()
    end
end

-- Update orbital projectile (orbits around a center point, tick damages)
function Projectile:updateOrbital(dt)
    -- Age tracking
    self.age = self.age + dt
    if self.lifetime > 0 and self.age >= self.lifetime then
        self:deactivate()
        return
    end

    -- Update orbit angle and position
    self.orbitAngle = self.orbitAngle + self.orbitSpeed * dt
    self.x = self.orbitCenterX + math.cos(self.orbitAngle) * self.orbitRadius
    self.y = self.orbitCenterY + math.sin(self.orbitAngle) * self.orbitRadius

    -- Update rotation to face orbit direction
    local facingAngle = math.deg(self.orbitAngle + math.pi / 2)
    self:setRotation(facingAngle)

    -- Tick timer: reset hitTargets periodically so orbital can re-damage
    if self.tickInterval > 0 then
        self.tickTimer = self.tickTimer + dt
        if self.tickTimer >= self.tickInterval then
            self.tickTimer = self.tickTimer - self.tickInterval
            self.hitTargets = {}  -- Reset hit tracking for next tick
        end
    end
end

-- Called when projectile hits something
function Projectile:onHit(target)
    self.hitCount = self.hitCount + 1

    -- Deactivate if max hits reached
    if self.hitCount >= self.maxHits then
        self:deactivate()
    end
end

-- Deactivate for pooling
function Projectile:deactivate()
    self.active = false
end

-- Get damage value
function Projectile:getDamage()
    return self.damage
end

-- Find best homing target (nearest active mob or boss)
function Projectile:findHomingTarget()
    -- If we have a specific target and it's still active, keep it
    if self.homingTarget and self.homingTarget.active then
        return self.homingTarget
    end

    -- Find nearest active mob
    if not GameplayScene then return nil end

    local bestTarget = nil
    local bestDistSq = math.huge

    for _, mob in ipairs(GameplayScene.mobs) do
        if mob.active then
            local distSq = Utils.distanceSquared(self.x, self.y, mob.x, mob.y)
            if distSq < bestDistSq then
                bestDistSq = distSq
                bestTarget = mob
            end
        end
    end

    -- Also check boss
    if GameplayScene.boss and GameplayScene.boss.active then
        local distSq = Utils.distanceSquared(self.x, self.y, GameplayScene.boss.x, GameplayScene.boss.y)
        if distSq < bestDistSq then
            bestTarget = GameplayScene.boss
        end
    end

    self.homingTarget = bestTarget
    return bestTarget
end

-- Get travel distance from spawn
function Projectile:getTravelDistance()
    return Utils.distance(self.x, self.y, self.spawnX, self.spawnY)
end


-- ============================================
-- Projectile Pool (Object Pooling)
-- ============================================

class('ProjectilePool')

function ProjectilePool:init(initialSize)
    self.pool = {}      -- Inactive projectiles
    self.active = {}    -- Active projectiles

    -- Pre-allocate projectiles
    initialSize = initialSize or Constants.MAX_ACTIVE_PROJECTILES
    for i = 1, initialSize do
        local proj = Projectile()
        proj.active = false
        table.insert(self.pool, proj)
    end

    print("ProjectilePool initialized with " .. initialSize .. " projectiles")
end

-- Get a projectile from the pool
function ProjectilePool:get(x, y, angle, speed, damage, imagePath, piercing)
    local proj

    if #self.pool > 0 then
        -- Reuse from pool
        proj = table.remove(self.pool)
    else
        -- Create new if pool empty
        proj = Projectile()
        print("ProjectilePool: Created new projectile (pool exhausted)")
    end

    -- Reset and configure
    proj:reset(x, y, angle, speed, damage, imagePath, piercing)

    -- Add to active list
    table.insert(self.active, proj)

    return proj
end

-- Update all active projectiles (swap-and-pop for O(1) removal)
function ProjectilePool:update(dt)
    local active = self.active
    local pool = self.pool
    local n = #active
    local i = 1

    while i <= n do
        local proj = active[i]
        if proj.active then
            proj:update(dt)
            i = i + 1
        else
            -- Swap-and-pop: O(1) removal
            active[i] = active[n]
            active[n] = nil
            n = n - 1
            pool[#pool + 1] = proj
        end
    end
end

-- Draw all active projectiles
function ProjectilePool:draw()
    for _, proj in ipairs(self.active) do
        if proj.active then
            proj:draw()
        end
    end
end

-- Get all active projectiles
function ProjectilePool:getActive()
    return self.active
end

-- Get count of active projectiles
function ProjectilePool:getActiveCount()
    return #self.active
end

-- Release all projectiles
function ProjectilePool:releaseAll()
    for i = #self.active, 1, -1 do
        local proj = self.active[i]
        proj:deactivate()
        table.insert(self.pool, proj)
    end
    self.active = {}
end


-- ============================================
-- Enemy Projectile (fired by MOBs at station)
-- ============================================

class('EnemyProjectile').extends(Entity)

function EnemyProjectile:init()
    EnemyProjectile.super.init(self, 0, 0, nil)

    -- Projectile properties
    self.speed = 90
    self.damage = 1
    self.angle = 0
    self.effect = nil  -- Special effect like "slow"

    -- Movement direction
    self.dx = 0
    self.dy = 0

    -- Collision
    self.radius = 4
end

function EnemyProjectile:reset(x, y, angle, speed, damage, imagePath, effect)
    self.x = x
    self.y = y
    self.angle = angle
    self.speed = speed or 90
    self.damage = damage or 1
    self.effect = effect
    self.active = true

    -- Calculate direction
    self.dx, self.dy = Utils.angleToVector(angle)

    -- Load image
    if imagePath then
        self:loadImage(imagePath)
    end

    -- Set rotation
    self:setRotation(angle)
end

function EnemyProjectile:update(dt)
    if not self.active then return end

    -- Move in direction
    self.x = self.x + self.dx * self.speed * dt
    self.y = self.y + self.dy * self.speed * dt

    -- Check if off screen
    if not self:isOnScreen(20) then
        self:deactivate()
    end
end

function EnemyProjectile:deactivate()
    self.active = false
end

function EnemyProjectile:getDamage()
    return self.damage
end

function EnemyProjectile:getEffect()
    return self.effect
end


-- ============================================
-- Enemy Projectile Pool
-- ============================================

class('EnemyProjectilePool')

function EnemyProjectilePool:init(initialSize)
    self.pool = {}
    self.active = {}

    initialSize = initialSize or 30
    for i = 1, initialSize do
        local proj = EnemyProjectile()
        proj.active = false
        table.insert(self.pool, proj)
    end

    print("EnemyProjectilePool initialized with " .. initialSize .. " projectiles")
end

function EnemyProjectilePool:get(x, y, angle, speed, damage, imagePath, effect)
    local proj

    if #self.pool > 0 then
        proj = table.remove(self.pool)
    else
        proj = EnemyProjectile()
    end

    proj:reset(x, y, angle, speed, damage, imagePath, effect)
    table.insert(self.active, proj)

    return proj
end

function EnemyProjectilePool:update(dt)
    local active = self.active
    local pool = self.pool
    local n = #active
    local i = 1

    while i <= n do
        local proj = active[i]
        if proj.active then
            proj:update(dt)
            i = i + 1
        else
            -- Swap-and-pop
            active[i] = active[n]
            active[n] = nil
            n = n - 1
            pool[#pool + 1] = proj
        end
    end
end

function EnemyProjectilePool:draw()
    for _, proj in ipairs(self.active) do
        if proj.active then
            proj:draw()
        end
    end
end

function EnemyProjectilePool:getActive()
    return self.active
end

function EnemyProjectilePool:releaseAll()
    for i = #self.active, 1, -1 do
        local proj = self.active[i]
        proj:deactivate()
        table.insert(self.pool, proj)
    end
    self.active = {}
end

return ProjectilePool
