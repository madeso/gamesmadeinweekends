require "world"
require "object"
require "tilesets"

function love.load()
	world = World:new()
	tilesets:add("ninja.png", 16)
	world:add(Object:new("ninja.png", 100, 100, 70))
	world:add(Object:new("ninja.png", 400, 200))
end

function love.draw()
    world:draw()
end

function love.update(dt)
    world:update(dt)
end
