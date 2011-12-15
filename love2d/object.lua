require "oo"
vector = require "hump/vector"

class "Object"
{
	pos = vector(40,40)
}

function Object:__init(x,y)
	self.pos = vector(x,y)
end

function Object:draw()
	love.graphics.print("Hello World", self.pos:unpack())
end

function Object:update(dt)
end