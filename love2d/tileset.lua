Class = require 'hump.class'

Tileset = Class{function(self, img, size)
	self.quads = {};
	
	self.img = love.graphics.newImage(img)
	local w,h = size,size
	local count = 0
	for y=0,self.img:getHeight()-1,h do
		for x=0,self.img:getWidth()-1,w do
			count = count + 1
			table.insert(self.quads, love.graphics.newQuad(x,y,w,h, self.img:getWidth(), self.img:getHeight()))
		end
	end
	print(img, count)
end}

function Tileset:draw(img, x,y)
	love.graphics.drawq(self.img, self.quads[img], x, y)
end