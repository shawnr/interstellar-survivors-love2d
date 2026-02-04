-- Phase Disruptor Tool (Episode 4)
-- Fires a piercing beam that passes through many enemies

class('PhaseDisruptor').extends(Tool)

PhaseDisruptor.DATA = {
    id = "phase_disruptor",
    name = "Phase Disruptor",
    description = "Piercing beam. Dmg: 15",
    imagePath = "assets/images/tools/tool_phase_disruptor",
    projectileImage = "assets/images/tools/tool_phase_beam",

    baseDamage = 15,
    fireRate = 0.4,
    projectileSpeed = 450,
    pattern = "piercing",
}

function PhaseDisruptor:init()
    PhaseDisruptor.super.init(self, PhaseDisruptor.DATA)
end

function PhaseDisruptor:fire()
    local firingAngle = self.station:getSlotFiringAngle(self.slotIndex)
    local offsetDist = 12
    local dx, dy = Utils.angleToVector(firingAngle)
    local fireX = self.x + dx * offsetDist
    local fireY = self.y + dy * offsetDist

    -- Muzzle flash
    self.muzzleFlashTimer = 0.05

    if GameplayScene and GameplayScene.projectilePool then
        local proj = GameplayScene.projectilePool:get(
            fireX, fireY, firingAngle,
            self.projectileSpeed * (1 + (self.projectileSpeedBonus or 0)),
            self.damage,
            self.data.projectileImage,
            true  -- piercing
        )
        if proj then
            proj.maxHits = 99  -- Effectively unlimited piercing
            proj.hitTargets = {}  -- Track which targets have been hit
        end
    end

    if AudioManager then
        AudioManager:playSFX("tool_frequency_scanner", 0.4)
    end
end

return PhaseDisruptor
