-- Utility functions for Interstellar Survivors
-- Ported from Playdate version for Love2D

Utils = {}

-- Image cache for performance
Utils.imageCache = {}

-- Icon cache (processed with alpha transparency)
Utils.iconCache = {}

function Utils.getCachedImage(path)
    if not Utils.imageCache[path] then
        local success, img = pcall(love.graphics.newImage, path)
        if success and img then
            Utils.imageCache[path] = img
        else
            print("Warning: Could not load image: " .. path)
            return nil
        end
    end
    return Utils.imageCache[path]
end

-- Load a 1-bit grayscale icon and process it for proper alpha rendering.
-- Converts black pixels to white (full alpha) and white pixels to transparent.
-- The result can be tinted to any color via love.graphics.setColor().
function Utils.getCachedIcon(path)
    if Utils.iconCache[path] then
        return Utils.iconCache[path]
    end

    local success, imageData = pcall(love.image.newImageData, path)
    if not success or not imageData then
        print("Warning: Could not load icon: " .. path)
        return nil
    end

    -- Process pixels: dark → white+opaque, light → transparent
    imageData:mapPixel(function(x, y, r, g, b, a)
        local brightness = r * 0.299 + g * 0.587 + b * 0.114
        if brightness < 0.5 then
            return 1, 1, 1, 1  -- Dark pixel → white, fully opaque
        else
            return 1, 1, 1, 0  -- Light pixel → transparent
        end
    end)

    local img = love.graphics.newImage(imageData)
    Utils.iconCache[path] = img
    return img
end

function Utils.clearImageCache()
    Utils.imageCache = {}
    Utils.iconCache = {}
end

-- Linear interpolation
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Angle-aware lerp (takes shortest path across the 0/360 boundary)
function Utils.lerpAngle(a, b, t)
    local diff = (b - a) % 360
    if diff > 180 then
        diff = diff - 360
    end
    return a + diff * t
end

-- Clamp a value between min and max
function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Distance between two points
function Utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Distance squared (faster, good for comparisons)
function Utils.distanceSquared(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

-- Normalize an angle to 0-360 range
function Utils.normalizeAngle(angle)
    angle = angle % 360
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

-- Convert degrees to radians
function Utils.degToRad(degrees)
    return degrees * (math.pi / 180)
end

-- Convert radians to degrees
function Utils.radToDeg(radians)
    return radians * (180 / math.pi)
end

-- Get direction vector from angle (in degrees)
-- Note: 0° = UP in game coordinates
function Utils.angleToVector(angleDegrees)
    local rad = Utils.degToRad(angleDegrees)
    return math.sin(rad), -math.cos(rad)
end

-- Get angle from direction vector (returns degrees)
-- Note: 0° = UP in game coordinates
function Utils.vectorToAngle(dx, dy)
    return Utils.radToDeg(math.atan2(dx, -dy))
end

-- Check if a point is within screen bounds
function Utils.isOnScreen(x, y, margin)
    margin = margin or 0
    return x >= -margin and x <= Constants.SCREEN_WIDTH + margin
       and y >= -margin and y <= Constants.SCREEN_HEIGHT + margin
end

-- Calculate XP required for a level
function Utils.xpForLevel(level)
    if level <= 1 then return 0 end
    return math.floor(Constants.BASE_XP * (math.pow(level, Constants.BASE_LEVEL_EXPONENT) - 1))
end

-- Calculate XP needed to go from current level to next
function Utils.xpToNextLevel(currentLevel)
    return Utils.xpForLevel(currentLevel + 1) - Utils.xpForLevel(currentLevel)
end

-- Random point on screen edge (for spawning)
function Utils.randomEdgePoint(margin)
    margin = margin or 20
    local edge = math.random(4)
    local x, y

    if edge == 1 then      -- Top
        x = math.random(0, Constants.SCREEN_WIDTH)
        y = -margin
    elseif edge == 2 then  -- Right
        x = Constants.SCREEN_WIDTH + margin
        y = math.random(0, Constants.SCREEN_HEIGHT)
    elseif edge == 3 then  -- Bottom
        x = math.random(0, Constants.SCREEN_WIDTH)
        y = Constants.SCREEN_HEIGHT + margin
    else                   -- Left
        x = -margin
        y = math.random(0, Constants.SCREEN_HEIGHT)
    end

    return x, y
end

-- Format time as M:SS
function Utils.formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

-- AABB collision check
function Utils.aabbOverlap(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

-- Circle collision check
function Utils.circleOverlap(x1, y1, r1, x2, y2, r2)
    local distSq = Utils.distanceSquared(x1, y1, x2, y2)
    local radiusSum = r1 + r2
    return distSq < radiusSum * radiusSum
end

-- Circle vs AABB collision
function Utils.circleRectOverlap(cx, cy, radius, rx, ry, rw, rh)
    local closestX = Utils.clamp(cx, rx, rx + rw)
    local closestY = Utils.clamp(cy, ry, ry + rh)
    local distSq = Utils.distanceSquared(cx, cy, closestX, closestY)
    return distSq < radius * radius
end

return Utils
