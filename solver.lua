function operator_in(item, items)
    if type(items) == "table" then
        for k, v in pairs(items) do
            if v == item then
                return true
            end
        end
    elseif type(items) == "string" and type(item) == "string" then
        return string.find(items, item, 1, true) ~= nil
    end

    return false
end

tableContains = function(item, source)
    if type(source) ~= 'table' or type(item) ~= 'table' then
        error('a table is expected as both parameters')
    end
    for counter = 1, #source do
        print('is Contained ' .. source[counter])
        if table.concat(item) == table.concat(source[counter]) then
            return true
        end
    end
    print('isContained :: false')
    return false
end

--[[
AUTHOR: Dylan Bowald

Read the README for a project overview!

Since I kind of awkwardly did this in one file
(it ended up being a lot longer than I thought),
I went ahead and seperated it into sections for
reader convenience.
 ]]


local board = {
    { '?', 'O', '?', 'O', '?', '?' },
    { '?', '?', '?', '?', 'O', '?' },
    { 'O', '?', 'O', '?', '?', '?' },
    { '?', '?', '?', '?', '?', 'O' },
    { 'O', '?', '?', '?', '?', '?' },
    { '?', '?', '?', '?', '?', '?' }
}
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
--[[
Initializes the global board object based on the given file
 ]]
--[[local function init()
    local f = open(sys.argv[1], "r")
    local count = 0
    f.readline()
    local line = f.readline().strip().split("x")
    board = (function()
        local result = list {}
        for i in range(0, int(line[0])) do
            result.append((list { "?" } * int(line[1])))
        end
        return result
    end)()
    for each in range(0, len(board)) do
        rowCount[each] = 0
        colCount[each] = 0
        :: loop_label_1 ::
    end
    f.readline()
    while true do
        line = f.readline().strip()
        if (line == "Columns") then
            break
        else
            rowTents[count] = int(line)
            count = (count + 1)
        end
        :: loop_label_2 ::
    end
    count = 0
    while true do
        line = f.readline().strip()
        if (line == "Trees") then
            break
        else
            colTents[count] = int(line)
            count = (count + 1)
        end
        :: loop_label_3 ::
    end
    while true do
        line = f.readline().strip()
        if (line == "") then
            break
        else
            line = line.split(",")
            board[int(line[0])][int(line[1])] = "O"
        end
        :: loop_label_4 ::
    end
    f.close()
end]]
--[[ Displays the ascii graphic representing the global game board ]]
local function printBoard()
    local border = "  * * " .. string.rep("* ", #board)
    local count = 1
    local bottom = ""
    print(border)
    for row = 1, #board do
        local toPrint = ""
        for col = 1, #board do
            toPrint = toPrint .. board[row][col] .. " "
        end
        print(rowHints[count] .. " * " .. toPrint .. "*")
        bottom = bottom .. colHints[count] .. " "
        count = count + 1
    end
    print(border)
    print("    " .. bottom .. " ")
end
--[[ Checks whether a move at <row, col> is valid within the rules
of tents and trees ]]
function isValid(row, col)
    if isValidSum(row, col) and isValidParity(row, col) and noAdjTents(row, col) then
        return true
    end
    return false
end
--[[ Checks whether placing a tent at <row,col> would exceed any of
the given row or column numbers ]]
function isValidSum(x, y)
    if rowTentCount[x] + 1 > rowHints[x] then
        return false
    end
    if ((colTentCount[y]) + 1 > colHints[y]) then
        return false
    end
    return true
end
--[[ Checks the parity of trees to tents. Essentially, it moves
between a connected chain of tent/tree pairs, and makes sure at
the end the number of trees matches the number of tents ]]
function isValidParity(x, y)
    local parity = -1
    local pred = { x, y }
    for k, v in pairs(getNeighbors(x, y)) do
        parity = (parity + countTreesRec(v[1], v[2], pred))
    end
    if (parity >= 0) then
        return true
    else
        return false
    end
end
--[[
Helper function for isValidParity. Called on a tent
to check for any trees around it, and recursively return the tree
to tent parity.
 ]]
function countTreesRec(x, y, pred)
    table.insert(pred, { x, y })
    if (board[x][y] == "O") then
        local parity = 1
        for k, v in pairs(getNeighbors(x, y)) do
            print('~~ START countTreesRec ~~')
            print(table.unpack(v))
            print(table.unpack(pred))
            if (not tableContains(pred, v)) then
                parity = parity + countTentsRec(v[1], v[2], pred)
            end
        end
        return parity
    else
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
        for k, v in pairs(getNeighbors(x, y)) do
            if (not operator_in(each, pred)) then
                parity = (parity + countTreesRec(v[1], v[2], pred))
            end
        end
        return parity
    else
        return 0
    end
end
--[[
Check that there are no tents adjacent to a given location
 ]]
function noAdjTents(x, y)
    print('noAdjTents -> getTentAdjacent')
    print(getTentAdjacent(x, y))
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
function getNeighbors(x, y)
    local neighbors = {}
    if (x > 1) then
        table.insert(neighbors, { (x - 1), y })
    end
    if (x < #board) then
        table.insert(neighbors, { (x + 1), y })
    end
    if y > 1 then
        table.insert(neighbors, { x, (y - 1) })
    end
    if y < #board then
        table.insert(neighbors, { x, (y + 1) })
    end
    print('~~ PRINT getNeighbors ~~')
    print('FOUND NEIGHBORS OF :: ' .. x .. ' and ' .. y)
    for i = 1, #neighbors do
        print(table.unpack(neighbors[i]))
    end
    print('~~ END PRINT getNeighbors ~~')
    return neighbors
end
--[[
Get the vertical, horizontal, and diagonal neighbors at a given
grid coordinate, returned as a list of coordinates.
 ]]
function getTentAdjacent(x, y)
    local neighbors = getNeighbors(x, y)
    print('getTentAdjacent')
    if x > 1 and y > 1 then
        table.insert(neighbors, { (x - 1), (y - 1) })
    end
    if ((x > 1) and (y < (#board[x]))) then
        table.insert(neighbors, { (x - 1), (y + 1) })
    end
    if ((x < (#board)) and (y > 1)) then
        table.insert(neighbors, { (x + 1), (y - 1) })
    end
    if ((x < (#board)) and (y < (#board))) then
        table.insert(neighbors, { (x + 1), (y + 1) })
    end
    -- print neighbors
    for c = 1, #neighbors do
        print(table.unpack(neighbors[c]))
    end
    return neighbors
end
--[[
Polls for an unknown space, and if it finds one,
returns it as a coordinate.
 ]]
function findUnknown()
    print('~~ START findUnknown ~~')
    for row = 1, #board do
        for col = 1, #board do
            if board[row][col] == "?" then
                print('~~ findUnknown ~~ found :: ' .. board[row][col] .. ' @ ' .. row .. ' ' .. col )
                return row, col
            end
        end
    end
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
            if (board[row][col] == "X") then
                totalRowTents = totalRowTents
            end
        end
        if (totalRowTents ~= rowHints[row]) then
            return false
        else
            totalRowTents = 0
        end
    end
    for col = 1, #board do
        for row = 1, #board do
            if (board[row][col] == "X") then
                totalColTents = totalColTents
            end
        end
        if (totalColTents ~= colHints[col]) then
            return false
        else
            totalColTents = 0
        end
        return true
    end
    --[[
    Returns a deepcopy of all the global state.
     ]]
end


--[[
Mark any spaces not adjacent to a tree as grass
 ]]
function markNotAdjacentAsGrass()
    -- print('~~ getNonAdjGrass ~~ ')
    for row = 1, #board do
        for col = 1, #board do
            if (board[row][col] ~= "O") then
                -- print('getNonAdjGrass :: Not a tree @ row ' .. row .. ' col ' .. col .. ' found ' .. board[row][col])
                board[row][col] = "."
                for k, v in pairs(getNeighbors(row, col)) do
                    if board[v[1]][v[2]] == "O" then
                        board[row][col] = "?"
                        break
                    end
                end
            end
        end
    end
    print('~~ END getNonAdjGrass ~~ ')
    printMap()
end

--[[
Marks any spaces adjacent to a placed tent as grass
 ]]
function markTentAdjGrass(x, y)
    print('Searching tent adjacents for ' .. x .. '  ' .. y)
    for k, v in pairs(getTentAdjacent(x, y)) do
        print('markTentAdjGrass')
        print(board[1][1])
        print(board[2][1])
        --        print('board ' .. v[1] .. '  ' .. v[2] .. ' == ' .. board[v[1]][v[2]])
        if (board[v[1]][v[2]] ~= "O") then
            board[v[1]][v[2]] = "."
        end
    end
end
--[[
Checks the row and column numbers, then marks
any rows or columns with a 0 as grass. Also
checks to see if any of them have the same number
of open spaces as tents needed, and if they do, fills
in those spaces with tents.
 ]]
function markNonBranching()
--[[
    for row in range(0, len(board)):
        for col in range(0, len(board[0])):
            if board[row][col] == "O" or board[row][col] == ".":
                totalRowOccupants += 1
            if rowTents[row] == 0 and board[row][col] != "O":
                board[row][col] = "."
        if len(board[0]) - totalRowOccupants == rowTents[row]:
            for j in range(0, len(board[0])):
                if (board[row][j] == "?"):
                    board[row][j] = "X"
        totalRowOccupants = 0]]
    local totalRowOccupants = 0
    local totalColOccupants = 0
    for row = 1, #board do
        for col = 1, #board do
            if ((board[row][col] == "O") or (board[row][col] == ".")) then
                totalRowOccupants = (totalRowOccupants + 1)
            end
            if ((rowHints[row] == 0) and (board[row][col] ~= "O")) then
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
                totalColOccupants = (totalColOccupants + 1)
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
function markTentRowCol(x, y)
    local totalRowOccupants = 0
    local totalColOccupants = 0
    for col = 1, #board do
        if ((board[x][col] == "O") or (board[x][col] == ".")) then
            totalRowOccupants = (totalRowOccupants + 1)
        end
    end
    if #board - totalRowOccupants == rowHints[x] then
        for j = 1, #board do
            if (board[x][j] == "?") then
                board[x][j] = "X"
            end
        end
    end
    if (rowHints[x] == rowTentCount[x]) then
        for j = 1, #board do
            if (board[x][j] == "?") then
                board[x][j] = "."
            end
        end
    end
    for row = 1, #board do
        if ((board[row][y] == "O") or (board[row][y] == ".")) then
            totalColOccupants = (totalColOccupants + 1)
        end
        :: loop_label_30 ::
    end
    if (#board - totalColOccupants) == colHints[col] then
        for i in range(0, len(board)) do
            if (board[i][y] == "?") then
                board[i][y] = "X"
            end
        end
        if (colHints[y] == colTentCount[y]) then
            for i in range(0, len(board)) do
                if (board[i][y] == "?") then
                    board[i][y] = "."
                end
            end
        end
    end
end
--[[
Primary function to start the solving process. Runs the pre-move
strategies, then calls the recursive solver.
 ]]
local function solve()
    markNotAdjacentAsGrass()
    markNonBranching()
    markNonBranching()
    if (findUnknown() ~= nil) then
        local row, col = findUnknown()
        return solveRec(row, col)
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
function solveRec(row, col)
    if isValid(row, col) then
        board[row][col] = "X"
        colTentCount[col] = (colTentCount[col] + 1)
        rowTentCount[row] = (rowTentCount[row] + 1)
        markTentAdjGrass(row, col)
        markTentRowCol(row, col)
        if (findUnknown() ~= nil) then
            local row, col = findUnknown()
            if (solveRec(row, col) == true) then
                return true
            else
                board[row][col] = "."
                if (solveRec(row, col) == true) then
                    return true
                else
                    return nil
                end
            end
        elseif isGoal() then
            return true
        else
            return nil
        end
    else
        board[row][col] = "."
        if (findUnknown() ~= nil) then
            local row, col = findUnknown()
            if (solveRec(row, col) == true) then
                return true
            else
                return nil
            end
        elseif isGoal() then
            return true
        else
            return nil
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
end
