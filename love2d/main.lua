require "world"
require "object"
require "player"
require "tilesets"
require "console"

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	world = World("level.tmx")
	tilesets:add("ninja.png", 16)
	world:add(Object("ninja.png", 100, 100, 70))
	world:add(Player(world:getCamera(), 400, 200))
end

function love.draw()
	world:draw()
	console:draw()
end

function love.update(dt)
	world:update(dt)
	console:update(dt)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	world:onkey(true, key, unicode)
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