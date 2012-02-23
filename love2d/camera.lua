require "oo"

class "Camera"
{
	x=0;
	y=0;
	zoom=1;
}

function Camera:__init(x,y)
	self.x,self.y=x,y
end

function Camera:target(x,y)
	self.x,self.y=-x+love.graphics.getWidth()/2,-y+love.graphics.getHeight()/2
end

function Camera:update(dt)
end

function Camera:getWorldFromView(x,y)
	return x-self.x, y-self.y
end