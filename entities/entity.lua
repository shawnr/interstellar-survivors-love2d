-- Entity Base Class
-- All game objects (station, tools, mobs, projectiles) extend this

class('Entity')

function Entity:init(x, y, imagePath)
    -- Position
    self.x = x or 0
    self.y = y or 0

    -- Velocity
    self.vx = 0
    self.vy = 0

    -- State
    self.active = true
    self.rotation = 0  -- Degrees (0 = UP in game coordinates)

    -- Visual
    self.image = nil
    self.width = 0
    self.height = 0
    self.originX = 0.5  -- Center by default
    self.originY = 0.5

    -- Load image if provided
    if imagePath then
        self:loadImage(imagePath)
    end
end

-- Load an image
function Entity:loadImage(path)
    self.image = Utils.getCachedImage(path .. ".png")
    if self.image then
        self.width = self.image:getWidth()
        self.height = self.image:getHeight()
    end
end

-- Set image directly
function Entity:setImage(img)
    self.image = img
    if img then
        self.width = img:getWidth()
        self.height = img:getHeight()
    end
end

-- Update method (override in subclasses)
function Entity:update(dt)
    -- Default: apply velocity
    if self.vx ~= 0 or self.vy ~= 0 then
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
    end
end

-- Draw the entity
function Entity:draw()
    if not self.active or not self.image then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- Rotate: game uses 0°=UP, Love2D uses 0°=RIGHT, so subtract 90°
    love.graphics.rotate(math.rad(self.rotation - 90))

    -- Draw centered on origin
    love.graphics.draw(
        self.image,
        -self.width * self.originX,
        -self.height * self.originY
    )

    love.graphics.pop()
end

-- Set position
function Entity:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Set velocity
function Entity:setVelocity(vx, vy)
    self.vx = vx
    self.vy = vy
end

-- Set rotation (degrees, 0 = UP)
function Entity:setRotation(angle)
    self.rotation = angle
end

-- Destroy the entity
function Entity:destroy()
    self.active = false
end

-- Check if entity is on screen
function Entity:isOnScreen(margin)
    margin = margin or 0
    return Utils.isOnScreen(self.x, self.y, margin)
end

-- Get bounding box for collision
function Entity:getBounds()
    return self.x - self.width/2, self.y - self.height/2, self.width, self.height
end

-- Get center position
function Entity:getCenter()
    return self.x, self.y
end

-- Get radius (for circular collision)
function Entity:getRadius()
    return math.max(self.width, self.height) / 2
end

-- Get size
function Entity:getSize()
    return self.width, self.height
end

return Entity
