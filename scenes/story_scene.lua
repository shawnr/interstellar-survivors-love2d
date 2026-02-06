-- Story Scene
-- Reusable scene for intro and ending cutscene panels
-- Each panel has an optional image and an array of text lines shown one at a time

StoryScene = {
    panels = {},
    currentPanel = 1,
    currentLine = 1,
    lineTimer = 0,
    autoAdvanceTime = 3.0,
    onComplete = nil,

    -- Current panel image
    currentImage = nil,
}

function StoryScene:init()
    self.panels = {}
    self.currentPanel = 1
    self.currentLine = 1
    self.onComplete = nil
    self.currentImage = nil
    self.skipRequested = false
end

function StoryScene:enter(params)
    params = params or {}
    self.panels = params.panels or {}
    self.onComplete = params.onComplete
    self.currentPanel = 1
    self.currentLine = 1
    self.lineTimer = 0
    self.currentImage = nil

    -- Check if cutscene skip is enabled
    if SaveManager and SaveManager:getCutsceneSkipEnabled() then
        print("Story scene: Cutscene skip enabled, auto-completing")
        -- Defer completion to next frame to avoid state issues
        self.skipRequested = true
        return
    end

    -- Load first panel image
    self:loadPanelImage()

    print("Story scene entered with " .. #self.panels .. " panels")
end

function StoryScene:loadPanelImage()
    self.currentImage = nil
    local panel = self.panels[self.currentPanel]
    if panel and panel.imagePath then
        self.currentImage = Utils.getCachedImage(panel.imagePath)
    end
end

function StoryScene:update(dt)
    -- Handle skip request from enter (deferred to avoid state issues)
    if self.skipRequested then
        self.skipRequested = false
        self:complete()
        return
    end

    -- Auto-advance timer
    self.lineTimer = self.lineTimer + dt
    if self.lineTimer >= self.autoAdvanceTime then
        self:advanceLine()
    end

    -- Manual advance
    if InputManager:justPressed("return") or InputManager:justPressed("space") then
        self:advanceLine()
    end

    -- Skip all panels
    if InputManager:justPressed("escape") then
        if AudioManager then AudioManager:playSFX("menu_back", 0.3) end
        self:complete()
    end
end

function StoryScene:advanceLine()
    self.lineTimer = 0

    local panel = self.panels[self.currentPanel]
    if not panel then
        self:complete()
        return
    end

    if self.currentLine < #panel.lines then
        -- Next line in current panel
        self.currentLine = self.currentLine + 1
    else
        -- Next panel
        if self.currentPanel < #self.panels then
            self.currentPanel = self.currentPanel + 1
            self.currentLine = 1
            self:loadPanelImage()
        else
            -- All panels done
            self:complete()
        end
    end
end

function StoryScene:complete()
    if self.onComplete then
        self.onComplete()
    end
end

function StoryScene:draw()
    local font = love.graphics.getFont()
    local centerX = Constants.SCREEN_WIDTH / 2

    -- Black background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- Draw panel image (centered, scaled to fit top portion)
    if self.currentImage then
        local imgW = self.currentImage:getWidth()
        local imgH = self.currentImage:getHeight()
        local maxW = Constants.SCREEN_WIDTH - 40
        local maxH = Constants.SCREEN_HEIGHT - 80  -- Leave room for text
        local scale = math.min(maxW / imgW, maxH / imgH, 1)

        local drawX = centerX - (imgW * scale) / 2
        local drawY = 10

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.currentImage, drawX, drawY, 0, scale, scale)
    end

    -- Draw text box at bottom
    local textBoxY = Constants.SCREEN_HEIGHT - 65
    local textBoxH = 55
    local textBoxW = Constants.SCREEN_WIDTH - 20
    local textBoxX = 10

    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", textBoxX, textBoxY, textBoxW, textBoxH)

    -- Border
    love.graphics.setColor(0.4, 0.6, 0.8)
    love.graphics.rectangle("line", textBoxX, textBoxY, textBoxW, textBoxH)

    -- Current text line
    local panel = self.panels[self.currentPanel]
    if panel and panel.lines then
        local line = panel.lines[self.currentLine] or ""
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(line, textBoxX + 8, textBoxY + 8, textBoxW - 16, "left")
    end

    -- Progress dots (panel indicator)
    local dotY = textBoxY - 12
    local totalDots = #self.panels
    local dotSpacing = 10
    local dotsStartX = centerX - (totalDots * dotSpacing) / 2

    for i = 1, totalDots do
        local dotX = dotsStartX + (i - 1) * dotSpacing + 4
        if i == self.currentPanel then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", dotX, dotY, 3)
        else
            love.graphics.setColor(0.4, 0.4, 0.5)
            love.graphics.circle("fill", dotX, dotY, 2)
        end
    end

    -- Line progress within panel
    if panel and panel.lines then
        local lineDotsY = textBoxY + textBoxH + 6
        local lineCount = #panel.lines
        local lineDotsStartX = centerX - (lineCount * 8) / 2

        for i = 1, lineCount do
            local x = lineDotsStartX + (i - 1) * 8 + 3
            if i <= self.currentLine then
                love.graphics.setColor(0.4, 0.7, 1)
                love.graphics.circle("fill", x, lineDotsY, 2)
            else
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.circle("fill", x, lineDotsY, 1.5)
            end
        end
    end

    -- Controls hint
    love.graphics.setColor(0.3, 0.3, 0.4)
    local hint = "Enter: Next   Esc: Skip"
    local hintW = font:getWidth(hint)
    love.graphics.print(hint, Constants.SCREEN_WIDTH - hintW - 8, textBoxY - 12)
end

function StoryScene:exit()
    self.panels = {}
    self.onComplete = nil
    self.currentImage = nil
end

return StoryScene
