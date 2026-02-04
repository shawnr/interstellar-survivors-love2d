-- Citation Platform MOB (Episode 5)
-- Academic platform that shares research aggressively via data beams

class('CitationPlatform').extends(MOB)

CitationPlatform.DATA = {
    id = "citation_platform",
    name = "Citation Platform",
    description = "Sharing research aggressively",
    imagePath = "assets/images/episodes/ep5/ep5_citation_platform",
    projectileImage = "assets/images/episodes/ep5/ep5_citation_beam",

    -- Stats - medium, ranged
    baseHealth = 16,
    baseSpeed = 15,
    baseDamage = 7,
    rpValue = 22,

    -- Collision
    width = 20,
    height = 20,
    range = 90,
    emits = true,

    -- Attack properties (used by MOB base class)
    fireRate = 0.5,
    projectileSpeed = 105,
}

function CitationPlatform:init(x, y, waveMultipliers)
    CitationPlatform.super.init(self, x, y, CitationPlatform.DATA, waveMultipliers)
end

return CitationPlatform
