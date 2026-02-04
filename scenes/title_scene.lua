-- Title Scene
-- Main menu with episode select submenu

TitleScene = {
    selectedIndex = 1,
    menuItems = {},

    -- Mode: "main" for title menu, "episodes" for episode select
    mode = "main",
    episodeIndex = 1,
}

function TitleScene:init()
    self.selectedIndex = 1
    self.menuItems = {}
    self.mode = "main"
    self.episodeIndex = 1
end

function TitleScene:enter(params)
    self.selectedIndex = 1
    self.mode = "main"
    self.episodeIndex = 1
    self:buildMenu()
    if AudioManager then
        AudioManager:playMusic("music_title")
    end
    print("Title scene entered")
end

function TitleScene:buildMenu()
    self.menuItems = {
        { label = "Episodes", action = "episodes" },
        { label = "Grants", action = "grants" },
        { label = "Specs", action = "specs" },
        { label = "Codex", action = "codex" },
        { label = "Settings", action = "settings" },
        { label = "Quit", action = "quit" },
    }
end

function TitleScene:update(dt)
    if self.mode == "main" then
        self:updateMainMenu(dt)
    elseif self.mode == "episodes" then
        self:updateEpisodeSelect(dt)
    end
end

function TitleScene:updateMainMenu(dt)
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
    end
end

function TitleScene:selectItem()
    local item = self.menuItems[self.selectedIndex]
    if not item then return end

    if item.action == "episodes" then
        self.mode = "episodes"
        self.episodeIndex = 1
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif item.action == "grants" then
        GameManager:transitionTo(GameManager.states.GRANTS)
    elseif item.action == "specs" then
        GameManager:transitionTo(GameManager.states.SPECS)
    elseif item.action == "codex" then
        GameManager:transitionTo(GameManager.states.CODEX)
    elseif item.action == "settings" then
        GameManager:transitionTo(GameManager.states.SETTINGS, {
            returnState = GameManager.states.TITLE
        })
    elseif item.action == "quit" then
        love.event.quit()
    end
end

function TitleScene:updateEpisodeSelect(dt)
    local episodeCount = 5

    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.episodeIndex = self.episodeIndex - 1
        if self.episodeIndex < 1 then
            self.episodeIndex = episodeCount
        end
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.episodeIndex = self.episodeIndex + 1
        if self.episodeIndex > episodeCount then
            self.episodeIndex = 1
        end
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("return") or InputManager:justPressed("space") then
        self:selectEpisode()
    elseif InputManager:justPressed("escape") then
        self.mode = "main"
        if AudioManager then
            AudioManager:playSFX("menu_back", 0.3)
        end
    end
end

function TitleScene:selectEpisode()
    local episodeId = self.episodeIndex
    local unlocked = SaveManager:isEpisodeUnlocked(episodeId)

    if unlocked then
        GameManager:startEpisode(episodeId)
    else
        -- Locked episode - play error sound
        if AudioManager then
            AudioManager:playSFX("station_hit", 0.3)
        end
    end
end

function TitleScene:draw()
    -- Background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- Starfield effect (simple dots)
    love.graphics.setColor(0.3, 0.3, 0.4)
    math.randomseed(42)  -- Fixed seed for consistent stars
    for i = 1, 60 do
        local sx = math.random(0, Constants.SCREEN_WIDTH)
        local sy = math.random(0, Constants.SCREEN_HEIGHT)
        local brightness = 0.2 + math.random() * 0.5
        love.graphics.setColor(brightness, brightness, brightness + 0.1)
        love.graphics.points(sx, sy)
    end
    math.randomseed(os.time())  -- Restore random seed

    local font = love.graphics.getFont()
    local centerX = Constants.SCREEN_WIDTH / 2

    -- Title
    love.graphics.setColor(0, 0.9, 1)  -- Cyan
    local title = "INTERSTELLAR SURVIVORS"
    local titleW = font:getWidth(title)
    love.graphics.print(title, centerX - titleW / 2, 50)

    -- Subtitle
    love.graphics.setColor(0.6, 0.6, 0.7)
    local subtitle = "Love2D Edition"
    local subtitleW = font:getWidth(subtitle)
    love.graphics.print(subtitle, centerX - subtitleW / 2, 66)

    if self.mode == "main" then
        self:drawMainMenu(font, centerX)
    elseif self.mode == "episodes" then
        self:drawEpisodeSelect(font, centerX)
    end

    -- Controls hint
    love.graphics.setColor(0.3, 0.3, 0.4)
    local hint
    if self.mode == "episodes" then
        hint = "W/S: Navigate   Enter: Select   Esc: Back"
    else
        hint = "W/S: Navigate   Enter: Select"
    end
    local hintW = font:getWidth(hint)
    love.graphics.print(hint, centerX - hintW / 2, Constants.SCREEN_HEIGHT - 20)
end

function TitleScene:drawMainMenu(font, centerX)
    local menuStartY = 110
    local itemSpacing = 24

    for i, item in ipairs(self.menuItems) do
        local y = menuStartY + (i - 1) * itemSpacing
        local isSelected = (i == self.selectedIndex)

        if isSelected then
            love.graphics.setColor(1, 1, 1)
            local text = "> " .. item.label .. " <"
            local textW = font:getWidth(text)
            love.graphics.print(text, centerX - textW / 2, y)
        else
            love.graphics.setColor(0.5, 0.5, 0.6)
            local textW = font:getWidth(item.label)
            love.graphics.print(item.label, centerX - textW / 2, y)
        end
    end
end

function TitleScene:drawEpisodeSelect(font, centerX)
    -- Episode list header
    love.graphics.setColor(0, 0.9, 1)
    local header = "SELECT EPISODE"
    local headerW = font:getWidth(header)
    love.graphics.print(header, centerX - headerW / 2, 88)

    local listStartY = 108
    local itemSpacing = 20

    for i = 1, 5 do
        local y = listStartY + (i - 1) * itemSpacing
        local ep = EpisodesData[i]
        local isSelected = (i == self.episodeIndex)
        local unlocked = SaveManager:isEpisodeUnlocked(i)
        local completed = SaveManager:isEpisodeCompleted(i)

        -- Build label
        local status = ""
        if completed then
            status = " [DONE]"
        elseif not unlocked then
            status = " [LOCKED]"
        end

        local label = i .. ". " .. (ep and ep.title or "???") .. status

        if isSelected then
            if unlocked then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.6, 0.3, 0.3)
            end
            local text = "> " .. label .. " <"
            local textW = font:getWidth(text)
            love.graphics.print(text, centerX - textW / 2, y)
        else
            if unlocked then
                love.graphics.setColor(0.5, 0.5, 0.6)
            else
                love.graphics.setColor(0.3, 0.3, 0.35)
            end
            local textW = font:getWidth(label)
            love.graphics.print(label, centerX - textW / 2, y)
        end
    end

    -- Tagline for selected episode
    local selectedEp = EpisodesData[self.episodeIndex]
    if selectedEp and selectedEp.tagline then
        love.graphics.setColor(0.5, 0.5, 0.6)
        local tagW = font:getWidth(selectedEp.tagline)
        love.graphics.print(selectedEp.tagline, centerX - tagW / 2, listStartY + 5 * itemSpacing + 6)
    end
end

function TitleScene:exit()
end

return TitleScene
