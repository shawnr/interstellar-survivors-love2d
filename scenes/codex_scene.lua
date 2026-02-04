-- Codex Scene
-- Encyclopedia UI for discovered content

CodexScene = {
    mode = "categories",  -- "categories" or "entries"
    selectedCategory = 1,
    selectedEntry = 1,
    currentCategoryId = nil,
}

function CodexScene:init()
    self.mode = "categories"
    self.selectedCategory = 1
    self.selectedEntry = 1
    self.currentCategoryId = nil
end

function CodexScene:enter(params)
    self.mode = "categories"
    self.selectedCategory = 1
    self.selectedEntry = 1
    self.currentCategoryId = nil
end

function CodexScene:update(dt)
    if self.mode == "categories" then
        self:updateCategories(dt)
    else
        self:updateEntries(dt)
    end
end

function CodexScene:updateCategories(dt)
    local categories = CodexData.categories

    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedCategory = self.selectedCategory - 1
        if self.selectedCategory < 1 then
            self.selectedCategory = #categories
        end
    end

    if InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedCategory = self.selectedCategory + 1
        if self.selectedCategory > #categories then
            self.selectedCategory = 1
        end
    end

    if InputManager:justPressed("return") or InputManager:justPressed("space") then
        local cat = categories[self.selectedCategory]
        if cat then
            self.currentCategoryId = cat.id
            self.selectedEntry = 1
            self.mode = "entries"
        end
    end

    if InputManager:justPressed("escape") then
        if AudioManager then AudioManager:playSFX("menu_back", 0.3) end
        GameManager:goToTitle()
    end
end

function CodexScene:updateEntries(dt)
    local entries = CodexData.getEntries(self.currentCategoryId)

    if InputManager:justPressed("w") or InputManager:justPressed("up") then
        self.selectedEntry = self.selectedEntry - 1
        if self.selectedEntry < 1 then
            self.selectedEntry = #entries
        end
    end

    if InputManager:justPressed("s") or InputManager:justPressed("down") then
        self.selectedEntry = self.selectedEntry + 1
        if self.selectedEntry > #entries then
            self.selectedEntry = 1
        end
    end

    if InputManager:justPressed("escape") then
        if AudioManager then AudioManager:playSFX("menu_back", 0.3) end
        self.mode = "categories"
    end
end

function CodexScene:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1)
    local title = "CODEX"
    local titleWidth = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, Constants.SCREEN_WIDTH / 2 - titleWidth / 2, 10)

    -- Discovery progress
    local discovered = CodexData.getDiscoveredCount()
    local total = CodexData.getTotalCount()
    local progressStr = "Discovered: " .. discovered .. "/" .. total
    local progressWidth = love.graphics.getFont():getWidth(progressStr)
    love.graphics.setColor(0.7, 0.9, 1)
    love.graphics.print(progressStr, Constants.SCREEN_WIDTH / 2 - progressWidth / 2, 24)

    if self.mode == "categories" then
        self:drawCategories()
    else
        self:drawEntries()
    end

    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.5)
    if self.mode == "categories" then
        love.graphics.print("W/S: Navigate  Enter: Open  Esc: Back", 12, Constants.SCREEN_HEIGHT - 16)
    else
        love.graphics.print("W/S: Navigate  Esc: Back to categories", 12, Constants.SCREEN_HEIGHT - 16)
    end
end

function CodexScene:drawCategories()
    local startY = 50
    local itemHeight = 28

    for i, cat in ipairs(CodexData.categories) do
        local y = startY + (i - 1) * itemHeight
        local isSelected = (i == self.selectedCategory)

        if isSelected then
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.rectangle("fill", 20, y - 2, Constants.SCREEN_WIDTH - 40, itemHeight - 4)
        end

        if isSelected then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(">", 24, y)
        end

        -- Category name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(cat.name, 40, y)

        -- Count
        local entries = CodexData.getEntries(cat.id)
        local catDiscovered = 0
        for _, entry in ipairs(entries) do
            if SaveManager:isDiscovered(entry.id) then
                catDiscovered = catDiscovered + 1
            end
        end
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print(catDiscovered .. "/" .. #entries, Constants.SCREEN_WIDTH - 60, y)
    end
end

function CodexScene:drawEntries()
    local entries = CodexData.getEntries(self.currentCategoryId)

    -- Category header
    love.graphics.setColor(0.8, 0.8, 0.8)
    for _, cat in ipairs(CodexData.categories) do
        if cat.id == self.currentCategoryId then
            love.graphics.print(cat.name, 12, 40)
            break
        end
    end

    local startY = 56
    local itemHeight = 18
    local maxVisible = 9  -- Max entries visible at once

    -- Calculate scroll offset
    local scrollOffset = 0
    if self.selectedEntry > maxVisible then
        scrollOffset = self.selectedEntry - maxVisible
    end

    for i = 1, math.min(#entries, maxVisible) do
        local entryIndex = i + scrollOffset
        if entryIndex > #entries then break end

        local entry = entries[entryIndex]
        local discovered = SaveManager:isDiscovered(entry.id)
        local isSelected = (entryIndex == self.selectedEntry)
        local y = startY + (i - 1) * itemHeight

        if isSelected then
            love.graphics.setColor(1, 1, 1, 0.08)
            love.graphics.rectangle("fill", 8, y - 1, Constants.SCREEN_WIDTH - 16, itemHeight - 2)
        end

        if isSelected then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(">", 12, y)
        end

        if discovered then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(entry.name, 28, y)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.print("???", 28, y)
        end
    end

    -- Show description of selected entry at bottom
    if #entries > 0 then
        local selected = entries[self.selectedEntry]
        if selected and SaveManager:isDiscovered(selected.id) then
            love.graphics.setColor(0.7, 0.7, 0.7)
            -- Word-wrap description in bottom area
            local descY = Constants.SCREEN_HEIGHT - 40
            love.graphics.printf(selected.description, 12, descY, Constants.SCREEN_WIDTH - 24, "left")
        end
    end
end

return CodexScene
