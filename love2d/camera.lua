Class = require 'hump.class'

Camera = Class{function (self,x,y)
	self.zoom=1;
	self.x,self.y=x,y
end}

function Camera:target(x,y)
	self.x,self.y=-x+love.graphics.getWidth()/2,-y+love.graphics.getHeight()/2
end

function Camera:update(dt)
end

function Camera:getWorldFromView(x,y)
	return x-self.x, y-self.y
end