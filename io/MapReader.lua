---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
--- DateTime: 2019-06-13 15:04
---

local M = {}

local StringUtils = require('utils.StringUtils')
local NumberUtils = require('utils.NumberUtils')

function map(func, tbl)
    local newtbl = {}
    for i, v in pairs(tbl) do
        newtbl[i] = func(v)
    end
    return newtbl
end

--[[
    - check whether file exists and it's readable
    - b' at the end is needed in some systems to open the file in binary mode
]]

local function fileExists(path)
    local file = io.open(path, 'rb')
    if file then
        file:close()
    end
    return file ~= nil
end

local getMapDimesnsion = function(line)

end

local getMapLine = function(iterator)

end

local getTopHints = function(line)

end

local getLeftHints = function(line)

end

function M.parse(path)
    assert(fileExists(path), string.format('File %s does not exist', path))
    local mapWidth = 0

    for line in io.lines(path) do
        -- case - mapDimension
        if string.match(line, '%d') then
            local currentLine = StringUtils.split(line, '([^,%s]+)')
            for _, v in pairs(currentLine) do
                assert(NumberUtils.isInt(tonumber(v)), "Invalid format :: " .. v)
            end
            print(table.unpack(currentLine))
            print(#currentLine)
        end -- for line in io.lines(path) do
    end
    
end

return M