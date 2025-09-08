function beginContact(fixture_a, fixture_b, contact)
    print(fixture_a:type())
    print(fixture_b:typelove())
    print(contact:isTouching())
end

function endContact(fixture_a, fixture_b, contact) print(contact:isTouching()) end

function love.load()
    canvas = love.graphics.newCanvas(800, 600)
    hoverButton = love.graphics.newCanvas(800, 600)
    displayText = love.graphics.newCanvas(800, 600)
    cursor = love.mouse.newCursor("cursor2.png", 16, 16)
    love.mouse.setCursor(cursor)
    -- Rectangle is drawn to the canvas with the regular/default alpha blend mode ("alphamultiply").
    menu = love.physics.newWorld(0, 0, true)
    cursorBody = love.physics.newBody(menu, 25, 25, "dynamic")
    cursorShape = love.physics.newRectangleShape(32, 32)
    cursorFixture = love.physics.newFixture(cursorBody, cursorShape, 1)
    onInteractable1 = false
    interactbleClicked1 = false

    interactableBody = love.physics.newBody(menu, 150, 250, "static")
    interactableShape = love.physics.newRectangleShape(100, 100)
    interactableFixture = love.physics.newFixture(interactableBody,
                                                  interactableShape, 1)
    -- interactableFixture:setSensor(true);
    menu:setCallbacks(beginContact, endContact)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 0, 0, .5)
    love.graphics.rectangle("fill", 100, 200, 100, 100)
    love.graphics.setCanvas()
end

function love.update(dt)
    local tickPeriod = 1 / 20 -- seconds per tick
    local accumulator = 0.0
    while accumulator < tickPeriod do accumulator = accumulator + dt end
    menu:update(accumulator, 1, 1)
    local x, y = love.mouse.getPosition()
    cursorBody:setX(x)
    cursorBody:setY(y)

    -- print(cursorBody:getWorldPoints(cursorShape:getPoints()))
    local x1, y1, x2, y2 = interactableBody:getWorldPoints(
                               interactableShape:getPoints())
    if x > x1 and x < x2 and y > y1 and y > y2 then
        onInteractable1 = true
    else
        onInteractable1 = false
    end

    local down = love.mouse.isDown(1)
    if down then
        if onInteractable1 then
            if interactbleClicked1 == false then
                interactbleClicked1 = true
            end
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    if onInteractable1 then
        love.graphics.setCanvas(hoverButton)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 25, 0, 1)
        love.graphics.rectangle("fill", 100, 200, 100, 100)
        love.graphics.setCanvas(canvas)
    else
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", 100, 200, 100, 100)
    end

    if interactbleClicked1 then
        love.graphics.setCanvas(displayText)
        love.graphics.print({{0, 255, 150, 1}, "button was clicked"}, 100, 100)
        love.graphics.setCanvas(canvas)
    end

    love.graphics.polygon("line", interactableBody:getWorldPoints(
                              interactableShape:getPoints()))
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.polygon("line",
                          cursorBody:getWorldPoints(cursorShape:getPoints()))
    love.graphics.setCanvas()
    if interactbleClicked1 then
        print("hovering")
        love.graphics.draw(hoverButton)
    elseif interactbleClicked1 then
        print("clicked and displaying")
        love.graphics.draw(displayText)
    else
        print("being weird")
        love.graphics.draw(canvas)
    end
end
