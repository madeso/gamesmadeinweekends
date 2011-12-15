require "oo"

class "Object"
{
	x = 400;
	y = 300;
}

function Object:__init(x,y)
	self.x = x
	self.y = y
end

function Object:draw()
	love.graphics.print("Hello World", self.x, self.y)
end