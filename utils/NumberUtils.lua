---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by c0ntrast3d.
--- DateTime: 2019-06-14 11:17
---

local M = {}

M.isInt = function(n)
    return ((type(n) == 'number') and (math.floor(n) == n)) and true or error(string.format('%s is not a correct number :: should be integer', n))
end

M.isBinary = function(number)
    return (number <= 1 and number >= 0) and true or error(string.format('Only 0 or 1 are allowed in the map field :: found %d', number))
end

M.isBetween = function(number, min, max)
    return (number >= min and number <= max)
            and true
            or error(string.format('Number of tents can not exceed map size :: found %d', number))
end

M.fromBoolean = function(boolean)
    return boolean == true and 1 or 0
end

return M

