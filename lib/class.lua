-- Simple OOP class system for Love2D
-- Compatible with the Playdate class() API

local function class(name)
    local cls = {}
    cls.__name = name
    cls.__index = cls

    -- Create new instance
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    -- Allow calling class directly as constructor
    setmetatable(cls, {
        __call = function(c, ...)
            return c:new(...)
        end
    })

    -- Extends functionality
    function cls.extends(base)
        -- Set up inheritance
        setmetatable(cls, {
            __index = base,
            __call = function(c, ...)
                return c:new(...)
            end
        })
        cls.super = base
        return cls
    end

    -- Store class globally by name
    _G[name] = cls

    return cls
end

-- Table utilities (from original class.lua)

-- Deep copy a table
function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Check if a table contains a value
function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Get the index of an element in a table
function table.indexOf(tbl, element)
    for i, value in ipairs(tbl) do
        if value == element then
            return i
        end
    end
    return nil
end

-- Remove an element from a table by value
function table.removeValue(tbl, element)
    local index = table.indexOf(tbl, element)
    if index then
        table.remove(tbl, index)
        return true
    end
    return false
end

-- Shuffle a table in place
function table.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- Get table length (works for non-sequential tables too)
function table.length(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return class
