function love.load()
    -- init physics world
    world = love.physics.newWorld()
    dimX = 1920
    dimY = 1080
    love.window.updateMode(dimX, dimY)
    -- init canvas
    canvas = love.graphics.newCanvas(dimX, dimY)
    mainMenuCanvas = love.graphics.newCanvas(dimX, dimY)
    settingsCanvas = love.graphics.newCanvas(dimX, dimY)
    -- init states
    gameState = {}
    mainMenuState = {}
    settingsState = {}
    
    resolutions = {
        [0] = function()
            dimX = 800
            dimY = 600
        end,
        [1] = function()
            dimX = 1280
            dimY = 720
        end,
        [2] = function()
            dimX = 1920
            dimY = 1080
        end
    }

    settingsState.resolution = 2
    settingsState.mouseReleased = true
    mainMenuState.mouseReleased = true
    gameState.prevTargetClicked = true
    gameState.mouseReleased = true
    gameState.currTarget = {}
    gameState.score = 0
    gameState.timer = 0
    gameState.currentScreen = "menu"
    gameState.currentCanvas = mainMenuCanvas

    -- set up scenes
    setUpMainMenu()
    setUpSettings()

    love.graphics.setCanvas(canvas)
    local r, g, b = love.math.colorFromBytes(25, 59, 138)
    love.graphics.setBackgroundColor(r, g, b)
    local font = love.graphics.newFont(24)
    plainText = love.graphics.newText(font, {{1, 1, 1}, "Your Score: ", gameState.score})
    local combinedString = "Resolution: " .. dimX .. " x " .. dimY
    local resFont = love.graphics.newFont()
    resolutionText = love.graphics.newText(resFont, {{.3, .3, .3}, combinedString})
    love.graphics.setCanvas()

    actionMap = {
        ["game"] = function(dt)
            updateMainGameState(dt) 
        end,
        ["menu"] = function(dt)
            updateMenuState(dt)
        end,
        ["settings"] = function(dt)
            updateSettingsState(dt)
        end,
    }

    canvasMap = {
        ["game"] = function()
            love.graphics.draw(canvas)
            love.graphics.draw(plainText, 312, 50)
        end,
        ["menu"] = function()
            love.graphics.draw(mainMenuCanvas)
        end,
        ["settings"] = function()
            love.graphics.draw(settingsCanvas)
            drawCenteredText(settingsState.resolutionObject.x, settingsState.resolutionObject.y, settingsState.resolutionObject.width, settingsState.resolutionObject.height / 8, resolutionText)
        end,
    }
end

function setUpMainMenu()
    love.graphics.setCanvas(mainMenuCanvas)

    mainMenuState.playGameObject = {}
    mainMenuState.playGameObject.x = dimX * .25
    mainMenuState.playGameObject.y = dimY * .33
    mainMenuState.playGameObject.width = dimX * .5
    mainMenuState.playGameObject.height = dimY * .083
    mainMenuState.playGameObject.body = love.physics.newBody(world, mainMenuState.playGameObject.x, mainMenuState.playGameObject.y, "static")
    mainMenuState.playGameObject.shape = love.physics.newRectangleShape(mainMenuState.playGameObject.x, 0, mainMenuState.playGameObject.width, mainMenuState.playGameObject.height)
    mainMenuState.playGameObject.fixture = love.physics.newFixture(mainMenuState.playGameObject.body, mainMenuState.playGameObject.shape, 1)
    
    mainMenuState.settingsObject = {}
    mainMenuState.settingsObject.x = dimX * .25
    mainMenuState.settingsObject.y = dimY * .458
    mainMenuState.settingsObject.width =  dimX * .5
    mainMenuState.settingsObject.height = dimY * .083
    mainMenuState.settingsObject.body = love.physics.newBody(world, mainMenuState.settingsObject.x, mainMenuState.settingsObject.y, "static")
    mainMenuState.settingsObject.shape = love.physics.newRectangleShape(mainMenuState.settingsObject.x, 0, mainMenuState.settingsObject.width, mainMenuState.settingsObject.height)
    mainMenuState.settingsObject.fixture = love.physics.newFixture(mainMenuState.settingsObject.body, mainMenuState.settingsObject.shape, 1)

    mainMenuState.exitObject = {}
    mainMenuState.exitObject.x = dimX * .25
    mainMenuState.exitObject.y = dimY * .576
    mainMenuState.exitObject.width =  dimX * .5
    mainMenuState.exitObject.height = dimY * .083
    mainMenuState.exitObject.body = love.physics.newBody(world, mainMenuState.exitObject.x, mainMenuState.exitObject.y, "static")
    mainMenuState.exitObject.shape = love.physics.newRectangleShape(mainMenuState.exitObject.x, 0, mainMenuState.exitObject.width, mainMenuState.exitObject.height)
    mainMenuState.exitObject.fixture = love.physics.newFixture(mainMenuState.exitObject.body, mainMenuState.exitObject.shape, 1)

    love.graphics.setColor(.8, .8, .8)
    love.graphics.polygon("fill", mainMenuState.playGameObject.body:getWorldPoints(mainMenuState.playGameObject.shape:getPoints()))
    love.graphics.polygon("fill", mainMenuState.settingsObject.body:getWorldPoints(mainMenuState.settingsObject.shape:getPoints()))
    love.graphics.polygon("fill", mainMenuState.exitObject.body:getWorldPoints(mainMenuState.exitObject.shape:getPoints()))

    local font = love.graphics.getFont()
    local playGameText = love.graphics.newText(font, {{.4, .4, .4}, "Play Game"})
    local settingsText = love.graphics.newText(font, {{.4, .4, .4}, "Settings"})
    local exitText = love.graphics.newText(font, {{.4, .4, .4}, "Exit"})
    drawCenteredText(mainMenuState.playGameObject.x, mainMenuState.playGameObject.y, mainMenuState.playGameObject.width, mainMenuState.playGameObject.height / 8, playGameText) --no clue why i have to divide by 8 on the height...
    drawCenteredText(mainMenuState.settingsObject.x, mainMenuState.settingsObject.y, mainMenuState.settingsObject.width, mainMenuState.settingsObject.height / 8, settingsText)
    drawCenteredText(mainMenuState.exitObject.x, mainMenuState.exitObject.y, mainMenuState.exitObject.width, mainMenuState.exitObject.height / 8, exitText)
    love.graphics.setCanvas()
end

function setUpSettings()
    love.graphics.setCanvas(settingsCanvas)
    settingsState.resolutionObject = {}
    settingsState.resolutionObject.x = dimX * .25
    settingsState.resolutionObject.y = dimY * .33
    settingsState.resolutionObject.width = dimX * .5
    settingsState.resolutionObject.height = dimY * .083
    settingsState.resolutionObject.body = love.physics.newBody(world, settingsState.resolutionObject.x, settingsState.resolutionObject.y, "static")
    settingsState.resolutionObject.shape = love.physics.newRectangleShape(settingsState.resolutionObject.x, 0, settingsState.resolutionObject.width, settingsState.resolutionObject.height)
    settingsState.resolutionObject.fixture = love.physics.newFixture(settingsState.resolutionObject.body, settingsState.resolutionObject.shape, 1)
    
    settingsState.backObject = {}
    settingsState.backObject.x = dimX * .25
    settingsState.backObject.y = dimY * .458
    settingsState.backObject.width = dimX * .5
    settingsState.backObject.height = dimY * .083
    settingsState.backObject.body = love.physics.newBody(world, settingsState.backObject.x, settingsState.backObject.y, "static")
    settingsState.backObject.shape = love.physics.newRectangleShape(settingsState.backObject.x, 0, settingsState.backObject.width, settingsState.backObject.height)
    settingsState.backObject.fixture = love.physics.newFixture(settingsState.backObject.body, settingsState.backObject.shape, 1)

    love.graphics.setColor(.8, .8, .8)
    love.graphics.polygon("fill", settingsState.resolutionObject.body:getWorldPoints(settingsState.resolutionObject.shape:getPoints()))
    love.graphics.polygon("fill", settingsState.backObject.body:getWorldPoints(settingsState.backObject.shape:getPoints()))

    local font = love.graphics.getFont()
    local backText = love.graphics.newText(font, {{.4, .4, .4}, "Back to Main Menu"})
    drawCenteredText(settingsState.backObject.x, settingsState.backObject.y, settingsState.backObject.width, settingsState.backObject.height / 8, backText)
    love.graphics.setCanvas()
end

function love.update(dt) 
    world:update(dt)
    local action = actionMap[gameState.currentScreen]
    action(dt)
end

function love.keypressed(key, scancode, isrepeat)
    handleKeyPress(key)
end

function love.draw()
    local drawCanvas = canvasMap[gameState.currentScreen]
    drawCanvas()
end





-- PRIVATE FUNCTIONS

-- STATE MANAGEMENT ----
function updateMainGameState(dt)
    gameState.timer = gameState.timer + dt
    if gameState.timer > 5 and gameState.currTarget then handleTimer() end

    -- Randomly create and draw circles, add to table.
    if gameState.prevTargetClicked then createRandomCircle() end

    -- Shoot the target boom
    gameState.mouseDown = love.mouse.isDown(1)
    if gameState.mouseDown and gameState.mouseReleased then handleClickGame() end

    -- ensure user releases mouse
    gameState.mouseReleased = not love.mouse.isDown(1)
end

function updateMenuState(dt)
    mainMenuState.mouseDown = love.mouse.isDown(1)

    if mainMenuState.mouseDown and mainMenuState.mouseReleased then handleClickMenu() end


    mainMenuState.mouseReleased = not love.mouse.isDown(1)
end

function updateSettingsState(dt)
    settingsState.mouseDown = love.mouse.isDown(1)
    if settingsState.mouseDown and settingsState.mouseReleased then handleClickSettings() end
    settingsState.mouseReleased = not love.mouse.isDown(1)
end

--- HANDLE CLICKS AND KEY PRESS ---
function handleClickMenu()
    local x, y = love.mouse.getPosition()
    local isInsideGame = mainMenuState.playGameObject.fixture:testPoint(x, y)

    if isInsideGame then
        gameState.currentCanvas = canvas
        gameState.currentScreen = "game"
    end

    local isInsideSettings = mainMenuState.settingsObject.fixture:testPoint(x, y)
    if isInsideSettings then
        gameState.currentCanvas = settingsCanvas
        gameState.currentScreen = "settings"
    end

    local isInsideExit = mainMenuState.exitObject.fixture:testPoint(x, y)
    if isInsideExit then
        love.event.quit(true)
        love.window.close()
    end
end

function handleClickSettings()
    local x, y = love.mouse.getPosition()
    local isInsideResolution = settingsState.resolutionObject.fixture:testPoint(x, y)

    if isInsideResolution then
        local res = (settingsState.resolution + 1) % 3
        settingsState.resolution = res
        local setRes = resolutions[res]
        setRes()
        local combinedString = "Resolution: " .. dimX .. " x " .. dimY
        resolutionText:set({{.3, .3, .3}, combinedString})
        love.window.updateMode(dimX, dimY)

        setUpMainMenu()
        setUpSettings()
    end

    local isInsideBack = settingsState.backObject.fixture:testPoint(x,y)

    if isInsideBack then
        gameState.currentScreen = "menu"
    end
end

function handleKeyPress(key)
    if key == "q" then
        gameState.currentScreen = "menu"
    end
end

function handleClickGame()
    local x, y = love.mouse.getPosition()
    local radius = gameState.currTarget.currShape:getRadius()
    local isInside = gameState.currTarget.currFixture:testPoint(x, y)

    if isInside then
        gameState.prevTargetClicked = true
        gameState.score = gameState.score + getScore(radius)
        plainText:set({{1, 1, 1}, "Your Score: ", gameState.score})
        gameState.timer = 0
        gameState.currTarget = {}
        -- Clean up the screen
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setCanvas()
    end

    gameState.mouseReleased = false
end

--- CORE GAME ---
function createRandomCircle()
    local randX = love.math.random(100, 700)
    local randY = love.math.random(100, 500)
    local randRadius = love.math.random(5, 20)

    -- Set up physics body
    local targetBody = love.physics.newBody(world, randX, randY, "static")
    local targetShape = love.physics.newCircleShape(randRadius)
    local targetFixture = love.physics.newFixture(targetBody, targetShape, 1)
    gameState.currTarget.currBody = targetBody
    gameState.currTarget.currShape = targetShape
    gameState.currTarget.currFixture = targetFixture
    -- Draw the circle
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", randX, randY, randRadius)
    love.graphics.setCanvas(canvas)
    local leftover = randRadius % 2
    local newRadius = randRadius
    if leftover > 0 then newRadius = randRadius - leftover end

    for i = 0, newRadius - 2, 4 do

        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", randX, randY, newRadius - i)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", randX, randY, randRadius - (i + 2))
    end

    love.graphics.setCanvas()

    -- Don't let it create a new shape until clicked
    gameState.prevTargetClicked = false
    gameState.timer = 0
end


--- MISC ---
function handleTimer()
    local radius = gameState.currTarget.currShape:getRadius()
    gameState.prevTargetClicked = true
    gameState.score = gameState.score - getScore(radius)
    plainText:set({{1, 1, 1}, "Your Score: ", gameState.score})

    -- Clean up the screen
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setCanvas()
    gameState.timer = 0
end

function getScore(radius)
    if radius < 10 then
        return 20
    elseif radius < 15 then
        return 15
    else
        return 10
    end
end

function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
    local font = love.graphics.getFont()
    local textWidth = text:getWidth()
    local textHeight = text:getHeight()
    love.graphics.draw(text, rectX + rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end