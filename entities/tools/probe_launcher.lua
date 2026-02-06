-- Probe Launcher Tool (Episode 4)
-- Fires homing probes that track enemies

class('ProbeLauncher').extends(Tool)

ProbeLauncher.DATA = {
    id = "probe_launcher",
    name = "Probe Launcher",
    description = "Homing probes. Dmg: 5",
    imagePath = "assets/images/tools/tool_probe_launcher",
    projectileImage = "assets/images/tools/tool_probe",

    baseDamage = 5,
    fireRate = 0.8,
    projectileSpeed = 180,
    pattern = "homing",
}

function ProbeLauncher:init()
    ProbeLauncher.super.init(self, ProbeLauncher.DATA)

    self.homingStrength = 200
    self.probeCount = 1
    self.spreadAngle = 10  -- Spread between multiple probes
end

function ProbeLauncher:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    if GameplayScene and GameplayScene.projectilePool then
        if self.probeCount == 1 then
            -- Single probe
            local proj = GameplayScene.projectilePool:get(
                fireX, fireY, firingAngle,
                self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
                self.damage,
                self.data.projectileImage
            )
            if proj then
                proj.homing = true
                proj.homingStrength = self.homingStrength
            end
        else
            -- Multiple probes with spread
            local halfSpread = self.spreadAngle / 2
            local angleStep = self.spreadAngle / (self.probeCount - 1)

            for i = 0, self.probeCount - 1 do
                local angle = firingAngle - halfSpread + (angleStep * i)
                local proj = GameplayScene.projectilePool:get(
                    fireX, fireY, angle,
                    self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
                    self.damage,
                    self.data.projectileImage
                )
                if proj then
                    proj.homing = true
                    proj.homingStrength = self.homingStrength
                end
            end
        end
    end

    if AudioManager then
        AudioManager:playSFX("tool_probe_launcher", 0.3)
    end
end

function ProbeLauncher:recalculateStats()
    ProbeLauncher.super.recalculateStats(self)

    if self.level >= 3 then
        self.probeCount = 3
        self.homingStrength = 260
    elseif self.level >= 2 then
        self.probeCount = 2
        self.homingStrength = 230
    end
end

-- Evolution: Drone Carrier — 12 dmg, +2 probes per shot
function ProbeLauncher:evolve()
    ProbeLauncher.super.evolve(self)
    self.damage = 12
    self.probeCount = self.probeCount + 2
    self.homingStrength = 300
    self.spreadAngle = 20
    if GrantsSystem then
        self.damage = self.damage * GrantsSystem:getDamageMultiplier()
    end
end

return ProbeLauncher
