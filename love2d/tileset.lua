Class = require 'hump.class'

Tileset = Class{function(self, img, size)
	self.quads = {};
	
	self.img = love.graphics.newImage(img)
	self.img:setWrap('clamp', 'clamp')
	self.img:setFilter('nearest', 'nearest')
	self.size = size
	local w,h = size,size
	local count = 0
	for y=0,self.img:getHeight()-1,h do
		for x=0,self.img:getWidth()-1,w do
			count = count + 1
			
			local q = love.graphics.newQuad(x,y,w,h, self.img:getWidth(), self.img:getHeight())
			
			table.insert(self.quads, q)
		end
	end
	print(img, count)
end}

function Tileset:draw(img, x,y, dir)
	if dir then
		love.graphics.drawq(self.img, self.quads[img], x+self.size, y, 0, -1, 1)
	else
		love.graphics.drawq(self.img, self.quads[img], x, y)
	end
end