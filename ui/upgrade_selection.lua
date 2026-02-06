-- Upgrade Selection UI
-- Shows upgrade options when player levels up (Love2D port)

UpgradeSelection = {
    isVisible = false,
    selectedIndex = 1,
    options = {},
    onSelect = nil,
}

function UpgradeSelection:init()
    self.isVisible = false
    self.selectedIndex = 1
    self.options = {}
    self.onSelect = nil
    print("UpgradeSelection initialized")
end

function UpgradeSelection:show(options, callback)
    self.isVisible = true
    self.selectedIndex = 1
    self.onSelect = callback
    self.options = options or {}

    print("UpgradeSelection showing " .. #self.options .. " options")
end

function UpgradeSelection:hide()
    self.isVisible = false
    self.options = {}
    self.onSelect = nil
end

function UpgradeSelection:update(dt)
    if not self.isVisible then return end

    -- Navigation: W/Up = up, S/Down = down
    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.options
        end
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.options then
            self.selectedIndex = 1
        end
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("return") or InputManager:justPressed("space") then
        self:confirmSelection()
    end
end

function UpgradeSelection:confirmSelection()
    if #self.options == 0 then return end

    local selected = self.options[self.selectedIndex]
    if self.onSelect then
        self.onSelect(selected)
    end
    self:hide()
end

-- Get the icon image for an upgrade option (processed for alpha transparency)
function UpgradeSelection:getOptionIcon(option)
    if not option then return nil end

    if option.type == "bonus_item" and option.bonusItemData and option.bonusItemData.iconPath then
        -- Use iconPath from bonus item data
        return Utils.getCachedIcon(option.bonusItemData.iconPath .. ".png")
    elseif option.type == "tool" or option.type == "evolution" then
        -- Tool icon: use iconPath from originalData if available, else derive from id
        local path
        if option.originalData and option.originalData.iconPath then
            path = option.originalData.iconPath .. ".png"
            -- iconPath may point to tools/ dir; convert to icons_on_white/
            path = path:gsub("assets/images/tools/", "assets/images/icons_on_white/")
        else
            path = "assets/images/icons_on_white/tool_" .. (option.id or "") .. ".png"
        end
        return Utils.getCachedIcon(path)
    end
    return nil
end

function UpgradeSelection:draw()
    if not self.isVisible then return end

    -- Layout constants
    local panelX, panelY = 40, 25
    local panelW, panelH = 320, 190
    local headerH = 28
    local footerH = 22
    local cardH = 32
    local cardMargin = 4
    local cardW = panelW - (cardMargin * 2)

    -- 1. Dim the background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- 2. Draw solid panel background
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)

    -- 3. Draw panel border (double line)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH)
    love.graphics.rectangle("line", panelX + 2, panelY + 2, panelW - 4, panelH - 4)

    -- 4. Draw header
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", panelX + 4, panelY + 4, panelW - 8, headerH - 4)
    love.graphics.setColor(0, 0, 0)
    local headerText = "LEVEL UP!"
    local headerFont = love.graphics.getFont()
    local headerWidth = headerFont:getWidth(headerText)
    love.graphics.print(headerText, panelX + panelW / 2 - headerWidth / 2, panelY + 8)

    -- 5. Draw horizontal line under header
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(panelX + 4, panelY + headerH, panelX + panelW - 4, panelY + headerH)

    -- 6. Draw each option card
    local contentY = panelY + headerH + 4
    for i, option in ipairs(self.options) do
        local cardY = contentY + (i - 1) * (cardH + 2)
        local cardX = panelX + cardMargin
        local isSelected = (i == self.selectedIndex)

        -- Card background
        if isSelected then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", cardX, cardY, cardW, cardH - 2, 4, 4)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", cardX, cardY, cardW, cardH - 2, 4, 4)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", cardX, cardY, cardW, cardH - 2, 4, 4)
        end

        -- Icon
        local iconSize = 20
        local iconX = cardX + 6
        local iconY = cardY + (cardH - 2) / 2 - iconSize / 2
        local iconImage = self:getOptionIcon(option)

        if iconImage then
            local iw, ih = iconImage:getWidth(), iconImage:getHeight()
            local scale = iconSize / math.max(iw, ih)
            if isSelected then
                love.graphics.setColor(1, 1, 1)  -- White icon on black card
            else
                love.graphics.setColor(0, 0, 0)  -- Black icon on white card
            end
            love.graphics.draw(iconImage, iconX, iconY, 0, scale, scale)
        else
            -- Fallback: empty box
            if isSelected then
                love.graphics.setColor(0.3, 0.3, 0.3)
            else
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            love.graphics.rectangle("fill", iconX, iconY, iconSize, iconSize)
            if isSelected then
                love.graphics.setColor(0.5, 0.5, 0.5)
            else
                love.graphics.setColor(0.6, 0.6, 0.6)
            end
            love.graphics.rectangle("line", iconX, iconY, iconSize, iconSize)
        end

        -- Text (shifted right to make room for icon)
        local textX = cardX + 30
        local textY = cardY + 4

        if isSelected then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0, 0, 0)
        end

        -- Name
        local name = option.name or "Unknown"
        love.graphics.print(name, textX, textY)

        -- Description on second line (with paired tool name for bonus items)
        local desc = option.description or ""
        if option.pairsWithToolName then
            if isSelected then
                love.graphics.setColor(0.7, 0.9, 1)
            else
                love.graphics.setColor(0.3, 0.3, 0.5)
            end
            love.graphics.print(desc .. " > " .. option.pairsWithToolName, textX, textY + 12)
        else
            love.graphics.print(desc, textX, textY + 12)
        end

        -- Restore main text color for badge
        if isSelected then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0, 0, 0)
        end

        -- Type badge on right
        local badge
        if option.type == "evolution" then
            badge = "[EVOLVE]"
        elseif option.type == "bonus_item" and option.isUpgrade then
            badge = "[UPGRADE]"
        elseif option.type == "bonus_item" then
            badge = "[ITEM]"
        elseif option.isNew then
            badge = "[NEW]"
        else
            badge = "[UPGRADE]"
        end
        local badgeWidth = headerFont:getWidth(badge)
        love.graphics.print(badge, cardX + cardW - badgeWidth - 10, textY)
    end

    -- Draw footer line
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(panelX + 4, panelY + panelH - footerH, panelX + panelW - 4, panelY + panelH - footerH)

    -- 7. Draw instructions at bottom
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", panelX + 6, panelY + panelH - footerH + 2, panelW - 12, footerH - 6)

    love.graphics.setColor(0, 0, 0)
    local footerText = "W/S: Select   Enter: Confirm"
    local footerWidth = headerFont:getWidth(footerText)
    love.graphics.print(footerText, panelX + panelW / 2 - footerWidth / 2, panelY + panelH - footerH + 5)
end

function UpgradeSelection:getSelectedOption()
    if #self.options > 0 then
        return self.options[self.selectedIndex]
    end
    return nil
end

return UpgradeSelection
