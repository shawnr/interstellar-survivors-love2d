-- Results Scene
-- Shown after victory or game over with run stats

ResultsScene = {
    isVictory = false,
    episodeData = nil,
    stats = nil,
}

function ResultsScene:init()
    self.isVictory = false
    self.episodeData = nil
    self.stats = nil
end

function ResultsScene:enter(params)
    params = params or {}
    self.isVictory = params.isVictory or false
    self.episodeData = params.episodeData
    self.stats = params.stats or {}

    print("Results scene: " .. (self.isVictory and "VICTORY" or "GAME OVER"))
end

function ResultsScene:update(dt)
    -- Return to title
    if InputManager:justPressed("return") or InputManager:justPressed("space") then
        GameManager:goToTitle()
    end
end

function ResultsScene:draw()
    local font = love.graphics.getFont()
    local centerX = Constants.SCREEN_WIDTH / 2

    -- Background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- Header
    local headerY = 20
    if self.isVictory then
        love.graphics.setColor(0.2, 1, 0.4)
        local header = "VICTORY!"
        local headerW = font:getWidth(header)
        love.graphics.print(header, centerX - headerW / 2, headerY)
    else
        love.graphics.setColor(1, 0.3, 0.3)
        local header = "GAME OVER"
        local headerW = font:getWidth(header)
        love.graphics.print(header, centerX - headerW / 2, headerY)
    end

    -- Episode name
    if self.episodeData then
        love.graphics.setColor(0.7, 0.7, 0.8)
        local epTitle = "Episode " .. (self.episodeData.id or "?") .. ": " .. (self.episodeData.title or "")
        local epW = font:getWidth(epTitle)
        love.graphics.print(epTitle, centerX - epW / 2, headerY + 18)
    end

    -- Stats panel
    local panelX = 80
    local panelY = 65
    local panelW = 240
    local panelH = 120
    local lineH = 18

    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH)

    -- Stats rows
    local stats = self.stats or {}
    local rows = {
        { "Time", Utils.formatTime(stats.elapsedTime or 0) },
        { "Level Reached", tostring(stats.levelReached or 1) },
        { "Research Points", tostring(stats.totalRP or 0) },
        { "Enemies Defeated", tostring(stats.mobKills or 0) },
        { "Tools Equipped", tostring(stats.toolsEquipped or 0) },
    }

    local textX = panelX + 12
    local valueEndX = panelX + panelW - 12
    local rowY = panelY + 10

    for _, row in ipairs(rows) do
        local label = row[1]
        local value = row[2]

        -- Label (left-aligned)
        love.graphics.setColor(0.6, 0.6, 0.7)
        love.graphics.print(label, textX, rowY)

        -- Value (right-aligned)
        love.graphics.setColor(1, 1, 1)
        local valueW = font:getWidth(value)
        love.graphics.print(value, valueEndX - valueW, rowY)

        rowY = rowY + lineH
    end

    -- Completion message for victory
    if self.isVictory then
        love.graphics.setColor(0.4, 0.8, 1)
        local msg = "Episode Complete!"
        local msgW = font:getWidth(msg)
        love.graphics.print(msg, centerX - msgW / 2, panelY + panelH + 15)
    end

    -- Continue prompt
    love.graphics.setColor(0.5, 0.5, 0.6)
    local prompt = "Press Enter to continue"
    local promptW = font:getWidth(prompt)
    love.graphics.print(prompt, centerX - promptW / 2, Constants.SCREEN_HEIGHT - 24)
end

function ResultsScene:exit()
    self.stats = nil
    self.episodeData = nil
end

return ResultsScene
