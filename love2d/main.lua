require "world"
require "object"
require "player"
require "tilesets"
require "console"

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	world = World:new("level.tmx")
	tilesets:add("ninja.png", 16)
	world:add(Object:new("ninja.png", 100, 100, 70))
	world:add(Player:new(world:getCamera(), 400, 200))
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
	world:onkey(true, key, unicode)
end

function love.keyreleased(key)
	world:onkey(false, key, nil)
end