---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
--- DateTime: 2019-06-17 15:05
---

local CellType = require('entities.CellType')

Cell = {}
Cell.__index = Cell

function Cell:create(row, column)
    local cell = {}
    setmetatable(cell, Cell)
    cell.type = CellType.unknown()
    cell.row = row
    cell.column = column
    return cell
end

function Cell:getRow()
    return self.row
end

function Cell:getColumn()
    return self.column
end

function Cell:getType()
    return self.type
end

function Cell:isTree()
    return self.type == CellType.tree()
end

function Cell:isTent()
    return self.type == CellType.tent()
end

function Cell:isSet()
    return self.type == CellType.tree() or self.type == CellType.grass() or self.type == CellType.tent()
end

function Cell:isNotSet()
    return self.type == CellType.uncertain() or self.type == CellType.unknown()
end

function Cell:sureNotATent()
    return self.type == CellType.tree() or self.type == CellType.grass()
end

function Cell:setType(type)
    if self.isNotSet(self) then
        self.type = type
    else
        error(string.format('This cell is already set to :: %s', CellType.toString(self.type)))
    end
end

function Cell:forceSetType(type)
    self.type = type
end

function Cell:trySetType(type)
    if self.isNotSet(self) then
        self.type = type
        return true
    end
    return false
end

function Cell:print()
    print(string.format('Row : %d | Col : %d | Type : %s', self.row, self.column, CellType.toString(self.type)))
end

return Cell