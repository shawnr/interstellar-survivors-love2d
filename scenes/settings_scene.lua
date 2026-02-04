-- Settings Scene
-- Volume controls for music and SFX

SettingsScene = {
    selectedIndex = 1,
    musicVolume = 0.7,
    sfxVolume = 0.7,
    returnState = nil,

    items = {
        { label = "Music Volume", key = "musicVolume" },
        { label = "SFX Volume", key = "sfxVolume" },
        { label = "Back", key = "back" },
    },
}

function SettingsScene:init()
    self.selectedIndex = 1
    self.returnState = nil
end

function SettingsScene:enter(params)
    params = params or {}
    self.selectedIndex = 1
    self.returnState = params.returnState or GameManager.states.TITLE

    -- Load current volumes from AudioManager
    self.musicVolume = AudioManager and AudioManager.musicVolume or 0.7
    self.sfxVolume = AudioManager and AudioManager.sfxVolume or 0.7

    print("Settings scene entered")
end

function SettingsScene:update(dt)
    -- Navigation
    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.items
        end
        if AudioManager then AudioManager:playSFX("menu_move", 0.3) end
    elseif InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.items then
            self.selectedIndex = 1
        end
        if AudioManager then AudioManager:playSFX("menu_move", 0.3) end
    end

    local item = self.items[self.selectedIndex]
    if not item then return end

    -- Adjust sliders with A/D
    if item.key == "musicVolume" then
        if InputManager:justPressed("a") or InputManager:justPressed("left") then
            self.musicVolume = Utils.clamp(self.musicVolume - 0.1, 0, 1)
            if AudioManager then AudioManager:setMusicVolume(self.musicVolume) end
        elseif InputManager:justPressed("d") or InputManager:justPressed("right") then
            self.musicVolume = Utils.clamp(self.musicVolume + 0.1, 0, 1)
            if AudioManager then AudioManager:setMusicVolume(self.musicVolume) end
        end
    elseif item.key == "sfxVolume" then
        if InputManager:justPressed("a") or InputManager:justPressed("left") then
            self.sfxVolume = Utils.clamp(self.sfxVolume - 0.1, 0, 1)
            if AudioManager then AudioManager:setSFXVolume(self.sfxVolume) end
            if AudioManager then AudioManager:playSFX("menu_move", 0.5) end
        elseif InputManager:justPressed("d") or InputManager:justPressed("right") then
            self.sfxVolume = Utils.clamp(self.sfxVolume + 0.1, 0, 1)
            if AudioManager then AudioManager:setSFXVolume(self.sfxVolume) end
            if AudioManager then AudioManager:playSFX("menu_move", 0.5) end
        end
    end

    -- Select / Back
    if InputManager:justPressed("return") or InputManager:justPressed("space") then
        if item.key == "back" then
            self:saveAndBack()
        end
    elseif InputManager:justPressed("escape") then
        self:saveAndBack()
    end
end

function SettingsScene:saveAndBack()
    -- Persist volume settings
    if SaveManager then
        SaveManager:setSetting("musicVolume", self.musicVolume)
        SaveManager:setSetting("sfxVolume", self.sfxVolume)
    end

    if AudioManager then AudioManager:playSFX("menu_back", 0.3) end

    -- Return to previous state
    if self.returnState == GameManager.states.GAMEPLAY then
        -- Return to gameplay without re-entering (preserves game state)
        GameManager.currentState = GameManager.states.GAMEPLAY
        if GameplayScene then
            GameplayScene:pause()
        end
    else
        GameManager:transitionTo(self.returnState)
    end
end

function SettingsScene:draw()
    -- Background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    local font = love.graphics.getFont()
    local centerX = Constants.SCREEN_WIDTH / 2

    -- Title
    love.graphics.setColor(0, 0.9, 1)
    local title = "SETTINGS"
    local titleW = font:getWidth(title)
    love.graphics.print(title, centerX - titleW / 2, 50)

    -- Menu items
    local startY = 100
    local spacing = 28

    for i, item in ipairs(self.items) do
        local y = startY + (i - 1) * spacing
        local isSelected = (i == self.selectedIndex)

        if item.key == "back" then
            -- Simple text button
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
        else
            -- Slider item
            local value = item.key == "musicVolume" and self.musicVolume or self.sfxVolume
            local pct = math.floor(value * 100 + 0.5)

            -- Label
            if isSelected then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.6)
            end

            local labelText = item.label
            local labelW = font:getWidth(labelText)
            love.graphics.print(labelText, centerX - 80, y)

            -- Slider track
            local sliderX = centerX + 10
            local sliderW = 80
            local sliderY = y + 4

            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", sliderX, sliderY, sliderW, 6)

            -- Slider fill
            if isSelected then
                love.graphics.setColor(0, 0.8, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.6)
            end
            love.graphics.rectangle("fill", sliderX, sliderY, sliderW * value, 6)

            -- Percentage text
            love.graphics.print(pct .. "%", sliderX + sliderW + 6, y)
        end
    end

    -- Controls hint
    love.graphics.setColor(0.3, 0.3, 0.4)
    local hint = "W/S: Navigate   A/D: Adjust   Esc: Back"
    local hintW = font:getWidth(hint)
    love.graphics.print(hint, centerX - hintW / 2, Constants.SCREEN_HEIGHT - 20)
end

return SettingsScene
