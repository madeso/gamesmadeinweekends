function Tileset(img, size)
	local self = {}
	self.quads = {};
	self.dobatch = true
	
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
	
	local tileset = self

	function tileset:draw(img, x,y, dir, ascale, aangle, a, r, g, b)
		local angle = aangle or 0
		local scale = ascale or 1
		local half = self.size / 2
		
		r = r or 255
		g = g or r
		b = b or g
		a = a or 255
		
		if self.dobatch then
			self.batch:setColor(r,g,b,a)
		else
			love.graphics.setColor(r,g,b,a)
		end
		
		if dir == 4 then
			if self.dobatch then
				self.batch:addq(self.quads[img], x+self.size*scale-half*2, y, angle, -scale, scale, half, half)
			else
				love.graphics.drawq(self.img, self.quads[img], x+self.size*scale-half*2, y, angle, -scale, scale, half, half)
			end
		elseif dir == 6 then
			if self.dobatch then
				self.batch:addq(self.quads[img], x, y, angle, scale, scale, half, half)
			else
				love.graphics.drawq(self.img, self.quads[img], x, y, angle, scale, scale, half, half)
			end
		else
			assert(false, "invalid dir passed to Tileset:draw")
		end
	end

	function tileset:start()
		if self.dobatch then
			self.batch:clear()
			self.batch:bind()
		end
	end

	function tileset:stop()
		if self.dobatch then
			self.batch:unbind()
			love.graphics.draw(self.batch)
		end
	end

	return self
end