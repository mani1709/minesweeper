--[[
    Minesweeper
    by Manuel Zechmann
    hexli.mp3 from https://soundcloud.com/user-526485730-259579305/1st-song/s-GdKKO
    background.jpg from https://www.pexels.com/photo/abstract-ancient-antique-art-235985/
    victory.wav from https://freesound.org/people/chripei/sounds/165491/
    lose.wav from https://freesound.org/people/Rocotilos/sounds/178875/
]]

push = require 'push'       -- retro look
Class = require 'class'     -- class library
require 'Map'               -- map class

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

gridsize = 10
bombs = 10
startedMusic = false

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')        -- 2D look
    love.window.setTitle('Minesweeper')                         -- set Title
    math.randomseed(os.time())                                  -- seed RNG

    -- Fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(smallFont)

    -- Background
    background = love.graphics.newImage("graphics/background.jpg")

    --initialize window with the virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    gameState = 'title' -- gamestates: title, pause, play, finished
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if Map.lose == true or Map.win == true then
        gameState = 'finished'
        Map:stopMusic()
        if Map.lose == true and startedMusic == false then
            loseSound = love.audio.newSource('sounds/lose.wav', 'static')
            loseSound:setLooping(false)
            loseSound:play()
            startedMusic = true
        elseif Map.win == true and startedMusic == false then
            victorySound = love.audio.newSource('sounds/victory.wav', 'static')
            victorySound:setLooping(false)
            victorySound:play()
            startedMusic = true
        end
    elseif gameState == 'play' then
        Map:checkWinAndLoseCon()
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'r' then
        gameState = 'title'
        Map:stopMusic()
    elseif key == 'up' and gameState == 'title' then
        gridsize = math.min(gridsize + 1, 20)
    elseif key == 'down' and gameState == 'title' then
        gridsize = math.max(gridsize - 1, 10)
    elseif key == 'left' and gameState == 'title' then
        bombs = math.max(bombs - 1, 5)
    elseif key == 'right' and gameState == 'title' then
        bombs = math.min(bombs + 1, 10)
    elseif key == 'return' and gameState == 'title' then
        Map:createGrid(gridsize, bombs)
        gameState = 'play'
        startedMusic = false
    elseif key == 'up' and gameState == 'play' then
        Map:moveUp()
    elseif key == 'down' and gameState == 'play' then
        Map:moveDown()
    elseif key == 'left' and gameState == 'play' then
        Map:moveLeft()
    elseif key == 'right' and gameState == 'play' then
        Map:moveRight()
    elseif key == 'return' and gameState == 'play' then
        Map:turnTile()
    elseif key == 'space' and gameState == 'play' then
        gameState = 'pause'
        love.audio.pause()
    elseif key == 'space' and gameState == 'pause' then
        gameState = 'play'
        Map:playMusic()
    elseif key == 'return' and gameState == 'finished' then
        gameState = 'title'
        Map.win = false
        Map.lose = false
    end
end

function love.draw()
    push:apply('start')

    for i = 0, love.graphics.getWidth() / background:getWidth() do
        for j = 0, love.graphics.getHeight() / background:getHeight() do
            love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
        end
    end

    if gameState == 'title' then
        love.graphics.setFont(smallFont)
        love.graphics.print("Gridsize: " .. tostring(gridsize), 20, 20)
        love.graphics.print("Bombs: " .. tostring(bombs), 20, 40)
        love.graphics.setFont(largeFont)
        love.graphics.print("Press return to start", VIRTUAL_WIDTH/2 - 90, VIRTUAL_HEIGHT/2 - 4)
    elseif gameState == 'play' or gameState == 'pause' then
        Map:render()
        if gameState == 'pause' then
            love.graphics.print("PAUSE", 20, 20)
        end
        Map:renderBombsNearby()
    elseif gameState == 'finished' then
        love.graphics.setFont(largeFont)
        if Map.win == true then
            love.graphics.printf("Victory!", 0, 70, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Press return to get to the main screen", 0, 90, VIRTUAL_WIDTH, 'center')
        elseif Map.lose == true then
            love.graphics.printf("You lost!", 0, 70, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Press return to get to the main screen", 0, 90, VIRTUAL_WIDTH, 'center')
        end
    end
    push:apply('end')
end