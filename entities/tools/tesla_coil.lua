-- Tesla Coil Tool (Episode 3)
-- Chain lightning: hits nearest enemy, then chains to nearby enemies

class('TeslaCoil').extends(Tool)

TeslaCoil.DATA = {
    id = "tesla_coil",
    name = "Tesla Coil",
    description = "Chain lightning. Dmg: 8 chain",
    imagePath = "assets/images/tools/tool_tesla_coil",
    projectileImage = "assets/images/tools/tool_lightning_bolt",

    baseDamage = 8,
    fireRate = 0.7,
    projectileSpeed = 350,
    pattern = "chain",
}

function TeslaCoil:init()
    TeslaCoil.super.init(self, TeslaCoil.DATA)

    self.maxChains = 2
    self.chainRange = 70       -- Max distance for chain jump
    self.chainDamageMult = 0.85  -- Each chain does 85% of previous
end

function TeslaCoil:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    -- Find nearest enemy to fire at
    local target = self:findNearestEnemy(fireX, fireY)
    if target then
        -- Aim at the target
        firingAngle = Utils.vectorToAngle(target.x - fireX, target.y - fireY)
    end

    if GameplayScene and GameplayScene.projectilePool then
        local proj = GameplayScene.projectilePool:get(
            fireX, fireY, firingAngle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage
        )
        if proj then
            -- Set chain callback
            local chainRange = self.chainRange
            local chainDamageMult = self.chainDamageMult
            local remainingChains = self.maxChains
            local projSpeed = self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0))
            local projImage = self.data.projectileImage

            proj.onHitCallback = function(hitProj, hitTarget)
                self:spawnChain(hitTarget, hitProj.damage, remainingChains, chainRange, chainDamageMult, projSpeed, projImage)
            end
        end
    end

    if AudioManager then
        AudioManager:playSFX("tool_tesla_coil", 0.5)
    end
end

-- Spawn a chain projectile from a hit target toward the nearest unhit enemy
function TeslaCoil:spawnChain(fromTarget, prevDamage, chainsLeft, chainRange, chainDamageMult, projSpeed, projImage)
    if chainsLeft <= 0 then return end
    if not GameplayScene or not GameplayScene.projectilePool then return end

    -- Find nearest enemy to the hit target (excluding the hit target itself)
    local bestTarget = nil
    local bestDistSq = chainRange * chainRange

    for _, mob in ipairs(GameplayScene.mobs) do
        if mob.active and mob ~= fromTarget then
            local distSq = Utils.distanceSquared(fromTarget.x, fromTarget.y, mob.x, mob.y)
            if distSq < bestDistSq then
                bestDistSq = distSq
                bestTarget = mob
            end
        end
    end

    -- Also check boss
    if GameplayScene.boss and GameplayScene.boss.active and GameplayScene.boss ~= fromTarget then
        local distSq = Utils.distanceSquared(fromTarget.x, fromTarget.y, GameplayScene.boss.x, GameplayScene.boss.y)
        if distSq < bestDistSq then
            bestTarget = GameplayScene.boss
        end
    end

    if not bestTarget then return end

    -- Spawn chain projectile from hit target toward next target
    local chainDamage = math.floor(prevDamage * chainDamageMult)
    if chainDamage < 1 then chainDamage = 1 end

    local angle = Utils.vectorToAngle(bestTarget.x - fromTarget.x, bestTarget.y - fromTarget.y)

    local proj = GameplayScene.projectilePool:get(
        fromTarget.x, fromTarget.y, angle,
        projSpeed,
        chainDamage,
        projImage
    )
    if proj then
        local nextChainsLeft = chainsLeft - 1
        proj.onHitCallback = function(hitProj, hitTarget)
            self:spawnChain(hitTarget, hitProj.damage, nextChainsLeft, chainRange, chainDamageMult, projSpeed, projImage)
        end
    end
end

-- Find nearest enemy to a point
function TeslaCoil:findNearestEnemy(fromX, fromY)
    if not GameplayScene then return nil end

    local bestTarget = nil
    local bestDistSq = math.huge

    for _, mob in ipairs(GameplayScene.mobs) do
        if mob.active then
            local distSq = Utils.distanceSquared(fromX, fromY, mob.x, mob.y)
            if distSq < bestDistSq then
                bestDistSq = distSq
                bestTarget = mob
            end
        end
    end

    if GameplayScene.boss and GameplayScene.boss.active then
        local distSq = Utils.distanceSquared(fromX, fromY, GameplayScene.boss.x, GameplayScene.boss.y)
        if distSq < bestDistSq then
            bestTarget = GameplayScene.boss
        end
    end

    return bestTarget
end

function TeslaCoil:recalculateStats()
    TeslaCoil.super.recalculateStats(self)

    if self.level >= 3 then
        self.maxChains = 4
        self.chainRange = 90
    elseif self.level >= 2 then
        self.maxChains = 3
        self.chainRange = 80
    end
end

-- Evolution: Storm Generator — 16 dmg, +1 chain target
function TeslaCoil:evolve()
    TeslaCoil.super.evolve(self)
    self.damage = 16
    self.maxChains = self.maxChains + 1
    self.chainRange = 100
    self.chainDamageMult = 0.9
    if GrantsSystem then
        self.damage = self.damage * GrantsSystem:getDamageMultiplier()
    end
end

return TeslaCoil
