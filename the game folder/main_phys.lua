function collisionOnEnter(fixture_a, fixture_b, contact)
    isTouching = contact:isTouching()
    print(contact:isTouching())
    return isTouching
end

-- Similar to draw, initializes and loads this code ONCE
function love.load()
    groundCategory = 1
    playerCategory = 2

    love.graphics.setColor(255,0,0)
    love.physics.setMeter(40)
    gravity = 9.81*40
    world = love.physics.newWorld(0, gravity, true)
    world:setCallbacks(collisionOnEnter)

    groundBody = love.physics.newBody(world, 400, 400, "static")
    groundShape = love.physics.newRectangleShape(600, 100)
    groundFixture = love.physics.newFixture(groundBody, groundShape, 1)
    groundFixture:setCategory(groundCategory)

    playerX = 200
    playerY = 200
    playerBody = love.physics.newBody(world, playerX, playerY, "dynamic")
    playerShape = love.physics.newRectangleShape(50, 50)
    playerFixture = love.physics.newFixture(playerBody, playerShape, 1)
    playerBody:setFixedRotation(true)
    playerFixture:setCategory(playerCategory)
    playerFixture:setMask(playerCategory)
    print('finished loading')
 end

 -- updates every frame/dt, or delta time, can do physics calculations in here.
 function love.update(dt)
    world:update(dt, 1, 1)
    local jump = love.keyboard.isDown('space')
    local x, y = playerBody:getLinearVelocity()
    if (jump and isTouching) then
        playerBody:applyLinearImpulse(0, -500)
        isTouching = false
    end
    local right = love.keyboard.isDown('d')
    local left = love.keyboard.isDown('a')
    local bodyPositionX, bodyPositionY = playerBody:getPosition()
    if right then
        playerBody:setX(bodyPositionX+(1))
        love.graphics.translate(x + 10, 0)
    elseif left then
        playerBody:setX(bodyPositionX-(1))
        love.graphics.translate(x - 10, 0)
    end

    if x > 500 then
        playerBody:setLinearVelocity(500, 0)
    end
    if x < -500 then
        playerBody:setLinearVelocity(-500, 0)
    end


 end

 -- updates every frame, draws the screen.
 function love.draw()
    love.graphics.polygon("line", playerBody:getWorldPoints(playerShape:getPoints()))
    love.graphics.polygon("line", groundBody:getWorldPoints(groundShape:getPoints()))
 end
