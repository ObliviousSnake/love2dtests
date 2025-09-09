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
    pauseMenu = love.graphics.newCanvas(dimX, dimY)
    -- init states
    gameState = {}
    mainMenuState = {}
    settingsState = {}
    pauseMenuState = {}
    
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
    mousePressed = false
    mouseReleased = true
    settingsState.mouseReleased = true
    mainMenuState.mouseReleased = true
    gameState.mouseReleased = true
    gameState.prevTargetClicked = true
    gameState.currTarget = {}
    gameState.score = 0
    gameState.timer = 0
    gameState.currentScreen = "menu"
    gameState.previousScreen = ""

    -- set up scenes
    setUpMainMenu()
    setUpSettings()
    setUpPauseMenu()

    love.graphics.setCanvas(canvas)
    local r, g, b = love.math.colorFromBytes(25, 59, 138)
    love.graphics.setBackgroundColor(r, g, b)
    local font = love.graphics.newFont((settingsState.resolution + 1) * 12)
    plainText = love.graphics.newText(font, {{1, 1, 1}, "Your Score: ", gameState.score})
    local combinedString = "Resolution: " .. dimX .. " x " .. dimY
    local resFont = love.graphics.newFont((settingsState.resolution + 1) * 12)
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
        ["pause"] = function(dt)
            updatePauseState(dt)
        end
    }

    canvasMap = {
        ["game"] = function()
            love.graphics.draw(canvas)
            drawCenteredText(0, dimY * .02, dimX, dimY * .05 / 8, plainText)
        end,
        ["menu"] = function()
            love.graphics.draw(mainMenuCanvas)
        end,
        ["settings"] = function()
            love.graphics.draw(settingsCanvas)
            drawCenteredText(settingsState.resolutionObject.x, settingsState.resolutionObject.y, settingsState.resolutionObject.width, settingsState.resolutionObject.height / 8, resolutionText)
        end,
        ["pause"] = function()
            love.graphics.draw(canvas)
            drawCenteredText(0, dimY * .02, dimX, dimY * .05 / 8, plainText)
            love.graphics.draw(pauseMenu)
        end
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

    local font = love.graphics.newFont((settingsState.resolution + 1) * 12)
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

    local font = love.graphics.newFont((settingsState.resolution + 1) * 12)
    local backText = love.graphics.newText(font, {{.4, .4, .4}, "Back"})
    drawCenteredText(settingsState.backObject.x, settingsState.backObject.y, settingsState.backObject.width, settingsState.backObject.height / 8, backText)
    love.graphics.setCanvas()
end

function setUpPauseMenu()
    love.graphics.setCanvas(pauseMenu)
    -- container
    pauseMenuState.container = {}
    pauseMenuState.container.x = dimX / 2
    pauseMenuState.container.y = dimY / 2
    pauseMenuState.container.width = dimX * .25
    pauseMenuState.container.height = dimY * .5
    pauseMenuState.container.body = love.physics.newBody(world, pauseMenuState.container.x, pauseMenuState.container.y, "static")
    pauseMenuState.container.shape = love.physics.newRectangleShape(0, 0, pauseMenuState.container.width, pauseMenuState.container.height)
    pauseMenuState.container.fixture = love.physics.newFixture(pauseMenuState.container.body, pauseMenuState.container.shape, 1)

    -- resume
    pauseMenuState.resumeButton = {}
    pauseMenuState.resumeButton.x = pauseMenuState.container.x
    pauseMenuState.resumeButton.y = pauseMenuState.container.y - (dimY * .15)
    pauseMenuState.resumeButton.width = pauseMenuState.container.width * .8
    pauseMenuState.resumeButton.height = pauseMenuState.container.height * .2
    pauseMenuState.resumeButton.body = love.physics.newBody(world, pauseMenuState.resumeButton.x, pauseMenuState.resumeButton.y, "static")
    pauseMenuState.resumeButton.shape = love.physics.newRectangleShape(0, 0, pauseMenuState.resumeButton.width, pauseMenuState.resumeButton.height)
    pauseMenuState.resumeButton.fixture = love.physics.newFixture(pauseMenuState.resumeButton.body, pauseMenuState.resumeButton.shape, 1)

    -- settings
    pauseMenuState.settingsButton = {}
    pauseMenuState.settingsButton.x = pauseMenuState.container.x
    pauseMenuState.settingsButton.y = pauseMenuState.container.y
    pauseMenuState.settingsButton.width = pauseMenuState.container.width * .8
    pauseMenuState.settingsButton.height = pauseMenuState.container.height * .2
    pauseMenuState.settingsButton.body = love.physics.newBody(world, pauseMenuState.settingsButton.x, pauseMenuState.settingsButton.y, "static")
    pauseMenuState.settingsButton.shape = love.physics.newRectangleShape(0, 0, pauseMenuState.settingsButton.width, pauseMenuState.settingsButton.height)
    pauseMenuState.settingsButton.fixture = love.physics.newFixture(pauseMenuState.settingsButton.body, pauseMenuState.settingsButton.shape, 1)
    
    -- back to menu
    pauseMenuState.menuButton = {}
    pauseMenuState.menuButton.x = pauseMenuState.container.x
    pauseMenuState.menuButton.y = pauseMenuState.container.y + (dimY * .15)
    pauseMenuState.menuButton.width = pauseMenuState.container.width * .8
    pauseMenuState.menuButton.height = pauseMenuState.container.height * .2
    pauseMenuState.menuButton.body = love.physics.newBody(world, pauseMenuState.menuButton.x, pauseMenuState.menuButton.y, "static")
    pauseMenuState.menuButton.shape = love.physics.newRectangleShape(0, 0, pauseMenuState.menuButton.width, pauseMenuState.menuButton.height)
    pauseMenuState.menuButton.fixture = love.physics.newFixture(pauseMenuState.menuButton.body, pauseMenuState.menuButton.shape, 1)

    love.graphics.setColor(.9, .9, .9, .8)
    love.graphics.polygon("fill", pauseMenuState.container.body:getWorldPoints(pauseMenuState.container.shape:getPoints()))
    love.graphics.setColor(0, 0, 0, 1) -- set color to black for line only
    love.graphics.setLineWidth(2) -- optional: make the outline more visible
    love.graphics.polygon("line", pauseMenuState.container.body:getWorldPoints(pauseMenuState.container.shape:getPoints()))

    love.graphics.setColor(.9, .9, .9)
    love.graphics.polygon("fill", pauseMenuState.resumeButton.body:getWorldPoints(pauseMenuState.resumeButton.shape:getPoints()))
    love.graphics.setColor(0, 0, 0, 1) -- set color to black for line only
    love.graphics.setLineWidth(2) -- optional: make the outline more visible
    love.graphics.polygon("line", pauseMenuState.resumeButton.body:getWorldPoints(pauseMenuState.resumeButton.shape:getPoints()))
    love.graphics.setColor(0,0,0)
    local font = love.graphics.newFont((settingsState.resolution + 1) * 12)
    local resumeText = love.graphics.newText(font, "Resume")
    local x1, y1 = pauseMenuState.resumeButton.body:getWorldPoints(pauseMenuState.resumeButton.shape:getPoints())
    drawCenteredText(x1, y1, pauseMenuState.resumeButton.width, pauseMenuState.resumeButton.height, resumeText)

    love.graphics.setColor(.9, .9, .9)
    love.graphics.polygon("fill", pauseMenuState.settingsButton.body:getWorldPoints(pauseMenuState.settingsButton.shape:getPoints()))
    love.graphics.setColor(0, 0, 0, 1) -- set color to black for line only
    love.graphics.setLineWidth(2) -- optional: make the outline more visible
    love.graphics.polygon("line", pauseMenuState.settingsButton.body:getWorldPoints(pauseMenuState.settingsButton.shape:getPoints()))
    local settingsText = love.graphics.newText(font, "Settings")
    x1, y1 = pauseMenuState.settingsButton.body:getWorldPoints(pauseMenuState.settingsButton.shape:getPoints())
    drawCenteredText(x1, y1, pauseMenuState.settingsButton.width, pauseMenuState.settingsButton.height, settingsText)

    love.graphics.setColor(.9, .9, .9)
    love.graphics.polygon("fill", pauseMenuState.menuButton.body:getWorldPoints(pauseMenuState.menuButton.shape:getPoints()))
    love.graphics.setColor(0, 0, 0, 1) -- set color to black for line only
    love.graphics.setLineWidth(2) -- optional: make the outline more visible
    love.graphics.polygon("line", pauseMenuState.menuButton.body:getWorldPoints(pauseMenuState.menuButton.shape:getPoints()))
    local menuText = love.graphics.newText(font, "Exit to Main Menu")
    x1, y1 = pauseMenuState.menuButton.body:getWorldPoints(pauseMenuState.menuButton.shape:getPoints())
    drawCenteredText(x1, y1, pauseMenuState.menuButton.width, pauseMenuState.menuButton.height, menuText)

    love.graphics.setColor(1, 1, 1, 1) -- reset color to white for text
    love.graphics.setCanvas()

end

function love.update(dt) 
    world:update(dt)
    mouseX, mouseY = love.mouse.getPosition()
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
    mousePressed = love.mouse.isDown(1)
    if mousePressed and mouseReleased then handleClickGame() end

    -- ensure user releases mouse
    mouseReleased = not love.mouse.isDown(1)
end

function updateMenuState(dt)
    mousePressed = love.mouse.isDown(1)

    if mousePressed and mouseReleased then handleClickMenu() end

    mouseReleased = not love.mouse.isDown(1)
end

function updateSettingsState(dt)
    mousePressed = love.mouse.isDown(1)
    if mousePressed and mouseReleased then handleClickSettings() end
    mouseReleased = not love.mouse.isDown(1)
end

function updatePauseState(dt)
    mousePressed = love.mouse.isDown(1)
    if mousePressed and mouseReleased then handleClickPause() end
    mouseReleased = not love.mouse.isDown(1)
end

--- HANDLE CLICKS AND KEY PRESS ---
function handleClickMenu()
    local isInsideGame = mainMenuState.playGameObject.fixture:testPoint(mouseX, mouseY)

    if isInsideGame then
        gameState.currentCanvas = canvas
        gameState.currentScreen = "game"
        gameState.previousScreen = "menu"
    end

    local isInsideSettings = mainMenuState.settingsObject.fixture:testPoint(mouseX, mouseY)
    if isInsideSettings then
        gameState.currentCanvas = settingsCanvas
        gameState.currentScreen = "settings"
        gameState.previousScreen = "menu"
    end

    local isInsideExit = mainMenuState.exitObject.fixture:testPoint(mouseX, mouseY)
    if isInsideExit then
        love.event.quit(true)
        love.window.close()
    end
end

function handleClickSettings()
    local isInsideResolution = settingsState.resolutionObject.fixture:testPoint(mouseX, mouseY)

    if isInsideResolution then
        local res = (settingsState.resolution + 1) % 3
        settingsState.resolution = res
        local setRes = resolutions[res]
        setRes()
        local combinedString = "Resolution: " .. dimX .. " x " .. dimY
        local font = love.graphics.newFont((settingsState.resolution + 1) * 12)
        resolutionText:setFont(font)
        resolutionText:set({{.3, .3, .3}, combinedString})
        love.window.updateMode(dimX, dimY)

        canvas = love.graphics.newCanvas(dimX, dimY)
        mainMenuCanvas = love.graphics.newCanvas(dimX, dimY)
        settingsCanvas = love.graphics.newCanvas(dimX, dimY)
        gameState.prevTargetClicked = true
        gameState.timer = 0

        setUpMainMenu()
        setUpSettings()
        setUpPauseMenu()
    end

    local isInsideBack = settingsState.backObject.fixture:testPoint(mouseX,mouseY)

    if isInsideBack then
        gameState.currentScreen = gameState.previousScreen
        gameState.previousScreen = "settings"
    end
end

function handleClickPause()
    local isResume = pauseMenuState.resumeButton.fixture:testPoint(mouseX, mouseY)

    if isResume then
        gameState.currentScreen = "game"
        gameState.previousScreen = "pause"
    end

    local isSettings = pauseMenuState.settingsButton.fixture:testPoint(mouseX, mouseY)

    if isSettings then
        gameState.currentScreen = "settings"
        gameState.previousScreen = "pause"
    end

    local isMenu = pauseMenuState.menuButton.fixture:testPoint(mouseX, mouseY)

    if isMenu then
        gameState.currentScreen = "menu"
        gameState.previousScreen = "pause"
    end
end

function handleKeyPress(key)
    if key == "escape" and gameState.currentScreen == "game" then
        gameState.currentScreen = "pause"
    end
    if key == "q" then
        gameState.currentScreen = "menu"
    end
end

function handleClickGame()
    local radius = gameState.currTarget.currShape:getRadius()
    local isInside = gameState.currTarget.currFixture:testPoint(mouseX, mouseY)

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
    local randX = love.math.random(100, dimX - 100)
    local randY = love.math.random(100, dimY - 100)
    local randRadius = love.math.random(5, dimX * .025)

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
    if radius < dimX * .00625 * 2 then
        return 20
    elseif radius < dimX * .00625 * 3 then
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