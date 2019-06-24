tableContainsTable = function(item, source)
    if type(source) ~= 'table' or type(item) ~= 'table' then
        error('a table is expected as both parameters')
    end
    for counter = 1, #source do
        if table.concat(item) == table.concat(source[counter]) then
            --print('is Contained ' .. table.concat(item) .. ' in ' .. table.concat(source[counter]))
            --printTable(source)
            return true
        end
    end
    --print('isContained :: false')
    --print(table.concat(item))
    --printTable(source)
    return false
end

stringifyMap = function(tentMap)
    local result = ''
    if not tentMap then
        return
    end
    for row = 1, #tentMap do
        for col = 1, #tentMap do
            local char
            local currentType = tentMap[row][col]
            if currentType == '?' then
                char = '?'
            elseif currentType == 'X' then
                char = '▲'
            elseif currentType == '.' then
                char = '.'
            elseif currentType == 'O' then
                char = 'T'
            end
            result = result .. char
        end
        result = result .. '\n'
    end
    return result
end

local board = {
    { '?', 'O', '?', 'O', '?', '?' },
    { '?', '?', '?', '?', 'O', '?' },
    { 'O', '?', 'O', '?', '?', '?' },
    { '?', '?', '?', '?', '?', 'O' },
    { 'O', '?', '?', '?', '?', '?' },
    { '?', '?', '?', '?', '?', '?' }
}
local boardStates = {}
local rowHints = { 2, 1, 1, 2, 1, 0 }
local colHints = { 2, 0, 2, 0, 2, 1 }
local rowTentCount = { 0, 0, 0, 0, 0, 0 }
local colTentCount = { 0, 0, 0, 0, 0, 0 }

printMap = function()
    print('START PRINTING BOARD')
    for r = 1, #board do
        local row = ''
        for c = 1, #board do
            row = row .. board[r][c] .. ''
        end
        print(row)
    end
    print('STOP PRINTING BOARD')
end

--[[ Displays the ascii graphic representing the global game board ]]
local function printBoard()
    local space = '   '
    local borderTop = space .. '_' .. string.rep("__", #board)
    local borderBottom = space .. '¯' .. string.rep("¯", #board * 2)
    local count = 1
    local bottom = ""
    print(borderTop)
    for row = 1, #board do
        local toPrint = ""
        for col = 1, #board do
            toPrint = toPrint .. board[row][col] .. " "
        end
        print(rowHints[count] .. " | " .. toPrint .. '|')
        bottom = bottom .. colHints[count] .. " "
        count = count + 1
    end
    print(borderBottom)
    print(space .. bottom .. " ")
end
--[[ Checks whether a move at <row, col> is valid within the rules
of tents and trees ]]
function isValid(row, col, caller)
    print('~~ START isValid ~~ INPUT :: row  = ' .. row .. ' col = ' .. col .. ' CALLER :: ' .. caller)
    if isValidSum(row, col, '~~ isValid ~~') and isValidParity(row, col, '~~ isValid ~~') and noAdjTents(row, col, '~~ isValid ~~') then
        return true
    end
    return false
end
--[[ Checks whether placing a tent at <row,col> would exceed any of
the given row or column numbers ]]
function isValidSum(x, y, caller)
    print('START ~~ isValidSum ~~ :: INPUT :: row = ' .. x .. ' col = ' .. y .. ' CALLER :: ' .. caller)
    print('rowTentsCount = ' .. rowTentCount[x] .. ' rowHints = ' .. rowHints[x])
    if rowTentCount[x] + 1 > rowHints[x] then
        print('~~ isValidSum ~~ :: FALSE')
        return false
    end
    print('colTentsCount = ' .. colTentCount[y] .. ' colHints = ' .. colHints[y])
    if colTentCount[y] + 1 > colHints[y] then
        print('~~ isValidSum ~~ :: FALSE')
        return false
    end
    print('~~ isValidSum ~~ :: TRUE')
    return true
end
--[[ Checks the parity of trees to tents. Essentially, it moves
between a connected chain of tent/tree pairs, and makes sure at
the end the number of trees matches the number of tents ]]
function isValidParity(x, y, caller)
    print('~~START isValidParity :: x = ' .. x .. ' y = ' .. y .. ' CALLER :: ' .. caller)
    local parity = -1
    pred = { { x, y } }
    for k, v in pairs(getNeighbors(x, y, '~~ isValidParity ~~')) do
        --print('~~ isValidParity LOOP START')
        parity = parity + countTreesRec(v[1], v[2], pred)
    end
    if (parity >= 0) then
        print('~~ isValidParity LOOP END :: PARITY == ' .. parity)
        return true
    end
    print('~~ isValidParity LOOP END :: PARITY == ' .. parity)
    return false
end
--[[
Helper function for isValidParity. Called on a tent
to check for any trees around it, and recursively return the tree
to tent parity.
 ]]
printTable = function(tbl)
    print ':: PRINTING TABLE ::'
    print('tbl length :: ' .. #tbl .. ' tbl contents :: ')
    for outer = 1, #tbl do
        local current = ''
        for inner = 1, #tbl[1] do
            current = current .. tbl[outer][inner] .. ' '
        end
        io.write(current)
        io.write(', ')
    end
    print('  ')
end

function countTreesRec(x, y, pred)
    print('~~ START countTreesRec ~~')
    io.write('got parameters :: x = ' .. x .. ' y = ' .. y .. ' pred =  ')
    printTable(pred)
    table.insert(pred, { x, y })
    if (board[x][y] == "O") then
        local parity = 1
        for k, v in pairs(getNeighbors(x, y, '~~ countTreesRec ~~')) do
            --io.write('value in getNeighbours :: ')
            print(table.unpack(v))
            if (not tableContainsTable(v, pred)) then
                print('UPDATING PARITY IN countTreesRec ::: current is ' .. parity)
                print(v[1] .. ' ' .. v[2])
                parity = parity + countTentsRec(v[1], v[2], pred)
            end
        end
        print('~~ END countTreesRec ~~')
        return parity
    else
        print('~~ END countTreesRec PARITY == 0 ~~')
        return 0
    end
end
--[[
Helper function for isValidParity. Called on a tree to
check for any tents around it, and recursively return the tree
to tent parity.
 ]]
function countTentsRec(x, y, pred)
    table.insert(pred, { x, y })
    if (board[x][y] == "X") then
        local parity = -1
        for k, v in pairs(getNeighbors(x, y, '~~ countTentsRec ~~')) do
            if (not tableContainsTable(v, pred)) then
                parity = parity + countTreesRec(v[1], v[2], pred)
            end
        end
        --print 'END countTreesRec'
        return parity
    end
    return 0
end
--[[
Check that there are no tents adjacent to a given location
 ]]
function noAdjTents(x, y)
    --print('noAdjTents -> getTentAdjacent')
    --print(getTentAdjacent(x, y))
    for k, v in pairs(getTentAdjacent(x, y)) do
        if (board[v[1]][v[2]] == "X") then
            return false
        end
    end
    return true
end
--[[
Get the vertical and horizontal neighbors at a given
grid coordinate, returned as a list of coordinates.
 ]]
function getNeighbors(x, y, caller)
    print('~~  START getNeighbors ~~ ' .. ' CALLER ::  ' .. caller)
    local neighbors = {}
    if (x > 1) then
        table.insert(neighbors, { x - 1, y })
    end
    if x < #board then
        table.insert(neighbors, { x + 1, y })
    end
    if y > 1 then
        table.insert(neighbors, { x, y - 1 })
    end
    if y < #board then
        table.insert(neighbors, { x, y + 1 })
    end
    print('~~ PRINT getNeighbors ~~')
    print('FOUND NEIGHBORS OF :: ' .. x .. ' and ' .. y)
    for i = 1, #neighbors do
        print(table.unpack(neighbors[i]))
    end
    print('~~ END PRINT getNeighbors ~~' .. ' CALLER :: ' .. caller)
    return neighbors
end
--[[
Get the vertical, horizontal, and diagonal neighbors at a given
grid coordinate, returned as a list of coordinates.
 ]]
function getTentAdjacent(x, y)

    local neighbors = getNeighbors(x, y, '~~ getTentAdjacent ~~')
    --print('getTentAdjacent')
    if x > 1 and y > 1 then
        table.insert(neighbors, { x - 1, y - 1 })
    end
    if x > 1 and y < #board - 1 then
        table.insert(neighbors, { x - 1, y + 1 })
    end
    if x < #board - 1 and y > 1 then
        table.insert(neighbors, { x + 1, y - 1 })
    end
    if x < #board and y < #board - 1 then
        table.insert(neighbors, { x + 1, y + 1 })
    end
    -- print neighbors
    --[[    for c = 1, #neighbors do
            print(' ~~ getTentAdjacent -> gor neighbors')
            print(table.unpack(neighbors[c]))
        end]]
    return neighbors
end
--[[
Polls for an unknown space, and if it finds one,
returns it as a coordinate.
 ]]
function findUnknown(caller)
    print('~~ START findUnknown ~~ :: CALLER :: ' .. caller)
    printBoard()
    for row = 1, #board do
        for col = 1, #board do
            if board[row][col] == "?" then
                print('~~ findUnknown ~~ found :: ' .. board[row][col] .. ' @ ' .. row .. ' ' .. col)
                return row, col
            end
        end
    end
    print('~~ findUnknown ~~ found :: NONE')
    print('~~ END findUnknown ~~')
    return nil
end


--[[
Checks the board against the game constraints
to see whether or not we have reached a goal
state. Returns true if so, false otherwise.
 ]]
function isGoal()
    local totalRowTents = 0
    local totalColTents = 0
    for row = 1, #board do
        for col = 1, #board do
            if board[row][col] == "X" then
                totalRowTents = totalRowTents + 1
            end
        end
        if (totalRowTents ~= rowHints[row]) then
            --print('~~ isGoal == FALSE ~~')
            --print(string.format('total row tent ~= rowhints :: total: %d | hints: %d | row: %d', totalRowTents, rowHints[row], row))
            return false
        else
            totalRowTents = 0
        end
    end
    for col = 1, #board do
        for row = 1, #board do
            if (board[row][col] == "X") then
                totalColTents = totalColTents + 1
            end
        end
        if (totalColTents ~= colHints[col]) then
            --print('~~ isGoal == FALSE ~~')
            return false
        else
            totalColTents = 0
        end
    end
    --print('~~ isGoal == TRUE ~~')
    return true
end


--[[
Mark any spaces not adjacent to a tree as grass
 ]]
function markNotAdjacentAsGrass()
    print('~~ START getNonAdjGrass ~~ ')
    for row = 1, #board do
        for col = 1, #board do
            if (board[row][col] ~= "O") then
                --print('getNonAdjGrass :: Not a tree @ row ' .. row .. ' col ' .. col .. ' found ' .. board[row][col])
                board[row][col] = "."
                for k, v in ipairs(getNeighbors(row, col, '~~ markNotAdjacentAsGrass ~~')) do
                    print(table.unpack(v))
                    if board[v[1]][v[2]] == "O" then
                        board[row][col] = "?"
                        break
                    end
                end
            end
        end
    end
    printBoard()
    --print('~~ END getNonAdjGrass ~~ ')
    --printMap()
end

--[[
Marks any spaces adjacent to a placed tent as grass
 ]]
function markTentAdjGrass(x, y, caller)
    print('START ~~ markTentAdjGrass ~~ :: INPUT :: row = ' .. x .. ' col = ' .. y .. ' CALLER :: ' .. caller)
    for k, v in pairs(getTentAdjacent(x, y)) do
        print('markTentAdjGrass board ' .. v[1] .. '  ' .. v[2] .. ' == ' .. board[v[1]][v[2]])
        if (board[v[1]][v[2]] ~= "O") then
            board[v[1]][v[2]] = "."
        end
    end
    printBoard()
end
--[[
Checks the row and column numbers, then marks
any rows or columns with a 0 as grass. Also
checks to see if any of them have the same number
of open spaces as tents needed, and if they do, fills
in those spaces with tents.
 ]]
function markNonBranching()
    local totalRowOccupants = 0
    local totalColOccupants = 0
    for row = 1, #board do
        for col = 1, #board do
            if board[row][col] == "O" or board[row][col] == "." then
                totalRowOccupants = totalRowOccupants + 1
            end
            if rowHints[row] == 0 and board[row][col] ~= "O" then
                board[row][col] = "."
            end
        end
        if #board - totalRowOccupants == rowHints[row] then
            for j = 1, #board do
                if (board[row][j] == "?") then
                    board[row][j] = "X"
                end
            end
        end
        totalRowOccupants = 0
    end
    for col = 1, #board do
        for row = 1, #board do
            if board[row][col] == "O" or board[row][col] == "." then
                totalColOccupants = totalColOccupants + 1
            end
            if colHints[col] == 0 and board[row][col] ~= "O" then
                board[row][col] = "."
            end
        end
        if #board - totalColOccupants == colHints[col] then
            for i = 1, #board do
                if (board[i][col] == "?") then
                    board[i][col] = "X"
                end
            end
        end
        totalColOccupants = 0
    end
end
--[[
Checks the given row and column numbers, then
checks to see if they have the same number
of open spaces as tents needed, and if they do,
fills n those spaces with tents. Compares number
of tents to row and column numbers, and if equal,
fills in the rest of the spaces with grass.
 ]]
function markTentRowCol(x, y, caller)
    print('START ~~ markTentRowCol ~~ :: INPUT :: row = ' .. x .. ' col = ' .. y .. ' CALLER :: ' .. caller)
    print('~~ markTentRowCol ~~ :: PRINTING BOARD')
    printBoard()
    local totalRowOccupants = 0
    local totalColOccupants = 0
    ncol = 1
    for col = 1, #board do
        if board[x][col] == "O" or board[x][col] == "." or board[x][col] == "X" then
            totalRowOccupants = totalRowOccupants + 1
        end
        ncol = col
    end
    print('~~ markTentRowCol ~~ :: CALCULATED totalRowOccupants :: ' .. totalRowOccupants .. ' for row ' .. x)
    -- print('BOARD LENGTH : ' .. #board .. ' TOTAL ROWS OCCUPIED ' .. totalRowOccupants .. ' ON ROW ' .. row .. ' COL  ' .. col .. ' rowHints ' .. rowHints[col])
    if #board - totalRowOccupants == rowHints[x] then
        print('~~ markTentRowCol ~~ ::  #board - totalRowOccupants == rowHints[x] == TRUE')
        for j = 1, #board do
            if board[x][j] == "?" then
                print('~~ markTentRowCol ~~ :: MARKED AS TENT :: row ' .. x .. ' col ' .. j)
                board[x][j] = "X"
            end
        end
    end
    if rowHints[x] == rowTentCount[x] then
        print('~~ markTentRowCol ~~ ::  rowTents[x] == rowCount[x] == TRUE')
        for j = 1, #board do
            if board[x][j] == "?" then
                print('~~ markTentRowCol ~~ :: MARKED AS GRASS :: row ' .. x .. ' col ' .. j)
                board[x][j] = "."
            end
        end
    end
    for row = 1, #board do
        if board[row][y] == "O" or board[row][y] == "." or board[row][y] == "X" then
            totalColOccupants = totalColOccupants + 1
        end
    end
    print('~~ markTentRowCol ~~ :: CALCULATED totalColOccupants :: ' .. totalColOccupants .. ' for col ' .. y)
    --print('~~ markTentRowCol ~~')
    -- print('BOARD LENGTH : ' .. #board .. ' TOTAL COL OCCUPIED ' .. totalColOccupants .. ' ON ROW ' .. row .. ' COL  ' .. col .. ' colHints ' .. colHints[col])
    print('board :: ' .. #board .. ' totalColOccupants :: ' .. totalColOccupants .. ' coltents[col] :: ' .. colHints[ncol] .. ' col :: ' .. ncol)
    if #board - totalColOccupants == colHints[ncol] then
        print('~~ markTentRowCol ~~ ::  #board - totalColOccupants == colHints[col] == TRUE')
        printBoard()
        for i = 1, #board do
            if (board[i][y] == "?") then
                board[i][y] = "X"
                --print('BOARD LENGTH : ' .. #board .. ' TOTAL COL OCCUPIED ' .. totalColOccupants .. ' ON ROW ' .. row .. ' COL  ' .. col .. ' ' .. colHints[col])
            end
        end
        if (colHints[y] == colTentCount[y]) then
            for i = 1, #board do
                if (board[i][y] == "?") then
                    board[i][y] = "."
                end
            end
        end
    end
    print('~~ markTentRowCol ~~ :: PRINTING BOARD')
    printBoard()
end -- markTentRowCol END
--[[
Primary function to start the solving process. Runs the pre-move
strategies, then calls the recursive solver.
 ]]
local function solve()
    markNotAdjacentAsGrass()
    markNonBranching()
    markNonBranching()
    if (findUnknown('~~ solve ~~') ~= nil) then
        row, col = findUnknown('~~ solve :: FU NOT NULL ~~')
        return solveRec(row, col, '~~ solve ~~')
    elseif isGoal() then
        return true
    else
        return nil
    end
end
--[[
Recursive solver function. Checks for an empty
spot, then attempts to put a tent there. Runs the
other strategies, then recurse. If there are no
unknowns left, it checks to see if we've reached a goal
state; if we have, it returns true to signify the goal
has been reached.
 ]]

local clone = function(source)
    return { table.unpack(source) }
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

saveState = function()
    local state = {}
    print('-- SAVING METADATA --')
    print('<- CURRENT BOARD AND HINTS ->')
    printBoard()
    print('-- END SAVING METADATA --')
    -- state.board = deepcopy(board)
    table.insert(boardStates, deepcopy(board))
    state.board = deepcopy(board)
    state.rowHints = deepcopy(rowHints)
    state.colHints = deepcopy(colHints)
    state.rowTentCount = deepcopy(rowTentCount)
    state.colTentCount = deepcopy(colTentCount)
    return state
end

findLastDifferent = function(collection)
    local result = {}
    local counter = #collection
    local index = 0
    while counter >=2  do
        local current = stringifyMap(collection[counter])
        local previous = stringifyMap(collection[counter - 1])
        if previous ~= current  then
            print('prev state found')
            result = collection[counter - 1]
            index = counter - 1
            counter = -1
        end
        counter = counter + 1
    end
    return result
end

local restoreState = function(previous)
    print('-- RESTORING METADATA --')
    print('BEFORE RESTORING METADATA THE BOARD WAS :: ')
    printMap(previous.board)
    print('AFTER RESTORING METADATA TE BOARD WAS :: ')
    printMap(boardStates[#boardStates])
    print('<- CURRENT BOARD AND HINTS ->')
    printBoard()
    print('ROW COUNT :: ')
    print(table.unpack(rowTentCount))
    print('COL COUNT :: ')
    print(table.unpack(colTentCount))
    print(#boardStates)
    print('-- END RESTORING METADATA --')
    local last = findLastDifferent(boardStates)
    print(stringifyMap(last))
    print('-- END RESTORING METADATA --')
    board = deepcopy(previous.board)
    rowHints = previous.rowHints
    colHints = previous.colHints
    rowTentCount = previous.rowTentCount
    colTentCount = previous.colTentCount
end

function solveRec(row, col, caller)
    row, col = row, col
    print('START ~~ solveRec ~~ :: INPUT :: row = ' .. row .. ' col = ' .. col .. ' CALLER :: ' .. caller)
    printBoard()
    local currentState = saveState()
    printBoard()
    if isValid(row, col, '~~ solveRec ~~') then
        print('~~ solveRec ~~ :: if IS VALID  ')
        board[row][col] = "X"
        printBoard()
        colTentCount[col] = colTentCount[col] + 1
        rowTentCount[row] = rowTentCount[row] + 1
        markTentAdjGrass(row, col, '~~ solveRec ~~')
        markTentRowCol(row, col, '~~ solveRec ~~')
        if findUnknown('~~ solveRec ~~') ~= nil then
            print('~~ solveRec ~~ :: if findUnknown(~~ solveRec ~~) != None:')
            row, col = findUnknown('~~ solveRec ~~ :: FU NOT NULL')
            printBoard()
            if solveRec(row, col, '~~ solveRec ~~') == true then
                print('~~ solveRec ~~ :: solveRec(row, col, ~~ solveRec ~~) == True')
                return true
            else
                print('~~ solveRec ~~ :: solveRec(row, col, ~~ solveRec ~~) == True :: ELSE BRANCH')
                restoreState(deepcopy(currentState))
                print('RESTORED ::')
                print(stringifyMap(board))
                print('board[row][col] = "."')
                print('row = ' .. row .. 'col = ' .. col)
                board[row][col] = "."
                check = solveRec(row, col, '~~ solveRec ~~')
                if check == true then
                    print('~~ solveRec ~~ :: solveRec(row, col, ~~ solveRec ~~) == True :: ELSE BRANCH --> IF')
                    return true
                else
                    print('~~ solveRec ~~ :: solveRec(row, col, ~~ solveRec ~~) == True :: ELSE BRANCH --> ELSE')
                    return nil
                end
            end
        else
            print('~~ solveRec ~~ :: if findUnknown(~~ solveRec ~~) != None:')
            printBoard()
            if isGoal() then
                print('~~ solveRec ~~ :: if findUnknown(~~ solveRec ~~) != None: :: IF IS GOAL ')
                return true
            else

                print('~~ solveRec ~~ :: if findUnknown(~~ solveRec ~~) != None: :: IF IS NOT GOAL ')
                return nil
            end
        end

    else
        print('~~ solveRec ~~ :: if IS VALID  ELSE BRANCH ')
        board[row][col] = "."
        if (findUnknown('~~ solveRec ~~') ~= nil) then
            row, col = findUnknown('~~ solveRec ~~ :: FU NOT NULL')
            if solveRec(row, col, '~~ solveRec ~~') then
                print('~~ solveRec ~~ :: if IS VALID  ELSE BRANCH IF SOLVEREC ')
                return true
            else
                print('~~ solveRec ~~ :: if IS VALID  ELSE BRANCH IF FIND UNKNOWN != NULL && SOLVEREC == FALSE')
                return nil
            end
        else
            print('~~ solveRec ~~ :: if IS VALID  ELSE BRANCH IF FIND UNKNOWN ==== NULL')
            if isGoal() then
                print('~~ solveRec ~~ :: if IS VALID  ELSE BRANCH IF FIND UNKNOWN ==== NULL :: IS GOAL')
                return true
            else
                print('~~ solveRec ~~ :: if IS VALID  ELSE BRANCH IF FIND UNKNOWN ==== NULL :: IS NOT GOAL')
                return nil
            end
        end
    end

end
--[[
In all but name, my main function. Starts everything.
 ]]
printBoard()
printMap()
if solve() then
    print("Found a solution: ")
    printBoard()
else
    print("Sorry, no solution could be found")
    printBoard()
end

print(#boardStates)
--[[for c = 1, #boardStates do
    print('c = ' .. c)
    for j = 1, #boardStates do
        print('j = ' .. j)
        print(table.unpack(boardStates[c][j]))
    end
end]]
print(stringifyMap(board))
for i = 1, #boardStates do
    print('i == ' .. i)
    print(stringifyMap(boardStates[i]))
end