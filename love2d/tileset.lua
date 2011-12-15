require "oo"

class "Tileset"
{
	quads = {};
}

function Tileset:__init(img, size)
	self.img = love.graphics.newImage(img)
	local w,h = size,size
	for y=0,self.img:getHeight(),h do
		for x=0,self.img:getWidth(),w do
			table.insert(self.quads, love.graphics.newQuad(x,y,w,h, self.img:getWidth(), self.img:getHeight()))
		end
	end
end

function Tileset:draw(img, x,y)
	love.graphics.drawq(self.img, self.quads[img], x, y)
end