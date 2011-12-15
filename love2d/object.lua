require "oo"
vector = require "hump/vector"
require "tileset"

class "Object"
{
	pos = vector(40,40);
	index = 1;
}

function Object:__init(img, x,y)
	self.pos = vector(x,y)
	self.img = Tileset:new(img, 16)
end

function Object:draw()
	self.img:draw(self.index, self.pos:unpack())
	--love.graphics.draw(self.img, self.pos:unpack())
end

function Object:update(dt)
end