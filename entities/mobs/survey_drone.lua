-- Survey Drone MOB (Episode 2)
-- Fast reconnaissance drone that rams into the station

class('SurveyDrone').extends(MOB)

SurveyDrone.DATA = {
    id = "survey_drone",
    name = "Survey Drone",
    description = "Fast reconnaissance drone",
    imagePath = "assets/images/episodes/ep2/ep2_survey_drone",

    -- Stats - fast and fragile
    baseHealth = 6,
    baseSpeed = 30,     -- px/sec
    baseDamage = 4,
    rpValue = 10,

    -- Collision
    width = 14,
    height = 14,
    range = 1,
    emits = false,  -- Ramming MOB
}

function SurveyDrone:init(x, y, waveMultipliers)
    SurveyDrone.super.init(self, x, y, SurveyDrone.DATA, waveMultipliers)
end

return SurveyDrone
