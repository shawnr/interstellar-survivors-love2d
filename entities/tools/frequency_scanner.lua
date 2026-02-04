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

return FrequencyScanner
