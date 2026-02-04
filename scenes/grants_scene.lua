-- Grants Scene
-- Between-run upgrade screen where players spend accumulated RP

GrantsScene = {
    selectedIndex = 1,
}

function GrantsScene:init()
    self.selectedIndex = 1
end

function GrantsScene:enter(params)
    self.selectedIndex = 1
end

function GrantsScene:update(dt)
    -- Navigation
    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #GrantsData.order
        end
    end

    if InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #GrantsData.order then
            self.selectedIndex = 1
        end
    end

    -- Purchase
    if InputManager:justPressed("return") or InputManager:justPressed("space") then
        local grantId = GrantsData.order[self.selectedIndex]
        if grantId then
            local success = GrantsSystem:purchase(grantId)
            if success and AudioManager then
                AudioManager:playSFX("level_up", 0.6)
            end
        end
    end

    -- Back
    if InputManager:justPressed("escape") then
        if AudioManager then AudioManager:playSFX("menu_back", 0.3) end
        GameManager:goToTitle()
    end
end

function GrantsScene:draw()
    -- Background
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1)
    local title = "GRANT FUNDING"
    local titleWidth = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, Constants.SCREEN_WIDTH / 2 - titleWidth / 2, 16)

    -- RP display
    local rp = SaveManager:getSpendableRP()
    local rpStr = "Available RP: " .. rp
    local rpWidth = love.graphics.getFont():getWidth(rpStr)
    love.graphics.setColor(1, 0.9, 0.4)
    love.graphics.print(rpStr, Constants.SCREEN_WIDTH / 2 - rpWidth / 2, 32)

    -- Grant list
    local startY = 56
    local itemHeight = 40

    for i, grantId in ipairs(GrantsData.order) do
        local grant = GrantsData[grantId]
        local level = GrantsSystem:getLevel(grantId)
        local cost = GrantsData.getCost(grantId, level)
        local y = startY + (i - 1) * itemHeight
        local isSelected = (i == self.selectedIndex)

        -- Selection highlight
        if isSelected then
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.rectangle("fill", 8, y - 2, Constants.SCREEN_WIDTH - 16, itemHeight - 4)
        end

        -- Cursor
        if isSelected then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(">", 12, y)
        end

        -- Grant name and level
        local levelStr = ""
        for lv = 1, grant.maxLevel do
            if lv <= level then
                levelStr = levelStr .. "[X]"
            else
                levelStr = levelStr .. "[ ]"
            end
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(grant.name, 28, y)

        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print(levelStr, 28, y + 12)

        -- Cost or MAX
        if cost then
            local canAfford = rp >= cost
            if canAfford then
                love.graphics.setColor(0.4, 1, 0.4)
            else
                love.graphics.setColor(0.6, 0.3, 0.3)
            end
            love.graphics.print(cost .. " RP", Constants.SCREEN_WIDTH - 80, y + 6)
        else
            love.graphics.setColor(0.8, 0.8, 0.2)
            love.graphics.print("MAX", Constants.SCREEN_WIDTH - 60, y + 6)
        end

        -- Bonus info
        local bonus = GrantsData.getBonus(grantId, level)
        if bonus > 0 then
            love.graphics.setColor(0.5, 0.8, 1)
            love.graphics.print("+" .. math.floor(bonus * 100) .. "%", Constants.SCREEN_WIDTH - 130, y + 6)
        end
    end

    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("W/S: Navigate  Enter: Purchase  Esc: Back", 12, Constants.SCREEN_HEIGHT - 16)
end

return GrantsScene
