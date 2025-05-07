function love.load()
    love.window.setTitle("Zombie Dodge")
    love.window.setMode(800, 600)

    playerImg = love.graphics.newImage("player.png")
    zombieImg = love.graphics.newImage("zombie.png")
    hitSound = love.audio.newSource("hit.wav", "static")
    spawnSound = love.audio.newSource("spawn.wav", "static")

    player = {
        x = 400, y = 300,
        speed = 200,
        radius = 20,
        img = playerImg
    }

    zombies = {}
    spawnZombieTimer = 0
    survivalTime = 0
    gameOver = false
end

function spawnZombie()
    local side = math.random(1, 4)
    local x, y

    if side == 1 then x, y = 0, math.random(0, 600)
    elseif side == 2 then x, y = 800, math.random(0, 600)
    elseif side == 3 then x, y = math.random(0, 800), 0
    else x, y = math.random(0, 800), 600 end

    table.insert(zombies, {
        x = x, y = y,
        speed = 100,
        img = zombieImg
    })

    love.audio.play(spawnSound)
end

function love.update(dt)
    if gameOver then return end

    if love.keyboard.isDown("up") then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("down") then player.y = player.y + player.speed * dt end
    if love.keyboard.isDown("left") then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("right") then player.x = player.x + player.speed * dt end

    player.x = math.max(player.radius, math.min(800 - player.radius, player.x))
    player.y = math.max(player.radius, math.min(600 - player.radius, player.y))

    spawnZombieTimer = spawnZombieTimer - dt
    if spawnZombieTimer <= 0 then
        spawnZombie()
        spawnZombieTimer = 1
    end

    for _, z in ipairs(zombies) do
        local dx, dy = player.x - z.x, player.y - z.y
        local dist = math.sqrt(dx*dx + dy*dy)
        z.x = z.x + (dx / dist) * z.speed * dt
        z.y = z.y + (dy / dist) * z.speed * dt
    end

    for _, z in ipairs(zombies) do
        local dx, dy = player.x - z.x, player.y - z.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < player.radius + 15 then
            gameOver = true
            love.audio.play(hitSound)
        end
    end

    survivalTime = survivalTime + dt
end

function love.draw()
    if player.img then
        love.graphics.draw(player.img, player.x - 20, player.y - 20)
    end

    for _, z in ipairs(zombies) do
        love.graphics.draw(z.img, z.x - 15, z.y - 15)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Time Survived: " .. math.floor(survivalTime) .. "s", 10, 10)

    if gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER\nPress R to Restart", 0, 250, 800, "center")
    end
end

function love.keypressed(key)
    if key == "r" and gameOver then
        player.x, player.y = 400, 300
        zombies = {}
        survivalTime = 0
        gameOver = false
        spawnZombieTimer = 0
    end
end