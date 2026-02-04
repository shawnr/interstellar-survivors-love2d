-- Pause Menu
-- Simple overlay with Resume and Quit options

PauseMenu = {
    isVisible = false,
    selectedIndex = 1,
    menuItems = {
        { label = "Resume", action = "resume" },
        { label = "Settings", action = "settings" },
        { label = "Quit to Title", action = "quit" },
    },
}

function PauseMenu:init()
    self.isVisible = false
    self.selectedIndex = 1
end

function PauseMenu:show()
    self.isVisible = true
    self.selectedIndex = 1
end

function PauseMenu:hide()
    self.isVisible = false
end

function PauseMenu:update(dt)
    if not self.isVisible then return end

    -- Navigation
    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.menuItems
        end
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.menuItems then
            self.selectedIndex = 1
        end
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("return") or InputManager:justPressed("space") then
        self:selectItem()
    elseif InputManager:justPressed("escape") then
        -- Escape again resumes
        self:selectResume()
    end
end

function PauseMenu:selectItem()
    local item = self.menuItems[self.selectedIndex]
    if not item then return end

    if item.action == "resume" then
        self:selectResume()
    elseif item.action == "settings" then
        self:selectSettings()
    elseif item.action == "quit" then
        self:selectQuit()
    end
end

function PauseMenu:selectResume()
    if AudioManager then AudioManager:playSFX("menu_back", 0.3) end
    self:hide()
    if GameplayScene then
        GameplayScene:unpause()
    end
end

function PauseMenu:selectSettings()
    self:hide()
    -- Switch to settings without transition (preserve gameplay state)
    GameManager.currentState = GameManager.states.SETTINGS
    if SettingsScene then
        SettingsScene:enter({ returnState = GameManager.states.GAMEPLAY })
    end
end

function PauseMenu:selectQuit()
    self:hide()
    if GameplayScene then
        GameplayScene:unpause()
        GameplayScene:exit()
    end
    if GameManager then
        GameManager:goToTitle()
    end
end

function PauseMenu:draw()
    if not self.isVisible then return end

    local font = love.graphics.getFont()
    local centerX = Constants.SCREEN_WIDTH / 2

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- Panel
    local panelW = 200
    local panelH = 128
    local panelX = centerX - panelW / 2
    local panelY = Constants.SCREEN_HEIGHT / 2 - panelH / 2

    -- Panel background
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)

    -- Panel border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH)
    love.graphics.rectangle("line", panelX + 2, panelY + 2, panelW - 4, panelH - 4)

    -- Header
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", panelX + 4, panelY + 4, panelW - 8, 20)
    love.graphics.setColor(0, 0, 0)
    local headerText = "PAUSED"
    local headerW = font:getWidth(headerText)
    love.graphics.print(headerText, centerX - headerW / 2, panelY + 8)

    -- Divider
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(panelX + 4, panelY + 26, panelX + panelW - 4, panelY + 26)

    -- Menu items
    local itemStartY = panelY + 34
    local itemH = 26
    local itemW = panelW - 16

    for i, item in ipairs(self.menuItems) do
        local y = itemStartY + (i - 1) * (itemH + 2)
        local x = panelX + 8
        local isSelected = (i == self.selectedIndex)

        if isSelected then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", x, y, itemW, itemH, 4, 4)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, itemW, itemH, 4, 4)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", x, y, itemW, itemH, 4, 4)
        end

        local textW = font:getWidth(item.label)
        love.graphics.print(item.label, centerX - textW / 2, y + 7)
    end
end

return PauseMenu
