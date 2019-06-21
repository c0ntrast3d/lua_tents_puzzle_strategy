---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
--- DateTime: 2019-06-17 15:04
---

local fOp = require('utils.FunctionalOperators')
local CellType = require('entities.CellType')
local MapState = require('entities.MapState')
local NumberUtils = require('utils.NumberUtils')

local M = {}

M.stringifyMap = function(tentMap, dimension)
    local result = ''
    for row = 1, dimension do
        for col = 1, dimension do
            local char
            local currentType = Cell.getType(tentMap[row][col])
            if currentType == CellType.unknown() then
                char = '_'
            elseif currentType == CellType.tent() then
                char = '▲'
            elseif currentType == CellType.uncertain() then
                char = '?'
            elseif currentType == CellType.grass() then
                char = '~'
            elseif currentType == CellType.tree() then
                char = 'T'
            end
            result = result .. char
        end
        result = result .. '\n'
    end
    return result
end

M.checkIsValid = function(tentMap, topHints, leftHints, dimension)
    local tentsInRow = {}
    for col = 1, dimension do
        tentsInRow[col] = 0
    end
    for row = 1, dimension do
        local tentsInColumn = 0
        for col = 1, dimension do
            if Cell:isTent(tentMap[row][col]) then
                tentsInColumn = tentsInColumn + 1
                tentsInRow[col] = tentsInRow[col] + 1
            end -- if end
        end -- for col = 1 end
        if tentsInColumn + leftHints[row] > dimension then
            return false, string.format('invalid row %d', row)
        end
    end -- for row = 1 end
    for col = 1, dimension do
        if tentsInRow[col] + topHints[col] > dimension then
            return false, string.format('invalid column %d', col)
        end
    end
    local totalTopHint = fOp.reduce(fOp.operator.add, topHints)
    local totalLeftHint = fOp.reduce(fOp.operator.add, leftHints)
    if totalTopHint ~= totalLeftHint then
        return false, 'total tents in top hints must be equal to total tents in left hints'
    end
    return true, ''
end -- checkIsValid End

M.markNoHintAsGrass = function(tentMap, topHints, leftHints, dimension)
    local isChanged = false
    for row = 1, dimension do
        if leftHints[row] == 0 then
            for col = 1, dimension do
                isChanged = Cell.trySetType(tentMap[row][col], CellType.grass())
            end
        end
    end
    for col = 1, dimension do
        if topHints[col] == 0 then
            for row = 1, dimension do
                isChanged = Cell.trySetType(tentMap[row][col], CellType.grass())
            end
        end
    end
    return isChanged
end

M.checkIsSolved = function(tentMap, topHints, leftHints, dimension)
    local tentsInRow = {}
    local unsetRows = {}
    -- init
    for col = 1, dimension do
        tentsInRow[col] = 0
        unsetRows[col] = 0
    end

    for row = 1, dimension do
        local tentsInColumn = 0
        local unsetColumns = 0
        for col = 1, dimension do
            local cell = tentMap[row][col]
            if cell:isTent() then
                tentsInColumn = tentsInColumn + 1
                tentsInRow[col] = tentsInRow[col] + 1
            elseif cell:isNotSet() then
                unsetColumns = unsetColumns + 1
                unsetRows[col] = unsetRows[col] + 1
            end -- if end
        end -- for col

        if tentsInColumn ~= leftHints[row] then
            return false
        end
        if unsetColumns > 0 then
            return false
        end
    end -- for row

    for col = 1, dimension do
        if tentsInRow[col] ~= topHints[col] then
            return false
        end
        if unsetRows[col] then
            return false
        end
        return true
    end -- for end
end -- check is solved end

M.currentState = function(tentMap, topHints, leftHints, prevState, result, stepCount, description, dimension)
    isValid, message = M.checkIsValid(tentMap, topHints, leftHints, dimension)
    if not isValid then
        local state = MapState:create(nil, nil, false, message)
        table.insert(result, state)
        return prevState, stepCount, false, true
    end

    local isSolved = M.checkIsSolved(tentMap, topHints, leftHints, dimension)
    local currentState = M.stringifyMap(tentMap, dimension)
    if prevState ~= currentState then
        local mapState = MapState:create(nil, tentMap, false, isSolved, message)
        table.insert(result, mapState)
        if isSolved then
            return prevState, stepCount, false, true
        end
        stepCount = stepCount + 1
        prevState = currentState
        return prevState, stepCount, true, false
    end
    return prevState, stepCount, false, false
end

M.tryIsTentOrNotSet = function(cell)
    if cell ~= nil then
        return cell:isTent() or cell:isNotSet()
    end
    return false
end

M.tryIsTree = function(cell)
    if cell ~= nil then
        return cell:isTree()
    end
    return false
end

M.getCellsAround = function(map, row, lastRow, nextRow, col, dimension)
    local lastCol = col - 1
    local nextCol = col + 1
    local topCell, leftCell, rightCell, bottomCell
    if lastRow >= 1 then
        topCell = map[lastRow][col]
    end
    if nextRow < dimension then
        bottomCell = map[nextRow][col]
    end
    if lastCol >= 1 then
        leftCell = map[row][lastCol]
    end
    if nextCol < dimension then
        rightCell = map[row][nextCol]
    end
    return topCell, leftCell, rightCell, bottomCell
end

M.findTent = function(cells)
    for cell = 1, #cells do
        if cells[cell] ~= nil then
            if cells[cell]:isTent() then
                return cells[cell]
            end
        end
    end
end

M.findTree = function(cells)
    for counter = 1, #cells do
        if cells[counter] ~= nil then
            if cells[counter]:isTree() then
                return cells[counter]
            end
        end
    end
end

M.removeAssociatedTreesAndTents = function(map, topHints, leftHints, dimension)
    local isRemoved = false
    for row = 1, dimension do
        local lastRow = row - 1
        local nextRow = row + 1
        for col = 1, dimension do
            local cell = map[row][col]
            if cell:isTree() then
                topCell, leftCell, rightCell, bottomCell = M.getCellsAround(map, row, lastRow, nextRow, col, dimension)
                local cellsAround = { topCell, leftCell, rightCell, bottomCell }
                local tentCount = NumberUtils.fromBoolean(M.tryIsTentOrNotSet(topCell))
                        + NumberUtils.fromBoolean(M.tryIsTentOrNotSet(topCell))
                        + NumberUtils.fromBoolean(M.tryIsTentOrNotSet(rightCell))
                        + NumberUtils.fromBoolean(M.tryIsTentOrNotSet(bottomCell))
                if tentCount == 1 then
                    local tentCell = M.findTent(cellsAround)
                    if tentCell ~= nil and tentCell:isTent() then
                        cell:forceSetType(CellType.grass())
                        tentCell:forceSetType(CellType.grass())
                        topHints[tentCell:getColumn()] = topHints[tentCell:getColumn()] - 1
                        leftHints[tentCell:getRow()] = leftHints[tentCell:getRow()] - 1
                        isRemoved = true
                    end
                end
            elseif cell:isTent() then
                topCell, leftCell, rightCell, bottomCell = M.getCellsAround(map, row, lastRow, nextRow, column, dimension)
                local cellsAround = { topCell, leftCell, rightCell, bottomCell }
                local treeCount = NumberUtils.fromBoolean(M.tryIsTree(topCell))
                        + NumberUtils.fromBoolean(M.tryIsTree(topCell))
                        + NumberUtils.fromBoolean(M.tryIsTree(rightCell))
                        + NumberUtils.fromBoolean(M.tryIsTree(bottomCell))
                if treeCount == 1 then
                    local treeCell = M.findTree(cellsAround)
                    if treeCell ~= nil and treeCell:isTree() then
                        cell:forceSetType(CellType.grass())
                        tentCell:forceSetType(CellType.grass())
                        topHints[cell:getColumn()] = topHints[tentCell:getColumn()] - 1
                        leftHints[cell:getRow()] = leftHints[tentCell:getRow()] - 1
                        isRemoved = true
                    end -- treeCell is tree
                end -- tentCount == 1

            end -- if is tree
        end -- for col
    end -- for row
    return isRemoved
end -- remove associated trees and tents end

M.excludeLand = function(tentMap, dimension)
    local isChanged = false
    for row = 1, dimension do
        for col = 1, dimension do
            if not tentMap[row][col]:isNotSet() then
                print(CellType.toString(tentMap[row][col]:getType()) .. ' cell @ row' .. row .. ' col' .. col)
                goto continue
            end
            local lastRow = row - 1
            local lastCol = col - 1
            local nextRow = row + 1
            local nextCol = col + 1
            local noTopTree = true
            local noLeftTree = true
            if lastRow >= 1 then
                noTopTree = not tentMap[lastRow][col]:isTree()
            end
            if lastCol >= 1 then
                noLeftTree = not tentMap[row][lastCol]:isTree()
            end
            local noBottomTree = true
            local noRightTree = true
            if nextRow < dimension then
                noBottomTree = not tentMap[nextRow][col]:isTree()
            end
            if nextCol < dimension then
                noRightTree = not tentMap[row][nextCol]:isTree()
            end
            if noTopTree and noLeftTree and noBottomTree and noRightTree then
                tentMap[row][col]:setType(CellType.grass())
                isChanged = true
            end
            :: continue ::
        end -- for col
        -- continue inner loop
        -- yeah, it's ugly, but it's one of solutions for continue replacement mentioned on lua-users wiki
    end -- for row
    return isChanged
end

local zeroFilledTable = function(dimension)
    local t = {}
    for counter = 1, dimension do
        table.insert(t, 0)
    end
    return t
end

M.placeTentsOnHints = function(tentMap, topHinrs, leftHints, dimension)
    local isChanged = false
    local unknownTentsTop = zeroFilledTable(dimension)
    local unknownTentsLeft = zeroFilledTable(dimension)
    local knownTentsTop = zeroFilledTable(dimension)
    local knownTentsLeft = zeroFilledTable(dimension)

    for row = 1, dimension do
        for col = 1, dimension do
            local cell = tentMap[row][col]
            if cell:isNotSet() then
                unknownTentsTop[col] = unknownTentsTop[col] + 1
                unknownTentsLeft[row] = unknownTentsLeft[row] + 1
            elseif cell:isTent() then
                knownTentsTop[col] = knownTentsTop[col] + 1
                knownTentsLeft[row] = knownTentsLeft[row] + 1
            end -- cell is Not set end
        end -- for col end
    end -- for row end

    for row = 1, dimension do
        if unknownTentsLeft[row] == 0 then
            goto continue
        end
        if knownTentsLeft[row] + unknownTentsLeft[row] == leftHints[row] then
            for col = 1 ,dimension do
                local cell = tentMap[row][col]
                if cell:isNotSet() then
                    tentMap[row][col]:setType(CellType.tent())
                    isChanged = true
                    unknownTentsTop[col] = unknownTentsTop[col] - 1
                    knownTentsTop[col] = knownTentsTop[col] + 1
                end
            end
        end
        :: continue ::
    end -- for row end

    for col = 1, dimension do
        if unknownTentsTop[col] == 0then
            goto continue
        end
        if knownTentsTop[col] + unknownTentsTop[col] == topHints[col] then
            for row = 1 , dimension do
                local cell = tentMap[row][col]
                isChanged = tentMap[row][col]:trySetType(CellType.tent())
            end
        end
        ::continue::
    end -- for col end
end

return M