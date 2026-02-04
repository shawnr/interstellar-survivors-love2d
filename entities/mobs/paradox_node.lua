-- Paradox Node MOB (Episode 3)
-- Slow, heavily armored logical impossibility

class('ParadoxNode').extends(MOB)

ParadoxNode.DATA = {
    id = "paradox_node",
    name = "Paradox Node",
    description = "This statement is false",
    imagePath = "assets/images/episodes/ep3/ep3_paradox_node",

    -- Stats - slow but very tough
    baseHealth = 18,
    baseSpeed = 15,
    baseDamage = 10,
    rpValue = 25,

    -- Collision
    width = 20,
    height = 20,
    range = 1,
    emits = false,
}

function ParadoxNode:init(x, y, waveMultipliers)
    ParadoxNode.super.init(self, x, y, ParadoxNode.DATA, waveMultipliers)
end

return ParadoxNode
