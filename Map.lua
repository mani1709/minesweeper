Map = Class{}

grid = {}
local cursorX = 95
local gridX = 1
local cursorY = 0
local gridY = 1
local music = love.audio.newSource('sounds/hexli.mp3', 'static')

function Map:init()
    self.lose = false
    self.win = false
    self.gridsize = 0
    rectsz = 0
end

-- 0 is unopened empty spot
-- 1 is unopened bomb spot
-- 2 is opened empty spot
-- 3 is opened bomb spot and game over
function Map:render()
    for x = 1, gridsize do
        for y = 1, gridsize do 
            if grid[x][y] == 0 or grid[x][y] == 1 then
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", (x-1)*rectsz+95, (y-1)*rectsz, rectsz, rectsz)
                love.graphics.setColor(128, 0, 0)
                love.graphics.rectangle("line", (x-1)*rectsz+95, (y-1)*rectsz, rectsz, rectsz)
            elseif grid[x][y] == 2 then
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", (x-1)*rectsz+95, (y-1)*rectsz, rectsz, rectsz)
                love.graphics.setColor(0, 128, 0)
                love.graphics.rectangle("line", (x-1)*rectsz+95, (y-1)*rectsz, rectsz, rectsz)
            end
        end
    end
    love.graphics.setColor(0, 128, 0)
    love.graphics.rectangle("line", cursorX, cursorY, rectsz, rectsz)
end

function Map:createGrid(gridsz, bombs)
    gridsize = gridsz
    for x = 1, gridsize do
        grid[x] = {}
        for y = 1, gridsize do 
            grid[x][y] = 0
        end
    end
    rectsz = math.floor(243 / gridsize)

    for x = 1, bombs do
        randx = love.math.random(1, gridsz)
        randy = love.math.random(1, gridsz)
        while grid[randx][randy] == 1 do
            randx = love.math.random(1, gridsz)
            randy = love.math.random(1, gridsz)
        end
        grid[randx][randy] = 1
    end
    cursorX = 95
    gridX = 1
    cursorY = 0
    gridY = 1
    Map.lose = false
    Map.win = false
    music:setLooping(true)
    music:play()
end

function Map:moveUp()
    oldcursorY = cursorY
    cursorY = math.max(cursorY - rectsz, 0)
    if oldcursorY ~= cursorY then
        gridY = gridY - 1
    end
end

function Map:moveDown()
    oldcursorY = cursorY
    cursorY = math.min(cursorY + rectsz, gridsize*rectsz-rectsz)
    if oldcursorY ~= cursorY then
        gridY = gridY + 1
    end
end

function Map:moveLeft()
    oldcursorX = cursorX
    cursorX = math.max(cursorX - rectsz, 95)
    if oldcursorX ~= cursorX then
        gridX = gridX - 1
    end
end

function Map:moveRight()
    oldcursorX = cursorX
    cursorX = math.min(cursorX + rectsz, 95+gridsize*rectsz-rectsz)
    if oldcursorX ~= cursorX then
        gridX = gridX + 1
    end
end

function Map:turnTile()
    if grid[gridX][gridY] == 0 then
        grid[gridX][gridY] = 2
    elseif grid[gridX][gridY] == 1 then
        grid[gridX][gridY] = 3
    end
end

function Map:checkWinAndLoseCon()
    self.win = true
    for x = 1, gridsize do
        for y = 1, gridsize do 
            if grid[x][y] == 3 then
                self.lose = true
            end
            if grid[x][y] == 0 then
                self.win = false
            end
        end
    end
end

function Map:renderBombsNearby() 
    love.graphics.setFont(smallFont)
    for x = 1, gridsize do
        for y = 1, gridsize do 
            if grid[x][y] == 2 then
                love.graphics.print(Map:countBombsNearby(x, y), 95+(x-1)*rectsz-1+rectsz/2-4, (y-1)*rectsz+rectsz/2-2)
            end
        end
    end
end

function Map:countBombsNearby(x, y)
    count = 0 
    if x > 1 and y > 1 then
        if grid[x-1][y-1] == 1 then
            count = count + 1
        end
    end 
    if y > 1 then
        if grid[x][y-1] == 1 then
            count = count + 1
        end
    end 
    if y > 1 and x < gridsize then
        if grid[x+1][y-1] == 1 then
            count = count + 1
        end
    end 
    if x > 1 then
        if grid[x-1][y] == 1 then
            count = count + 1
        end
    end 
    if x < gridsize then
        if grid[x+1][y] == 1 then
            count = count + 1
        end
    end 
    if y < gridsize and x > 1 then
        if grid[x-1][y+1] == 1 then
            count = count + 1
        end
    end
    if y < gridsize then
        if grid[x][y+1] == 1 then
            count = count + 1
        end
    end
    if y < gridsize and x < gridsize then
        if grid[x+1][y+1] == 1 then
            count = count + 1
        end
    end
    return count
end

function Map:playMusic()
    love.audio.play(music)
    music:setLooping(true)
end

function Map:stopMusic()
    love.audio.stop(music)
    music:setLooping(false)
end