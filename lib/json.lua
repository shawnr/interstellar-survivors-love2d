-- Minimal JSON encoder/decoder for save data
-- Handles strings, numbers, booleans, arrays, and objects

local json = {}

-- Encode Lua value to JSON string
function json.encode(value)
    local t = type(value)

    if value == nil then
        return "null"
    elseif t == "boolean" then
        return value and "true" or "false"
    elseif t == "number" then
        return tostring(value)
    elseif t == "string" then
        -- Escape special characters
        local escaped = value:gsub('\\', '\\\\')
            :gsub('"', '\\"')
            :gsub('\n', '\\n')
            :gsub('\r', '\\r')
            :gsub('\t', '\\t')
        return '"' .. escaped .. '"'
    elseif t == "table" then
        -- Determine if array or object
        local isArray = true
        local maxIndex = 0
        local count = 0
        for k, _ in pairs(value) do
            count = count + 1
            if type(k) == "number" and k == math.floor(k) and k > 0 then
                maxIndex = math.max(maxIndex, k)
            else
                isArray = false
                break
            end
        end

        if isArray and maxIndex == count then
            -- Encode as array
            local parts = {}
            for i = 1, #value do
                parts[i] = json.encode(value[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            -- Encode as object
            local parts = {}
            for k, v in pairs(value) do
                local key = type(k) == "string" and k or tostring(k)
                table.insert(parts, json.encode(key) .. ":" .. json.encode(v))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end

    return "null"
end

-- Decode JSON string to Lua value
function json.decode(str)
    local pos = 1

    local function skipWhitespace()
        while pos <= #str and str:sub(pos, pos):match("%s") do
            pos = pos + 1
        end
    end

    local function parseValue()
        skipWhitespace()
        local c = str:sub(pos, pos)

        if c == '"' then
            return parseString()
        elseif c == '{' then
            return parseObject()
        elseif c == '[' then
            return parseArray()
        elseif c == 't' then
            pos = pos + 4
            return true
        elseif c == 'f' then
            pos = pos + 5
            return false
        elseif c == 'n' then
            pos = pos + 4
            return nil
        else
            return parseNumber()
        end
    end

    function parseString()
        pos = pos + 1  -- skip opening quote
        local result = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == '\\' then
                pos = pos + 1
                local escaped = str:sub(pos, pos)
                if escaped == 'n' then table.insert(result, '\n')
                elseif escaped == 'r' then table.insert(result, '\r')
                elseif escaped == 't' then table.insert(result, '\t')
                elseif escaped == '"' then table.insert(result, '"')
                elseif escaped == '\\' then table.insert(result, '\\')
                else table.insert(result, escaped)
                end
            elseif c == '"' then
                pos = pos + 1
                return table.concat(result)
            else
                table.insert(result, c)
            end
            pos = pos + 1
        end
        return table.concat(result)
    end

    function parseNumber()
        local start = pos
        if str:sub(pos, pos) == '-' then pos = pos + 1 end
        while pos <= #str and str:sub(pos, pos):match("[%d%.eE%+%-]") do
            pos = pos + 1
        end
        return tonumber(str:sub(start, pos - 1))
    end

    function parseArray()
        pos = pos + 1  -- skip [
        local arr = {}
        skipWhitespace()
        if str:sub(pos, pos) == ']' then
            pos = pos + 1
            return arr
        end
        while true do
            table.insert(arr, parseValue())
            skipWhitespace()
            if str:sub(pos, pos) == ',' then
                pos = pos + 1
            else
                break
            end
        end
        skipWhitespace()
        pos = pos + 1  -- skip ]
        return arr
    end

    function parseObject()
        pos = pos + 1  -- skip {
        local obj = {}
        skipWhitespace()
        if str:sub(pos, pos) == '}' then
            pos = pos + 1
            return obj
        end
        while true do
            skipWhitespace()
            local key = parseString()
            skipWhitespace()
            pos = pos + 1  -- skip :
            obj[key] = parseValue()
            skipWhitespace()
            if str:sub(pos, pos) == ',' then
                pos = pos + 1
            else
                break
            end
        end
        skipWhitespace()
        pos = pos + 1  -- skip }
        return obj
    end

    return parseValue()
end

return json
