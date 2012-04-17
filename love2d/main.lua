require "world"
require "box"
require "player"
require "tilesets"
require "console"

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	world = World("level.tmx")
	tilesets:add("ninja.png", 16)
	world:add(Box(100, 100, 50))
	world:add(Player(world:getCamera(), 400, 20))
	canplay = 3
	deltat = 1
end

function love.draw()
	world:draw()
	console:draw()
	fps = 1/deltat
	love.graphics.setColor(0,0,0, 255)
	love.graphics.print(string.format("%d", fps), 100, 10)
end

function love.update(dt)
	deltat=dt
	if canplay==0 then
		world:update(dt)
		console:update(dt)
	else
		print(dt)
		canplay = canplay - 1
		world:update(0)
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	
	if canplay==0 then
		world:onkey(true, key, unicode)
	end
end

function love.keyreleased(key)
	world:onkey(false, key, nil)
end

function love.mousepressed(x, y, button)
	world:onkey(true, "_"..button, nil)
end

function love.mousereleased(x, y, button)
	world:onkey(false, "_"..button, nil)
end