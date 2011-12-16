require "world"
require "object"
require "player"
require "tilesets"

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	world = World:new()
	tilesets:add("ninja.png", 16)
	world:add(Object:new("ninja.png", 100, 100, 70))
	world:add(Player:new(400, 200))
end

function love.draw()
    world:draw()
end

function love.update(dt)
    world:update(dt)
end

function love.keypressed(key, unicode)
	world:onkey(true, key, unicode)
end

function love.keyreleased(key)
	world:onkey(false, key, nil)
end