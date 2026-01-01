local introscene, nextScene, blueScreenImg, currentTerminalBG
local scaleX, scaleY, nextScaleX, nextScaleY
local arcadeFont, terminalFont
local gameStarted = false
local zoomingOut = false
local zoomFactor = 1
local zoomTimer = 0
local showFinal = false

local userInput = ""
local maxInputLength = 61
local prompt = "[os]$ "

local cubeImg
local cubeVisible = false
local cubeClosing = false
local cubeScale = 0
local cubeRotation = 0
local cubeSizeW = 0
local cubeSizeH = 0

function love.load()
    introscene = love.graphics.newImage("fullcomp.png")
    nextScene = love.graphics.newImage("screen.png")
    blueScreenImg = love.graphics.newImage("bluescreen.png")
    currentTerminalBG = nextScene
    
    cubeImg = love.graphics.newImage("cube.png")
    cubeSizeW = cubeImg:getWidth()
    cubeSizeH = cubeImg:getHeight()

    scaleX = love.graphics.getWidth() / introscene:getWidth()
    scaleY = love.graphics.getHeight() / introscene:getHeight()
    nextScaleX = love.graphics.getWidth() / nextScene:getWidth()
    nextScaleY = love.graphics.getHeight() / nextScene:getHeight()
    
    arcadeFont = love.graphics.newFont(24)
    terminalFont = love.graphics.newFont(18)
end

function love.textinput(t)
    if showFinal and #userInput < maxInputLength then
        userInput = userInput .. t
    end
end

function love.keypressed(key)
    if showFinal then
        if key == "backspace" then
            local byteoffset = require("utf8").offset(userInput, -1)
            if byteoffset then
                userInput = string.sub(userInput, 1, byteoffset - 1)
            end
        elseif key == "return" then
            local command = userInput:gsub("%s+", ""):lower()
            if command == "cube" then
                cubeVisible = true
                cubeClosing = false
                cubeScale = 0
                cubeRotation = 0
            elseif command == "lol" then
                currentTerminalBG = blueScreenImg
            end
            userInput = ""
        elseif key == "escape" then
            if cubeVisible then
                cubeClosing = true
            elseif currentTerminalBG == blueScreenImg then
                currentTerminalBG = nextScene
            else
                showFinal = false
                zoomingOut = true
                gameStarted = false
                userInput = ""
            end
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown("space") and not gameStarted and not zoomingOut then
        gameStarted = true
    end

    if cubeVisible then
        cubeRotation = cubeRotation + (4 * dt)
        
        if cubeClosing then
            cubeScale = cubeScale - (5 * dt)
            if cubeScale <= 0 then
                cubeScale = 0
                cubeVisible = false
                cubeClosing = false
            end
        elseif cubeScale < 1 then
            cubeScale = cubeScale + (5 * dt)
            if cubeScale > 1 then cubeScale = 1 end
        end
    end

    if gameStarted and not showFinal then
        zoomFactor = zoomFactor + (4 * dt)
        zoomTimer = zoomTimer + dt
        if zoomTimer >= 1.35 then
            showFinal = true
        end
    elseif zoomingOut then
        zoomFactor = zoomFactor - (4 * dt)
        if zoomFactor <= 1 then
            zoomFactor = 1
            zoomTimer = 0
            zoomingOut = false
        end
    end
end

function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if not showFinal then
        love.graphics.push()
        if gameStarted or zoomingOut then
            love.graphics.translate(screenWidth / 2, screenHeight / 2)
            love.graphics.scale(zoomFactor)
            love.graphics.translate(-screenWidth / 2, -screenHeight / 2)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(introscene, 0, 0, 0, scaleX, scaleY)
        love.graphics.pop()

        if not gameStarted and not zoomingOut then
            if math.floor(love.timer.getTime() / 0.6) % 2 == 0 then
                love.graphics.setColor(0, 1, 0)
            else
                love.graphics.setColor(0, 0, 1)
            end
            love.graphics.setFont(arcadeFont)
            local text = "PRESS SPACE TO START"
            local fontHeight = arcadeFont:getHeight()
            local verticalCenter = (screenHeight / 2) - (fontHeight / 2)
            love.graphics.printf(text, 0, verticalCenter, screenWidth, "center")
        end
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(currentTerminalBG, 0, 0, 0, nextScaleX, nextScaleY)
        
        if currentTerminalBG == nextScene then
            love.graphics.setFont(terminalFont)
            love.graphics.setColor(0, 1, 0)
            local fullText = prompt .. userInput
            local cursor = ""
            if math.floor(love.timer.getTime() * 2) % 2 == 0 then
                cursor = "_"
            end
            love.graphics.print(fullText .. cursor, 50, 50)
        end

        if cubeVisible then
            love.graphics.setColor(1, 1, 1, 1)
            local cx = screenWidth / 2
            local cy = screenHeight / 2
            
            local spinScaleX = math.cos(cubeRotation) * cubeScale
            
            love.graphics.draw(cubeImg, cx, cy, 0, spinScaleX, cubeScale, cubeSizeW / 2, cubeSizeH / 2)
        end
    end
end
