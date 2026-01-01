local introscene, nextScene
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

function love.load()
    introscene = love.graphics.newImage("fullcomp.png")
    nextScene = love.graphics.newImage("screen.png")
    
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
            userInput = ""
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown("space") and not gameStarted and not zoomingOut then
        gameStarted = true
    end

    if love.keyboard.isDown("escape") and (gameStarted or showFinal) then
        showFinal = false
        zoomingOut = true
        gameStarted = false
        userInput = ""
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
        love.graphics.draw(nextScene, 0, 0, 0, nextScaleX, nextScaleY)
        
        love.graphics.setFont(terminalFont)
        love.graphics.setColor(0, 1, 0)
        
        local fullText = prompt .. userInput
        local cursor = ""
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            cursor = "_"
        end
        
        love.graphics.print(fullText .. cursor, 50, 50)
    end
end
