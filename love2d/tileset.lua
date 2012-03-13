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
	local angle = 0
	local scale = 1
	local half = self.size / 2
	if dir == 4 then
		love.graphics.drawq(self.img, self.quads[img], x+self.size*scale-half, y-half, angle, -scale, scale)
	elseif dir == 6 then
		love.graphics.drawq(self.img, self.quads[img], x-half, y-half, angle, scale, scale)
	else
		assert(false, "invalid dir passed to Tileset:draw")
	end
end