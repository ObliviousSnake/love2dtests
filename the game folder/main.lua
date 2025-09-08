function love.load()
    -- init physics world
    world = love.physics.newWorld()
    dimX = 800
    dimY = 600
    love.window.updateMode(dimX, dimY)
    -- init canvas
    canvas = love.graphics.newCanvas(dimX, dimY)
    mainMenuCanvas = love.graphics.newCanvas(dimX, dimY)
    settingsCanvas = love.graphics.newCanvas(dimX, dimY)
    -- init states
    gameState = {}
    mainMenuState = {}
    settingsState = {}

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
        end,
    }
end

function setUpMainMenu()
    love.graphics.setCanvas(mainMenuCanvas)

    mainMenuState.playGameObject = {
        body = love.physics.newBody(world, 200, 200, "static"),
    }
    local x, y = mainMenuState.playGameObject.body:getPosition()
    mainMenuState.playGameObject.shape = love.physics.newRectangleShape(x, y-175, 400, 50)
    mainMenuState.playGameObject.fixture = love.physics.newFixture(mainMenuState.playGameObject.body, mainMenuState.playGameObject.shape, 1)
    
    mainMenuState.settingsObject =  {
        body = love.physics.newBody(world, 200, 275, "static")
    }
    x, y = mainMenuState.settingsObject.body:getPosition()
    mainMenuState.settingsObject.shape = love.physics.newRectangleShape(x, y-250, 400, 50)
    mainMenuState.settingsObject.fixture = love.physics.newFixture(mainMenuState.settingsObject.body, mainMenuState.settingsObject.shape, 1)

    love.graphics.setColor(.8, .8, .8)
    love.graphics.polygon("fill", mainMenuState.playGameObject.body:getWorldPoints(mainMenuState.playGameObject.shape:getPoints()))
    love.graphics.polygon("fill", mainMenuState.settingsObject.body:getWorldPoints(mainMenuState.settingsObject.shape:getPoints()))

    love.graphics.print({{.4, .4, .4},"Play Game"}, 375, 220)
    love.graphics.print({{.4, .4, .4},"Settings"}, 380, 295)
    love.graphics.setCanvas()
end

function setUpSettings()
    love.graphics.setCanvas(settingsCanvas)
    settingsState.resolutionObject = {
        body = love.physics.newBody(world, 200, 200, "static"),
    }
    local x, y = settingsState.resolutionObject.body:getPosition()
    settingsState.resolutionObject.shape = love.physics.newRectangleShape(x, y-175, 400, 50)
    settingsState.resolutionObject.fixture = love.physics.newFixture(settingsState.resolutionObject.body, settingsState.resolutionObject.shape, 1)
    
    settingsState.backObject =  {
        body = love.physics.newBody(world, 200, 275, "static")
    }
    x, y = settingsState.backObject.body:getPosition()
    settingsState.backObject.shape = love.physics.newRectangleShape(x, y-250, 400, 50)
    settingsState.backObject.fixture = love.physics.newFixture(settingsState.backObject.body, settingsState.backObject.shape, 1)

    love.graphics.setColor(.8, .8, .8)
    love.graphics.polygon("fill", settingsState.resolutionObject.body:getWorldPoints(settingsState.resolutionObject.shape:getPoints()))
    love.graphics.polygon("fill", settingsState.backObject.body:getWorldPoints(settingsState.backObject.shape:getPoints()))

    love.graphics.print({{.4, .4, .4},"Resolution: ", dimX, " x ", dimY}, 375, 220)
    love.graphics.print({{.4, .4, .4},"Back to Main Menu"}, 380, 295)
    love.graphics.setCanvas()
end

function love.update(dt) 
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
    print(mainMenuState.settingsObject.body:getWorldPoints(mainMenuState.settingsObject.shape:getPoints()))
    if isInsideSettings then
        gameState.currentCanvas = settingsCanvas
        gameState.currentScreen = "settings"
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
