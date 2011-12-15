require "oo"
vector = require "hump/vector"

class "Object"
{
	pos = vector(40,40)
}

function Object:__init(img, x,y)
	self.pos = vector(x,y)
	self.img = love.graphics.newImage(img)
end

function Object:draw()
	love.graphics.draw(self.img, self.pos:unpack())
end

function Object:update(dt)
end