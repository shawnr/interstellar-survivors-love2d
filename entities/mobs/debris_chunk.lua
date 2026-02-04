-- Debris Chunk MOB (Episode 4)
-- Tumbling metal fragment from an ancient war

class('DebrisChunk').extends(MOB)

DebrisChunk.DATA = {
    id = "debris_chunk",
    name = "Debris Chunk",
    description = "Twisted metal fragment from an ancient war",
    imagePath = "assets/images/episodes/ep4/ep4_debris_chunk",

    -- Stats - moderate
    baseHealth = 8,
    baseSpeed = 21,
    baseDamage = 5,
    rpValue = 8,

    -- Collision
    width = 14,
    height = 14,
    range = 1,
    emits = false,
}

function DebrisChunk:init(x, y, waveMultipliers)
    DebrisChunk.super.init(self, x, y, DebrisChunk.DATA, waveMultipliers)

    -- Tumble rotation (visual only)
    self.tumbleSpeed = 90 + math.random() * 120  -- degrees/sec
    self.rotation = math.random() * 360
end

function DebrisChunk:update(dt)
    DebrisChunk.super.update(self, dt)
    if not self.active then return end

    -- Apply tumble rotation
    self.rotation = self.rotation + self.tumbleSpeed * dt
    self:setRotation(self.rotation)
end

return DebrisChunk
