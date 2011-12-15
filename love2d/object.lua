require "oo"
vector = require "hump/vector"
require "tilesets"

class "Object"
{
	pos = vector(40,40);
	index = 1;
}

function Object:__init(img, x,y,index)
	self.pos = vector(x,y)
	self.img = tilesets:get(img)
	if index ~= nil then
		self.index = index
	end
end

function Object:draw()
	self.img:draw(self.index, self.pos:unpack())
	--love.graphics.draw(self.img, self.pos:unpack())
end

function Object:update(dt)
end