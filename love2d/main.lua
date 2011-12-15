require "world"
require "object"

function love.load()
	world = World:new()
	world:add(Object:new(100, 20))
	world:add(Object:new(400, 200))
end

function love.draw()
    world:draw()
end