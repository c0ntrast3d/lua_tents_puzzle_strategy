---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
---

local M = {}

M.clone = function(source)
    return { table.unpack(source) }
end

M.deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

M.tableContainsTable = function(item, source)
    if type(source) ~= 'table' or type(item) ~= 'table' then
        error('a table is expected as both parameters')
    end
    for counter = 1, #source do
        if table.concat(item) == table.concat(source[counter]) then
            return true
        end
    end
    return false
end

M.findLastDifferent = function(collection)
    local result = {}
    local counter = #collection
    local index = 0
    while counter >= 2 do
        local current = stringifyMap(collection[counter])
        local previous = stringifyMap(collection[counter - 1])
        if previous ~= current then
            print('prev state found')
            result = collection[counter - 1]
            index = counter - 1
            counter = -1
        end
        counter = counter + 1
    end
    return result
end

return M