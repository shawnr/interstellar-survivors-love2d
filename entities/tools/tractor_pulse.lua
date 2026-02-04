-- Tractor Pulse Tool
-- Pulls collectibles toward station (no damage)

class('TractorPulse').extends(Tool)

TractorPulse.DATA = {
    id = "tractor_pulse",
    name = "Tractor Pulse",
    description = "Pulls collectibles. No dmg",
    imagePath = "assets/images/tools/tool_tractor_pulse",

    baseDamage = 0,
    fireRate = 0.8,
    projectileSpeed = 0,
    pattern = "pulse",
}

function TractorPulse:init()
    TractorPulse.super.init(self, TractorPulse.DATA)
    self.rangeBonus = 0
    self.pullRange = 80
    self.upgraded = false
end

function TractorPulse:fire()
    -- Tractor pulse affects collectibles
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)

    -- Pull collectibles
    self:pullCollectibles(firingAngle)

    -- Create visual effect
    local range = self.pullRange * (1 + self.rangeBonus)
    if GameplayScene and GameplayScene.createPulseEffect then
        GameplayScene:createPulseEffect(
            Constants.STATION_CENTER_X,
            Constants.STATION_CENTER_Y,
            range,
            0.3,
            "tractor"
        )
    end

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_tractor_pulse", 0.4)
    end
end

function TractorPulse:pullCollectibles(firingAngle)
    if not GameplayScene or not GameplayScene.collectiblePool then return false end

    local range = self.pullRange * (1 + self.rangeBonus)
    local pullStrength = self.upgraded and 240 or 150  -- px/sec
    local pulledAny = false
    local dt = 1/60  -- Approximate frame time

    -- Pull all collectibles within range
    local collectibles = GameplayScene.collectiblePool:getActive()
    for _, collectible in ipairs(collectibles) do
        if collectible.active then
            local dx = collectible.x - Constants.STATION_CENTER_X
            local dy = collectible.y - Constants.STATION_CENTER_Y
            local dist = math.sqrt(dx * dx + dy * dy)

            -- Pull if within range
            if dist < range and dist > 15 then
                -- Pull toward station
                local pullX = -dx / dist * pullStrength * dt
                local pullY = -dy / dist * pullStrength * dt
                collectible.x = collectible.x + pullX
                collectible.y = collectible.y + pullY
                pulledAny = true
            end
        end
    end

    return pulledAny
end

-- Override createProjectile to do nothing (tractor doesn't fire projectiles)
function TractorPulse:createProjectile(x, y, angle)
    -- No projectile for tractor pulse
end

return TractorPulse
