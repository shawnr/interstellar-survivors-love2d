-- Input Manager
-- Handles keyboard A/D rotation controls (emulating crank)

InputManager = {
    -- Rotation state
    targetRotation = 0,
    currentRotation = 0,

    -- Key states
    keys = {},

    -- Edge detection: keys pressed/released this frame
    justPressedKeys = {},
    justReleasedKeys = {},
    buttonState = {},

    -- Speed multiplier (for slow effects)
    rotationSpeedMultiplier = 1.0,

    -- Control inversion (for ImprobabilityEngine boss)
    controlInverted = false,
}

function InputManager:init()
    self.targetRotation = 0
    self.currentRotation = 0
    self.keys = {}
    self.justPressedKeys = {}
    self.justReleasedKeys = {}
    self.buttonState = {}
    self.rotationSpeedMultiplier = 1.0
    self.controlInverted = false
end

function InputManager:update(dt)
    -- Accumulate rotation based on held keys (with slow effect multiplier)
    local bonusMultiplier = 1.0
    if BonusItemsSystem then
        bonusMultiplier = bonusMultiplier + BonusItemsSystem:getRotationSpeedBonus()
    end
    local rotationSpeed = Constants.ROTATION_SPEED * dt * self.rotationSpeedMultiplier * bonusMultiplier

    -- Direction: normally left=-1, right=+1; inverted swaps these
    local leftDir = self.controlInverted and 1 or -1
    local rightDir = self.controlInverted and -1 or 1

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.targetRotation = self.targetRotation + rotationSpeed * leftDir
    end

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.targetRotation = self.targetRotation + rotationSpeed * rightDir
    end

    -- Smooth current rotation toward target (angle-aware to avoid glitch at 0/360)
    self.currentRotation = Utils.lerpAngle(
        self.currentRotation,
        self.targetRotation,
        Constants.ROTATION_SMOOTHING
    )

    -- Normalize both to 0-360 after lerp
    self.currentRotation = Utils.normalizeAngle(self.currentRotation)
    self.targetRotation = Utils.normalizeAngle(self.targetRotation)
end

-- Call at end of love.update() to clear per-frame input state
function InputManager:endFrame()
    self.justPressedKeys = {}
    self.justReleasedKeys = {}
end

-- Get the current smoothed rotation
function InputManager:getRotation()
    return self.currentRotation
end

-- Get change in rotation since last frame
function InputManager:getRotationDelta()
    return 0
end

-- Key press/release handlers (called from main.lua)
function InputManager:onKeyPressed(key)
    self.buttonState[key] = true
    self.justPressedKeys[key] = true
end

function InputManager:onKeyReleased(key)
    self.buttonState[key] = false
    self.justReleasedKeys[key] = true
end

-- Edge detection for button presses (true only on the frame the key was pressed)
function InputManager:justPressed(key)
    return self.justPressedKeys[key] == true
end

function InputManager:isPressed(key)
    return self.buttonState[key] == true
end

-- Set rotation speed multiplier (for slow effects)
function InputManager:setRotationSpeedMultiplier(multiplier)
    self.rotationSpeedMultiplier = multiplier
end

-- Get rotation speed multiplier
function InputManager:getRotationSpeedMultiplier()
    return self.rotationSpeedMultiplier
end

-- Set control inversion
function InputManager:setControlInversion(inverted)
    self.controlInverted = inverted
end

return InputManager
