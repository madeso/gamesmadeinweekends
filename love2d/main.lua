require "world"
require "object"

function love.load()
	world = World:new()
	world:add(Object:new("ninja.png", 100, 100))
	world:add(Object:new("ninja.png", 400, 200))
end

function love.draw()
    world:draw()
end

function love.update(dt)
    world:update(dt)
end
