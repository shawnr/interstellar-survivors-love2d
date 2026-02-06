-- Slot Picker UI
-- Visual tool placement screen with spider diagram
-- Layout: tool info on left, slot diagram on right

SlotPicker = {
    isVisible = false,
    selectedSlot = 0,
    station = nil,
    pendingOption = nil,
    onConfirm = nil,
}

function SlotPicker:init()
    self.isVisible = false
    self.selectedSlot = 0
    self.station = nil
    self.pendingOption = nil
    self.onConfirm = nil
end

function SlotPicker:show(station, option, callback)
    self.isVisible = true
    self.station = station
    self.pendingOption = option
    self.onConfirm = callback

    -- Default to first available slot
    self.selectedSlot = station:getNextAvailableSlot() or 0
end

function SlotPicker:hide()
    self.isVisible = false
    self.station = nil
    self.pendingOption = nil
    self.onConfirm = nil
end

function SlotPicker:update(dt)
    if not self.isVisible or not self.station then return end

    -- Navigate slots with A/D or Left/Right
    if InputManager:justPressed("a") or InputManager:justPressed("left") then
        self:cycleSlot(-1)
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("d") or InputManager:justPressed("right") then
        self:cycleSlot(1)
        if AudioManager then
            AudioManager:playSFX("menu_move", 0.3)
        end
    elseif InputManager:justPressed("return") or InputManager:justPressed("space") then
        self:confirmSlot()
    end
end

-- Cycle to the next available (unoccupied) slot
function SlotPicker:cycleSlot(direction)
    local startSlot = self.selectedSlot
    local slot = self.selectedSlot

    for i = 1, Constants.STATION_SLOTS do
        slot = (slot + direction) % Constants.STATION_SLOTS
        if not self.station.usedSlots[slot] then
            self.selectedSlot = slot
            return
        end
    end

    -- No available slots found, stay on current
    self.selectedSlot = startSlot
end

function SlotPicker:confirmSlot()
    if not self.station.usedSlots[self.selectedSlot] then
        if self.onConfirm then
            self.onConfirm(self.selectedSlot)
        end
        self:hide()
    end
end

-- Get tool icon image by tool ID (processed for alpha transparency)
function SlotPicker:getToolIcon(toolId)
    if not toolId then return nil end
    -- Use iconPath from ToolsData if available (handles missing icon fallbacks)
    local toolData = ToolsData and ToolsData[toolId]
    local path
    if toolData and toolData.iconPath then
        path = toolData.iconPath .. ".png"
        path = path:gsub("assets/images/tools/", "assets/images/icons_on_white/")
    else
        path = "assets/images/icons_on_white/tool_" .. toolId .. ".png"
    end
    return Utils.getCachedIcon(path)
end

-- Get slot position on the spider diagram
function SlotPicker:getSlotPos(slotIndex, centerX, centerY, radius)
    local slotData = Constants.TOOL_SLOTS[slotIndex]
    local nx = slotData.x / 32
    local ny = slotData.y / 32
    return centerX + nx * radius, centerY + ny * radius
end

function SlotPicker:draw()
    if not self.isVisible then return end

    local font = love.graphics.getFont()
    local fontH = font:getHeight()

    -- Panel layout
    local panelX, panelY = 30, 25
    local panelW, panelH = 340, 190

    -- Left side: tool info
    local infoX = panelX + 12
    local infoW = 130

    -- Right side: spider diagram
    local diagramCX = panelX + panelW - 90
    local diagramCY = panelY + panelH / 2 + 5
    local diagramRadius = 58
    local nodeRadius = 12

    -- 1. Dim the background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

    -- 2. Panel background
    love.graphics.setColor(0.12, 0.12, 0.18)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)

    -- 3. Panel border (double line)
    love.graphics.setColor(0.4, 0.5, 0.6)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH)
    love.graphics.setColor(0.25, 0.35, 0.45)
    love.graphics.rectangle("line", panelX + 2, panelY + 2, panelW - 4, panelH - 4)

    -- 4. Header bar
    love.graphics.setColor(0.15, 0.2, 0.3)
    love.graphics.rectangle("fill", panelX + 3, panelY + 3, panelW - 6, 22)
    love.graphics.setColor(0.7, 0.85, 1)
    local headerText = "PLACE TOOL"
    local headerW = font:getWidth(headerText)
    love.graphics.print(headerText, panelX + panelW / 2 - headerW / 2, panelY + 7)

    -- 5. Divider line under header
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.line(panelX + 4, panelY + 26, panelX + panelW - 4, panelY + 26)

    -- === LEFT SIDE: Tool Info ===
    local infoY = panelY + 34
    local iconBoxSize = 28

    -- Tool icon
    local toolIcon = self.pendingOption and self:getToolIcon(self.pendingOption.id) or nil
    if toolIcon then
        local iw, ih = toolIcon:getWidth(), toolIcon:getHeight()
        local scale = iconBoxSize / math.max(iw, ih)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(toolIcon, infoX, infoY, 0, scale, scale)
    else
        -- Fallback: empty box
        love.graphics.setColor(0.2, 0.25, 0.35)
        love.graphics.rectangle("fill", infoX, infoY, iconBoxSize, iconBoxSize)
        love.graphics.setColor(0.5, 0.6, 0.7)
        love.graphics.rectangle("line", infoX, infoY, iconBoxSize, iconBoxSize)
    end

    -- Tool name
    love.graphics.setColor(1, 1, 1)
    local toolName = self.pendingOption and self.pendingOption.name or "???"
    love.graphics.print(toolName, infoX + 34, infoY + 2)

    -- Tool description (word wrap to infoW)
    love.graphics.setColor(0.6, 0.7, 0.8)
    local desc = self.pendingOption and self.pendingOption.description or ""
    love.graphics.printf(desc, infoX, infoY + 18, infoW, "left")

    -- Damage stat if available
    if self.pendingOption and self.pendingOption.originalData then
        local dmg = self.pendingOption.originalData.baseDamage
        local rate = self.pendingOption.originalData.baseFireRate
        if dmg then
            love.graphics.setColor(0.5, 0.65, 0.8)
            local statY = infoY + 50
            love.graphics.print("Dmg: " .. dmg, infoX, statY)
            if rate then
                love.graphics.print("Rate: " .. string.format("%.1f", rate), infoX, statY + fontH + 2)
            end
        end
    end

    -- Vertical divider between info and diagram
    love.graphics.setColor(0.25, 0.35, 0.45)
    love.graphics.line(panelX + infoW + 24, panelY + 28, panelX + infoW + 24, panelY + panelH - 24)

    -- === RIGHT SIDE: Spider Diagram ===

    -- Draw connecting lines from center to each slot node
    love.graphics.setColor(0.25, 0.3, 0.4)
    for i = 0, Constants.STATION_SLOTS - 1 do
        local sx, sy = self:getSlotPos(i, diagramCX, diagramCY, diagramRadius)
        love.graphics.line(diagramCX, diagramCY, sx, sy)
    end

    -- Draw octagon outline connecting adjacent nodes
    love.graphics.setColor(0.2, 0.28, 0.38)
    for i = 0, Constants.STATION_SLOTS - 1 do
        local nextI = (i + 1) % Constants.STATION_SLOTS
        local x1, y1 = self:getSlotPos(i, diagramCX, diagramCY, diagramRadius)
        local x2, y2 = self:getSlotPos(nextI, diagramCX, diagramCY, diagramRadius)
        love.graphics.line(x1, y1, x2, y2)
    end

    -- Draw center station sprite
    local stationImg = Utils.getCachedImage("assets/images/shared/station_base.png")
    if stationImg then
        local sw, sh = stationImg:getWidth(), stationImg:getHeight()
        local stationSize = 24
        local scale = stationSize / math.max(sw, sh)
        love.graphics.setColor(0, 1, 1)  -- Cyan tint to match game
        love.graphics.draw(stationImg, diagramCX, diagramCY, 0, scale, scale, sw / 2, sh / 2)
    else
        -- Fallback: simple circle
        love.graphics.setColor(0.3, 0.35, 0.45)
        love.graphics.circle("fill", diagramCX, diagramCY, 12)
        love.graphics.setColor(0.5, 0.6, 0.7)
        love.graphics.circle("line", diagramCX, diagramCY, 12)
    end

    -- Draw each slot node
    for i = 0, Constants.STATION_SLOTS - 1 do
        local sx, sy = self:getSlotPos(i, diagramCX, diagramCY, diagramRadius)
        local isOccupied = self.station.usedSlots[i]
        local isSelected = (i == self.selectedSlot)

        if isOccupied then
            -- Occupied: dark filled circle with tool icon
            love.graphics.setColor(0.2, 0.25, 0.35)
            love.graphics.circle("fill", sx, sy, nodeRadius)
            love.graphics.setColor(0.5, 0.6, 0.7)
            love.graphics.circle("line", sx, sy, nodeRadius)

            -- Tool icon
            local toolId = nil
            for _, tool in ipairs(self.station.tools) do
                if tool.slotIndex == i and tool.data then
                    toolId = tool.data.id
                    break
                end
            end
            local icon = self:getToolIcon(toolId)
            if icon then
                local iw, ih = icon:getWidth(), icon:getHeight()
                local iconFit = (nodeRadius * 2) - 4
                local scale = iconFit / math.max(iw, ih)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(icon, sx - (iw * scale) / 2, sy - (ih * scale) / 2, 0, scale, scale)
            end

        elseif isSelected then
            -- Selected: pulsing cyan highlight
            local pulse = 0.6 + math.sin(love.timer.getTime() * 6) * 0.4
            love.graphics.setColor(0, 0.7, 1, pulse)
            love.graphics.circle("fill", sx, sy, nodeRadius + 3)
            love.graphics.setColor(0.15, 0.2, 0.3)
            love.graphics.circle("fill", sx, sy, nodeRadius)
            love.graphics.setColor(0, 0.85, 1)
            love.graphics.circle("line", sx, sy, nodeRadius)

            -- Plus sign to indicate "place here"
            love.graphics.setColor(0, 0.85, 1)
            local plus = "+"
            local plusW = font:getWidth(plus)
            love.graphics.print(plus, sx - plusW / 2, sy - fontH / 2)

        else
            -- Empty unselected: dim outline
            love.graphics.setColor(0.18, 0.22, 0.3)
            love.graphics.circle("fill", sx, sy, nodeRadius)
            love.graphics.setColor(0.3, 0.38, 0.48)
            love.graphics.circle("line", sx, sy, nodeRadius)
        end
    end

    -- 6. Footer
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.line(panelX + 4, panelY + panelH - 20, panelX + panelW - 4, panelY + panelH - 20)

    love.graphics.setColor(0.5, 0.65, 0.8)
    local footerText = "A/D: Rotate   Enter: Place"
    local footerW = font:getWidth(footerText)
    love.graphics.print(footerText, panelX + panelW / 2 - footerW / 2, panelY + panelH - 15)
end

return SlotPicker
