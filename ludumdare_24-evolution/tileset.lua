Class = require 'hump.class'

Tileset = Class{function(self, img, size)
	self.quads = {};
	self.dobatch = false
	
	self.img = love.graphics.newImage(img)
	if self.dobatch then
		self.batch = love.graphics.newSpriteBatch(self.img, 1000)
	end
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

function Tileset:draw(img, x,y, dir, ascale, aangle, a, r, g, b)
	local angle = aangle or 0
	local scale = ascale or 1
	local half = self.size / 2
	
	r = r or 255
	g = g or 255
	b = b or 255
	a = a or 255
	
	if self.dobatch then
		self.batch:setColor(r,g,b,a)
	else
		love.graphics.setColor(r,g,b,a)
	end
	
	if dir == 4 then
		if self.dobatch then
			self.batch:addq(self.quads[img], x+self.size*scale-half, y-half, angle, -scale, scale)
		else
			love.graphics.drawq(self.img, self.quads[img], x+self.size*scale-half, y-half, angle, -scale, scale)
		end
	elseif dir == 6 then
		if self.dobatch then
			self.batch:addq(self.quads[img], x-half, y-half, angle, scale, scale)
		else
			love.graphics.drawq(self.img, self.quads[img], x-half, y-half, angle, scale, scale)
		end
	else
		assert(false, "invalid dir passed to Tileset:draw")
	end
end

function Tileset:start()
	if self.dobatch then
		self.batch:clear()
		self.batch:bind()
	end
end

function Tileset:stop()
	if self.dobatch then
		self.batch:unbind()
		love.graphics.draw(self.batch)
	end
end

