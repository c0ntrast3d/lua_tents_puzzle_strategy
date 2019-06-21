---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
--- DateTime: 2019-06-17 15:04
---
---
local Cell = require('entities.Cell')
local CellType = require('entities.CellType')
local SolverHelpers = require('solver.SolverHelpers')
local MapState = require('entities.MapState')
local TableUtils = require('utils.TableUtils')

local M = {}

local initTentMap = function(dimension)
    print('Initializing map')
    local tentMap = {}
    for row = 1, dimension do
        tentMap[row] = {}
        for col = 1, dimension do
            tentMap[row][col] = Cell:create(row, col)
        end -- for col = 1
    end -- for row = 1
    return tentMap
end

local placeTrees = function(treeMap, tentMap, dimension)
    print('Placing trees')
    for row = 1, dimension do
        for col = 1, dimension do
            if treeMap[row][col] == 1 and Cell.isNotSet(tentMap[row][col]) then
                Cell.setType(tentMap[row][col], CellType.tree())
            end
        end
    end
    return tentMap
end

M.solve = function(dimension, treeMap, topHints, leftHints)
    local result = {}
    local tentMap = placeTrees(treeMap, initTentMap(dimension), dimension)
    print(SolverHelpers.stringifyMap(tentMap, dimension))
    local isValid = false
    isValid, message = SolverHelpers.checkIsValid(tentMap, topHints, leftHints, dimension)
    if not isValid then
        error(message)
    end
    table.insert(result, MapState:create({}, tentMap, isValid, false, 'Created initial map'))
    local stepCount = 1;
    local prevState = SolverHelpers.stringifyMap(tentMap, dimension)

    SolverHelpers.markNoHintAsGrass(tentMap, topHints, leftHints, dimension)
    prevState, stepCount, continue, finish = SolverHelpers.currentState(tentMap, topHints, leftHints, prevState, result, stepCount, message, dimension)
    print('Mark no hints as grass')
    print(SolverHelpers.stringifyMap(tentMap, dimension))
    if finish then
        return result
    end
    while (isValid) do
        print('Removing associated')
        local isRemoved = SolverHelpers.removeAssociatedTreesAndTents(tentMap, topHints, leftHints, dimension)
        print(isRemoved)
        if isRemoved then
            table.insert(result, MapState:create(nil, nil, false, false, 'Remove associated trees and tents'))
        end
        local isChanged = SolverHelpers.excludeLand(tentMap, dimension);
        print('Excluding land')
        print(SolverHelpers.stringifyMap(tentMap, dimension))
        if isChanged then
            prevState, stepCount, continue, finish = SolverHelpers.currentState(tentMap, topHints, leftHints, prevState, result, stepCount, message, dimension)
            if finish then
                break
            end
            if continue then
                goto continue
            end
        end -- if is changed end
        :: continue ::
        isValid = false
    end -- while is valid
    --[[        for i = 1, dimension do
                for j = 1, dimension do
                    Cell.print(tentMap[i][j])
                end
            end]]
    print(SolverHelpers.stringifyMap(tentMap, dimension))

end -- solve end

return M
