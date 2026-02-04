-- Specs Scene
-- Research Specs equip UI

SpecsScene = {
    selectedIndex = 1,
}

function SpecsScene:init()
    self.selectedIndex = 1
end

function SpecsScene:enter(params)
    self.selectedIndex = 1
    -- Check for any newly unlocked specs
    SpecsSystem:checkUnlocks()
end

function SpecsScene:update(dt)
    -- Navigation
    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #SpecsData.order
        end
    end

    if InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #SpecsData.order then
            self.selectedIndex = 1
        end
    end

    -- Toggle equip
    if InputManager:justPressed("return") or InputManager:justPressed("space") then
        local specId = SpecsData.order[self.selectedIndex]
        if specId and SaveManager:isSpecUnlocked(specId) then
            SpecsSystem:toggleEquip(specId)
            if AudioManager then
                AudioManager:playSFX("level_up", 0.4)
            end
        end
    end

    -- Back
    if InputManager:justPressed("escape") then
        if AudioManager then AudioManager:playSFX("menu_back", 0.3) end
        GameManager:goToTitle()
    end
end

function SpecsScene:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1)
    local title = "RESEARCH SPECS"
    local titleWidth = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, Constants.SCREEN_WIDTH / 2 - titleWidth / 2, 10)

    -- Equipped count
    local equipped = SaveManager:getEquippedSpecs()
    local equipStr = "Equipped: " .. #equipped .. "/" .. SpecsData.MAX_EQUIPPED
    local equipWidth = love.graphics.getFont():getWidth(equipStr)
    love.graphics.setColor(0.7, 0.9, 1)
    love.graphics.print(equipStr, Constants.SCREEN_WIDTH / 2 - equipWidth / 2, 24)

    -- Specs list
    local startY = 42
    local itemHeight = 20

    for i, specId in ipairs(SpecsData.order) do
        local spec = SpecsData[specId]
        local unlocked = SaveManager:isSpecUnlocked(specId)
        local isEquipped = SpecsSystem:isEquipped(specId)
        local isSelected = (i == self.selectedIndex)
        local y = startY + (i - 1) * itemHeight

        -- Selection highlight
        if isSelected then
            love.graphics.setColor(1, 1, 1, 0.08)
            love.graphics.rectangle("fill", 8, y - 1, Constants.SCREEN_WIDTH - 16, itemHeight - 2)
        end

        -- Cursor
        if isSelected then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(">", 12, y)
        end

        -- Equipped indicator
        if isEquipped then
            love.graphics.setColor(0.3, 1, 0.3)
            love.graphics.print("[E]", 24, y)
        end

        -- Name
        if unlocked then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(spec.name, 48, y)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.print("???", 48, y)
        end

        -- Description or unlock condition
        if unlocked then
            love.graphics.setColor(0.6, 0.6, 0.6)
            love.graphics.print(spec.description, 200, y)
        else
            love.graphics.setColor(0.4, 0.3, 0.3)
            love.graphics.print(spec.unlockText, 200, y)
        end
    end

    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("W/S: Navigate  Enter: Equip/Unequip  Esc: Back", 12, Constants.SCREEN_HEIGHT - 16)
end

return SpecsScene
