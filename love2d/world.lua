require "oo"
require "camera"

ATL_Loader = require("AdvTiledLoader.Loader")

class "World"
{
	objects = {};
}

function World:__init(path)
	self.map = ATL_Loader.load(path)
	self.camera = Camera:new(0,0)
end

function World:add(o)
	table.insert(self.objects, o)
end

function World:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.push()
	love.graphics.scale(self.camera.zoom)
	love.graphics.translate(self.camera.x, self.camera.y)
	
	self.map:draw()
	for i,o in ipairs(self.objects) do
		o:draw()
	end
	
	love.graphics.pop()
end

function World:getCamera()
	return self.camera
end

function World:update(dt)
	for i,o in ipairs(self.objects) do
		o:update(dt)
	end
end

function World:onkey(down, key, unicode)
	for i,o in ipairs(self.objects) do
		o:onkey(down, key, unicode)
	end
end