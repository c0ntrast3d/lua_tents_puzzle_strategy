---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
---

local json = require('utils.json')
local MapUtils = require('utils.MapUtils')

local M = {}

local function tryReadJsonMap(path)
    local file = assert(io.open(path, 'rb'), string.format('Unable to open file :: %s', path))
    local content = file:read('*all')
    file:close()
    return content
end

local decodeJsonMap = function(path)
    return json.decode(tryReadJsonMap(path))
end

M.parse = function(path)
    local readerOutput = {}
    local decodedJson = decodeJsonMap(path)
    local mapDimension = MapUtils.getMapDimension(decodedJson)
    local map = MapUtils.getMap(decodedJson, mapDimension)
    local colHints = MapUtils.getColHints(decodedJson, mapDimension)
    local rowHints = MapUtils.getRowHints(decodedJson, mapDimension)
    readerOutput.map = map
    readerOutput.rowHints = rowHints
    readerOutput.colHints = colHints
    readerOutput.mapDimension = mapDimension
    return readerOutput
end

return M