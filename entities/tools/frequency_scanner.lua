-- Frequency Scanner Tool
-- Fires fast beams with frequency damage

class('FrequencyScanner').extends(Tool)

FrequencyScanner.DATA = {
    id = "frequency_scanner",
    name = "Frequency Scanner",
    description = "Frequency damage. Dmg: 10",
    imagePath = "assets/images/tools/tool_frequency_scanner",
    projectileImage = "assets/images/tools/tool_frequency_scanner_beam",

    baseDamage = 10,
    fireRate = 1.2,
    projectileSpeed = 420,  -- px/sec
    pattern = "straight",
}

function FrequencyScanner:init()
    FrequencyScanner.super.init(self, FrequencyScanner.DATA)
end

function FrequencyScanner:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    self:createProjectile(fireX, fireY, firingAngle)

    -- Play sound
    if AudioManager then
        AudioManager:playSFX("tool_frequency_scanner", 0.4)
    end
end

-- Evolution: Harmonic Disruptor — 25 dmg, projectiles chain to nearby MOBs
function FrequencyScanner:evolve()
    FrequencyScanner.super.evolve(self)
    self.damage = 25
    self.chainOnHit = true
    self.chainRange = 60
    self.chainDamageMult = 0.5
    if GrantsSystem then
        self.damage = self.damage * GrantsSystem:getDamageMultiplier()
    end
end

function FrequencyScanner:createProjectile(x, y, angle)
    if GameplayScene and GameplayScene.projectilePool then
        local proj = GameplayScene.projectilePool:get(
            x, y, angle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage
        )
        if proj and self.chainOnHit then
            local chainRange = self.chainRange
            local chainDmgMult = self.chainDamageMult
            local projSpeed = self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0))
            local projImage = self.data.projectileImage
            proj.onHitCallback = function(hitProj, hitTarget)
                if not GameplayScene or not GameplayScene.projectilePool then return end
                local bestTarget, bestDistSq = nil, chainRange * chainRange
                for _, mob in ipairs(GameplayScene.mobs) do
                    if mob.active and mob ~= hitTarget then
                        local distSq = Utils.distanceSquared(hitTarget.x, hitTarget.y, mob.x, mob.y)
                        if distSq < bestDistSq then
                            bestDistSq = distSq
                            bestTarget = mob
                        end
                    end
                end
                if bestTarget then
                    local chainAngle = Utils.vectorToAngle(bestTarget.x - hitTarget.x, bestTarget.y - hitTarget.y)
                    GameplayScene.projectilePool:get(
                        hitTarget.x, hitTarget.y, chainAngle,
                        projSpeed, math.floor(hitProj.damage * chainDmgMult), projImage
                    )
                end
            end
        end
        return proj
    end
end

return FrequencyScanner
