-- Singularity Core Tool (Episode 3)
-- Creates orbiting projectiles around the station that damage enemies on contact

class('SingularityCore').extends(Tool)

SingularityCore.DATA = {
    id = "singularity_core",
    name = "Singularity Core",
    description = "Orbiting damage field. Dmg: 3/tick",
    imagePath = "assets/images/tools/tool_singularity_core",
    projectileImage = "assets/images/tools/tool_singularity_orb",

    baseDamage = 3,
    fireRate = 0.2,  -- Slow fire rate (spawns orbs infrequently)
    projectileSpeed = 0,  -- Not used for orbital
    pattern = "orbital",
}

function SingularityCore:init()
    SingularityCore.super.init(self, SingularityCore.DATA)

    self.maxOrbs = 2
    self.orbLifetime = 10       -- Seconds
    self.orbitRadius = 60       -- Distance from station center
    self.orbitSpeed = 2.0       -- Radians per second
    self.tickInterval = 0.167   -- ~6 ticks per second
    self.activeOrbs = {}        -- Track active orbital projectiles
end

function SingularityCore:fire()
    -- Clean up deactivated orbs
    local n = #self.activeOrbs
    local i = 1
    while i <= n do
        if not self.activeOrbs[i].active then
            self.activeOrbs[i] = self.activeOrbs[n]
            self.activeOrbs[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end

    -- Don't spawn if at max orbs
    if #self.activeOrbs >= self.maxOrbs then
        return
    end

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    if GameplayScene and GameplayScene.projectilePool then
        -- Spawn new orbital at a random starting angle
        local startAngle = math.random() * math.pi * 2

        local proj = GameplayScene.projectilePool:get(
            Constants.STATION_CENTER_X + math.cos(startAngle) * self.orbitRadius,
            Constants.STATION_CENTER_Y + math.sin(startAngle) * self.orbitRadius,
            0,  -- angle doesn't matter for orbital
            0,  -- speed doesn't matter for orbital
            self.damage,
            self.data.projectileImage
        )
        if proj then
            -- Configure as orbital projectile
            proj.orbital = true
            proj.orbitRadius = self.orbitRadius
            proj.orbitAngle = startAngle
            proj.orbitSpeed = self.orbitSpeed
            proj.orbitCenterX = Constants.STATION_CENTER_X
            proj.orbitCenterY = Constants.STATION_CENTER_Y
            proj.lifetime = self.orbLifetime
            proj.tickInterval = self.tickInterval
            proj.hitTargets = {}
            -- Orbital projectiles don't deactivate on hit
            proj.piercing = true
            proj.maxHits = 99999

            table.insert(self.activeOrbs, proj)
        end
    end

    if AudioManager then
        AudioManager:playSFX("tool_frequency_scanner", 0.3)
    end
end

function SingularityCore:recalculateStats()
    SingularityCore.super.recalculateStats(self)

    if self.level >= 3 then
        self.maxOrbs = 3
        self.orbitSpeed = 2.8
        self.orbLifetime = 12
    elseif self.level >= 2 then
        self.maxOrbs = 3
        self.orbitSpeed = 2.4
        self.orbLifetime = 11
    end
end

return SingularityCore
